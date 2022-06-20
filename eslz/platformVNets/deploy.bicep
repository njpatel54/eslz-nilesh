targetScope = 'subscription'

@description('Required. Subscription ID.')
param subscriptionId string

@description('Required. The Virtual Network (vNet) Name.')
param name string

@description('Required. An Array of 1 or more IP Address Prefixes for the Virtual Network.')
param addressPrefixes array

@description('Optional. An Array of subnets to deploy to the Virtual Network.')
param subnets array = []

@description('Optional. Hub Virtual Network configurations.')
param spokeVnets array = []

@description('Optional. Virtual Network Peerings configurations')
param virtualNetworkPeerings array = []

@description('Optional. Resource ID of the diagnostic storage account.')
param diagnosticStorageAccountId string = ''

@description('Optional. Resource ID of the diagnostic log analytics workspace.')
param diagnosticWorkspaceId string = ''

@description('Optional. Resource ID of the diagnostic event hub authorization rule for the Event Hubs namespace in which the event hub should be created or streamed to.')
param diagnosticEventHubAuthorizationRuleId string = ''

@description('Optional. Name of the diagnostic event hub within the namespace to which logs are streamed. Without this, an event hub is created for each log category.')
param diagnosticEventHubName string = ''

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

// Create Hub Resoruce Group
module hubRg '../modules/resourceGroups/deploy.bicep'= {
  name: 'rg-${uniqueString(deployment().name, location)}'
  scope: subscription(subscriptionId)
  params: {
    name: resourceGroupName
    location: location
    tags: combinedTags
  }
}

// Create Hub Virtual Network
module hubVnet '../modules/network/virtualNetworks/deploy.bicep' = {
  name: 'vnet-${uniqueString(deployment().name, location)}-${name}'
  scope: resourceGroup(subscriptionId, resourceGroupName)
  dependsOn: [
    hubRg
  ]
  params:{
    location: location
    addressPrefixes: addressPrefixes
    name: name
    subnets: subnets
    virtualNetworkPeerings: virtualNetworkPeerings
    subscriptionId: subscriptionId
    diagnosticStorageAccountId: diagnosticStorageAccountId
    diagnosticWorkspaceId: diagnosticWorkspaceId
    diagnosticEventHubAuthorizationRuleId: diagnosticEventHubAuthorizationRuleId
    diagnosticEventHubName: diagnosticEventHubName
  }
}

// Create Spoke Resoruce Group(s)
module spokeRg '../modules/resourceGroups/deploy.bicep'= [ for (vNet, index) in spokeVnets : {
  name: 'rg-${uniqueString(deployment().name, location)}'
  scope: subscription(vNet.subscriptionId)
  params: {
    name: resourceGroupName
    location: location
    tags: combinedTags
  }
}]

// Create Spoke Virtual Network(s)
module spokeVnet '../modules/network/virtualNetworks/deploy.bicep' = [ for (vNet, index) in spokeVnets : {
  name: 'vnet-${uniqueString(deployment().name, location)}-${vNet.name}'
  scope: resourceGroup(vNet.subscriptionId, resourceGroupName)
  dependsOn: [
    spokeRg
    hubVnet
  ]
  params:{
    location: location
    addressPrefixes: vNet.addressPrefixes
    name: vNet.name
    subnets: vNet.subnets
    virtualNetworkPeerings: vNet.virtualNetworkPeerings
    subscriptionId: vNet.subscriptionId
    diagnosticStorageAccountId: diagnosticStorageAccountId
    diagnosticWorkspaceId: diagnosticWorkspaceId
    diagnosticEventHubAuthorizationRuleId: diagnosticEventHubAuthorizationRuleId
    diagnosticEventHubName: diagnosticEventHubName    
  }
}]
