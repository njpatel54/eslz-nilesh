targetScope = 'managementGroup'

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

@description('Optional. Blob service and containers to deploy')
param blobServices object

@description('Optional. File service and shares to deploy')
param fileServices object

@description('Optional. Queue service and queues to create.')
param queueServices object

@description('Optional. Table service and tables to create.')
param tableServices object

@description('Required. Name of the resourceGroup, where networking components will be.')
param vnetRgName string

@description('Required. Virtual Network name in Landing Zone Subscription.')
param vnetName string

@description('Required. Subnet name to be used for Private Endpoint.')
param mgmtSubnetName string

@description('Required. Subscription ID of Connectivity Subscription')
param connsubid string

@description('Required. Resource Group name for Private DNS Zones.')
param priDNSZonesRgName string

@description('Required. Name for the Diagnostics Setting Configuration.')
param diagSettingName string = ''

@description('Optional. Resource ID of the diagnostic log analytics workspace.')
param diagnosticWorkspaceId string = ''

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

// 1. Create Storage Account - Landing Zone Subscription
module sa '../../modules/storageAccounts/deploy.bicep' = {
  name: 'sa-${take(uniqueString(deployment().name, location), 4)}-${stgAcctName}'
  scope: resourceGroup(subscriptionId, wlRgName)
  params: {
    storageAccountName: stgAcctName
    location: location
    tags: combinedTags
    storageSKU: storageaccount_sku
    blobServices: blobServices
    fileServices: fileServices
    queueServices: queueServices
    tableServices: tableServices
    publicNetworkAccess: 'Disabled'
    diagnosticSettingsName: diagSettingName
    diagnosticWorkspaceId: diagnosticWorkspaceId
  }
}

// 2. Create Private Endpoint for Storage Account - Landing Zone Subscription
module saPe '../../modules/network/privateEndpoints/deploy.bicep' = [for (stgGroupId, index) in stgGroupIds: if (!empty(stgGroupIds)) {
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
    subnetResourceId: resourceId(subscriptionId, vnetRgName, 'Microsoft.Network/virtualNetworks/subnets', vnetName, mgmtSubnetName)
    privateDnsZoneGroup: {
      privateDNSResourceIds: [
        resourceId(connsubid, priDNSZonesRgName, 'Microsoft.Network/privateDnsZones', contains(groupIds, stgGroupId) ? groupIds[stgGroupId] : '')
      ]
    }
  }
}]

/*
// 3. Create Azure File Share
module fileShare '../../modules/storageAccounts/fileServices/shares/deploy.bicep' = {
  scope: 
  name: 
  params: {
    name: 
    storageAccountName: 
  }
}
*/

// 4. Create Private Endpoint for Storage Account - Shared Services Subscription
@description('Output - Storage Account "name"')
output saName string = sa.outputs.name

@description('Output - Storage Account "resoruceId"')
output saResoruceId string = sa.outputs.resourceId
