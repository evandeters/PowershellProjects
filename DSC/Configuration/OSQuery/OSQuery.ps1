Configuration OSQuery {
    
    Import-DscResource -ModuleName cChoco

    Node localhost
    {
        cChocoInstaller installChoco
        {
            InstallDir = "C:\ProgramData\chocolatey"
        }

        cChocoPackageInstaller installOSQuery
        {
            Name = "osquery"
            DependsOn = "[cChocoInstaller]installChoco"
        }
    }

}