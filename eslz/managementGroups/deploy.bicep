targetScope = 'tenant'

@description('Required. Default Management Group where newly created Subscription will be added to.')
param onboardmg string

@description('Required. Indicates whether RBAC access is required upon group creation under the root Management Group. If set to true, user will require Microsoft.Management/managementGroups/write action on the root Management Group scope in order to create new Groups directly under the root. .')
param requireAuthorizationForGroupCreation bool

@description('Required. Array of Management Groups objects.')
param managementGroups array

@description('Required. Array of role assignment objects to define RBAC on this resource.')
param roleAssignments array = []

@description('Required. Array of Subscription objects.')
param subscriptions array

@description('Required. Azure AD Tenant ID.')
param tenantid string

param deploymentId string = substring(uniqueString(utcNow()),0,6)

// Create Management Groups
@batchSize(1)
module resource_managementGroups 'managementGroup/deploy.bicep' = [ for managementGroup in managementGroups: {
  name: 'deploy-mg-${managementGroup.name}'
  params:{
    name: managementGroup.name
    displayName: managementGroup.displayName
    parentMGName: managementGroup.parentMGName
    roleAssignments: roleAssignments
  }
}]

// Create Role Assignments
module managementGroup_rbac './managementGroup/.bicep/nested_rbac.bicep' = [ for (roleAssignment, index) in roleAssignments :{
  name: 'ManagementGroup-Rbac-${roleAssignment.managementGroupName}-${index}'
  dependsOn: [
    resource_managementGroups
  ]
  params: {
    description: contains(roleAssignment, 'description') ? roleAssignment.description : ''
    principalIds: roleAssignment.principalIds
    principalType: contains(roleAssignment, 'principalType') ? roleAssignment.principalType : ''
    roleDefinitionIdOrName: roleAssignment.roleDefinitionIdOrName
    resourceId: resourceId('Microsoft.Management/managementGroups', roleAssignment.managementGroupName)
  }
  scope: managementGroup(roleAssignment.managementGroupName)
}]

// Move Subscriptions to Management Groups
module movesubs './moveSubs/deploy.bicep' = [ for subscription in subscriptions: {
  name: 'deploy-movesubs-${subscription.subscriptionId}-${deploymentId}'
  dependsOn: [
    resource_managementGroups
  ]
  params: {
      subscriptionId: subscription.subscriptionId
      managementGroupName:  subscription.managementGroupName
  }
}]


// Configure Default Management Group Settings
resource rootmg 'Microsoft.Management/managementGroups@2021-04-01' existing = {
    name: tenantid
}

resource mg_settings 'Microsoft.Management/managementGroups/settings@2021-04-01' = {
  parent: rootmg
  name: 'default'
  dependsOn: [
    resource_managementGroups
  ]
  properties: {
      defaultManagementGroup: '/providers/Microsoft.Management/managementGroups/${onboardmg}'
      requireAuthorizationForGroupCreation: requireAuthorizationForGroupCreation
  }
}
