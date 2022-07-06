wget https://github.com/evanjd711/PowershellProjects/archive/refs/heads/main.zip -UseBasicParsing -OutFile $env:ProgramFiles\DSC.zip
Expand-Archive $env:ProgramFiles\DSC.zip -DestinationPath $env:ProgramFiles\DSC\
cd $env:ProgramFiles\DSC\PowershellProjects-main\DSC\
. .\DscWebServiceRegistration.ps1
New_xDscPullServer -RegistrationKey (New-Guid).Guid