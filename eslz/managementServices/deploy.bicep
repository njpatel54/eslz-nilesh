targetScope = 'subscription'

@description('Required. Name for the Event Hub Namespace.')
param eventhubNamespaceName string

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
param rgName string = 'rg-${projowner}-${opscope}-${region}-siem'
param lawName string = 'log-${projowner}-${opscope}-${region}-${suffix}'
param automationAcctName string = 'aa-${projowner}-${opscope}-${region}-${suffix}'
param stgAcctName string = toLower('st${projowner}${opscope}${region}${suffix}')

// From Parameters Files
param storageaccount_sku string

// Create Resoruce Group
module siem_rg '../resourceGroups/deploy.bicep'= {
  name: 'rg-${uniqueString(deployment().name, location)}-${rgName}'
  scope: subscription(mgmtsubid)
  params: {
    name: rgName
    location: location
    tags: combinedTags
  }
}

// Create Log Analytics Workspace
module loga '../workspaces/deploy.bicep' = {
  name: 'loga-${uniqueString(deployment().name, location)}-${lawName}'
  scope: resourceGroup(rgName)
  params:{
    mgmtsubid: mgmtsubid
    connsubid: connsubid
    idensubid: idensubid
    ssvcsubid: ssvcsubid
    aaname: automationAcctName
    workspacename: lawName
    location: location
    tags: combinedTags
  }
}

// Create Storage Account
module sa '../storageAccounts/deploy.bicep' = {
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
module eh '../namespaces/deploy.bicep' = {
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
