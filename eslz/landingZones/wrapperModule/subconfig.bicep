targetScope = 'managementGroup'

@description('Location for the deployments and the resources')
param location string

@description('Required. Array of role assignment objects to define RBAC on subscriptions.')
param subRoleAssignments array = []

@description('Required. Name for the Diagnostics Setting Configuration.')
param diagSettingName string = ''

@description('Optional. Resource ID of the diagnostic log analytics workspace.')
param diagnosticWorkspaceId string = ''

@description('subscriptionId for the deployment')
param subscriptionId string

@description('Required. Combine Tags in dynamoctags object with Tags from parameter file.')
param combinedTags object

// 1. Create Role Assignments for Subscription
module subRbac '../../modules/authorization/roleAssignments/subscription/deploy.bicep' = [for (roleAssignment, index) in subRoleAssignments: {
  name: 'subRbac-${take(uniqueString(deployment().name, location), 4)}-${index}'
  scope: subscription(subscriptionId)
  params: {
    location: location
    description: contains(roleAssignment, 'description') ? roleAssignment.description : ''
    principalIds: roleAssignment.principalIds
    principalType: contains(roleAssignment, 'principalType') ? roleAssignment.principalType : ''
    roleDefinitionIdOrName: roleAssignment.roleDefinitionIdOrName
    subscriptionId: subscriptionId
  }
}]

// 2. Configure Diagnostics Settings for Subscriptions
module subDiagSettings '../../modules/insights/diagnosticSettings/sub.deploy.bicep' = {
  name: 'subDiagSettings-${subscriptionId}'
  scope: subscription(subscriptionId)
  params: {
    name: diagSettingName
    location: location
    diagnosticWorkspaceId: diagnosticWorkspaceId
  }
}

//3 Configure Tags for Subscription
module subTags '../../modules/resources/tags/subscriptions/deploy.bicep' = {
  name: 'subTags-${subscriptionId}'
  scope: subscription(subscriptionId)
    params: {
    tags: combinedTags
  }
}
