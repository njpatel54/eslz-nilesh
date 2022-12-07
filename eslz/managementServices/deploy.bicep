targetScope = 'tenant'

@description('Optional. List of gallerySolutions to be created in the Log Ananlytics Workspace for Azure Sentinel.')
param logaSentinelGallerySolution array = []

@description('Optional. List of gallerySolutions to be created in the Log Ananlytics Workspace for resource Diagnostics Settings - Log Collection.')
param logaGallerySolutions array = []

@description('Optional. List of data sources to be configured in the Log Ananlytics Workspace.')
param dataSources array = []

@description('Optional. The network access type for accessing Log Analytics ingestion.')
param publicNetworkAccessForIngestion string = ''

@description('Optional. The network access type for accessing Log Analytics query.')
param publicNetworkAccessForQuery string = ''

@description('Required. Authorization Rules for Event Hub Namespace.')
param authorizationRules array = []

@description('Required. Array of Event Hubs instances.')
param eventHubs array = []

@description('Required. Subscription ID of Management Subscription.')
param mgmtsubid string

@description('Required. Subscription ID of Shared Services Subscription.')
param ssvcsubid string

@description('Required. Default Management Group where newly created Subscription will be added to.')
param onboardmg string

@description('Required. Indicates whether RBAC access is required upon group creation under the root Management Group. If set to true, user will require Microsoft.Management/managementGroups/write action on the root Management Group scope in order to create new Groups directly under the root. .')
param requireAuthorizationForGroupCreation bool

@description('Required. Array of Management Groups objects.')
param managementGroups array

@description('Required. Array of role assignment objects to define RBAC on management groups.')
param mgRoleAssignments array = []

@description('Required. Array of role assignment objects to define RBAC on subscriptions.')
param subRoleAssignments array = []

@description('Required. Array of Subscription objects.')
param subscriptions array

@description('Required. Azure AD Tenant ID.')
param tenantid string

@description('Required. Location for all resources.')
param location string

/*
@description('Required. Suffix to be used in resource naming with 4 characters.')
param suffix string = substring(uniqueString(utcNow()),0,4)
*/

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

@description('Required. Last four digits of Enrollment Number.')
param enrollmentID string

// Build param values using string interpolation
@description('Required. SIEM Resource Group Name.')
param siemRgName string = 'rg-${projowner}-${opscope}-${region}-siem'

@description('Required. Name of the resourceGroup, where centralized management components will be.')
param mgmtRgName string = 'rg-${projowner}-${opscope}-${region}-mgmt'

@description('Required. Log Ananlytics Workspace Name for Azure Sentinel.')
param sentinelLawName string = 'log-${projowner}-${opscope}-${region}-siem'

@description('Required. Log Ananlytics Workspace Name for resource Diagnostics Settings - Log Collection.')
param logsLawName string = 'log-${projowner}-${opscope}-${region}-logs'

@description('Required. Eventhub Namespace Name for resource Diagnostics Settings - Log Collection.')
param eventhubNamespaceName string = 'evhns-${projowner}-${opscope}-${region}-logs'

@description('Required. Automation Account Name - LAW - Logs Collection.')
param logAutomationAcctName string = 'aa-${projowner}-${opscope}-${region}-logs'

@description('Optional. Indicates whether traffic on the non-ARM endpoint (Webhook/Agent) is allowed from the public internet')
param automationAcctPublicNetworkAccess bool = false

@description('Required. Automation Account Name - LAW - Sentinel')
param sentinelAutomationAcctName string = 'aa-${projowner}-${opscope}-${region}-siem'

@description('Optional. List of softwareUpdateConfigurations to be created in the automation account.')
param softwareUpdateConfigurations array = []

@description('Required. Storage Account Name for resource Diagnostics Settings - Log Collection - Management Subscription.')
param stgAcctName string = toLower(take('st${projowner}${opscope}${enrollmentID}${region}logs', 24))

@description('Required. Storage Account Name for Storing Shared data managed by platform team - Shared Services Subscription.')
param stgAcctSsvcName string = toLower(take('st${projowner}${opscope}${enrollmentID}${region}ssvc', 24))

@description('Optional. Whether or not public network access is allowed for this resource. For security reasons it should be disabled. If not specified, it will be disabled by default if private endpoints are set.')
param stgPublicNetworkAccess string = 'Disabled'

@description('Required. Name of the Key Vault. Must be globally unique - Management Subscription.')
@maxLength(24)
param akvName string = toLower(take('kv-${projowner}-${opscope}-${region}-siem', 24))

@description('Optional. Whether or not public network access is allowed for this resource. For security reasons it should be disabled. If not specified, it will be disabled by default if private endpoints are set.')
param kvPublicNetworkAccess string = 'Enabled'

@description('Optional. Key Vault Role Assignment array.')
param kvRoleAssignments array

// From Parameters Files
@description('Required. Storage Account SKU.')
param storageaccount_sku string

@description('Optional. Blob service and containers to deploy')
param blobServices object

@description('Optional. File service and shares to deploy')
param fileServices object

