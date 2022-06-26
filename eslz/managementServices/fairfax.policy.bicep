targetScope = 'managementGroup'

param location string

@description('The management group scope to which the policy definitions are to be created at.')
param targetMgId string

@description('The management group resoruceId.')
var targetMgResourceId = tenantResourceId('Microsoft.Management/managementGroups', targetMgId)

param policyDefinitions array
//param policySetDefinitions array

@description('Variable containing all Custom Policy Definitions info.')
var customPolicyDefinitions = [
  {
    name: 'Append-AppService-httpsonly'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_append_appservice_httpsonly.json'))
  }
  {
    name: 'Append-AppService-latestTLS'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_append_appservice_latesttls.json'))
  }
  {
    name: 'Append-KV-SoftDelete'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_append_kv_softdelete.json'))
  }
  {
    name: 'Append-Redis-disableNonSslPort'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_append_redis_disablenonsslport.json'))
  }
  {
    name: 'Append-Redis-sslEnforcement'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_append_redis_sslenforcement.json'))
  }
  {
    name: 'Audit-MachineLearning-PrivateEndpointId'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_audit_machinelearning_privateendpointid.json'))
  }
  {
    name: 'Deny-AA-child-resources'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_deny_aa_child_resources.json'))
  }
  {
    name: 'Deny-AppGW-Without-WAF'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_deny_appgw_without_waf.json'))
  }
  {
    name: 'Deny-AppServiceApiApp-http'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_deny_appserviceapiapp_http.json'))
  }
  {
    name: 'Deny-AppServiceFunctionApp-http'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_deny_appservicefunctionapp_http.json'))
  }
  {
    name: 'Deny-AppServiceWebApp-http'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_deny_appservicewebapp_http.json'))
  }
  {
    name: 'Deny-Databricks-NoPublicIp'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_deny_databricks_nopublicip.json'))
  }
  {
    name: 'Deny-Databricks-Sku'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_deny_databricks_sku.json'))
  }
  {
    name: 'Deny-Databricks-VirtualNetwork'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_deny_databricks_virtualnetwork.json'))
  }
  {
    name: 'Deny-MachineLearning-Aks'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_deny_machinelearning_aks.json'))
  }
  {
    name: 'Deny-MachineLearning-Compute-SubnetId'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_deny_machinelearning_compute_subnetid.json'))
  }
  {
    name: 'Deny-MachineLearning-Compute-VmSize'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_deny_machinelearning_compute_vmsize.json'))
  }
  {
    name: 'Deny-MachineLearning-ComputeCluster-RemoteLoginPortPublicAccess'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_deny_machinelearning_computecluster_remoteloginportpublicaccess.json'))
  }
  {
    name: 'Deny-MachineLearning-ComputeCluster-Scale'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_deny_machinelearning_computecluster_scale.json'))
  }
  {
    name: 'Deny-MachineLearning-HbiWorkspace'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_deny_machinelearning_hbiworkspace.json'))
  }
  {
    name: 'Deny-MachineLearning-PublicAccessWhenBehindVnet'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_deny_machinelearning_publicaccesswhenbehindvnet.json'))
  }
  {
    name: 'Deny-MachineLearning-PublicNetworkAccess'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_deny_machinelearning_publicnetworkaccess.json'))
  }
  {
    name: 'Deny-MySql-http'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_deny_mysql_http.json'))
  }
  {
    name: 'Deny-PostgreSql-http'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_deny_postgresql_http.json'))
  }
  {
    name: 'Deny-Private-DNS-Zones'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_deny_private_dns_zones.json'))
  }
  {
    name: 'Deny-PublicEndpoint-MariaDB'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_deny_publicendpoint_mariadb.json'))
  }
  {
    name: 'Deny-PublicIP'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_deny_publicip.json'))
  }
  {
    name: 'Deny-RDP-From-Internet'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_deny_rdp_from_internet.json'))
  }
  {
    name: 'Deny-Redis-http'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_deny_redis_http.json'))
  }
  {
    name: 'Deny-Sql-minTLS'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_deny_sql_mintls.json'))
  }
  {
    name: 'Deny-SqlMi-minTLS'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_deny_sqlmi_mintls.json'))
  }
  {
    name: 'Deny-Storage-minTLS'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_deny_storage_mintls.json'))
  }
  {
    name: 'Deny-Subnet-Without-Nsg'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_deny_subnet_without_nsg.json'))
  }
  {
    name: 'Deny-Subnet-Without-Udr'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_deny_subnet_without_udr.json'))
  }
  {
    name: 'Deny-VNET-Peer-Cross-Sub'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_deny_vnet_peer_cross_sub.json'))
  }
  {
    name: 'Deny-VNET-Peering-To-Non-Approved-VNETs'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_deny_vnet_peering_to_non_approved_vnets.json'))
  }
  {
    name: 'Deny-VNet-Peering'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_deny_vnet_peering.json'))
  }
  {
    name: 'Deploy-ASC-SecurityContacts'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_deploy_asc_securitycontacts.json'))
  }
  {
    name: 'Deploy-Budget'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_deploy_budget.json'))
  }
  {
    name: 'Deploy-Custom-Route-Table'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_deploy_custom_route_table.json'))
  }
  {
    name: 'Deploy-DDoSProtection'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_deploy_ddosprotection.json'))
  }
  {
    name: 'Deploy-Diagnostics-AA'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_deploy_diagnostics_aa.json'))
  }
  {
    name: 'Deploy-Diagnostics-ACI'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_deploy_diagnostics_aci.json'))
  }
  {
    name: 'Deploy-Diagnostics-ACR'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_deploy_diagnostics_acr.json'))
  }
  {
    name: 'Deploy-Diagnostics-AnalysisService'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_deploy_diagnostics_analysisservice.json'))
  }
  {
    name: 'Deploy-Diagnostics-ApiForFHIR'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_deploy_diagnostics_apiforfhir.json'))
  }
  {
    name: 'Deploy-Diagnostics-APIMgmt'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_deploy_diagnostics_apimgmt.json'))
  }
  {
    name: 'Deploy-Diagnostics-ApplicationGateway'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_deploy_diagnostics_applicationgateway.json'))
  }
  {
    name: 'Deploy-Diagnostics-AVDScalingPlans'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_deploy_diagnostics_avdscalingplans.json'))
  }
  {
    name: 'Deploy-Diagnostics-Bastion'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_deploy_diagnostics_bastion.json'))
  }
  {
    name: 'Deploy-Diagnostics-CDNEndpoints'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_deploy_diagnostics_cdnendpoints.json'))
  }
  {
    name: 'Deploy-Diagnostics-CognitiveServices'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_deploy_diagnostics_cognitiveservices.json'))
  }
  {
    name: 'Deploy-Diagnostics-CosmosDB'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_deploy_diagnostics_cosmosdb.json'))
  }
  {
    name: 'Deploy-Diagnostics-Databricks'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_deploy_diagnostics_databricks.json'))
  }
  {
    name: 'Deploy-Diagnostics-DataExplorerCluster'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_deploy_diagnostics_dataexplorercluster.json'))
  }
  {
    name: 'Deploy-Diagnostics-DataFactory'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_deploy_diagnostics_datafactory.json'))
  }
  {
    name: 'Deploy-Diagnostics-DLAnalytics'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_deploy_diagnostics_dlanalytics.json'))
  }
  {
    name: 'Deploy-Diagnostics-EventGridSub'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_deploy_diagnostics_eventgridsub.json'))
  }
  {
    name: 'Deploy-Diagnostics-EventGridSystemTopic'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_deploy_diagnostics_eventgridsystemtopic.json'))
  }
  {
    name: 'Deploy-Diagnostics-EventGridTopic'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_deploy_diagnostics_eventgridtopic.json'))
  }
  {
    name: 'Deploy-Diagnostics-ExpressRoute'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_deploy_diagnostics_expressroute.json'))
  }
  {
    name: 'Deploy-Diagnostics-Firewall'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_deploy_diagnostics_firewall.json'))
  }
  {
    name: 'Deploy-Diagnostics-FrontDoor'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_deploy_diagnostics_frontdoor.json'))
  }
  {
    name: 'Deploy-Diagnostics-Function'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_deploy_diagnostics_function.json'))
  }
  {
    name: 'Deploy-Diagnostics-HDInsight'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_deploy_diagnostics_hdinsight.json'))
  }
  {
    name: 'Deploy-Diagnostics-iotHub'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_deploy_diagnostics_iothub.json'))
  }
  {
    name: 'Deploy-Diagnostics-LoadBalancer'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_deploy_diagnostics_loadbalancer.json'))
  }
  {
    name: 'Deploy-Diagnostics-LogicAppsISE'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_deploy_diagnostics_logicappsise.json'))
  }
  {
    name: 'Deploy-Diagnostics-MariaDB'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_deploy_diagnostics_mariadb.json'))
  }
  {
    name: 'Deploy-Diagnostics-MediaService'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_deploy_diagnostics_mediaservice.json'))
  }
  {
    name: 'Deploy-Diagnostics-MlWorkspace'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_deploy_diagnostics_mlworkspace.json'))
  }
  {
    name: 'Deploy-Diagnostics-MySQL'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_deploy_diagnostics_mysql.json'))
  }
  {
    name: 'Deploy-Diagnostics-NetworkSecurityGroups'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_deploy_diagnostics_networksecuritygroups.json'))
  }
  {
    name: 'Deploy-Diagnostics-NIC'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_deploy_diagnostics_nic.json'))
  }
  {
    name: 'Deploy-Diagnostics-PostgreSQL'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_deploy_diagnostics_postgresql.json'))
  }
  {
    name: 'Deploy-Diagnostics-PowerBIEmbedded'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_deploy_diagnostics_powerbiembedded.json'))
  }
  {
    name: 'Deploy-Diagnostics-RedisCache'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_deploy_diagnostics_rediscache.json'))
  }
  {
    name: 'Deploy-Diagnostics-Relay'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_deploy_diagnostics_relay.json'))
  }
  {
    name: 'Deploy-Diagnostics-SignalR'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_deploy_diagnostics_signalr.json'))
  }
  {
    name: 'Deploy-Diagnostics-SQLElasticPools'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_deploy_diagnostics_sqlelasticpools.json'))
  }
  {
    name: 'Deploy-Diagnostics-SQLMI'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_deploy_diagnostics_sqlmi.json'))
  }
  {
    name: 'Deploy-Diagnostics-TimeSeriesInsights'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_deploy_diagnostics_timeseriesinsights.json'))
  }
  {
    name: 'Deploy-Diagnostics-TrafficManager'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_deploy_diagnostics_trafficmanager.json'))
  }
  {
    name: 'Deploy-Diagnostics-VirtualNetwork'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_deploy_diagnostics_virtualnetwork.json'))
  }
  {
    name: 'Deploy-Diagnostics-VM'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_deploy_diagnostics_vm.json'))
  }
  {
    name: 'Deploy-Diagnostics-VMSS'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_deploy_diagnostics_vmss.json'))
  }
  {
    name: 'Deploy-Diagnostics-VNetGW'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_deploy_diagnostics_vnetgw.json'))
  }
  {
    name: 'Deploy-Diagnostics-WebServerFarm'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_deploy_diagnostics_webserverfarm.json'))
  }
  {
    name: 'Deploy-Diagnostics-Website'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_deploy_diagnostics_website.json'))
  }
  {
    name: 'Deploy-Diagnostics-WVDAppGroup'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_deploy_diagnostics_wvdappgroup.json'))
  }
  {
    name: 'Deploy-Diagnostics-WVDHostPools'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_deploy_diagnostics_wvdhostpools.json'))
  }
  {
    name: 'Deploy-Diagnostics-WVDWorkspace'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_deploy_diagnostics_wvdworkspace.json'))
  }
  {
    name: 'Deploy-FirewallPolicy'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_deploy_firewallpolicy.json'))
  }
  {
    name: 'Deploy-MySQL-sslEnforcement'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_deploy_mysql_sslenforcement.json'))
  }
  {
    name: 'Deploy-Nsg-FlowLogs-to-LA'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_deploy_nsg_flowlogs_to_la.json'))
  }
  {
    name: 'Deploy-Nsg-FlowLogs'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_deploy_nsg_flowlogs.json'))
  }
  {
    name: 'Deploy-PostgreSQL-sslEnforcement'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_deploy_postgresql_sslenforcement.json'))
  }
  {
    name: 'Deploy-Sql-AuditingSettings'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_deploy_sql_auditingsettings.json'))
  }
  {
    name: 'Deploy-SQL-minTLS'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_deploy_sql_mintls.json'))
  }
  {
    name: 'Deploy-Sql-SecurityAlertPolicies'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_deploy_sql_securityalertpolicies.json'))
  }
  {
    name: 'Deploy-Sql-Tde'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_deploy_sql_tde.json'))
  }
  {
    name: 'Deploy-Sql-vulnerabilityAssessments'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_deploy_sql_vulnerabilityassessments.json'))
  }
  {
    name: 'Deploy-SqlMi-minTLS'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_deploy_sqlmi_mintls.json'))
  }
  {
    name: 'Deploy-Storage-sslEnforcement'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_deploy_storage_sslenforcement.json'))
  }
  {
    name: 'Deploy-VNET-HubSpoke'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_deploy_vnet_hubspoke.json'))
  }
  {
    name: 'Deploy-Windows-DomainJoin'
    definition: json(loadTextContent('policy/policyDefinitions/policy_definition_es_deploy_windows_domainjoin.json'))
  }
]

