targetScope = 'managementGroup'

@description('subscriptionId for the deployment')
param subscriptionId string

@description('Required. Array of role assignment objects to define RBAC on subscriptions.')
param subRoleAssignments array = []

@description('Required. Subscription ID of Connectivity Subscription')
param connsubid string

@description('Required. Resource Group name.')
param vnetRgName string

// Start - Variables created to be used to attach NSG to Management Subnet
var params = json(loadTextContent('../.parameters/parameters.json'))

@description('Required. Iterate over each "hubVnetSubnets" and build variable to store Managemet Subnet.')
var mgmtSubnet = params.parameters.subnets.value[2]

@description('Required. Iterate over each "networkSecurityGroups" and build variable to store NSG for Managemet Subnet.')
var mgmgNsg = params.parameters.networkSecurityGroups.value[0].name
// End - Variables created to be used to attach NSG to Management Subnet

@description('Required. Resource Group name for Private DNS Zones.')
param priDNSZonesRgName string

@description('Required. Subnet name to be used for Private Endpoint.')
param peSubnetName string

@description('Required. Suffix to be used in resource naming with 4 characters.')
param suffix string

@description('Name of the resourceGroup, will be created in the same location as the deployment.')
param lzRgName string

@description('Location for the deployments and the resources')
param location string = deployment().location

@description('Required. Combine Tags in dynamoctags object with Tags from parameter file.')
param combinedTags object

@description('Required. Storage Account Name.')
param stgAcctName string

// From Parameters Files
@description('Required. Storage Account SKU.')
param storageaccount_sku string

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

@description('Required. The Virtual Network (vNet) Name.')
param vnetName string

@description('Required. An Array of 1 or more IP Address Prefixes for the Virtual Network.')
param vnetAddressPrefixes array

@description('Required. Hub - Network Security Groups Array.')
param networkSecurityGroups array

@description('Optional. An Array of subnets to deploy to the Virtual Network.')
param subnets array = []

@description('Optional. Virtual Network Peerings configurations')
param virtualNetworkPeerings array = []

@description('Required. Array of Private DNS Zones (Azure US Govrenment).')
param privateDnsZones array

@description('Required. Log Ananlytics Workspace Name for resource Diagnostics Settings - Log Collection.')
param logsLawName string

@description('Optional. List of gallerySolutions to be created in the Log Ananlytics Workspace for resource Diagnostics Settings - Log Collection.')
param logaGallerySolutions array = []

@description('Optional. The network access type for accessing Log Analytics ingestion.')
param publicNetworkAccessForIngestion string = ''

@description('Optional. The network access type for accessing Log Analytics query.')
param publicNetworkAccessForQuery string = ''

@description('Required. Azure Monitor Private Link Scope Name.')
param amplsName string

@description('Required. Name of the Key Vault. Must be globally unique.')
@maxLength(24)
param akvName string

@description('Optional. Whether or not public network access is allowed for this resource. For security reasons it should be disabled. If not specified, it will be disabled by default if private endpoints are set.')
@allowed([
  ''
  'Enabled'
  'Disabled'
])
param publicNetworkAccess string = ''

@description('Required. Array of role assignment objects to define RBAC on Resource Groups.')
param rgRoleAssignments array = []

// 1. Create Role Assignments for Subscriptions
module subRbac '../../modules/authorization/roleAssignments/subscription/deploy.bicep' = [ for (roleAssignment, i) in subRoleAssignments :{
  name: 'subscription-Rbac-${subscriptionId}-${i}'
  scope: subscription(subscriptionId)
  params: {
    location: location
    description: contains(roleAssignment, 'description') ? roleAssignment.description : ''
    principalIds: roleAssignment.principalIds
    principalType: contains(roleAssignment, 'principalType') ? roleAssignment.principalType : ''
    roleDefinitionIdOrName: roleAssignment.roleDefinitionIdOrName
    subscriptionId: subscriptionId
  }
}]

// 2. Create Role Assignments for Subscriptions
module rgRbac '../../modules/authorization/roleAssignments/resourceGroup/deploy.bicep' = [ for (roleAssignment, i) in rgRoleAssignments :{
  name: 'subscription-Rbac-${subscriptionId}-${i}'
  scope: resourceGroup(roleAssignment.subscriptionId, roleAssignment.resourceGroupName)
  params: {
    description: contains(roleAssignment, 'description') ? roleAssignment.description : ''
    principalIds: roleAssignment.principalIds
    principalType: contains(roleAssignment, 'principalType') ? roleAssignment.principalType : ''
    roleDefinitionIdOrName: roleAssignment.roleDefinitionIdOrName
    subscriptionId: roleAssignment.subscriptionId
    resourceGroupName: roleAssignment.resourceGroupName
  }
}]

