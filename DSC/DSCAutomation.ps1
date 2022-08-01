#Get DSC Files from GitHub
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
wget https://github.com/evanjd711/PowershellProjects/archive/refs/heads/main.zip -UseBasicParsing -OutFile $env:ProgramFiles\DSC.zip
Expand-Archive $env:ProgramFiles\DSC.zip -DestinationPath $env:ProgramFiles\DSC\

#Install DSC web server
$DSCPath = "$env:ProgramFiles\DSC\PowershellProjects-main\DSC\InitialConfigs\"
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
cd ..\Configuration\Chrome\
Publish-MofToPullServer -FullName .\Chrome.mof -PullServerWebConfig C:\inetpub\PSDSCPullServer\web.config

#Client enrollment
$Hostname = hostname
$Computers = Get-ADComputer -filter *| Where-Object name -NotLike $Hostname | Select-Object -ExpandProperty Name
foreach ($Computer in $Computers) {
    Copy-Item -Path $DSCPath\PullClientConfigID.ps1 -Destination 'C:\' -toSession (New-PSSession -ComputerName $Computer)
}
$RegistrationKey = Get-Content 'C:\Program Files\WindowsPowerShell\DscService\RegistrationKeys.txt'
Invoke-Command $Computers -ScriptBlock {
    $Path = Get-Location
    . "C:\PullClientConfigID.ps1"
    PullClientConfigID -DSCServerFQDN $Using:Hostname -Configurations ('OSQuery', 'Chrome') -RegistrationKey $Using:RegistrationKey
    Start-DscConfiguration -Path "$Path\PullClientConfigID\localhost.meta.mof"
    reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v DSCAutomationHostEnabled /t REG_DWORD /d 1 /f
    Restart-Computer -Force
}
