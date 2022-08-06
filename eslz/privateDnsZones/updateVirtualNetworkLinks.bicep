
targetScope = 'subscription'

@description('Required. Project Owner (projowner) parameter.')
@allowed([
  'ccs'
  'proj'
])
param projowner string = 'ccs'

@description('Required. Operational Scope (opscope) parameter.')
@allowed([
  'prod'
  'dev'
  'qa'
  'stage'
  'test'
  'sand'
])
param opscope string = 'prod'

@description('Required. Region (region) parameter.')
@allowed([
  'usva'
  'ustx'
  'usaz'
])
param region string = 'usva'

@description('Required. Resource Group name.')
param priDNSZonesRgName string = 'rg-${projowner}-${opscope}-${region}-dnsz'

@description('Required. Load content from json file.')
var vNets = json(loadTextContent('../platformVNets/.parameters/parameters.json'))

param privateDnsZones array

module vNetLink '../modules//network/privateDnsZones/virtualNetworkLinks/deploy.bicep' = [for privateDnsZone in privateDnsZones: {
  name: 'vNetLink-${privateDnsZone}'
  scope: resourceGroup(vNets.parameters.hubVnetSubscriptionId.value, priDNSZonesRgName)
  params: {
    privateDnsZoneName: privateDnsZone
    virtualNetworkResourceId: '/subscriptions/df3b1809-17d0-47a0-9241-d2724780bdac/resourceGroups/contoso-az-rg-x-001/providers/Microsoft.Network/virtualNetworks/contoso-vnet'
    location: 'Global'
  }
}]
