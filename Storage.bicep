param uniqueName string
param location string

var storageName = 'sa${uniqueName}'

resource storage 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  name: storageName
  location: location
  sku: {
    name:'Standard_LRS'
  }
  kind:'StorageV2'
  
}

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

resource peblob 'Microsoft.Network/privateEndpoints@2021-03-01' = {
  name: 'peblob${uniqueName}'
  location: location
  properties: {
    subnet: {
      id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnet.name, subnetName)
    }
    privateLinkServiceConnections: [
      {
        name: 'peblobconnection'
        properties: {
          privateLinkServiceId: storage.id
          groupIds: [
            'blob'
          ]
        }
      }
    ]
  }
}
