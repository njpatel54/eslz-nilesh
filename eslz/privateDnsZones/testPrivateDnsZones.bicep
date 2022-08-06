
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

param MGMTSUBSCRIPTIONID string

// Create PrivateDNSZones
@description('Required. Resource Group name.')
param priDNSZonesRgName string = 'rg-${projowner}-${opscope}-${region}-dnsz'

@description('Required. Load content from json file.')
var vNets = json(loadTextContent('../platformVNets/.parameters/parameters.json'))

// Variables created to be used as 'virtualNetworkLinks' for Private DNS Zone(s)
@description('Required. Iterate over each "spokeVnets" and build "resourceId" of each Virtual Networks using "subscriptionId", "resourceGroupName" and "vNet.name".')
var spokeVNetsResourceIds = [for vNet in vNets.parameters.spokeVnets.value: resourceId(vNet.subscriptionId, resourceGroupName, 'Microsoft.Network/virtualNetworks', vNet.name)]



//param privateDnsZones array

// 1 - Create Resource Group
module testPriDNSZonesRg '../modules/resourceGroups/deploy.bicep'= {
  name: 'rg-${MGMTSUBSCRIPTIONID}-${priDNSZonesRgName}'
  scope: subscription(MGMTSUBSCRIPTIONID)
  params: {
    name: priDNSZonesRgName
    location: location
    tags: ccsCombinedTags
  }
}

module testPriDNSZones '../modules/network/privateDnsZones/deploy.bicep' = [for privateDnsZone in privateDnsZonesMerge: {
  name: 'testPriDNSZones-${privateDnsZone}'
  scope: resourceGroup(MGMTSUBSCRIPTIONID, priDNSZonesRgName)
  dependsOn: [
    testPriDNSZonesRg
  ]
  params: {
    name: privateDnsZone
    location: 'Global'
    tags: ccsCombinedTags
    virtualNetworkLinks: [for vNetResourceId in spokeVNetsResourceIds: {
      virtualNetworkResourceId: vNetResourceId
      registrationEnabled: false
    }]
  }
}]



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

var privateDNSZones = array(json(loadTextContent('privateDNSZones.json')))

// If Azure region is entered in 'location' parameter and matches a lookup to 'azureBackupGeoCodes', then insert Azure Backup Private DNS Zone with appropriate geo code inserted alongside zones in 'privateDnsZones'. If not, just return 'privateDnsZones'
//   'privatelink.{region}.backup.windowsazure.us'
var privateDnsZonesMerge = contains(azureBackupGeoCodes, location) ? union(privateDNSZones, ['privatelink.${azureBackupGeoCodes[toLower(location)]}.backup.windowsazure.us']) : privateDNSZones





/*
@description('Required. Build "resourceId" of Hub Virtual Network using "hubVnetSubscriptionId", "resourceGroupName" and "hubVnetName".')
var hubVNetResourceId = [resourceId(vNets.parameters.hubVnetSubscriptionId.value, resourceGroupName, 'Microsoft.Network/virtualNetworks', vNets.parameters.hubVnetName.value)]

@description('Required. Combine two varibales using "union" function.')
var vNetResourceIds = union(hubVNetResourceId, spokeVNetsResourceIds)

*/
