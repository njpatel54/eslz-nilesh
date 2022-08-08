targetScope = 'managementGroup'

@description('subscriptionId for the deployment')
param subscriptionId string

@description('Required. Array of role assignment objects to define RBAC on subscriptions.')
param subRoleAssignments array = []

@description('Required. Subscription ID of Connectivity Subscription')
param connsubscriptionid string

@description('Required. Resource Group name for Private DNS Zones.')
param priDNSZonesRgName string

@description('Required. Subnet name to be used for Private Endpoint.')
param peSubnetName string

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

@description('Optional. An Array of subnets to deploy to the Virtual Network.')
param subnets array = []

@description('Optional. Virtual Network Peerings configurations')
param virtualNetworkPeerings array = []

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

// 2. Configure Diagnostics Settings for Subscriptions
module subDiagSettings '../../modules/insights/diagnosticSettings/deploy.bicep' = {
  name: 'diagSettings-${subscriptionId}'
  scope: subscription(subscriptionId)
  params:{
    name: diagSettingName
    diagnosticStorageAccountId: diagnosticStorageAccountId
    diagnosticWorkspaceId: diagnosticWorkspaceId
    //diagnosticEventHubAuthorizationRuleId: diagnosticEventHubAuthorizationRuleId
    //diagnosticEventHubName: diagnosticEventHubName
  }
}

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

// 4. Create Spoke Virtual Network(s)
module lzVnets '../../modules/network/virtualNetworks/deploy.bicep' = {
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

// 6. Create Storage Account
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

// 7. Create Private Endpoint for Storage Account
module saPe '../../modules/network/privateEndpoints/deploy.bicep' = {
  name: 'saPe-${take(uniqueString(deployment().name, location), 4)}-${stgAcctName}'
  scope: resourceGroup(subscriptionId, lzRgName)
  dependsOn: [
    sa
    lzVnets
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
        resourceId(connsubscriptionid, priDNSZonesRgName, 'Microsoft.Network/privateDnsZones', 'privatelink.blob.core.usgovcloudapi.net')
      ]
    }
  }
}

@description('Output - Resoruce Group Name')
output rgName string = rg.outputs.name

@description('Output - Resoruce Group resourceId')
output rgResoruceId string = rg.outputs.resourceId

@description('Output - Storage Account resourceId')
output saResourceId string = sa.outputs.resourceId
