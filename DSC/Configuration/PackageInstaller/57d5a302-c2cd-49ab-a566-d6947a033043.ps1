Configuration PackageInstaller {
    
    Import-DscResource -ModuleName cChoco
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    Node localhost
    {
        cChocoInstaller installChoco
        {
            InstallDir = "C:\ProgramData\chocolatey"
        }

        cChocoPackageInstallerSet installPackages 
        {
            Ensure = 'Present'
            Name = @(
                        "osquery"
                    )
            DependsOn = "[cChocoInstaller]installChoco"
        }

        Service osqueryd
        {
            Ensure = "Present"
            Name = "osqueryd"
            Path = "C:\Program Files\osquery\osqueryd\osqueryd.exe"
            BuiltInAccount = 'LocalSystem'
            StartupType = 'Automatic'
            State = 'Running'
            Description = 'osquery daemon service'
            DependsOn = "[cChocoPackageInstallerSet]installPackages"
        }
    }
}