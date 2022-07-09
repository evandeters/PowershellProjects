wget https://github.com/evanjd711/PowershellProjects/archive/refs/heads/main.zip -UseBasicParsing -OutFile $env:ProgramFiles\DSC.zip
Expand-Archive $env:ProgramFiles\DSC.zip -DestinationPath $env:ProgramFiles\DSC\
cd $env:ProgramFiles\DSC\PowershellProjects-main\DSC\InitialConfigs\
. .\DscWebServiceRegistration.ps1
New_xDscPullServer -RegistrationKey (New-Guid).Guid
Start-DscConfiguration .\New_xDscPullServer
Install-Module cChoco -Confirm:$false
Compress-Archive -Path $env:ProgramFiles\WindowsPowerShell\Modules\cChoco -DestinationPath $env:ProgramFiles\WindowsPowerShell\DscService\Modules\cChoco_2.5.0.0.zip 
New-DscChecksum -Path $env:ProgramFiles\WindowsPowerShell\DscService\Modules\cChoco_2.5.0.0.zip 
cd ..\Configuration\OSQuery\
Publish-MofToPullServer -FullName .\OSQuery.mof -PullServerWebConfig C:\inetpub\PSDSCPullServer\web.config