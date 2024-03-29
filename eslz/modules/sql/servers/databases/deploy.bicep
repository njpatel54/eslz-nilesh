@description('Required. The name of the database.')
param name string

@description('Conditional. The name of the parent SQL Server. Required if the template is used in a standalone deployment.')
param serverName string

@description('Optional. The collation of the database.')
param collation string = 'SQL_Latin1_General_CP1_CI_AS'

@description('Optional. The skuTier or edition of the particular SKU.')
param skuTier string = 'GeneralPurpose'

@description('Optional. The name of the SKU.')
param skuName string = 'GP_Gen5_2'

@description('Optional. Capacity of the particular SKU.')
param skuCapacity int = -1

@description('Optional. If the service has different generations of hardware, for the same SKU, then that can be captured here.')
param skuFamily string = ''

@description('Optional. Size of the particular SKU.')
param skuSize string = ''

@description('Optional. The max size of the database expressed in bytes.')
param maxSizeBytes int = 34359738368

@description('Optional. The name of the sample schema to apply when creating this database.')
param sampleName string = ''

@description('Optional. Whether or not this database is zone redundant.')
param zoneRedundant bool = false

@description('Optional. The license type to apply for this database.')
param licenseType string = ''

@description('Optional. The state of read-only routing.')
@allowed([
  'Enabled'
  'Disabled'
])
param readScale string = 'Disabled'

@description('Optional. The number of readonly secondary replicas associated with the database.')
param highAvailabilityReplicaCount int = 0

@description('Optional. Minimal capacity that database will always have allocated.')
param minCapacity string = ''

@description('Optional. Time in minutes after which database is automatically paused.')
param autoPauseDelay string = ''

@description('Optional. Tags of the resource.')
param tags object = {}

@description('Optional. Location for all resources.')
param location string = resourceGroup().location

@description('Optional. Specifies the number of days that logs will be kept for; a value of 0 will retain data indefinitely.')
@minValue(0)
@maxValue(365)
param diagnosticLogsRetentionInDays int = 365

@description('Optional. Resource ID of the diagnostic storage account.')
param diagnosticStorageAccountId string = ''

@description('Optional. Resource ID of the diagnostic log analytics workspace.')
param diagnosticWorkspaceId string = ''

@description('Optional. Resource ID of the diagnostic event hub authorization rule for the Event Hubs namespace in which the event hub should be created or streamed to.')
param diagnosticEventHubAuthorizationRuleId string = ''

@description('Optional. Name of the diagnostic event hub within the namespace to which logs are streamed. Without this, an event hub is created for each log category.')
param diagnosticEventHubName string = ''

@description('Optional. The name of logs that will be streamed.')
@allowed([
  'SQLInsights'
  'AutomaticTuning'
  'QueryStoreRuntimeStatistics'
  'QueryStoreWaitStatistics'
  'Errors'
  'DatabaseWaitStatistics'
  'Timeouts'
  'Blocks'
  'Deadlocks'
  'DevOpsOperationsAudit'
  'SQLSecurityAuditEvents'
])
param diagnosticLogCategoriesToEnable array = [
  'SQLInsights'
  'AutomaticTuning'
  'QueryStoreRuntimeStatistics'
  'QueryStoreWaitStatistics'
  'Errors'
  'DatabaseWaitStatistics'
  'Timeouts'
  'Blocks'
  'Deadlocks'
  'DevOpsOperationsAudit'
  'SQLSecurityAuditEvents'
]

@description('Optional. The name of metrics that will be streamed.')
@allowed([
  'Basic'
  'InstanceAndAppAdvanced'
  'WorkloadManagement'
])
param diagnosticMetricsToEnable array = [
  'Basic'
  'InstanceAndAppAdvanced'
  'WorkloadManagement'
]

@description('Optional. The name of the diagnostic setting, if deployed.')
param diagnosticSettingsName string = '${name}-diagnosticSettings'

var diagnosticsLogs = [for category in diagnosticLogCategoriesToEnable: {
  category: category
  enabled: true
  retentionPolicy: {
    enabled: true
    days: diagnosticLogsRetentionInDays
  }
}]

var diagnosticsMetrics = [for metric in diagnosticMetricsToEnable: {
  category: metric
  timeGrain: null
  enabled: true
  retentionPolicy: {
    enabled: true
    days: diagnosticLogsRetentionInDays
  }
}]

