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

@description('Required. User Assigned Managed Identity to be used to assigned to Firewall Policy which it will utilize to access Key Vault Certificate for TLS Inspection configuration.')
param userMiAfpTlsInspection string = 'id-${projowner}-${opscope}-${region}-afwp'

@description('Required. Firewall Policy name prefix.')
param firewallPolicyNamePrefix string = 'afwp-${projowner}-${opscope}-${region}-00'

@description('Required. Firewall Policies array.')
param firewallPolicies array

@description('Required. Firewall Policy Rule Collection Groups array.')
param firewallPolicyRuleCollectionGroups array

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

@description('Required. Storage Account Name for resource Diagnostics Settings - Log Collection - Management Subscription.')
param stgAcctName string = toLower(take('st${projowner}${opscope}${enrollmentID}${region}logs', 24))

@description('Required. Storage Account Name for Storing Shared data managed by platform team - Shared Services Subscription.')
param stgAcctSsvcName string = toLower(take('st${projowner}${opscope}${enrollmentID}${region}ssvc', 24))

@description('Required. Name of the Key Vault. Must be globally unique - Management Subscription.')
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
param mgmtVaultName string = 'rsv-${projowner}-${opscope}-${region}-${mgmtSuffix}'

@description('Required. Name of the Azure Recovery Service Vault in Shared Services Subscription.')
param ssvcVaultName string = 'rsv-${projowner}-${opscope}-${region}-${ssvcSuffix}'

@description('Required. Subscription ID of Shared Services Subscription.')
param ssvcsubid string

@description('Required. Virtual Network name in Shared Services Subscription.')
param ssvcVnetName string = 'vnet-${projowner}-${opscope}-${region}-ssvc'

@description('Required. Name of the resourceGroup, where centralized management components will be.')
param mgmtRgName string = 'rg-${projowner}-${opscope}-${region}-mgmt'

@description('Required. Load content from json file to iterate over "rgRoleAssignments".')
var paramsRoles = json(loadTextContent('../roles/.parameters/customRoleAssignments.json'))

@description('Required. Iterate over "rgRoleAssignments" and build variable to store roleDefitionId for "Deploy Private Endpoint - Private DNS A Contributor" custom role.')
var priDNSAContributorRoleDefintionId = paramsRoles.parameters.rgRoleAssignments.value[0].roleDefinitionIdOrName

@description('Required. Iterate over "rgRoleAssignments" and build variable to store roleDefitionId for "Deploy Private Endpoint - Networking Permissions" custom role.')
var networkingPermsRoleDefintionId = paramsRoles.parameters.rgRoleAssignments.value[1].roleDefinitionIdOrName

@description('Required. Storage Account Subresource(s) (aka "groupIds").')
param stgGroupIds array

@description('Required. Mapping Storage Account Subresource(s) with required Privaate DNS Zone(s) for Private Endpoint creation.')
var groupIds = {
  blob: 'privatelink.blob.core.usgovcloudapi.net'
  blob_secondary: 'privatelink.blob.core.usgovcloudapi.net'
  table: 'privatelink.table.core.usgovcloudapi.net'
  table_secondary: 'privatelink.table.core.usgovcloudapi.net'
  queue: 'privatelink.queue.core.usgovcloudapi.net'
  queue_secondary: 'privatelink.queue.core.usgovcloudapi.net'
  file: 'privatelink.file.core.usgovcloudapi.net'
  web: 'privatelink.web.core.usgovcloudapi.net'
  web_secondary: 'privatelink.web.core.usgovcloudapi.net'
  dfs: 'privatelink.dfs.core.usgovcloudapi.net'
  dfs_secondary: 'privatelink.dfs.core.usgovcloudapi.net'
}

// Azure Backup Geo Codes - https://learn.microsoft.com/en-us/azure/backup/scripts/geo-code-list
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

// 2. Create Hub Network Security Group(s) (Connectivity Subscription)
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
  dependsOn: [
    hubRg
  ]
  params: {
    name: defaultRouteTableName
    location: location
    tags: ccsCombinedTags
    routes: routes
  }
}

