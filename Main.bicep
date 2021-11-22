targetScope = 'subscription'
var subscriptionUnique = take(uniqueString(subscription().subscriptionId),6)
var location = 'northeurope'

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'private-fhir-${subscriptionUnique}'
  location: location
}

module network 'Network.bicep' = {
  scope: rg
  name: 'networkModule'
  params: {
    location: location
    uniqueName: subscriptionUnique
  }
}

module fhirWithStorage 'FhirWithStorage.bicep' = {
  scope: rg
  name: 'fhirWithStorageModule'
  params: {
    location: location
    uniqueName: subscriptionUnique
    network: network.outputs.network
  }
}

param adminUsername string
@secure()
param adminPassword string

module vmModule 'Vm.bicep' = {
  scope: rg
  name: 'vmModule'
  params: {
    adminPassword: adminPassword
    adminUsername: adminUsername
    location: location
    uniqueName: subscriptionUnique
    network: network.outputs.network
  }
}
