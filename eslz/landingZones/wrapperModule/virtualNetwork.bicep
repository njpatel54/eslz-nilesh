targetScope = 'managementGroup'

@description('subscriptionId for the deployment')
param subscriptionId string

@description('Location for the deployments and the resources')
param location string

@description('Required. Combine Tags in dynamoctags object with Tags from parameter file.')
param combinedTags object

@description('Required. Default Route Table name.')
param defaultRouteTableName string

@description('Optional. An Array of Routes to be established within the hub route table.')
param routes array

@description('Required. The Virtual Network (vNet) Name.')
param vnetName string

@description('Required. An Array of 1 or more IP Address Prefixes for the Virtual Network.')
param vnetAddressPrefixes array

@description('Optional. DNS Servers associated to the Virtual Network.')
param dnsServers array

@description('Required. Hub - Network Security Groups Array.')
param networkSecurityGroups array

@description('Optional. An Array of subnets to deploy to the Virtual Network.')
param subnets array = []

@description('Optional. Virtual Network Peerings configurations')
param virtualNetworkPeerings array = []

@description('Required. Array of Private DNS Zones (Azure US Govrenment).')
param privateDnsZones array

@description('Required. Name for the Diagnostics Setting Configuration.')
param diagSettingName string = ''

@description('Optional. Resource ID of the diagnostic log analytics workspace.')
param diagnosticWorkspaceId string = ''

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

// 1. Create Route Table (Connectivity Subscription)
module lzRouteTable '../../modules/network//routeTables/deploy.bicep' = {
  name: 'lzRouteTable-${take(uniqueString(deployment().name, location), 4)}-${defaultRouteTableName}'
  scope: resourceGroup(subscriptionId, vnetRgName)
  params: {
    name: defaultRouteTableName
    location: location
    tags: combinedTags
    routes: routes
  }
}

// 2. Create Virtual Network
module lzVnet '../../modules/network/virtualNetworks/deploy.bicep' = {
  name: 'lzVnet-${take(uniqueString(deployment().name, location), 4)}-${vnetName}'
  scope: resourceGroup(subscriptionId, vnetRgName)
  dependsOn: [
    lzRouteTable
  ]
  params: {
    name: vnetName
    location: location
    tags: combinedTags
    addressPrefixes: vnetAddressPrefixes
    dnsServers: dnsServers
    subnets: subnets
    virtualNetworkPeerings: virtualNetworkPeerings
    subscriptionId: subscriptionId
    diagnosticSettingsName: diagSettingName
    diagnosticWorkspaceId: diagnosticWorkspaceId
  }
}

// 3. Create Network Security Group(s)
module lzNsgs '../../modules/network/networkSecurityGroups/deploy.bicep' = [for (nsg, index) in networkSecurityGroups: {
  name: 'lzNsgs-${take(uniqueString(deployment().name, location), 4)}-${nsg.name}'
  scope: resourceGroup(subscriptionId, vnetRgName)
  dependsOn: [
    lzVnet
  ]
  params: {
    name: nsg.name
    location: location
    tags: combinedTags
    securityRules: nsg.securityRules
    roleAssignments: nsg.roleAssignments
    diagnosticSettingsName: diagSettingName
    diagnosticWorkspaceId: diagnosticWorkspaceId
  }
}]

// 4. Attach NSG & Route Table to Subnets
@batchSize(1)
module lzAttachNsgRouteTableToSubnets '../../modules/network/virtualNetworks/subnets/deploy.bicep' = [for (subnet, index) in subnets: {
  name: 'lzAttachNsgRouteTableToSubnets-${subnet.name}'
  scope: resourceGroup(subscriptionId, vnetRgName)
  dependsOn: [
    lzVnet
    lzNsgs
  ]
  params: {
    name: subnet.name
    virtualNetworkName: vnetName
    addressPrefix: subnet.addressPrefix
    serviceEndpoints: subnet.serviceEndpoints
    privateEndpointNetworkPolicies: subnet.privateEndpointNetworkPolicies
    privateLinkServiceNetworkPolicies: subnet.privateLinkServiceNetworkPolicies
    networkSecurityGroupId: resourceId(subscriptionId, vnetRgName, 'Microsoft.Network/networkSecurityGroups', bastionNsg)
    routeTableId: resourceId(subscriptionId, vnetRgName, 'Microsoft.Network/routeTables', defaultRouteTableName)
  }
}]



/*
@description('Required. Iterate over each "spokeVnets" and build "resourceId" of each Virtual Networks using "subscriptionId", "vnetRgName" and "vNet.name".')
var vNetResourceIds = [for vNet in params.parameters.vNets.value: resourceId(subscriptionId, vnetRgName, 'Microsoft.Network/virtualNetworks', vNet.name)]

// 5. Update Virtual Network Links on Provate DNS Zones
module priDNSZones 'virtualNetworkLinks.bicep' = [for (vNetResourceId, i) in vNetResourceIds: {
  name: 'lzVnetLinks-${take(uniqueString(deployment().name, location), 4)}-${i}'
  scope: resourceGroup(connsubid, priDNSZonesRgName)
  dependsOn: [
    lzAttachNsgRouteTableToSubnets
  ]
  params: {
    virtualNetworkResourceId: vNetResourceId
    combinedTags: combinedTags
    connsubid: connsubid
    priDNSZonesRgName: priDNSZonesRgName
    privateDnsZones: privateDnsZones
  }
}]

// 5. Update Virtual Network Links on Provate DNS Zones
module lzVnetLinks '../../modules/network/privateDnsZones/virtualNetworkLinks/deploy.bicep' = [for privateDnsZone in privateDnsZones: {
  name: 'lzVnetLinks-${take(uniqueString(deployment().name, location), 4)}-${privateDnsZone}'
  scope: resourceGroup(connsubid, priDNSZonesRgName)
  dependsOn: [
    lzAttachNsgRouteTableToSubnets
  ]
  params: {
    privateDnsZoneName: privateDnsZone
    location: 'global'
    tags: combinedTags
    virtualNetworkResourceId: lzVnet.outputs.resourceId
  }
}]
*/

@description('Output - Virtual Network "name"')
output vNetName string = lzVnet.outputs.name

@description('Output - Virtual Network "resoruceId"')
output vNetResoruceId string = lzVnet.outputs.resourceId

@description('Output - Subnets "name" Array')
output subnetNames array = lzVnet.outputs.subnetNames

@description('Output - Subnets "resoruceId" Array')
output subnetResourceIds array = lzVnet.outputs.subnetResourceIds

@description('Output - NSG "name" Array')
output nsgsNames array = [for (nsg, index) in networkSecurityGroups: {
  name: lzNsgs[index].outputs.name
}]

@description('Output - NSG "resoruceId" Array')
output nsgsResourceIds array = [for (nsg, index) in networkSecurityGroups: {
  resoruceId: lzNsgs[index].outputs.resourceId
}]
