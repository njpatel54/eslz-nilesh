targetScope = 'managementGroup'

@description('subscriptionId for the deployment')
param subscriptionId string

@description('Location for the deployments and the resources')
param location string

@description('Required. Combine Tags in dynamoctags object with Tags from parameter file.')
param combinedTags object

@description('Required. Name of the Key Vault. Must be globally unique.')
@maxLength(24)
param akvName string

@description('Optional. Whether or not public network access is allowed for this resource. For security reasons it should be disabled. If not specified, it will be disabled by default if private endpoints are set.')
@allowed([
  ''
  'Enabled'
  'Disabled'
])
param publicNetworkAccess string

@description('Optional. Service endpoint object information. For security reasons, it is recommended to set the DefaultAction Deny.')
param networkAcls object

@description('Required. Name of the resourceGroup, where application workload will be deployed.')
param wlRgName string

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

// 1. Create Azure Key Vault
module akv '../../modules/keyVault/vaults/deploy.bicep' = {
  name: 'akv-${take(uniqueString(deployment().name, location), 4)}-${akvName}'
  scope: resourceGroup(subscriptionId, wlRgName)
  params: {
    name: akvName
    location: location
    tags: combinedTags
    vaultSku: 'premium'
    publicNetworkAccess: publicNetworkAccess
    networkAcls: networkAcls
    diagnosticSettingsName: diagSettingName
    diagnosticWorkspaceId: diagnosticWorkspaceId
  }
}

// 2. Create Private Endpoint for Key Vault
module akvPe '../../modules/network/privateEndpoints/deploy.bicep' = {
  name: 'akvPe-${take(uniqueString(deployment().name, location), 4)}-${akvName}'
  scope: resourceGroup(subscriptionId, wlRgName)
  dependsOn: [
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
    subnetResourceId: resourceId(subscriptionId, vnetRgName, 'Microsoft.Network/virtualNetworks/subnets', vnetName, mgmtSubnetName)
    privateDnsZoneGroup: {
      privateDNSResourceIds: [
        resourceId(connsubid, priDNSZonesRgName, 'Microsoft.Network/privateDnsZones', 'privatelink.vaultcore.usgovcloudapi.net')
      ]
    }
  }
}

@description('Output - Log Analytics Workspace "name"')
output akvName string = akv.outputs.name

@description('Output - Log Analytics Workspace "resoruceId"')
output akvResoruceId string = akv.outputs.resourceId

@description('Output - Log Analytics Workspace "resoruceId"')
output akvUri string = akv.outputs.uri
