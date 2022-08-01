configuration New_xDscPullServer
{
    param
    (
        [string[]]$NodeName = 'localhost',

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $RegistrationKey
    )

    Import-DscResource -ModuleName xPSDesiredStateConfiguration
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    Node $NodeName
    {
        WindowsFeature DSCServiceFeature
        {
            Ensure = 'Present'
            Name   = 'DSC-Service'
        }

        WindowsFeature RSAT-AD-PowerShell
        {
            Ensure = 'Present'
            Name = 'RSAT-AD-PowerShell'
        }

        xDscWebService PSDSCPullServer
        {
            Ensure                   = 'Present'
            EndpointName             = 'PSDSCPullServer'
            Port                     = 8080
            PhysicalPath             = "$env:SystemDrive\inetpub\PSDSCPullServer"
            CertificateThumbPrint    = "AllowUnencryptedTraffic"
            ModulePath               = "$env:ProgramFiles\WindowsPowerShell\DscService\Modules"
            ConfigurationPath        = "$env:ProgramFiles\WindowsPowerShell\DscService\Configuration"
            State                    = 'Started'
            DependsOn                = '[WindowsFeature]DSCServiceFeature'
            UseSecurityBestPractices = $false
            ConfigureFirewall        = $false
        }

        File RegistrationKeyFile
        {
            Ensure          = 'Present'
            Type            = 'File'
            DestinationPath = "$env:ProgramFiles\WindowsPowerShell\DscService\RegistrationKeys.txt"
            Contents        = $RegistrationKey
        }
    }
}