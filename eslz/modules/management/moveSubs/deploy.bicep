param subscriptionId string
param managementGroupName string

targetScope='tenant'

resource managementGroup 'Microsoft.Management/managementGroups@2021-04-01' existing = {
  name: managementGroupName
}

resource movesub 'Microsoft.Management/managementGroups/subscriptions@2021-04-01' = {
  parent: managementGroup
  name: subscriptionId
}


@sys.description('The management group name.')
output mgName string = managementGroupName

@sys.description('The Subscription ID.')
output subId string = subscriptionId
