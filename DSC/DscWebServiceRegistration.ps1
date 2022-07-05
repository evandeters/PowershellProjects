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
    Import-DscResource -ModuleName NetworkingDsc

    Node $NodeName
    {
        WindowsFeature DSCServiceFeature
        {
            Ensure = 'Present'
            Name = 'DSC-Service'
        }

        xDscWebService PSDSCPullServer
        {
            Ensure = 'Present'
            EndpointName = 'PSDSCPullServer'
            Port = 8080
            PhysicalPath = "$env:SystemDrive\inetpub\PSDSCPullServer"
            CertificateThumbPrint = "BEF14AEA377DDF6C00271A435BF2061021FFCB1B"
            ModulePath = "$env:ProgramFiles\WindowsPowerShell\DscService\Modules"
            ConfigurationPath = "$env:ProgramFiles\WindowsPowerShell\DscService\Configuration"
            State = 'Started'
            DependsOn = '[WindowsFeature]DSCServiceFeature'
            UseSecurityBestPractices = $false
            ConfigureFirewall = $false
        }

        File RegistrationKeyFile
        {
            Ensure = 'Present'
            Type = 'File'
            DestinationPath = "$env:ProgramFiles\WindowsPowerShell\DscService\RegistrationKeys.txt"
            Contents = $RegistrationKey
        }
    }
}