@description('Required. Specifies the Actions-Groups and Actions to audit.')
@allowed([
  'APPLICATION_ROLE_CHANGE_PASSWORD_GROUP'
  'BACKUP_RESTORE_GROUP'
  'DATABASE_LOGOUT_GROUP'
  'DATABASE_OBJECT_CHANGE_GROUP'
  'DATABASE_OBJECT_OWNERSHIP_CHANGE_GROUP'
  'DATABASE_OBJECT_PERMISSION_CHANGE_GROUP'
  'DATABASE_OPERATION_GROUP'
  'DATABASE_PERMISSION_CHANGE_GROUP'
  'DATABASE_PRINCIPAL_CHANGE_GROUP'
  'DATABASE_PRINCIPAL_IMPERSONATION_GROUP'
  'DATABASE_ROLE_MEMBER_CHANGE_GROUP'
  'FAILED_DATABASE_AUTHENTICATION_GROUP'
  'SCHEMA_OBJECT_ACCESS_GROUP'
  'SCHEMA_OBJECT_CHANGE_GROUP'
  'SCHEMA_OBJECT_OWNERSHIP_CHANGE_GROUP'
  'SCHEMA_OBJECT_PERMISSION_CHANGE_GROUP'
  'SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP'
  'USER_CHANGE_PASSWORD_GROUP'
  'BATCH_STARTED_GROUP'
  'BATCH_COMPLETED_GROUP'
  'DBCC_GROUP'
  'DATABASE_OWNERSHIP_CHANGE_GROUP'
  'DATABASE_CHANGE_GROUP'
  'LEDGER_OPERATION_GROUP'
])
param auditActionsAndGroups array = [
  'BATCH_COMPLETED_GROUP'
  'SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP'
  'FAILED_DATABASE_AUTHENTICATION_GROUP'
]

@description('Optional. The storage account type to be used to store backups for this database.')
@allowed([
  'Geo'
  'Local'
  'Zone'
  ''
])
param requestedBackupStorageRedundancy string = ''

@description('Optional. Whether or not this database is a ledger database, which means all tables in the database are ledger tables. Note: the value of this property cannot be changed after the database has been created.')
param isLedgerOn bool = false

@description('Optional. Maintenance configuration ID assigned to the database. This configuration defines the period when the maintenance updates will occur.')
param maintenanceConfigurationId string = ''

// The SKU object must be built in a variable
// The alternative, 'null' as default values, leads to non-terminating deployments
var skuVar = union({
    name: skuName
    tier: skuTier
  }, (skuCapacity != -1) ? {
    capacity: skuCapacity
  } : !empty(skuFamily) ? {
    family: skuFamily
  } : !empty(skuSize) ? {
    size: skuSize
  } : {})

resource server 'Microsoft.Sql/servers@2021-05-01-preview' existing = {
  name: serverName
}

resource database 'Microsoft.Sql/servers/databases@2021-02-01-preview' = {
  name: name
  parent: server
  location: location
  tags: tags
  properties: {
    collation: collation
    maxSizeBytes: maxSizeBytes
    sampleName: sampleName
    zoneRedundant: zoneRedundant
    licenseType: licenseType
    readScale: readScale
    minCapacity: !empty(minCapacity) ? json(minCapacity) : 0
    autoPauseDelay: !empty(autoPauseDelay) ? json(autoPauseDelay) : 0
    highAvailabilityReplicaCount: highAvailabilityReplicaCount
    requestedBackupStorageRedundancy: any(requestedBackupStorageRedundancy)
    isLedgerOn: isLedgerOn
    maintenanceConfigurationId: !empty(maintenanceConfigurationId) ? maintenanceConfigurationId : null
  }
  sku: skuVar
}

resource database_diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if ((!empty(diagnosticStorageAccountId)) || (!empty(diagnosticWorkspaceId)) || (!empty(diagnosticEventHubAuthorizationRuleId)) || (!empty(diagnosticEventHubName))) {
  name: diagnosticSettingsName
  properties: {
    storageAccountId: !empty(diagnosticStorageAccountId) ? diagnosticStorageAccountId : null
    workspaceId: !empty(diagnosticWorkspaceId) ? diagnosticWorkspaceId : null
    eventHubAuthorizationRuleId: !empty(diagnosticEventHubAuthorizationRuleId) ? diagnosticEventHubAuthorizationRuleId : null
    eventHubName: !empty(diagnosticEventHubName) ? diagnosticEventHubName : null
    metrics: diagnosticsMetrics
    logs: diagnosticsLogs
  }
  scope: database
}

/*
// Define server-level vs. database-level auditing policy (https://learn.microsoft.com/en-us/azure/azure-sql/database/auditing-overview?view=azuresql#server-vs-database-level)
// You should avoid enabling both server auditing and database blob auditing together, unless:
// 1. You want to use a different storage account, retention period or Log Analytics Workspace for a specific database.
// 2. You want to audit event types or categories for a specific database that differ from the rest of the databases on the server. For example, you might have table inserts that need to be audited only for a specific database.
// Otherwise, we recommended that you enable only server-level auditing and leave the database-level auditing disabled for all databases.
resource database_auditingSettings 'Microsoft.Sql/servers/databases/auditingSettings@2022-05-01-preview' = {
  name: 'default'
  parent: database
  properties: {
    auditActionsAndGroups: auditActionsAndGroups
    isAzureMonitorTargetEnabled: true
    state: 'Enabled'
  }
}
*/


@description('The name of the deployed database.')
output name string = database.name

@description('The resource ID of the deployed database.')
output resourceId string = database.id

@description('The resource group of the deployed database.')
output resourceGroupName string = resourceGroup().name

@description('The location the resource was deployed into.')
output location string = database.location