@description('Variable containing all Custom Policy-Set Definitions info.')
var customPolicySetDefinitions = [
  {
    name: 'Billing-Tags-Policy'
    setDefinition: json(loadTextContent('./.parameters/test.policySet.definition.json'))
    setChildDefinitions: [
      {
        definitionReferenceId: 'ACRDenyPaasPublicIP'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/0fdf0491-d080-4575-b627-ad0e843cba0f'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy_set_definition_es_deny_publicpaasendpoints.parameters.json')).ACRDenyPaasPublicIP.parameters
      }
      {
        definitionReferenceId: 'AFSDenyPaasPublicIP'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/21a8cd35-125e-4d13-b82d-2e19b7208bb7'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy_set_definition_es_deny_publicpaasendpoints.parameters.json')).AFSDenyPaasPublicIP.parameters
      }
      {
        definitionReferenceId: 'AKSDenyPaasPublicIP'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/040732e8-d947-40b8-95d6-854c95024bf8'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy_set_definition_es_deny_publicpaasendpoints.parameters.json')).AKSDenyPaasPublicIP.parameters
      }
      {
        definitionReferenceId: 'BatchDenyPublicIP'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/74c5a0ae-5e48-4738-b093-65e23a060488'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy_set_definition_es_deny_publicpaasendpoints.parameters.json')).BatchDenyPublicIP.parameters
      }
    ]
  }
]

