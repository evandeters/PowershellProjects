function New-AD {
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $DomainName,
        [Parameter(Mandatory)]
        [ValidateSet('Win2008','Win2008R2','Win2012','Win2012R2','WinThreshold')]
        [string] $DomainMode,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $NewHostname
    )

    Set-DnsClientServerAddress -InterfaceIndex (Get-NetAdapter | Select-Object -expand ifindex) -ServerAddress ("127.0.0.1", (Get-NetIPConfiguration | Select-Object -ExpandProperty IPv4DefaultGateway | Select-Object -ExpandProperty NextHop))
    Install-WindowsFeature AD-Domain-Services -Confirm:$false
    Install-WindowsFeature RSAT-AD-PowerShell -Confirm:$false
    Install-WindowsFeature RSAT-ADDS -Confirm:$false
   
    Remove-ItemProperty -path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -name "Hostname" 
    Remove-ItemProperty -path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -name "NV Hostname" 

    Set-ItemProperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\Computername\Computername" -name "Computername" -value $NewHostname
    Set-ItemProperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\Computername\ActiveComputername" -name "Computername" -value $NewHostname
    Set-ItemProperty -path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -name "Hostname" -value $NewHostname
    Set-ItemProperty -path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -name "NV Hostname" -value  $NewHostname
    Set-ItemProperty -path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -name "AltDefaultDomainName" -value $NewHostname
    Set-ItemProperty -path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -name "DefaultDomainName" -value $NewHostname
   
    Register-ScheduledJob -Name "Create-AD-Forest" -ScriptBlock {
        Install-ADDSForest `
        -CreateDnsDelegation:$false `
        -DatabasePath 'C:\Windows\NTDS' `
        -DomainMode $DomainMode `
        -DomainName $DomainName `
        -ForestMode $DomainMode `
        -SafeModeAdministratorPassword (ConvertTo-SecureString -AsPlainText "swift" -Force)
        -InstallDns:$true `
        -LogPath 'C:\Windows\NTDS' `
        -NoRebootOnCompletion:$false `
        -SysvolPath 'C:\Windows\SYSVOL' `
        -Force:$true
    }
    New-JobTrigger -AtLogOn -User Administrator -Once
    
}