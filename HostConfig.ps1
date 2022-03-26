### Retrieve and Install Require Package Managers ###
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force

### Hyper-V Specific Configuration ###
New-VMSwitch -Name "Nat-Switch" -SwitchType Internal
New-NetIPAddress -IPAddress 172.16.0.1 -PrefixLength 24 -InterfaceAlias "vEthernet (Nat-Switch)"
New-NetNat -Name "Nat-Switch" -InternalIPInterfaceAddressPrefix 172.16.0.0/24

Add-DhcpServerSecurityGroup
Add-DhcpServerv4Scope -Name "Nested VMs" -StartRange 172.16.0.10 -EndRange 172.16.0.100 -SubnetMask 255.255.255.0
Set-DhcpServerv4OptionValue -DnsServer 168.63.129.16 -Router 172.16.0.1
Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\ServerManager\Roles\12 -Name ConfigurationState -Value 2
Restart-Service -Name DHCPServer -Force

Get-Disk | Where-Object -Property PartitionStyle -EQ "RAW" | Initialize-Disk -PartitionStyle GPT -PassThru | New-Volume -FileSystem REFS -AllocationUnitSize 65536 -DriveLetter F -FriendlyName "VMS"
New-Item -Path "F:\VMS" -ItemType Directory;New-Item -Path "F:\VMS\Disks" -ItemType Directory;New-Item -Path "F:\VMS\Templates" -ItemType Directory 
Set-VMHost -VirtualMachinePath "F:\VMS" -VirtualHardDiskPath "F:\VMS\Disks" -EnableEnhancedSessionMode $true


### Retrieve and Install Required Software (Azure Storage Explorer, Az PS Module, Az Cli, Az Copy, PowerShell Core, Windows Admin Center and 7-Zip) ###
choco install microsoftazurestorageexplorer -y
choco install az.powershell -y
choco install azcopy10 -y
choco install windows-admin-center -y
choco install azure-cli -y
choco install powershell-core -y
choco install 7zip

### Create Desktop Shortcuts for Windows Admin Center, Microsoft Evaluation Center and Hyper-V Manager ###
$Shell = New-Object -ComObject ("WScript.Shell")

$Shortcut1 = $Shell.CreateShortcut("C:\Users\Public\Desktop\Windows Admin Center.url")
$Shortcut1.TargetPath = "https://localhost:6516";
$Shortcut1.Save()

$Shortcut2 = $Shell.CreateShortcut("C:\Users\Public\Desktop\Microsoft Evaluation Center.url")
$Shortcut2.TargetPath = "https://www.microsoft.com/en-us/evalcenter/";
$Shortcut2.Save()

Start-Sleep 10
Copy-Item -Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Administrative Tools\Hyper-V Manager.lnk" -Destination "C:\Users\Public\Desktop\Hyper-V Manager.lnk"


