param uniqueName string
param location string

var vnetPrefix = '10.0.0.0/16'
var vnetName = 'vnet${uniqueName}'
var subnetPrefix = '10.0.0.0/24'
var subnetName = 'subn${uniqueName}'

resource vnet 'Microsoft.Network/virtualNetworks@2021-03-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [ 
         vnetPrefix
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          privateEndpointNetworkPolicies: 'Disabled'
          addressPrefix: subnetPrefix
        }
      }
    ]
  }
}

output network object = {
  vnet: {
    id: vnet.id
    name: vnetName
  }
  subnet: {
    id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, subnetName)
    name: subnetName
  }
}
