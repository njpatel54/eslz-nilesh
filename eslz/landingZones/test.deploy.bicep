//Route Table

targetScope = 'managementGroup'

// Start - Common parameters
@description('Required. Location for all resources.')
param location string

@description('subscriptionId for the deployment')
param subscriptionId string = 'df3b1809-17d0-47a0-9241-d2724780bdac'

@description('Required. To deploy "lzSql" module or not')
param lzSqlDeploy bool

@description('Required. To deploy "lzVms" module or not')
param lzVmsDeploy bool

@description('Required. To deploy "lzSa" module or not')
param lzSaDeploy bool

@description('Required. To deploy "lzAkv" module or not')
param lzAkvDeploy bool

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
param projowner string

@description('Required. Region (region) parameter.')
@allowed([
  'usva'
  'ustx'
  'usaz'
])
param region string

@description('Name of the virtual machine to be created')
@maxLength(15)
param virtualMachineNamePrefix string = 'vm-${projowner}-0'

@description('Required. Suffix to be used in resource naming with 4 characters.')
param suffix string

@description('Required. Name for the Diagnostics Setting Configuration.')
param diagSettingName string

@description('Required. "projowner" parameter used for Platform.')
param platformProjOwner string

@description('Required. "opscope" parameter used for Platform.')
param platformOpScope string

@description('Required. Subnet name to be used for Private Endpoint.')
param mgmtSubnetName string = 'snet-${projowner}-${region}-mgmt'
// End - Common parameters

// Start - 'subRbac' Module Parameters
@description('Required. Array of role assignment objects to define RBAC on subscriptions.')
param subRoleAssignments array = []
// End - 'subRbac' Module Parameters

// Start - 'rgs' Module Parameters
@description('Required. Name of the resourceGroup, where application workload will be deployed.')
param wlRgName string = 'rg-${projowner}-${region}-wl01'

@description('Required. Name of the resourceGroup, where networking components will be.')
param vnetRgName string = 'rg-${projowner}-${region}-vnet'

@description('Required. Name of the resourceGroup, where centralized management components will be.')
param mgmtRgName string = 'rg-${projowner}-${region}-mgmt'

@description('Contains the array of resourceGroup names.')
param resourceGroups array = [
  wlRgName
  vnetRgName
  mgmtRgName
]

@description('Required. Array of role assignment objects to assign RBAC roles at Resource Groups.')
param rgRoleAssignments array = []
// End - 'rgs' Module Parameters

// Start - 'virtualNetwork' Module Parameters
@description('Required. Default Route Table name.')
param defaultRouteTableName string = 'rt-${projowner}-${region}-0001'

@description('Optional. An Array of Routes to be established within the hub route table.')
param routes array = []

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
param priDNSZonesRgName string = 'rg-${platformProjOwner}-${platformOpScope}-${region}-dnsz'

@description('Required. Subscription ID of Management Subscription.')
param mgmtsubid string

@description('Required. SIEM Resource Group Name.')
param siemRgName string = 'rg-${platformProjOwner}-${platformOpScope}-${region}-siem'

@description('Required. Array of Private DNS Zones (Azure US Govrenment).')
param privateDnsZones array
// End - 'virtualNetwork' Module Parameters

// Start - 'sa' Module Parameters
@description('Required. Taking 7 characters from billingAccount parameter to be used in Storage Account name')
param billingAccountShort string = take('${billingAccount}', 7)

@description('Required. Storage Account Name for resource Diagnostics Settings - Log Collection.')
param stgAcctName string = toLower(take('st${projowner}${billingAccountShort}${region}logs', 24))

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
  'file_secondary'
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
param lzAkvName string = toLower(take('kv-${projowner}-${region}', 24))

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

@description('Required. Log Ananlytics Workspace Name for resource Diagnostics Settings - Log Collection.')
param logsLawName string = 'log-${projowner}-${region}'

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
param amplsName string = 'ampls-${platformProjOwner}-${platformOpScope}-${region}-hub'

@description('Required. Azure SQL Server Name (Primary)')
param sqlPrimaryServerName string = toLower('sql-${projowner}-${region}-01')

@description('Required. Azure SQL Server Name (Primary)')
param sqlSecondaryServerName string = toLower('sql-${projowner}-${region}-02')

@description('Conditional. Azure SQL Fail Over Group Name.')
param sqlFailOverGroupName string = toLower('fogrp-${projowner}-${region}')

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

@description('Virtual Machine Size')
param virtualMachineSize string = 'Standard_DS2_v2'

