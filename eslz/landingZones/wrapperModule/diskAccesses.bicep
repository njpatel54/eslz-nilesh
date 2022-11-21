targetScope = 'managementGroup'

@description('subscriptionId for the deployment')
param subscriptionId string

@description('Location for the deployments and the resources')
param location string

@description('Required. Combine Tags in dynamoctags object with Tags from parameter file.')
param combinedTags object

@description('Required. Name of the Disk Accesses resource. Must be globally unique.')
param name string

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

// 1. Create Disk Access Resoruce
module diskAccess '../../modules/compute/diskAccesses/deploy.bicep' = {
  name: 'diskAccess-${take(uniqueString(deployment().name, location), 4)}-${name}'
  scope: resourceGroup(subscriptionId, wlRgName)
  params: {
    name: name
    location: location
    tags: combinedTags
  }
}

// 2. Create Private Endpoint for Disk Access Resource
module diskAccessPe '../../modules/network/privateEndpoints/deploy.bicep' = {
  name: 'diskAccessPe-${take(uniqueString(deployment().name, location), 4)}-${name}'
  scope: resourceGroup(subscriptionId, wlRgName)
  dependsOn: [
    diskAccess
  ]
  params: {
    name: '${name}-disks-pe'
    location: location
    tags: combinedTags
    serviceResourceId: diskAccess.outputs.resourceId
    groupIds: [
      'disks'
    ]
    subnetResourceId: resourceId(subscriptionId, vnetRgName, 'Microsoft.Network/virtualNetworks/subnets', vnetName, mgmtSubnetName)
    privateDnsZoneGroup: {
      privateDNSResourceIds: [
        resourceId(connsubid, priDNSZonesRgName, 'Microsoft.Network/privateDnsZones', 'privatelink.blob.core.usgovcloudapi.net')
      ]
    }
  }
}

@description('Output - Disk Access resource "name"')
output diskAccessName string = diskAccess.outputs.name

@description('Output - Disk Access resource "resoruceId"')
output diskAccessResoruceId string = diskAccess.outputs.resourceId
