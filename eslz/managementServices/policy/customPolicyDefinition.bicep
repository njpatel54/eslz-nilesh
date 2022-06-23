targetScope = 'managementGroup'

@description('Required. Location for all resources.')
param location string

@description('The management group scope to which the policy definitions are to be created at.')
param targetMgId string

@description('The management group resoruceId.')
var targetMgResourceId = tenantResourceId('Microsoft.Management/managementGroups', targetMgId)

@description('Variable containing all Custom Policy Definitions info.')
var customPolicyDefinitions = [
  {
    name: 'Append-AppService-httpsonly'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_append_appservice_httpsonly.json'))
  }
  {
    name: 'Append-AppService-latestTLS'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_append_appservice_latesttls.json'))
  }
  {
    name: 'Append-KV-SoftDelete'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_append_kv_softdelete.json'))
  }
  {
    name: 'Append-Redis-disableNonSslPort'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_append_redis_disablenonsslport.json'))
  }
  {
    name: 'Append-Redis-sslEnforcement'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_append_redis_sslenforcement.json'))
  }
  {
    name: 'Audit-MachineLearning-PrivateEndpointId'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_audit_machinelearning_privateendpointid.json'))
  }
  {
    name: 'Deny-AA-child-resources'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_deny_aa_child_resources.json'))
  }
  {
    name: 'Deny-AppGW-Without-WAF'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_deny_appgw_without_waf.json'))
  }
  {
    name: 'Deny-AppServiceApiApp-http'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_deny_appserviceapiapp_http.json'))
  }
  {
    name: 'Deny-AppServiceFunctionApp-http'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_deny_appservicefunctionapp_http.json'))
  }
  {
    name: 'Deny-AppServiceWebApp-http'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_deny_appservicewebapp_http.json'))
  }
  {
    name: 'Deny-Databricks-NoPublicIp'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_deny_databricks_nopublicip.json'))
  }
  {
    name: 'Deny-Databricks-Sku'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_deny_databricks_sku.json'))
  }
  {
    name: 'Deny-Databricks-VirtualNetwork'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_deny_databricks_virtualnetwork.json'))
  }
  {
    name: 'Deny-MachineLearning-Aks'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_deny_machinelearning_aks.json'))
  }
  {
    name: 'Deny-MachineLearning-Compute-SubnetId'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_deny_machinelearning_compute_subnetid.json'))
  }
  {
    name: 'Deny-MachineLearning-Compute-VmSize'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_deny_machinelearning_compute_vmsize.json'))
  }
  {
    name: 'Deny-MachineLearning-ComputeCluster-RemoteLoginPortPublicAccess'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_deny_machinelearning_computecluster_remoteloginportpublicaccess.json'))
  }
  {
    name: 'Deny-MachineLearning-ComputeCluster-Scale'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_deny_machinelearning_computecluster_scale.json'))
  }
  {
    name: 'Deny-MachineLearning-HbiWorkspace'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_deny_machinelearning_hbiworkspace.json'))
  }
  {
    name: 'Deny-MachineLearning-PublicAccessWhenBehindVnet'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_deny_machinelearning_publicaccesswhenbehindvnet.json'))
  }
  {
    name: 'Deny-MachineLearning-PublicNetworkAccess'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_deny_machinelearning_publicnetworkaccess.json'))
  }
  {
    name: 'Deny-MySql-http'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_deny_mysql_http.json'))
  }
  {
    name: 'Deny-PostgreSql-http'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_deny_postgresql_http.json'))
  }
  {
    name: 'Deny-Private-DNS-Zones'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_deny_private_dns_zones.json'))
  }
  {
    name: 'Deny-PublicEndpoint-MariaDB'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_deny_publicendpoint_mariadb.json'))
  }
  {
    name: 'Deny-PublicIP'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_deny_publicip.json'))
  }
  {
    name: 'Deny-RDP-From-Internet'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_deny_rdp_from_internet.json'))
  }
  {
    name: 'Deny-Redis-http'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_deny_redis_http.json'))
  }
  {
    name: 'Deny-Sql-minTLS'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_deny_sql_mintls.json'))
  }
  {
    name: 'Deny-SqlMi-minTLS'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_deny_sqlmi_mintls.json'))
  }
  {
    name: 'Deny-Storage-minTLS'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_deny_storage_mintls.json'))
  }
  {
    name: 'Deny-Subnet-Without-Nsg'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_deny_subnet_without_nsg.json'))
  }
  {
    name: 'Deny-Subnet-Without-Udr'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_deny_subnet_without_udr.json'))
  }
  {
    name: 'Deny-VNET-Peer-Cross-Sub'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_deny_vnet_peer_cross_sub.json'))
  }
  {
    name: 'Deny-VNET-Peering-To-Non-Approved-VNETs'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_deny_vnet_peering_to_non_approved_vnets.json'))
  }
  {
    name: 'Deny-VNet-Peering'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_deny_vnet_peering.json'))
  }
  {
    name: 'Deploy-ASC-SecurityContacts'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_deploy_asc_securitycontacts.json'))
  }
  {
    name: 'Deploy-Budget'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_deploy_budget.json'))
  }
  {
    name: 'Deploy-Custom-Route-Table'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_deploy_custom_route_table.json'))
  }
  {
    name: 'Deploy-DDoSProtection'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_deploy_ddosprotection.json'))
  }
  {
    name: 'Deploy-Diagnostics-AA'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_deploy_diagnostics_aa.json'))
  }
  {
    name: 'Deploy-Diagnostics-ACI'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_deploy_diagnostics_aci.json'))
  }
  {
    name: 'Deploy-Diagnostics-ACR'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_deploy_diagnostics_acr.json'))
  }
  {
    name: 'Deploy-Diagnostics-AnalysisService'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_deploy_diagnostics_analysisservice.json'))
  }
  {
    name: 'Deploy-Diagnostics-ApiForFHIR'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_deploy_diagnostics_apiforfhir.json'))
  }
  {
    name: 'Deploy-Diagnostics-APIMgmt'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_deploy_diagnostics_apimgmt.json'))
  }
  {
    name: 'Deploy-Diagnostics-ApplicationGateway'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_deploy_diagnostics_applicationgateway.json'))
  }
  {
    name: 'Deploy-Diagnostics-AVDScalingPlans'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_deploy_diagnostics_avdscalingplans.json'))
  }
  {
    name: 'Deploy-Diagnostics-Bastion'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_deploy_diagnostics_bastion.json'))
  }
  {
    name: 'Deploy-Diagnostics-CDNEndpoints'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_deploy_diagnostics_cdnendpoints.json'))
  }
  {
    name: 'Deploy-Diagnostics-CognitiveServices'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_deploy_diagnostics_cognitiveservices.json'))
  }
  {
    name: 'Deploy-Diagnostics-CosmosDB'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_deploy_diagnostics_cosmosdb.json'))
  }
  {
    name: 'Deploy-Diagnostics-Databricks'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_deploy_diagnostics_databricks.json'))
  }
  {
    name: 'Deploy-Diagnostics-DataExplorerCluster'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_deploy_diagnostics_dataexplorercluster.json'))
  }
  {
    name: 'Deploy-Diagnostics-DataFactory'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_deploy_diagnostics_datafactory.json'))
  }
  {
    name: 'Deploy-Diagnostics-DLAnalytics'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_deploy_diagnostics_dlanalytics.json'))
  }
  {
    name: 'Deploy-Diagnostics-EventGridSub'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_deploy_diagnostics_eventgridsub.json'))
  }
  {
    name: 'Deploy-Diagnostics-EventGridSystemTopic'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_deploy_diagnostics_eventgridsystemtopic.json'))
  }
  {
    name: 'Deploy-Diagnostics-EventGridTopic'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_deploy_diagnostics_eventgridtopic.json'))
  }
  {
    name: 'Deploy-Diagnostics-ExpressRoute'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_deploy_diagnostics_expressroute.json'))
  }
  {
    name: 'Deploy-Diagnostics-Firewall'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_deploy_diagnostics_firewall.json'))
  }
  {
    name: 'Deploy-Diagnostics-FrontDoor'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_deploy_diagnostics_frontdoor.json'))
  }
  {
    name: 'Deploy-Diagnostics-Function'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_deploy_diagnostics_function.json'))
  }
  {
    name: 'Deploy-Diagnostics-HDInsight'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_deploy_diagnostics_hdinsight.json'))
  }
  {
    name: 'Deploy-Diagnostics-iotHub'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_deploy_diagnostics_iothub.json'))
  }
  {
    name: 'Deploy-Diagnostics-LoadBalancer'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_deploy_diagnostics_loadbalancer.json'))
  }
  {
    name: 'Deploy-Diagnostics-LogicAppsISE'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_deploy_diagnostics_logicappsise.json'))
  }
  {
    name: 'Deploy-Diagnostics-MariaDB'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_deploy_diagnostics_mariadb.json'))
  }
  {
    name: 'Deploy-Diagnostics-MediaService'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_deploy_diagnostics_mediaservice.json'))
  }
  {
    name: 'Deploy-Diagnostics-MlWorkspace'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_deploy_diagnostics_mlworkspace.json'))
  }
  {
    name: 'Deploy-Diagnostics-MySQL'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_deploy_diagnostics_mysql.json'))
  }
  {
    name: 'Deploy-Diagnostics-NetworkSecurityGroups'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_deploy_diagnostics_networksecuritygroups.json'))
  }
  {
    name: 'Deploy-Diagnostics-NIC'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_deploy_diagnostics_nic.json'))
  }
  {
    name: 'Deploy-Diagnostics-PostgreSQL'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_deploy_diagnostics_postgresql.json'))
  }
  {
    name: 'Deploy-Diagnostics-PowerBIEmbedded'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_deploy_diagnostics_powerbiembedded.json'))
  }
  {
    name: 'Deploy-Diagnostics-RedisCache'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_deploy_diagnostics_rediscache.json'))
  }
  {
    name: 'Deploy-Diagnostics-Relay'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_deploy_diagnostics_relay.json'))
  }
  {
    name: 'Deploy-Diagnostics-SignalR'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_deploy_diagnostics_signalr.json'))
  }
  {
    name: 'Deploy-Diagnostics-SQLElasticPools'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_deploy_diagnostics_sqlelasticpools.json'))
  }
  {
    name: 'Deploy-Diagnostics-SQLMI'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_deploy_diagnostics_sqlmi.json'))
  }
  {
    name: 'Deploy-Diagnostics-TimeSeriesInsights'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_deploy_diagnostics_timeseriesinsights.json'))
  }
  {
    name: 'Deploy-Diagnostics-TrafficManager'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_deploy_diagnostics_trafficmanager.json'))
  }
  {
    name: 'Deploy-Diagnostics-VirtualNetwork'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_deploy_diagnostics_virtualnetwork.json'))
  }
  {
    name: 'Deploy-Diagnostics-VM'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_deploy_diagnostics_vm.json'))
  }
  {
    name: 'Deploy-Diagnostics-VMSS'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_deploy_diagnostics_vmss.json'))
  }
  {
    name: 'Deploy-Diagnostics-VNetGW'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_deploy_diagnostics_vnetgw.json'))
  }
  {
    name: 'Deploy-Diagnostics-WebServerFarm'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_deploy_diagnostics_webserverfarm.json'))
  }
  {
    name: 'Deploy-Diagnostics-Website'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_deploy_diagnostics_website.json'))
  }
  {
    name: 'Deploy-Diagnostics-WVDAppGroup'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_deploy_diagnostics_wvdappgroup.json'))
  }
  {
    name: 'Deploy-Diagnostics-WVDHostPools'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_deploy_diagnostics_wvdhostpools.json'))
  }
  {
    name: 'Deploy-Diagnostics-WVDWorkspace'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_deploy_diagnostics_wvdworkspace.json'))
  }
  {
    name: 'Deploy-FirewallPolicy'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_deploy_firewallpolicy.json'))
  }
  {
    name: 'Deploy-MySQL-sslEnforcement'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_deploy_mysql_sslenforcement.json'))
  }
  {
    name: 'Deploy-Nsg-FlowLogs-to-LA'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_deploy_nsg_flowlogs_to_la.json'))
  }
  {
    name: 'Deploy-Nsg-FlowLogs'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_deploy_nsg_flowlogs.json'))
  }
  {
    name: 'Deploy-PostgreSQL-sslEnforcement'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_deploy_postgresql_sslenforcement.json'))
  }
  {
    name: 'Deploy-Sql-AuditingSettings'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_deploy_sql_auditingsettings.json'))
  }
  {
    name: 'Deploy-SQL-minTLS'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_deploy_sql_mintls.json'))
  }
  {
    name: 'Deploy-Sql-SecurityAlertPolicies'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_deploy_sql_securityalertpolicies.json'))
  }
  {
    name: 'Deploy-Sql-Tde'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_deploy_sql_tde.json'))
  }
  {
    name: 'Deploy-Sql-vulnerabilityAssessments'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_deploy_sql_vulnerabilityassessments.json'))
  }
  {
    name: 'Deploy-SqlMi-minTLS'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_deploy_sqlmi_mintls.json'))
  }
  {
    name: 'Deploy-Storage-sslEnforcement'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_deploy_storage_sslenforcement.json'))
  }
  {
    name: 'Deploy-VNET-HubSpoke'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_deploy_vnet_hubspoke.json'))
  }
  {
    name: 'Deploy-Windows-DomainJoin'
    definition: json(loadTextContent('policyDefinitions/policy_definition_es_deploy_windows_domainjoin.json'))
  }
]