@description('Required. Log Ananlytics Workspace Name for Azure Sentinel.')
param sentinelLawName string = 'log-${platformProjOwner}-${platformOpScope}-${region}-siem'

@description('Required. Automation Account Name - LAW - Sentinel')
param sentinelAutomationAcctName string = 'aa-${platformProjOwner}-${platformOpScope}-${region}-siem'

@description('Required. Load content from json file to iterate over any array in the parameters file')
var params = json(loadTextContent('.parameters/parameters.json'))

@description('Required. Iterate over each "subnets" and build variable to store "lzVMsSubnetName".')
var lzVMsSubnetName = params.parameters.subnets.value[2].name

@description('Required. Name of the Azure Recovery Service Vault.')
param vaultName string = 'rsv-${projowner}-${region}'

@description('Required. Name of the separate resource group to store the restore point collection of managed virtual machines - instant recovery points .')
param rpcRgName string = 'rg-${projowner}-${region}-rpc'

@description('Required. Name of the Key Vault. Must be globally unique.')
@maxLength(24)
param akvName string = toLower(take('kv-${platformProjOwner}-${platformOpScope}-${region}-siem', 24))

@description('Required. Parameter for policyAssignments')
param policyAssignments array

@description('Optional. List of softwareUpdateConfigurations to be created in the automation account.')
param softwareUpdateConfigurations array = []

@description('Required. Disk Access resource name.')
param diskAccessName string = 'da-${projowner}-${region}-01'

@description('Optional. Security contact data.')
param defenderSecurityContactProperties object

@description('The kind of data connectors that can be deployed via ARM templates at Subscription level: ["AzureActivityLog", "AzureSecurityCenter"]')
param dataConnectorsSubs array = [
  // 'AzureSecurityCenter'
]

