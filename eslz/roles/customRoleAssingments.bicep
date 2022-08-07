targetScope = 'tenant'

@sys.description('Optional. Location deployment metadata.')
param location string

@description('Required. Array of role assignment objects to define RBAC on management groups.')
param mgRoleAssignments array = []

@description('Required. Array of role assignment objects to define RBAC on subscriptions.')
param subRoleAssignments array = []

@description('Required. Array of role assignment objects to define RBAC on Resource Groups.')
param rgRoleAssignments array = []

// 1. Create Role Assignments at Management Group Scope
module mgRbac '../modules/authorization/roleAssignments/managementGroup/deploy.bicep' = [ for (roleAssignment, index) in mgRoleAssignments :{
  name: 'mgRbac-${roleAssignment.managementGroupName}-${index}'  
  scope: managementGroup(roleAssignment.managementGroupName)
  params: {
    location: location
    description: contains(roleAssignment, 'description') ? roleAssignment.description : ''
    principalIds: roleAssignment.principalIds
    principalType: contains(roleAssignment, 'principalType') ? roleAssignment.principalType : ''
    roleDefinitionIdOrName: roleAssignment.roleDefinitionIdOrName
    managementGroupId: roleAssignment.managementGroupName
  }
}]

// 2. Create Role Assignments at Subscription Scope
module subRbac '../modules/authorization/roleAssignments/subscription/deploy.bicep' = [ for (roleAssignment, index) in subRoleAssignments :{
  name: 'subRbac-${roleAssignment.subscriptionId}-${index}'
  scope: subscription(roleAssignment.subscriptionId)
  params: {
    location: location
    description: contains(roleAssignment, 'description') ? roleAssignment.description : ''
    principalIds: roleAssignment.principalIds
    principalType: contains(roleAssignment, 'principalType') ? roleAssignment.principalType : ''
    roleDefinitionIdOrName: roleAssignment.roleDefinitionIdOrName
    subscriptionId: roleAssignment.subscriptionId
  }
}]

// 3. Create Role Assignments at Resource Group Scope
module rgRbac '../modules/authorization/roleAssignments/resourceGroup/deploy.bicep' = [ for (roleAssignment, index) in rgRoleAssignments :{
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
