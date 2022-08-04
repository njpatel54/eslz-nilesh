////////////////////////////////////////////////////////////////////////////////////
// Folloing parameters/variables can be removed in original Bicep Template file.
targetScope = 'subscription'
//param hubVnetSubscriptionId string = 'e6c61ac5-feea-4459-93fc-7131f8352553'
param location string = 'usgovvirginia'


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

////////////////////////////////////////////////////////////////////////////////////

// Create PrivateDNSZones
@description('Required. Resource Group name.')
param priDNSZonesRgName string = 'rg-${projowner}-${opscope}-${region}-dnsz'

var vNets = json(loadTextContent('.parameters/parameters.json'))

var spokeVNetsResourceIds = [for vNet in vNets.parameters.spokeVnets.value: resourceId(vNet.subscriptionId, resourceGroupName, 'Microsoft.Network/virtualNetworks', vNet.name)]

var hubVNetsResourceIds = [resourceId(vNets.parameters.hubVnetSubscriptionId.value, resourceGroupName, 'Microsoft.Network/virtualNetworks', vNets.parameters.hubVnetName.value)]

var vNetResourceIds = union(hubVNetsResourceIds, spokeVNetsResourceIds)

@description('Required. Array of Private DNS Zones.')
param privateDNSZones array = [
  'privatelink.adx.monitor.azure.us'
  'privatelink.afs.azure.net'
  'privatelink.agentsvc.azure-automation.us'
  'privatelink.api.ml.azure.us'
  'privatelink.azconfig.azure.us'
  'privatelink.azure-automation.us'
  'privatelink.azurecr.us'
  'privatelink.azure-devices.net'
  'privatelink.azure-devices.us'
  'privatelink.azurehdinsight.us'
  'privatelink.azuresynapse.usgovcloudapi.net'
  'privatelink.azurewebsites.us'
  'privatelink.batch.usgovcloudapi.net'
  'privatelink.blob.core.usgovcloudapi.net'
  'privatelink.cassandra.cosmos.azure.us'
  'privatelink.cognitiveservices.azure.us'
  'privatelink.database.usgovcloudapi.net'
  'privatelink.dev.azuresynapse.usgovcloudapi.net'
  'privatelink.dfs.core.usgovcloudapi.net'
  'privatelink.documents.azure.us'
  'privatelink.eventgrid.windows.net'
  'privatelink.file.core.usgovcloudapi.net'
  'privatelink.gremlin.cosmos.azure.us'
  'privatelink.mariadb.database.usgovcloudapi.net'
  'privatelink.mongo.cosmos.azure.us'
  'privatelink.mysql.database.usgovcloudapi.net'
  'privatelink.notebooks.usgovcloudapi.net'
  'privatelink.ods.opinsights.azure.us'
  'privatelink.oms.opinsights.azure.us'
  'privatelink.postgres.database.usgovcloudapi.net'
  'privatelink.prod.migration.windowsazure.us'
  'privatelink.queue.core.usgovcloudapi.net'
  'privatelink.redis.cache.usgovcloudapi.net'
  'privatelink.search.windows.us'
  'privatelink.servicebus.usgovcloudapi.net'
  'privatelink.servicebus.windows.us'
  'privatelink.signalr.azure.us'
  'privatelink.siterecovery.windowsazure.us'
  'privatelink.sql.azuresynapse.usgovcloudapi.net'
  'privatelink.table.core.usgovcloudapi.net'
  'privatelink.table.cosmos.azure.us'
  'privatelink.vaultcore.usgovcloudapi.net'
  'privatelink.web.core.usgovcloudapi.net'  
]

// Azure Geo Codes - https://docs.microsoft.com/en-us/azure/backup/private-endpoints#when-using-custom-dns-server-or-host-files
// Azure Geo Codes - https://download.microsoft.com/download/1/2/6/126a410b-0e06-45ed-b2df-84f353034fa1/AzureRegionCodesList.docx
@description('Required. Map of the Geo Codes for each Azure Region.')
var azureBackupGeoCodes = {
  australiacentral: 'acl'
  australiacentral2: 'acl2'
  australiaeast: 'ae'
  australiasoutheast: 'ase'
  brazilsouth: 'brs'
  centraluseuap: 'ccy'
  canadacentral: 'cnc'
  canadaeast: 'cne'
  centralus: 'cus'
  eastasia: 'ea'
  eastus2euap: 'ecy'
  eastus: 'eus'
  eastus2: 'eus2'
  francecentral: 'frc'
  francesouth: 'frs'
  germanynorth: 'gn'
  germanywestcentral: 'gwc'
  centralindia: 'inc'
  southindia: 'ins'
  westindia: 'inw'
  japaneast: 'jpe'
  japanwest: 'jpw'
  koreacentral: 'krc'
  koreasouth: 'krs'
  northcentralus: 'ncus'
  northeurope: 'ne'
  norwayeast: 'nwe'
  norwaywest: 'nww'
  southafricanorth: 'san'
  southafricawest: 'saw'
  southcentralus: 'scus'
  swedencentral: 'sdc'
  swedensouth: 'sds'
  southeastasia: 'sea'
  switzerlandnorth: 'szn'
  switzerlandwest: 'szw'
  uaecentral: 'uac'
  uaenorth: 'uan'
  uksouth: 'uks'
  ukwest: 'ukw'
  westcentralus: 'wcus'
  westeurope: 'we'
  westus: 'wus'
  westus2: 'wus2'
  usdodcentral: 'udc'
  usdodeast: 'ude'
  usgovarizona: 'uga'
  usgoviowa: 'ugi'
  usgovtexas: 'ugt'
  usgovvirginia: 'ugv'
  chinanorth: 'bjb'
  chinanorth2: 'bjb2'
  chinaeast: 'sha'
  chinaeast2: 'sha2'
  germanycentral: 'gec'
  germanynortheast: 'gne'
}

// If Azure region is entered in 'location' parameter and matches a lookup to 'azureBackupGeoCodes', then insert Azure Backup Private DNS Zone with appropriate geo code inserted alongside zones in 'privateDnsZones'. If not, just return 'privateDnsZones'
//   'privatelink.{region}.backup.windowsazure.us'
var privateDnsZonesMerge = contains(azureBackupGeoCodes, location) ? union(privateDNSZones, ['privatelink.${azureBackupGeoCodes[toLower(location)]}.backup.windowsazure.us']) : privateDNSZones

module PriDNSZonesRg '../modules/resourceGroups/deploy.bicep'= {
  name: 'rg-${vNets.parameters.hubVnetSubscriptionId.value}-${priDNSZonesRgName}'
  scope: subscription(vNets.parameters.hubVnetSubscriptionId.value)
  params: {
    name: priDNSZonesRgName
    location: location
    tags: ccsCombinedTags
  }
}

module PriDNSZones '../modules/network/privateDnsZones/deploy.bicep' = [for privateDnsZone in privateDnsZonesMerge: {
  name: 'PriDNSZones-${privateDnsZone}'
  scope: resourceGroup(vNets.parameters.hubVnetSubscriptionId.value, priDNSZonesRgName)
  dependsOn: [
    PriDNSZonesRg
  ]
  params: {
    name: privateDnsZone
    location: 'Global'
    virtualNetworkLinks: [for vNetResourceId in vNetResourceIds: {
      virtualNetworkResourceId: vNetResourceId
      registrationEnabled: false
    }]
  }
}]