/*
// 1. Retrieve an exisiting Key Vault (From Management Subscription)
resource akv 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: akvName
  scope: resourceGroup(mgmtsubid, siemRgName)
}

// 2. Retrieve an existing Log Analytics Workspace (Sentinel - From Management Subscription)
resource logaSentinel 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: sentinelLawName
  scope: resourceGroup(mgmtsubid, siemRgName)
}

// 4. Create Subscription
module sub 'wrapperModule/createSub.bicep' = {
  name: 'mod-sub-${take(uniqueString(deployment().name, location), 4)}-${subscriptionAlias}'
  params: {
    location: location
    billingAccount: billingAccount
    enrollmentAccount: enrollmentAccount
    subscriptionAlias: subscriptionAlias
    subscriptionDisplayName: subscriptionDisplayName
    subscriptionWorkload: subscriptionWorkload
    managementGroupId: managementGroupId
  }
}

// 5. Create Resource Groups
module lzRgs './wrapperModule/resourceGroup.bicep' = {
  name: 'mod-rgs-${take(uniqueString(deployment().name, location), 4)}'
  dependsOn: [
    //sub
  ]
  params: {
    location: location
    combinedTags: combinedTags
    resourceGroups: resourceGroups
    rgRoleAssignments: rgRoleAssignments
    subscriptionId: subscriptionId
  }
}

// 6. Create Log Analytics Workspace
module lzLoga 'wrapperModule/logAnalytics.bicep' = {
  name: 'mod-lzLoga-${take(uniqueString(deployment().name, location), 4)}-${logsLawName}'
  dependsOn: [
    lzRgs
  ]
  params: {
    logsLawName: logsLawName
    location: location
    combinedTags: combinedTags
    subscriptionId: subscriptionId
    wlRgName: wlRgName
    logaGallerySolutions: logaGallerySolutions
    publicNetworkAccessForIngestion: publicNetworkAccessForIngestion
    publicNetworkAccessForQuery: publicNetworkAccessForQuery
    connsubid: connsubid
    vnetRgName: vnetRgName
    amplsName: amplsName
  }
}

// 7. Configure Subscription
module lzSubConfig 'wrapperModule/subconfig.bicep' = {
  name: 'mod-subConfig-${take(uniqueString(deployment().name, location), 4)}-${subscriptionAlias}'
  dependsOn: [
    lzLoga
  ]
  params: {
    location: location
    subRoleAssignments: subRoleAssignments
    subscriptionId: subscriptionId
    combinedTags: combinedTags
    diagSettingName: diagSettingName
    diagnosticWorkspaceId: lzLoga.outputs.logaResoruceId
  }
}

// 8. Create Virtual Network
module lzVnet 'wrapperModule/virtualNetwork.bicep' = {
  name: 'mod-lzVnet-${take(uniqueString(deployment().name, location), 4)}-${vnetName}'
  dependsOn: [
    lzLoga
  ]
  params: {
    vnetName: vnetName
    location: location
    combinedTags: combinedTags
    defaultRouteTableName: defaultRouteTableName
    routes: routes
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
    diagnosticWorkspaceId: lzLoga.outputs.logaResoruceId
  }
}

// 9. Create Storage Account
module lzSa 'wrapperModule/storage.bicep' = if (lzSaDeploy) {
  name: 'mod-lzSa-${take(uniqueString(deployment().name, location), 4)}-${stgAcctName}'
  dependsOn: [
    lzVnet
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
    diagnosticWorkspaceId: lzLoga.outputs.logaResoruceId
  }
}

// 10. Create Azure Key Vault
module lzAkv 'wrapperModule/keyVault.bicep' = if (lzAkvDeploy) {
  name: 'mod-lzAkv-${take(uniqueString(deployment().name, location), 4)}-${lzAkvName}'
  dependsOn: [
    lzVnet
  ]
  params: {
    akvName: lzAkvName
    location: location
    combinedTags: combinedTags
    wlRgName: wlRgName
    networkAcls: networkAcls
    publicNetworkAccess: publicNetworkAccess
    subscriptionId: subscriptionId
    vnetRgName: vnetRgName
    vnetName: vnetName
    mgmtSubnetName: mgmtSubnetName
    connsubid: connsubid
    priDNSZonesRgName: priDNSZonesRgName
    diagSettingName: diagSettingName
    diagnosticWorkspaceId: lzLoga.outputs.logaResoruceId
  }
}

// 11. Create SQL Server(s)
module lzSql 'wrapperModule/sql.bicep' = if (lzSqlDeploy) {
  name: 'mod-lzSql-${take(uniqueString(deployment().name, location), 4)}'
  dependsOn: [
    lzVnet
  ]
  params: {
    location: location
    combinedTags: combinedTags
    sqlPrimaryServerName: sqlPrimaryServerName
    sqlSecondaryServerName: sqlSecondaryServerName
    subscriptionId: subscriptionId
    wlRgName: wlRgName
    administratorLogin: akv.getSecret(sqlAdministratorLogin)
    administratorLoginPassword: akv.getSecret(sqlAdministratorLoginPassword)
    administrators: administrators
    databases: databases
    sqlFailOverGroupName: sqlFailOverGroupName
    diagSettingName: diagSettingName
    diagnosticWorkspaceId: lzLoga.outputs.logaResoruceId
  }
}

// 12. Create Virtual Machine(s)
module lzVms 'wrapperModule/virtualMachine.bicep' = [for (virtualMachine, i) in virtualMachines: if (lzVmsDeploy) {
  name: 'mod-lzVms-${take(uniqueString(deployment().name, location), 4)}-${virtualMachineNamePrefix}${i + 1}'
  dependsOn: [
    lzVnet
  ]
  params: {
    name: '${virtualMachineNamePrefix}${i + 1}'
    location: location
    combinedTags: combinedTags
    subscriptionId: subscriptionId
    wlRgName: wlRgName
    vmAdmin: akv.getSecret(virtualMachine.vmAdmin)
    vmAdminPassword: akv.getSecret(virtualMachine.vmAdminPassword)
    osType: virtualMachine.osType
    virtualMachineSize: virtualMachineSize
    licenseType: virtualMachine.licenseType
    availabilityZone: virtualMachine.availabilityZone
    operatingSystem: virtualMachine.operatingSystem
    dataDisks: virtualMachine.dataDisks
    subnetResourceId: resourceId(subscriptionId, vnetRgName, 'Microsoft.Network/virtualNetworks/subnets', vnetName, lzVMsSubnetName)
    diagnosticWorkspaceId: lzLoga.outputs.logaResoruceId
    monitoringWorkspaceId: logaSentinel.id
  }
}]

// 13. Create Recovery Services Vault
module lzRsv 'wrapperModule/recoveryServicesVault.bicep' = {
  name: 'mod-rsv-${take(uniqueString(deployment().name, location), 4)}-${vaultName}'
  dependsOn: [
    lzVnet
  ]
  params: {
    name: vaultName
    location: location
    combinedTags: combinedTags
    suffix: suffix
    subscriptionId: subscriptionId
    mgmtRgName: mgmtRgName
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

// 14. Create Software Update Management Configuration
module lzUpdateMgmt 'wrapperModule/updateManagement.bicep' = {
  name: 'mod-lzUpdateMgmt-${take(uniqueString(deployment().name, location), 4)}'
  dependsOn: [
    lzVnet
  ]
  params: {
    location: location
    mgmtsubid: mgmtsubid
    sentinelAutomationAcctName: sentinelAutomationAcctName
    siemRgName: siemRgName
    suffix: suffix
    subscriptionId: '/subscriptions/${subscriptionId}'
    softwareUpdateConfigurations: softwareUpdateConfigurations
  }
}

// 15. Create Disk Accesses Resource
module lzDiskAccess 'wrapperModule/diskAccesses.bicep' = {
  name: 'mod-diskAccess-${take(uniqueString(deployment().name, location), 4)}-${diskAccessName}'
  dependsOn: [
    lzVnet
  ]
  params: {
    name: diskAccessName
    location: location
    combinedTags: combinedTags
    wlRgName: wlRgName
    subscriptionId: subscriptionId
    vnetRgName: vnetRgName
    vnetName: vnetName
    mgmtSubnetName: mgmtSubnetName
    connsubid: connsubid
    priDNSZonesRgName: priDNSZonesRgName
  }
}

// 16. Cconfigure Defender for Cloud
module lzDefender 'wrapperModule/defender.bicep' = {
  name: 'defender-${take(uniqueString(deployment().name, location), 4)}-${subscriptionAlias}'
  scope: subscription(subscriptionId)
  //dependsOn: [
  //  sub
  //]
    params: {
      location: location
      subscriptionAlias: subscriptionAlias
      subscriptionId: subscriptionId
      workspaceId: resourceId(mgmtsubid, siemRgName, 'Microsoft.OperationalInsights/workspaces', sentinelLawName)
      defenderSecurityContactProperties: defenderSecurityContactProperties
  }
}

// 11. Configure Sentinel Data Connectors - Subscription Level
module dataConnectorsSubsScope '../modules/securityInsights/dataConnectors/subscription.deploy.bicep' = {
  name: 'dataConnectorsSubs-${take(uniqueString(deployment().name, location), 4)}-${subscriptionId}'
  scope: resourceGroup(mgmtsubid, siemRgName)
  params: {
    subscriptionId: subscriptionId
    workspaceName: sentinelLawName
    dataConnectors: dataConnectorsSubs
  }
}

// 17. Create Policy Assignment and Remediation
module lzPolicyAssignment 'wrapperModule/polAssignment.bicep' = {
  name: 'mod-policyAssignment-${take(uniqueString(deployment().name, location), 4)}'
  dependsOn: [
    lzRsv
    lzVms
  ]
  params: {
    subscriptionId: subscriptionId
    policyAssignments: policyAssignments
  }
}
*/