@description('Optional. Queue service and queues to create.')
param queueServices object

@description('Optional. Table service and tables to create.')
param tableServices object

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

@description('Required. Suffix to be used in resource naming with 4 characters.')
param mgmtSuffix string = 'mgmt'

@description('Required. Suffix to be used in resource naming with 4 characters.')
param ssvcSuffix string = 'ssvc'

@description('Required. Name of the separate resource group to store the restore point collection of managed virtual machines - instant recovery points .')
param rpcRgName string = 'rg-${projowner}-${opscope}-${region}-rpc'

@description('Required. Name of the Azure Recovery Service Vault in Management Subscription.')
param mgmtVaultName  string = 'rsv-${projowner}-${opscope}-${region}-${mgmtSuffix}'

@description('Required. Name of the Azure Recovery Service Vault in Shared Services Subscription.')
param ssvcVaultName  string = 'rsv-${projowner}-${opscope}-${region}-${ssvcSuffix}'

@description('Optional. Security contact data.')
param defenderSecurityContactProperties object

@description('The kind of data connectors that can be deployed via ARM templates at Tenent level: ["AmazonWebServicesCloudTrail",  "AzureAdvancedThreatProtection", "MicrosoftCloudAppSecurity", "MicrosoftDefenderAdvancedThreatProtection", "Office365", "ThreatIntelligence"]')
@allowed([
  'AmazonWebServicesCloudTrail'
  'AzureActiveDirectory'
  'AzureAdvancedThreatProtection'                                   // Requires Azure Active Directory Premium P2 License
  'MicrosoftCloudAppSecurity'
  'MicrosoftDefenderAdvancedThreatProtection'                       
  'Office365'
  'ThreatIntelligence'
])
param dataConnectorsTenant array = []

@description('The kind of data connectors that can be deployed via ARM templates at Subscription level: ["AzureSecurityCenter"]')
@allowed([
  'AzureSecurityCenter'
])
param dataConnectorsSubs array = []

@description('Required. Array of Action Groups')
param actionGroups array

@description('Required. Array containing Budgets.')
param budgets array = []

// 1. Create Resoruce Group (siem - Management Subscription)
module siemRg '../modules/resources/resourceGroups/deploy.bicep'= {
  name: 'rg-${take(uniqueString(deployment().name, location), 4)}-${siemRgName}'
  scope: subscription(mgmtsubid)
  params: {
    name: siemRgName
    location: location
    tags: ccsCombinedTags
  }
}

// 2. Create Resoruce Groups (mgmt - All Platform Subscriptions)
module mgmtRg '../modules/resources/resourceGroups/deploy.bicep' = [ for subscription in subscriptions: {
  name: 'rg-${take(uniqueString(deployment().name, location), 4)}-${mgmtRgName}'
  scope: subscription(subscription.subscriptionId)
  params: {
    name: mgmtRgName
    location: location
    tags: ccsCombinedTags
  }
}]

// 3. Create Log Analytics Workspace for Azure Sentinel
module logaSentinel '../modules/operationalInsights/workspaces/deploy.bicep' = {
  name: 'logaSentinel-${take(uniqueString(deployment().name, location), 4)}-${sentinelLawName}'
  scope: resourceGroup(mgmtsubid, siemRgName)
  dependsOn: [
    siemRg
  ]
  params:{
    name: sentinelLawName
    location: location
    tags: ccsCombinedTags
    gallerySolutions: logaSentinelGallerySolution
    dataSources: dataSources
    publicNetworkAccessForIngestion: publicNetworkAccessForIngestion
    publicNetworkAccessForQuery: publicNetworkAccessForQuery
  }
}

// 4. Create Log Analytics Workspace for resource Diagnostics Settings - Log Collection
module loga '../modules/operationalInsights/workspaces/deploy.bicep' = {
  name: 'loga-${take(uniqueString(deployment().name, location), 4)}-${logsLawName}'
  scope: resourceGroup(mgmtsubid, siemRgName)
  dependsOn: [
    siemRg
  ]
  params:{
    name: logsLawName
    location: location
    tags: ccsCombinedTags
    gallerySolutions: logaGallerySolutions
    dataSources: dataSources
    publicNetworkAccessForIngestion: publicNetworkAccessForIngestion
    publicNetworkAccessForQuery: publicNetworkAccessForQuery    
  }
}

// 5. Create Storage Account (Management Subscription)
module saMgmt '../modules/storageAccounts/deploy.bicep' = {
  name: 'saMgmt-${take(uniqueString(deployment().name, location), 4)}-${stgAcctName}'
  scope: resourceGroup(mgmtsubid, siemRgName)
  dependsOn: [
    loga
    logaSentinel
  ]
  params: {
    location: location
    storageAccountName: stgAcctName
    storageSKU: storageaccount_sku
    blobServices: blobServices
    fileServices: fileServices
    queueServices: queueServices
    tableServices: tableServices
    diagnosticSettingsName: diagSettingName
    diagnosticWorkspaceId: loga.outputs.resourceId
    tags: ccsCombinedTags
    publicNetworkAccess: stgPublicNetworkAccess
  }
}