// 4. Create Hub Virtual Network
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

// 5. Attach NSG to AzureBastionSubnet
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

// 6. Create Spoke Resoruce Group(s)
module spokeRg '../modules/resources/resourceGroups/deploy.bicep' = [for (vNet, index) in spokeVnets: {
  name: 'rg-${take(uniqueString(deployment().name, location), 4)}-${vnetRgName}'
  scope: subscription(vNet.subscriptionId)
  params: {
    name: vnetRgName
    location: location
    tags: ccsCombinedTags
  }
}]

// 7. Create Hub Network Security Group(s) (Spoke Subscriptions)
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

// 8. Create Route Table (Spoke Subscriptions)
module spokeRouteTables '../modules/network//routeTables/deploy.bicep' = [for (vNet, index) in spokeVnets: {
  name: 'spokeRouteTables-${take(uniqueString(deployment().name, location), 4)}-${defaultRouteTableName}'
  scope: resourceGroup(vNet.subscriptionId, vnetRgName)
  dependsOn: [
    spokeRg
  ]
  params: {
    name: defaultRouteTableName
    location: location
    tags: ccsCombinedTags
    routes: routes
  }
}]

// 9. Create Spoke Virtual Network(s)
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
    dnsServers: vNet.dnsServers
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

// 10. Create Resource Group for Private DNS Zones
module priDNSZonesRg '../modules/resources/resourceGroups/deploy.bicep' = {
  name: 'priDNSZonesRg-${take(uniqueString(deployment().name, location), 4)}-${priDNSZonesRgName}'
  scope: subscription(hubVnetSubscriptionId)
  params: {
    name: priDNSZonesRgName
    location: location
    tags: ccsCombinedTags
  }
}

// 11. Create Private DNS Zones
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

// 12. Create Public IP Address for Azure Firewall
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

// 13. Create User Assigned Managed Identity (Firewall Policy - TLS Inspection/KeyVault Secret)
module userMiAfwp '../modules/managedIdentity/userAssignedIdentities/deploy.bicep' = {
  name: 'userMiAfwp-${take(uniqueString(deployment().name, location), 4)}'
  scope: resourceGroup(hubVnetSubscriptionId, vnetRgName)
  dependsOn: [
    hubRg
  ]
  params: {
    name: userMiAfpTlsInspection
    location: location
    tags: ccsCombinedTags
  }
}

// 14. Retrieve an existing Key Vault resource (Management Subscription)
resource akv 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: akvName
  scope: resourceGroup(mgmtsubid, siemRgName)
}

// 15. Create Private Endpoint for Key Vault
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

// 16. Create Role Assignment for User Assignment Managed Identity to Key Vault (Connectivity Subscription)
module roleAssignmentKeyVault '../modules/authorization/roleAssignments/resourceGroup/deploy.bicep' = {
  name: 'roleAssignmentKeyVault-${take(uniqueString(deployment().name, location), 4)}-${akvName}'
  scope: resourceGroup(mgmtsubid, siemRgName)
  dependsOn: [
    userMiAfwp
    akv
  ]
  params: {
    roleDefinitionIdOrName: 'Key Vault Secrets User'
    principalType: 'ServicePrincipal'
    principalIds: [
      userMiAfwp.outputs.principalId
    ]
  }
}