@description('Required. Array of Action Groups')
param actionGroups array = []

// 18. Create Action Group(s)
module lzActionGroup 'wrapperModule/actionGroup.bicep' = [for (actionGroup, i) in actionGroups: {
  name: 'lzActionGroup--${take(uniqueString(deployment().name, location), 4)}-${actionGroup.name}'
  scope: resourceGroup(subscriptionId, wlRgName)
  //dependsOn: [
  //  lzRgs
  //]
  params: {
    name: actionGroup.name
    groupShortName: actionGroup.groupShortName
    emailReceivers: actionGroup.emailReceivers
    smsReceivers: actionGroup.smsReceivers
    tags: combinedTags
  }
}]

// 18. Create Alerts
module lzAlerts 'wrapperModule/alerts.bicep' = {
  name: 'lzAlerts--${take(uniqueString(deployment().name, location), 4)}-${subscriptionId}'
  scope: resourceGroup(subscriptionId, wlRgName)
  dependsOn: [
    lzActionGroup
  ]
  params: {
    subscriptionId: subscriptionId
    wlRgName: wlRgName
    actionGroups: actionGroups
    tags: combinedTags
  }
}

/*
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

// Start - Outputs to supress warnings - "unused parameters"
output billingAccount string = billingAccount
output enrollmentAccount string = enrollmentAccount
output subscriptionAlias string = subscriptionAlias
output subscriptionDisplayName string = subscriptionDisplayName
output subscriptionWorkload string = subscriptionWorkload
output managementGroupId string = managementGroupId
output subscriptionOwnerId string = subscriptionOwnerId
//output subscriptionId string = subscriptionId
// End - Outputs to supress warnings - "unused parameters"
*/
/*
@description('Required. The administrator login for the Virtual Machine.')
@secure()
param vmAdmin string = ''

@description('Required. The administrator login password for the Virtual Machine.')
@secure()
param vmAdminPassword string = ''
*/
