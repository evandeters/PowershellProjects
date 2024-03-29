#Get DSC Files from GitHub
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
wget https://github.com/evanjd711/PowershellProjects/archive/refs/heads/main.zip -UseBasicParsing -OutFile $env:ProgramFiles\DSC.zip
Expand-Archive $env:ProgramFiles\DSC.zip -DestinationPath $env:ProgramFiles\DSC\

#Install DSC web server
$DSCPath = "$env:ProgramFiles\DSC\PowershellProjects-main\DSC\InitialConfigs\"
cd $DSCPath
Install-Module xPSDesiredStateConfiguration -Confirm:$false -Force
Install-Module xNetworking -Confirm:$false -Force
. .\DscWebServiceRegistration.ps1
New_xDscPullServer -RegistrationKey (New-Guid).Guid
Start-DscConfiguration .\New_xDscPullServer -Wait -Verbose

#Add configurations to Pull Server
Install-Module cChoco -Confirm:$false -RequiredVersion 2.5.0.0 -Force
Compress-Archive -Path "$env:ProgramFiles\WindowsPowerShell\Modules\cChoco\2.5.0.0\*" -DestinationPath "$env:ProgramFiles\WindowsPowerShell\DscService\Modules\cChoco_2.5.0.0.zip" 
New-DscChecksum -Path "$env:ProgramFiles\WindowsPowerShell\DscService\Modules\cChoco_2.5.0.0.zip"
cd ..\Configuration\PackageInstaller
. .\57d5a302-c2cd-49ab-a566-d6947a033043.ps1
PackageInstaller -OutputPath .\
Rename-Item -Path .\localhost.mof .\57d5a302-c2cd-49ab-a566-d6947a033043.mof
New-DscChecksum .\
Publish-MofToPullServer -FullName ".\57d5a302-c2cd-49ab-a566-d6947a033043.mof" -PullServerWebConfig "C:\inetpub\PSDSCPullServer\web.config"

#Client enrollment
$Hostname = hostname
$Computers = Get-ADComputer -filter *| Where-Object name -NotLike $Hostname | Select-Object -ExpandProperty Name
foreach ($Computer in $Computers) {
    Copy-Item -Path $DSCPath\PullClientConfigID.ps1 -Destination 'C:\' -toSession (New-PSSession -ComputerName $Computer)
}
$RegistrationKey = Get-Content 'C:\Program Files\WindowsPowerShell\DscService\RegistrationKeys.txt'
Invoke-Command $Computers -ScriptBlock {
    Set-ExecutionPolicy RemoteSigned
    Unblock-File "C:\PullClientConfigID.ps1"
    Import-Module PSDesiredStateConfiguration
    $Path = Get-Location
    . "C:\PullClientConfigID.ps1"
    PullClientConfigID -DSCServerFQDN $Using:Hostname -RegistrationKey $Using:RegistrationKey
    Set-DscLocalConfigurationManager -Path "$Path\PullClientConfigID\" -Force -Verbose
    reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v DSCAutomationHostEnabled /t REG_DWORD /d 1 /f
    Remove-Item -Path "C:\PullClientConfigID.ps1"
    Restart-Computer -Force
}

#Cleanup
Remove-Item -Path "$env:ProgramFiles\DSC.zip"