// 17. Create Fireall Policy
module afwp '../modules/network/firewallPolicies/deploy.bicep' = [for (firewallPolicy, i) in firewallPolicies: {
  name: 'afwp-${take(uniqueString(deployment().name, location), 4)}-${i}'
  scope: resourceGroup(hubVnetSubscriptionId, vnetRgName)
  dependsOn: [
    hubRg
    roleAssignmentKeyVault
    akvPe
  ]
  params: {
    name: '${firewallPolicyNamePrefix}${i + 1}'
    location: location
    tags: ccsCombinedTags
    userAssignedIdentities: {
      '${userMiAfwp.outputs.resourceId}': {}
    }
    insightsIsEnabled: firewallPolicy.insightsIsEnabled
    defaultWorkspaceId: diagnosticWorkspaceId
    tier: firewallPolicy.tier
    enableProxy: firewallPolicy.enableDnsProxy
    servers: firewallPolicy.customDnsServers
    certificateName: firewallPolicy.transportSecurityCertificateName
    keyVaultSecretId: '${akv.properties.vaultUri}secrets/${firewallPolicy.transportSecurityCertificateName}'
    mode: firewallPolicy.intrusionDetectionMode
    bypassTrafficSettings: firewallPolicy.intrusionDetectionBypassTrafficSettings
    signatureOverrides: firewallPolicy.intrusionDetectionSignatureOverrides
    threatIntelMode: firewallPolicy.threatIntelMode
    fqdns: firewallPolicy.threatIntelFqdns
    ipAddresses: firewallPolicy.threatIntelIpAddresses
    //ruleCollectionGroups: firewallPolicy.firewallPolicyRuleCollectionGroups
  }
}]

// 18. Create Firewall Policy Rule Collection Groups
module afprcg '../modules/network/firewallPolicies/ruleCollectionGroups/deploy.bicep' = [for (firewallPolicyRuleCollectionGroup, i) in firewallPolicyRuleCollectionGroups: {
  name:  'afprcg-${take(uniqueString(deployment().name, location), 4)}-${firewallPolicyRuleCollectionGroup.name}'
  scope: resourceGroup(hubVnetSubscriptionId, vnetRgName)
  dependsOn: [
    afwp
  ]
  params: {
    firewallPolicyName: '${firewallPolicyNamePrefix}1'
    name: firewallPolicyRuleCollectionGroup.name
    priority: firewallPolicyRuleCollectionGroup.priority
    ruleCollections: firewallPolicyRuleCollectionGroup.ruleCollections
  }
}]

// 18. Create Firewall
module afw '../modules/network/azureFirewalls/deploy.bicep' = {
  name: 'afw-${take(uniqueString(deployment().name, location), 4)}-${firewallName}'
  scope: resourceGroup(hubVnetSubscriptionId, vnetRgName)
  dependsOn: [
    hubVnet
    spokeVnet
    afwPip
    afprcg
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
    firewallPolicyId: afwp[0].outputs.resourceId
    roleAssignments: firewallRoleAssignments
    diagnosticSettingsName: diagSettingName
    diagnosticStorageAccountId: diagnosticStorageAccountId
    diagnosticWorkspaceId: diagnosticWorkspaceId
    //diagnosticEventHubAuthorizationRuleId: diagnosticEventHubAuthorizationRuleId
    //diagnosticEventHubName: diagnosticEventHubName
  }
}

// 19. Create Public IP Address for Azure Bastion Host
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

// 20. Create Azure Bastion Host
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

// 21. Retrieve an existing Storage Account resource (Management Subscription)
resource saMgmt 'Microsoft.Storage/storageAccounts@2021-09-01' existing = {
  name: stgAcctName
  scope: resourceGroup(mgmtsubid, siemRgName)
}

// 22. Create Private Endpoint for Storage Account (Management Subscription)
module saMgmtPe '../modules/network/privateEndpoints/deploy.bicep' = [for (stgGroupId, index) in stgGroupIds: if (!empty(stgGroupIds)) {
  name: 'saMgmtPe-${take(uniqueString(deployment().name, location), 4)}-${stgGroupId}'
  scope: resourceGroup(mgmtsubid, siemRgName)
  dependsOn: [
    priDNSZones
  ]
  params: {
    name: '${stgAcctName}-${stgGroupId}-pe'
    location: location
    tags: ccsCombinedTags
    serviceResourceId: saMgmt.id
    groupIds: [
      stgGroupId
    ]
    subnetResourceId: resourceId(mgmtsubid, vnetRgName, 'Microsoft.Network/virtualNetworks/subnets', mgmtVnetName, peSubnetName)
    privateDnsZoneGroup: {
      privateDNSResourceIds: [
        resourceId(hubVnetSubscriptionId, priDNSZonesRgName, 'Microsoft.Network/privateDnsZones', contains(groupIds, stgGroupId) ? groupIds[stgGroupId] : '')
      ]
    }
  }
}]

