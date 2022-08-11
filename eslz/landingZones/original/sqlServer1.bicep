@secure()
param vulnerabilityAssessments_Default_storageContainerPath string
param servers_sql_ccs_prod_usva_lz01_name string = 'sql-ccs-prod-usva-lz01'
param servers_sql_ccs_prod_usva_lz02_externalid string = '/subscriptions/df3b1809-17d0-47a0-9241-d2724780bdac/resourceGroups/rg-ccs-prod-usva-wl01/providers/Microsoft.Sql/servers/sql-ccs-prod-usva-lz02'

resource servers_sql_ccs_prod_usva_lz01_name_resource 'Microsoft.Sql/servers@2021-11-01-preview' = {
  name: servers_sql_ccs_prod_usva_lz01_name
  location: 'usgovvirginia'
  tags: {
    CreatedOn: 'Wednesday, 10 August 2022 22:55:18'
    Customer: 'LZ Customer'
    ProjectID: 'LZ01'
    ProjectName: 'LZ Prod Workload'
    SecurityContactEmail: 'lz-1669@azgperatonpartners.onmicrosoft.us'
    TechContactEmail: 'lz-1669@azgperatonpartners.onmicrosoft.us'
  }
  kind: 'v12.0'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    administratorLogin: 'sqladmin'
    version: '12.0'
    minimalTlsVersion: '1.2'
    publicNetworkAccess: 'Enabled'
    administrators: {
      administratorType: 'ActiveDirectory'
      principalType: 'Group'
      login: 'IRAD01 SQL Server Admins'
      sid: '8c482db7-2379-405d-b681-e205b2d9f945'
      tenantId: '624e5a3d-aa66-4393-9eba-9fb802780e70'
      azureADOnlyAuthentication: false
    }
    restrictOutboundNetworkAccess: 'Disabled'
  }
}

resource servers_sql_ccs_prod_usva_lz01_name_ActiveDirectory 'Microsoft.Sql/servers/administrators@2021-11-01-preview' = {
  parent: servers_sql_ccs_prod_usva_lz01_name_resource
  name: 'ActiveDirectory'
  properties: {
    administratorType: 'ActiveDirectory'
    login: 'IRAD01 SQL Server Admins'
    sid: '8c482db7-2379-405d-b681-e205b2d9f945'
    tenantId: '624e5a3d-aa66-4393-9eba-9fb802780e70'
  }
}

resource servers_sql_ccs_prod_usva_lz01_name_Default 'Microsoft.Sql/servers/advancedThreatProtectionSettings@2021-11-01-preview' = {
  parent: servers_sql_ccs_prod_usva_lz01_name_resource
  name: 'Default'
  properties: {
    state: 'Disabled'
  }
}

resource servers_sql_ccs_prod_usva_lz01_name_CreateIndex 'Microsoft.Sql/servers/advisors@2014-04-01' = {
  parent: servers_sql_ccs_prod_usva_lz01_name_resource
  name: 'CreateIndex'
  properties: {
    autoExecuteValue: 'Disabled'
  }
}

resource servers_sql_ccs_prod_usva_lz01_name_DbParameterization 'Microsoft.Sql/servers/advisors@2014-04-01' = {
  parent: servers_sql_ccs_prod_usva_lz01_name_resource
  name: 'DbParameterization'
  properties: {
    autoExecuteValue: 'Disabled'
  }
}

resource servers_sql_ccs_prod_usva_lz01_name_DefragmentIndex 'Microsoft.Sql/servers/advisors@2014-04-01' = {
  parent: servers_sql_ccs_prod_usva_lz01_name_resource
  name: 'DefragmentIndex'
  properties: {
    autoExecuteValue: 'Disabled'
  }
}

resource servers_sql_ccs_prod_usva_lz01_name_DropIndex 'Microsoft.Sql/servers/advisors@2014-04-01' = {
  parent: servers_sql_ccs_prod_usva_lz01_name_resource
  name: 'DropIndex'
  properties: {
    autoExecuteValue: 'Disabled'
  }
}

resource servers_sql_ccs_prod_usva_lz01_name_ForceLastGoodPlan 'Microsoft.Sql/servers/advisors@2014-04-01' = {
  parent: servers_sql_ccs_prod_usva_lz01_name_resource
  name: 'ForceLastGoodPlan'
  properties: {
    autoExecuteValue: 'Enabled'
  }
}

