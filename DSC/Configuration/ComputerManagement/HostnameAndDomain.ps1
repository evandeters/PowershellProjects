Configuration HostnameAndDomain
{

    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $Hostname,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $Domain,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullorEmpty()]
        [System.Management.Automation.PSCredential] $Credential
    )

    Import-DscResource -Module ComputerManagementDsc

    Node localhost 
    {
        Computer NewNameAndDomain
        {
            Name        = "$Hostname"
            DomainName  = "$Domain"
            Credential  = $Credential
        }
    }
}