// 23. Retrieve an existing Storage Account resource (Shared Services Subscription)
resource saSsvc 'Microsoft.Storage/storageAccounts@2021-09-01' existing = {
  name: stgAcctSsvcName
  scope: resourceGroup(ssvcsubid, mgmtRgName)
}

// 24. Create Private Endpoint for Storage Account (Shared Services Subscription)
module saSsvcPe '../modules/network/privateEndpoints/deploy.bicep' = [for (stgGroupId, index) in stgGroupIds: if (!empty(stgGroupIds)) {
  name: 'saSsvcPe-${take(uniqueString(deployment().name, location), 4)}-${stgGroupId}'
  scope: resourceGroup(ssvcsubid, mgmtRgName)
  dependsOn: [
    priDNSZones
    saMgmtPe
  ]
  params: {
    name: '${stgAcctSsvcName}-${stgGroupId}-pe'
    location: location
    tags: ccsCombinedTags
    serviceResourceId: saSsvc.id
    groupIds: [
      stgGroupId
    ]
    subnetResourceId: resourceId(ssvcsubid, vnetRgName, 'Microsoft.Network/virtualNetworks/subnets', ssvcVnetName, peSubnetName)
    privateDnsZoneGroup: {
      privateDNSResourceIds: [
        resourceId(hubVnetSubscriptionId, priDNSZonesRgName, 'Microsoft.Network/privateDnsZones', contains(groupIds, stgGroupId) ? groupIds[stgGroupId] : '')
      ]
    }
  }
}]

// 25. Retrieve an existing Automation Account resource (LAW - Logs Collection)
resource aaLoga 'Microsoft.Automation/automationAccounts@2021-06-22' existing = {
  name: logAutomationAcctName
  scope: resourceGroup(mgmtsubid, siemRgName)
}

