targetScope = 'subscription'

@description('Required. Hub - Network Security Groups Array.')
param hubNetworkSecurityGroups array

@description('Required. Subscription ID.')
param hubVnetSubscriptionId string

@description('Required. Default Route Table name.')
param defaultRouteTableName string = 'rt-${projowner}-${opscope}-${region}-0001'

@description('Optional. An Array of Routes to be established within the hub route table.')
param routes array = []

@description('Required. The Virtual Network (vNet) Name.')
param hubVnetName string

@description('Required. An Array of 1 or more IP Address Prefixes for the Virtual Network.')
param hubVnetAddressPrefixes array

@description('Optional. An Array of subnets to deploy to the Virtual Network.')
param hubVnetSubnets array = []

@description('Required. Spoke - Network Security Groups Array.')
param spokeNetworkSecurityGroups array

@description('Optional. Hub Virtual Network configurations.')
param spokeVnets array = []

@description('Optional. Virtual Network Peerings configurations')
param hubVnetVirtualNetworkPeerings array = []

@description('Required. Name for the Diagnostics Setting Configuration.')
param diagSettingName string

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
var params = json(loadTextContent('.parameters/parameters.json'))

// Start - Variables created to be used to attach NSG to AzureBastionSubnet
@description('Required. Iterate over each "hubVnetSubnets" and build variable to store "AzureBastionSubnet".')
var AzureBastionSubnet = params.parameters.hubVnetSubnets.value[3]

@description('Required. Iterate over each "hubNetworkSecurityGroups" and build variable to store NSG for "AzureBastionSubnet".')
var bastionNsg = params.parameters.hubNetworkSecurityGroups.value[0].name
// End - Variables created to be used to attach NSG to AzureBastionSubnet

// Start - Variables created to be used to configure 'virtualNetworkLinks' for Private DNS Zone(s)
@description('Required. Iterate over each "spokeVnets" and build "resourceId" of each Virtual Networks using "subscriptionId", "vnetRgName" and "vNet.name".')
var spokeVNetsResourceIds = [for vNet in params.parameters.spokeVnets.value: resourceId(vNet.subscriptionId, vnetRgName, 'Microsoft.Network/virtualNetworks', vNet.name)]

@description('Required. Build "resourceId" of Hub Virtual Network using "hubVnetSubscriptionId", "vnetRgName" and "hubVnetName".')
var hubVNetResourceId = [ resourceId(hubVnetSubscriptionId, vnetRgName, 'Microsoft.Network/virtualNetworks', params.parameters.hubVnetName.value) ]

@description('Required. Combine two varibales using "union" function - This will be input for "virtualNetworkLinks" configuration for each Private DNS Zones.')
var vNetResourceIds = union(hubVNetResourceId, spokeVNetsResourceIds)
// End - Variables created to be used to configure 'virtualNetworkLinks' for Private DNS Zone(s)

@description('Required. Subscription ID of Management Subscription.')
param mgmtsubid string

@description('Required. Virtual Network name in Management Subscription.')
param mgmtVnetName string = 'vnet-${projowner}-${opscope}-${region}-mgmt'

@description('Required. Subnet name to be used for Private Endpoint.')
param peSubnetName string = 'snet-${projowner}-${opscope}-${region}-mgmt'

@description('Required. SIEM Resource Group Name.')
param siemRgName string = 'rg-${projowner}-${opscope}-${region}-siem'

@description('Required. Automation Account Name - LAW - Logs Collection.')
param logAutomationAcctName string = 'aa-${projowner}-${opscope}-${region}-logs'

@description('Required. Automation Account Name - LAW - Sentinel')
param sentinelAutomationAcctName string = 'aa-${projowner}-${opscope}-${region}-siem'

@description('Required. Last four digits of Enrollment Number.')
param enrollmentID string

@description('Required. Storage Account Name for resource Diagnostics Settings - Log Collection.')
param stgAcctName string = toLower(take('st${projowner}${opscope}${enrollmentID}${region}logs', 24))

@description('Required. Name of the Key Vault. Must be globally unique.')
@maxLength(24)
param akvName string = toLower(take('kv-${projowner}-${opscope}-${region}-siem', 24))

@description('Required. Automation Account subresource IDs (groupId).')
var aaGroupIds = [
  'Webhook'
  'DSCAndHybridWorker'
]