// 6. Create Storage Account (Shared Services Subscription)
module saSsvc '../modules/storageAccounts/deploy.bicep' = {
  name: 'saSsvc-${take(uniqueString(deployment().name, location), 4)}-${stgAcctSsvcName}'
  scope: resourceGroup(ssvcsubid, mgmtRgName)
  dependsOn: [
    loga
    logaSentinel
  ]
  params: {
    location: location
    storageAccountName: stgAcctSsvcName
    storageSKU: storageaccount_sku
    blobServices: blobServices
    fileServices: fileServices
    queueServices: queueServices
    tableServices: tableServices
    diagnosticSettingsName: diagSettingName
    diagnosticWorkspaceId: loga.outputs.resourceId
    tags: ccsCombinedTags
    publicNetworkAccess: stgPublicNetworkAccess
  }
}

// 7. Create Event Hub Namespace and Event Hub
module eh '../modules/namespaces/deploy.bicep' = {
  name: 'eh-${take(uniqueString(deployment().name, location), 4)}-${eventhubNamespaceName}'
  scope: resourceGroup(mgmtsubid, siemRgName)
  dependsOn: [
    saMgmt
  ]
  params: {
    location: location
    tags: ccsCombinedTags
    eventhubNamespaceName: eventhubNamespaceName
    eventHubs: eventHubs
    authorizationRules: authorizationRules
    diagnosticSettingsName: diagSettingName
    diagnosticStorageAccountId: saMgmt.outputs.resourceId
    diagnosticWorkspaceId: loga.outputs.resourceId    
  }
}

// 8. Create Automation Account and link it to Log Analytics Workspace (LAW - Log Collection)
module aaLoga '../modules/automation/automationAccounts/deploy.bicep' = {
  name: 'aaLoga-${take(uniqueString(deployment().name, location), 4)}-${logAutomationAcctName}'
  scope: resourceGroup(mgmtsubid, siemRgName)
  dependsOn: [
    eh
  ]
  params:{
    name: logAutomationAcctName
    location: location
    tags: ccsCombinedTags
    publicNetworkAccess: automationAcctPublicNetworkAccess
    linkedWorkspaceResourceId: loga.outputs.resourceId
    diagnosticSettingsName: diagSettingName
    diagnosticStorageAccountId: saMgmt.outputs.resourceId
    diagnosticWorkspaceId: loga.outputs.resourceId
    //diagnosticEventHubName: eventHubs[0].name    //First Event Hub name from eventHubs object in parameter file.
    //diagnosticEventHubAuthorizationRuleId: resourceId(mgmtsubid, siemRgName, 'Microsoft.EventHub/namespaces/AuthorizationRules', eventhubNamespaceName, 'RootManageSharedAccessKey')
  }
}

// 9. Create Automation Account and link it to Log Analytics Workspace (LAW - Sentinel)
module aaLogaSentinel '../modules/automation/automationAccounts/deploy.bicep' = {
  name: 'aaLogaSentinel-${take(uniqueString(deployment().name, location), 4)}-${sentinelAutomationAcctName}'
  scope: resourceGroup(mgmtsubid, siemRgName)
  dependsOn: [
    eh
    logaSentinel
  ]
  params:{
    name: sentinelAutomationAcctName
    location: location
    tags: ccsCombinedTags
    publicNetworkAccess: automationAcctPublicNetworkAccess
    linkedWorkspaceResourceId: logaSentinel.outputs.resourceId
    softwareUpdateConfigurations: softwareUpdateConfigurations
    diagnosticSettingsName: diagSettingName
    diagnosticStorageAccountId: saMgmt.outputs.resourceId
    diagnosticWorkspaceId: loga.outputs.resourceId
    //diagnosticEventHubName: eventHubs[0].name    //First Event Hub name from eventHubs object in parameter file.
    //diagnosticEventHubAuthorizationRuleId: resourceId(mgmtsubid, siemRgName, 'Microsoft.EventHub/namespaces/AuthorizationRules', eventhubNamespaceName, 'RootManageSharedAccessKey')
  }
}

// 10. Create Azure Key Vault (Management Subscription)
module akvManagement '../modules/keyVault/vaults/deploy.bicep' = {
  name: 'akvManagement-${take(uniqueString(deployment().name, location), 4)}-${akvName}'
  scope: resourceGroup(mgmtsubid, siemRgName)
  dependsOn: [
    eh
  ]
    params: {
      name: akvName
      location: location
      tags: ccsCombinedTags
      vaultSku: 'premium'
      publicNetworkAccess: kvPublicNetworkAccess
      roleAssignments: kvRoleAssignments
      diagnosticSettingsName: diagSettingName
      diagnosticStorageAccountId: saMgmt.outputs.resourceId
      diagnosticWorkspaceId: loga.outputs.resourceId
      //diagnosticEventHubName: eventHubs[0].name    //First Event Hub name from eventHubs object in parameter file.
      //diagnosticEventHubAuthorizationRuleId: resourceId(mgmtsubid, siemRgName, 'Microsoft.EventHub/namespaces/AuthorizationRules', eventhubNamespaceName, 'RootManageSharedAccessKey')
    }
}

