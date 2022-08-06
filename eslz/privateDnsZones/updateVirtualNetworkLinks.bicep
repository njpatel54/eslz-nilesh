
param privateDnsZones array

module vNetLink '../modules//network/privateDnsZones/virtualNetworkLinks/deploy.bicep' = [for privateDnsZone in privateDnsZones: {
  name: 'vNetLink-${privateDnsZone}'
  params: {
    privateDnsZoneName: privateDnsZone
    virtualNetworkResourceId: '/subscriptions/df3b1809-17d0-47a0-9241-d2724780bdac/resourceGroups/contoso-az-rg-x-001/providers/Microsoft.Network/virtualNetworks/contoso-vnet'
    location: 'Global'
  }
}]
