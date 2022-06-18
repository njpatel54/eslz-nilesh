targetScope = 'subscription'

param subscriptionId string

@description('Required. Name for the Resoruce Group.')
param rgName string = 'rg-${projowner}-${opscope}-${region}-vnet'

@description('Required. Location for all resources.')
param location string

/*
@description('Required. Suffix to be used in resource naming with 4 characters.')
param suffix string = substring(uniqueString(utcNow()),0,4)
*/

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

// Create Resoruce Group
module rg '../rg/resourceGroups/deploy.bicep'= {
  name: 'rg-${uniqueString(deployment().name, location)}'
  scope: subscription(subscriptionId)
  params: {
    name: rgName
    location: location
    tags: combinedTags
  }
}
