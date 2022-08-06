targetScope = 'subscription'

@description('Required. Location for all resources.')
param location string

@description('Required. Resource Group name.')
param resourceGroupName string = 'rg-${projowner}-${opscope}-${region}-vnet'

@description('Required. utcfullvalue to be used in Tags.')
param utcfullvalue string = utcNow('F')

@description('Required. Assign utffullvaule to "CreatedOn" tag.')
param dynamictags object = ({
  CreatedOn: utcfullvalue
})

var tags = json(loadTextContent('../tags.json'))

@description('Required. Combine Tags in dynamoctags object with Tags from parameter file.')
var ccsCombinedTags = union(dynamictags, tags.ccsTags.value)

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

// Create PrivateDNSZones
@description('Required. Resource Group name.')
param priDNSZonesRgName string = 'rg-${projowner}-${opscope}-${region}-dnsz'

@description('Required. Load content from json file.')
var vNets = json(loadTextContent('../platformVNets/.parameters/parameters.json'))

// Variables created to be used as 'virtualNetworkLinks' for Private DNS Zone(s)
@description('Required. Iterate over each "spokeVnets" and build "resourceId" of each Virtual Networks using "subscriptionId", "resourceGroupName" and "vNet.name".')
var spokeVNetsResourceIds = [for vNet in vNets.parameters.spokeVnets.value: resourceId(vNet.subscriptionId, resourceGroupName, 'Microsoft.Network/virtualNetworks', vNet.name)]

@description('Required. Build "resourceId" of Hub Virtual Network using "hubVnetSubscriptionId", "resourceGroupName" and "hubVnetName".')
var hubVNetResourceId = [resourceId(vNets.parameters.hubVnetSubscriptionId.value, resourceGroupName, 'Microsoft.Network/virtualNetworks', vNets.parameters.hubVnetName.value)]

@description('Required. Combine two varibales using "union" function.')
var vNetResourceIds = union(hubVNetResourceId, spokeVNetsResourceIds)

param privateDnsZones array

// 1 - Create Resource Group
module testPriDNSZonesRg '../modules/resourceGroups/deploy.bicep'= {
  name: 'rg-${vNets.parameters.hubVnetSubscriptionId.value}-${priDNSZonesRgName}'
  scope: subscription(vNets.parameters.hubVnetSubscriptionId.value)
  params: {
    name: priDNSZonesRgName
    location: location
    tags: ccsCombinedTags
  }
}

// 2 - Create Private DNS Zones
module testPriDNSZones '../modules/network/privateDnsZones/deploy.bicep' = [for privateDnsZone in privateDnsZones: {
  name: 'testPriDNSZones-${privateDnsZone}'
  scope: resourceGroup(vNets.parameters.hubVnetSubscriptionId.value, priDNSZonesRgName)
  dependsOn: [
    testPriDNSZonesRg
  ]
  params: {
    name: privateDnsZone
    location: 'Global'
    tags: ccsCombinedTags
    virtualNetworkLinks: [for vNetResourceId in vNetResourceIds: {
      virtualNetworkResourceId: vNetResourceId
      registrationEnabled: false
    }]
  }
}]
