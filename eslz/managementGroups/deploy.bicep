targetScope = 'tenant'

@description('Required. The group ID of the Management group.')
param name string

@description('Optional. The friendly name of the management group. If no value is passed then this field will be set to the group ID.')
param displayName string = ''

@description('Optional. The management group parent ID. Defaults to current scope.')
param parentMGName string = ''

@description('Optional. Array of role assignment objects to define RBAC on this resource.')
param roleAssignments array = []

param deploymentId string = substring(uniqueString(utcNow()),0,6)

// From Parameters File
param onboardmg string
param requireAuthorizationForGroupCreation bool
param managementGroups array
param subscriptions array
param tenantid string

// Create Management Groups
@batchSize(1)
module resource_managementGroups 'managementGroup/deploy.bicep' = [ for managementGroup in managementGroups: {
  name: 'deploy-mg-${managementGroup.name}'
  params:{
    name: managementGroup.name
    displayName: managementGroup.displayName
    parentMGName: managementGroup.parentMGName
  }
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
