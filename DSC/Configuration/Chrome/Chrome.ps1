Configuration Chrome {
    
    Import-DscResource -ModuleName cChoco

    Node localhost
    {
        cChocoInstaller installChoco
        {
            InstallDir = "C:\ProgramData\chocolatey"
        }

        cChocoPackageInstaller installOSQuery 
        {
            Name      = "googlechrome"
            DependsOn = "[cChocoInstaller]installChoco"
        }
    }
}