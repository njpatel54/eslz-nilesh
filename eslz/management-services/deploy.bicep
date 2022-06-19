targetScope = 'subscription'

@description('Required. Name for the Event Hub Namespace.')
param name string

@description('Required. Authorization Rules for Event Hub Namespace.')
param authorizationRules array = []

@description('Required. Array of Event Hubs instances.')
param eventHubs array = []

@description('Required. Subscription ID of Management Subscription.')
param mgmtsubid string

@description('Required. Subscription ID of Connectivity Subscription.')
param connsubid string

@description('Required. Subscription ID of Identity Subscription.')
param idensubid string

@description('Required. Subscription ID of Sandbox Subscription.')
param ssvcsubid string

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
param siem_rg_name string = 'rg-${projowner}-${opscope}-${region}-siem'
param loganalytics_workspace_name string = 'log-${projowner}-${opscope}-${region}-${suffix}'
param azureautomation_name string = 'aa-${projowner}-${opscope}-${region}-${suffix}'
param storageaccount_name string = toLower('st${projowner}${opscope}${region}${suffix}')

// From Parameters Files
param storageaccount_sku string

// Create Resoruce Group
resource siem_rg 'Microsoft.Resources/resourceGroups@2021-04-01'={
  name: siem_rg_name
  location: location
  tags: combinedTags
}

// Create Log Analytics Workspace
module loga './workspaces/deploy.bicep' = {
  name: 'loga_${suffix}'
  scope: siem_rg
  params:{
    mgmtsubid: mgmtsubid
    connsubid: connsubid
    idensubid: idensubid
    ssvcsubid: ssvcsubid
    aaname: azureautomation_name
    workspacename: loganalytics_workspace_name
    location: location
    tags: combinedTags
  }
}

// Create Storage Account
module sa './storageAccounts/deploy.bicep' = {
  name: 'sa_${suffix}'
  scope: siem_rg
  dependsOn: [
    loga
  ]
  params: {
    location: location
    storageAccountName: storageaccount_name
    storageSKU: storageaccount_sku
    diagnosticWorkspaceId: loga.outputs.resourceId
    tags: combinedTags
  }
}

// Create Event Hub Namespace and Event Hub
module eh './namespaces/deploy.bicep' = {
  name: 'eh_${suffix}'
  scope: siem_rg
  dependsOn: [
    loga
  ]
  params: {
    location: location
    eventhubNamespaceName: name
    diagnosticWorkspaceId: loga.outputs.resourceId
    tags: combinedTags
    eventHubs: eventHubs
    authorizationRules: authorizationRules
  }
}
