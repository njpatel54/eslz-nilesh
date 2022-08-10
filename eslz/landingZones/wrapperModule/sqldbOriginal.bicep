param servers_sql_ccs_prod_usva_lz01_name string = 'sql-ccs-prod-usva-lz01'

resource servers_sql_ccs_prod_usva_lz01_name_sqldb_ccs_prod_usva_lz01 'Microsoft.Sql/servers/databases@2021-11-01-preview' = {
  name: '${servers_sql_ccs_prod_usva_lz01_name}/sqldb-ccs-prod-usva-lz01'
  location: 'usgovvirginia'
  sku: {
    name: 'GP_Gen5'
    tier: 'GeneralPurpose'
    family: 'Gen5'
    capacity: 2
  }
  kind: 'v12.0,user,vcore'
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: 34359738368
    catalogCollation: 'SQL_Latin1_General_CP1_CI_AS'
    zoneRedundant: false
    licenseType: 'LicenseIncluded'
    readScale: 'Disabled'
    requestedBackupStorageRedundancy: 'Geo'
    maintenanceConfigurationId: '/subscriptions/df3b1809-17d0-47a0-9241-d2724780bdac/providers/Microsoft.Maintenance/publicMaintenanceConfigurations/SQL_Default'
    isLedgerOn: false
  }
}

resource servers_sql_ccs_prod_usva_lz01_name_sqldb_ccs_prod_usva_lz01_Default 'Microsoft.Sql/servers/databases/advancedThreatProtectionSettings@2021-11-01-preview' = {
  parent: servers_sql_ccs_prod_usva_lz01_name_sqldb_ccs_prod_usva_lz01
  name: 'Default'
  properties: {
    state: 'Disabled'
  }
}

resource servers_sql_ccs_prod_usva_lz01_name_sqldb_ccs_prod_usva_lz01_CreateIndex 'Microsoft.Sql/servers/databases/advisors@2014-04-01' = {
  parent: servers_sql_ccs_prod_usva_lz01_name_sqldb_ccs_prod_usva_lz01
  name: 'CreateIndex'
  properties: {
    autoExecuteValue: 'Disabled'
  }
}

resource servers_sql_ccs_prod_usva_lz01_name_sqldb_ccs_prod_usva_lz01_DbParameterization 'Microsoft.Sql/servers/databases/advisors@2014-04-01' = {
  parent: servers_sql_ccs_prod_usva_lz01_name_sqldb_ccs_prod_usva_lz01
  name: 'DbParameterization'
  properties: {
    autoExecuteValue: 'Disabled'
  }
}

resource servers_sql_ccs_prod_usva_lz01_name_sqldb_ccs_prod_usva_lz01_DefragmentIndex 'Microsoft.Sql/servers/databases/advisors@2014-04-01' = {
  parent: servers_sql_ccs_prod_usva_lz01_name_sqldb_ccs_prod_usva_lz01
  name: 'DefragmentIndex'
  properties: {
    autoExecuteValue: 'Disabled'
  }
}

resource servers_sql_ccs_prod_usva_lz01_name_sqldb_ccs_prod_usva_lz01_DropIndex 'Microsoft.Sql/servers/databases/advisors@2014-04-01' = {
  parent: servers_sql_ccs_prod_usva_lz01_name_sqldb_ccs_prod_usva_lz01
  name: 'DropIndex'
  properties: {
    autoExecuteValue: 'Disabled'
  }
}

resource servers_sql_ccs_prod_usva_lz01_name_sqldb_ccs_prod_usva_lz01_ForceLastGoodPlan 'Microsoft.Sql/servers/databases/advisors@2014-04-01' = {
  parent: servers_sql_ccs_prod_usva_lz01_name_sqldb_ccs_prod_usva_lz01
  name: 'ForceLastGoodPlan'
  properties: {
    autoExecuteValue: 'Enabled'
  }
}

resource Microsoft_Sql_servers_databases_auditingPolicies_servers_sql_ccs_prod_usva_lz01_name_sqldb_ccs_prod_usva_lz01_Default 'Microsoft.Sql/servers/databases/auditingPolicies@2014-04-01' = {
  parent: servers_sql_ccs_prod_usva_lz01_name_sqldb_ccs_prod_usva_lz01
  name: 'Default'
  location: 'USGov Virginia'
  properties: {
    auditingState: 'Disabled'
  }
}