resource Microsoft_Sql_servers_auditingPolicies_servers_sql_ccs_prod_usva_lz01_name_Default 'Microsoft.Sql/servers/auditingPolicies@2014-04-01' = {
  parent: servers_sql_ccs_prod_usva_lz01_name_resource
  name: 'Default'
  location: 'USGov Virginia'
  properties: {
    auditingState: 'Disabled'
  }
}

resource Microsoft_Sql_servers_auditingSettings_servers_sql_ccs_prod_usva_lz01_name_Default 'Microsoft.Sql/servers/auditingSettings@2021-11-01-preview' = {
  parent: servers_sql_ccs_prod_usva_lz01_name_resource
  name: 'default'
  properties: {
    retentionDays: 0
    auditActionsAndGroups: []
    isStorageSecondaryKeyInUse: false
    isAzureMonitorTargetEnabled: false
    isManagedIdentityInUse: false
    state: 'Disabled'
    storageAccountSubscriptionId: '00000000-0000-0000-0000-000000000000'
  }
}

resource Microsoft_Sql_servers_azureADOnlyAuthentications_servers_sql_ccs_prod_usva_lz01_name_Default 'Microsoft.Sql/servers/azureADOnlyAuthentications@2021-11-01-preview' = {
  parent: servers_sql_ccs_prod_usva_lz01_name_resource
  name: 'Default'
  properties: {
    azureADOnlyAuthentication: false
  }
}

resource Microsoft_Sql_servers_connectionPolicies_servers_sql_ccs_prod_usva_lz01_name_default 'Microsoft.Sql/servers/connectionPolicies@2021-11-01-preview' = {
  parent: servers_sql_ccs_prod_usva_lz01_name_resource
  name: 'default'
  location: 'usgovvirginia'
  properties: {
    connectionType: 'Default'
  }
}

