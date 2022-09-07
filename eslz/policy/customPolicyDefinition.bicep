targetScope = 'managementGroup'

@description('Required. Location for all resources.')
param location string

@description('The management group scope to which the policy definitions are to be created at.')
param targetMgId string

@description('The management group resourceId.')
var targetMgResourceId = tenantResourceId('Microsoft.Management/managementGroups', targetMgId)

@description('Variable containing all Custom Policy Definitions info.')
var customPolicyDefinitions = [
  {
    name: 'Append-AppService-httpsonly'
    definition: json(loadTextContent('policyDefinitions/policy-def-Append-AppService-httpsonly.json'))
  }
  {
    name: 'Append-AppService-latestTLS'
    definition: json(loadTextContent('policyDefinitions/policy-def-Append-AppService-latestTLS.json'))
  }
  {
    name: 'Append-KV-SoftDelete'
    definition: json(loadTextContent('policyDefinitions/policy-def-Append-KV-SoftDelete.json'))
  }
  {
    name: 'Append-Redis-disableNonSslPort'
    definition: json(loadTextContent('policyDefinitions/policy-def-Append-Redis-disableNonSslPort.json'))
  }
  {
    name: 'Append-Redis-sslEnforcement'
    definition: json(loadTextContent('policyDefinitions/policy-def-Append-Redis-sslEnforcement.json'))
  }
  {
    name: 'Deny-AA-child-resources'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deny-AA-child-resources.json'))
  }
  {
    name: 'Deny-AppGW-Without-WAF'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deny-AppGW-Without-WAF.json'))
  }
  {
    name: 'Deny-AppServiceApiApp-http'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deny-AppServiceApiApp-http.json'))
  }
  {
    name: 'Deny-AppServiceFunctionApp-http'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deny-AppServiceFunctionApp-http.json'))
  }
  {
    name: 'Deny-AppServiceWebApp-http'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deny-AppServiceWebApp-http.json'))
  }
  {
    name: 'Deny-MySql-http'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deny-MySql-http.json'))
  }
  {
    name: 'Deny-PostgreSql-http'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deny-PostgreSql-http.json'))
  }
  {
    name: 'Deny-Private-DNS-Zones'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deny-Private-DNS-Zones.json'))
  }
  {
    name: 'Deny-PublicEndpoint-MariaDB'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deny-PublicEndpoint-MariaDB.json'))
  }
  {
    name: 'Deny-PublicIP'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deny-PublicIP.json'))
  }
  {
    name: 'Deny-RDP-From-Internet'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deny-RDP-From-Internet.json'))
  }
  {
    name: 'Deny-Redis-http'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deny-Redis-http.json'))
  }
  {
    name: 'Deny-Sql-minTLS'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deny-Sql-minTLS.json'))
  }
  {
    name: 'Deny-SqlMi-minTLS'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deny-SqlMi-minTLS.json'))
  }
  {
    name: 'Deny-Storage-minTLS'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deny-Storage-minTLS.json'))
  }
  {
    name: 'Deny-Subnet-Without-Nsg'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deny-Subnet-Without-Nsg.json'))
  }
  {
    name: 'Deny-Subnet-Without-Udr'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deny-Subnet-Without-Udr.json'))
  }
  {
    name: 'Deny-VNET-Peer-Cross-Sub'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deny-VNET-Peer-Cross-Sub.json'))
  }
  {
    name: 'Deny-VNET-Peering-To-Non-Approved-VNETs'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deny-VNET-Peering-To-Non-Approved-VNETs.json'))
  }
  {
    name: 'Deny-VNet-Peering'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deny-VNet-Peering.json'))
  }
  {
    name: 'Deploy-ASC-SecurityContacts'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-ASC-SecurityContacts.json'))
  }
  {
    name: 'Deploy-Budget'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Budget.json'))
  }
  {
    name: 'Deploy-DDoSProtection'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-DDoSProtection.json'))
  }
  {
    name: 'Deploy-Default-Udr'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Default-Udr.json'))
  }
  {
    name: 'Deploy-FirewallPolicy'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-FirewallPolicy.json'))
  }
  {
    name: 'Deploy-MySQL-sslEnforcement'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-MySQL-sslEnforcement.json'))
  }
  {
    name: 'Deploy-Nsg-FlowLogs-to-LA'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Nsg-FlowLogs-to-LA.json'))
  }
  {
    name: 'Deploy-Nsg-FlowLogs'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Nsg-FlowLogs.json'))
  }
  {
    name: 'Deploy-PostgreSQL-sslEnforcement'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-PostgreSQL-sslEnforcement.json'))
  }
  {
    name: 'Deploy-Sql-AuditingSettings'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Sql-AuditingSettings.json'))
  }
  {
    name: 'Deploy-SQL-minTLS'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-SQL-minTLS.json'))
  }
  {
    name: 'Deploy-Sql-SecurityAlertPolicies'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Sql-SecurityAlertPolicies.json'))
  }
  {
    name: 'Deploy-Sql-Tde'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Sql-Tde.json'))
  }
  {
    name: 'Deploy-Sql-vulnerabilityAssessments'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Sql-vulnerabilityAssessments.json'))
  }
  {
    name: 'Deploy-SqlMi-minTLS'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-SqlMi-minTLS.json'))
  }
  {
    name: 'Deploy-Storage-sslEnforcement'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Storage-sslEnforcement.json'))
  }
  {
    name: 'Deploy-VNET-HubSpoke'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-VNET-HubSpoke.json'))
  }
  {
    name: 'Deploy-Windows-DomainJoin'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Windows-DomainJoin.json'))
  }
  {
    name: 'Deploy-VM-Backup'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-VM-Backup.json'))
  }
  {
    name: 'Deploy-AzureActivity'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-AzureActivity.json'))
  }
]

