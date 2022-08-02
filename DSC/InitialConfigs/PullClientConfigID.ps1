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
        [string] $RegistrationKey
    )
    
    Node localhost
    {
        Settings 
        {
            RefreshFrequencyMins           = 30
            RefreshMode                    = "PULL"
            ConfigurationMode              = "ApplyAndAutocorrect"
            ConfigurationID                = "57d5a302-c2cd-49ab-a566-d6947a033043"
            AllowModuleOverwrite           = $true
            RebootNodeIfNeeded             = $true
            ConfigurationModeFrequencyMins = 60
        }

        ConfigurationRepositoryWeb PullSrv 
        {
            ServerURL               = "http://$DSCServerFQDN`:8080/PSDSCPullServer.svc"
            RegistrationKey         = $RegistrationKey
            AllowUnsecureConnection = $True
        }

        ResourceRepositoryWeb ResourceSrv 
        {
            ServerURL               = "http://$DSCServerFQDN`:8080/PSDSCPullServer.svc"
            RegistrationKey         = $RegistrationKey
            AllowUnsecureConnection = $true
        } 
    }
}