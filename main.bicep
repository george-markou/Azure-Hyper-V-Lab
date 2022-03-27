@description('Location for all resources.')
param location string = resourceGroup().location

@description('Name of Hyper-V Host Virtual Machine, Maximum of 15 characters, use letters and numbers only.')
@maxLength(15)
param computerName string

@description('Admin Username for the Host Virtual Machine')
param AdminUsername string

@description('Admin User Password for the Host Virtual Machine')
@secure()
param AdminPassword string

@description('Size of the Host Virtual Machine')
@allowed([
  'Standard_D2_v4'
  'Standard_D4_v4'
  'Standard_D8_v4'
  'Standard_D16_v4'
  'Standard_D32_v4'
  'Standard_D48_v4'
  'Standard_D64_v4'
  'Standard_D2s_v4'
  'Standard_D4s_v4'
  'Standard_D8s_v4'
  'Standard_D16s_v4'
  'Standard_D32s_v4'
  'Standard_D48s_v4'
  'Standard_D64s_v4'
  'Standard_D2_v3'
  'Standard_D4_v3'
  'Standard_D8_v3'
  'Standard_D16_v3'
  'Standard_D32_v3'
  'Standard_D2s_v3'
  'Standard_D4s_v3'
  'Standard_D8s_v3'
  'Standard_D16s_v3'
  'Standard_D32s_v3'
  'Standard_D64_v3'
  'Standard_E2_v3'
  'Standard_E4_v3'
  'Standard_E8_v3'
  'Standard_E16_v3'
  'Standard_E32_v3'
  'Standard_E64_v3'
  'Standard_D64s_v3'
  'Standard_E2s_v3'
  'Standard_E4s_v3'
  'Standard_E8s_v3'
  'Standard_E16s_v3'
  'Standard_E32s_v3'
  'Standard_E64s_v3'
  'Standard_E2_v4'
  'Standard_E4_v4'
  'Standard_E8_v4'
  'Standard_E16_v4'
  'Standard_E20_v4'
  'Standard_E32_v4'
  'Standard_E48_v4'
  'Standard_E64_v4'
  'Standard_E2s_v4'
  'Standard_E4s_v4'
  'Standard_E8s_v4'
  'Standard_E16s_v4'
  'Standard_E20s_v4'
  'Standard_E32s_v4'
  'Standard_E48s_v4'
  'Standard_E64s_v4'
  'Standard_E80s_v4'
  'Standard_F2s_v2'
  'Standard_F4s_v2'
  'Standard_F8s_v2'
  'Standard_F16s_v2'
  'Standard_F32s_v2'
  'Standard_F48s_v2'
  'Standard_F64s_v2'
  'Standard_F72s_v2'
  'Standard_M8ms'
  'Standard_M16ms'
  'Standard_M32ts'
  'Standard_M32ls'
  'Standard_M32ms'
  'Standard_M64s'
  'Standard_M64ls'
  'Standard_M64ms'
  'Standard_M128s'
  'Standard_M128ms'
  'Standard_M64'
  'Standard_M64m'
  'Standard_M128'
  'Standard_M128m'
])
param VirtualMachineSize string = 'Standard_F8s_v2'

@description('Virtual Network(VNet) Configuration')
param vnetName string
param vnetaddressPrefix string = '192.168.0.0/24'
param subnetName1 string = 'HyperVLab-snet'
param subnetPrefix1 string = '192.168.0.0/28'

@description('Deployment of Network Security Group(NSG)')
resource nsg 'Microsoft.Network/networkSecurityGroups@2021-05-01' = {
  name: '${computerName}-nsg'
  location: resourceGroup().location
  properties: {
    securityRules: [
      {
        name: 'Allow_RDP'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '3389'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
    ]
  }
}

@description('Deployment of Virtual Network(VNet)')
resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: '${vnetName}-vnet'
  location: resourceGroup().location
   properties: {
    addressSpace: {
      addressPrefixes: [
        vnetaddressPrefix
      ]
    }
    subnets: [
      {
        name: subnetName1
        properties: {
          addressPrefix: subnetPrefix1
        }
      }
    ]
  }
}