@description('Required. Suffix to be used in resource naming with 4 characters.')
param mgmtSuffix string = 'mgmt'

@description('Required. Suffix to be used in resource naming with 4 characters.')
param ssvcSuffix string = 'ssvc'

@description('Required. Name of the Azure Recovery Service Vault in Management Subscription.')
param mgmtVaultName  string = 'rsv-${projowner}-${opscope}-${region}-${mgmtSuffix}'

@description('Required. Name of the Azure Recovery Service Vault in Shared Services Subscription.')
param ssvcVaultName  string = 'rsv-${projowner}-${opscope}-${region}-${ssvcSuffix}'

@description('Required. Subscription ID of Shared Services Subscription.')
param ssvcsubid string

@description('Required. Virtual Network name in Management Subscription.')
param ssvcVnetName string = 'vnet-${projowner}-${opscope}-${region}-ssvc'

@description('Required. Name of the resourceGroup, where centralized management components will be.')
param mgmtRgName string = 'rg-${projowner}-${opscope}-${region}-mgmt'

@description('Required. Load content from json file to iterate over "rgRoleAssignments".')
var paramsRoles = json(loadTextContent('../roles/.parameters/customRoleAssignments.json'))

@description('Required. Iterate over "rgRoleAssignments" and build variable to store roleDefitionId for "Deploy Private Endpoint - Private DNS A Contributor" custom role.')
var priDNSAContributorRoleDefintionId = paramsRoles.parameters.rgRoleAssignments.value[0].roleDefinitionIdOrName

@description('Required. Iterate over "rgRoleAssignments" and build variable to store roleDefitionId for "Deploy Private Endpoint - Networking Permissions" custom role.')
var networkingPermsRoleDefintionId = paramsRoles.parameters.rgRoleAssignments.value[1].roleDefinitionIdOrName

var varAzBackupGeoCodes = {
  australiacentral: 'acl'
  australiacentral2: 'acl2'
  australiaeast: 'ae'
  australiasoutheast: 'ase'
  brazilsouth: 'brs'
  brazilsoutheast: 'bse'
  centraluseuap: 'ccy'
  canadacentral: 'cnc'
  canadaeast: 'cne'
  centralus: 'cus'
  eastasia: 'ea'
  eastus2euap: 'ecy'
  eastus: 'eus'
  eastus2: 'eus2'
  francecentral: 'frc'
  francesouth: 'frs'
  germanynorth: 'gn'
  germanywestcentral: 'gwc'
  centralindia: 'inc'
  southindia: 'ins'
  westindia: 'inw'
  japaneast: 'jpe'
  japanwest: 'jpw'
  jioindiacentral: 'jic'
  jioindiawest: 'jiw'
  koreacentral: 'krc'
  koreasouth: 'krs'
  northcentralus: 'ncus'
  northeurope: 'ne'
  norwayeast: 'nwe'
  norwaywest: 'nww'
  qatarcentral: 'qac'
  southafricanorth: 'san'
  southafricawest: 'saw'
  southcentralus: 'scus'
  swedencentral: 'sdc'
  swedensouth: 'sds'
  southeastasia: 'sea'
  switzerlandnorth: 'szn'
  switzerlandwest: 'szw'
  uaecentral: 'uac'
  uaenorth: 'uan'
  uksouth: 'uks'
  ukwest: 'ukw'
  westcentralus: 'wcus'
  westeurope: 'we'
  westus: 'wus'
  westus2: 'wus2'
  westus3: 'wus3'
  usdodcentral: 'udc'
  usdodeast: 'ude'
  usgovarizona: 'uga'
  usgoviowa: 'ugi'
  usgovtexas: 'ugt'
  usgovvirginia: 'ugv'
  usnateast: 'exe'
  usnatwest: 'exw'
  usseceast: 'rxe'
  ussecwest: 'rxw'
  chinanorth: 'bjb'
  chinanorth2: 'bjb2'
  chinanorth3: 'bjb3'
  chinaeast: 'sha'
  chinaeast2: 'sha2'
  chinaeast3: 'sha3'
  germanycentral: 'gec'
  germanynortheast: 'gne'
}

// If region entered in `location` and matches a lookup to varAzBackupGeoCodes then insert Azure Backup Private DNS Zone with appropriate geo code inserted alongside zones in parPrivateDnsZones. If not just return parPrivateDnsZones
var privatelinkBackup = replace('privatelink.<geoCode>.backup.windowsazure.us', '<geoCode>', '${varAzBackupGeoCodes[toLower(location)]}')