// 26. Create Private Endpoint for Automation Account (LAW - Logs Collection)
module aaLogaPe '../modules/network/privateEndpoints/deploy.bicep' = [for aaGroupId in aaGroupIds: {
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

// 27. Retrieve an existing Automation Account resource (LAW - Sentinel)
resource aaLogaSentinel 'Microsoft.Automation/automationAccounts@2021-06-22' existing = {
  name: sentinelAutomationAcctName
  scope: resourceGroup(mgmtsubid, siemRgName)
}

// 28. Create Private Endpoint for Automation Account (LAW - Sentinel)
module aaLogaSentinelPe '../modules/network/privateEndpoints/deploy.bicep' = [for aaGroupId in aaGroupIds: {
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

// 29. Retrieve an existing Recovery Services Vault Resource (Management Subscription)
resource rsv_mgmt 'Microsoft.RecoveryServices/vaults@2022-04-01' existing = {
  name: mgmtVaultName
  scope: resourceGroup(mgmtsubid, mgmtRgName)
}

// 30. Create Role Assignment for Recovery Services Vault's System Managed Identity (PrivateDNSZones RG)
module roleAssignmentPriDNSAContributor_mgmt '../modules/authorization/roleAssignments/resourceGroup/deploy.bicep' = {
  name: 'roleAssignmentPriDNSAContributor-${take(uniqueString(deployment().name, location), 4)}-${mgmtVaultName}'
  scope: resourceGroup(hubVnetSubscriptionId, priDNSZonesRgName)
  dependsOn: [
    rsv_mgmt
    hubRg
    spokeRg
  ]
  params: {
    roleDefinitionIdOrName: priDNSAContributorRoleDefintionId
    principalType: 'ServicePrincipal'
    principalIds: [
      rsv_mgmt.identity.principalId
    ]
  }
}

// 31. Create Role Assignment for Recovery Services Vault's System Managed Identity (Management - VNet RG)
module roleAssignmentNetworkingPerms_mgmt '../modules/authorization/roleAssignments/resourceGroup/deploy.bicep' = {
  name: 'roleAssignmentNetworkingPerms-${take(uniqueString(deployment().name, location), 4)}-${mgmtVaultName}'
  scope: resourceGroup(mgmtsubid, vnetRgName)
  dependsOn: [
    rsv_mgmt
    hubRg
    spokeRg
  ]
  params: {
    roleDefinitionIdOrName: networkingPermsRoleDefintionId
    principalType: 'ServicePrincipal'
    principalIds: [
      rsv_mgmt.identity.principalId
    ]
  }
}

// 32. Create Role Assignment for Recovery Services Vault's System Managed Identity (Management - MGMT RG)
module roleAssignmentContributor_mgmt '../modules/authorization/roleAssignments/resourceGroup/deploy.bicep' = {
  name: 'roleAssignmentContributor-${take(uniqueString(deployment().name, location), 4)}-${mgmtVaultName}'
  scope: resourceGroup(mgmtsubid, mgmtRgName)
  dependsOn: [
    rsv_mgmt
    hubRg
    spokeRg
  ]
  params: {
    roleDefinitionIdOrName: 'Contributor'
    principalType: 'ServicePrincipal'
    principalIds: [
      rsv_mgmt.identity.principalId
    ]
  }
}

// 33. Create Private Endpoint for Recovery Services Vault (Management Subscription)
module rsvPe_mgmt '../modules/network/privateEndpoints/deploy.bicep' = {
  name: 'rsvPe_mgmt-${take(uniqueString(deployment().name, location), 4)}-${mgmtVaultName}'
  scope: resourceGroup(mgmtsubid, mgmtRgName)
  dependsOn: [
    roleAssignmentPriDNSAContributor_mgmt
    roleAssignmentNetworkingPerms_mgmt
    roleAssignmentContributor_mgmt
    hubVnet
    spokeVnet
  ]
  params: {
    name: '${mgmtVaultName}-AzureBackup-pe'
    location: location
    tags: ccsCombinedTags
    serviceResourceId: rsv_mgmt.id
    groupIds: [
      'AzureBackup'
    ]
    subnetResourceId: resourceId(mgmtsubid, vnetRgName, 'Microsoft.Network/virtualNetworks/subnets', mgmtVnetName, peSubnetName)
    privateDnsZoneGroup: {
      privateDNSResourceIds: [
        resourceId(hubVnetSubscriptionId, priDNSZonesRgName, 'Microsoft.Network/privateDnsZones', privatelinkBackup)
        resourceId(hubVnetSubscriptionId, priDNSZonesRgName, 'Microsoft.Network/privateDnsZones', 'privatelink.queue.core.usgovcloudapi.net')
        resourceId(hubVnetSubscriptionId, priDNSZonesRgName, 'Microsoft.Network/privateDnsZones', 'privatelink.blob.core.usgovcloudapi.net')
      ]
    }
  }
}

// 34. Retrieve an existing Recovery Services Vault Resource (Shared Services Subscription)
resource rsv_ssvc 'Microsoft.RecoveryServices/vaults@2022-04-01' existing = {
  name: ssvcVaultName
  scope: resourceGroup(ssvcsubid, mgmtRgName)
}

// 35. Create Role Assignment for Recovery Services Vault's System Managed Identity (PrivateDNSZones RG)
module roleAssignmentPriDNSAContributor_ssvc '../modules/authorization/roleAssignments/resourceGroup/deploy.bicep' = {
  name: 'roleAssignmentPriDNSAContributor-${take(uniqueString(deployment().name, location), 4)}-${ssvcVaultName}'
  scope: resourceGroup(hubVnetSubscriptionId, priDNSZonesRgName)
  dependsOn: [
    rsv_mgmt
    hubRg
    spokeRg
  ]
  params: {
    roleDefinitionIdOrName: priDNSAContributorRoleDefintionId
    principalType: 'ServicePrincipal'
    principalIds: [
      rsv_ssvc.identity.principalId
    ]
  }
}

// 36. Create Role Assignment for Recovery Services Vault's System Managed Identity (Shared Services - VNet RG)
module roleAssignmentNetworkingPerms_ssvc '../modules/authorization/roleAssignments/resourceGroup/deploy.bicep' = {
  name: 'roleAssignmentNetworkingPerms-${take(uniqueString(deployment().name, location), 4)}-${ssvcVaultName}'
  scope: resourceGroup(ssvcsubid, vnetRgName)
  dependsOn: [
    rsv_mgmt
    hubRg
    spokeRg
  ]
  params: {
    roleDefinitionIdOrName: networkingPermsRoleDefintionId
    principalType: 'ServicePrincipal'
    principalIds: [
      rsv_ssvc.identity.principalId
    ]
  }
}

// 37. Create Role Assignment for Recovery Services Vault's System Managed Identity (Shared Services - MGMT RG)
module roleAssignmentContributor_ssvc '../modules/authorization/roleAssignments/resourceGroup/deploy.bicep' = {
  name: 'roleAssignmentContributor-${take(uniqueString(deployment().name, location), 4)}-${ssvcVaultName}'
  scope: resourceGroup(ssvcsubid, mgmtRgName)
  dependsOn: [
    rsv_mgmt
    hubRg
    spokeRg
  ]
  params: {
    roleDefinitionIdOrName: 'Contributor'
    principalType: 'ServicePrincipal'
    principalIds: [
      rsv_ssvc.identity.principalId
    ]
  }
}

// 38. Create Private Endpoint for Recovery Services Vault (Shared Services Subscription)
module rsvPe_ssvc '../modules/network/privateEndpoints/deploy.bicep' = {
  name: 'rsvPe_mgmt-${take(uniqueString(deployment().name, location), 4)}-${ssvcVaultName}'
  scope: resourceGroup(ssvcsubid, mgmtRgName)
  dependsOn: [
    roleAssignmentPriDNSAContributor_ssvc
    roleAssignmentNetworkingPerms_ssvc
    roleAssignmentContributor_ssvc
    hubVnet
    spokeVnet
  ]
  params: {
    name: '${mgmtVaultName}-AzureBackup-pe'
    location: location
    tags: ccsCombinedTags
    serviceResourceId: rsv_ssvc.id
    groupIds: [
      'AzureBackup'
    ]
    subnetResourceId: resourceId(ssvcsubid, vnetRgName, 'Microsoft.Network/virtualNetworks/subnets', ssvcVnetName, peSubnetName)
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
@description('Required. Name of the Key Vault. Must be globally unique - Connectivity Subscription.')
@maxLength(24)
param akvConnectivityName string = toLower(take('kv-${projowner}-${opscope}-${region}-conn', 24))

// 12. Retrieve an existing Key Vault resource (Connectivity Subscription)
resource akvConnectivity 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: akvConnectivityName
  scope: resourceGroup(hubVnetSubscriptionId, mgmtRgName)
}

// 13. Create Private Endpoint for Key Vault (Connectivity Subscription)
module akvConnectivityPe '../modules/network/privateEndpoints/deploy.bicep' = {
  name: 'akvPe-${take(uniqueString(deployment().name, location), 4)}-${akvConnectivityName}'
  scope: resourceGroup(hubVnetSubscriptionId, mgmtRgName)
  dependsOn: [
    priDNSZones
  ]
  params: {
    name: '${akvConnectivityName}-vault-pe'
    location: location
    tags: ccsCombinedTags
    serviceResourceId: akv.id
    groupIds: [
      'vault'
    ]
    subnetResourceId: resourceId(hubVnetSubscriptionId, vnetRgName, 'Microsoft.Network/virtualNetworks/subnets', hubVnetName, peSubnetName)
    privateDnsZoneGroup: {
      privateDNSResourceIds: [
        resourceId(hubVnetSubscriptionId, priDNSZonesRgName, 'Microsoft.Network/privateDnsZones', 'privatelink.vaultcore.usgovcloudapi.net')
      ]
    }
  }
}


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
