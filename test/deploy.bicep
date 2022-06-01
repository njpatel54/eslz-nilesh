
@description('Optional. Hub Virtual Network configurations.')
param hubVirtualNetwork array = []

@description('Optional. Hub Virtual Network configurations.')
param spokeVirtualNetworks array = []

@description('Required. The Virtual Network (vNet) Name.')
param addressPrefixes array = []

@description('Required. The Virtual Network (vNet) Name.')
param name string = 'test'

@description('Optional. Location for all resources.')
param location string = resourceGroup().location

module hubVnet './virtualNetworks/deploy.bicep' = [ for (virtualNetwork, index) in hubVirtualNetwork : {
  name: '${virtualNetwork.name}-VNet-Module-${index}'
  scope: resourceGroup(virtualNetwork.subscriptionId, virtualNetwork.resourceGroupName)
  params: {
    name: virtualNetwork.name
    location: location
    addressPrefixes: virtualNetwork.addressPrefixes
    //ddosProtectionPlanId: !empty(virtualNetwork.ddosProtectionPlanId) ? virtualNetwork.ddosProtectionPlanId : null
    //dnsServers: !empty(virtualNetwork.dnsServers) ? virtualNetwork.dnsServers : null
    subnets: [for subnet in virtualNetwork.subnets: {
      name: subnet.name
      addressPrefix: subnet.addressPrefix
      addressPrefixes: contains(subnet, 'addressPrefixes') ? subnet.addressPrefixes : []
      applicationGatewayIpConfigurations: contains(subnet, 'applicationGatewayIpConfigurations') ? subnet.applicationGatewayIpConfigurations : []
      delegations: contains(subnet, 'delegations') ? subnet.delegations : []
      ipAllocations: contains(subnet, 'ipAllocations') ? subnet.ipAllocations : []
      natGateway: contains(subnet, 'natGatewayId') ? {
        'id': subnet.natGatewayId
      } : json('null')
      networkSecurityGroup: contains(subnet, 'networkSecurityGroupId') ? {
        'id': subnet.networkSecurityGroupId
      } : json('null')
      privateEndpointNetworkPolicies: contains(subnet, 'privateEndpointNetworkPolicies') ? subnet.privateEndpointNetworkPolicies : null
      privateLinkServiceNetworkPolicies: contains(subnet, 'privateLinkServiceNetworkPolicies') ? subnet.privateLinkServiceNetworkPolicies : null
      routeTable: contains(subnet, 'routeTableId') ? {
        'id': subnet.routeTableId
      } : json('null')
      serviceEndpoints: contains(subnet, 'serviceEndpoints') ? subnet.serviceEndpoints : []
      serviceEndpointPolicies: contains(subnet, 'serviceEndpointPolicies') ? subnet.serviceEndpointPolicies : []
      }]
  }
}]


module spokeVnet './virtualNetworks/deploy.bicep' = {
  name: 'SpokeVNet-Module'
  scope: resourceGroup('test')
  params: {
    name: hubVnet.
    location: location
    addressPrefixes: addressPrefixes
    }
  }

















module spokeVnets 'virtualNetworks/deploy.bicep' = [ for (spokeVirtualNetwork, index) in spokeVirtualNetworks : {
  name: '${spokeVirtualNetwork.name}-VNet-Module-${index}'
  scope: resourceGroup(spokeVirtualNetwork.subscriptionId, spokeVirtualNetwork.resourceGroupName)
  params: {
    name: hub                   //spokeVirtualNetwork.name
    location: location
    addressPrefixes: spokeVirtualNetwork.addressPrefixes
    //ddosProtectionPlanId: !empty(spokeVirtualNetwork.ddosProtectionPlanId) ? spokeVirtualNetwork.ddosProtectionPlanId : null
    //dnsServers: !empty(spokeVirtualNetwork.dnsServers) ? spokeVirtualNetwork.dnsServers : null
    subnets: [for subnet in spokeVirtualNetwork.subnets: {
      name: subnet.name
      addressPrefix: subnet.addressPrefix
      addressPrefixes: contains(subnet, 'addressPrefixes') ? subnet.addressPrefixes : []
      applicationGatewayIpConfigurations: contains(subnet, 'applicationGatewayIpConfigurations') ? subnet.applicationGatewayIpConfigurations : []
      delegations: contains(subnet, 'delegations') ? subnet.delegations : []
      ipAllocations: contains(subnet, 'ipAllocations') ? subnet.ipAllocations : []
      natGateway: contains(subnet, 'natGatewayId') ? {
        'id': subnet.natGatewayId
      } : json('null')
      networkSecurityGroup: contains(subnet, 'networkSecurityGroupId') ? {
        'id': subnet.networkSecurityGroupId
      } : json('null')
      privateEndpointNetworkPolicies: contains(subnet, 'privateEndpointNetworkPolicies') ? subnet.privateEndpointNetworkPolicies : null
      privateLinkServiceNetworkPolicies: contains(subnet, 'privateLinkServiceNetworkPolicies') ? subnet.privateLinkServiceNetworkPolicies : null
      routeTable: contains(subnet, 'routeTableId') ? {
        'id': subnet.routeTableId
      } : json('null')
      serviceEndpoints: contains(subnet, 'serviceEndpoints') ? subnet.serviceEndpoints : []
      serviceEndpointPolicies: contains(subnet, 'serviceEndpointPolicies') ? subnet.serviceEndpointPolicies : []
      }]
  }
}]