@description('Required. Subnet name to be used for Private Endpoint.')
param mgmtSubnetName string = 'snet-${projowner}-${opscope}-${region}-mgmt'

// 1. Create Hub Resoruce Group
module hubRg '../modules/resources/resourceGroups/deploy.bicep' = {
  name: 'rg-${take(uniqueString(deployment().name, location), 4)}-${vnetRgName}'
  scope: subscription(hubVnetSubscriptionId)
  params: {
    name: vnetRgName
    location: location
    tags: ccsCombinedTags
  }
}

// 2. Create Hub Network Security Group(s)
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
    diagnosticSettingsName: diagSettingName
    diagnosticStorageAccountId: diagnosticStorageAccountId
    diagnosticWorkspaceId: diagnosticWorkspaceId
    //diagnosticEventHubAuthorizationRuleId: diagnosticEventHubAuthorizationRuleId
    //diagnosticEventHubName: diagnosticEventHubName
  }
}]

// 3. Create Route Table (Connectivity Subscription)
module hubRouteTable '../modules/network//routeTables/deploy.bicep' = {
  name: 'hubRouteTable-${take(uniqueString(deployment().name, location), 4)}-${defaultRouteTableName}'
  scope: resourceGroup(hubVnetSubscriptionId, vnetRgName)
  params: {
    name: defaultRouteTableName
    location: location
    tags: ccsCombinedTags
    routes: routes
  }
}

// 4. Create Route Table (Spoke Subscriptions)
module spokeRouteTables '../modules/network//routeTables/deploy.bicep' = [for (vNet, index) in spokeVnets: {
  name: 'spokeRouteTables-${take(uniqueString(deployment().name, location), 4)}-${defaultRouteTableName}'
  scope: resourceGroup(vNet.subscriptionId, vnetRgName)
  params: {
    name: defaultRouteTableName
    location: location
    tags: ccsCombinedTags
    routes: routes
  }
}]

// 3. Create Hub Virtual Network
module hubVnet '../modules/network/virtualNetworks/deploy.bicep' = {
  name: 'vnet-${take(uniqueString(deployment().name, location), 4)}-${hubVnetName}'
  scope: resourceGroup(hubVnetSubscriptionId, vnetRgName)
  dependsOn: [
    hubNsgs
    hubRouteTable
  ]
  params: {
    name: hubVnetName
    location: location
    tags: ccsCombinedTags
    addressPrefixes: hubVnetAddressPrefixes
    subnets: hubVnetSubnets
    virtualNetworkPeerings: hubVnetVirtualNetworkPeerings
    subscriptionId: hubVnetSubscriptionId
    diagnosticSettingsName: diagSettingName
    diagnosticStorageAccountId: diagnosticStorageAccountId
    diagnosticWorkspaceId: diagnosticWorkspaceId
    //diagnosticEventHubAuthorizationRuleId: diagnosticEventHubAuthorizationRuleId
    //diagnosticEventHubName: diagnosticEventHubName
  }
}

// 4. Attach NSG to AzureBastionSubnet
module attachNsgToAzureBastionSubnet '../modules/network/virtualNetworks/subnets/deploy.bicep' = {
  name: 'attachNsgToAzureBastionSubnet-${AzureBastionSubnet.name}'
  scope: resourceGroup(hubVnetSubscriptionId, vnetRgName)
  dependsOn: [
    hubNsgs
    hubVnet
  ]
  params: {
    name: AzureBastionSubnet.name
    virtualNetworkName: hubVnetName
    addressPrefix: AzureBastionSubnet.addressPrefix
    networkSecurityGroupId: resourceId(hubVnetSubscriptionId, vnetRgName, 'Microsoft.Network/networkSecurityGroups', bastionNsg)
    //serviceEndpoints: AzureBastionSubnet.serviceEndpoints
    //privateEndpointNetworkPolicies: AzureBastionSubnet.privateEndpointNetworkPolicies
    //privateLinkServiceNetworkPolicies: AzureBastionSubnet.privateLinkServiceNetworkPolicies
  }
}

// 5. Create Spoke Resoruce Group(s)
module spokeRg '../modules/resources/resourceGroups/deploy.bicep' = [for (vNet, index) in spokeVnets: {
  name: 'rg-${take(uniqueString(deployment().name, location), 4)}-${vnetRgName}'
  scope: subscription(vNet.subscriptionId)
  params: {
    name: vnetRgName
    location: location
    tags: ccsCombinedTags
  }
}]

