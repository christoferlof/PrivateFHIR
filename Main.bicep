targetScope = 'subscription'
var context = {
  uniqueName: take(uniqueString(subscription().subscriptionId),6)
  location: deployment().location
  name: deployment().name
}

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'private-fhir-${context.uniqueName}'
  location: context.location
}

module network 'Network.bicep' = {
  scope: rg
  name: '${context.name}-networkModule'
  params: {
    deployment: context
  }
}

@description('Conditional assignment of authorization rules. Will only be assigned on new deployments.')
@allowed([
  'new'
  'existing'
])
param newOrExisting string = 'new'
module fhirWithStorage 'FhirWithStorage.bicep' = {
  scope: rg
  name: '${context.name}-fhirWithStorageModule'
  params: {
    deployment: context
    network: network.outputs.network
    newOrExisting: newOrExisting
  }
}

param adminUsername string
@secure()
param adminPassword string

module vmModule 'Vm.bicep' = {
  scope: rg
  name: '${context.name}-vmModule'
  params: {
    adminPassword: adminPassword
    adminUsername: adminUsername
    deployment: context
    network: network.outputs.network
  }
}
