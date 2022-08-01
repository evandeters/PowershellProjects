#Get DSC Files from GitHub
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
wget https://github.com/evanjd711/PowershellProjects/archive/refs/heads/main.zip -UseBasicParsing -OutFile $env:ProgramFiles\DSC.zip
Expand-Archive $env:ProgramFiles\DSC.zip -DestinationPath $env:ProgramFiles\DSC\

#Install DSC web server
cd $env:ProgramFiles\DSC\PowershellProjects-main\DSC\InitialConfigs\
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
New-SMBShare -Name "DSCClients" -Path "$env:ProgramFiles\DSC\PowershellProjects-main\DSC\InitialConfigs\" -FullAccess "Everyone"

$Computers = Get-ADComputer -filter * | Select-Object -ExpandProperty Name
$Hostname = hostname
Invoke-Command $Computers -ScriptBlock {
    mkdir C:\DSC
    $RegistrationKey = Get-Content 'C:\Program Files\WindowsPowerShell\DscService\RegistrationKeys.txt'
    cp \\$Hostname\DSCClients\PullClientConfig\PullClientConfigID.ps1 C:\DSC\ClientConfig.ps1
    . "C:\DSS\ClientConfig.ps1"
    PullClientConfigID -DSCServerFQDN $Hostname -Configurations ('OSQuery', 'Chrome') -RegistrationKey $RegistrationKey
    Start-DscConfiguration -Path "C:\DSC\PullClientConfigID"
    reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v DSCAutomationHostEnabled /t REG_DWORD /d 1 /f
    Restart-Computer
}
