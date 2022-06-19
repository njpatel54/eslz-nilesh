//targetScope = 'subscription'

param subscriptionId string
param resourceGroupName string

@description('Required. Name for the Event Hub Namespace.')
param name string

@description('Required. An Array of 1 or more IP Address Prefixes for the Virtual Network.')
param addressPrefixes array

@description('Optional. An Array of subnets to deploy to the Virtual Network.')
param subnets array = []

@description('Optional. DNS Servers associated to the Virtual Network.')
param dnsServers array = []

@description('Optional. Resource ID of the DDoS protection plan to assign the VNET to. If it\'s left blank, DDoS protection will not be configured. If it\'s provided, the VNET created by this template will be attached to the referenced DDoS protection plan. The DDoS protection plan can exist in the same or in a different subscription.')
param ddosProtectionPlanId string = ''

@description('Optional. Virtual Network Peerings configurations')
param virtualNetworkPeerings array = []

@description('Required. Location for all resources.')
param location string

/*
// Create Resoruce Group
module rg './resourceGroups/deploy.bicep'= {
  name: 'rg-${uniqueString(deployment().name, location)}'
  scope: subscription(subscriptionId)
  params: {
    name: rgName
    location: location
    tags: combinedTags
  }
}
*/

// Create Virtual Network
module vnet './virtualNetworks/deploy.bicep' = {
  name: 'vnet-${uniqueString(deployment().name, location)}-${name}'
  scope: resourceGroup(subscriptionId, resourceGroupName)
  params:{
    location: location
    addressPrefixes: addressPrefixes
    name: name
    subnets: subnets
    dnsServers: dnsServers
    ddosProtectionPlanId: ddosProtectionPlanId
    virtualNetworkPeerings: virtualNetworkPeerings
  }
}

