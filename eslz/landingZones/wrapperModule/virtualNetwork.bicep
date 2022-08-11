@description('subscriptionId for the deployment')
param subscriptionId string

@description('Location for the deployments and the resources')
param location string

@description('Required. Combine Tags in dynamoctags object with Tags from parameter file.')
param combinedTags object

@description('Required. The Virtual Network (vNet) Name.')
param vnetName string

@description('Required. An Array of 1 or more IP Address Prefixes for the Virtual Network.')
param vnetAddressPrefixes array

@description('Required. Hub - Network Security Groups Array.')
param networkSecurityGroups array

@description('Optional. An Array of subnets to deploy to the Virtual Network.')
param subnets array = []

@description('Optional. Virtual Network Peerings configurations')
param virtualNetworkPeerings array = []

@description('Required. Array of Private DNS Zones (Azure US Govrenment).')
param privateDnsZones array

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

@description('Required. Subscription ID of Connectivity Subscription')
param connsubid string

@description('Required. Resource Group name for Private DNS Zones.')
param priDNSZonesRgName string

@description('Required. Resource Group name.')
param vnetRgName string

// Start - Variables created to be used to attach NSG to Management Subnet
var params = json(loadTextContent('../.parameters/parameters.json'))

@description('Required. Iterate over each "networkSecurityGroups" and build variable to store NSG for Managemet Subnet.')
var bastionNsg = params.parameters.networkSecurityGroups.value[0].name
// End - Variables created to be used to attach NSG to Management Subnet

// 1. Create Virtual Network
module lzVnet '../../modules/network/virtualNetworks/deploy.bicep' = {
  name: 'lzVnets-${take(uniqueString(deployment().name, location), 4)}-${vnetName}'
  //scope: resourceGroup(subscriptionId, vnetRgName)
  params: {
    name: vnetName
    location: location
    tags: combinedTags
    addressPrefixes: vnetAddressPrefixes
    subnets: subnets
    virtualNetworkPeerings: virtualNetworkPeerings
    subscriptionId: subscriptionId
    diagnosticSettingsName: diagSettingName
    diagnosticStorageAccountId: diagnosticStorageAccountId
    diagnosticWorkspaceId: diagnosticWorkspaceId
    //diagnosticEventHubAuthorizationRuleId: diagnosticEventHubAuthorizationRuleId
    //diagnosticEventHubName: diagnosticEventHubName
  }
}

// 2. Create Network Security Group(s)
module nsgs '../../modules/network/networkSecurityGroups/deploy.bicep' = [for (nsg, index) in networkSecurityGroups: {
  name: 'hubNsg-${take(uniqueString(deployment().name, location), 4)}-${nsg.name}'
  dependsOn: [
    lzVnet
  ]
  //scope: resourceGroup(subscriptionId, vnetRgName)
  params: {
    name: nsg.name
    location: location
    tags: combinedTags
    securityRules: nsg.securityRules
    roleAssignments: nsg.roleAssignments
    diagnosticSettingsName: diagSettingName
    diagnosticStorageAccountId: diagnosticStorageAccountId
    diagnosticWorkspaceId: diagnosticWorkspaceId
    //diagnosticEventHubAuthorizationRuleId: diagnosticEventHubAuthorizationRuleId
    //diagnosticEventHubName: diagnosticEventHubName
  }
}]

// 3. Attach NSG to Subnets
module attachNsgToSubnets '../../modules/network/virtualNetworks/subnets/deploy.bicep' = [for (subnet, index) in subnets: {
  name: 'attachNsgToSubnets-${subnet.name}'
  //scope: resourceGroup(subscriptionId, vnetRgName)
  dependsOn: [
    lzVnet
    nsgs
  ]
  params: {
    name: subnet.name
    virtualNetworkName: vnetName
    addressPrefix: subnet.addressPrefix
    serviceEndpoints: subnet.serviceEndpoints
    privateEndpointNetworkPolicies: subnet.privateEndpointNetworkPolicies
    privateLinkServiceNetworkPolicies: subnet.privateLinkServiceNetworkPolicies
    networkSecurityGroupId: resourceId(subscriptionId, vnetRgName, 'Microsoft.Network/networkSecurityGroups', bastionNsg)    
  }
}]

// 4. Update Virtual Network Links on Provate DNS Zones
module vnetLinks '../../modules/network/privateDnsZones/virtualNetworkLinks/deploy.bicep' = [for privateDnsZone in privateDnsZones: {
  name: 'vnetLinks-${take(uniqueString(deployment().name, location), 4)}-${privateDnsZone}'
  scope: resourceGroup(connsubid, priDNSZonesRgName)
  dependsOn: [
    attachNsgToSubnets
  ]
  params: {
    location: 'global'
    privateDnsZoneName: privateDnsZone
    virtualNetworkResourceId: lzVnet.outputs.resourceId
    tags: combinedTags
  }
}]