@description('Variable containing all Custom Policy-Set Definitions info.')
var customPolicySetDefinitions = [
  {
    name: 'Deploy-MDFC-Config'
    setDefinition: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-MDFC-Config.json'))
    setChildDefinitions: [
      {
        definitionReferenceId: 'ascExport'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/ffb6f416-7bd2-4488-8828-56585fef2be9'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-MDFC-Config.parameters.json')).ascExport.parameters
      }
      {
        definitionReferenceId: 'defenderForArm'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/b7021b2b-08fd-4dc0-9de7-3c6ece09faf9'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-MDFC-Config.parameters.json')).defenderForArm.parameters
      }
      {
        definitionReferenceId: 'defenderForContainers'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/c9ddb292-b203-4738-aead-18e2716e858f'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-MDFC-Config.parameters.json')).defenderForContainers.parameters
      }
      {
        definitionReferenceId: 'defenderForDns'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/2370a3c1-4a25-4283-a91a-c9c1a145fb2f'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-MDFC-Config.parameters.json')).defenderForDns.parameters
      }
      {
        definitionReferenceId: 'defenderForSqlPaas'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/b99b73e7-074b-4089-9395-b7236f094491'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-MDFC-Config.parameters.json')).defenderForSqlPaas.parameters
      }
      {
        definitionReferenceId: 'defenderForStorageAccounts'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/74c30959-af11-47b3-9ed2-a26e03f427a3'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-MDFC-Config.parameters.json')).defenderForStorageAccounts.parameters
      }
      {
        definitionReferenceId: 'defenderForVM'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/8e86a5b6-b9bd-49d1-8e21-4bb8a0862222'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-MDFC-Config.parameters.json')).defenderForVM.parameters
      }
      {
        definitionReferenceId: 'securityEmailContact'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-ASC-SecurityContacts'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-MDFC-Config.parameters.json')).securityEmailContact.parameters
      }
    ]
  }
  {
    name: 'Deploy-Sql-Security'
    setDefinition: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Sql-Security.json'))
    setChildDefinitions: [
      {
        definitionReferenceId: 'SqlDbAuditingSettingsDeploySqlSecurity'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Sql-AuditingSettings'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Sql-Security.parameters.json')).SqlDbAuditingSettingsDeploySqlSecurity.parameters
      }
      {
        definitionReferenceId: 'SqlDbSecurityAlertPoliciesDeploySqlSecurity'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Sql-SecurityAlertPolicies'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Sql-Security.parameters.json')).SqlDbSecurityAlertPoliciesDeploySqlSecurity.parameters
      }
      {
        definitionReferenceId: 'SqlDbTdeDeploySqlSecurity'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Sql-Tde'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Sql-Security.parameters.json')).SqlDbTdeDeploySqlSecurity.parameters
      }
      {
        definitionReferenceId: 'SqlDbVulnerabilityAssessmentsDeploySqlSecurity'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Sql-vulnerabilityAssessments'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Sql-Security.parameters.json')).SqlDbVulnerabilityAssessmentsDeploySqlSecurity.parameters
      }
    ]
  }
  {
    name: 'Enforce-Encryption-CMK'
    setDefinition: json(loadTextContent('policySetDefinitions/policy-defset-Enforce-Encryption-CMK.json'))
    setChildDefinitions: [
      {
        definitionReferenceId: 'ACRCmkDeny'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/5b9159ae-1701-4a6f-9a7a-aa9c8ddd0580'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Enforce-Encryption-CMK.parameters.json')).ACRCmkDeny.parameters
      }
      {
        definitionReferenceId: 'AksCmkDeny'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/7d7be79c-23ba-4033-84dd-45e2a5ccdd67'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Enforce-Encryption-CMK.parameters.json')).AksCmkDeny.parameters
      }
      {
        definitionReferenceId: 'AzureBatchCMKEffect'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/99e9ccd8-3db9-4592-b0d1-14b1715a4d8a'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Enforce-Encryption-CMK.parameters.json')).AzureBatchCMKEffect.parameters
      }
      {
        definitionReferenceId: 'CognitiveServicesCMK'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/67121cc7-ff39-4ab8-b7e3-95b84dab487d'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Enforce-Encryption-CMK.parameters.json')).CognitiveServicesCMK.parameters
      }
      {
        definitionReferenceId: 'CosmosCMKEffect'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/1f905d99-2ab7-462c-a6b0-f709acca6c8f'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Enforce-Encryption-CMK.parameters.json')).CosmosCMKEffect.parameters
      }
      {
        definitionReferenceId: 'DataBoxCMKEffect'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/86efb160-8de7-451d-bc08-5d475b0aadae'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Enforce-Encryption-CMK.parameters.json')).DataBoxCMKEffect.parameters
      }
      {
        definitionReferenceId: 'EncryptedVMDisksEffect'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/0961003e-5a0a-4549-abde-af6a37f2724d'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Enforce-Encryption-CMK.parameters.json')).EncryptedVMDisksEffect.parameters
      }
      {
        definitionReferenceId: 'SqlServerTDECMKEffect'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/0d134df8-db83-46fb-ad72-fe0c9428c8dd'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Enforce-Encryption-CMK.parameters.json')).SqlServerTDECMKEffect.parameters
      }
      {
        definitionReferenceId: 'StorageCMKEffect'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/6fac406b-40ca-413b-bf8e-0bf964659c25'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Enforce-Encryption-CMK.parameters.json')).StorageCMKEffect.parameters
      }
      {
        definitionReferenceId: 'StreamAnalyticsCMKEffect'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/87ba29ef-1ab3-4d82-b763-87fcd4f531f7'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Enforce-Encryption-CMK.parameters.json')).StreamAnalyticsCMKEffect.parameters
      }
      {
        definitionReferenceId: 'SynapseWorkspaceCMKEffect'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/f7d52b2d-e161-4dfa-a82b-55e564167385'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Enforce-Encryption-CMK.parameters.json')).SynapseWorkspaceCMKEffect.parameters
      }
      {
        definitionReferenceId: 'WorkspaceCMK'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/ba769a63-b8cc-4b2d-abf6-ac33c7204be8'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Enforce-Encryption-CMK.parameters.json')).WorkspaceCMK.parameters
      }
    ]
  }
  {
    name: 'Enforce-EncryptTransit'
    setDefinition: json(loadTextContent('policySetDefinitions/policy-defset-Enforce-EncryptTransit.json'))
    setChildDefinitions: [
      {
        definitionReferenceId: 'AKSIngressHttpsOnlyEffect'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/1a5b4dca-0b6f-4cf5-907c-56316bc1bf3d'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Enforce-EncryptTransit.parameters.json')).AKSIngressHttpsOnlyEffect.parameters
      }
      {
        definitionReferenceId: 'APIAppServiceHttpsEffect'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deny-AppServiceApiApp-http'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Enforce-EncryptTransit.parameters.json')).APIAppServiceHttpsEffect.parameters
      }
      {
        definitionReferenceId: 'APIAppServiceLatestTlsEffect'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/8cb6aa8b-9e41-4f4e-aa25-089a7ac2581e'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Enforce-EncryptTransit.parameters.json')).APIAppServiceLatestTlsEffect.parameters
      }
      {
        definitionReferenceId: 'AppServiceHttpEffect'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Append-AppService-httpsonly'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Enforce-EncryptTransit.parameters.json')).AppServiceHttpEffect.parameters
      }
      {
        definitionReferenceId: 'AppServiceminTlsVersion'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Append-AppService-latestTLS'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Enforce-EncryptTransit.parameters.json')).AppServiceminTlsVersion.parameters
      }
      {
        definitionReferenceId: 'FunctionLatestTlsEffect'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/f9d614c5-c173-4d56-95a7-b4437057d193'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Enforce-EncryptTransit.parameters.json')).FunctionLatestTlsEffect.parameters
      }
      {
        definitionReferenceId: 'FunctionServiceHttpsEffect'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deny-AppServiceFunctionApp-http'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Enforce-EncryptTransit.parameters.json')).FunctionServiceHttpsEffect.parameters
      }
      {
        definitionReferenceId: 'MySQLEnableSSLDeployEffect'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-MySQL-sslEnforcement'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Enforce-EncryptTransit.parameters.json')).MySQLEnableSSLDeployEffect.parameters
      }
      {
        definitionReferenceId: 'MySQLEnableSSLEffect'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deny-MySql-http'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Enforce-EncryptTransit.parameters.json')).MySQLEnableSSLEffect.parameters
      }
      {
        definitionReferenceId: 'PostgreSQLEnableSSLDeployEffect'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-PostgreSQL-sslEnforcement'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Enforce-EncryptTransit.parameters.json')).PostgreSQLEnableSSLDeployEffect.parameters
      }
      {
        definitionReferenceId: 'PostgreSQLEnableSSLEffect'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deny-PostgreSql-http'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Enforce-EncryptTransit.parameters.json')).PostgreSQLEnableSSLEffect.parameters
      }
      {
        definitionReferenceId: 'RedisDenyhttps'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deny-Redis-http'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Enforce-EncryptTransit.parameters.json')).RedisDenyhttps.parameters
      }
      {
        definitionReferenceId: 'RedisdisableNonSslPort'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Append-Redis-disableNonSslPort'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Enforce-EncryptTransit.parameters.json')).RedisdisableNonSslPort.parameters
      }
      {
        definitionReferenceId: 'RedisTLSDeployEffect'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Append-Redis-sslEnforcement'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Enforce-EncryptTransit.parameters.json')).RedisTLSDeployEffect.parameters
      }
      {
        definitionReferenceId: 'SQLManagedInstanceTLSDeployEffect'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-SqlMi-minTLS'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Enforce-EncryptTransit.parameters.json')).SQLManagedInstanceTLSDeployEffect.parameters
      }
      {
        definitionReferenceId: 'SQLManagedInstanceTLSEffect'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deny-SqlMi-minTLS'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Enforce-EncryptTransit.parameters.json')).SQLManagedInstanceTLSEffect.parameters
      }
      {
        definitionReferenceId: 'SQLServerTLSDeployEffect'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-SQL-minTLS'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Enforce-EncryptTransit.parameters.json')).SQLServerTLSDeployEffect.parameters
      }
      {
        definitionReferenceId: 'SQLServerTLSEffect'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deny-Sql-minTLS'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Enforce-EncryptTransit.parameters.json')).SQLServerTLSEffect.parameters
      }
      {
        definitionReferenceId: 'StorageDeployHttpsEnabledEffect'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Storage-sslEnforcement'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Enforce-EncryptTransit.parameters.json')).StorageDeployHttpsEnabledEffect.parameters
      }
      {
        definitionReferenceId: 'StorageHttpsEnabledEffect'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deny-Storage-minTLS'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Enforce-EncryptTransit.parameters.json')).StorageHttpsEnabledEffect.parameters
      }
      {
        definitionReferenceId: 'WebAppServiceHttpsEffect'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deny-AppServiceWebApp-http'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Enforce-EncryptTransit.parameters.json')).WebAppServiceHttpsEffect.parameters
      }
      {
        definitionReferenceId: 'WebAppServiceLatestTlsEffect'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/f0e6e85b-9b9f-4a4b-b67b-f730d42f1b0b'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Enforce-EncryptTransit.parameters.json')).WebAppServiceLatestTlsEffect.parameters
      }
    ]
  }  
]

