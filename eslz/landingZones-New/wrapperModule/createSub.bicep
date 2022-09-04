targetScope = 'managementGroup'

@description('Location for the deployments and the resources')
param location string

@description('Required. Combine Tags in dynamoctags object with Tags from parameter file.')
param combinedTags object

@description('Required. BillingAccount used for subscription billing')
param billingAccount string

@description('Required. EnrollmentAccount used for subscription billing')
param enrollmentAccount string

@description('Required. Alias to assign to the subscription')
param subscriptionAlias string

@description('Required. Display name for the subscription')
param subscriptionDisplayName string

@description('Required. Workload type for the subscription')
@allowed([
  'Production'
  'DevTest'
])
param subscriptionWorkload string

@description('Required. Management Group target for the subscription')
param managementGroupId string

@description('Required. Subscription Owner Id for the subscription')
param subscriptionOwnerId string

// 1. Creat Subscription
module sub '../../modules/subscription/alias/deploy.bicep' = {
  name: 'mod-sub-${take(uniqueString(deployment().name, location), 4)}-${subscriptionAlias}'
  params: {
    billingAccount: billingAccount
    enrollmentAccount: enrollmentAccount
    subscriptionAlias: subscriptionAlias
    subscriptionDisplayName: subscriptionDisplayName
    subscriptionWorkload: subscriptionWorkload
    managementGroupId: '/providers/Microsoft.Management/managementGroups/${managementGroupId}'
    subscriptionOwnerId: subscriptionOwnerId
    tags: combinedTags
  }
}

output subscriptionId string = sub.outputs.subscriptionId
