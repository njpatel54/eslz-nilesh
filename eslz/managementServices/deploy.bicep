targetScope = 'tenant'

@description('Required. Name for the Diagnostics Setting Configuration.')
param diagSettingName string

@description('Optional. List of gallerySolutions to be created in the Log Ananlytics Workspace for Azure Sentinel.')
param logaSentinelGallerySolution array = []

@description('Optional. List of gallerySolutions to be created in the Log Ananlytics Workspace for resource Diagnostics Settings - Log Collection.')
param logaGallerySolutions array = []

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

@description('Required. Location for all resources.')
param location string

@description('Required. Suffix to be used in resource naming with 4 characters.')
param suffix string = substring(uniqueString(utcNow()),0,4)

@description('Required. utcfullvalue to be used in Tags.')
param utcfullvalue string = utcNow('F')

@description('Required. Assign utffullvaule to "CreatedOn" tag.')
param dynamictags object = ({
  CreatedOn: utcfullvalue
})

var tags = json(loadTextContent('../tags.json'))

@description('Required. Combine Tags in dynamoctags object with Tags from parameter file.')
var ccsCombinedTags = union(dynamictags, tags.ccsTags.value)
//var lzCombinedTags = union(dynamictags, tags.lz01Tags.value)

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
@description('Required. SIEM Resource Group Name.')
param rgName string = 'rg-${projowner}-${opscope}-${region}-siem'

@description('Required. Log Ananlytics Workspace Name for Azure Sentinel.')
param sentinelLawName string = 'log-${projowner}-${opscope}-${region}-siem'

@description('Required. Log Ananlytics Workspace Name for resource Diagnostics Settings - Log Collection.')
param logsLawName string = 'log-${projowner}-${opscope}-${region}-logs'

@description('Required. Eventhub Namespace Name for resource Diagnostics Settings - Log Collection.')
param eventhubNamespaceName string = 'evhns-${projowner}-${opscope}-${region}-${suffix}'

@description('Required. Automation Account Name.')
param automationAcctName string = 'aa-${projowner}-${opscope}-${region}-${suffix}'

@description('Required. Storage Account Name for resource Diagnostics Settings - Log Collection.')
param stgAcctName string = toLower(take('st${projowner}${opscope}${region}${suffix}', 24))

// From Parameters Files
@description('Required. Storage Account SKU.')
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
  name: 'rg-${take(uniqueString(deployment().name, location), 4)}-${rgName}'
  scope: subscription(mgmtsubid)
  params: {
    name: rgName
    location: location
    tags: ccsCombinedTags
  }
}

// Create Log Analytics Workspace for Azure Sentinel
module logaSentinel '../modules/operationalInsights/workspaces/deploy.bicep' = {
  name: 'logaSentinel-${take(uniqueString(deployment().name, location), 4)}-${sentinelLawName}'
  scope: resourceGroup(mgmtsubid, rgName)
  dependsOn: [
    siem_rg
  ]
  params:{
    name: sentinelLawName
    location: location
    tags: ccsCombinedTags
    gallerySolutions: logaSentinelGallerySolution    
  }
}

// Create Log Analytics Workspace for resource Diagnostics Settings - Log Collection
module loga '../modules/operationalInsights/workspaces/deploy.bicep' = {
  name: 'loga-${take(uniqueString(deployment().name, location), 4)}-${logsLawName}'
  scope: resourceGroup(mgmtsubid, rgName)
  dependsOn: [
    siem_rg
  ]
  params:{
    name: logsLawName
    location: location
    tags: ccsCombinedTags
    gallerySolutions: logaGallerySolutions    
  }
}

// Create Storage Account
module sa '../modules/storageAccounts/deploy.bicep' = {
  name: 'sa-${take(uniqueString(deployment().name, location), 4)}-${stgAcctName}'
  scope: resourceGroup(mgmtsubid, rgName)
  dependsOn: [
    loga
  ]
  params: {
    location: location
    storageAccountName: stgAcctName
    storageSKU: storageaccount_sku
    diagnosticWorkspaceId: loga.outputs.resourceId
    tags: ccsCombinedTags
  }
}

// Create Event Hub Namespace and Event Hub
module eh '../modules/namespaces/deploy.bicep' = {
  name: 'eh-${take(uniqueString(deployment().name, location), 4)}-${eventhubNamespaceName}'
  scope: resourceGroup(mgmtsubid, rgName)
  dependsOn: [
    loga
  ]
  params: {
    location: location
    tags: ccsCombinedTags
    eventhubNamespaceName: eventhubNamespaceName
    eventHubs: eventHubs
    authorizationRules: authorizationRules
    diagnosticStorageAccountId: sa.outputs.resourceId
    diagnosticWorkspaceId: loga.outputs.resourceId
  }
}

