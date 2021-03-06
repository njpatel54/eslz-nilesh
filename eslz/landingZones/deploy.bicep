


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
  //Configure Rol Assignments
	
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

@description('Required. SIEM Resource Group Name.')
param rgName string = 'rg-${projowner}-${opscope}-${region}-siem'

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

// creating resources in the subscription requires an extra level of "nesting" to reference the subscriptionId as a module output and use for a scope
// The module outputs cannot be used for the scope property so needs to be passed down as a parameter one level
module landingZone  './wrapperModule/landingZone.bicep' = {
  name: 'landingZone-${take(uniqueString(deployment().name, location), 4)}-${rgName}'
  dependsOn: [
    subAlias
  ]
  params: {
    subRoleAssignments: subRoleAssignments
    rgName: rgName
    location: location
    combinedTags: combinedTags
    subscriptionId: subAlias.outputs.subscriptionId
    stgAcctName: stgAcctName
    storageaccount_sku: storageaccount_sku
    diagSettingName: diagSettingName
    diagnosticWorkspaceId: diagnosticWorkspaceId
    diagnosticStorageAccountId: diagnosticStorageAccountId
    diagnosticEventHubAuthorizationRuleId: diagnosticEventHubAuthorizationRuleId
    diagnosticEventHubName: diagnosticEventHubName
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
