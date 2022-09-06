// Module - Subscriptions (Landing Zones and IRADs) 

//Configure Role Assignments
//Configure Policy Assignments

// Module - Virtual Networks & Peering

//Route Table

targetScope = 'managementGroup'

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

@description('Name of the virtual machine to be created')
@maxLength(15)
param virtualMachineNamePrefix string = 'vm-${projowner}-${opscope}-0'

@description('Required. Suffix to be used in resource naming with 4 characters.')
param suffix string

@description('Required. Name for the Diagnostics Setting Configuration.')
param diagSettingName string

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
param networkSecurityGroups array = []

@description('Required. Subscription ID of Connectivity Subscription')
param connsubid string

@description('Required. Resource Group name for Private DNS Zones.')
param priDNSZonesRgName string = 'rg-${projowner}-${opscope}-${region}-dnsz'

@description('Required. Subscription ID of Management Subscription.')
param mgmtsubid string

@description('Required. SIEM Resource Group Name.')
param siemRgName string = 'rg-${projowner}-${opscope}-${region}-siem'

@description('Required. Array of Private DNS Zones (Azure US Govrenment).')
param privateDnsZones array
// End - 'virtualNetwork' Module Parameters

// Start - 'sa' Module Parameters
@description('Required. Storage Account Name for resource Diagnostics Settings - Log Collection.')
param stgAcctName string = toLower(take('st${projowner}${opscope}${region}${suffix}', 24))

@description('Required. Storage Account SKU.')
param storageaccount_sku string

@description('Required. Storage Account Subresource(s) (aka "groupIds").')
@allowed([
  'blob'
  'blob_secondary'
  'table'
  'table_secondary'
  'queue'
  'queue_secondary'
  'file'
  'web'
  'web_secondary'
  'dfs'
  'dfs_secondary'
])
param stgGroupIds array
// End - 'sa' Module Parameters

// Start - 'akv' Module Parameters
@description('Required. Name of the Key Vault. Must be globally unique.')
@maxLength(24)
param lzAkvName string = toLower(take('akv-${projowner}-${opscope}-${region}-${suffix}', 24))

@description('Optional. Whether or not public network access is allowed for this resource. For security reasons it should be disabled. If not specified, it will be disabled by default if private endpoints are set.')
@allowed([
  ''
  'Enabled'
  'Disabled'
])
param publicNetworkAccess string = 'Disabled'

@description('Optional. Service endpoint object information. For security reasons, it is recommended to set the DefaultAction Deny.')
param networkAcls object
// End - 'akv' Module Parameters
/*
@description('Required. BillingAccount used for subscription billing')
param billingAccount string

@description('Required. EnrollmentAccount used for subscription billing')
param enrollmentAccount string

@description('Required. Alias to assign to the subscription')
param subscriptionAlias string

@description('Required. Display name for the subscription')
param subscriptionDisplayName string

@description('Required. Workload type for the subscription')
@allowed([
  'Production'
  'DevTest'
])
param subscriptionWorkload string

@description('Required. Management Group target for the subscription')
param managementGroupId string

@description('Required. Subscription Owner Id for the subscription')
param subscriptionOwnerId string
*/
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

@description('Required. Azure SQL Server Name (Primary)')
param sqlPrimaryServerName string = 'sql-${projowner}-${opscope}-${region}-srv1'

@description('Required. Azure SQL Server Name (Secondary)')
param sqlSecondaryServerName string = 'sql-${projowner}-${opscope}-${region}-srv2'

@description('Conditional. Azure SQL Fail Over Group Name.')
param sqlFailOverGroupName string = 'fogrp-${projowner}-${opscope}-${region}-${suffix}'

@description('Conditional. The Azure Active Directory (AAD) administrator authentication. Required if no `administratorLogin` & `administratorLoginPassword` is provided.')
param administrators object = {}

@description('Optional. The databases to create in the server.')
param databases array = []

@description('Conditional. The administrator username for the server. Required if no `administrators` object for AAD authentication is provided.')
@secure()
param sqlAdministratorLogin string = ''

@description('Conditional. The administrator login password. Required if no `administrators` object for AAD authentication is provided.')
@secure()
param sqlAdministratorLoginPassword string = ''

@description('Optional. The array of Virtual Machines.')
param virtualMachines array 

