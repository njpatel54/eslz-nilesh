targetScope = 'subscription'

@description('Required. Hub - Network Security Groups Array.')
param hubNetworkSecurityGroups array

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

@description('Required. Assign utffullvaule to "CreatedOn" tag.')
param dynamictags object = ({
  CreatedOn: utcfullvalue
})

var tags = json(loadTextContent('../tags.json'))

@description('Required. Combine Tags in dynamoctags object with Tags from parameter file.')
var ccsCombinedTags = union(dynamictags, tags.ccsTags.value)
//var lzCombinedTags = union(dynamictags, tags.lz01Tags.value)

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
param publicIPSkuName string

@description('Required. Firewall Public IP allocation method.')
param publicIPAllocationMethod string

@description('Required. Firewall Public IP zones.')
param publicIPzones array

@description('Required. Firewall Policy name.')
param firewallPolicyName string = 'afwp-${projowner}-${opscope}-${region}-0001'

@description('Required. Firewall Policy Tier.')
param firewallPolicyTier string

@description('Optional. Rule collection groups.')
param firewallPolicyRuleCollectionGroups array = []

@description('Required. Firewall name.')
param firewallName string = 'afw-${projowner}-${opscope}-${region}-0001'

@description('Required. Firewall SKU Tier.')
param firewallSkuTier string

@description('Optional. Zone numbers e.g. 1,2,3.')
param firewallZones array

@description('Optional. Array of role assignment objects that contain the \'roleDefinitionIdOrName\' and \'principalId\' to define RBAC role assignments on this resource. In the roleDefinitionIdOrName attribute, you can provide either the display name of the role definition, or its fully qualified ID in the following format: \'/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11\'')
param firewallRoleAssignments array = []

@description('Required. Bastion Host Public IP name.')
param bastionHostPublicIPName string = 'pip-${projowner}-${opscope}-${region}-bhip'

@description('Required. Bastion Host name.')
param bastionHostName string = 'bas-${projowner}-${opscope}-${region}-0001'

@description('Required. Bastion Host sku type.')
param bastionHostSkuType string

@description('Required. Bastion Host scale units.')
param bastionHostScaleUnits int

@description('Optional. Array of role assignment objects that contain the \'roleDefinitionIdOrName\' and \'principalId\' to define RBAC role assignments on this resource. In the roleDefinitionIdOrName attribute, you can provide either the display name of the role definition, or its fully qualified ID in the following format: \'/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11\'')
param bastionHostRoleAssignments array = []

// 1 - Create Hub Resoruce Group
module hubRg '../modules/resourceGroups/deploy.bicep'= {
  name: 'rg-${hubVnetSubscriptionId}-${resourceGroupName}'
  scope: subscription(hubVnetSubscriptionId)
  params: {
    name: resourceGroupName
    location: location
    tags: ccsCombinedTags
  }
}

// 2 - Create Hub Network Security Group(s)
module hubNsgs '../modules/network/networkSecurityGroups/deploy.bicep' = [ for (nsg, index) in hubNetworkSecurityGroups : {
  name: 'hubNsg-${take(uniqueString(deployment().name, location), 4)}-${nsg.name}'
  scope: resourceGroup(hubVnetSubscriptionId, resourceGroupName)
  dependsOn: [
    hubRg
  ]
  params:{
    name: nsg.name
    location: location
    tags: ccsCombinedTags
    securityRules: nsg.securityRules
    roleAssignments: nsg.roleAssignments
    diagnosticStorageAccountId: diagnosticStorageAccountId
    diagnosticWorkspaceId: diagnosticWorkspaceId
    //diagnosticEventHubAuthorizationRuleId: diagnosticEventHubAuthorizationRuleId
    //diagnosticEventHubName: diagnosticEventHubName
  }
}]

// 3 - Create Hub Virtual Network
module hubVnet '../modules/network/virtualNetworks/deploy.bicep' = {
  name: 'vnet-${take(uniqueString(deployment().name, location), 4)}-${hubVnetName}'
  scope: resourceGroup(hubVnetSubscriptionId, resourceGroupName)
  dependsOn: [
    hubNsgs
  ]
  params:{
    name: hubVnetName
    location: location
    tags: ccsCombinedTags
    addressPrefixes: hubVnetAddressPrefixes
    subnets: hubVnetSubnets
    virtualNetworkPeerings: hubVnetVirtualNetworkPeerings
    subscriptionId: hubVnetSubscriptionId
    diagnosticStorageAccountId: diagnosticStorageAccountId
    diagnosticWorkspaceId: diagnosticWorkspaceId
    //diagnosticEventHubAuthorizationRuleId: diagnosticEventHubAuthorizationRuleId
    //diagnosticEventHubName: diagnosticEventHubName
  }
}

// 4 - Create Spoke Resoruce Group(s)
module spokeRg '../modules/resourceGroups/deploy.bicep'= [ for (vNet, index) in spokeVnets : {
  name: 'rg-${vNet.subscriptionId}-${resourceGroupName}'
  scope: subscription(vNet.subscriptionId)
  params: {
    name: resourceGroupName
    location: location
    tags: ccsCombinedTags
  }
}]

// 5 - Create Spoke Virtual Network(s)
module spokeVnet '../modules/network/virtualNetworks/deploy.bicep' = [ for (vNet, index) in spokeVnets : {
  name: 'vnet-${take(uniqueString(deployment().name, location), 4)}-${vNet.name}'
  scope: resourceGroup(vNet.subscriptionId, resourceGroupName)
  dependsOn: [
    spokeRg
    hubVnet
  ]
  params:{
    name: vNet.name
    location: location
    tags: ccsCombinedTags    
    addressPrefixes: vNet.addressPrefixes
    subnets: vNet.subnets
    virtualNetworkPeerings: vNet.virtualNetworkPeerings
    subscriptionId: vNet.subscriptionId
    diagnosticStorageAccountId: diagnosticStorageAccountId
    diagnosticWorkspaceId: diagnosticWorkspaceId
    //diagnosticEventHubAuthorizationRuleId: diagnosticEventHubAuthorizationRuleId
    //diagnosticEventHubName: diagnosticEventHubName    
  }
}]

