function New-AD {
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $DomainName,
        [Parameter(Mandatory)]
        [ValidateSet('Win2008','Win2008R2','Win2012','Win2012R2','WinThreshold')]
        [string] $DomainMode
    )

    Install-WindowsFeature AD-Domain-Services -Confirm:$false
    Install-WindowsFeature RSAT-AD-PowerShell -Confirm:$false
    Install-WindowsFeature RSAT-ADDS -Confirm:$false

    # Windows PowerShell script for AD DS Deployment
    Import-module ADDSDep10yment
    Install-ADDSForest `
    -CreateDnsDelegation:$false `
    -DatabasePath "C:\Windows\NTDS" `
    -DomainMode "$DomainMode" `
    -DomainName "$DomainName" `
    -ForestMode "$DomainMode" `
    -InstallDns:$true `
    -LogPath "C:\Windows\NTDS" `
    -NoRebootOnCompletion:$false `
    -SysvolPath "C:\Windows\SYSVOL" `
    -Force:$true
}