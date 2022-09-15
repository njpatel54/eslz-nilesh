targetScope = 'managementGroup'

@description('Provide a name for the alias. This name will also be the display name of the subscription.')
param subscriptionAliasName string

@description('Provide the full resourceId of the MCA or the enrollment account id used for subscription creation.')
param billingAccountId string

@description('Provide the resourceId of the target management group to place the subscription.')
param targetManagementGroup string

resource subscriptionAliasName_resource 'Microsoft.Subscription/aliases@2020-09-01' = {
  scope: tenant()
  name: subscriptionAliasName
  properties: {
    workload: 'Production'
    displayName: subscriptionAliasName
    billingScope: billingAccountId
    managementGroupId: tenantResourceId('Microsoft.Management/managementGroups/', targetManagementGroup)
  }
}