resource Microsoft_Sql_servers_databases_auditingSettings_servers_sql_ccs_prod_usva_lz01_name_sqldb_ccs_prod_usva_lz01_Default 'Microsoft.Sql/servers/databases/auditingSettings@2021-11-01-preview' = {
  parent: servers_sql_ccs_prod_usva_lz01_name_sqldb_ccs_prod_usva_lz01
  name: 'default'
  properties: {
    retentionDays: 0
    isAzureMonitorTargetEnabled: false
    state: 'Disabled'
    storageAccountSubscriptionId: '00000000-0000-0000-0000-000000000000'
  }
}

resource Microsoft_Sql_servers_databases_backupLongTermRetentionPolicies_servers_sql_ccs_prod_usva_lz01_name_sqldb_ccs_prod_usva_lz01_default 'Microsoft.Sql/servers/databases/backupLongTermRetentionPolicies@2021-11-01-preview' = {
  parent: servers_sql_ccs_prod_usva_lz01_name_sqldb_ccs_prod_usva_lz01
  name: 'default'
  properties: {
    weeklyRetention: 'PT0S'
    monthlyRetention: 'PT0S'
    yearlyRetention: 'PT0S'
    weekOfYear: 0
  }
}

resource Microsoft_Sql_servers_databases_backupShortTermRetentionPolicies_servers_sql_ccs_prod_usva_lz01_name_sqldb_ccs_prod_usva_lz01_default 'Microsoft.Sql/servers/databases/backupShortTermRetentionPolicies@2021-11-01-preview' = {
  parent: servers_sql_ccs_prod_usva_lz01_name_sqldb_ccs_prod_usva_lz01
  name: 'default'
  properties: {
    retentionDays: 7
    diffBackupIntervalInHours: 12
  }
}

resource Microsoft_Sql_servers_databases_extendedAuditingSettings_servers_sql_ccs_prod_usva_lz01_name_sqldb_ccs_prod_usva_lz01_Default 'Microsoft.Sql/servers/databases/extendedAuditingSettings@2021-11-01-preview' = {
  parent: servers_sql_ccs_prod_usva_lz01_name_sqldb_ccs_prod_usva_lz01
  name: 'default'
  properties: {
    retentionDays: 0
    isAzureMonitorTargetEnabled: false
    state: 'Disabled'
    storageAccountSubscriptionId: '00000000-0000-0000-0000-000000000000'
  }
}

resource Microsoft_Sql_servers_databases_geoBackupPolicies_servers_sql_ccs_prod_usva_lz01_name_sqldb_ccs_prod_usva_lz01_Default 'Microsoft.Sql/servers/databases/geoBackupPolicies@2014-04-01' = {
  parent: servers_sql_ccs_prod_usva_lz01_name_sqldb_ccs_prod_usva_lz01
  name: 'Default'
  location: 'USGov Virginia'
  properties: {
    state: 'Enabled'
  }
}

resource servers_sql_ccs_prod_usva_lz01_name_sqldb_ccs_prod_usva_lz01_Current 'Microsoft.Sql/servers/databases/ledgerDigestUploads@2021-11-01-preview' = {
  parent: servers_sql_ccs_prod_usva_lz01_name_sqldb_ccs_prod_usva_lz01
  name: 'Current'
  properties: {
  }
}

resource Microsoft_Sql_servers_databases_securityAlertPolicies_servers_sql_ccs_prod_usva_lz01_name_sqldb_ccs_prod_usva_lz01_Default 'Microsoft.Sql/servers/databases/securityAlertPolicies@2021-11-01-preview' = {
  parent: servers_sql_ccs_prod_usva_lz01_name_sqldb_ccs_prod_usva_lz01
  name: 'Default'
  properties: {
    state: 'Disabled'
    disabledAlerts: [
      ''
    ]
    emailAddresses: [
      ''
    ]
    emailAccountAdmins: false
    retentionDays: 0
  }
}

resource Microsoft_Sql_servers_databases_transparentDataEncryption_servers_sql_ccs_prod_usva_lz01_name_sqldb_ccs_prod_usva_lz01_Current 'Microsoft.Sql/servers/databases/transparentDataEncryption@2021-11-01-preview' = {
  parent: servers_sql_ccs_prod_usva_lz01_name_sqldb_ccs_prod_usva_lz01
  name: 'Current'
  properties: {
    state: 'Enabled'
  }
}

resource Microsoft_Sql_servers_databases_vulnerabilityAssessments_servers_sql_ccs_prod_usva_lz01_name_sqldb_ccs_prod_usva_lz01_Default 'Microsoft.Sql/servers/databases/vulnerabilityAssessments@2021-11-01-preview' = {
  parent: servers_sql_ccs_prod_usva_lz01_name_sqldb_ccs_prod_usva_lz01
  name: 'Default'
  properties: {
    recurringScans: {
      isEnabled: false
      emailSubscriptionAdmins: true
    }
  }
}