Configuration PowerShellWebAccess
{
    param ($MachineName='localhost')

    Node $MachineName
    {
        WindowsFeature IIS
        {
            Ensure  = "Present"
            Name    = "Web-Server"
            IncludeAllSubFeature = $true
        }

        WindowsFeature ASP
        {
            Ensure  = "Present"
            Name    = "Web-Asp-Net45"
        }

        WindowsFeature ASPExt
        {
            Ensure  = "Present"
            Name    = "Web-Net-Ext45"
        }

        WindowsFeature ISAPIExt
        {
            Ensure  = "Present"
            Name    = "Web-ISAPI-Ext"
        }

        WindowsFeature ISAPIFilter
        {
            Ensure  = "Present"
            Name    = "Web-ISAPI-Filter"
        }

        WindowsFeature WebManagement
        {
            Ensure               = "Present"
            Name                 = "Web-Mgmt-Tools"
            IncludeAllSubFeature = $true
        }

        WindowsFeature PSWA
        {
            Ensure               = "Present"
            Name                 = "WindowsPowerShellWebAccess"
            IncludeAllSubFeature = $true
        }

        Script AllowUsers 
        {
            SetScript = {
                Install-PswaWebApplication -UseTestCertificate
                Add-PswaAuthorizationRule * * *
            }
            TestScript = { $false }
            GetScript = { $true }
            
        }
    }
}