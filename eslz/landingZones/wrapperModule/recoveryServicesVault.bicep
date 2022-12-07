targetScope = 'managementGroup'

@description('subscriptionId for the deployment')
param subscriptionId string

@description('Required. Name of the resourceGroup, where centralized management components will be.')
param mgmtRgName string

@description('Location for the deployments and the resources')
param location string

@description('Required. Combine Tags in dynamoctags object with Tags from parameter file.')
param combinedTags object

@description('Required. Name of the Azure Recovery Service Vault.')
param name string

@description('Required. Name of the resourceGroup, where networking components will be.')
param vnetRgName string

@description('Required. Virtual Network name in Landing Zone Subscription.')
param vnetName string

@description('Required. Subnet name to be used for Private Endpoint.')
param mgmtSubnetName string

@description('Required. Subscription ID of Connectivity Subscription')
param connsubid string

@description('Required. Resource Group name for Private DNS Zones.')
param priDNSZonesRgName string

@description('Required. Name for the Diagnostics Setting Configuration.')
param diagSettingName string = ''

@description('Optional. Resource ID of the diagnostic log analytics workspace.')
param diagnosticWorkspaceId string = ''

@description('Required. Suffix to be used in resource naming with 4 characters.')
param suffix string

@description('Required. Name of the separate resource group to store the restore point collection of managed virtual machines - instant recovery points .')
param rpcRgName string

@description('Required. Load content from json file to iterate over "rgRoleAssignments".')
var paramsRoles = json(loadTextContent('../../roles/.parameters/customRoleAssignments.json'))

@description('Required. Iterate over "rgRoleAssignments" and build variable to store roleDefitionId for "Deploy Private Endpoint - Private DNS A Contributor" custom role.')
var priDNSAContributorRoleDefintionId = paramsRoles.parameters.rgRoleAssignments.value[0].roleDefinitionIdOrName

@description('Required. Iterate over "rgRoleAssignments" and build variable to store roleDefitionId for "Deploy Private Endpoint - Networking Permissions" custom role.')
var networkingPermsRoleDefintionId = paramsRoles.parameters.rgRoleAssignments.value[1].roleDefinitionIdOrName

var varAzBackupGeoCodes = {
  australiacentral: 'acl'
  australiacentral2: 'acl2'
  australiaeast: 'ae'
  australiasoutheast: 'ase'
  brazilsouth: 'brs'
  brazilsoutheast: 'bse'
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
  jioindiacentral: 'jic'
  jioindiawest: 'jiw'
  koreacentral: 'krc'
  koreasouth: 'krs'
  northcentralus: 'ncus'
  northeurope: 'ne'
  norwayeast: 'nwe'
  norwaywest: 'nww'
  qatarcentral: 'qac'
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
  westus3: 'wus3'
  usdodcentral: 'udc'
  usdodeast: 'ude'
  usgovarizona: 'uga'
  usgoviowa: 'ugi'
  usgovtexas: 'ugt'
  usgovvirginia: 'ugv'
  usnateast: 'exe'
  usnatwest: 'exw'
  usseceast: 'rxe'
  ussecwest: 'rxw'
  chinanorth: 'bjb'
  chinanorth2: 'bjb2'
  chinanorth3: 'bjb3'
  chinaeast: 'sha'
  chinaeast2: 'sha2'
  chinaeast3: 'sha3'
  germanycentral: 'gec'
  germanynortheast: 'gne'
}

// If region entered in parLocation and matches a lookup to varAzBackupGeoCodes then insert Azure Backup Private DNS Zone with appropriate geo code inserted alongside zones in parPrivateDnsZones. If not just return parPrivateDnsZones
var privatelinkBackup = replace('privatelink.<geoCode>.backup.windowsazure.us', '<geoCode>', '${varAzBackupGeoCodes[toLower(location)]}')

