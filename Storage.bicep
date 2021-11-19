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
  properties: {
    networkAcls: {
      bypass:'None'
      defaultAction: 'Deny'
    }
    minimumTlsVersion: 'TLS1_2'
    allowSharedKeyAccess: false
  }
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

var storageBlobDnsZoneName = 'privatelink.blob.${environment().suffixes.storage}'

resource storageBlobDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: storageBlobDnsZoneName
  location: 'global'
}

resource peblobDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: storageBlobDnsZone
  name: '${storageBlobDnsZone.name}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnet.id
    }
  }
}

resource peblobDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-03-01' = {
  parent: peblob
  name: 'peblobdnsgroups${uniqueName}'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config'
        properties: {
          privateDnsZoneId: storageBlobDnsZone.id
        }
      }
    ]
  }
}

var fhirServerName = 'fhir${uniqueName}'
var subnetRef = resourceId('Microsoft.Network/virtualNetworks/subnets', vnet.name, subnetName)

resource pefhir 'Microsoft.Network/privateEndpoints@2021-03-01' = {
  name: 'pefhir${uniqueName}'
  location: location
  properties: {
    subnet: {
      id: subnetRef
    }
    privateLinkServiceConnections: [
      {
        name: 'pefhirconnection'
        properties: {
          privateLinkServiceId: fhirServer.id
          groupIds: [
            'fhir'
          ]
        }
      }
    ]
  }
}

resource fhirServer 'Microsoft.HealthcareApis/services@2021-01-11' = {
  name: fhirServerName
  location: location
  kind: 'fhir-R4'
  properties: {
    authenticationConfiguration: {
      audience: 'https://${fhirServerName}.azurehealthcareapis.com'
      authority: uri(environment().authentication.loginEndpoint, subscription().tenantId)
    }
    publicNetworkAccess: 'Disabled'
  }
}

output subnetRef string = subnetRef
