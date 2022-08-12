@description('subscriptionId for the deployment')
param subscriptionId string

@description('Location for the deployments and the resources')
param location string

@description('Required. Combine Tags in dynamoctags object with Tags from parameter file.')
param combinedTags object

@description('Required. Name of the resourceGroup, where application workload will be deployed.')
param wlRgName string


@description('Required. Subscription ID of Connectivity Subscription')
param connsubid string

@description('Required. Resource Group name.')
param vnetRgName string

@description('Required. Log Ananlytics Workspace Name for resource Diagnostics Settings - Log Collection.')
param logsLawName string

@description('Optional. List of gallerySolutions to be created in the Log Ananlytics Workspace for resource Diagnostics Settings - Log Collection.')
param logaGallerySolutions array = []

@description('Optional. The network access type for accessing Log Analytics ingestion.')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccessForIngestion string

@description('Optional. The network access type for accessing Log Analytics query.')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccessForQuery string

@description('Required. Azure Monitor Private Link Scope Name.')
param amplsName string

// 1. Create Log Analytics Workspace
module loga '../../modules/operationalInsights/workspaces/deploy.bicep' = {
  name: 'mod-loga-${take(uniqueString(deployment().name, location), 4)}-${logsLawName}'
  scope: resourceGroup(subscriptionId, wlRgName)
  params:{
    name: logsLawName
    location: location
    tags: combinedTags
    gallerySolutions: logaGallerySolutions
    publicNetworkAccessForIngestion: publicNetworkAccessForIngestion
    publicNetworkAccessForQuery: publicNetworkAccessForQuery
  }
}

// 2. Add Log Analytics Workspace to Azure Monitor Private Link Scope (AMPLS)
module amplssr '../../modules//insights//privateLinkScopes/scopedResources/deploy.bicep' = {
  name: 'mod-amplssr-${take(uniqueString(deployment().name, location), 4)}-${logsLawName}'
  scope: resourceGroup(connsubid, vnetRgName)
  dependsOn: [
    loga
  ]
  params: {
    linkedResourceId: loga.outputs.resourceId
    name: logsLawName
    privateLinkScopeName: amplsName
  }
}

@description('Output - Log Analytics Workspace "name"')
output logaName string = loga.outputs.name

@description('Output - Log Analytics Workspace "resoruceId"')
output logaResoruceId string = loga.outputs.resourceId