// Create Automation Account and link it to Log Analytics Workspace
module aa '../modules/automation/automationAccounts/deploy.bicep' = {
  name: 'aa-${take(uniqueString(deployment().name, location), 4)}-${automationAcctName}'
  scope: resourceGroup(mgmtsubid, rgName)
  dependsOn: [
    siem_rg
    loga
    sa
    eh
  ]
  params:{
    name: automationAcctName
    location: location
    tags: ccsCombinedTags
    linkedWorkspaceResourceId: loga.outputs.resourceId
    diagnosticStorageAccountId: sa.outputs.resourceId
    diagnosticWorkspaceId: loga.outputs.resourceId
    diagnosticEventHubName: eventHubs[0].name    //First Event Hub name from eventHubs object in parameter file.
    diagnosticEventHubAuthorizationRuleId: resourceId(mgmtsubid, rgName, 'Microsoft.EventHub/namespaces/AuthorizationRules', eventhubNamespaceName, 'RootManageSharedAccessKey')
  }
}

// Configure Diagnostics Settings for Subscriptions
module subDiagSettings '../modules/insights/diagnosticSettings/sub.deploy.bicep' = [ for subscription in subscriptions: {
  name: 'diagSettings-${subscription.subscriptionId}'
  scope: subscription(subscription.subscriptionId)
  dependsOn: [
    siem_rg
    loga
    sa
    eh
  ]
  params:{
    name: diagSettingName
    location: location
    diagnosticStorageAccountId: sa.outputs.resourceId
    diagnosticWorkspaceId: loga.outputs.resourceId
    diagnosticEventHubName: eventHubs[0].name    //First Event Hub name from eventHubs object in parameter file.
    diagnosticEventHubAuthorizationRuleId: resourceId(mgmtsubid, rgName, 'Microsoft.EventHub/namespaces/AuthorizationRules', eventhubNamespaceName, 'RootManageSharedAccessKey')
  }
}]

@description('Output - Name of Event Hub')
output ehnsAuthorizationId string = resourceId(mgmtsubid, rgName, 'Microsoft.EventHub/namespaces/AuthorizationRules', eventhubNamespaceName, 'RootManageSharedAccessKey')

@description('Output - SIEM Resource Group Name')
output siemRgName string = siem_rg.outputs.name

@description('Output - SIEM Resource Group resourceId')
output siemRgresourceId string = siem_rg.outputs.resourceId

@description('Output - Log Analytics Workspce Name - resource Diagnostics Settings - Log Collection')
output logaSentinelName string = logaSentinel.outputs.name

@description('Output - Log Analytics Workspce resourceId - resource Diagnostics Settings - Log Collection')
output logaSentinelResourceId string = logaSentinel.outputs.resourceId

@description('Output - Log Analytics Workspce Name - resource Diagnostics Settings - Log Collection')
output logaName string = loga.outputs.name

@description('Output - Log Analytics Workspce resourceId - resource Diagnostics Settings - Log Collection')
output logaResourceId string = loga.outputs.resourceId

@description('Output - Storage Account Name')
output saName string = sa.outputs.name

@description('Output - Storage Account resourceId')
output saResourceId string = sa.outputs.resourceId

@description('Output - Eventhub Namespace Name')
output ehNamespaceName string = eh.outputs.name

@description('Output - Subscription Diagnostics Settings Names Array')
output subDiagSettingsNames array = [for (subscription, i) in subscriptions: {  
  subscriptionId: subDiagSettings[i].outputs.resourceId
  diagnosticSettingsName: subDiagSettings[i].outputs.name
}]

// Start - Outputs to supress warnings - "unused parameters"
output onboardmg string = onboardmg
output requireAuthorizationForGroupCreation bool = requireAuthorizationForGroupCreation
output managementGroups array = managementGroups
output mgRoleAssignments array = mgRoleAssignments
output subRoleAssignments array = subRoleAssignments
output tenantid string = tenantid
output diagnosticStorageAccountId string = diagnosticStorageAccountId
output diagnosticWorkspaceId string = diagnosticWorkspaceId
output diagnosticEventHubAuthorizationRuleId string = diagnosticEventHubAuthorizationRuleId
output diagnosticEventHubName string = diagnosticEventHubName
// End - Outputs to supress warnings - "unused parameters"

/*
// Currently DiagnosticSettings at Management Group level is supported in Azure US Gov - (Reference - https://github.com/Azure/azure-powershell/issues/17717)
// Configure Diagnostics Settings for Management Groups
module mgDiagSettings '../modules/insights/diagnosticSettings/mg.deploy.bicep' = [ for managementGroup in managementGroups: {
  name: 'diagSettings-${managementGroup.name}'
//  scope: managementGroup(managementGroup.name)
  dependsOn: [
    siem_rg
    loga
    sa
    eh
  ]
  params:{
    name: diagSettingName
    location: location
    diagnosticStorageAccountId: sa.outputs.resourceId
    diagnosticWorkspaceId: loga.outputs.resourceId
    diagnosticEventHubName: eventHubs[0].name
    diagnosticEventHubAuthorizationRuleId: resourceId(mgmtsubid, rgName, 'Microsoft.EventHub/namespaces/AuthorizationRules', eventhubNamespaceName, 'RootManageSharedAccessKey')
  }
}]
*/
