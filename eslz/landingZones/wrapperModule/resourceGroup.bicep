targetScope = 'managementGroup'

@description('Required. Array of role assignment objects to define RBAC on subscriptions.')
param subRoleAssignments array = []

@description('subscriptionId for the deployment')
param subscriptionId string

@description('Location for the deployments and the resources')
param location string = deployment().location

@description('Required. Combine Tags in dynamoctags object with Tags from parameter file.')
param combinedTags object

@description('Name of the resourceGroup, will be created in the same location as the deployment.')
param lzRgName string

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

// 2. Create Resoruce Group
module rg '../../modules/resourceGroups/deploy.bicep'= {
  name: 'rg-${take(uniqueString(deployment().name, location), 4)}-${lzRgName}'
  scope: subscription(subscriptionId)
  params: {
    name: lzRgName
    location: location
    tags: combinedTags
  }
}

// 3. Create Role Assignments for Resoruce Group
module rgRbac '../../modules/authorization/roleAssignments/resourceGroup/deploy.bicep' = [ for (roleAssignment, index) in rgRoleAssignments :{
  name: 'rgRbac-${roleAssignment.resourceGroupName}-${index}'
  scope: resourceGroup(roleAssignment.subscriptionId, roleAssignment.resourceGroupName)
  params: {
    description: contains(roleAssignment, 'description') ? roleAssignment.description : ''
    principalIds: roleAssignment.principalIds
    principalType: contains(roleAssignment, 'principalType') ? roleAssignment.principalType : ''
    roleDefinitionIdOrName: roleAssignment.roleDefinitionIdOrName
    subscriptionId: roleAssignment.subscriptionId
    resourceGroupName: roleAssignment.resourceGroupName
  }
}]

@description('Output - Resoruce Group Name')
output rgName string = rg.outputs.name

@description('Output - Resoruce Group resourceId')
output rgResoruceId string = rg.outputs.resourceId
