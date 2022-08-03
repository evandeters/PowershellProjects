Configuration PackageInstaller {
    
    Import-DscResource -ModuleName cChoco

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
                        "googlechrome"
                        "malwarebytes"
                        "sysinternals"
                    )
            DependsOn = "[cChocoInstaller]installChoco"
        }
    }
}