
@description('Required. Project Owner (projowner) parameter.')
@allowed([
  'ccs'
  'proj'
])
param projowner string = 'ccs'

@description('Required. Operational Scope (opscope) parameter.')
@allowed([
  'prod'
  'dev'
  'qa'
  'stage'
  'test'
  'sand'
])
param opscope string = 'prod'

@description('Required. Region (region) parameter.')
@allowed([
  'usva'
  'ustx'
  'usaz'
])
param region string = 'usva'
@description('Required. Subscription ID of Management Subscription.')
param mgmtsubid string

@description('Required. SIEM Resource Group Name.')
param siemRgName string = 'rg-${projowner}-${opscope}-${region}-siem'


@description('Required. Log Ananlytics Workspace Name for Azure Sentinel.')
param sentinelLawName string = 'log-${projowner}-${opscope}-${region}-test'

@description('Optional. List of gallerySolutions to be created in the Log Ananlytics Workspace for Azure Sentinel.')
param logaSentinelGallerySolution array = []

@description('Optional. The network access type for accessing Log Analytics ingestion.')
param publicNetworkAccessForIngestion string = ''

@description('Optional. The network access type for accessing Log Analytics query.')
param publicNetworkAccessForQuery string = ''

@description('Required. Location for all resources.')
param location string

/*
@description('Required. Suffix to be used in resource naming with 4 characters.')
param suffix string = substring(uniqueString(utcNow()),0,4)
*/

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

module logaSentinel '../modules/operationalInsights/workspaces/deploy.bicep' = {
  name: 'logaSentinel-${take(uniqueString(deployment().name, location), 4)}-${sentinelLawName}'
  scope: resourceGroup(mgmtsubid, siemRgName)
  params:{
    name: sentinelLawName
    location: location
    tags: ccsCombinedTags
    gallerySolutions: logaSentinelGallerySolution    
    publicNetworkAccessForIngestion: publicNetworkAccessForIngestion
    publicNetworkAccessForQuery: publicNetworkAccessForQuery
  }
}

