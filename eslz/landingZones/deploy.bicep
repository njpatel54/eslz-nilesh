


// Module - Subscriptions (Landing Zones and IRADs) 

  //Create Subscription(s)
	//Move Subscriptions to appropriate MG
	//Configure Diagnostic Settings for Subscriptions & MGs
	//Configure Tags
  //Configure Role Assignments
  //Configure Policy Assignments


// Module - Virtual Networks & Peering

  //Resoruce Group for Virtual Network
  //Network Security Group - (To be linked to Subnets)
  //Create Landing Zone VNet(s)
	//DDOS Protection Plan (optional)
	//Create VNet Peering with Connectivity Subscription
	//Configure Diagnostic Settins for VNets
	//Route Table
  //Configure Tags
  //Configure Role Assignments
	
// Module - Azure Resources/Workloads

  //Resoruce Group for Azure Resources/Workloads
  //Create required resources for Landing Zone
    //Key Vault
    //Storage Account
    //Log Analytics Workspace - for their workload/app related logs
    //Virtual Machines
    //Recovery Services Vault	


targetScope =  'managementGroup'

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// "billingScope" -	Billing scope of the subscription.                                                                                              //
// For CustomerLed and FieldLed - /billingAccounts/{billingAccountName}/billingProfiles/{billingProfileName}/invoiceSections/{invoiceSectionName}   //
// For PartnerLed - /billingAccounts/{billingAccountName}/customers/{customerName}                                                                  //
// For Legacy EA - /billingAccounts/{billingAccountName}/enrollmentAccounts/{enrollmentAccountName}                                                 //
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Start - Common parameters
@description('Required. Location for all resources.')
param location string

@description('subscriptionId for the deployment')
param subscriptionId string = 'df3b1809-17d0-47a0-9241-d2724780bdac'

@description('Required. utcfullvalue to be used in Tags.')
param utcfullvalue string = utcNow('F')

var tags = json(loadTextContent('lzTags.json'))

@description('Required. Assign utffullvaule to "CreatedOn" tag.')
param dynamictags object = ({
  CreatedOn: utcfullvalue
})

@description('Required. Combine Tags in dynamoctags object with Tags from parameter file.')
var combinedTags = union(dynamictags, tags.lzTags.value)

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

@description('Required. Suffix to be used in resource naming with 4 characters.')
param suffix string

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

@description('Required. Subnet name to be used for Private Endpoint.')
param mgmtSubnetName string = 'snet-${projowner}-${opscope}-${region}-mgmt'
// End - Common parameters

// Start - 'subRbac' Module Parameters
@description('Required. Array of role assignment objects to define RBAC on subscriptions.')
param subRoleAssignments array = []
// End - 'subRbac' Module Parameters

// Start - 'rgs' Module Parameters
@description('Required. Name of the resourceGroup, where application workload will be deployed.')
param wlRgName string = 'rg-${projowner}-${opscope}-${region}-wl01'

@description('Required. Name of the resourceGroup, where networking components will be.')
param vnetRgName string = 'rg-${projowner}-${opscope}-${region}-vnet'

@description('Contains the array of resourceGroup names.')
param resourceGroups array = [
  wlRgName
  vnetRgName
]

@description('Required. Array of role assignment objects to assign RBAC roles at Resource Groups.')
param rgRoleAssignments array = []
// End - 'rgs' Module Parameters

// Start - 'virtualNetwork' Module Parameters
@description('Required. The Virtual Network (vNet) Name.')
param vnetName string

@description('Required. An Array of 1 or more IP Address Prefixes for the Virtual Network.')
param vnetAddressPrefixes array

@description('Optional. An Array of subnets to deploy to the Virtual Network.')
param subnets array = []

@description('Optional. Virtual Network Peerings configurations')
param virtualNetworkPeerings array = []

@description('Required. Hub - Network Security Groups Array.')
param networkSecurityGroups array

@description('Required. Subscription ID of Connectivity Subscription')
param connsubid string

@description('Required. Resource Group name for Private DNS Zones.')
param priDNSZonesRgName string = 'rg-${projowner}-${opscope}-${region}-dnsz'

@description('Required. Array of Private DNS Zones (Azure US Govrenment).')
param privateDnsZones array
// End - 'virtualNetwork' Module Parameters

// Start - 'sa' Module Parameters
@description('Required. Storage Account Name for resource Diagnostics Settings - Log Collection.')
param stgAcctName string = toLower(take('st${projowner}${opscope}${region}${suffix}', 24))

@description('Required. Storage Account SKU.')
param storageaccount_sku string