// 3. Create Resoruce Group
module rg '../../modules/resourceGroups/deploy.bicep'= {
  name: 'rg-${take(uniqueString(deployment().name, location), 4)}-${lzRgName}'
  scope: subscription(subscriptionId)
  params: {
    name: lzRgName
    location: location
    tags: combinedTags
  }
}

// 4. Create Virtual Network
module lzVnet '../../modules/network/virtualNetworks/deploy.bicep' = {
  name: 'lzVnets-${take(uniqueString(deployment().name, location), 4)}-${vnetName}'
  scope: resourceGroup(subscriptionId, lzRgName)
  dependsOn: [
    rg
  ]
  params: {
    name: vnetName
    location: location
    tags: combinedTags
    addressPrefixes: vnetAddressPrefixes
    subnets: subnets
    virtualNetworkPeerings: virtualNetworkPeerings
    subscriptionId: subscriptionId
    diagnosticStorageAccountId: diagnosticStorageAccountId
    diagnosticWorkspaceId: diagnosticWorkspaceId
    //diagnosticEventHubAuthorizationRuleId: diagnosticEventHubAuthorizationRuleId
    //diagnosticEventHubName: diagnosticEventHubName
  }
}

// 5. Create Network Security Group(s)
module nsgs '../../modules/network/networkSecurityGroups/deploy.bicep' = [for (nsg, index) in networkSecurityGroups: {
  name: 'hubNsg-${take(uniqueString(deployment().name, location), 4)}-${nsg.name}'
  scope: resourceGroup(subscriptionId, lzRgName)
  dependsOn: [
    rg
  ]
  params: {
    name: nsg.name
    location: location
    tags: combinedTags
    securityRules: nsg.securityRules
    roleAssignments: nsg.roleAssignments
    diagnosticStorageAccountId: diagnosticStorageAccountId
    diagnosticWorkspaceId: diagnosticWorkspaceId
    //diagnosticEventHubAuthorizationRuleId: diagnosticEventHubAuthorizationRuleId
    //diagnosticEventHubName: diagnosticEventHubName
  }
}]

// 6. Attach NSG to Management Subnet
module attachNsgToMgmtSubnet '../../modules/network/virtualNetworks/subnets/deploy.bicep' = {
  name: 'attachNsgToMgmtSubnet-${mgmtSubnet.name}'
  scope: resourceGroup(subscriptionId, lzRgName)
  dependsOn: [
    nsgs
    lzVnet
  ]
  params: {
    name: mgmtSubnet.name
    virtualNetworkName: vnetName
    addressPrefix: mgmtSubnet.addressPrefix
    serviceEndpoints: mgmtSubnet.serviceEndpoints
    privateEndpointNetworkPolicies: mgmtSubnet.privateEndpointNetworkPolicies
    privateLinkServiceNetworkPolicies: mgmtSubnet.privateLinkServiceNetworkPolicies
    networkSecurityGroupId: resourceId(subscriptionId, lzRgName, 'Microsoft.Network/networkSecurityGroups', mgmgNsg)    
  }
}

// 7. Update Virtual Network Links on Provate DNS Zones
module vnetLinks '../../modules/network/privateDnsZones/virtualNetworkLinks/deploy.bicep' = [for privateDnsZone in privateDnsZones: {
  name: 'vnetLinks-${take(uniqueString(deployment().name, location), 4)}-${privateDnsZone}'
  scope: resourceGroup(connsubid, priDNSZonesRgName)
  dependsOn: [
    lzVnet
  ]
  params: {
    location: 'global'
    privateDnsZoneName: privateDnsZone
    virtualNetworkResourceId: lzVnet.outputs.resourceId
    tags: combinedTags
  }
}]

// 8. Create Storage Account
module sa '../../modules/storageAccounts/deploy.bicep' = {
  name: 'sa-${take(uniqueString(deployment().name, location), 4)}-${stgAcctName}'
  scope: resourceGroup(subscriptionId, lzRgName)
  dependsOn: [
    rg
  ]
  params: {
    storageAccountName: stgAcctName
    location: location
    tags: combinedTags
    storageSKU: storageaccount_sku
    publicNetworkAccess: 'Disabled'
    diagnosticSettingsName: diagSettingName
    diagnosticWorkspaceId: diagnosticWorkspaceId
    diagnosticEventHubAuthorizationRuleId: diagnosticEventHubAuthorizationRuleId
    diagnosticEventHubName: diagnosticEventHubName
  }
}

