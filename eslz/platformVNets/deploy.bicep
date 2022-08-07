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

@description('Required. Array of Custom RBAC Role Definitions.')
param vNetRgCustomRbacRoles array = []

@description('Required. Array of Custom RBAC Role Definitions.')
param priDNSZonesRgCustomRbacRoles array = []

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
param vnetRgName string = 'rg-${projowner}-${opscope}-${region}-vnet'

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

@description('Required. Resource Group name for Private DNS Zones.')
param priDNSZonesRgName string = 'rg-${projowner}-${opscope}-${region}-dnsz'

@description('Required. Array of Private DNS Zones (Azure US Govrenment).')
param privateDnsZones array

@description('Required. Load content from json file to iterate over virtual networks in "hubVnet" and "spokeVnets"')
var vNets = json(loadTextContent('.parameters/parameters.json'))

// Variables created to be used to configure 'virtualNetworkLinks' for Private DNS Zone(s)
@description('Required. Iterate over each "spokeVnets" and build "resourceId" of each Virtual Networks using "subscriptionId", "vnetRgName" and "vNet.name".')
var spokeVNetsResourceIds = [for vNet in vNets.parameters.spokeVnets.value: resourceId(vNet.subscriptionId, vnetRgName, 'Microsoft.Network/virtualNetworks', vNet.name)]

@description('Required. Build "resourceId" of Hub Virtual Network using "hubVnetSubscriptionId", "vnetRgName" and "hubVnetName".')
var hubVNetResourceId = [ resourceId(vNets.parameters.hubVnetSubscriptionId.value, vnetRgName, 'Microsoft.Network/virtualNetworks', vNets.parameters.hubVnetName.value) ]

@description('Required. Combine two varibales using "union" function - This will be input for "virtualNetworkLinks" configuration for each Private DNS Zones.')
var vNetResourceIds = union(hubVNetResourceId, spokeVNetsResourceIds)

@description('Required. Subscription ID of Management Subscription.')
param mgmtsubid string

@description('Required. Virtual Network name in Management Subscription.')
param mgmtVnetName string = 'vnet-${projowner}-${opscope}-${region}-mgmt'

@description('Required. Subnet name to be used for Private Endpoint.')
param peSubnetName string = 'snet-${projowner}-${opscope}-${region}-mgmt'

@description('Required. SIEM Resource Group Name.')
param siemRgName string = 'rg-${projowner}-${opscope}-${region}-siem'

@description('Required. Log Ananlytics Workspace Name for Azure Sentinel.')
param sentinelLawName string = 'log-${projowner}-${opscope}-${region}-siem'

@description('Required. Log Ananlytics Workspace Name for resource Diagnostics Settings - Log Collection.')
param logsLawName string = 'log-${projowner}-${opscope}-${region}-logs'

@description('Required. Automation Account Name.')
param automationAcctName string = 'aa-${projowner}-${opscope}-${region}-logs'

@description('Required. Storage Account Name for resource Diagnostics Settings - Log Collection.')
param stgAcctName string = toLower(take('st${projowner}${opscope}${region}logs', 24))

@description('Required. Automation Account subresource IDs (groupId).')
var aaGroupIds = [
  'Webhook'
  'DSCAndHybridWorker'
]

@description('Required. Azure Monitor Private Link Scope Name.')
param amplsName string = 'ampls-${projowner}-${opscope}-${region}-hub'

@description('Optional. Specifies the default access mode of ingestion through associated private endpoints in scope. If not specified default value is "Open".')
@allowed([
  'Open'
  'PrivateOnly'
])
param ingestionAccessMode string = 'PrivateOnly'

@description('Optional. Specifies the default access mode of queries through associated private endpoints in scope. If not specified default value is "Open".')
@allowed([
  'Open'
  'PrivateOnly'
])
param queryAccessMode string = 'PrivateOnly'

// 1 - Create Hub Resoruce Group
module hubRg '../modules/resourceGroups/deploy.bicep' = {
  name: 'rg-${take(uniqueString(deployment().name, location), 4)}-${vnetRgName}'
  scope: subscription(hubVnetSubscriptionId)
  params: {
    name: vnetRgName
    location: location
    tags: ccsCombinedTags
  }
}

