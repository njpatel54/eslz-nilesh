targetScope = 'subscription'

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

// 1. Create Resoruce Groups
module rg '../../modules/resourceGroups/deploy.bicep'= [ for (resourceGroup, index) in resourceGroups :{
  name: 'rg-${take(uniqueString(deployment().name, location), 4)}-${resourceGroup}'
  scope: subscription(subscriptionId)
  params: {
    name: resourceGroup
    location: location
    tags: combinedTags
  }
}]

// 2. Create Role Assignments for Resoruce Group
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
output rgNames array = [ for (resourceGroup, index) in resourceGroups :{
  resourceId: rg[index].outputs.resourceId
}]

@description('Output - Resource Group "resoruceId" Array')
output rgResoruceIds array = [ for (resourceGroup, index) in resourceGroups :{
  resourceId: rg[index].outputs.resourceId
}]