@description('Required. The administrator login for the Virtual Machine.')
@secure()
param vmAdmin string = ''

@description('Required. The administrator login password for the Virtual Machine.')
@secure()
param vmAdminPassword string = ''

@description('Virtual Machine Size')
param virtualMachineSize string = 'Standard_DS2_v2'

@description('Required. Load content from json file to iterate over any array in the parameters file')
var params = json(loadTextContent('.parameters/parameters.json'))

@description('Required. Iterate over each "subnets" and build variable to store "lzVMsSubnetName".')
var lzVMsSubnetName = params.parameters.subnets.value[2].name

@description('Required. Name of the Azure Recovery Service Vault.')
param vaultName  string = 'rsv-${projowner}-${opscope}-${region}-${suffix}'

@description('Required. Name of the separate resource group to store the restore point collection of managed virtual machines - instant recovery points .')
param rpcRgName string = 'rg-${projowner}-${opscope}-${region}-rpc'

@description('Required. Array containing all Policy Assignments at Subscription Scope.')
param subPolicyAssignments array = []

@description('Required. Name of the Key Vault. Must be globally unique.')
@maxLength(24)
param akvName string = toLower(take('kv-${projowner}-${opscope}-${region}-siem', 24))

// Retrieve exisiting Key Vault (From Management Subscription)
resource akv 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: akvName
  scope: resourceGroup(mgmtsubid, siemRgName)
}

@description('Required. Object containging Subscription properties.')
param subscription object

// 1. Create Subscription
module sub 'wrapperModule/createSub.bicep' = {
  name: 'mod-sub-${take(uniqueString(deployment().name, location), 4)}-${subscription.subscriptionAlias}'
  params: {
    location: location
    combinedTags: combinedTags
    billingAccount: subscription.billingAccount
    enrollmentAccount: subscription.enrollmentAccount
    subscriptionAlias: subscription.subscriptionAlias
    subscriptionDisplayName: subscription.subscriptionDisplayName
    subscriptionWorkload: subscription.subscriptionWorkload
    managementGroupId: subscription.managementGroupId
    subscriptionOwnerId: subscription.subscriptionOwnerId
  }
}

// 2. Create Resoruce Groups
module rgs './wrapperModule/resourceGroup.bicep' = {
  name: 'mod-rgs-${take(uniqueString(deployment().name, location), 4)}'
  params: {
    location: location
    combinedTags: combinedTags
    resourceGroups: resourceGroups
    rgRoleAssignments: rgRoleAssignments
    subscriptionId: sub.outputs.subscriptionId
  }
}

@description('Required. Object containging Virtual Network properties.')
param logAnalyticsWorkspace object

// 3. Create Log Analytics Workspace
module lzLoga 'wrapperModule/logAnalytics.bicep' = {
  name: 'mod-lzLoga-${take(uniqueString(deployment().name, location), 4)}-${logsLawName}'
  dependsOn: [
    rgs
  ]
  params: {
    logsLawName: logsLawName
    location: location
    combinedTags: combinedTags
    subscriptionId: sub.outputs.subscriptionId
    wlRgName: wlRgName
    logaGallerySolutions: logAnalyticsWorkspace.logaGallerySolutions
    publicNetworkAccessForIngestion: logAnalyticsWorkspace.publicNetworkAccessForIngestion
    publicNetworkAccessForQuery: logAnalyticsWorkspace.publicNetworkAccessForQuery
    connsubid: connsubid
    vnetRgName: vnetRgName
    amplsName: amplsName
  }
}

// 4. Configure Subscription
module subConfig 'wrapperModule/subconfig.bicep' = {
  name: 'mod-subConfig-${take(uniqueString(deployment().name, location), 4)}-${subscription.subscriptionAlias}'
  dependsOn: [
    lzLoga
  ]
  params: {
    location: location
    subRoleAssignments: subscription.subRoleAssignments
    subscriptionId: sub.outputs.subscriptionId
    diagSettingName: diagSettingName
    diagnosticWorkspaceId: lzLoga.outputs.logaResoruceId
  }
}

@description('Required. Object containging Virtual Network properties.')
param virtualNetwork object

