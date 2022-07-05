[DSCLocalConfigurationManager()]
Configuration PullClientConfigID
{
    param(
        [string[]]$NodeName = 'localhost',

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $DSCServerFQDN,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string[]] $Configurations
    )

    Node localhost
    {
        Settings
        {
            RefreshMode = 'Pull'
            RefreshFrequencyMins = 30
            RebootNodeIfNeeded = $true
            ConfigurationMode = "ApplyAndAutoCorrect"
        }

        ConfigurationRepositoryWeb PullSrv
        {
            ServerURL = "http://$DSCServerFQDN`:8080/PSDSCPullServer.svc"
            RegistrationKey = '05916093-ed87-46be-9c72-1a862d3c90d1'
            ConfigurationNames = $Configurations
            AllowUnsecureConnection = $true
        }
    }
}