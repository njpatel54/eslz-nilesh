targetScope = 'subscription'
//param subscriptionId string

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

@description('Optional. Hub Virtual Network configurations.')
param spokeVnets array = []

@description('Required. Location for all resources.')
param location string

param resourceGroupName string = 'rg-${projowner}-${opscope}-${region}-vnet'

// Create Resoruce Group
module rg './resourceGroups/deploy.bicep'= [ for (vNet, index) in spokeVnets : {
  name: 'rg-${uniqueString(deployment().name, location)}'
  scope: subscription(vNet.subscriptionId)
  params: {
    name: resourceGroupName
    location: location
    tags: combinedTags
  }
}]

// Create Virtual Network
module vnet './virtualNetworks/deploy.bicep' = [ for (vNet, index) in spokeVnets : {
  name: 'vnet-${uniqueString(deployment().name, location)}-${vNet.name}'
  scope: resourceGroup(vNet.subscriptionId, resourceGroupName)
  dependsOn: [
    rg
  ]
  params:{
    location: location
    addressPrefixes: vNet.addressPrefixes
    name: vNet.name
    subnets: vNet.subnets
    virtualNetworkPeerings: vNet.virtualNetworkPeerings
    subscriptionId: vNet.subscriptionId
    //dnsServers: vNet.dnsServers
    //ddosProtectionPlanId: vNet.ddosProtectionPlanId
    
  }
}]
