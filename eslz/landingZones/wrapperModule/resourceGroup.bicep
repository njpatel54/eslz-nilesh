targetScope = 'managementGroup'

@description('Required. Array of role assignment objects to define RBAC on subscriptions.')
param subRoleAssignments array = []

@description('subscriptionId for the deployment')
param subscriptionId string

@description('Location for the deployments and the resources')
param location string

@description('Required. Combine Tags in dynamoctags object with Tags from parameter file.')
param combinedTags object

@description('Contains the resourceGroup names.')
param resourceGroups array

@description('Required. Array of role assignment objects to define RBAC on Resource Groups.')
param rgRoleAssignments array = []

// 1. Create Role Assignments for Subscription
module subRbac '../../modules/authorization/roleAssignments/subscription/deploy.bicep' = [ for (roleAssignment, index) in subRoleAssignments :{
  name: 'subRbac-${subscriptionId}-${index}'
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

// 2. Create Resoruce Groups
module rg '../../modules/resourceGroups/deploy.bicep'= [ for (resourceGroup, index) in resourceGroups :{
  name: 'rg-${take(uniqueString(deployment().name, location), 4)}-${resourceGroup}'
  scope: subscription(subscriptionId)
  params: {
    name: resourceGroup
    location: location
    tags: combinedTags
  }
}]

// 3. Create Role Assignments for Resoruce Group
module rgRbac '../../modules/authorization/roleAssignments/resourceGroup/deploy.bicep' = [ for (roleAssignment, index) in rgRoleAssignments :{
  name: 'rgRbac-${roleAssignment.resourceGroupName}-${index}'
  scope: resourceGroup(roleAssignment.subscriptionId, roleAssignment.resourceGroupName)
  dependsOn: [
    rg
  ]
  params: {
    description: contains(roleAssignment, 'description') ? roleAssignment.description : ''
    principalIds: roleAssignment.principalIds
    principalType: contains(roleAssignment, 'principalType') ? roleAssignment.principalType : ''
    roleDefinitionIdOrName: roleAssignment.roleDefinitionIdOrName
    subscriptionId: contains(roleAssignment, 'subscriptionId') && !empty(roleAssignment.subscriptionId) ? roleAssignment.subscriptionId : subscriptionId
    resourceGroupName: roleAssignment.resourceGroupName
  }
}]

@description('Output - Resource Group "name" Array')
output name array = [ for (resourceGroup, index) in resourceGroups :{
  resourceId: rg[index].outputs.resourceId
}]

@description('Output - Resource Group "resoruceId" Array')
output resoruceId array = [ for (resourceGroup, index) in resourceGroups :{
  resourceId: rg[index].outputs.resourceId
}]
