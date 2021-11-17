targetScope = 'subscription'
var subscriptionUnique = take(uniqueString(subscription().subscriptionId),4)

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'private-fhir-${subscriptionUnique}'
  location: 'northeurope'
}
