targetScope = 'subscription'
param subscriptionId string

@description('Required. The Virtual Network (vNet) Name.')
param name string

@description('Required. An Array of 1 or more IP Address Prefixes for the Virtual Network.')
param addressPrefixes array

@description('Optional. An Array of subnets to deploy to the Virtual Network.')
param subnets array = []

@description('Optional. Virtual Network Peerings configurations')
param virtualNetworkPeerings array = []

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

@description('Required. Location for all resources.')
param location string

param resourceGroupName string = 'rg-${projowner}-${opscope}-${region}-vnet'

// Create Resoruce Group
module rg './resourceGroups/deploy.bicep'= {
  name: 'rg-${uniqueString(deployment().name, location)}'
  scope: subscription(subscriptionId)
  params: {
    name: resourceGroupName
    location: location
    tags: combinedTags
  }
}

// Create Virtual Network
module vnet './virtualNetworks/deploy.bicep' = {
  name: 'vnet-${uniqueString(deployment().name, location)}-${name}'
  scope: resourceGroup(subscriptionId, resourceGroupName)
  dependsOn: [
    rg
  ]
  params:{
    location: location
    addressPrefixes: addressPrefixes
    name: name
    subnets: subnets
    virtualNetworkPeerings: virtualNetworkPeerings
    subscriptionId: subscriptionId
    //dnsServers: vNet.dnsServers
    //ddosProtectionPlanId: vNet.ddosProtectionPlanId
    
  }
}
