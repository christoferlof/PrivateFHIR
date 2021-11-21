param uniqueName string
param location string
param prefix string
param vnetName string
param vnetId string
param subnetName string
param dnsZoneName string
param privateLinkServiceId string
param privateLinkGroupIds array

var subnetRef = resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, subnetName)

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2021-03-01' = {
  name: 'pe${prefix}${uniqueName}'
  location: location
  properties: {
    subnet: {
      id: subnetRef
    }
    privateLinkServiceConnections: [
      {
        name: 'pe${prefix}connection'
        properties: {
          privateLinkServiceId: privateLinkServiceId
          groupIds: privateLinkGroupIds
        }
      }
    ]
  }
}

resource dnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: dnsZoneName
  location: 'global'
}

resource dnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: dnsZone
  name: '${dnsZone.name}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}

resource dnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-03-01' = {
  parent: privateEndpoint
  name: '${prefix}dnsgroups${uniqueName}'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config'
        properties: {
          privateDnsZoneId: dnsZone.id
        }
      }
    ]
  }
}