@description('Deployment of Public IP Address(PIP)')
resource vmPip 'Microsoft.Network/publicIPAddresses@2021-02-01' = {
  name: '${computerName}-pip'
  location: resourceGroup().location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    deleteOption: 'Delete'
    publicIPAllocationMethod: 'Static'
  }
}

@description('Deployment of Network Interface Card(NIC)')
resource vmNic 'Microsoft.Network/networkInterfaces@2021-05-01' = {
  name: '${computerName}-nic'
  location: resourceGroup().location
  properties: {
  ipConfigurations: [
  {
    name: 'ipconfig01'
    properties: {
      privateIPAllocationMethod: 'Dynamic'
      subnet: {
        id: '${vnet.id}/subnets/${subnetName1}'
      }
      publicIPAddress: {
      id: resourceId(resourceGroup().name, 'Microsoft.Network/publicIPAddresses', vmPip.name)
    }
    }
  }
  ]
  dnsSettings: {
    dnsServers: [
      
    ]
  }
  enableIPForwarding: true
  networkSecurityGroup: {
    id: nsg.id
    location: resourceGroup().location
  }
  }
}

@description('Deployment of Virtual Machine with Nested Virtualization')
resource vm 'Microsoft.Compute/virtualMachines@2021-03-01' = {
  name: computerName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: VirtualMachineSize
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2022-Datacenter'
        version: 'latest'
      }
      osDisk: {
        name: '${computerName}-OsDisk'
        createOption: 'FromImage'
        deleteOption: 'Delete'
        managedDisk: {
          storageAccountType: 'Premium_LRS'
        }
        caching: 'ReadWrite'
      }
      dataDisks: [
        {
          lun: 0
          name: '${computerName}-DataDisk1'
          createOption: 'Empty'
          diskSizeGB: 512
          caching: 'ReadOnly'
          deleteOption: 'Delete'
          managedDisk: {
            storageAccountType: 'Premium_LRS'
          }
        }
      ]
    }
    osProfile: {
      computerName: computerName
      adminUsername: AdminUsername
      adminPassword: AdminPassword
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: vmNic.id
          properties: {
            primary: true
            deleteOption: 'Delete'
          }        
        }
      ]
    }
  }
}

@description('Deployment of DSC Configuration. Enablement of Hyper-V and DHCP Roles along with RSAT Tools.')
resource vmExtension 'Microsoft.Compute/virtualMachines/extensions@2021-03-01' = {
  parent: vm
  name: 'InstallWindowsFeatures'
  location: location
  properties: {
    publisher: 'Microsoft.Powershell'
    type: 'DSC'
    typeHandlerVersion: '2.77'
    autoUpgradeMinorVersion: true
    settings: {
      wmfVersion: 'latest'
      configuration: {
        url: 'https://github.com/george-markou/Azure-Hyper-V-Lab/raw/main/dsc/DSCInstallWindowsFeatures.zip'
        script: 'DSCInstallWindowsFeatures.ps1'
        function: 'InstallWindowsFeatures'
      }
    }
  }
}

@description('Custom Script Execution. Configuration of Server Roles, installation of Chocolatey and deployment of software.')
resource hostVmSetupExtension 'Microsoft.Compute/virtualMachines/extensions@2021-03-01' = {
  parent: vm
  name: 'HostConfiguration'
  location: location
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.9'
    autoUpgradeMinorVersion: true
    settings: {
      fileUris: [
        'https://raw.githubusercontent.com/george-markou/Azure-Hyper-V-Lab/main/HostConfig.ps1'
      ]
      commandToExecute: 'powershell -ExecutionPolicy Unrestricted -File HostConfig.ps1'
    }
  }
  dependsOn: [
    vmExtension
  ]
}