module spokeNsg '../modules/network/networkSecurityGroups/deploy.bicep' = [for (vNet, index) in spokeVnets: {
  name: 'spokeNsg-${take(uniqueString(deployment().name, location), 4)}-${spokeNetworkSecurityGroups[0].name}'
  scope: resourceGroup(vNet.subscriptionId, vnetRgName)
  dependsOn: [
    hubRg
  ]
  params: {
    name: spokeNetworkSecurityGroups[0].name
    location: location
    tags: ccsCombinedTags
    securityRules: spokeNetworkSecurityGroups[0].securityRules
    roleAssignments: spokeNetworkSecurityGroups[0].roleAssignments    
    diagnosticSettingsName: diagSettingName
    diagnosticStorageAccountId: diagnosticStorageAccountId
    diagnosticWorkspaceId: diagnosticWorkspaceId
    //diagnosticEventHubAuthorizationRuleId: diagnosticEventHubAuthorizationRuleId
    //diagnosticEventHubName: diagnosticEventHubName
  }
}]

// 6. Create Spoke Virtual Network(s)
module spokeVnet '../modules/network/virtualNetworks/deploy.bicep' = [for (vNet, index) in spokeVnets: {
  name: 'vnet-${take(uniqueString(deployment().name, location), 4)}-${vNet.name}'
  scope: resourceGroup(vNet.subscriptionId, vnetRgName)
  dependsOn: [
    spokeRg
    hubVnet
    spokeRouteTables
  ]
  params: {
    name: vNet.name
    location: location
    tags: ccsCombinedTags
    addressPrefixes: vNet.addressPrefixes
    subnets: vNet.subnets
    virtualNetworkPeerings: vNet.virtualNetworkPeerings
    subscriptionId: vNet.subscriptionId
    networkSecurityGroupId: resourceId(vNet.subscriptionId, vnetRgName, 'Microsoft.Network/networkSecurityGroups', spokeNetworkSecurityGroups[0].name)
    diagnosticSettingsName: diagSettingName
    diagnosticStorageAccountId: diagnosticStorageAccountId
    diagnosticWorkspaceId: diagnosticWorkspaceId
    //diagnosticEventHubAuthorizationRuleId: diagnosticEventHubAuthorizationRuleId
    //diagnosticEventHubName: diagnosticEventHubName
    
  }
}]

// 7. Create Public IP Address for Azure Firewall
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
    diagnosticSettingsName: diagSettingName
    diagnosticStorageAccountId: diagnosticStorageAccountId
    diagnosticWorkspaceId: diagnosticWorkspaceId
    //diagnosticEventHubAuthorizationRuleId: diagnosticEventHubAuthorizationRuleId
    //diagnosticEventHubName: diagnosticEventHubName    
  }
}

// 8. Create Fireall Policy and Firewall Policy Rule Collection Groups
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

// 9. Create Firewall
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
    diagnosticSettingsName: diagSettingName
    diagnosticStorageAccountId: diagnosticStorageAccountId
    diagnosticWorkspaceId: diagnosticWorkspaceId
    //diagnosticEventHubAuthorizationRuleId: diagnosticEventHubAuthorizationRuleId
    //diagnosticEventHubName: diagnosticEventHubName
  }
}

// 10. Create Public IP Address for Azure Bastion Host
module bhPip '../modules/network/publicIPAddresses/deploy.bicep' = {
  name: 'bhPip-${take(uniqueString(deployment().name, location), 4)}-${bastionHostPublicIPName}'
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
    diagnosticSettingsName: diagSettingName
    diagnosticStorageAccountId: diagnosticStorageAccountId
    diagnosticWorkspaceId: diagnosticWorkspaceId
    //diagnosticEventHubAuthorizationRuleId: diagnosticEventHubAuthorizationRuleId
    //diagnosticEventHubName: diagnosticEventHubName    
  }
}

// 11. Create Azure Bastion Host
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
    diagnosticSettingsName: diagSettingName
    diagnosticStorageAccountId: diagnosticStorageAccountId
    diagnosticWorkspaceId: diagnosticWorkspaceId
    //diagnosticEventHubAuthorizationRuleId: diagnosticEventHubAuthorizationRuleId
    //diagnosticEventHubName: diagnosticEventHubName
  }
}