// 11. Configure Diagnostics Settings for Subscriptions
module subDiagSettings '../modules/insights/diagnosticSettings/sub.deploy.bicep' = [ for subscription in subscriptions: {
  name: 'subDiagSettings-${subscription.subscriptionId}'
  scope: subscription(subscription.subscriptionId)
  dependsOn: [
    eh
  ]
  params:{
    name: diagSettingName
    location: location
    diagnosticStorageAccountId: saMgmt.outputs.resourceId
    diagnosticWorkspaceId: loga.outputs.resourceId
    //diagnosticEventHubName: eventHubs[0].name    //First Event Hub name from eventHubs object in parameter file.
    //diagnosticEventHubAuthorizationRuleId: resourceId(mgmtsubid, siemRgName, 'Microsoft.EventHub/namespaces/AuthorizationRules', eventhubNamespaceName, 'RootManageSharedAccessKey')
  }
}]

// 12. Configure Tags for Subscriptions
module subTags '../modules/resources/tags/subscriptions/deploy.bicep' = [ for subscription in subscriptions: {
  name: 'subTags-${subscription.subscriptionId}'
  scope: subscription(subscription.subscriptionId)
    params: {
    tags: ccsCombinedTags
  }
}]

// 13. Configure Defender for Cloud
module defender '../modules/security/azureSecurityCenter/deploy.bicep' = [ for subscription in subscriptions: {
  name: 'defender-${take(uniqueString(deployment().name, location), 4)}-${subscription.subscriptionId}'
  scope: subscription(subscription.subscriptionId)
  dependsOn: [
    logaSentinel
  ]
  params: {
    scope: '/subscriptions/${subscription.subscriptionId}'
    workspaceId: logaSentinel.outputs.resourceId
    securityContactProperties: defenderSecurityContactProperties
  }
}]

// 14. Configure Sentinel Data Connectors - Tenent Level
module dataConnectorsTenantScope '../modules/securityInsights/dataConnectors/tenant.deploy.bicep' = {
  name: 'dataConnectorsTenant-${take(uniqueString(deployment().name, location), 4)}'
  scope: resourceGroup(mgmtsubid, siemRgName)
  dependsOn: [
    logaSentinel
  ]
  params: {
    workspaceName: sentinelLawName
    dataConnectors: dataConnectorsTenant
  }
}

// 15. Configure Sentinel Data Connectors - Subscription Level
module dataConnectorsSubsScope '../modules/securityInsights/dataConnectors/subscription.deploy.bicep' = [ for subscription in subscriptions: {
  name: 'dataConnectorsSubs-${take(uniqueString(deployment().name, location), 4)}-${subscription.subscriptionId}'
  scope: resourceGroup(mgmtsubid, siemRgName)
  dependsOn: [
    logaSentinel 
  ]
  params: {
    subscriptionId: subscription.subscriptionId
    workspaceName: sentinelLawName
    dataConnectors: dataConnectorsSubs
  }
}]