// 6 - Create Public IP Address for Azure Firewall
module afwPip '../modules/network/publicIPAddresses/deploy.bicep' = {
  name: 'fwpip-${take(uniqueString(deployment().name, location), 4)}-${firewallPublicIPName}'
  scope: resourceGroup(hubVnetSubscriptionId, resourceGroupName)
  dependsOn: [
    hubRg
  ]
  params:{
    name: firewallPublicIPName
    location: location
    tags: ccsCombinedTags 
    publicIPAllocationMethod: publicIPAllocationMethod
    skuName: publicIPSkuName
    zones: publicIPzones
    diagnosticStorageAccountId: diagnosticStorageAccountId
    diagnosticWorkspaceId: diagnosticWorkspaceId
    //diagnosticEventHubAuthorizationRuleId: diagnosticEventHubAuthorizationRuleId
    //diagnosticEventHubName: diagnosticEventHubName    
  }
}

// 7 - Create Fireall Policy and Firewall Policy Rule Collection Groups
module afwp '../modules/network/firewallPolicies/deploy.bicep' = {
  name: 'afwp-${take(uniqueString(deployment().name, location), 4)}-${firewallPolicyName}'
  scope: resourceGroup(hubVnetSubscriptionId, resourceGroupName)
  dependsOn: [
    hubRg
  ]
  params:{
    name: firewallPolicyName
    location: location
    tags: ccsCombinedTags
    defaultWorkspaceId: diagnosticWorkspaceId
    insightsIsEnabled: true
    tier: firewallPolicyTier
    ruleCollectionGroups: firewallPolicyRuleCollectionGroups

  }
}

// 8 - Create Firewall
module afw '../modules/network/azureFirewalls/deploy.bicep' = {
  name: 'afw-${take(uniqueString(deployment().name, location), 4)}-${firewallName}'
  scope: resourceGroup(hubVnetSubscriptionId, resourceGroupName)
  dependsOn: [
    hubVnet
    spokeVnet
    afwPip
    afwp
  ]
  params:{
    name: firewallName
    location: location
    tags: ccsCombinedTags
    azureSkuTier: firewallSkuTier
    zones: firewallZones
    ipConfigurations: [
      {
        name: 'ipConfig01'
        publicIPAddressResourceId: afwPip.outputs.resourceId
        subnetResourceId: resourceId(hubVnetSubscriptionId, resourceGroupName, 'Microsoft.Network/virtualNetworks/subnets', hubVnetName, 'AzureFirewallSubnet')
      }
    ]
    firewallPolicyId: afwp.outputs.resourceId
    roleAssignments: firewallRoleAssignments
    diagnosticStorageAccountId: diagnosticStorageAccountId
    diagnosticWorkspaceId: diagnosticWorkspaceId
    //diagnosticEventHubAuthorizationRuleId: diagnosticEventHubAuthorizationRuleId
    //diagnosticEventHubName: diagnosticEventHubName
  }
}

// 9 - Create Public IP Address for Azure Bastion Host
module bhPip '../modules/network/publicIPAddresses/deploy.bicep' = {
  name: 'fwpip-${take(uniqueString(deployment().name, location), 4)}-${bastionHostPublicIPName}'
  scope: resourceGroup(hubVnetSubscriptionId, resourceGroupName)
  dependsOn: [
    hubRg
  ]
  params:{
    name: bastionHostPublicIPName
    location: location
    tags: ccsCombinedTags 
    publicIPAllocationMethod: publicIPAllocationMethod
    skuName: publicIPSkuName
    zones: publicIPzones
    diagnosticStorageAccountId: diagnosticStorageAccountId
    diagnosticWorkspaceId: diagnosticWorkspaceId
    //diagnosticEventHubAuthorizationRuleId: diagnosticEventHubAuthorizationRuleId
    //diagnosticEventHubName: diagnosticEventHubName    
  }
}

// 10 - Create Azure Bastion Host
module bas '../modules/network/bastionHosts/deploy.bicep' = {
  name: 'bas-${take(uniqueString(deployment().name, location), 4)}-${bastionHostName}'
  scope: resourceGroup(hubVnetSubscriptionId, resourceGroupName)
  dependsOn: [
    hubVnet
    spokeVnet
    bhPip
  ]
  params:{
    name: bastionHostName
    location: location
    tags: ccsCombinedTags 
    vNetId: hubVnet.outputs.resourceId
    azureBastionSubnetPublicIpId: bhPip.outputs.resourceId
    skuType: bastionHostSkuType
    scaleUnits: bastionHostScaleUnits
    roleAssignments: bastionHostRoleAssignments
    diagnosticStorageAccountId: diagnosticStorageAccountId
    diagnosticWorkspaceId: diagnosticWorkspaceId
    //diagnosticEventHubAuthorizationRuleId: diagnosticEventHubAuthorizationRuleId
    //diagnosticEventHubName: diagnosticEventHubName
  }
}



// Start - Outputs to supress warnings - "unused parameters"
output diagnosticEventHubAuthorizationRuleId string = diagnosticEventHubAuthorizationRuleId
output diagnosticEventHubName string = diagnosticEventHubName
// End - Outputs to supress warnings - "unused parameters"
