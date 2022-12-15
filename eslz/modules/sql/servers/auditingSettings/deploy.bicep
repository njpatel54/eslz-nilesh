@description('Required. The name of the parent SQL Server. Required if the template is used in a standalone deployment.')
param sqlServerName string

@description('Required. Resource ID of the diagnostic log analytics workspace.')
param diagnosticWorkspaceId string = ''

@description('Required. The name of the diagnostic setting, if deployed.')
param diagnosticSettingsName string = 'diagnosticSettings'

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

resource masterDb 'Microsoft.Sql/servers/databases@2021-11-01-preview' existing = {
  name: '${sqlServerName}/master'
}

resource SqlDbDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: masterDb
  name: 'master-${diagnosticSettingsName}'
  properties: {
    workspaceId: !empty(diagnosticWorkspaceId) ? diagnosticWorkspaceId : null
    logs: [
      {
        category: 'SQLSecurityAuditEvents'
        enabled: true
        retentionPolicy: {
          days: 0
          enabled: false
        }
      }
      {
        category: 'DevOpsOperationsAudit'
        enabled: true
        retentionPolicy: {
          days: 0
          enabled: false
        }
      }
    ]
  }
}

resource sqlServer 'Microsoft.Sql/servers@2022-05-01-preview' existing = {
  name: sqlServerName
}

resource sqlAudit 'Microsoft.Sql/servers/auditingSettings@2021-11-01-preview'={
  name: 'default'
  parent: sqlServer
  properties:{
    isAzureMonitorTargetEnabled: true
    state:'Enabled'
    auditActionsAndGroups:auditActionsAndGroups
  }
}

resource devOpsAuditingSettings 'Microsoft.Sql/servers/devOpsAuditingSettings@2021-11-01-preview' = {
 parent: sqlServer
 name: 'default'
 properties: {
   state: 'Enabled'
   isAzureMonitorTargetEnabled: true
 }
}