// 16. Create Recovery Services Vault (Management Subscription)
module rsvMgmt '../modules/recoveryServices/vaults/deploy.bicep' = {
  name: 'rsv-${take(uniqueString(deployment().name, location), 4)}-${mgmtVaultName}'
  scope: resourceGroup(mgmtsubid, mgmtRgName)
  dependsOn: [
    mgmtRg
    eh
  ]
  params: {
    name: mgmtVaultName
    location: location
    tags: ccsCombinedTags
    systemAssignedIdentity: true
    backupPolicies: [
      {
        name: '${mgmtSuffix}vmBackupPolicy'
        type: 'Microsoft.RecoveryServices/vaults/backupPolicies'
        properties: {
          backupManagementType: 'AzureIaasVM'
          policyType: 'V1'
          instantRPDetails: {
            azureBackupRGNamePrefix: rpcRgName
          }
          schedulePolicy: {
            schedulePolicyType: 'SimpleSchedulePolicy'
            scheduleRunFrequency: 'Daily'
            scheduleRunTimes: [
              '2022-09-01T01:00:00Z'
            ]
            scheduleWeeklyFrequency: 0
          }
          retentionPolicy: {
            retentionPolicyType: 'LongTermRetentionPolicy'
            dailySchedule: {
              retentionTimes: [
                '2022-09-01T01:00:00Z'
              ]
              retentionDuration: {
                count: 180
                durationType: 'Days'
              }
            }
            weeklySchedule: {
              daysOfTheWeek: [
                'Sunday'
              ]
              retentionTimes: [
                '2022-09-01T01:00:00Z'
              ]
              retentionDuration: {
                count: 12
                durationType: 'Weeks'
              }
            }
            monthlySchedule: {
              retentionScheduleFormatType: 'Weekly'
              retentionScheduleWeekly: {
                daysOfTheWeek: [
                  'Sunday'
                ]
                weeksOfTheMonth: [
                  'First'
                ]
              }
              retentionTimes: [
                '2022-09-01T01:00:00Z'
              ]
              retentionDuration: {
                count: 60
                durationType: 'Months'
              }
            }
          }
          instantRpRetentionRangeInDays: 2
          timeZone: 'Eastern Standard Time'
          protectedItemsCount: 0
        }
      }
      {
        name: '${mgmtSuffix}sqlBackupPolicy'
        type: 'Microsoft.RecoveryServices/vaults/backupPolicies'
        properties: {
          backupManagementType: 'AzureWorkload'
          workLoadType: 'SQLDataBase'
          settings: {
            timeZone: 'Eastern Standard Time'
            issqlcompression: true
            isCompression: true
          }
          subProtectionPolicy: [
            {
              policyType: 'Full'
              schedulePolicy: {
                schedulePolicyType: 'SimpleSchedulePolicy'
                scheduleRunFrequency: 'Weekly'
                scheduleRunDays: [
                  'Sunday'
                ]
                scheduleRunTimes: [
                  '2022-08-30T01:00:00Z'
                ]
                scheduleWeeklyFrequency: 0
              }
              retentionPolicy: {
                retentionPolicyType: 'LongTermRetentionPolicy'
                weeklySchedule: {
                  daysOfTheWeek: [
                    'Sunday'
                  ]
                  retentionTimes: [
                    '2022-08-30T01:00:00Z'
                  ]
                  retentionDuration: {
                    count: 104
                    durationType: 'Weeks'
                  }
                }
                monthlySchedule: {
                  retentionScheduleFormatType: 'Weekly'
                  retentionScheduleWeekly: {
                    daysOfTheWeek: [
                      'Sunday'
                    ]
                    weeksOfTheMonth: [
                      'First'
                    ]
                  }
                  retentionTimes: [
                    '2022-08-30T01:00:00Z'
                  ]
                  retentionDuration: {
                    count: 60
                    durationType: 'Months'
                  }
                }
                yearlySchedule: {
                  retentionScheduleFormatType: 'Weekly'
                  monthsOfYear: [
                    'January'
                  ]
                  retentionScheduleWeekly: {
                    daysOfTheWeek: [
                      'Sunday'
                    ]
                    weeksOfTheMonth: [
                      'First'
                    ]
                  }
                  retentionTimes: [
                    '2022-08-30T01:00:00Z'
                  ]
                  retentionDuration: {
                    count: 10
                    durationType: 'Years'
                  }
                }
              }
            }
            {
              policyType: 'Differential'
              schedulePolicy: {
                schedulePolicyType: 'SimpleSchedulePolicy'
                scheduleRunFrequency: 'Weekly'
                scheduleRunDays: [
                  'Monday'
                ]
                scheduleRunTimes: [
                  '2022-08-30T01:00:00Z'
                ]
                scheduleWeeklyFrequency: 0
              }
              retentionPolicy: {
                retentionPolicyType: 'SimpleRetentionPolicy'
                retentionDuration: {
                  count: 30
                  durationType: 'Days'
                }
              }
            }
            {
              policyType: 'Log'
              schedulePolicy: {
                schedulePolicyType: 'LogSchedulePolicy'
                scheduleFrequencyInMins: 120
              }
              retentionPolicy: {
                retentionPolicyType: 'SimpleRetentionPolicy'
                retentionDuration: {
                  count: 15
                  durationType: 'Days'
                }
              }
            }
          ]
          protectedItemsCount: 0
        }
      }
      {
        name: '${mgmtSuffix}fileShareBackupPolicy'
        type: 'Microsoft.RecoveryServices/vaults/backupPolicies'
        properties: {
          backupManagementType: 'AzureStorage'
          workloadType: 'AzureFileShare'
          schedulePolicy: {
            schedulePolicyType: 'SimpleSchedulePolicy'
            scheduleRunFrequency: 'Daily'
            scheduleRunTimes: [
              '2022-08-30T01:00:00Z'
            ]
            scheduleWeeklyFrequency: 0
          }
          retentionPolicy: {
            retentionPolicyType: 'LongTermRetentionPolicy'
            dailySchedule: {
              retentionTimes: [
                '2022-08-30T01:00:00Z'
              ]
              retentionDuration: {
                count: 30
                durationType: 'Days'
              }
            }
          }
          timeZone: 'Eastern Standard Time'
          protectedItemsCount: 0
        }
      }
    ]
    diagnosticSettingsName: diagSettingName
    diagnosticStorageAccountId: saMgmt.outputs.resourceId
    diagnosticWorkspaceId: loga.outputs.resourceId
  }
}

// 17. Create Recovery Services Vault's Backup Configuration (Management Subscription)
module rsvBackupConfigMgmt '../modules/recoveryServices/vaults/backupConfig/deploy.bicep' = {
  name: 'rsvBackupConfigMgmt-${take(uniqueString(deployment().name, location), 4)}'
  scope: resourceGroup(mgmtsubid, mgmtRgName)
  params: {
    recoveryVaultName: rsvMgmt.outputs.name    
  }
}

