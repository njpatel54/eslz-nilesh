targetScope='tenant'

@description('subscriptionId for the deployment')
param subscriptionId string

@description('Required. The group ID of the Management group.')
param managementGroupName string

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
