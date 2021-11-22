param uniqueName string
param location string
param network object

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



var storageBlobDnsZoneName = 'privatelink.blob.${environment().suffixes.storage}'

module storagePrivateEndpoint 'PrivateEndpoint.bicep' = {
  name: 'storagePrivateEndpoint'
  params: {
    dnsZoneName: storageBlobDnsZoneName
    location: location
    prefix: 'blob'
    privateLinkGroupIds: [
      'blob'
    ]
    privateLinkServiceId: storage.id
    subnetName: network.subnet.name
    uniqueName: uniqueName
    vnetId: network.vnet.id
    vnetName: network.vnet.name
  }
}

var fhirServerName = 'fhir${uniqueName}'
var fhirDnsZoneName = 'privatelink.azurehealthcareapis.com'

module fhirPrivateEndpoint 'PrivateEndpoint.bicep' = {
  name: 'fhirPrivateEndpoint'
  params: {
    dnsZoneName: fhirDnsZoneName
    location: location
    prefix: 'fhir'
    privateLinkGroupIds: [
      'fhir'
    ]
    privateLinkServiceId: fhirServer.id
    subnetName: network.subnet.name
    uniqueName: uniqueName
    vnetId: network.vnet.id
    vnetName: network.vnet.name
  }
}

var fhirAudience = 'https://${fhirServerName}.azurehealthcareapis.com'

resource fhirServer 'Microsoft.HealthcareApis/services@2021-01-11' = {
  name: fhirServerName
  location: location
  kind: 'fhir-R4'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    authenticationConfiguration: {
      audience: fhirAudience
      authority: uri(environment().authentication.loginEndpoint, subscription().tenantId)
    }
    publicNetworkAccess: 'Disabled'
    exportConfiguration: {
      storageAccountName: storageName
    }
  }
}

var storageBlobContributorRoleDefId = 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'

resource roleDefinition 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  name: storageBlobContributorRoleDefId
}

var fhirStorageRoleAssignmentName = guid(uniqueName, storageBlobContributorRoleDefId)

resource fhirStorageRoleAssigment 'Microsoft.Authorization/roleAssignments@2020-08-01-preview' = {
  name: fhirStorageRoleAssignmentName
  scope: storage
  properties: {
    principalId: fhirServer.identity.principalId
    roleDefinitionId: roleDefinition.id
  }
}