// 18. Create Recovery Services Vault (Shared Services Subscription)
module rsvSsvc '../modules/recoveryServices/vaults/deploy.bicep' = {
  name: 'rsv-${take(uniqueString(deployment().name, location), 4)}-${ssvcVaultName}'
  scope: resourceGroup(ssvcsubid, mgmtRgName)
  dependsOn: [
    mgmtRg
    eh
  ]
  params: {
    name: ssvcVaultName
    location: location
    tags: ccsCombinedTags
    systemAssignedIdentity: true
    backupPolicies: [
      {
        name: '${ssvcSuffix}vmBackupPolicy'
        type: 'Microsoft.RecoveryServices/vaults/backupPolicies'
        properties: {
          backupManagementType: 'AzureIaasVM'
          policyType: 'V1'
          instantRPDetails: {
            azureBackupRGNamePrefix: rpcRgName
          }
          schedulePolicy: {
            schedulePolicyType: 'SimpleSchedulePolicy'
            scheduleRunFrequency: 'Daily'
            scheduleRunTimes: [
              '2022-09-01T01:00:00Z'
            ]
            scheduleWeeklyFrequency: 0
          }
          retentionPolicy: {
            retentionPolicyType: 'LongTermRetentionPolicy'
            dailySchedule: {
              retentionTimes: [
                '2022-09-01T01:00:00Z'
              ]
              retentionDuration: {
                count: 180
                durationType: 'Days'
              }
            }
            weeklySchedule: {
              daysOfTheWeek: [
                'Sunday'
              ]
              retentionTimes: [
                '2022-09-01T01:00:00Z'
              ]
              retentionDuration: {
                count: 12
                durationType: 'Weeks'
              }
            }
            monthlySchedule: {
              retentionScheduleFormatType: 'Weekly'
              retentionScheduleWeekly: {
                daysOfTheWeek: [
                  'Sunday'
                ]
                weeksOfTheMonth: [
                  'First'
                ]
              }
              retentionTimes: [
                '2022-09-01T01:00:00Z'
              ]
              retentionDuration: {
                count: 60
                durationType: 'Months'
              }
            }
          }
          instantRpRetentionRangeInDays: 2
          timeZone: 'Eastern Standard Time'
          protectedItemsCount: 0
        }
      }
      {
        name: '${ssvcSuffix}sqlBackupPolicy'
        type: 'Microsoft.RecoveryServices/vaults/backupPolicies'
        properties: {
          backupManagementType: 'AzureWorkload'
          workLoadType: 'SQLDataBase'
          settings: {
            timeZone: 'Eastern Standard Time'
            issqlcompression: true
            isCompression: true
          }
          subProtectionPolicy: [
            {
              policyType: 'Full'
              schedulePolicy: {
                schedulePolicyType: 'SimpleSchedulePolicy'
                scheduleRunFrequency: 'Weekly'
                scheduleRunDays: [
                  'Sunday'
                ]
                scheduleRunTimes: [
                  '2022-08-30T01:00:00Z'
                ]
                scheduleWeeklyFrequency: 0
              }
              retentionPolicy: {
                retentionPolicyType: 'LongTermRetentionPolicy'
                weeklySchedule: {
                  daysOfTheWeek: [
                    'Sunday'
                  ]
                  retentionTimes: [
                    '2022-08-30T01:00:00Z'
                  ]
                  retentionDuration: {
                    count: 104
                    durationType: 'Weeks'
                  }
                }
                monthlySchedule: {
                  retentionScheduleFormatType: 'Weekly'
                  retentionScheduleWeekly: {
                    daysOfTheWeek: [
                      'Sunday'
                    ]
                    weeksOfTheMonth: [
                      'First'
                    ]
                  }
                  retentionTimes: [
                    '2022-08-30T01:00:00Z'
                  ]
                  retentionDuration: {
                    count: 60
                    durationType: 'Months'
                  }
                }
                yearlySchedule: {
                  retentionScheduleFormatType: 'Weekly'
                  monthsOfYear: [
                    'January'
                  ]
                  retentionScheduleWeekly: {
                    daysOfTheWeek: [
                      'Sunday'
                    ]
                    weeksOfTheMonth: [
                      'First'
                    ]
                  }
                  retentionTimes: [
                    '2022-08-30T01:00:00Z'
                  ]
                  retentionDuration: {
                    count: 10
                    durationType: 'Years'
                  }
                }
              }
            }
            {
              policyType: 'Differential'
              schedulePolicy: {
                schedulePolicyType: 'SimpleSchedulePolicy'
                scheduleRunFrequency: 'Weekly'
                scheduleRunDays: [
                  'Monday'
                ]
                scheduleRunTimes: [
                  '2022-08-30T01:00:00Z'
                ]
                scheduleWeeklyFrequency: 0
              }
              retentionPolicy: {
                retentionPolicyType: 'SimpleRetentionPolicy'
                retentionDuration: {
                  count: 30
                  durationType: 'Days'
                }
              }
            }
            {
              policyType: 'Log'
              schedulePolicy: {
                schedulePolicyType: 'LogSchedulePolicy'
                scheduleFrequencyInMins: 120
              }
              retentionPolicy: {
                retentionPolicyType: 'SimpleRetentionPolicy'
                retentionDuration: {
                  count: 15
                  durationType: 'Days'
                }
              }
            }
          ]
          protectedItemsCount: 0
        }
      }
      {
        name: '${ssvcSuffix}fileShareBackupPolicy'
        type: 'Microsoft.RecoveryServices/vaults/backupPolicies'
        properties: {
          backupManagementType: 'AzureStorage'
          workloadType: 'AzureFileShare'
          schedulePolicy: {
            schedulePolicyType: 'SimpleSchedulePolicy'
            scheduleRunFrequency: 'Daily'
            scheduleRunTimes: [
              '2022-08-30T01:00:00Z'
            ]
            scheduleWeeklyFrequency: 0
          }
          retentionPolicy: {
            retentionPolicyType: 'LongTermRetentionPolicy'
            dailySchedule: {
              retentionTimes: [
                '2022-08-30T01:00:00Z'
              ]
              retentionDuration: {
                count: 30
                durationType: 'Days'
              }
            }
          }
          timeZone: 'Eastern Standard Time'
          protectedItemsCount: 0
        }
      }
    ]
    diagnosticSettingsName: diagSettingName
    diagnosticStorageAccountId: saMgmt.outputs.resourceId
    diagnosticWorkspaceId: loga.outputs.resourceId
  }
}