// 1. Create Recovery Services Vault
module rsv '../../modules/recoveryServices/vaults/deploy.bicep' = {
  name: 'rsv-${take(uniqueString(deployment().name, location), 4)}-${name}'
  scope: resourceGroup(subscriptionId, mgmtRgName)
  params: {
    name: name
    location: location
    tags: combinedTags
    systemAssignedIdentity: true
    backupPolicies: [
      {
        name: '${suffix}vmBackupPolicy'
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
        name: '${suffix}sqlBackupPolicy'
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
        name: '${suffix}fileShareBackupPolicy'
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
    diagnosticWorkspaceId: diagnosticWorkspaceId    
  }
}

// 2. Create Recovery Services Vault's Backup Configuration
module rsvBackupConfig '../../modules/recoveryServices/vaults/backupConfig/deploy.bicep' = {
  name: 'rsvBackupConfig-${take(uniqueString(deployment().name, location), 4)}-${name}'
  scope: resourceGroup(subscriptionId, mgmtRgName)
  params: {
    recoveryVaultName: rsv.outputs.name    
  }
}
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Grant permissions to the vault to create required private endpoints                                                                                                     //
// https://docs.microsoft.com/en-us/azure/backup/private-endpoints#grant-permissions-to-the-vault-to-create-required-private-endpoints                                     //
//                                                                                                                                                                         //
// To create the required private endpoints for Azure Backup, the vault (the Managed Identity of the vault) must have permissions to the following resource groups:        //
//                                                                                                                                                                         //     
// (1) The "Resource Group" that contains the "target VNet"                                                                                                                //   
// (2) The "Resource Group" where the "Private Endpoints are to be created"                                                                                                //
// (3) The "Resource Group" that contains the "Private DNS zones"                                                                                                          //
//                                                                                                                                                                         //
// We recommend that you grant the Contributor role for those three resource groups to the vault (managed identity).                                                       //
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// 3. Create Role Assignment for Recovery Services Vault's System Managed Identity (PrivateDNSZones RG)
module roleAssignmentPriDNSAContributor '../../modules/authorization/roleAssignments/resourceGroup/deploy.bicep' = {
  name: 'roleAssignmentPriDNSAContributor-${take(uniqueString(deployment().name, location), 4)}-${name}'
  scope: resourceGroup(connsubid, priDNSZonesRgName)
  dependsOn: [
    rsv
  ]
  params: {
    roleDefinitionIdOrName: priDNSAContributorRoleDefintionId
    principalType: 'ServicePrincipal'
    principalIds: [
      rsv.outputs.systemAssignedPrincipalId
    ]
  }
}

// 4. Create Role Assignment for Recovery Services Vault's System Managed Identity (VNet RG)
module roleAssignmentNetworkingPerms '../../modules/authorization/roleAssignments/resourceGroup/deploy.bicep' = {
  name: 'roleAssignmentNetworkingPerms-${take(uniqueString(deployment().name, location), 4)}-${name}'
  scope: resourceGroup(subscriptionId, vnetRgName)
  dependsOn: [
    rsv
  ]
  params: {
    roleDefinitionIdOrName: networkingPermsRoleDefintionId
    principalType: 'ServicePrincipal'
    principalIds: [
      rsv.outputs.systemAssignedPrincipalId
    ]
  }
}

// 5. Create Role Assignment for Recovery Services Vault's System Managed Identity (MGMT RG)
module roleAssignmentContributor '../../modules/authorization/roleAssignments/resourceGroup/deploy.bicep' = {
  name: 'roleAssignmentContributor-${take(uniqueString(deployment().name, location), 4)}-${name}'
  scope: resourceGroup(subscriptionId, mgmtRgName)
  dependsOn: [
    rsv
  ]
  params: {
    roleDefinitionIdOrName: 'Contributor'
    principalType: 'ServicePrincipal'
    principalIds: [
      rsv.outputs.systemAssignedPrincipalId
    ]
  }
}

// 6. Create Private Endpoint for Recovery Services Vault
module rsvPe '../../modules/network/privateEndpoints/deploy.bicep' = {
  name: 'rsvPe-${take(uniqueString(deployment().name, location), 4)}-${name}'
  scope: resourceGroup(subscriptionId, mgmtRgName)
  dependsOn: [
    roleAssignmentPriDNSAContributor
    roleAssignmentNetworkingPerms
    roleAssignmentContributor
  ]
  params: {
    name: '${name}-AzureBackup-pe'
    location: location
    tags: combinedTags
    serviceResourceId: rsv.outputs.resourceId
    groupIds: [
      'AzureBackup'
    ]
    subnetResourceId: resourceId(subscriptionId, vnetRgName, 'Microsoft.Network/virtualNetworks/subnets', vnetName, mgmtSubnetName)
    privateDnsZoneGroup: {
      privateDNSResourceIds: [
        resourceId(connsubid, priDNSZonesRgName, 'Microsoft.Network/privateDnsZones', privatelinkBackup)
        resourceId(connsubid, priDNSZonesRgName, 'Microsoft.Network/privateDnsZones', 'privatelink.queue.core.usgovcloudapi.net')
        resourceId(connsubid, priDNSZonesRgName, 'Microsoft.Network/privateDnsZones', 'privatelink.blob.core.usgovcloudapi.net')
      ]
    }
  }
}