// 2 - Create Hub Network Security Group(s)
module hubNsgs '../modules/network/networkSecurityGroups/deploy.bicep' = [for (nsg, index) in hubNetworkSecurityGroups: {
  name: 'hubNsg-${take(uniqueString(deployment().name, location), 4)}-${nsg.name}'
  scope: resourceGroup(hubVnetSubscriptionId, vnetRgName)
  dependsOn: [
    hubRg
  ]
  params: {
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
  scope: resourceGroup(hubVnetSubscriptionId, vnetRgName)
  dependsOn: [
    hubNsgs
  ]
  params: {
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
module spokeRg '../modules/resourceGroups/deploy.bicep' = [for (vNet, index) in spokeVnets: {
  name: 'rg-${take(uniqueString(deployment().name, location), 4)}-${vnetRgName}'
  scope: subscription(vNet.subscriptionId)
  params: {
    name: vnetRgName
    location: location
    tags: ccsCombinedTags
  }
}]

// 5 - Create Spoke Virtual Network(s)
module spokeVnet '../modules/network/virtualNetworks/deploy.bicep' = [for (vNet, index) in spokeVnets: {
  name: 'vnet-${take(uniqueString(deployment().name, location), 4)}-${vNet.name}'
  scope: resourceGroup(vNet.subscriptionId, vnetRgName)
  dependsOn: [
    spokeRg
    hubVnet
  ]
  params: {
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
  scope: resourceGroup(hubVnetSubscriptionId, vnetRgName)
  dependsOn: [
    hubRg
  ]
  params: {
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
  scope: resourceGroup(hubVnetSubscriptionId, vnetRgName)
  dependsOn: [
    hubRg
  ]
  params: {
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
  scope: resourceGroup(hubVnetSubscriptionId, vnetRgName)
  dependsOn: [
    hubVnet
    spokeVnet
    afwPip
    afwp
  ]
  params: {
    name: firewallName
    location: location
    tags: ccsCombinedTags
    azureSkuTier: firewallSkuTier
    zones: firewallZones
    ipConfigurations: [
      {
        name: 'ipConfig01'
        publicIPAddressResourceId: afwPip.outputs.resourceId
        subnetResourceId: resourceId(hubVnetSubscriptionId, vnetRgName, 'Microsoft.Network/virtualNetworks/subnets', hubVnetName, 'AzureFirewallSubnet')
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
  scope: resourceGroup(hubVnetSubscriptionId, vnetRgName)
  dependsOn: [
    hubRg
  ]
  params: {
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
  scope: resourceGroup(hubVnetSubscriptionId, vnetRgName)
  dependsOn: [
    hubVnet
    spokeVnet
    bhPip
  ]
  params: {
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

// 11 - Create Resource Group for Private DNS Zones
module priDNSZonesRg '../modules/resourceGroups/deploy.bicep' = {
  name: 'priDNSZonesRg-${take(uniqueString(deployment().name, location), 4)}-${priDNSZonesRgName}'
  scope: subscription(vNets.parameters.hubVnetSubscriptionId.value)
  params: {
    name: priDNSZonesRgName
    location: location
    tags: ccsCombinedTags
  }
}

// 12 - Create Private DNS Zones
module priDNSZones '../modules/network/privateDnsZones/deploy.bicep' = [for privateDnsZone in privateDnsZones: {
  name: 'priDNSZones-${privateDnsZone}'
  scope: resourceGroup(vNets.parameters.hubVnetSubscriptionId.value, priDNSZonesRgName)
  dependsOn: [
    priDNSZonesRg
    hubVnet
    spokeVnet
  ]
  params: {
    name: privateDnsZone
    location: 'Global'
    tags: ccsCombinedTags
    virtualNetworkLinks: [for vNetResourceId in vNetResourceIds: {
      virtualNetworkResourceId: vNetResourceId
      registrationEnabled: false
    }]
  }
}]

// 13. Retrieve an existing Storage Account resource
resource sa 'Microsoft.Storage/storageAccounts@2021-09-01' existing = {
  name: stgAcctName
  scope: resourceGroup(mgmtsubid, siemRgName)
}

// 14. Create Private Endpoint for Storage Account
module saPe '../modules/network/privateEndpoints/deploy.bicep' = {
  name: 'saPe-${take(uniqueString(deployment().name, location), 4)}-${stgAcctName}'
  scope: resourceGroup(mgmtsubid, siemRgName)
  dependsOn: [
    hubVnet
    spokeVnet
    priDNSZones
  ]
  params: {
    name: '${stgAcctName}-blob-pe'
    location: location
    tags: ccsCombinedTags
    serviceResourceId: sa.id
    groupIds: [
      'blob'
    ]
    subnetResourceId: resourceId(mgmtsubid, vnetRgName, 'Microsoft.Network/virtualNetworks/subnets', mgmtVnetName, peSubnetName)
    privateDnsZoneGroup: {
      privateDNSResourceIds: [
        resourceId(hubVnetSubscriptionId, priDNSZonesRgName, 'Microsoft.Network/privateDnsZones', 'privatelink.blob.core.usgovcloudapi.net')
      ]
    }
  }
}

// 15. Retrieve an existing Automation Account resource
resource aa 'Microsoft.Automation/automationAccounts@2021-06-22' existing = {
  name: automationAcctName
  scope: resourceGroup(mgmtsubid, siemRgName)
}

// 16. Create Private Endpoint for Automation Account
module aaPe '../modules/network/privateEndpoints/deploy.bicep' = [ for aaGroupId in aaGroupIds: {
  name: 'aaPe-${take(uniqueString(deployment().name, location), 4)}-${automationAcctName}-${aaGroupId}'
  scope: resourceGroup(mgmtsubid, siemRgName)
  dependsOn: [
    hubVnet
    spokeVnet
    priDNSZones
  ]
  params: {
    name: '${automationAcctName}-${aaGroupId}-pe'
    location: location
    tags: ccsCombinedTags
    serviceResourceId: aa.id
    groupIds: [
      aaGroupId
    ]
    subnetResourceId: resourceId(mgmtsubid, vnetRgName, 'Microsoft.Network/virtualNetworks/subnets', mgmtVnetName, peSubnetName)
    privateDnsZoneGroup: {
      privateDNSResourceIds: [
        resourceId(hubVnetSubscriptionId, priDNSZonesRgName, 'Microsoft.Network/privateDnsZones', 'privatelink.azure-automation.us')
      ]
    }
  }
}]

// 17. Create Azure Monitor Private Link Scope
// An Azure Monitor Private Link connects a private endpoint to a set of Azure Monitor resources (Log Analytics Workspace, App Insights, Data Collection Endpoints) through an Azure Monitor Private Link Scope (AMPLS).
module ampls '../modules/insights/privateLinkScopes/deploy.bicep' = {
  name: 'ampls-${take(uniqueString(deployment().name, location), 4)}-${amplsName}'
  scope: resourceGroup(hubVnetSubscriptionId,  vnetRgName)
  dependsOn: [
    hubVnet
    spokeVnet
    priDNSZones
  ]
  params: {
    name: amplsName
    location: 'Global'
    tags: ccsCombinedTags
    exclusions: []
    ingestionAccessMode: ingestionAccessMode
    queryAccessMode: queryAccessMode
    scopedResources: [           
      {
        name: logsLawName
        privateLinkScopeName: amplsName
        linkedResourceId: resourceId(mgmtsubid, siemRgName, 'Microsoft.OperationalInsights/workspaces', logsLawName)
      }
      {
        name: sentinelLawName
        privateLinkScopeName: amplsName
        linkedResourceId: resourceId(mgmtsubid, siemRgName, 'Microsoft.OperationalInsights/workspaces', sentinelLawName)
      }
    ]
  }
}

// 18. Create Private Endpoint for Azure Monitor Private Link Scope
module amplsPe '../modules/network/privateEndpoints/deploy.bicep' = {
  name: 'amplsPe-${take(uniqueString(deployment().name, location), 4)}-${amplsName}'
  scope: resourceGroup(hubVnetSubscriptionId, vnetRgName)
  dependsOn: [
    hubVnet
    spokeVnet
    priDNSZones
  ]
  params: {
    name: '${amplsName}-pe'
    location: location
    tags: ccsCombinedTags
    serviceResourceId: ampls.outputs.resourceId
    groupIds: [
      'azuremonitor'
    ]
    subnetResourceId: resourceId(hubVnetSubscriptionId, vnetRgName, 'Microsoft.Network/virtualNetworks/subnets', hubVnetName, peSubnetName)
    privateDnsZoneGroup: {
      privateDNSResourceIds: [
        resourceId(hubVnetSubscriptionId, priDNSZonesRgName, 'Microsoft.Network/privateDnsZones', 'privatelink.monitor.azure.us')
        resourceId(hubVnetSubscriptionId, priDNSZonesRgName, 'Microsoft.Network/privateDnsZones', 'privatelink.oms.opinsights.azure.us')
        resourceId(hubVnetSubscriptionId, priDNSZonesRgName, 'Microsoft.Network/privateDnsZones', 'privatelink.ods.opinsights.azure.us')
        resourceId(hubVnetSubscriptionId, priDNSZonesRgName, 'Microsoft.Network/privateDnsZones', 'privatelink.agentsvc.azure-automation.us')
        resourceId(hubVnetSubscriptionId, priDNSZonesRgName, 'Microsoft.Network/privateDnsZones', 'privatelink.blob.core.usgovcloudapi.net')
      ]
    }
  }
}


// Start - Outputs to supress warnings - "unused parameters"
output diagnosticEventHubAuthorizationRuleId string = diagnosticEventHubAuthorizationRuleId
output diagnosticEventHubName string = diagnosticEventHubName
output vNetRgCustomRbacRoles array = vNetRgCustomRbacRoles
output priDNSZonesRgCustomRbacRoles array = priDNSZonesRgCustomRbacRoles
// End - Outputs to supress warnings - "unused parameters"


