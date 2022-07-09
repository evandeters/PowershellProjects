@{
    AllNodes = @(
        @{
            NodeName = '*'
            PsDscAllowDomainUser = $true
            PsDscAllowPlainTextPassword = $true
        },
        @{
            NodeName = 'DC01'
            Purpose = 'Domain Controller'
            WindowsFeatures = 'AD-Domain-Services'
        }
    )
    NonNodeData = @{
        DomainName = 'mytestlab.local'
    }
}