// 12. Create Resource Group for Private DNS Zones
module priDNSZonesRg '../modules/resources/resourceGroups/deploy.bicep' = {
  name: 'priDNSZonesRg-${take(uniqueString(deployment().name, location), 4)}-${priDNSZonesRgName}'
  scope: subscription(hubVnetSubscriptionId)
  params: {
    name: priDNSZonesRgName
    location: location
    tags: ccsCombinedTags
  }
}

// 13. Create Private DNS Zones
module priDNSZones '../modules/network/privateDnsZones/deploy.bicep' = [for privateDnsZone in privateDnsZones: {
  name: 'priDNSZones-${privateDnsZone}'
  scope: resourceGroup(hubVnetSubscriptionId, priDNSZonesRgName)
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

// 14. Retrieve an existing Storage Account resource
resource sa 'Microsoft.Storage/storageAccounts@2021-09-01' existing = {
  name: stgAcctName
  scope: resourceGroup(mgmtsubid, siemRgName)
}

// 15. Create Private Endpoint for Storage Account
module saPe '../modules/network/privateEndpoints/deploy.bicep' = {
  name: 'saPe-${take(uniqueString(deployment().name, location), 4)}-${stgAcctName}'
  scope: resourceGroup(mgmtsubid, siemRgName)
  dependsOn: [
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

// 16. Retrieve an existing Automation Account resource (LAW - Logs Collection)
resource aaLoga 'Microsoft.Automation/automationAccounts@2021-06-22' existing = {
  name: logAutomationAcctName
  scope: resourceGroup(mgmtsubid, siemRgName)
}

// 17. Create Private Endpoint for Automation Account (LAW - Logs Collection)
module aaLogaPe '../modules/network/privateEndpoints/deploy.bicep' = [ for aaGroupId in aaGroupIds: {
  name: 'aaPe-${take(uniqueString(deployment().name, location), 4)}-${logAutomationAcctName}-${aaGroupId}'
  scope: resourceGroup(mgmtsubid, siemRgName)
  dependsOn: [
    priDNSZones
  ]
  params: {
    name: '${logAutomationAcctName}-${aaGroupId}-pe'
    location: location
    tags: ccsCombinedTags
    serviceResourceId: aaLoga.id
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

// 18. Retrieve an existing Automation Account resource (LAW - Sentinel)
resource aaLogaSentinel 'Microsoft.Automation/automationAccounts@2021-06-22' existing = {
  name: sentinelAutomationAcctName
  scope: resourceGroup(mgmtsubid, siemRgName)
}

// 19. Create Private Endpoint for Automation Account (LAW - Sentinel)
module aaLogaSentinelPe '../modules/network/privateEndpoints/deploy.bicep' = [ for aaGroupId in aaGroupIds: {
  name: 'aaPe-${take(uniqueString(deployment().name, location), 4)}-${sentinelAutomationAcctName}-${aaGroupId}'
  scope: resourceGroup(mgmtsubid, siemRgName)
  dependsOn: [
    priDNSZones
  ]
  params: {
    name: '${sentinelAutomationAcctName}-${aaGroupId}-pe'
    location: location
    tags: ccsCombinedTags
    serviceResourceId: aaLogaSentinel.id
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

// 20. Retrieve an existing Key Vault resource
resource akv 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: akvName
  scope: resourceGroup(mgmtsubid, siemRgName)
}

// 21. Create Private Endpoint for Key Vault
module akvPe '../modules/network/privateEndpoints/deploy.bicep' = {
  name: 'akvPe-${take(uniqueString(deployment().name, location), 4)}-${akvName}'
  scope: resourceGroup(mgmtsubid, siemRgName)
  dependsOn: [
    priDNSZones
  ]
  params: {
    name: '${akvName}-vault-pe'
    location: location
    tags: ccsCombinedTags
    serviceResourceId: akv.id
    groupIds: [
      'vault'
    ]
    subnetResourceId: resourceId(mgmtsubid, vnetRgName, 'Microsoft.Network/virtualNetworks/subnets', mgmtVnetName, peSubnetName)
    privateDnsZoneGroup: {
      privateDNSResourceIds: [
        resourceId(hubVnetSubscriptionId, priDNSZonesRgName, 'Microsoft.Network/privateDnsZones', 'privatelink.vaultcore.usgovcloudapi.net')
      ]
    }
  }
}

// 22. Retrieve an existing Recovery Services Vault Resource (Management Subscription)
resource rsv_mgmt 'Microsoft.RecoveryServices/vaults@2022-04-01' existing = {
  name: mgmtVaultName
  scope: resourceGroup(mgmtsubid, mgmtRgName)
}

// 23. Create Role Assignment for Recovery Services Vault's System Managed Identity (PrivateDNSZones RG)
module roleAssignmentPriDNSAContributor_mgmt '../modules/authorization/roleAssignments/resourceGroup/deploy.bicep' = {
  name: 'roleAssignmentPriDNSAContributor-${take(uniqueString(deployment().name, location), 4)}-${mgmtVaultName}'
  scope: resourceGroup(hubVnetSubscriptionId, priDNSZonesRgName)
  dependsOn: [
    rsv_mgmt
  ]
  params: {
    roleDefinitionIdOrName: priDNSAContributorRoleDefintionId
    principalType: 'ServicePrincipal'
    principalIds: [
      rsv_mgmt.identity.principalId
    ]
  }
}

// 24. Create Role Assignment for Recovery Services Vault's System Managed Identity (Management - VNet RG)
module roleAssignmentNetworkingPerms_mgmt '../modules/authorization/roleAssignments/resourceGroup/deploy.bicep' = {
  name: 'roleAssignmentNetworkingPerms-${take(uniqueString(deployment().name, location), 4)}-${mgmtVaultName}'
  scope: resourceGroup(mgmtsubid, vnetRgName)
  dependsOn: [
    rsv_mgmt
  ]
  params: {
    roleDefinitionIdOrName: networkingPermsRoleDefintionId
    principalType: 'ServicePrincipal'
    principalIds: [
      rsv_mgmt.identity.principalId
    ]
  }
}

// 25. Create Role Assignment for Recovery Services Vault's System Managed Identity (Management - MGMT RG)
module roleAssignmentContributor_mgmt '../modules/authorization/roleAssignments/resourceGroup/deploy.bicep' = {
  name: 'roleAssignmentContributor-${take(uniqueString(deployment().name, location), 4)}-${mgmtVaultName}'
  scope: resourceGroup(mgmtsubid, mgmtRgName)
  dependsOn: [
    rsv_mgmt
  ]
  params: {
    roleDefinitionIdOrName: 'Contributor'
    principalType: 'ServicePrincipal'
    principalIds: [
      rsv_mgmt.identity.principalId
    ]
  }
}

// 26. Create Private Endpoint for Recovery Services Vault (Management Subscription)
module rsvPe_mgmt '../modules/network/privateEndpoints/deploy.bicep' = {
  name: 'rsvPe_mgmt-${take(uniqueString(deployment().name, location), 4)}-${mgmtVaultName}'
  scope: resourceGroup(mgmtsubid, mgmtRgName)
  dependsOn: [
    roleAssignmentPriDNSAContributor_mgmt
    roleAssignmentNetworkingPerms_mgmt
    roleAssignmentContributor_mgmt
  ]
  params: {
    name: '${mgmtVaultName}-AzureBackup-pe'
    location: location
    tags: ccsCombinedTags
    serviceResourceId: rsv_mgmt.id
    groupIds: [
      'AzureBackup'
    ]
    subnetResourceId: resourceId(mgmtsubid, vnetRgName, 'Microsoft.Network/virtualNetworks/subnets', mgmtVnetName, mgmtSubnetName)
    privateDnsZoneGroup: {
      privateDNSResourceIds: [
        resourceId(hubVnetSubscriptionId, priDNSZonesRgName, 'Microsoft.Network/privateDnsZones', privatelinkBackup)
        resourceId(hubVnetSubscriptionId, priDNSZonesRgName, 'Microsoft.Network/privateDnsZones', 'privatelink.queue.core.usgovcloudapi.net')
        resourceId(hubVnetSubscriptionId, priDNSZonesRgName, 'Microsoft.Network/privateDnsZones', 'privatelink.blob.core.usgovcloudapi.net')
      ]
    }
  }
}

// 27. Retrieve an existing Recovery Services Vault Resource (Shared Services Subscription)
resource rsv_ssvc 'Microsoft.RecoveryServices/vaults@2022-04-01' existing = {
  name: ssvcVaultName
  scope: resourceGroup(ssvcsubid, mgmtRgName)
}

// 28. Create Role Assignment for Recovery Services Vault's System Managed Identity (PrivateDNSZones RG)
module roleAssignmentPriDNSAContributor_ssvc '../modules/authorization/roleAssignments/resourceGroup/deploy.bicep' = {
  name: 'roleAssignmentPriDNSAContributor-${take(uniqueString(deployment().name, location), 4)}-${ssvcVaultName}'
  scope: resourceGroup(hubVnetSubscriptionId, priDNSZonesRgName)
  dependsOn: [
    rsv_ssvc
  ]
  params: {
    roleDefinitionIdOrName: priDNSAContributorRoleDefintionId
    principalType: 'ServicePrincipal'
    principalIds: [
      rsv_ssvc.identity.principalId
    ]
  }
}

// 29. Create Role Assignment for Recovery Services Vault's System Managed Identity (Shared Services - VNet RG)
module roleAssignmentNetworkingPerms_ssvc '../modules/authorization/roleAssignments/resourceGroup/deploy.bicep' = {
  name: 'roleAssignmentNetworkingPerms-${take(uniqueString(deployment().name, location), 4)}-${ssvcVaultName}'
  scope: resourceGroup(ssvcsubid, vnetRgName)
  dependsOn: [
    rsv_ssvc
  ]
  params: {
    roleDefinitionIdOrName: networkingPermsRoleDefintionId
    principalType: 'ServicePrincipal'
    principalIds: [
      rsv_ssvc.identity.principalId
    ]
  }
}

// 30. Create Role Assignment for Recovery Services Vault's System Managed Identity (Shared Services - MGMT RG)
module roleAssignmentContributor_ssvc '../modules/authorization/roleAssignments/resourceGroup/deploy.bicep' = {
  name: 'roleAssignmentContributor-${take(uniqueString(deployment().name, location), 4)}-${ssvcVaultName}'
  scope: resourceGroup(ssvcsubid, mgmtRgName)
  dependsOn: [
    rsv_ssvc
  ]
  params: {
    roleDefinitionIdOrName: 'Contributor'
    principalType: 'ServicePrincipal'
    principalIds: [
      rsv_ssvc.identity.principalId
    ]
  }
}

// 31. Create Private Endpoint for Recovery Services Vault (Shared Services Subscription)
module rsvPe_ssvc '../modules/network/privateEndpoints/deploy.bicep' = {
  name: 'rsvPe_mgmt-${take(uniqueString(deployment().name, location), 4)}-${ssvcVaultName}'
  scope: resourceGroup(ssvcsubid, mgmtRgName)
  dependsOn: [
    roleAssignmentPriDNSAContributor_ssvc
    roleAssignmentNetworkingPerms_ssvc
    roleAssignmentContributor_ssvc
  ]
  params: {
    name: '${mgmtVaultName}-AzureBackup-pe'
    location: location
    tags: ccsCombinedTags
    serviceResourceId: rsv_ssvc.id
    groupIds: [
      'AzureBackup'
    ]
    subnetResourceId: resourceId(ssvcsubid, vnetRgName, 'Microsoft.Network/virtualNetworks/subnets', ssvcVnetName, mgmtSubnetName)
    privateDnsZoneGroup: {
      privateDNSResourceIds: [
        resourceId(hubVnetSubscriptionId, priDNSZonesRgName, 'Microsoft.Network/privateDnsZones', privatelinkBackup)
        resourceId(hubVnetSubscriptionId, priDNSZonesRgName, 'Microsoft.Network/privateDnsZones', 'privatelink.queue.core.usgovcloudapi.net')
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


/*
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

@description('Required. Log Ananlytics Workspace Name for Azure Sentinel.')
param sentinelLawName string = 'log-${projowner}-${opscope}-${region}-siem'

@description('Required. Log Ananlytics Workspace Name for resource Diagnostics Settings - Log Collection.')
param logsLawName string = 'log-${projowner}-${opscope}-${region}-logs'

// 20. Create Azure Monitor Private Link Scope
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

// 21. Create Private Endpoint for Azure Monitor Private Link Scope
module amplsPe '../modules/network/privateEndpoints/deploy.bicep' = {
  name: 'amplsPe-${take(uniqueString(deployment().name, location), 4)}-${amplsName}'
  scope: resourceGroup(hubVnetSubscriptionId, vnetRgName)
  dependsOn: [
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
}*/
