targetScope = 'subscription'

@description('Required. Subscription ID.')
param hubVnetSubscriptionId string

@description('Required. The Virtual Network (vNet) Name.')
param hubVnetName string

@description('Required. An Array of 1 or more IP Address Prefixes for the Virtual Network.')
param hubVnetAddressPrefixes array

@description('Optional. An Array of subnets to deploy to the Virtual Network.')
param hubVnetSubnets array = []

@description('Optional. Hub Virtual Network configurations.')
param spokeVnets array = []

@description('Optional. Virtual Network Peerings configurations')
param hubVnetVirtualNetworkPeerings array = []

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

@description('Required. Resource Group name.')
param resourceGroupName string = 'rg-${projowner}-${opscope}-${region}-vnet'

@description('Required. Firewall Public IP name.')
param firewallPublicIPName string = 'pip-${projowner}-${opscope}-${region}-fwip'

@description('Required. Firewall Public IP SKU name.')
param firewallPpublicIPSkuName string

@description('Required. Firewall Public IP allocation method.')
param firewallPublicIPAllocationMethod string

@description('Required. Firewall Public IP zones.')
param firewallPublicIPzones array

@description('Required. Firewall Policy name.')
param firewallPolicyName string = 'afwp-${projowner}-${opscope}-${region}-0001'

@description('Optional. Rule collection groups.')
param firewallPolicyRuleCollectionGroups array = []

@description('Required. Firewall name.')
param firewallName string = 'afw-${projowner}-${opscope}-${region}-0001'

@description('Optional. Collection of application rule collections used by Azure Firewall.')
param firewallApplicationRuleCollections array = []

@description('Optional. Collection of network rule collections used by Azure Firewall.')
param firewallNetworkRuleCollections array = []

@description('Required. List of IP Configurations.')
param firewallIpConfigurations array

@description('Optional. Zone numbers e.g. 1,2,3.')
param firewallZones array

@description('Optional. Array of role assignment objects that contain the \'roleDefinitionIdOrName\' and \'principalId\' to define RBAC role assignments on this resource. In the roleDefinitionIdOrName attribute, you can provide either the display name of the role definition, or its fully qualified ID in the following format: \'/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11\'')
param firewallRoleAssignments array = []

// Create Hub Resoruce Group
module hubRg '../modules/resourceGroups/deploy.bicep'= {
  name: 'rg-${uniqueString(deployment().name, location)}'
  scope: subscription(hubVnetSubscriptionId)
  params: {
    name: resourceGroupName
    location: location
    tags: combinedTags
  }
}

// Create Hub Virtual Network
module hubVnet '../modules/network/virtualNetworks/deploy.bicep' = {
  name: 'vnet-${uniqueString(deployment().name, location)}-${hubVnetName}'
  scope: resourceGroup(hubVnetSubscriptionId, resourceGroupName)
  dependsOn: [
    hubRg
  ]
  params:{
    location: location
    addressPrefixes: hubVnetAddressPrefixes
    name: hubVnetName
    subnets: hubVnetSubnets
    virtualNetworkPeerings: hubVnetVirtualNetworkPeerings
    subscriptionId: hubVnetSubscriptionId
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

// Create Public IP Address for Azure Firewall
module afwPip '../modules/network/publicIPAddresses/deploy.bicep' = {
  name: 'fwpip-${firewallPublicIPName}'
  scope: resourceGroup(hubVnetSubscriptionId, resourceGroupName)
  dependsOn: [
    hubRg
  ]
  params:{
    location: location
    name: firewallPublicIPName
    publicIPAllocationMethod: firewallPublicIPAllocationMethod
    skuName: firewallPpublicIPSkuName
    zones: firewallPublicIPzones
    diagnosticStorageAccountId: diagnosticStorageAccountId
    diagnosticWorkspaceId: diagnosticWorkspaceId
    diagnosticEventHubAuthorizationRuleId: diagnosticEventHubAuthorizationRuleId
    diagnosticEventHubName: diagnosticEventHubName    
  }
}

// Create Fireall Policy
module afwrcg '../modules/network/firewallPolicies/deploy.bicep' = {
  name: 'afwrcg-${firewallPolicyName}'
  scope: resourceGroup(hubVnetSubscriptionId, resourceGroupName)
  dependsOn: [
    hubRg
  ]
  params:{
    location: location
    name: firewallPolicyName
    defaultWorkspaceId: diagnosticWorkspaceId
    insightsIsEnabled: true
    ruleCollectionGroups: firewallPolicyRuleCollectionGroups    
  }
}

// Create Fireall
module afw '../modules/network/azureFirewalls/deploy.bicep' = {
  name: 'afw-${firewallName}'
  scope: resourceGroup(hubVnetSubscriptionId, resourceGroupName)
  dependsOn: [
    hubRg
  ]
  params:{
    location: location
    name: firewallName
    zones: firewallZones
    ipConfigurations: [
      {
        name: 'ipConfig01'
        publicIPAddressResourceId: afwPip.outputs.resourceId
        subnetResourceId: resourceId(hubVnetSubscriptionId, resourceGroupName, 'Microsoft.Network/virtualNetworks/subnets', 'AzureFirewallSubnet')
      }
    ]
    applicationRuleCollections: firewallApplicationRuleCollections
    networkRuleCollections: firewallNetworkRuleCollections
    roleAssignments: firewallRoleAssignments
  }
}

