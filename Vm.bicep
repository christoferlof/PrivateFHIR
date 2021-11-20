param uniqueName string
param location string
param subnetId string
param adminUsername string
@secure()
param adminPassword string

var vmName = 'vm${uniqueName}'

resource vmIp 'Microsoft.Network/publicIPAddresses@2021-03-01' = {
  name: '${vmName}ip'
  location: location
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Dynamic'
    dnsSettings: {
      domainNameLabel: vmName
    }
    idleTimeoutInMinutes: 4
  }
  sku: {
    name: 'Basic'
    tier: 'Regional'
  }
}

resource vmNsg 'Microsoft.Network/networkSecurityGroups@2021-03-01' = {
  name: '${vmName}nsg'
  location: location
  properties: {
    securityRules: [
      {
        name: 'ssh'
        properties: {
          protocol: 'Tcp'
          priority: 1000
          access: 'Deny'
          direction: 'Inbound'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '22'
        }
      }
    ]
  }
}

resource vmNic 'Microsoft.Network/networkInterfaces@2021-03-01' = {
  name: '${vmName}nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig'
        properties: {
          subnet: {
            id: subnetId
          }
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: vmIp.id
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: vmNsg.id
    }
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2021-07-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_A0'
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
      imageReference: {
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: '18.04-LTS'
        version: 'latest'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: vmNic.id
        }
      ]
    }
  }
}