// 19. Create Recovery Services Vault's Backup Configuration (Shared Services Subscription)
module rsvBackupConfigSsvc '../modules/recoveryServices/vaults/backupConfig/deploy.bicep' = {
  name: 'rsvBackupConfigSsvc-${take(uniqueString(deployment().name, location), 4)}'
  scope: resourceGroup(mgmtsubid, mgmtRgName)
  params: {
    recoveryVaultName: rsvSsvc.outputs.name    
  }
}

// 20. Create Action Group(s)
module actionGroup '../landingZones/wrapperModule/actionGroup.bicep' = [ for subscription in subscriptions: {
  name: 'actionGroup-${take(uniqueString(deployment().name, location), 4)}-${subscription.suffix}'
  scope: resourceGroup(subscription.subscriptionId, mgmtRgName)
  dependsOn: [
    mgmtRg
  ]
  params: {
    location: location
    tags: ccsCombinedTags
    actionGroups: actionGroups
  }
}]

// 21. Create Alerts
module alerts '../landingZones/wrapperModule/alerts.bicep' = [ for subscription in subscriptions: {
  name: 'alerts-${take(uniqueString(deployment().name, location), 4)}-${subscription.suffix}'
  scope: resourceGroup(subscription.subscriptionId, mgmtRgName)
  dependsOn: [
    mgmtRg
    actionGroup
  ]
  params: {
    subscriptionId: subscription.subscriptionId
    wlRgName: mgmtRgName
    tags: ccsCombinedTags    
    suffix: subscription.suffix
    actionGroups: actionGroups
  }
}]

/*
// 22. Create Budgets
module budget '../landingZones/wrapperModule/budgets.bicep' = [ for subscription in subscriptions: {
  name: 'budgets-${take(uniqueString(deployment().name, location), 4)}-${subscription.suffix}'
  scope: resourceGroup(subscription.subscriptionId, mgmtRgName)
  dependsOn: [
    actionGroup
  ]
  params: {
    location: location
    subscriptionId: subscription.subscriptionId
    budgets: budgets
  }
}]
*/

@description('Output - Name of Event Hub')
output ehnsAuthorizationId string = resourceId(mgmtsubid, siemRgName, 'Microsoft.EventHub/namespaces/AuthorizationRules', eventhubNamespaceName, 'RootManageSharedAccessKey')

@description('Output - SIEM Resource Group Name')
output siemRgName string = siemRg.outputs.name

@description('Output - SIEM Resource Group resourceId')
output siemRgresourceId string = siemRg.outputs.resourceId

@description('Output - Log Analytics Workspce Name - resource Diagnostics Settings - Log Collection')
output logaSentinelName string = logaSentinel.outputs.name

@description('Output - Log Analytics Workspce resourceId - resource Diagnostics Settings - Log Collection')
output logaSentinelResourceId string = logaSentinel.outputs.resourceId

@description('Output - Log Analytics Workspce Name - resource Diagnostics Settings - Log Collection')
output logaName string = loga.outputs.name

@description('Output - Log Analytics Workspce resourceId - resource Diagnostics Settings - Log Collection')
output logaResourceId string = loga.outputs.resourceId

@description('Output - Storage Account Name')
output saMgmtName string = saMgmt.outputs.name

@description('Output - Storage Account resourceId')
output saMgmtResourceId string = saMgmt.outputs.resourceId

@description('Output - Eventhub Namespace Name')
output ehNamespaceName string = eh.outputs.name

@description('Output - Subscription Diagnostics Settings Names Array')
output subDiagSettingsNames array = [for (subscription, i) in subscriptions: {  
  subscriptionId: subDiagSettings[i].outputs.resourceId
  diagnosticSettingsName: subDiagSettings[i].outputs.name
}]