// 5. Create Virtual Network
module lzVnet 'wrapperModule/virtualNetwork.bicep' = {
  name: 'mod-lzVnet-${take(uniqueString(deployment().name, location), 4)}-${virtualNetwork.vnetName}'
  dependsOn: [
    lzLoga
  ]
  params: {
    vnetName: virtualNetwork.vnetName
    location: location
    combinedTags: combinedTags
    vnetRgName: vnetRgName
    subscriptionId: sub.outputs.subscriptionId
    vnetAddressPrefixes: virtualNetwork.vnetAddressPrefixes
    subnets: virtualNetwork.subnets
    virtualNetworkPeerings: virtualNetwork.virtualNetworkPeerings
    networkSecurityGroups: virtualNetwork.networkSecurityGroups
    connsubid: connsubid
    priDNSZonesRgName: priDNSZonesRgName
    privateDnsZones: privateDnsZones
    diagSettingName: diagSettingName
    diagnosticWorkspaceId: lzLoga.outputs.logaResoruceId
  }
}

@description('Required. Object containging Storage Account properties.')
param storageAccount object

// 6. Create Storage Account
module lzSa 'wrapperModule/storage.bicep' = {
  name: 'mod-lzSa-${take(uniqueString(deployment().name, location), 4)}-${stgAcctName}'
  dependsOn: [
    lzVnet
  ]
  params: {
    stgAcctName: stgAcctName
    location: location
    combinedTags: combinedTags
    wlRgName: wlRgName
    storageaccount_sku: storageAccount.storageaccount_sku
    stgGroupIds: storageAccount.stgGroupIds
    subscriptionId: sub.outputs.subscriptionId
    vnetRgName: vnetRgName
    vnetName: vnetName
    mgmtSubnetName: mgmtSubnetName
    connsubid: connsubid
    priDNSZonesRgName: priDNSZonesRgName
    diagSettingName: diagSettingName
    diagnosticWorkspaceId: lzLoga.outputs.logaResoruceId
  }
}

@description('Required. Object containging Key Vault properties.')
param keyVault object

// 7. Create Azure Key Vault
module lzAkv 'wrapperModule/keyVault.bicep' = {
  name: 'mod-lzAkv-${take(uniqueString(deployment().name, location), 4)}-${lzAkvName}'
  dependsOn: [
    lzVnet
  ]
  params: {
    akvName: lzAkvName
    location: location
    combinedTags: combinedTags
    wlRgName: wlRgName
    networkAcls: keyVault.networkAcls
    publicNetworkAccess: publicNetworkAccess
    subscriptionId: sub.outputs.subscriptionId
    vnetRgName: vnetRgName
    vnetName: vnetName
    mgmtSubnetName: mgmtSubnetName
    connsubid: connsubid
    priDNSZonesRgName: priDNSZonesRgName
    diagSettingName: diagSettingName
    diagnosticWorkspaceId: lzLoga.outputs.logaResoruceId
  }
}

@description('Required. Object containging SQL Server properties.')
param sql object

// 8. Create SQL Server
module lzSql 'wrapperModule/sql.bicep' = {
  name: 'mod-lzSql-${take(uniqueString(deployment().name, location), 4)}'
  dependsOn: [
    lzVnet
  ]
  params: {
    location: location
    combinedTags: combinedTags
    sqlPrimaryServerName: sqlPrimaryServerName
    sqlSecondaryServerName: sqlSecondaryServerName
    subscriptionId: sub.outputs.subscriptionId
    wlRgName: wlRgName
    administratorLogin: akv.getSecret(sql.sqlAdministratorLogin)
    administratorLoginPassword: akv.getSecret(sql.sqlAdministratorLoginPassword)
    administrators: sql.administrators
    databases: sql.databases
    sqlFailOverGroupName: sqlFailOverGroupName
    diagSettingName: diagSettingName
    diagnosticWorkspaceId: lzLoga.outputs.logaResoruceId
  }
}