param stgGroupIds array = [
  'blob'
  'table'
]
// End - 'sa' Module Parameters

@description('BillingAccount used for subscription billing')
param billingAccount string

@description('EnrollmentAccount used for subscription billing')
param enrollmentAccount string

@description('Alias to assign to the subscription')
param subscriptionAlias string

@description('Display name for the subscription')
param subscriptionDisplayName string

@description('Workload type for the subscription')
@allowed([
    'Production'
    'DevTest'
])
param subscriptionWorkload string

@description('Management Group target for the subscription')
param managementGroupId string

@description('Subscription Owner Id for the subscription')
param subscriptionOwnerId string


@description('Required. Log Ananlytics Workspace Name for resource Diagnostics Settings - Log Collection.')
param logsLawName string = 'log-${projowner}-${opscope}-${region}-${suffix}'

@description('Optional. List of gallerySolutions to be created in the Log Ananlytics Workspace for resource Diagnostics Settings - Log Collection.')
param logaGallerySolutions array = []

@description('Optional. The network access type for accessing Log Analytics ingestion.')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccessForIngestion string

@description('Optional. The network access type for accessing Log Analytics query.')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccessForQuery string

@description('Required. Azure Monitor Private Link Scope Name.')
param amplsName string = 'ampls-${projowner}-${opscope}-${region}-hub'

@description('Required. Name of the Key Vault. Must be globally unique.')
@maxLength(24)
param akvName string = toLower(take('kv-${projowner}-${opscope}-${region}-${suffix}', 24))


param sqlPrimaryServerName string = 'sql-${projowner}-${opscope}-${region}-srv1'
param sqlSecondaryServerName string = 'sql-${projowner}-${opscope}-${region}-srv2'
param sqlDbName string = 'sqldb-${projowner}-${opscope}-${region}-${suffix}'
param administrators object
param databases array = []
@secure()
param sqlAdministratorLogin string

@secure()
param sqlAdministratorLoginPassword string

param sqlFailOverGroupName string = 'fogrp-${projowner}-${opscope}-${region}-${suffix}'


@description('Optional. Whether or not public network access is allowed for this resource. For security reasons it should be disabled. If not specified, it will be disabled by default if private endpoints are set.')
@allowed([
  ''
  'Enabled'
  'Disabled'
])
param publicNetworkAccess string = 'Disabled'

@description('Optional. Service endpoint object information. For security reasons, it is recommended to set the DefaultAction Deny.')
param networkAcls object








/*
// 1. Create the Subscription
module subAlias '../modules/subscription/alias/deploy.bicep' = {
  name: 'subAlias-${take(uniqueString(deployment().name, location), 4)}-${subscriptionAlias}'
  params: {
    billingAccount: billingAccount
    enrollmentAccount: enrollmentAccount
    subscriptionAlias: subscriptionAlias
    subscriptionDisplayName: subscriptionDisplayName
    subscriptionWorkload: subscriptionWorkload
    managementGroupId: managementGroupId
    subscriptionOwnerId: subscriptionOwnerId
  }
}
*/

// 2. Create Role Assignments for Subscription
module subRbac '../modules/authorization/roleAssignments/subscription/deploy.bicep' = [ for (roleAssignment, index) in subRoleAssignments :{
  name: 'subRbac-${take(uniqueString(deployment().name, location), 4)}-${index}'
  scope: subscription(subscriptionId)
  params: {
    location: location
    description: contains(roleAssignment, 'description') ? roleAssignment.description : ''
    principalIds: roleAssignment.principalIds
    principalType: contains(roleAssignment, 'principalType') ? roleAssignment.principalType : ''
    roleDefinitionIdOrName: roleAssignment.roleDefinitionIdOrName
    subscriptionId: subscriptionId
  }
}]

// 3. Create Resoruce Groups
module rgs './wrapperModule/resourceGroup.bicep' = {
  name: 'rgs-${take(uniqueString(deployment().name, location), 4)}'
  scope: subscription(subscriptionId)
  params: {
    location: location
    combinedTags: combinedTags
    resourceGroups: resourceGroups
    rgRoleAssignments: rgRoleAssignments
    subscriptionId: subscriptionId
  }
}