// 1 - Create Custom Policy Defintions
module policyDefinitions '../modules/authorization/policyDefinitions/managementGroup/deploy.bicep' = [for policy in customPolicyDefinitions: {
  name: '${policy.name}'
  params: {
    name: policy.name
    location: location
    description: policy.definition.properties.description
    displayName: policy.definition.properties.displayName
    metadata: policy.definition.properties.metadata
    mode: policy.definition.properties.mode
    parameters: policy.definition.properties.parameters
    policyRule: policy.definition.properties.policyRule
  }
}]

// 2 - Create Custom Policy-Set Defintions
module policySetDefinitions '../modules/authorization/policySetDefinitions/managementGroup/deploy.bicep' = [for policySet in customPolicySetDefinitions: {
  name: policySet.setDefinition.name
  dependsOn: [
    policyDefinitions
  ]
  params: {
    name: policySet.setDefinition.name
    location: location
    description: policySet.setDefinition.properties.description
    displayName: policySet.setDefinition.properties.displayName
    metadata: policySet.setDefinition.properties.metadata
    parameters: policySet.setDefinition.properties.parameters
    policyDefinitions: [for policySetDef in policySet.setChildDefinitions: {
      policyDefinitionReferenceId: policySetDef.definitionReferenceId
      policyDefinitionId: policySetDef.definitionId
      parameters: policySetDef.definitionParameters
    }]
    //policyDefinitionGroups: policySet.setDefinition.properties.policyDefinitionGroups
  }
}]


// Start - Outputs to supress warnings - "unused parameters"
output location string = location
// End - Outputs to supress warnings - "unused parameters"
