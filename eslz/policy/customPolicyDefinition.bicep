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
    name: 'Deny-PublicEndpoint-ManagedDisk'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deny-PublicEndpoint-MangedDisk.json'))
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
    name: 'Modify-Deny-Disk-Export'
    definition: json(loadTextContent('policyDefinitions/policy-def-Modify-Deny-Disk-Export.json'))
  }
  {
    name: 'Deny-PrivateDNSZone-PrivateLink'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deny-DNS-Zone-With-Privatelink-Prefix.json'))
  }
  {
    name: 'Deny-Enforce-Naming-Convention'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deny-Enforce-Naming-Convention.json'))
  }

  {
    name: 'Deny-Route-NextHopVirtualAppliance'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deny-Route-NextHopVirtualAppliance.json'))
  }
  {
    name: 'Modify-RouteTable-NextHopVirtualAppliance'
    definition: json(loadTextContent('policyDefinitions/policy-def-Modify-RouteTable-NextHopVirtualAppliance.json'))
  }
  {
    name: 'Deny-NSG-Rule-Destination-443-80'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deny-NSG-Rule-Destination-443-80.json'))
  }
  {
    name: 'Deny-NSG-Rule-Destination-3389-22'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deny-NSG-Rule-Destination-3389-22.json'))
  }
  {
    name: 'Deny-NSG-Rule-With-Any-Source-Allow-Inbound'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deny-NSG-Rule-With-Any-Source-Allow-Inbound.json'))
  }
  {
    name: 'Deny-Security-Rule-to-Dest-Ports-If-Source-IP-Ranges-Not-From-List'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deny-Security-Rule-to-Specific-Dest-Ports-If-Source-IP-Ranges-Not-From-Allowed-List.json'))
  }
  {
    name: 'Deny-NSG-With-Security-Rule-to-Dest-Ports-If-Source-IP-Ranges-Not-From-List'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deny-NSG-With-Security-Rule-to-Specific-Dest-Ports-If-Source-IP-Ranges-Not-From-Allowed-List.json'))
  }
]

