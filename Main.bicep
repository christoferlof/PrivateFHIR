targetScope = 'subscription'
var subscriptionUnique = take(uniqueString(subscription().subscriptionId),6)
var location = 'northeurope'

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'private-fhir-${subscriptionUnique}'
  location: location
}

module storageModule 'Storage.bicep' = {
  scope: rg
  name: 'storageModule'
  params: {
    location: location
    uniqueName: subscriptionUnique
  }
}
