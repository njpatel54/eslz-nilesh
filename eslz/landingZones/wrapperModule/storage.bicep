@description('subscriptionId for the deployment')
param subscriptionId string

@description('Location for the deployments and the resources')
param location string

@description('Required. Combine Tags in dynamoctags object with Tags from parameter file.')
param combinedTags object

@description('Required. Name of the resourceGroup, where application workload will be deployed.')
param wlRgName string

@description('Required. Storage Account Name for resource Diagnostics Settings - Log Collection.')
param stgAcctName string

@description('Required. Storage Account SKU.')
param storageaccount_sku string

@description('Required. Name of the resourceGroup, where networking components will be.')
param vnetRgName string

@description('Required. Virtual Network name in Management Subscription.')
param mgmtVnetName string

@description('Required. Subnet name to be used for Private Endpoint.')
param peSubnetName string

@description('Required. Subscription ID of Connectivity Subscription')
param connsubid string

@description('Required. Resource Group name for Private DNS Zones.')
param priDNSZonesRgName string

@description('Required. Name for the Diagnostics Setting Configuration.')
param diagSettingName string

@description('Optional. Resource ID of the diagnostic log analytics workspace.')
param diagnosticWorkspaceId string = ''

@description('Optional. Resource ID of the diagnostic event hub authorization rule for the Event Hubs namespace in which the event hub should be created or streamed to.')
param diagnosticEventHubAuthorizationRuleId string = ''

@description('Optional. Name of the diagnostic event hub within the namespace to which logs are streamed. Without this, an event hub is created for each log category.')
param diagnosticEventHubName string = ''

param stgGroupIds array

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

// 1. Create Storage Account
module sa '../../modules/storageAccounts/deploy.bicep' = {
  name: 'sa-${take(uniqueString(deployment().name, location), 4)}-${stgAcctName}'
  scope: resourceGroup(subscriptionId, wlRgName)
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

// 2. Create Private Endpoint for Storage Account
module saPe '../../modules/network/privateEndpoints/deploy.bicep' = [for (stgGroupId, index) in stgGroupIds: {
  name: 'saPe-${take(uniqueString(deployment().name, location), 4)}-${stgAcctName}-${stgGroupId}'
  scope: resourceGroup(subscriptionId, wlRgName)
  dependsOn: [
    sa
  ]
  params: {
    name: '${stgAcctName}-${stgGroupId}-pe'
    location: location
    tags: combinedTags
    serviceResourceId: sa.outputs.resourceId
    groupIds: [
      stgGroupId
    ]
    subnetResourceId: resourceId(subscriptionId, vnetRgName, 'Microsoft.Network/virtualNetworks/subnets', mgmtVnetName, peSubnetName)
    privateDnsZoneGroup: {
      privateDNSResourceIds: [
        resourceId(connsubid, priDNSZonesRgName, 'Microsoft.Network/privateDnsZones', contains(groupIds, stgGroupId) ? groupIds[stgGroupId] : '')
      ]
    }
  }
}]


/*
// 2. Create Private Endpoint for Storage Account
module saPe '../../modules/network/privateEndpoints/deploy.bicep' = {
  name: 'saPe-${take(uniqueString(deployment().name, location), 4)}-${stgAcctName}'
  scope: resourceGroup(subscriptionId, wlRgName)
  params: {
    name: '${stgAcctName}-blob-pe'
    location: location
    tags: combinedTags
    serviceResourceId: sa.outputs.resourceId
    groupIds: [
      'blob'
    ]
    subnetResourceId: resourceId(subscriptionId, vnetRgName, 'Microsoft.Network/virtualNetworks/subnets', mgmtVnetName, peSubnetName)
    privateDnsZoneGroup: {
      privateDNSResourceIds: [
        resourceId(connsubid, priDNSZonesRgName, 'Microsoft.Network/privateDnsZones', 'privatelink.blob.core.usgovcloudapi.net')
      ]
    }
  }
}
*/