// 9. Create Virtual Machine(s)
module lzVms 'wrapperModule/virtualMachine.bicep' = [for (virtualMachine, i) in virtualMachines: {
  name: 'mod-lzVms-${take(uniqueString(deployment().name, location), 4)}-${virtualMachineNamePrefix}${i + 1}'
  dependsOn: [
    lzVnet
  ]
  params: {
    name: '${virtualMachineNamePrefix}${i + 1}'
    location: location
    combinedTags: combinedTags
    subscriptionId: sub.outputs.subscriptionId
    wlRgName: wlRgName
    vmAdmin: akv.getSecret(virtualMachine.vmAdmin)
    vmAdminPassword: akv.getSecret(virtualMachine.vmAdminPassword)     
    osType: virtualMachine.osType
    virtualMachineSize: virtualMachineSize    
    licenseType: virtualMachine.licenseType
    availabilityZone: virtualMachine.availabilityZone
    operatingSystem: virtualMachine.operatingSystem
    dataDisks: virtualMachine.dataDisks
    subnetResourceId: resourceId(sub.outputs.subscriptionId, vnetRgName, 'Microsoft.Network/virtualNetworks/subnets', vnetName, lzVMsSubnetName)
    diagnosticWorkspaceId: lzLoga.outputs.logaResoruceId
  }
}]

// 10. Create Recovery Services Vault
module rsv 'wrapperModule/recoveryServicesVault.bicep' = {
  name: 'mod-rsv-${take(uniqueString(deployment().name, location), 4)}-${vaultName}'
  dependsOn: [
    lzVnet
  ]
  params: {
    name: vaultName
    location: location
    combinedTags: combinedTags
    suffix: suffix
    subscriptionId: sub.outputs.subscriptionId
    wlRgName: wlRgName
    rpcRgName: rpcRgName
    vnetRgName: vnetRgName
    vnetName: vnetName
    mgmtSubnetName: mgmtSubnetName
    connsubid: connsubid
    priDNSZonesRgName: priDNSZonesRgName
    diagSettingName: diagSettingName
    diagnosticWorkspaceId: lzLoga.outputs.logaResoruceId
  }
}

// 11. Create Policy Assignment
module policyAssignment 'wrapperModule/policyAssignment.bicep' = {
  name: 'mod-policyAssignment-${take(uniqueString(deployment().name, location), 4)}'
  dependsOn: [
    rsv
  ]
  params: {
    subscriptionId: sub.outputs.subscriptionId
    subPolicyAssignments: subPolicyAssignments
  }
}


@description('Output - Resource Group "name" Array')
output rgNames array = rgs.outputs.rgNames

@description('Output - Resource Group "resoruceId" Array')
output rgResoruceIds array = rgs.outputs.rgResoruceIds

@description('Output - Log Analytics Workspace "name"')
output logaName string = lzLoga.outputs.logaName

@description('Output - Log Analytics Workspace "resoruceId"')
output logaResoruceId string = lzLoga.outputs.logaResoruceId

@description('Output - Virtual Network "name"')
output vNetName string = lzVnet.outputs.vNetName

@description('Output - Virtual Network "resoruceId"')
output vNetResoruceId string = lzVnet.outputs.vNetResoruceId

@description('Output - Subnets "name" Array')
output subnetNames array = lzVnet.outputs.subnetNames

@description('Output - Subnets "resoruceId" Array')
output subnetResourceIds array = lzVnet.outputs.subnetResourceIds

@description('Output - NSG "name" Array')
output nsgsNames array = lzVnet.outputs.nsgsNames

@description('Output - NSG "resoruceId" Array')
output nsgsResourceIds array = lzVnet.outputs.nsgsResourceIds

@description('Output - Storage Account "name"')
output saName string = lzSa.outputs.saName

@description('Output - Storage Account "resoruceId"')
output saResoruceId string = lzSa.outputs.saResoruceId

@description('Output - Log Analytics Workspace "name"')
output akvName string = lzAkv.outputs.akvName

@description('Output - Log Analytics Workspace "resoruceId"')
output akvResoruceId string = lzAkv.outputs.akvResoruceId

@description('Output - Log Analytics Workspace "resoruceId"')
output akvUri string = lzAkv.outputs.akvUri

/*
// Start - Outputs to supress warnings - "unused parameters"
output billingAccount string = billingAccount
output enrollmentAccount string = enrollmentAccount
output subscriptionAlias string = subscriptionAlias
output subscriptionDisplayName string = subscriptionDisplayName
output subscriptionWorkload string = subscriptionWorkload
output managementGroupId string = managementGroupId
output subscriptionOwnerId string = subscriptionOwnerId
// End - Outputs to supress warnings - "unused parameters"
*/