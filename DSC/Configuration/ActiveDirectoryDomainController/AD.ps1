Configuration NewActiveDirectoryConfig {  
  param (  
    [Parameter(Mandatory)]   
    [PSCredential]$DomainCredential = "swift",  
    [Parameter(Mandatory)]   
    [PSCredential]$DSRMpassword = "swift"
  )  
  Import-DscResource -ModuleName xActiveDirectory  
  Node $ComputerName {  
    #Install Active Directory role and required tools  
    WindowsFeature ActiveDirectory {  
      Ensure = 'Present'  
      Name   = 'AD-Domain-Services'  
    }  
    WindowsFeature ActiveDirectoryTools {  
      Ensure    = 'Present'  
      Name      = 'RSAT-AD-Tools'  
      DependsOn = "[WindowsFeature]ActiveDirectory"  
    }  
    WindowsFeature DNSServerTools {  
      Ensure    = 'Present'  
      Name      = 'RSAT-DNS-Server'  
      DependsOn = "[WindowsFeature]ActiveDirectoryTools"  
    }  
    WindowsFeature ActiveDirectoryPowershell {  
      Ensure    = "Present"  
      Name      = "RSAT-AD-PowerShell"  
      DependsOn = "[WindowsFeature]DNSServerTools"  
    }  
    #Configure Active Directory Role   
    xADDomain RootDomain {  
      Domainname                    = 'evan.test'
      SafemodeAdministratorPassword = $DSRMpassword  
      DomainAdministratorCredential = $DomainCredential  
      #DomainNetbiosName = ($DomainName -split '\.')[0]  
      DependsOn                     = "[WindowsFeature]ActiveDirectory", "[WindowsFeature]ActiveDirectoryPowershell"  
    }  
    #LCM Configuration  
    LocalConfigurationManager {        
      ActionAfterReboot  = 'ContinueConfiguration'        
      ConfigurationMode  = 'ApplyOnly'        
      RebootNodeIfNeeded = $true        
    }        
  }  
}  
#Allow plain text password to be stored  
$ConfigurationData = @{  
  AllNodes = @(  
    @{  
      NodeName                    = DC  
      PSDscAllowPlainTextPassword = $true  
      DomainName                  = 'evan.test'
    }  
  )  
}  
#Generate mof files  
NewActiveDirectoryConfig -DSRMpassword $DSRMpassword -DomainCredential $DomainCredential -OutputPath $MOFfiles -ConfigurationData $ConfigurationData  
#Configure LCM on remote computer  
Set-DSCLocalConfigurationManager -Path $MOFfiles –Verbose -CimSession $CimSession  
#Start Deployment remotely  
Start-DscConfiguration -Path $MOFfiles -Verbose -CimSession $CimSession -Wait -Force 