Configuration WebServer
{
    param ($MachineName)

    Node $MachineName
    {
        WindowsFeature IIS
        {
            Ensure = "Present"
            Name = "Web-Server"
        }

        WindowsFeature ASP
        {
            Ensure = "Present"
            Name = "web-Asp-Net45"
        }
    }
}