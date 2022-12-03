
@description('Required. Combine Tags in dynamoctags object with Tags from parameter file.')
param combinedTags object

@description('Required. Subscription ID of Connectivity Subscription')
param connsubid string

@description('Required. Resource Group name for Private DNS Zones.')
param priDNSZonesRgName string

@description('Required. Array of Private DNS Zones (Azure US Govrenment).')
param privateDnsZones array

@description('Required. Link to another virtual network resource ID.')
param virtualNetworkResourceId string

// 1. Update Virtual Network Links on Provate DNS Zones
module lzVnetLinks '../../modules/network/privateDnsZones/virtualNetworkLinks/deploy.bicep' = [for privateDnsZone in privateDnsZones: {
  name: 'lzVnetLinks-${take(uniqueString(deployment().name), 4)}-${privateDnsZone}'
  scope: resourceGroup(connsubid, priDNSZonesRgName)
  params: {
    privateDnsZoneName: privateDnsZone
    location: 'global'
    tags: combinedTags
    virtualNetworkResourceId: virtualNetworkResourceId
  }
}]