// 9. Create Private Endpoint for Storage Account
module saPe '../../modules/network/privateEndpoints/deploy.bicep' = {
  name: 'saPe-${take(uniqueString(deployment().name, location), 4)}-${stgAcctName}'
  scope: resourceGroup(subscriptionId, lzRgName)
  dependsOn: [
    sa
    lzVnet
  ]
  params: {
    name: '${stgAcctName}-blob-pe'
    location: location
    tags: combinedTags
    serviceResourceId: sa.outputs.resourceId
    groupIds: [
      'blob'
    ]
    subnetResourceId: resourceId(subscriptionId, lzRgName, 'Microsoft.Network/virtualNetworks/subnets', vnetName, peSubnetName)
    privateDnsZoneGroup: {
      privateDNSResourceIds: [
        resourceId(connsubid, priDNSZonesRgName, 'Microsoft.Network/privateDnsZones', 'privatelink.blob.core.usgovcloudapi.net')
      ]
    }
  }
}

// 10. Create Log Analytics Workspace
module loga '../../modules/operationalInsights/workspaces/deploy.bicep' = {
  name: 'loga-${take(uniqueString(deployment().name, location), 4)}-${logsLawName}'
  scope: resourceGroup(subscriptionId, lzRgName)
  dependsOn: [
    rg
  ]
  params:{
    name: logsLawName
    location: location
    tags: combinedTags
    gallerySolutions: logaGallerySolutions
    publicNetworkAccessForIngestion: publicNetworkAccessForIngestion
    publicNetworkAccessForQuery: publicNetworkAccessForQuery
  }
}

// 11. Add Log Analytics Workspace to Azure Monitor Private Link Scope (AMPLS)
module amplssr '../../modules//insights//privateLinkScopes/scopedResources/deploy.bicep' = {
  name: 'amplssr-${take(uniqueString(deployment().name, location), 4)}-${logsLawName}'
  scope: resourceGroup(connsubid, vnetRgName)
  dependsOn: [
    loga
  ]
  params: {
    linkedResourceId: loga.outputs.resourceId
    name: logsLawName
    privateLinkScopeName: amplsName
  }
}

// 12. Create Azure Key Vault
module akv '../../modules//keyVault/vaults/deploy.bicep' = {
  name: 'akv-${take(uniqueString(deployment().name, location), 4)}-${akvName}'
  scope: resourceGroup(subscriptionId, lzRgName)
  dependsOn: [
    rg
  ]
    params: {
      name: akvName
      location: location
      tags: combinedTags
      vaultSku: 'premium'
      publicNetworkAccess: publicNetworkAccess
    }
}

// 13. Create Private Endpoint for Key Vault
module akvPe '../../modules//network//privateEndpoints/deploy.bicep' = {
  name: 'akvPe-${take(uniqueString(deployment().name, location), 4)}-${akvName}'
  scope: resourceGroup(subscriptionId, lzRgName)
  dependsOn: [
    lzVnet
    akv
  ]
  params: {
    name: '${akvName}-vault-pe'
    location: location
    tags: combinedTags
    serviceResourceId: akv.outputs.resourceId
    groupIds: [
      'vault'
    ]
    subnetResourceId: resourceId(subscriptionId, lzRgName, 'Microsoft.Network/virtualNetworks/subnets', vnetName, peSubnetName)
    privateDnsZoneGroup: {
      privateDNSResourceIds: [
        resourceId(connsubid, priDNSZonesRgName, 'Microsoft.Network/privateDnsZones', 'privatelink.vaultcore.usgovcloudapi.net')
      ]
    }
  }
}

// 14. Configure Diagnostics Settings for Subscriptions
module subDiagSettings '../../modules/insights/diagnosticSettings/deploy.bicep' = {
  name: 'diagSettings-${subscriptionId}'
  scope: subscription(subscriptionId)
  dependsOn: [
    sa
    loga
  ]
  params:{
    name: '${diagSettingName}-${suffix}'
    diagnosticStorageAccountId: sa.outputs.resourceId
    diagnosticWorkspaceId: loga.outputs.resourceId
    //diagnosticEventHubAuthorizationRuleId: diagnosticEventHubAuthorizationRuleId
    //diagnosticEventHubName: diagnosticEventHubName
  }
}

@description('Output - Resoruce Group Name')
output rgName string = rg.outputs.name

@description('Output - Resoruce Group resourceId')
output rgResoruceId string = rg.outputs.resourceId

@description('Output - Storage Account resourceId')
output saResourceId string = sa.outputs.resourceId