@description('Variable containing all Custom Policy-Set Definitions info.')
var customPolicySetDefinitions = [
  {
    name: 'Deny-PublicPaaSEndpoints'
    setDefinition: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deny_publicpaasendpoints.json'))
    setChildDefinitions: [
      {
        definitionReferenceId: 'ACRDenyPaasPublicIP'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/0fdf0491-d080-4575-b627-ad0e843cba0f'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deny_publicpaasendpoints.parameters.json')).ACRDenyPaasPublicIP.parameters
      }
      {
        definitionReferenceId: 'AFSDenyPaasPublicIP'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/21a8cd35-125e-4d13-b82d-2e19b7208bb7'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deny_publicpaasendpoints.parameters.json')).AFSDenyPaasPublicIP.parameters
      }
      {
        definitionReferenceId: 'AKSDenyPaasPublicIP'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/040732e8-d947-40b8-95d6-854c95024bf8'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deny_publicpaasendpoints.parameters.json')).AKSDenyPaasPublicIP.parameters
      }
      {
        definitionReferenceId: 'BatchDenyPublicIP'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/74c5a0ae-5e48-4738-b093-65e23a060488'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deny_publicpaasendpoints.parameters.json')).BatchDenyPublicIP.parameters
      }
      {
        definitionReferenceId: 'CosmosDenyPaasPublicIP'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/797b37f7-06b8-444c-b1ad-fc62867f335a'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deny_publicpaasendpoints.parameters.json')).CosmosDenyPaasPublicIP.parameters
      }
      {
        definitionReferenceId: 'KeyVaultDenyPaasPublicIP'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/55615ac9-af46-4a59-874e-391cc3dfb490'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deny_publicpaasendpoints.parameters.json')).KeyVaultDenyPaasPublicIP.parameters
      }
      {
        definitionReferenceId: 'SqlServerDenyPaasPublicIP'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/1b8ca024-1d5c-4dec-8995-b1a932b41780'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deny_publicpaasendpoints.parameters.json')).SqlServerDenyPaasPublicIP.parameters
      }
      {
        definitionReferenceId: 'StorageDenyPaasPublicIP'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/34c877ad-507e-4c82-993e-3452a6e0ad3c'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deny_publicpaasendpoints.parameters.json')).StorageDenyPaasPublicIP.parameters
      }
    ]
  }
  {
    name: 'Deploy-Diagnostics-LogAnalytics'
    setDefinition: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deploy_diagnostics_loganalytics.json'))
    setChildDefinitions: [
      {
        definitionReferenceId: 'ACIDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-ACI'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deploy_diagnostics_loganalytics.parameters.json')).ACIDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'ACRDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-ACR'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deploy_diagnostics_loganalytics.parameters.json')).ACRDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'AKSDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/6c66c325-74c8-42fd-a286-a74b0e2939d8'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deploy_diagnostics_loganalytics.parameters.json')).AKSDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'AnalysisServiceDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-AnalysisService'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deploy_diagnostics_loganalytics.parameters.json')).AnalysisServiceDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'APIforFHIRDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-ApiForFHIR'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deploy_diagnostics_loganalytics.parameters.json')).APIforFHIRDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'APIMgmtDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-APIMgmt'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deploy_diagnostics_loganalytics.parameters.json')).APIMgmtDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'ApplicationGatewayDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-ApplicationGateway'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deploy_diagnostics_loganalytics.parameters.json')).ApplicationGatewayDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'AppServiceDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-WebServerFarm'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deploy_diagnostics_loganalytics.parameters.json')).AppServiceDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'AppServiceWebappDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-Website'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deploy_diagnostics_loganalytics.parameters.json')).AppServiceWebappDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'AutomationDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-AA'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deploy_diagnostics_loganalytics.parameters.json')).AutomationDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'AVDScalingPlansDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-AVDScalingPlans'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deploy_diagnostics_loganalytics.parameters.json')).AVDScalingPlansDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'BastionDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-Bastion'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deploy_diagnostics_loganalytics.parameters.json')).BastionDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'BatchDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/c84e5349-db6d-4769-805e-e14037dab9b5'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deploy_diagnostics_loganalytics.parameters.json')).BatchDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'CDNEndpointsDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-CDNEndpoints'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deploy_diagnostics_loganalytics.parameters.json')).CDNEndpointsDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'CognitiveServicesDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-CognitiveServices'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deploy_diagnostics_loganalytics.parameters.json')).CognitiveServicesDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'CosmosDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-CosmosDB'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deploy_diagnostics_loganalytics.parameters.json')).CosmosDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'DatabricksDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-Databricks'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deploy_diagnostics_loganalytics.parameters.json')).DatabricksDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'DataExplorerClusterDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-DataExplorerCluster'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deploy_diagnostics_loganalytics.parameters.json')).DataExplorerClusterDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'DataFactoryDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-DataFactory'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deploy_diagnostics_loganalytics.parameters.json')).DataFactoryDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'DataLakeAnalyticsDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-DLAnalytics'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deploy_diagnostics_loganalytics.parameters.json')).DataLakeAnalyticsDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'DataLakeStoreDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/d56a5a7c-72d7-42bc-8ceb-3baf4c0eae03'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deploy_diagnostics_loganalytics.parameters.json')).DataLakeStoreDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'EventGridSubDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-EventGridSub'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deploy_diagnostics_loganalytics.parameters.json')).EventGridSubDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'EventGridTopicDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-EventGridTopic'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deploy_diagnostics_loganalytics.parameters.json')).EventGridTopicDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'EventHubDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/1f6e93e8-6b31-41b1-83f6-36e449a42579'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deploy_diagnostics_loganalytics.parameters.json')).EventHubDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'EventSystemTopicDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-EventGridSystemTopic'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deploy_diagnostics_loganalytics.parameters.json')).EventSystemTopicDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'ExpressRouteDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-ExpressRoute'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deploy_diagnostics_loganalytics.parameters.json')).ExpressRouteDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'FirewallDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-Firewall'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deploy_diagnostics_loganalytics.parameters.json')).FirewallDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'FrontDoorDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-FrontDoor'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deploy_diagnostics_loganalytics.parameters.json')).FrontDoorDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'FunctionAppDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-Function'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deploy_diagnostics_loganalytics.parameters.json')).FunctionAppDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'HDInsightDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-HDInsight'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deploy_diagnostics_loganalytics.parameters.json')).HDInsightDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'IotHubDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-iotHub'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deploy_diagnostics_loganalytics.parameters.json')).IotHubDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'KeyVaultDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/bef3f64c-5290-43b7-85b0-9b254eef4c47'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deploy_diagnostics_loganalytics.parameters.json')).KeyVaultDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'LoadBalancerDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-LoadBalancer'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deploy_diagnostics_loganalytics.parameters.json')).LoadBalancerDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'LogicAppsISEDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-LogicAppsISE'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deploy_diagnostics_loganalytics.parameters.json')).LogicAppsISEDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'LogicAppsWFDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/b889a06c-ec72-4b03-910a-cb169ee18721'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deploy_diagnostics_loganalytics.parameters.json')).LogicAppsWFDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'MariaDBDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-MariaDB'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deploy_diagnostics_loganalytics.parameters.json')).MariaDBDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'MediaServiceDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-MediaService'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deploy_diagnostics_loganalytics.parameters.json')).MediaServiceDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'MlWorkspaceDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-MlWorkspace'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deploy_diagnostics_loganalytics.parameters.json')).MlWorkspaceDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'MySQLDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-MySQL'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deploy_diagnostics_loganalytics.parameters.json')).MySQLDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'NetworkNICDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-NIC'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deploy_diagnostics_loganalytics.parameters.json')).NetworkNICDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'NetworkPublicIPNicDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/752154a7-1e0f-45c6-a880-ac75a7e4f648'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deploy_diagnostics_loganalytics.parameters.json')).NetworkPublicIPNicDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'NetworkSecurityGroupsDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-NetworkSecurityGroups'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deploy_diagnostics_loganalytics.parameters.json')).NetworkSecurityGroupsDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'PostgreSQLDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-PostgreSQL'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deploy_diagnostics_loganalytics.parameters.json')).PostgreSQLDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'PowerBIEmbeddedDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-PowerBIEmbedded'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deploy_diagnostics_loganalytics.parameters.json')).PowerBIEmbeddedDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'RecoveryVaultDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/c717fb0c-d118-4c43-ab3d-ece30ac81fb3'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deploy_diagnostics_loganalytics.parameters.json')).RecoveryVaultDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'RedisCacheDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-RedisCache'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deploy_diagnostics_loganalytics.parameters.json')).RedisCacheDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'RelayDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-Relay'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deploy_diagnostics_loganalytics.parameters.json')).RelayDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'SearchServicesDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/08ba64b8-738f-4918-9686-730d2ed79c7d'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deploy_diagnostics_loganalytics.parameters.json')).SearchServicesDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'ServiceBusDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/04d53d87-841c-4f23-8a5b-21564380b55e'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deploy_diagnostics_loganalytics.parameters.json')).ServiceBusDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'SignalRDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-SignalR'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deploy_diagnostics_loganalytics.parameters.json')).SignalRDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'SQLDatabaseDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/b79fa14e-238a-4c2d-b376-442ce508fc84'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deploy_diagnostics_loganalytics.parameters.json')).SQLDatabaseDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'SQLElasticPoolsDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-SQLElasticPools'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deploy_diagnostics_loganalytics.parameters.json')).SQLElasticPoolsDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'SQLMDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-SQLMI'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deploy_diagnostics_loganalytics.parameters.json')).SQLMDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'StorageAccountDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/6f8f98a4-f108-47cb-8e98-91a0d85cd474'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deploy_diagnostics_loganalytics.parameters.json')).StorageAccountDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'StreamAnalyticsDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/237e0f7e-b0e8-4ec4-ad46-8c12cb66d673'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deploy_diagnostics_loganalytics.parameters.json')).StreamAnalyticsDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'TimeSeriesInsightsDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-TimeSeriesInsights'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deploy_diagnostics_loganalytics.parameters.json')).TimeSeriesInsightsDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'TrafficManagerDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-TrafficManager'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deploy_diagnostics_loganalytics.parameters.json')).TrafficManagerDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'VirtualMachinesDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-VM'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deploy_diagnostics_loganalytics.parameters.json')).VirtualMachinesDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'VirtualNetworkDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-VirtualNetwork'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deploy_diagnostics_loganalytics.parameters.json')).VirtualNetworkDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'VMSSDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-VMSS'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deploy_diagnostics_loganalytics.parameters.json')).VMSSDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'VNetGWDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-VNetGW'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deploy_diagnostics_loganalytics.parameters.json')).VNetGWDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'WVDAppGroupDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-WVDAppGroup'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deploy_diagnostics_loganalytics.parameters.json')).WVDAppGroupDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'WVDHostPoolsDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-WVDHostPools'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deploy_diagnostics_loganalytics.parameters.json')).WVDHostPoolsDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'WVDWorkspaceDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-WVDWorkspace'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deploy_diagnostics_loganalytics.parameters.json')).WVDWorkspaceDeployDiagnosticLogDeployLogAnalytics.parameters
      }
    ]
  }
  {
    name: 'Deploy-MDFC-Config'
    setDefinition: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deploy_mdfc_config.json'))
    setChildDefinitions: [
      {
        definitionReferenceId: 'ascExport'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/ffb6f416-7bd2-4488-8828-56585fef2be9'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deploy_mdfc_config.parameters.json')).ascExport.parameters
      }
      {
        definitionReferenceId: 'defenderForArm'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/b7021b2b-08fd-4dc0-9de7-3c6ece09faf9'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deploy_mdfc_config.parameters.json')).defenderForArm.parameters
      }
      {
        definitionReferenceId: 'defenderforContainers'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/c9ddb292-b203-4738-aead-18e2716e858f'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deploy_mdfc_config.parameters.json')).defenderforContainers.parameters
      }
      {
        definitionReferenceId: 'defenderForDns'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/2370a3c1-4a25-4283-a91a-c9c1a145fb2f'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deploy_mdfc_config.parameters.json')).defenderForDns.parameters
      }
      {
        definitionReferenceId: 'defenderForSqlPaas'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/b99b73e7-074b-4089-9395-b7236f094491'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deploy_mdfc_config.parameters.json')).defenderForSqlPaas.parameters
      }
      {
        definitionReferenceId: 'defenderForStorageAccounts'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/74c30959-af11-47b3-9ed2-a26e03f427a3'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deploy_mdfc_config.parameters.json')).defenderForStorageAccounts.parameters
      }
      {
        definitionReferenceId: 'defenderForVM'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/8e86a5b6-b9bd-49d1-8e21-4bb8a0862222'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deploy_mdfc_config.parameters.json')).defenderForVM.parameters
      }
      {
        definitionReferenceId: 'securityEmailContact'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-ASC-SecurityContacts'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deploy_mdfc_config.parameters.json')).securityEmailContact.parameters
      }
    ]
  }
  {
    name: 'Deploy-Private-DNS-Zones'
    setDefinition: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deploy_private_dns_zones.json'))
    setChildDefinitions: [
      {
        definitionReferenceId: 'DINE-Private-DNS-Azure-ACR'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/e9585a95-5b8c-4d03-b193-dc7eb5ac4c32'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deploy_private_dns_zones.parameters.json'))['DINE-Private-DNS-Azure-ACR'].parameters
      }
      {
        definitionReferenceId: 'DINE-Private-DNS-Azure-App'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/7a860e27-9ca2-4fc6-822d-c2d248c300df'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deploy_private_dns_zones.parameters.json'))['DINE-Private-DNS-Azure-App'].parameters
      }
      {
        definitionReferenceId: 'DINE-Private-DNS-Azure-AppServices'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/b318f84a-b872-429b-ac6d-a01b96814452'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deploy_private_dns_zones.parameters.json'))['DINE-Private-DNS-Azure-AppServices'].parameters
      }
      {
        definitionReferenceId: 'DINE-Private-DNS-Azure-Batch'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/4ec38ebc-381f-45ee-81a4-acbc4be878f8'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deploy_private_dns_zones.parameters.json'))['DINE-Private-DNS-Azure-Batch'].parameters
      }
      {
        definitionReferenceId: 'DINE-Private-DNS-Azure-CognitiveSearch'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/fbc14a67-53e4-4932-abcc-2049c6706009'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deploy_private_dns_zones.parameters.json'))['DINE-Private-DNS-Azure-CognitiveSearch'].parameters
      }
      {
        definitionReferenceId: 'DINE-Private-DNS-Azure-CognitiveServices'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/c4bc6f10-cb41-49eb-b000-d5ab82e2a091'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deploy_private_dns_zones.parameters.json'))['DINE-Private-DNS-Azure-CognitiveServices'].parameters
      }
      {
        definitionReferenceId: 'DINE-Private-DNS-Azure-DiskAccess'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/bc05b96c-0b36-4ca9-82f0-5c53f96ce05a'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deploy_private_dns_zones.parameters.json'))['DINE-Private-DNS-Azure-DiskAccess'].parameters
      }
      {
        definitionReferenceId: 'DINE-Private-DNS-Azure-EventGridDomains'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/d389df0a-e0d7-4607-833c-75a6fdac2c2d'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deploy_private_dns_zones.parameters.json'))['DINE-Private-DNS-Azure-EventGridDomains'].parameters
      }
      {
        definitionReferenceId: 'DINE-Private-DNS-Azure-EventGridTopics'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/baf19753-7502-405f-8745-370519b20483'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deploy_private_dns_zones.parameters.json'))['DINE-Private-DNS-Azure-EventGridTopics'].parameters
      }
      {
        definitionReferenceId: 'DINE-Private-DNS-Azure-EventHubNamespace'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/ed66d4f5-8220-45dc-ab4a-20d1749c74e6'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deploy_private_dns_zones.parameters.json'))['DINE-Private-DNS-Azure-EventHubNamespace'].parameters
      }
      {
        definitionReferenceId: 'DINE-Private-DNS-Azure-File-Sync'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/06695360-db88-47f6-b976-7500d4297475'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deploy_private_dns_zones.parameters.json'))['DINE-Private-DNS-Azure-File-Sync'].parameters
      }
      {
        definitionReferenceId: 'DINE-Private-DNS-Azure-IoT'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/aaa64d2d-2fa3-45e5-b332-0b031b9b30e8'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deploy_private_dns_zones.parameters.json'))['DINE-Private-DNS-Azure-IoT'].parameters
      }
      {
        definitionReferenceId: 'DINE-Private-DNS-Azure-IoTHubs'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/c99ce9c1-ced7-4c3e-aca0-10e69ce0cb02'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deploy_private_dns_zones.parameters.json'))['DINE-Private-DNS-Azure-IoTHubs'].parameters
      }
      {
        definitionReferenceId: 'DINE-Private-DNS-Azure-KeyVault'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/ac673a9a-f77d-4846-b2d8-a57f8e1c01d4'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deploy_private_dns_zones.parameters.json'))['DINE-Private-DNS-Azure-KeyVault'].parameters
      }
      {
        definitionReferenceId: 'DINE-Private-DNS-Azure-MachineLearningWorkspace'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/ee40564d-486e-4f68-a5ca-7a621edae0fb'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deploy_private_dns_zones.parameters.json'))['DINE-Private-DNS-Azure-MachineLearningWorkspace'].parameters
      }
      {
        definitionReferenceId: 'DINE-Private-DNS-Azure-RedisCache'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/e016b22b-e0eb-436d-8fd7-160c4eaed6e2'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deploy_private_dns_zones.parameters.json'))['DINE-Private-DNS-Azure-RedisCache'].parameters
      }
      {
        definitionReferenceId: 'DINE-Private-DNS-Azure-ServiceBusNamespace'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/f0fcf93c-c063-4071-9668-c47474bd3564'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deploy_private_dns_zones.parameters.json'))['DINE-Private-DNS-Azure-ServiceBusNamespace'].parameters
      }
      {
        definitionReferenceId: 'DINE-Private-DNS-Azure-SignalR'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/b0e86710-7fb7-4a6c-a064-32e9b829509e'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deploy_private_dns_zones.parameters.json'))['DINE-Private-DNS-Azure-SignalR'].parameters
      }
      {
        definitionReferenceId: 'DINE-Private-DNS-Azure-Site-Recovery'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/942bd215-1a66-44be-af65-6a1c0318dbe2'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deploy_private_dns_zones.parameters.json'))['DINE-Private-DNS-Azure-Site-Recovery'].parameters
      }
    ]
  }
  {
    name: 'Deploy-Sql-Security'
    setDefinition: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deploy_sql_security.json'))
    setChildDefinitions: [
      {
        definitionReferenceId: 'SqlDbAuditingSettingsDeploySqlSecurity'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Sql-AuditingSettings'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deploy_sql_security.parameters.json')).SqlDbAuditingSettingsDeploySqlSecurity.parameters
      }
      {
        definitionReferenceId: 'SqlDbSecurityAlertPoliciesDeploySqlSecurity'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Sql-SecurityAlertPolicies'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deploy_sql_security.parameters.json')).SqlDbSecurityAlertPoliciesDeploySqlSecurity.parameters
      }
      {
        definitionReferenceId: 'SqlDbTdeDeploySqlSecurity'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Sql-Tde'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deploy_sql_security.parameters.json')).SqlDbTdeDeploySqlSecurity.parameters
      }
      {
        definitionReferenceId: 'SqlDbVulnerabilityAssessmentsDeploySqlSecurity'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Sql-vulnerabilityAssessments'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_deploy_sql_security.parameters.json')).SqlDbVulnerabilityAssessmentsDeploySqlSecurity.parameters
      }
    ]
  }
  {
    name: 'Enforce-Encryption-CMK'
    setDefinition: json(loadTextContent('policySetDefinitions/policy_set_definition_es_enforce_encryption_cmk.json'))
    setChildDefinitions: [
      {
        definitionReferenceId: 'ACRCmkDeny'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/5b9159ae-1701-4a6f-9a7a-aa9c8ddd0580'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_enforce_encryption_cmk.parameters.json')).ACRCmkDeny.parameters
      }
      {
        definitionReferenceId: 'AksCmkDeny'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/7d7be79c-23ba-4033-84dd-45e2a5ccdd67'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_enforce_encryption_cmk.parameters.json')).AksCmkDeny.parameters
      }
      {
        definitionReferenceId: 'AzureBatchCMKEffect'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/99e9ccd8-3db9-4592-b0d1-14b1715a4d8a'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_enforce_encryption_cmk.parameters.json')).AzureBatchCMKEffect.parameters
      }
      {
        definitionReferenceId: 'CognitiveServicesCMK'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/67121cc7-ff39-4ab8-b7e3-95b84dab487d'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_enforce_encryption_cmk.parameters.json')).CognitiveServicesCMK.parameters
      }
      {
        definitionReferenceId: 'CosmosCMKEffect'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/1f905d99-2ab7-462c-a6b0-f709acca6c8f'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_enforce_encryption_cmk.parameters.json')).CosmosCMKEffect.parameters
      }
      {
        definitionReferenceId: 'DataBoxCMKEffect'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/86efb160-8de7-451d-bc08-5d475b0aadae'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_enforce_encryption_cmk.parameters.json')).DataBoxCMKEffect.parameters
      }
      {
        definitionReferenceId: 'EncryptedVMDisksEffect'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/0961003e-5a0a-4549-abde-af6a37f2724d'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_enforce_encryption_cmk.parameters.json')).EncryptedVMDisksEffect.parameters
      }
      {
        definitionReferenceId: 'SqlServerTDECMKEffect'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/0d134df8-db83-46fb-ad72-fe0c9428c8dd'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_enforce_encryption_cmk.parameters.json')).SqlServerTDECMKEffect.parameters
      }
      {
        definitionReferenceId: 'StorageCMKEffect'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/6fac406b-40ca-413b-bf8e-0bf964659c25'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_enforce_encryption_cmk.parameters.json')).StorageCMKEffect.parameters
      }
      {
        definitionReferenceId: 'StreamAnalyticsCMKEffect'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/87ba29ef-1ab3-4d82-b763-87fcd4f531f7'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_enforce_encryption_cmk.parameters.json')).StreamAnalyticsCMKEffect.parameters
      }
      {
        definitionReferenceId: 'SynapseWorkspaceCMKEffect'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/f7d52b2d-e161-4dfa-a82b-55e564167385'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_enforce_encryption_cmk.parameters.json')).SynapseWorkspaceCMKEffect.parameters
      }
      {
        definitionReferenceId: 'WorkspaceCMK'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/ba769a63-b8cc-4b2d-abf6-ac33c7204be8'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_enforce_encryption_cmk.parameters.json')).WorkspaceCMK.parameters
      }
    ]
  }
  {
    name: 'Enforce-EncryptTransit'
    setDefinition: json(loadTextContent('policySetDefinitions/policy_set_definition_es_enforce_encrypttransit.json'))
    setChildDefinitions: [
      {
        definitionReferenceId: 'AKSIngressHttpsOnlyEffect'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/1a5b4dca-0b6f-4cf5-907c-56316bc1bf3d'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_enforce_encrypttransit.parameters.json')).AKSIngressHttpsOnlyEffect.parameters
      }
      {
        definitionReferenceId: 'APIAppServiceHttpsEffect'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deny-AppServiceApiApp-http'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_enforce_encrypttransit.parameters.json')).APIAppServiceHttpsEffect.parameters
      }
      {
        definitionReferenceId: 'APIAppServiceLatestTlsEffect'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/8cb6aa8b-9e41-4f4e-aa25-089a7ac2581e'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_enforce_encrypttransit.parameters.json')).APIAppServiceLatestTlsEffect.parameters
      }
      {
        definitionReferenceId: 'AppServiceHttpEffect'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Append-AppService-httpsonly'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_enforce_encrypttransit.parameters.json')).AppServiceHttpEffect.parameters
      }
      {
        definitionReferenceId: 'AppServiceminTlsVersion'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Append-AppService-latestTLS'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_enforce_encrypttransit.parameters.json')).AppServiceminTlsVersion.parameters
      }
      {
        definitionReferenceId: 'FunctionLatestTlsEffect'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/f9d614c5-c173-4d56-95a7-b4437057d193'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_enforce_encrypttransit.parameters.json')).FunctionLatestTlsEffect.parameters
      }
      {
        definitionReferenceId: 'FunctionServiceHttpsEffect'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deny-AppServiceFunctionApp-http'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_enforce_encrypttransit.parameters.json')).FunctionServiceHttpsEffect.parameters
      }
      {
        definitionReferenceId: 'MySQLEnableSSLDeployEffect'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-MySQL-sslEnforcement'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_enforce_encrypttransit.parameters.json')).MySQLEnableSSLDeployEffect.parameters
      }
      {
        definitionReferenceId: 'MySQLEnableSSLEffect'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deny-MySql-http'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_enforce_encrypttransit.parameters.json')).MySQLEnableSSLEffect.parameters
      }
      {
        definitionReferenceId: 'PostgreSQLEnableSSLDeployEffect'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-PostgreSQL-sslEnforcement'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_enforce_encrypttransit.parameters.json')).PostgreSQLEnableSSLDeployEffect.parameters
      }
      {
        definitionReferenceId: 'PostgreSQLEnableSSLEffect'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deny-PostgreSql-http'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_enforce_encrypttransit.parameters.json')).PostgreSQLEnableSSLEffect.parameters
      }
      {
        definitionReferenceId: 'RedisDenyhttps'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deny-Redis-http'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_enforce_encrypttransit.parameters.json')).RedisDenyhttps.parameters
      }
      {
        definitionReferenceId: 'RedisdisableNonSslPort'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Append-Redis-disableNonSslPort'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_enforce_encrypttransit.parameters.json')).RedisdisableNonSslPort.parameters
      }
      {
        definitionReferenceId: 'RedisTLSDeployEffect'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Append-Redis-sslEnforcement'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_enforce_encrypttransit.parameters.json')).RedisTLSDeployEffect.parameters
      }
      {
        definitionReferenceId: 'SQLManagedInstanceTLSDeployEffect'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-SqlMi-minTLS'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_enforce_encrypttransit.parameters.json')).SQLManagedInstanceTLSDeployEffect.parameters
      }
      {
        definitionReferenceId: 'SQLManagedInstanceTLSEffect'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deny-SqlMi-minTLS'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_enforce_encrypttransit.parameters.json')).SQLManagedInstanceTLSEffect.parameters
      }
      {
        definitionReferenceId: 'SQLServerTLSDeployEffect'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-SQL-minTLS'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_enforce_encrypttransit.parameters.json')).SQLServerTLSDeployEffect.parameters
      }
      {
        definitionReferenceId: 'SQLServerTLSEffect'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deny-Sql-minTLS'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_enforce_encrypttransit.parameters.json')).SQLServerTLSEffect.parameters
      }
      {
        definitionReferenceId: 'StorageDeployHttpsEnabledEffect'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Storage-sslEnforcement'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_enforce_encrypttransit.parameters.json')).StorageDeployHttpsEnabledEffect.parameters
      }
      {
        definitionReferenceId: 'StorageHttpsEnabledEffect'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deny-Storage-minTLS'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_enforce_encrypttransit.parameters.json')).StorageHttpsEnabledEffect.parameters
      }
      {
        definitionReferenceId: 'WebAppServiceHttpsEffect'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deny-AppServiceWebApp-http'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_enforce_encrypttransit.parameters.json')).WebAppServiceHttpsEffect.parameters
      }
      {
        definitionReferenceId: 'WebAppServiceLatestTlsEffect'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/f0e6e85b-9b9f-4a4b-b67b-f730d42f1b0b'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy_set_definition_es_enforce_encrypttransit.parameters.json')).WebAppServiceLatestTlsEffect.parameters
      }
    ]
  }
]

// Create Custom Policy Defintions
module policyDefinitions '../../modules/authorization/policyDefinitions/managementGroup/deploy.bicep' = [for policy in customPolicyDefinitions: {
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

// Create Custom Policy-Set Defintions
module policySetDefinitions '../../modules/authorization/policySetDefinitions/managementGroup/deploy.bicep' = [for policySet in customPolicySetDefinitions: {
  name: '${policySet.setDefinition.name}'
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
    policyDefinitionGroups: policySet.setDefinition.properties.policyDefinitionGroups
    
  }
}]
