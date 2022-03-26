@description('Location for all resources.')
param location string = resourceGroup().location

@description('Name of Hyper-V Host Virtual Machine, Maximum of 15 characters, use letters and numbers only.')
@maxLength(15)
param computerName string

@description('Admin Username for the Host Virtual Machine')
param HostAdminUsername string

@description('Admin User Password for the Host Virtual Machine')
@secure()
param HostAdminPassword string

@description('Size of the Host Virtual Machine')
@allowed([
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
])
param HostVirtualMachineSize string = 'Standard_D4s_v3'

param vnetName string
param vnetaddressPrefix string = '192.168.0.0/24'
param subnetName1 string = 'HyperVLab-snet'
param subnetPrefix1 string = '192.168.0.0/28'


resource HyperVNSG 'Microsoft.Network/networkSecurityGroups@2021-05-01' = {
  name: 'nsg-${computerName}'
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

resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: vnetName
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

resource HyperVpip 'Microsoft.Network/publicIPAddresses@2021-02-01' = {
  name: 'pip-${computerName}-01'
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

resource HyperVNic 'Microsoft.Network/networkInterfaces@2021-05-01' = {
  name: 'nic-${computerName}-01'
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
      id: resourceId(resourceGroup().name, 'Microsoft.Network/publicIPAddresses', HyperVpip.name)
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
    id: HyperVNSG.id
    location: resourceGroup().location
  }
  }
}

resource hostVm 'Microsoft.Compute/virtualMachines@2021-03-01' = {
  name: computerName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: HostVirtualMachineSize
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
      adminUsername: HostAdminUsername
      adminPassword: HostAdminPassword
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: HyperVNic.id
          properties: {
            primary: true
            deleteOption: 'Delete'
          }        
        }
      ]
    }
  }
}

resource vmExtension 'Microsoft.Compute/virtualMachines/extensions@2021-03-01' = {
  parent: hostVm
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
        url: 'https://github.com/george-markou/Azure-Hyper-V-Lab/blob/main/dsc/DSCInstallWindowsFeatures.zip'
        script: 'DSCInstallWindowsFeatures.ps1'
        function: 'InstallWindowsFeatures'
      }
    }
  }
}

resource hostVmSetupExtension 'Microsoft.Compute/virtualMachines/extensions@2021-03-01' = {
  parent: hostVm
  name: 'HostConfig'
  location: location
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.9'
    autoUpgradeMinorVersion: true
    settings: {
      fileUris: [
        'https://github.com/george-markou/Azure-Hyper-V-Lab/blob/main/HostConfig.ps1'
      ]
      commandToExecute: 'powershell -ExecutionPolicy Unrestricted -File HostConfig.ps1'
    }
  }
  dependsOn: [
    vmExtension
  ]
}
