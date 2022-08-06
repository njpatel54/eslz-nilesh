// Start - Copied from deploy.bicep
targetScope = 'subscription'

@description('Required. utcfullvalue to be used in Tags.')
param utcfullvalue string = utcNow('F')

@description('Required. Assign utffullvaule to "CreatedOn" tag.')
param dynamictags object = ({
  CreatedOn: utcfullvalue
})

var tags = json(loadTextContent('../tags.json'))

@description('Required. Combine Tags in dynamoctags object with Tags from parameter file.')
var ccsCombinedTags = union(dynamictags, tags.ccsTags.value)
//var lzCombinedTags = union(dynamictags, tags.lz01Tags.value)

@description('Required. Project Owner (projowner) parameter.')
@allowed([
  'ccs'
  'proj'
])
param projowner string

@description('Required. Operational Scope (opscope) parameter.')
@allowed([
  'prod'
  'dev'
  'qa'
  'stage'
  'test'
  'sand'
])
param opscope string

@description('Required. Region (region) parameter.')
@allowed([
  'usva'
  'ustx'
  'usaz'
])
param region string

@description('Required. Location for all resources.')
param location string

@description('Required. Resource Group name.')
param resourceGroupName string = 'rg-${projowner}-${opscope}-${region}-vnet'

@description('Required. Subscription ID of Management Subscription.')
param mgmtsubid string

@description('Required. SIEM Resource Group Name.')
param rgName string = 'rg-${projowner}-${opscope}-${region}-siem'
/*
@description('Required. Log Ananlytics Workspace Name for Azure Sentinel.')
param sentinelLawName string = 'log-${projowner}-${opscope}-${region}-siem'

@description('Required. Log Ananlytics Workspace Name for resource Diagnostics Settings - Log Collection.')
param logsLawName string = 'log-${projowner}-${opscope}-${region}-logs'

@description('Required. Eventhub Namespace Name for resource Diagnostics Settings - Log Collection.')
param eventhubNamespaceName string = 'evhns-${projowner}-${opscope}-${region}-logs'

@description('Required. Automation Account Name.')
param automationAcctName string = 'aa-${projowner}-${opscope}-${region}-logs'
*/
@description('Required. Storage Account Name for resource Diagnostics Settings - Log Collection.')
param stgAcctName string = toLower(take('st${projowner}${opscope}${region}logs', 24))
// End - Copied from deploy.bicep

// Start - Define following Parameters in parameters.json file
param mgmtVnetName string
param mgmtPeSubnetName string
// End - Define following Parameters in parameters.json file

// 13 - Create Private Endpoint for Storage Account
// 13.1 - Retrieve an existing Storage Account resource
resource sa 'Microsoft.Storage/storageAccounts@2021-09-01' existing = {
  name: stgAcctName
  scope: resourceGroup(mgmtsubid, rgName)
}

// 13.2 - Retrieve an existing Virtual Network resource
resource mgmtVnet 'Microsoft.Network/virtualNetworks@2021-02-01' existing ={
  name: mgmtVnetName
  scope: resourceGroup(mgmtsubid, rgName)
}

// 13.3 - Retrieve an existing Subnet resource to be used to Private Endpoint
resource mgmtPeSubnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' existing =  {
  name : mgmtPeSubnetName
  parent: mgmtVnet
}

// 13.4 - Create Private Endpoint for Storage Account
module saPe '../modules/network/privateEndpoints/deploy.bicep' = {
  name: 'saPe-${stgAcctName}'
  scope: resourceGroup(mgmtsubid, rgName)
  params: {
    groupIds: [
      'blob'
    ]
    name: '${stgAcctName}-pe'
    location: location
    tags: ccsCombinedTags
    serviceResourceId: sa.id
    subnetResourceId: mgmtPeSubnet.id
    privateDnsZoneGroup: {
      privateDNSResourceIds: [
        resourceId(mgmtsubid, resourceGroupName, 'Microsoft.Network/privateDnsZones', 'privatelink.blob.core.usgovcloudapi.net')
      ]
    }
  }
}
