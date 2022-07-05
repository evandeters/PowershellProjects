Configuration WebServer
{
    param ($MachineName='localhost')

    Node $MachineName
    {
        WindowsFeature IIS
        {
            Ensure  = "Present"
            Name    = "Web-Server"
        }

        WindowsFeature ASP
        {
            Ensure  = "Present"
            Name    = "web-Asp-Net45"
        }

        WindowsFeature WebManagement
        {
            Ensure               = "Present"
            Name                 = "Web-Mgmt-Tools"
            IncludeAllSubFeature = $true
        }

        
    }
}