// 4. Create Virtual Network
module virtulNetwork 'wrapperModule/virtualNetwork.bicep' = {
  name: 'virtulNetwork-${take(uniqueString(deployment().name, location), 4)}-${vnetName}'
  scope: resourceGroup(subscriptionId, vnetRgName)
  dependsOn: [
    rgs
  ]
  params: {
    vnetName: vnetName
    location: location
    combinedTags: combinedTags
    vnetRgName: vnetRgName
    subscriptionId: subscriptionId
    vnetAddressPrefixes: vnetAddressPrefixes
    subnets: subnets
    virtualNetworkPeerings: virtualNetworkPeerings
    networkSecurityGroups: networkSecurityGroups
    connsubid: connsubid
    priDNSZonesRgName: priDNSZonesRgName
    privateDnsZones: privateDnsZones
    diagSettingName: diagSettingName
    diagnosticStorageAccountId: diagnosticStorageAccountId
    diagnosticWorkspaceId: diagnosticWorkspaceId
    diagnosticEventHubName: diagnosticEventHubName
    diagnosticEventHubAuthorizationRuleId: diagnosticEventHubAuthorizationRuleId
  }
}

// 5. Create Storage Account
module sa 'wrapperModule/storage.bicep' = {
  name: 'sa-${take(uniqueString(deployment().name, location), 4)}-${vnetName}'
  scope: resourceGroup(subscriptionId, wlRgName)
  dependsOn: [
    virtulNetwork
  ]
  params: {
    stgAcctName: stgAcctName
    location: location
    combinedTags: combinedTags
    wlRgName: wlRgName
    storageaccount_sku: storageaccount_sku
    stgGroupIds: stgGroupIds
    subscriptionId: subscriptionId
    vnetRgName: vnetRgName
    vnetName: vnetName
    mgmtSubnetName: mgmtSubnetName
    connsubid: connsubid
    priDNSZonesRgName: priDNSZonesRgName
    diagSettingName: diagSettingName
    diagnosticWorkspaceId: diagnosticWorkspaceId
    diagnosticEventHubName: diagnosticEventHubName
    diagnosticEventHubAuthorizationRuleId: diagnosticEventHubAuthorizationRuleId
  }
}




/*
// 2. Deploy Landing Zone using Wraper Module
// Creating resources in the subscription requires an extra level of "nesting" to reference the subscriptionId as a module output and use for a scope
// The module outputs cannot be used for the scope property so needs to be passed down as a parameter one level
module landingZone  './wrapperModule/landingZone.bicep' = {
  name: 'landingZone-${take(uniqueString(deployment().name, location), 4)}-${lzRgName}'
  //dependsOn: [
  //  subAlias
  //]
  params: {
    subRoleAssignments: subRoleAssignments
    rgRoleAssignments: rgRoleAssignments
    lzRgName: lzRgName
    location: location
    combinedTags: combinedTags
    //subscriptionId: subAlias.outputs.subscriptionId
    subscriptionId: subscriptionId
    connsubid: connsubid
    suffix: suffix
    vnetRgName: vnetRgName
    priDNSZonesRgName: priDNSZonesRgName
    peSubnetName: peSubnetName
    vnetName: vnetName
    vnetAddressPrefixes: vnetAddressPrefixes
    subnets: subnets
    virtualNetworkPeerings: virtualNetworkPeerings
    privateDnsZones: privateDnsZones
    stgAcctName: stgAcctName
    storageaccount_sku: storageaccount_sku
    logsLawName: logsLawName
    logaGallerySolutions: logaGallerySolutions
    publicNetworkAccessForIngestion: publicNetworkAccessForIngestion
    publicNetworkAccessForQuery: publicNetworkAccessForQuery
    amplsName: amplsName
    akvName: akvName
    publicNetworkAccess: publicNetworkAccess
    networkAcls: networkAcls
    sqlPrimaryServerName: sqlPrimaryServerName
    sqlSecondaryServerName: sqlSecondaryServerName
    sqlFailOverGroupName: sqlFailOverGroupName
    sqlAdministratorLogin: sqlAdministratorLogin
    sqlAdministratorLoginPassword: sqlAdministratorLoginPassword
    administrators: administrators
    sqlDbName: sqlDbName
    databases: databases
    diagSettingName: diagSettingName
    diagnosticWorkspaceId: diagnosticWorkspaceId
    diagnosticStorageAccountId: diagnosticStorageAccountId
    diagnosticEventHubAuthorizationRuleId: diagnosticEventHubAuthorizationRuleId
    diagnosticEventHubName: diagnosticEventHubName
    networkSecurityGroups: networkSecurityGroups
  }
}

@description('Output - Subscrition ID')
output subscriptionId string = subAlias.outputs.subscriptionId

@description('Output - Resoruce Group Name')
output rgName string = landingZone.outputs.rgName

@description('Output - Resoruce Group resourceId')
output rgResoruceId string = landingZone.outputs.rgResoruceId

@description('Output - Storage Account resourceId')
output saResourceId string = landingZone.outputs.saResourceId

*/
