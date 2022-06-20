targetScope = 'subscription'

@description('Required. Name for the Event Hub Namespace.')
param eventhubNamespaceName string

@description('Required. Authorization Rules for Event Hub Namespace.')
param authorizationRules array = []

@description('Required. Array of Event Hubs instances.')
param eventHubs array = []

@description('Required. Subscription ID of Management Subscription.')
param mgmtsubid string

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

/*
@description('Required. Subscription ID of Connectivity Subscription.')
param connsubid string

@description('Required. Subscription ID of Identity Subscription.')
param idensubid string

@description('Required. Subscription ID of Sandbox Subscription.')
param ssvcsubid string
*/

@description('Required. Location for all resources.')
param location string

@description('Required. Suffix to be used in resource naming with 4 characters.')
param suffix string = substring(uniqueString(utcNow()),0,4)

@description('Required. utcfullvalue to be used in Tags.')
param utcfullvalue string = utcNow('F')

@description('Required. Resource Tags.')
param tags object

@description('Required. Assign utffullvaule to "CreatedOn" tag.')
param dynamictags object = ({
  CreatedOn: utcfullvalue
})

@description('Required. Combine Tags in dynamoctags object with Tags from parameter file.')
var combinedTags = union(dynamictags, tags)

@description('Required. Project Owner (projowner) parameter.')
@allowed([
  'ccs'
  'proj'
])
param projowner string

@description('Required. Operational Scope (opscope) parameter.')
@allowed([
  'prod'
  'dev'
  'qa'
  'stage'
  'test'
  'sand'
])
param opscope string

@description('Required. Region (region) parameter.')
@allowed([
  'usva'
  'ustx'
  'usaz'
])
param region string

// Build param values using string interpolation
param rgName string = 'rg-${projowner}-${opscope}-${region}-siem'
param lawName string = 'log-${projowner}-${opscope}-${region}-siem'
param automationAcctName string = 'aa-${projowner}-${opscope}-${region}-siem'
param stgAcctName string = toLower(take('st${projowner}${opscope}${region}${suffix}', 24))

// From Parameters Files
param storageaccount_sku string

@description('Optional. Resource ID of the diagnostic storage account.')
param diagnosticStorageAccountId string = ''

@description('Optional. Resource ID of the diagnostic log analytics workspace.')
param diagnosticWorkspaceId string = ''

@description('Optional. Resource ID of the diagnostic event hub authorization rule for the Event Hubs namespace in which the event hub should be created or streamed to.')
param diagnosticEventHubAuthorizationRuleId string = ''

@description('Optional. Name of the diagnostic event hub within the namespace to which logs are streamed. Without this, an event hub is created for each log category.')
param diagnosticEventHubName string = ''

// Create Resoruce Group
module siem_rg '../modules/resourceGroups/deploy.bicep'= {
  name: 'rg-${uniqueString(deployment().name, location)}-${rgName}'
  scope: subscription(mgmtsubid)
  params: {
    name: rgName
    location: location
    tags: combinedTags
  }
}

// Create Log Analytics Workspace
module loga '../modules/workspaces/deploy.bicep' = {
  name: 'loga-${uniqueString(deployment().name, location)}-${lawName}'
  scope: resourceGroup(rgName)
  dependsOn: [
    siem_rg
  ]
  params:{
    //mgmtsubid: mgmtsubid
    //connsubid: connsubid
    //idensubid: idensubid
    //ssvcsubid: ssvcsubid
    aaname: automationAcctName
    workspacename: lawName
    location: location
    tags: combinedTags
  }
}

// Create Storage Account
module sa '../modules/storageAccounts/deploy.bicep' = {
  name: 'sa-${uniqueString(deployment().name, location)}-${stgAcctName}'
  scope: resourceGroup(rgName)
  dependsOn: [
    loga
  ]
  params: {
    location: location
    storageAccountName: stgAcctName
    storageSKU: storageaccount_sku
    diagnosticWorkspaceId: loga.outputs.resourceId
    tags: combinedTags
  }
}

// Create Event Hub Namespace and Event Hub
module eh '../modules/namespaces/deploy.bicep' = {
  name: 'eh_${suffix}'
  scope: resourceGroup(rgName)
  dependsOn: [
    loga
  ]
  params: {
    location: location
    eventhubNamespaceName: eventhubNamespaceName
    diagnosticWorkspaceId: loga.outputs.resourceId
    tags: combinedTags
    eventHubs: eventHubs
    authorizationRules: authorizationRules
  }
}

// Configure Diagnostics Settings for Subscriptions
module diagSettings '../modules/insights/diagnosticSettings/deploy.bicep' = [ for subscription in subscriptions: {
  name: 'diagSettings-${subscription.subscriptionId}'
  scope: subscription(subscription.subscriptionId)
  dependsOn: [
    siem_rg
    loga
    sa
    eh
  ]
  params:{
    location: location
    diagnosticStorageAccountId: diagnosticStorageAccountId
    diagnosticWorkspaceId: diagnosticWorkspaceId
    diagnosticEventHubName: diagnosticEventHubName
    diagnosticEventHubAuthorizationRuleId: diagnosticEventHubAuthorizationRuleId
  }
}]
