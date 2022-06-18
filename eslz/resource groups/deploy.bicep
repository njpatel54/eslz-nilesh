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
param lz01subid string

@description('Required. Subscription ID of Sandbox Subscription.')
param sandsubid string

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
param siem_rg_name string = 'rg-${projowner}-${opscope}-${region}-${suffix}'

// Create Resoruce Group
module rg './resourceGroups/deploy.bicep'= [ for (vNet, index) in spokeVnets :{
  name: siem_rg_name
  location: location
  tags: combinedTags
}]