resource servers_sql_ccs_prod_usva_lz01_name_sqldb_ccs_prod_usva_lz01 'Microsoft.Sql/servers/databases@2021-11-01-preview' = {
  parent: servers_sql_ccs_prod_usva_lz01_name_resource
  name: 'sqldb-ccs-prod-usva-lz01'
  location: 'usgovvirginia'
  tags: {
    CreatedOn: 'Wednesday, 10 August 2022 22:55:18'
    Customer: 'LZ Customer'
    ProjectID: 'LZ01'
    ProjectName: 'LZ Prod Workload'
    SecurityContactEmail: 'lz-1669@azgperatonpartners.onmicrosoft.us'
    TechContactEmail: 'lz-1669@azgperatonpartners.onmicrosoft.us'
  }
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

resource servers_sql_ccs_prod_usva_lz01_name_master_Default 'Microsoft.Sql/servers/databases/advancedThreatProtectionSettings@2021-11-01-preview' = {
  name: '${servers_sql_ccs_prod_usva_lz01_name}/master/Default'
  properties: {
    state: 'Disabled'
  }
  dependsOn: [
    servers_sql_ccs_prod_usva_lz01_name_resource
  ]
}

resource Microsoft_Sql_servers_databases_auditingPolicies_servers_sql_ccs_prod_usva_lz01_name_master_Default 'Microsoft.Sql/servers/databases/auditingPolicies@2014-04-01' = {
  name: '${servers_sql_ccs_prod_usva_lz01_name}/master/Default'
  location: 'USGov Virginia'
  properties: {
    auditingState: 'Disabled'
  }
  dependsOn: [
    servers_sql_ccs_prod_usva_lz01_name_resource
  ]
}

resource Microsoft_Sql_servers_databases_auditingSettings_servers_sql_ccs_prod_usva_lz01_name_master_Default 'Microsoft.Sql/servers/databases/auditingSettings@2021-11-01-preview' = {
  name: '${servers_sql_ccs_prod_usva_lz01_name}/master/Default'
  properties: {
    retentionDays: 0
    isAzureMonitorTargetEnabled: false
    state: 'Disabled'
    storageAccountSubscriptionId: '00000000-0000-0000-0000-000000000000'
  }
  dependsOn: [
    servers_sql_ccs_prod_usva_lz01_name_resource
  ]
}

resource Microsoft_Sql_servers_databases_extendedAuditingSettings_servers_sql_ccs_prod_usva_lz01_name_master_Default 'Microsoft.Sql/servers/databases/extendedAuditingSettings@2021-11-01-preview' = {
  name: '${servers_sql_ccs_prod_usva_lz01_name}/master/Default'
  properties: {
    retentionDays: 0
    isAzureMonitorTargetEnabled: false
    state: 'Disabled'
    storageAccountSubscriptionId: '00000000-0000-0000-0000-000000000000'
  }
  dependsOn: [
    servers_sql_ccs_prod_usva_lz01_name_resource
  ]
}

resource Microsoft_Sql_servers_databases_geoBackupPolicies_servers_sql_ccs_prod_usva_lz01_name_master_Default 'Microsoft.Sql/servers/databases/geoBackupPolicies@2014-04-01' = {
  name: '${servers_sql_ccs_prod_usva_lz01_name}/master/Default'
  location: 'USGov Virginia'
  properties: {
    state: 'Disabled'
  }
  dependsOn: [
    servers_sql_ccs_prod_usva_lz01_name_resource
  ]
}

resource servers_sql_ccs_prod_usva_lz01_name_master_Current 'Microsoft.Sql/servers/databases/ledgerDigestUploads@2021-11-01-preview' = {
  name: '${servers_sql_ccs_prod_usva_lz01_name}/master/Current'
  properties: {
  }
  dependsOn: [
    servers_sql_ccs_prod_usva_lz01_name_resource
  ]
}

resource Microsoft_Sql_servers_databases_securityAlertPolicies_servers_sql_ccs_prod_usva_lz01_name_master_Default 'Microsoft.Sql/servers/databases/securityAlertPolicies@2021-11-01-preview' = {
  name: '${servers_sql_ccs_prod_usva_lz01_name}/master/Default'
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
  dependsOn: [
    servers_sql_ccs_prod_usva_lz01_name_resource
  ]
}

resource Microsoft_Sql_servers_databases_transparentDataEncryption_servers_sql_ccs_prod_usva_lz01_name_master_Current 'Microsoft.Sql/servers/databases/transparentDataEncryption@2021-11-01-preview' = {
  name: '${servers_sql_ccs_prod_usva_lz01_name}/master/Current'
  properties: {
    state: 'Disabled'
  }
  dependsOn: [
    servers_sql_ccs_prod_usva_lz01_name_resource
  ]
}

resource Microsoft_Sql_servers_databases_vulnerabilityAssessments_servers_sql_ccs_prod_usva_lz01_name_master_Default 'Microsoft.Sql/servers/databases/vulnerabilityAssessments@2021-11-01-preview' = {
  name: '${servers_sql_ccs_prod_usva_lz01_name}/master/Default'
  properties: {
    recurringScans: {
      isEnabled: false
      emailSubscriptionAdmins: true
    }
  }
  dependsOn: [
    servers_sql_ccs_prod_usva_lz01_name_resource
  ]
}

resource Microsoft_Sql_servers_devOpsAuditingSettings_servers_sql_ccs_prod_usva_lz01_name_Default 'Microsoft.Sql/servers/devOpsAuditingSettings@2021-11-01-preview' = {
  parent: servers_sql_ccs_prod_usva_lz01_name_resource
  name: 'Default'
  properties: {
    isAzureMonitorTargetEnabled: false
    state: 'Disabled'
    storageAccountSubscriptionId: '00000000-0000-0000-0000-000000000000'
  }
}

resource servers_sql_ccs_prod_usva_lz01_name_current 'Microsoft.Sql/servers/encryptionProtector@2021-11-01-preview' = {
  parent: servers_sql_ccs_prod_usva_lz01_name_resource
  name: 'current'
  kind: 'servicemanaged'
  properties: {
    serverKeyName: 'ServiceManaged'
    serverKeyType: 'ServiceManaged'
    autoRotationEnabled: false
  }
}

resource Microsoft_Sql_servers_extendedAuditingSettings_servers_sql_ccs_prod_usva_lz01_name_Default 'Microsoft.Sql/servers/extendedAuditingSettings@2021-11-01-preview' = {
  parent: servers_sql_ccs_prod_usva_lz01_name_resource
  name: 'default'
  properties: {
    retentionDays: 0
    auditActionsAndGroups: []
    isStorageSecondaryKeyInUse: false
    isAzureMonitorTargetEnabled: false
    isManagedIdentityInUse: false
    state: 'Disabled'
    storageAccountSubscriptionId: '00000000-0000-0000-0000-000000000000'
  }
}

resource servers_sql_ccs_prod_usva_lz01_name_AllowAllWindowsAzureIps 'Microsoft.Sql/servers/firewallRules@2021-11-01-preview' = {
  parent: servers_sql_ccs_prod_usva_lz01_name_resource
  name: 'AllowAllWindowsAzureIps'
}

resource servers_sql_ccs_prod_usva_lz01_name_ServiceManaged 'Microsoft.Sql/servers/keys@2021-11-01-preview' = {
  parent: servers_sql_ccs_prod_usva_lz01_name_resource
  name: 'ServiceManaged'
  kind: 'servicemanaged'
  properties: {
    serverKeyType: 'ServiceManaged'
  }
}

resource Microsoft_Sql_servers_securityAlertPolicies_servers_sql_ccs_prod_usva_lz01_name_Default 'Microsoft.Sql/servers/securityAlertPolicies@2021-11-01-preview' = {
  parent: servers_sql_ccs_prod_usva_lz01_name_resource
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

resource Microsoft_Sql_servers_vulnerabilityAssessments_servers_sql_ccs_prod_usva_lz01_name_Default 'Microsoft.Sql/servers/vulnerabilityAssessments@2021-11-01-preview' = {
  parent: servers_sql_ccs_prod_usva_lz01_name_resource
  name: 'Default'
  properties: {
    recurringScans: {
      isEnabled: false
      emailSubscriptionAdmins: true
    }
    storageContainerPath: vulnerabilityAssessments_Default_storageContainerPath
  }
}

resource servers_sql_ccs_prod_usva_lz01_name_sqldb_ccs_prod_usva_lz01_Default 'Microsoft.Sql/servers/databases/advancedThreatProtectionSettings@2021-11-01-preview' = {
  parent: servers_sql_ccs_prod_usva_lz01_name_sqldb_ccs_prod_usva_lz01
  name: 'Default'
  properties: {
    state: 'Disabled'
  }
  dependsOn: [

    servers_sql_ccs_prod_usva_lz01_name_resource
  ]
}

resource servers_sql_ccs_prod_usva_lz01_name_sqldb_ccs_prod_usva_lz01_CreateIndex 'Microsoft.Sql/servers/databases/advisors@2014-04-01' = {
  parent: servers_sql_ccs_prod_usva_lz01_name_sqldb_ccs_prod_usva_lz01
  name: 'CreateIndex'
  properties: {
    autoExecuteValue: 'Disabled'
  }
  dependsOn: [

    servers_sql_ccs_prod_usva_lz01_name_resource
  ]
}

resource servers_sql_ccs_prod_usva_lz01_name_sqldb_ccs_prod_usva_lz01_DbParameterization 'Microsoft.Sql/servers/databases/advisors@2014-04-01' = {
  parent: servers_sql_ccs_prod_usva_lz01_name_sqldb_ccs_prod_usva_lz01
  name: 'DbParameterization'
  properties: {
    autoExecuteValue: 'Disabled'
  }
  dependsOn: [

    servers_sql_ccs_prod_usva_lz01_name_resource
  ]
}

resource servers_sql_ccs_prod_usva_lz01_name_sqldb_ccs_prod_usva_lz01_DefragmentIndex 'Microsoft.Sql/servers/databases/advisors@2014-04-01' = {
  parent: servers_sql_ccs_prod_usva_lz01_name_sqldb_ccs_prod_usva_lz01
  name: 'DefragmentIndex'
  properties: {
    autoExecuteValue: 'Disabled'
  }
  dependsOn: [

    servers_sql_ccs_prod_usva_lz01_name_resource
  ]
}

resource servers_sql_ccs_prod_usva_lz01_name_sqldb_ccs_prod_usva_lz01_DropIndex 'Microsoft.Sql/servers/databases/advisors@2014-04-01' = {
  parent: servers_sql_ccs_prod_usva_lz01_name_sqldb_ccs_prod_usva_lz01
  name: 'DropIndex'
  properties: {
    autoExecuteValue: 'Disabled'
  }
  dependsOn: [

    servers_sql_ccs_prod_usva_lz01_name_resource
  ]
}

resource servers_sql_ccs_prod_usva_lz01_name_sqldb_ccs_prod_usva_lz01_ForceLastGoodPlan 'Microsoft.Sql/servers/databases/advisors@2014-04-01' = {
  parent: servers_sql_ccs_prod_usva_lz01_name_sqldb_ccs_prod_usva_lz01
  name: 'ForceLastGoodPlan'
  properties: {
    autoExecuteValue: 'Enabled'
  }
  dependsOn: [

    servers_sql_ccs_prod_usva_lz01_name_resource
  ]
}

resource Microsoft_Sql_servers_databases_auditingPolicies_servers_sql_ccs_prod_usva_lz01_name_sqldb_ccs_prod_usva_lz01_Default 'Microsoft.Sql/servers/databases/auditingPolicies@2014-04-01' = {
  parent: servers_sql_ccs_prod_usva_lz01_name_sqldb_ccs_prod_usva_lz01
  name: 'Default'
  location: 'USGov Virginia'
  properties: {
    auditingState: 'Disabled'
  }
  dependsOn: [

    servers_sql_ccs_prod_usva_lz01_name_resource
  ]
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
  dependsOn: [

    servers_sql_ccs_prod_usva_lz01_name_resource
  ]
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
  dependsOn: [

    servers_sql_ccs_prod_usva_lz01_name_resource
  ]
}

resource Microsoft_Sql_servers_databases_backupShortTermRetentionPolicies_servers_sql_ccs_prod_usva_lz01_name_sqldb_ccs_prod_usva_lz01_default 'Microsoft.Sql/servers/databases/backupShortTermRetentionPolicies@2021-11-01-preview' = {
  parent: servers_sql_ccs_prod_usva_lz01_name_sqldb_ccs_prod_usva_lz01
  name: 'default'
  properties: {
    retentionDays: 7
    diffBackupIntervalInHours: 12
  }
  dependsOn: [

    servers_sql_ccs_prod_usva_lz01_name_resource
  ]
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
  dependsOn: [

    servers_sql_ccs_prod_usva_lz01_name_resource
  ]
}

resource Microsoft_Sql_servers_databases_geoBackupPolicies_servers_sql_ccs_prod_usva_lz01_name_sqldb_ccs_prod_usva_lz01_Default 'Microsoft.Sql/servers/databases/geoBackupPolicies@2014-04-01' = {
  parent: servers_sql_ccs_prod_usva_lz01_name_sqldb_ccs_prod_usva_lz01
  name: 'Default'
  location: 'USGov Virginia'
  properties: {
    state: 'Enabled'
  }
  dependsOn: [

    servers_sql_ccs_prod_usva_lz01_name_resource
  ]
}

resource servers_sql_ccs_prod_usva_lz01_name_sqldb_ccs_prod_usva_lz01_Current 'Microsoft.Sql/servers/databases/ledgerDigestUploads@2021-11-01-preview' = {
  parent: servers_sql_ccs_prod_usva_lz01_name_sqldb_ccs_prod_usva_lz01
  name: 'Current'
  properties: {
  }
  dependsOn: [

    servers_sql_ccs_prod_usva_lz01_name_resource
  ]
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
  dependsOn: [

    servers_sql_ccs_prod_usva_lz01_name_resource
  ]
}

resource Microsoft_Sql_servers_databases_transparentDataEncryption_servers_sql_ccs_prod_usva_lz01_name_sqldb_ccs_prod_usva_lz01_Current 'Microsoft.Sql/servers/databases/transparentDataEncryption@2021-11-01-preview' = {
  parent: servers_sql_ccs_prod_usva_lz01_name_sqldb_ccs_prod_usva_lz01
  name: 'Current'
  properties: {
    state: 'Enabled'
  }
  dependsOn: [

    servers_sql_ccs_prod_usva_lz01_name_resource
  ]
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
  dependsOn: [

    servers_sql_ccs_prod_usva_lz01_name_resource
  ]
}

resource servers_sql_ccs_prod_usva_lz01_name_ccsprodfailovergrop 'Microsoft.Sql/servers/failoverGroups@2021-11-01-preview' = {
  parent: servers_sql_ccs_prod_usva_lz01_name_resource
  name: 'ccsprodfailovergrop'
  location: 'USGov Virginia'
  properties: {
    readWriteEndpoint: {
      failoverPolicy: 'Automatic'
      failoverWithDataLossGracePeriodMinutes: 60
    }
    readOnlyEndpoint: {
      failoverPolicy: 'Disabled'
    }
    partnerServers: [
      {
        id: servers_sql_ccs_prod_usva_lz02_externalid
      }
    ]
    databases: [
      servers_sql_ccs_prod_usva_lz01_name_sqldb_ccs_prod_usva_lz01.id
    ]
  }
}