module policyDefs '../modules/authorization/policyDefinitions/managementGroup/deploy.bicep' = [for policy in policyDefinitions: {
  name: '${policy.name}'
  params: {
    name: policy.name
    location: location
    description: policy.properties.description
    displayName: policy.properties.displayName
    metadata: policy.properties.metadata
    mode: policy.properties.mode
    parameters: policy.properties.parameters
    policyRule: policy.properties.policyRule
  }
}]

/*
// Create Custom Policy-Set Defintions
module policySetDefs '../modules/authorization/policySetDefinitions/managementGroup/deploy.bicep' = [for policySet in policySetDefinitions: {
  name: '${policySet.name}'
  dependsOn: [
    policyDefs
  ]
  params: {
    name: policySet.name
    location: location
    description: policySet.properties.description
    displayName: policySet.properties.displayName
    metadata: policySet.properties.metadata
    parameters: policySet.properties.parameters
    policyDefinitions: [for policyDefinition in policyDefinitions: {
      policyDefinitionReferenceId: policyDefinition.definitionReferenceId
      policyDefinitionId: policyDefinition.definitionId
      parameters: policyDefinition.definitionParameters
    }]
    policyDefinitionGroups: policySet.properties.policyDefinitionGroups
    
  }
}]

*/
output targetMgResourceId string = targetMgResourceId
