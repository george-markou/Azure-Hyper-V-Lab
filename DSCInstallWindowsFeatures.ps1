Configuration InstallWindowsFeatures {

    Import-DscResource -ModuleName PsDesiredStateConfiguration

    Node "localhost" {

        LocalConfigurationManager {
            RebootNodeIfNeeded = $true
            ActionAfterReboot  = 'ContinueConfiguration'
        }
        WindowsFeature Hyper-V {
            Name   = "Hyper-V"
            Ensure = "Present"
		    IncludeAllSubFeature = $true
        }
        WindowsFeature Hyper-V-PowerShell {
            Name   = "Hyper-V-PowerShell"
            Ensure = "Present"
		    IncludeAllSubFeature = $true
        }
        WindowsFeature RSAT-Hyper-V-Tools {
            Name = "RSAT-Hyper-V-Tools"
            Ensure = "Present"
            IncludeAllSubFeature = $true
        }
        WindowsFeature Containers {
            Name   = "Containers"
            Ensure = "Present"
		    IncludeAllSubFeature = $true
        }
        WindowsFeature DHCP {
            Name   = "DHCP"
            Ensure = "Present"
		    IncludeAllSubFeature = $true
        }
        WindowsFeature RSAT-DHCP {
            Name = "RSAT-DHCP"
            Ensure = "Present"
            IncludeAllSubFeature = $true
        }    
    }
}