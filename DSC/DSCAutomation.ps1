#Get DSC Files from GitHub
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
wget https://github.com/evanjd711/PowershellProjects/archive/refs/heads/main.zip -UseBasicParsing -OutFile $env:ProgramFiles\DSC.zip
Expand-Archive $env:ProgramFiles\DSC.zip -DestinationPath $env:ProgramFiles\DSC\

#Install DSC web server
$DSCPath = $env:ProgramFiles\DSC\PowershellProjects-main\DSC\InitialConfigs\
cd $DSCPath
Install-Module xPSDesiredStateConfiguration -Confirm:$false
. .\DscWebServiceRegistration.ps1
New_xDscPullServer -RegistrationKey (New-Guid).Guid
Start-DscConfiguration .\New_xDscPullServer

#Add configurations to Pull Server
Install-Module cChoco -Confirm:$false
Compress-Archive -Path $env:ProgramFiles\WindowsPowerShell\Modules\cChoco -DestinationPath $env:ProgramFiles\WindowsPowerShell\DscService\Modules\cChoco_2.5.0.0.zip 
New-DscChecksum -Path $env:ProgramFiles\WindowsPowerShell\DscService\Modules\cChoco_2.5.0.0.zip 
cd ..\Configuration\OSQuery\
Publish-MofToPullServer -FullName .\OSQuery.mof -PullServerWebConfig C:\inetpub\PSDSCPullServer\web.config

#Client enrollment
New-SMBShare -Name "DSCClients" -Path $DSCPath -FullAccess "Everyone"

$Computers = Get-ADComputer -filter * | Select-Object -ExpandProperty Name
$Computers | %{New-PSSession -ComputerName $_; Copy-Item -Path $DSCPath\PullClientConfigID.ps1 -Destination 'C:\' -toSession (Get-PSSession -ComputerName $_)}
$Hostname = hostname
$RegistrationKey = Get-Content 'C:\Program Files\WindowsPowerShell\DscService\RegistrationKeys.txt'
Invoke-Command $Computers -ScriptBlock {
    . "C:\ClientConfig.ps1"
    PullClientConfigID -DSCServerFQDN $Hostname -Configurations ('OSQuery', 'Chrome') -RegistrationKey $Using:RegistrationKey
    Start-DscConfiguration -Path "C:\PullClientConfigID"
    reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v DSCAutomationHostEnabled /t REG_DWORD /d 1 /f
    Restart-Computer
}