@description('Output - Key Vault "name"')
output akvManagementName string = akvManagement.outputs.name

@description('Output - Key Vault "resoruceId"')
output akvManagementResoruceId string = akvManagement.outputs.resourceId

@description('Output - Key Vault "resoruceId"')
output akvManagementUri string = akvManagement.outputs.uri

// Start - Outputs to supress warnings - "unused parameters"
output onboardmg string = onboardmg
output requireAuthorizationForGroupCreation bool = requireAuthorizationForGroupCreation
output managementGroups array = managementGroups
output mgRoleAssignments array = mgRoleAssignments
output subRoleAssignments array = subRoleAssignments
output tenantid string = tenantid
output diagnosticStorageAccountId string = diagnosticStorageAccountId
output diagnosticWorkspaceId string = diagnosticWorkspaceId
output diagnosticEventHubAuthorizationRuleId string = diagnosticEventHubAuthorizationRuleId
output diagnosticEventHubName string = diagnosticEventHubName
// End - Outputs to supress warnings - "unused parameters"




























/*
@description('Required. Subscription ID of Connectivity Subscription.')
param connsubid string

@description('Required. Name of the Key Vault. Must be globally unique - Connectivity Subscription.')
@maxLength(24)
param akvConnectivityName string = toLower(take('kv-${projowner}-${opscope}-${region}-conn', 24))

// 10. Create Azure Key Vault (Connectivity Subscription)
module akvConnectivity '../modules/keyVault/vaults/deploy.bicep' = {
  name: 'akvConnectivity-${take(uniqueString(deployment().name, location), 4)}-${akvConnectivityName}'
  scope: resourceGroup(connsubid, mgmtRgName)
  dependsOn: [
    mgmtRg
    eh
  ]
    params: {
      name: akvConnectivityName
      location: location
      tags: ccsCombinedTags
      vaultSku: 'premium'
      publicNetworkAccess: kvPublicNetworkAccess
      roleAssignments: kvRoleAssignments
      diagnosticSettingsName: diagSettingName
      diagnosticStorageAccountId: saMgmt.outputs.resourceId
      diagnosticWorkspaceId: loga.outputs.resourceId
      //diagnosticEventHubName: eventHubs[0].name    //First Event Hub name from eventHubs object in parameter file.
      //diagnosticEventHubAuthorizationRuleId: resourceId(mgmtsubid, siemRgName, 'Microsoft.EventHub/namespaces/AuthorizationRules', eventhubNamespaceName, 'RootManageSharedAccessKey')
    }
}


@description('Output - Key Vault "name"')
output akvConnectivityName string = akvConnectivity.outputs.name

@description('Output - Key Vault "resoruceId"')
output akvConnectivityResoruceId string = akvConnectivity.outputs.resourceId

@description('Output - Key Vault "resoruceId"')
output akvConnectivityUri string = akvConnectivity.outputs.uri

// Currently DiagnosticSettings at Management Group level is supported in Azure US Gov - (Reference - https://github.com/Azure/azure-powershell/issues/17717)
// Configure Diagnostics Settings for Management Groups
module mgDiagSettings '../modules/insights/diagnosticSettings/mg.deploy.bicep' = [ for managementGroup in managementGroups: {
  name: 'diagSettings-${managementGroup.name}'
//  scope: managementGroup(managementGroup.name)
  dependsOn: [
    siemRg
    loga
    sa
    eh
  ]
  params:{
    name: diagSettingName
    location: location
    diagnosticStorageAccountId: sa.outputs.resourceId
    diagnosticWorkspaceId: loga.outputs.resourceId
    diagnosticEventHubName: eventHubs[0].name
    diagnosticEventHubAuthorizationRuleId: resourceId(mgmtsubid, siemRgName, 'Microsoft.EventHub/namespaces/AuthorizationRules', eventhubNamespaceName, 'RootManageSharedAccessKey')
  }
}]

module mgmt_mgmt_rg '../modules/resources/resourceGroups/deploy.bicep'= {
  name: 'rg-${take(uniqueString(deployment().name, location), 4)}-${mgmtRgName}'
  scope: subscription(mgmtsubid)
  params: {
    name: mgmtRgName
    location: location
    tags: ccsCombinedTags
  }
}

module ssvc_mgmt_rg '../modules/resources/resourceGroups/deploy.bicep'= {
  name: 'rg-${take(uniqueString(deployment().name, location), 4)}-${mgmtRgName}'
  scope: subscription(ssvcsubid)
  params: {
    name: mgmtRgName
    location: location
    tags: ccsCombinedTags
  }
}

module conn_mgmt_rg '../modules/resources/resourceGroups/deploy.bicep'= {
  name: 'rg-${take(uniqueString(deployment().name, location), 4)}-${mgmtRgName}'
  scope: subscription(connsubid)
  params: {
    name: mgmtRgName
    location: location
    tags: ccsCombinedTags
  }
}
*/
