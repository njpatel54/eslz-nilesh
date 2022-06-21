targetScope = 'tenant'

@sys.description('Optional. Location deployment metadata.')
param location string

@description('Required. Default Management Group where newly created Subscription will be added to.')
param onboardmg string

@description('Required. Indicates whether RBAC access is required upon group creation under the root Management Group. If set to true, user will require Microsoft.Management/managementGroups/write action on the root Management Group scope in order to create new Groups directly under the root. .')
param requireAuthorizationForGroupCreation bool

@description('Required. Array of Management Groups objects.')
param managementGroups array

@description('Required. Array of role assignment objects to define RBAC on management groups.')
param mgRoleAssignments array = []

@description('Required. Array of role assignment objects to define RBAC on subscriptions.')
param subRoleAssignments array = []

@description('Required. Array of Subscription objects.')
param subscriptions array

@description('Required. Azure AD Tenant ID.')
param tenantid string

param deploymentId string = substring(uniqueString(utcNow()),0,6)

// Create Management Groups
@batchSize(1)
module mg '../modules/management/managementGroups/deploy.bicep' = [ for managementGroup in managementGroups: {
  name: 'deploy-mg-${managementGroup.name}'
  //scope: managementGroup(managementGroup.name)
  params:{
    location: location
    name: managementGroup.name
    displayName: managementGroup.displayName
    parentId: managementGroup.parentId
  }
}]

// Create Role Assignments for Management Groups
module mgRbac '../modules/authorization/roleAssignments/managementGroup/deploy.bicep' = [ for (roleAssignment, index) in mgRoleAssignments :{
  name: 'ManagementGroup-Rbac-${roleAssignment.managementGroupName}-${index}'  
  scope: managementGroup(roleAssignment.managementGroupName)
  dependsOn: [
    mg
  ]
  params: {
    location: location
    description: contains(roleAssignment, 'description') ? roleAssignment.description : ''
    principalIds: roleAssignment.principalIds
    principalType: contains(roleAssignment, 'principalType') ? roleAssignment.principalType : ''
    roleDefinitionIdOrName: roleAssignment.roleDefinitionIdOrName
    managementGroupId: roleAssignment.managementGroupName              //resourceId('Microsoft.Management/managementGroups', roleAssignment.managementGroupName)
  }
}]

// Move Subscriptions to Management Groups
module moveSubs '../modules/management/moveSubs/deploy.bicep' = [ for subscription in subscriptions: {
  name: 'deploy-movesubs-${subscription.subscriptionId}-${deploymentId}'
  scope: tenant()
  dependsOn: [
    mg
  ]
  params: {
      subscriptionId: subscription.subscriptionId
      managementGroupName:  subscription.managementGroupName
  }
}]

// Create Role Assignments for Subscriptions
module subRbac '../modules/authorization/roleAssignments/subscription/deploy.bicep' = [ for (roleAssignment, index) in subRoleAssignments :{
  name: 'subscription-Rbac-${roleAssignment.subscriptionId}-${index}'
  scope: subscription(roleAssignment.subscriptionId)
  dependsOn: [
    mg
  ]
  params: {
    location: location
    description: contains(roleAssignment, 'description') ? roleAssignment.description : ''
    principalIds: roleAssignment.principalIds
    principalType: contains(roleAssignment, 'principalType') ? roleAssignment.principalType : ''
    roleDefinitionIdOrName: roleAssignment.roleDefinitionIdOrName
    subscriptionId: roleAssignment.subscriptionId
  }
}]

// Retrieve Tenant Root Management Group
resource rootmg 'Microsoft.Management/managementGroups@2021-04-01' existing = {
  name: tenantid
  scope: tenant()
}

// Configure Default Management Group Settings
resource mgSettings 'Microsoft.Management/managementGroups/settings@2021-04-01' = {
parent: rootmg
name: 'default'
dependsOn: [
  mg
]
properties: {
  defaultManagementGroup: '/providers/Microsoft.Management/managementGroups/${onboardmg}'
  requireAuthorizationForGroupCreation: requireAuthorizationForGroupCreation
}
}
