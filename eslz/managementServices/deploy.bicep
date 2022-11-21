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

@description('Required. Storage Account Name for resource Diagnostics Settings - Log Collection.')
param stgAcctName string = toLower(take('st${projowner}${opscope}${enrollmentID}${region}logs', 24))

@description('Optional. Whether or not public network access is allowed for this resource. For security reasons it should be disabled. If not specified, it will be disabled by default if private endpoints are set.')
param stgPublicNetworkAccess string = 'Disabled'

@description('Required. Name of the Key Vault. Must be globally unique.')
@maxLength(24)
param akvName string = toLower(take('kv-${projowner}-${opscope}-${region}-siem', 24))

@description('Optional. Whether or not public network access is allowed for this resource. For security reasons it should be disabled. If not specified, it will be disabled by default if private endpoints are set.')
param kvPublicNetworkAccess string = 'Disabled'

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

// 1. Create Resoruce Groups
module siem_rg '../modules/resources/resourceGroups/deploy.bicep'= {
  name: 'rg-${take(uniqueString(deployment().name, location), 4)}-${siemRgName}'
  scope: subscription(mgmtsubid)
  params: {
    name: siemRgName
    location: location
    tags: ccsCombinedTags
  }
}

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

// 2. Create Log Analytics Workspace for Azure Sentinel
module logaSentinel '../modules/operationalInsights/workspaces/deploy.bicep' = {
  name: 'logaSentinel-${take(uniqueString(deployment().name, location), 4)}-${sentinelLawName}'
  scope: resourceGroup(mgmtsubid, siemRgName)
  dependsOn: [
    siem_rg
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

// 3. Create Log Analytics Workspace for resource Diagnostics Settings - Log Collection
module loga '../modules/operationalInsights/workspaces/deploy.bicep' = {
  name: 'loga-${take(uniqueString(deployment().name, location), 4)}-${logsLawName}'
  scope: resourceGroup(mgmtsubid, siemRgName)
  dependsOn: [
    siem_rg
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

// 4. Create Storage Account
module sa '../modules/storageAccounts/deploy.bicep' = {
  name: 'sa-${take(uniqueString(deployment().name, location), 4)}-${stgAcctName}'
  scope: resourceGroup(mgmtsubid, siemRgName)
  dependsOn: [
    loga
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

// 5. Create Event Hub Namespace and Event Hub
module eh '../modules/namespaces/deploy.bicep' = {
  name: 'eh-${take(uniqueString(deployment().name, location), 4)}-${eventhubNamespaceName}'
  scope: resourceGroup(mgmtsubid, siemRgName)
  dependsOn: [
    sa
  ]
  params: {
    location: location
    tags: ccsCombinedTags
    eventhubNamespaceName: eventhubNamespaceName
    eventHubs: eventHubs
    authorizationRules: authorizationRules
    diagnosticSettingsName: diagSettingName
    diagnosticStorageAccountId: sa.outputs.resourceId
    diagnosticWorkspaceId: loga.outputs.resourceId    
  }
}

// 6. Create Automation Account and link it to Log Analytics Workspace (LAW - Log Collection)
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
    diagnosticStorageAccountId: sa.outputs.resourceId
    diagnosticWorkspaceId: loga.outputs.resourceId
    //diagnosticEventHubName: eventHubs[0].name    //First Event Hub name from eventHubs object in parameter file.
    //diagnosticEventHubAuthorizationRuleId: resourceId(mgmtsubid, siemRgName, 'Microsoft.EventHub/namespaces/AuthorizationRules', eventhubNamespaceName, 'RootManageSharedAccessKey')
  }
}

// 7. Create Automation Account and link it to Log Analytics Workspace (LAW - Sentinel)
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
    diagnosticStorageAccountId: sa.outputs.resourceId
    diagnosticWorkspaceId: loga.outputs.resourceId
    //diagnosticEventHubName: eventHubs[0].name    //First Event Hub name from eventHubs object in parameter file.
    //diagnosticEventHubAuthorizationRuleId: resourceId(mgmtsubid, siemRgName, 'Microsoft.EventHub/namespaces/AuthorizationRules', eventhubNamespaceName, 'RootManageSharedAccessKey')
  }
}

// 8. Create Azure Key Vault
module akv '../modules/keyVault/vaults/deploy.bicep' = {
  name: 'akv-${take(uniqueString(deployment().name, location), 4)}-${akvName}'
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
      diagnosticStorageAccountId: sa.outputs.resourceId
      diagnosticWorkspaceId: loga.outputs.resourceId
      //diagnosticEventHubName: eventHubs[0].name    //First Event Hub name from eventHubs object in parameter file.
      //diagnosticEventHubAuthorizationRuleId: resourceId(mgmtsubid, siemRgName, 'Microsoft.EventHub/namespaces/AuthorizationRules', eventhubNamespaceName, 'RootManageSharedAccessKey')
    }
}

// 9. Configure Diagnostics Settings for Subscriptions
module subDiagSettings '../modules/insights/diagnosticSettings/sub.deploy.bicep' = [ for subscription in subscriptions: {
  name: 'subDiagSettings-${subscription.subscriptionId}'
  scope: subscription(subscription.subscriptionId)
  dependsOn: [
    eh
  ]
  params:{
    name: diagSettingName
    location: location
    diagnosticStorageAccountId: sa.outputs.resourceId
    diagnosticWorkspaceId: loga.outputs.resourceId
    //diagnosticEventHubName: eventHubs[0].name    //First Event Hub name from eventHubs object in parameter file.
    //diagnosticEventHubAuthorizationRuleId: resourceId(mgmtsubid, siemRgName, 'Microsoft.EventHub/namespaces/AuthorizationRules', eventhubNamespaceName, 'RootManageSharedAccessKey')
  }
}]

// 10. Configure Defender for Cloud
module defender '../modules/security/azureSecurityCenter/deploy.bicep' = [ for subscription in subscriptions: {
  name: 'defender-${take(uniqueString(deployment().name, location), 4)}-${subscription.subscriptionId}'
  scope: subscription(subscription.subscriptionId)
  params: {
    scope: '/subscriptions/${subscription.subscriptionId}'
    workspaceId: logaSentinel.outputs.resourceId
    securityContactProperties: defenderSecurityContactProperties
  }
}]


@description('The kind of data connectors that can be deployed via ARM templates: ["AmazonWebServicesCloudTrail", "AzureActivityLog", "AzureAdvancedThreatProtection", "AzureSecurityCenter", "MicrosoftCloudAppSecurity", "MicrosoftDefenderAdvancedThreatProtection", "Office365", "ThreatIntelligence"]')
param dataConnectors array = [
  // 'AmazonWebServicesCloudTrail'
  'AzureActiveDirectory'
  'AzureAdvancedThreatProtection'
  'AzureSecurityCenter'
  'MicrosoftCloudAppSecurity'
  'MicrosoftDefenderAdvancedThreatProtection'
  'Office365'
  'ThreatIntelligence'
]

// 11. Configure Sentinel Data Connectors
module sentinelDataConnectors '../modules/securityInsights/dataConnectors/deploy.bicep' = {
  name: 'sentinelDataConnectors-${take(uniqueString(deployment().name, location), 4)}'
  scope: resourceGroup(mgmtsubid, siemRgName)
  params: {
    subscriptionId: mgmtsubid
    workspaceName: sentinelLawName
    dataConnectors: dataConnectors
  }
}
// 10. Create Recovery Services Vault (Management Subscription)
module rsv_mgmt '../modules/recoveryServices/vaults/deploy.bicep' = {
  name: 'rsv-${take(uniqueString(deployment().name, location), 4)}-${mgmtVaultName}'
  scope: resourceGroup(mgmtsubid, mgmtRgName)
  dependsOn: [
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
    diagnosticStorageAccountId: sa.outputs.resourceId
    diagnosticWorkspaceId: loga.outputs.resourceId
  }
}

// 11. Create Recovery Services Vault (Shared Services Subscription)
module rsv_ssvc '../modules/recoveryServices/vaults/deploy.bicep' = {
  name: 'rsv-${take(uniqueString(deployment().name, location), 4)}-${ssvcVaultName}'
  scope: resourceGroup(ssvcsubid, mgmtRgName)
  dependsOn: [
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
    diagnosticStorageAccountId: sa.outputs.resourceId
    diagnosticWorkspaceId: loga.outputs.resourceId
  }
}

@description('Output - Name of Event Hub')
output ehnsAuthorizationId string = resourceId(mgmtsubid, siemRgName, 'Microsoft.EventHub/namespaces/AuthorizationRules', eventhubNamespaceName, 'RootManageSharedAccessKey')

@description('Output - SIEM Resource Group Name')
output siemRgName string = siem_rg.outputs.name

@description('Output - SIEM Resource Group resourceId')
output siemRgresourceId string = siem_rg.outputs.resourceId

@description('Output - Log Analytics Workspce Name - resource Diagnostics Settings - Log Collection')
output logaSentinelName string = logaSentinel.outputs.name

@description('Output - Log Analytics Workspce resourceId - resource Diagnostics Settings - Log Collection')
output logaSentinelResourceId string = logaSentinel.outputs.resourceId

@description('Output - Log Analytics Workspce Name - resource Diagnostics Settings - Log Collection')
output logaName string = loga.outputs.name

@description('Output - Log Analytics Workspce resourceId - resource Diagnostics Settings - Log Collection')
output logaResourceId string = loga.outputs.resourceId

@description('Output - Storage Account Name')
output saName string = sa.outputs.name

@description('Output - Storage Account resourceId')
output saResourceId string = sa.outputs.resourceId

@description('Output - Eventhub Namespace Name')
output ehNamespaceName string = eh.outputs.name

@description('Output - Subscription Diagnostics Settings Names Array')
output subDiagSettingsNames array = [for (subscription, i) in subscriptions: {  
  subscriptionId: subDiagSettings[i].outputs.resourceId
  diagnosticSettingsName: subDiagSettings[i].outputs.name
}]

@description('Output - Log Analytics Workspace "name"')
output akvName string = akv.outputs.name

@description('Output - Log Analytics Workspace "resoruceId"')
output akvResoruceId string = akv.outputs.resourceId

@description('Output - Log Analytics Workspace "resoruceId"')
output akvUri string = akv.outputs.uri

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
// Currently DiagnosticSettings at Management Group level is supported in Azure US Gov - (Reference - https://github.com/Azure/azure-powershell/issues/17717)
// Configure Diagnostics Settings for Management Groups
module mgDiagSettings '../modules/insights/diagnosticSettings/mg.deploy.bicep' = [ for managementGroup in managementGroups: {
  name: 'diagSettings-${managementGroup.name}'
//  scope: managementGroup(managementGroup.name)
  dependsOn: [
    siem_rg
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
*/


