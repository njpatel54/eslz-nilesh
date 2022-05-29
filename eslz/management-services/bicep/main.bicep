param location string
param mgmtsubid string
param connsubid string
param idensubid string
param sandsubid string
param suffix string = substring(uniqueString(utcNow()),0,4)

@description('Project Owner')
@allowed([
  'ccs'
  'proj'
])
param projowner string

@description('Operational Scope')
@allowed([
  'prod'
  'dev'
  'qa'
  'stage'
  'test'
  'sand'
])
param opscope string

@description('Region')
@allowed([
  'usva'
  'ustx'
  'usaz'
])
param region string

// Build param values using string interpolation
param siem_rg_name string = 'rg-${projowner}-${opscope}-${region}-${suffix}'
param loganalytics_workspace_name string = 'log-${projowner}-${opscope}-${region}-${suffix}'
param azureautomation_name string = 'aa-${projowner}-${opscope}-${region}-${suffix}'
param storageaccount_name string = toLower('st${projowner}${opscope}${region}${suffix}')

// From Parameters Files
param storageaccount_sku string


targetScope = 'subscription'

resource siem_rg 'Microsoft.Resources/resourceGroups@2021-04-01'={
    name: siem_rg_name
    location: location
}

module loga 'loga.bicep' = {
    name: 'loga_${suffix}'
    scope: siem_rg
    params:{
        mgmtsubid: mgmtsubid
        connsubid: connsubid
        idensubid: idensubid
        sandsubid: sandsubid
        aaname: azureautomation_name
        workspacename: loganalytics_workspace_name
        location: location
    }
}

module sa 'storageaccount.bicep' = {
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
    }
}