@description('Variable containing all Custom Policy-Set Definitions info.')
var customPolicySetDefinitions = [
  {
    name: 'Deploy-MDFC-Config'
    setDefinition: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-MDFC-Config.json'))
    setChildDefinitions: [
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
  {
    name: 'Deny-PaaS-PublicEndpoints'
    setDefinition: json(loadTextContent('policySetDefinitions/policy_defset_Deny-PublicPaaSEndpoints.json'))
    setChildDefinitions: [
      {
        definitionReferenceId: 'AppConfigurationDenyPaasPublicIP'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/3d9f5e4c-9947-4579-9539-2a7695fbc187'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_defset_Deny-PublicPaaSEndpoints.parameters.json')).AppConfigurationDenyPaasPublicIP.parameters
      }
      {
        definitionReferenceId: 'AppServiceAppsDenyPaasPublicIP'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/1b5ef780-c53c-4a64-87f3-bb9c8c8094ba'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_defset_Deny-PublicPaaSEndpoints.parameters.json')).AppServiceAppsDenyPaasPublicIP.parameters
      }
      {
        definitionReferenceId: 'AppServiceAppSlotsDenyPaasPublicIP'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/701a595d-38fb-4a66-ae6d-fb3735217622'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_defset_Deny-PublicPaaSEndpoints.parameters.json')).AppServiceAppSlotsDenyPaasPublicIP.parameters
      }
      {
        definitionReferenceId: 'AutomationAccountsDenyPaasPublicIP'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/955a914f-bf86-4f0e-acd5-e0766b0efcb6'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_defset_Deny-PublicPaaSEndpoints.parameters.json')).AutomationAccountsDenyPaasPublicIP.parameters
      }
      {
        definitionReferenceId: 'AzureCacheForRedisDenyPaasPublicIP'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/470baccb-7e51-4549-8b1a-3e5be069f663'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_defset_Deny-PublicPaaSEndpoints.parameters.json')).AzureCacheForRedisDenyPaasPublicIP.parameters
      }
      {
        definitionReferenceId: 'AzureCognitiveSearchServiceDenyPaasPublicIP'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/ee980b6d-0eca-4501-8d54-f6290fd512c3'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_defset_Deny-PublicPaaSEndpoints.parameters.json')).AzureCognitiveSearchServiceDenyPaasPublicIP.parameters
      }
      {
        definitionReferenceId: 'AzureCosmosDBDenyPaasPublicIP'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/797b37f7-06b8-444c-b1ad-fc62867f335a'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_defset_Deny-PublicPaaSEndpoints.parameters.json')).AzureCosmosDBDenyPaasPublicIP.parameters
      }
      {
        definitionReferenceId: 'AzureDataFactoryDenyPaasPublicIP'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/1cf164be-6819-4a50-b8fa-4bcaa4f98fb6'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_defset_Deny-PublicPaaSEndpoints.parameters.json')).AzureDataFactoryDenyPaasPublicIP.parameters
      }
      {
        definitionReferenceId: 'AzureEventGridDomainsDenyPaasPublicIP'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/f8f774be-6aee-492a-9e29-486ef81f3a68'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_defset_Deny-PublicPaaSEndpoints.parameters.json')).AzureEventGridDomainsDenyPaasPublicIP.parameters
      }
      {
        definitionReferenceId: 'AzureFileSyncDenyPaasPublicIP'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/21a8cd35-125e-4d13-b82d-2e19b7208bb7'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_defset_Deny-PublicPaaSEndpoints.parameters.json')).AzureFileSyncDenyPaasPublicIP.parameters
      }
      {
        definitionReferenceId: 'AzureIoTHubDenyPaasPublicIP'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/2d6830fb-07eb-48e7-8c4d-2a442b35f0fb'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_defset_Deny-PublicPaaSEndpoints.parameters.json')).AzureIoTHubDenyPaasPublicIP.parameters
      }
      {
        definitionReferenceId: 'AzureMachineLearningWorkspacesDenyPaasPublicIP'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/438c38d2-3772-465a-a9cc-7a6666a275ce'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_defset_Deny-PublicPaaSEndpoints.parameters.json')).AzureMachineLearningWorkspacesDenyPaasPublicIP.parameters
      }
      {
        definitionReferenceId: 'AzureMediaServicesDenyPaasPublicIP'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/8bfe3603-0888-404a-87ff-5c1b6b4cc5e3'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_defset_Deny-PublicPaaSEndpoints.parameters.json')).AzureMediaServicesDenyPaasPublicIP.parameters
      }
      {
        definitionReferenceId: 'AzureSignalRServiceDenyPaasPublicIP'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/21a9766a-82a5-4747-abb5-650b6dbba6d0'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_defset_Deny-PublicPaaSEndpoints.parameters.json')).AzureSignalRServiceDenyPaasPublicIP.parameters
      }
      {
        definitionReferenceId: 'AzureSQLDatabaseDenyPaasPublicIP'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/1b8ca024-1d5c-4dec-8995-b1a932b41780'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_defset_Deny-PublicPaaSEndpoints.parameters.json')).AzureSQLDatabaseDenyPaasPublicIP.parameters
      }
      {
        definitionReferenceId: 'AzureSQLManagedInstanceDenyPaasPublicIP'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/9dfea752-dd46-4766-aed1-c355fa93fb91'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_defset_Deny-PublicPaaSEndpoints.parameters.json')).AzureSQLManagedInstanceDenyPaasPublicIP.parameters
      }
      {
        definitionReferenceId: 'AzureSynapseWorkspaceDenyPaasPublicIP'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/38d8df46-cf4e-4073-8e03-48c24b29de0d'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_defset_Deny-PublicPaaSEndpoints.parameters.json')).AzureSynapseWorkspaceDenyPaasPublicIP.parameters
      }
      {
        definitionReferenceId: 'BatchAccountsDenyPaasPublicIP'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/74c5a0ae-5e48-4738-b093-65e23a060488'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_defset_Deny-PublicPaaSEndpoints.parameters.json')).BatchAccountsDenyPaasPublicIP.parameters
      }
      {
        definitionReferenceId: 'CognitiveServicesDenyPaasPublicIP'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/0725b4dd-7e76-479c-a735-68e7ee23d5ca'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_defset_Deny-PublicPaaSEndpoints.parameters.json')).CognitiveServicesDenyPaasPublicIP.parameters
      }
      {
        definitionReferenceId: 'ContainerRegistryDenyPaasPublicIP'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/0fdf0491-d080-4575-b627-ad0e843cba0f'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_defset_Deny-PublicPaaSEndpoints.parameters.json')).ContainerRegistryDenyPaasPublicIP.parameters
      }
      {
        definitionReferenceId: 'DatabricksWorkspaceDenyPaasPublicIP'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/0e7849de-b939-4c50-ab48-fc6b0f5eeba2'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_defset_Deny-PublicPaaSEndpoints.parameters.json')).DatabricksWorkspaceDenyPaasPublicIP.parameters
      }
      {
        definitionReferenceId: 'EventGridTopicsDenyPaasPublicIP'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/1adadefe-5f21-44f7-b931-a59b54ccdb45'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_defset_Deny-PublicPaaSEndpoints.parameters.json')).EventGridTopicsDenyPaasPublicIP.parameters
      }
      {
        definitionReferenceId: 'FunctionAppsDenyPaasPublicIP'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/969ac98b-88a8-449f-883c-2e9adb123127'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_defset_Deny-PublicPaaSEndpoints.parameters.json')).FunctionAppsDenyPaasPublicIP.parameters
      }
      {
        definitionReferenceId: 'FunctionAppSlotsDenyPaasPublicIP'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/11c82d0c-db9f-4d7b-97c5-f3f9aa957da2'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_defset_Deny-PublicPaaSEndpoints.parameters.json')).FunctionAppSlotsDenyPaasPublicIP.parameters
      }
      {
        definitionReferenceId: 'IoTHubDeviceProvisioningServiceDenyPaasPublicIP'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/d82101f3-f3ce-4fc5-8708-4c09f4009546'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_defset_Deny-PublicPaaSEndpoints.parameters.json')).IoTHubDeviceProvisioningServiceDenyPaasPublicIP.parameters
      }
      {
        definitionReferenceId: 'KeyVaultDenyPaasPublicIP'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/405c5871-3e91-4644-8a63-58e19d68ff5b'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_defset_Deny-PublicPaaSEndpoints.parameters.json')).KeyVaultDenyPaasPublicIP.parameters
      }
      {
        definitionReferenceId: 'MariaDBDenyPaasPublicIP'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deny-PublicEndpoint-MariaDB'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_defset_Deny-PublicPaaSEndpoints.parameters.json')).MariaDBDenyPaasPublicIP.parameters
      }
      {
        definitionReferenceId: 'ServiceBusNamespacesDenyPaasPublicIP'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/cbd11fd3-3002-4907-b6c8-579f0e700e13'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_defset_Deny-PublicPaaSEndpoints.parameters.json')).ServiceBusNamespacesDenyPaasPublicIP.parameters
      }
      {
        definitionReferenceId: 'StorageAccountsDenyPaasPublicIP'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/b2982f36-99f2-4db5-8eff-283140c09693'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_defset_Deny-PublicPaaSEndpoints.parameters.json')).StorageAccountsDenyPaasPublicIP.parameters
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
