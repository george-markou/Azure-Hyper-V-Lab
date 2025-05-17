### Retrieve and Install Required Package Managers ###
# Enable TLS 1.2 for secure downloads and install Chocolatey (a package manager for Windows)
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Install NuGet provider, which is required for managing packages
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force

### Hyper-V Specific Configuration ###
# Create a new internal virtual switch named "Nat-Switch"
New-VMSwitch -Name "Nat-Switch" -SwitchType Internal

# Assign an IP address to the virtual switch for NAT configuration
New-NetIPAddress -IPAddress 172.16.0.1 -PrefixLength 24 -InterfaceAlias "vEthernet (Nat-Switch)"

# Create a NAT network using the virtual switch
New-NetNat -Name "Nat-Switch" -InternalIPInterfaceAddressPrefix 172.16.0.0/24

# Add the DHCP Server security group to the system
Add-DhcpServerSecurityGroup

# Create a DHCP scope for the nested VMs with a specified IP range
Add-DhcpServerv4Scope -Name "Nested VMs" -StartRange 172.16.0.10 -EndRange 172.16.0.100 -SubnetMask 255.255.255.0

# Set DNS server and default gateway options for the DHCP scope
Set-DhcpServerv4OptionValue -DnsServer 168.63.129.16 -Router 172.16.0.1

# Configure the DHCP server role to be in a ready state
Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\ServerManager\Roles\12 -Name ConfigurationState -Value 2

# Restart the DHCP server service to apply changes
Restart-Service -Name DHCPServer -Force

### Disk and Directory Setup ###
# Initialize any RAW disks, format them with ReFS, and assign the drive letter F
Get-Disk | Where-Object -Property PartitionStyle -EQ "RAW" | Initialize-Disk -PartitionStyle GPT -PassThru | New-Volume -FileSystem REFS -AllocationUnitSize 65536 -DriveLetter F -FriendlyName "VMS"

# Create necessary directories for VM configurations, ISOs, disks, and templates
New-Item -Path "F:\VMS" -ItemType Directory
New-Item -Path "F:\VMS\ISO" -ItemType Directory
New-Item -Path "F:\VMS\Disks" -ItemType Directory
New-Item -Path "F:\VMS\Templates" -ItemType Directory

# Configure the VM host to use the created directories and enable Enhanced Session Mode
Set-VMHost -VirtualMachinePath "F:\VMS" -VirtualHardDiskPath "F:\VMS\Disks" -EnableEnhancedSessionMode $true

### Download Windows Server 2025 Evaluation ISO ###
$isoUrl = "https://go.microsoft.com/fwlink/?linkid=2293312&clcid=0x409&culture=en-us&country=us"

# The destination path for the downloaded ISO
$isoDestination = "F:\VMS\ISO\WindowsServer2025Eval.iso"

# Download the ISO file and save it to the specified location
Start-BitsTransfer -Source $isoUrl -Destination $isoDestination

### Retrieve and Install Required Software ###
# Install various tools and utilities using Chocolatey
choco install microsoftazurestorageexplorer -y  # Azure Storage Explorer
choco install az.powershell -y                 # Azure PowerShell Module
choco install azcopy10 -y                      # AzCopy Utility
choco install windows-admin-center -y         # Windows Admin Center
choco install azure-cli -y                     # Azure CLI
choco install powershell-core -y               # PowerShell Core
choco install 7zip -y                          # 7-Zip File Archiver

### Create Desktop Shortcuts ###
# Create a COM object to manage desktop shortcuts
$Shell = New-Object -ComObject ("WScript.Shell")

# Create a shortcut for Windows Admin Center
$Shortcut1 = $Shell.CreateShortcut("C:\Users\Public\Desktop\Windows Admin Center.url")
$Shortcut1.TargetPath = "https://localhost:6516"  # URL for Windows Admin Center
$Shortcut1.Save()

# Create a shortcut for the Microsoft Evaluation Center
$Shortcut2 = $Shell.CreateShortcut("C:\Users\Public\Desktop\Microsoft Evaluation Center.url")
$Shortcut2.TargetPath = "https://www.microsoft.com/en-us/evalcenter/"  # URL for Evaluation Center
$Shortcut2.Save()

# Create a shortcut for the MSLAB GitHub Repository
$Shortcut3 = $Shell.CreateShortcut("C:\Users\Public\Desktop\MSLAB GitHub Repository.url")
$Shortcut3.TargetPath = "https://github.com/microsoft/MSLab"  # URL for MSLAB GitHub
$Shortcut3.Save()

# Copy the Hyper-V Manager shortcut to the desktop
Copy-Item -Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Administrative Tools\Hyper-V Manager.lnk" -Destination "C:\Users\Public\Desktop\Hyper-V Manager.lnk"


