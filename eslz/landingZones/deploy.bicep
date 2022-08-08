


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

@description('Required. Array of role assignment objects to define RBAC on subscriptions.')
param subRoleAssignments array = []

@description('Required. Location for all resources.')
param location string

@description('Required. Subscription ID of Connectivity Subscription')
param connsubid string

@description('Required. Resource Group name.')
param vnetRgName string = 'rg-${projowner}-${opscope}-${region}-vnet'

@description('Name of the resourceGroup, will be created in the same location as the deployment.')
param lzRgName string = 'rg-${projowner}-${opscope}-${region}-wl01'

@description('Required. Resource Group name for Private DNS Zones.')
param priDNSZonesRgName string = 'rg-${projowner}-${opscope}-${region}-dnsz'

@description('Required. Subnet name to be used for Private Endpoint.')
param peSubnetName string = 'snet-${projowner}-${opscope}-${region}-mgmt'

@description('Required. The Virtual Network (vNet) Name.')
param vnetName string

@description('Required. An Array of 1 or more IP Address Prefixes for the Virtual Network.')
param vnetAddressPrefixes array

@description('Optional. An Array of subnets to deploy to the Virtual Network.')
param subnets array = []

@description('Optional. Virtual Network Peerings configurations')
param virtualNetworkPeerings array = []

@description('Required. Array of Private DNS Zones (Azure US Govrenment).')
param privateDnsZones array

@description('Required. Log Ananlytics Workspace Name for resource Diagnostics Settings - Log Collection.')
param logsLawName string = 'log-${projowner}-${opscope}-${region}-logs'

@description('Optional. List of gallerySolutions to be created in the Log Ananlytics Workspace for resource Diagnostics Settings - Log Collection.')
param logaGallerySolutions array = []

@description('Optional. The network access type for accessing Log Analytics ingestion.')
param publicNetworkAccessForIngestion string = ''

@description('Optional. The network access type for accessing Log Analytics query.')
param publicNetworkAccessForQuery string = ''

@description('Required. Azure Monitor Private Link Scope Name.')
param amplsName string = 'ampls-${projowner}-${opscope}-${region}-hub'

@description('Required. Name of the Key Vault. Must be globally unique.')
@maxLength(24)
param akvName string = toLower(take('kv-${projowner}-${opscope}-${region}-lz01', 24))

@description('Required. Array of role assignment objects to define RBAC on Resource Groups.')
param rgRoleAssignments array = []

@description('Required. Suffix to be used in resource naming with 4 characters.')
param suffix string = substring(uniqueString(utcNow()),0,4)

@description('Required. utcfullvalue to be used in Tags.')
param utcfullvalue string = utcNow('F')

@description('Required. Resource Tags.')
param tags object

@description('Required. Assign utffullvaule to "CreatedOn" tag.')
param dynamictags object = ({
  CreatedOn: utcfullvalue
})

@description('Required. Combine Tags in dynamoctags object with Tags from parameter file.')
var combinedTags = union(dynamictags, tags)

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

@description('Required. Storage Account Name for resource Diagnostics Settings - Log Collection.')
param stgAcctName string = toLower(take('st${projowner}${opscope}${region}${suffix}', 24))

@description('Required. Storage Account SKU.')
param storageaccount_sku string

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

/*
// Create the Subscription
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

// creating resources in the subscription requires an extra level of "nesting" to reference the subscriptionId as a module output and use for a scope
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
    subscriptionId: 'df3b1809-17d0-47a0-9241-d2724780bdac'
    connsubid: connsubid
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
    diagSettingName: diagSettingName
    diagnosticWorkspaceId: diagnosticWorkspaceId
    diagnosticStorageAccountId: diagnosticStorageAccountId
    diagnosticEventHubAuthorizationRuleId: diagnosticEventHubAuthorizationRuleId
    diagnosticEventHubName: diagnosticEventHubName
  }
}

/*
@description('Output - Subscrition ID')
output subscriptionId string = subAlias.outputs.subscriptionId
*/

@description('Output - Resoruce Group Name')
output rgName string = landingZone.outputs.rgName

@description('Output - Resoruce Group resourceId')
output rgResoruceId string = landingZone.outputs.rgResoruceId

@description('Output - Storage Account resourceId')
output saResourceId string = landingZone.outputs.saResourceId
