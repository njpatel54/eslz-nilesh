targetScope = 'subscription'

param subscriptionId string

@description('Required. Name for the Event Hub Namespace.')
param name string

@description('Required. Name for the Resoruce Group.')
param rgName string = 'rg-${projowner}-${opscope}-${region}-vnet'

@description('Required. An Array of 1 or more IP Address Prefixes for the Virtual Network.')
param addressPrefixes array

@description('Optional. An Array of subnets to deploy to the Virtual Network.')
param subnets array = []

@description('Optional. DNS Servers associated to the Virtual Network.')
param dnsServers array = []

@description('Optional. Resource ID of the DDoS protection plan to assign the VNET to. If it\'s left blank, DDoS protection will not be configured. If it\'s provided, the VNET created by this template will be attached to the referenced DDoS protection plan. The DDoS protection plan can exist in the same or in a different subscription.')
param ddosProtectionPlanId string = ''

//@description('Optional. Virtual Network Peerings configurations')
//param virtualNetworkPeerings array = []

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

// Create Resoruce Group
module rg './resourceGroups/deploy.bicep'= {
  name: 'rg-${uniqueString(deployment().name, location)}'
  scope: subscription(subscriptionId)
  params: {
    name: rgName
    location: location
    tags: combinedTags
  }
}

// Create Virtual Network
module vnet './virtualNetworks/deploy.bicep' = {
  name: 'vnet-${uniqueString(deployment().name, location)}-${name}'
  scope: resourceGroup(subscriptionId, rgName)
  dependsOn: [
    rg
  ]
  params:{
    location: location
    addressPrefixes: addressPrefixes
    name: name
    subnets: subnets
    dnsServers: dnsServers
    ddosProtectionPlanId: ddosProtectionPlanId
    //subscriptionId:subscriptionId
    //virtualNetworkPeerings: virtualNetworkPeerings

  }
}

