param deployment object

var vnetPrefix = '10.0.0.0/16'
var vnetName = 'vnet${deployment.uniqueName}'
var subnetPrefix = '10.0.0.0/24'
var subnetName = 'subn${deployment.uniqueName}'

resource vnet 'Microsoft.Network/virtualNetworks@2021-03-01' = {
  name: vnetName
  location: deployment.location
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
