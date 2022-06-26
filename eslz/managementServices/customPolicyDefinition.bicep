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
    definition: json(loadTextContent('policy/policyDefinitions/policy-def-Append-AppService-httpsonly.json'))
  }
  {
    name: 'Append-AppService-latestTLS'
    definition: json(loadTextContent('policy/policyDefinitions/policy-def-Append-AppService-latestTLS.json'))
  }
  {
    name: 'Append-KV-SoftDelete'
    definition: json(loadTextContent('policy/policyDefinitions/policy-def-Append-KV-SoftDelete.json'))
  }
  {
    name: 'Append-Redis-disableNonSslPort'
    definition: json(loadTextContent('policy/policyDefinitions/policy-def-Append-Redis-disableNonSslPort.json'))
  }
  {
    name: 'Append-Redis-sslEnforcement'
    definition: json(loadTextContent('policy/policyDefinitions/policy-def-Append-Redis-sslEnforcement.json'))
  }
  {
    name: 'Deny-AA-child-resources'
    definition: json(loadTextContent('policy/policyDefinitions/policy-def-Deny-AA-child-resources.json'))
  }
  {
    name: 'Deny-AppGW-Without-WAF'
    definition: json(loadTextContent('policy/policyDefinitions/policy-def-Deny-AppGW-Without-WAF.json'))
  }
  {
    name: 'Deny-AppServiceApiApp-http'
    definition: json(loadTextContent('policy/policyDefinitions/policy-def-Deny-AppServiceApiApp-http.json'))
  }
  {
    name: 'Deny-AppServiceFunctionApp-http'
    definition: json(loadTextContent('policy/policyDefinitions/policy-def-Deny-AppServiceFunctionApp-http.json'))
  }
  {
    name: 'Deny-AppServiceWebApp-http'
    definition: json(loadTextContent('policy/policyDefinitions/policy-def-Deny-AppServiceWebApp-http.json'))
  }
  {
    name: 'Deny-MySql-http'
    definition: json(loadTextContent('policy/policyDefinitions/policy-def-Deny-MySql-http.json'))
  }
  {
    name: 'Deny-PostgreSql-http'
    definition: json(loadTextContent('policy/policyDefinitions/policy-def-Deny-PostgreSql-http.json'))
  }
  {
    name: 'Deny-Private-DNS-Zones'
    definition: json(loadTextContent('policy/policyDefinitions/policy-def-Deny-Private-DNS-Zones.json'))
  }
  {
    name: 'Deny-PublicEndpoint-MariaDB'
    definition: json(loadTextContent('policy/policyDefinitions/policy-def-Deny-PublicEndpoint-MariaDB.json'))
  }
  {
    name: 'Deny-PublicIP'
    definition: json(loadTextContent('policy/policyDefinitions/policy-def-Deny-PublicIP.json'))
  }
  {
    name: 'Deny-RDP-From-Internet'
    definition: json(loadTextContent('policy/policyDefinitions/policy-def-Deny-RDP-From-Internet.json'))
  }
  {
    name: 'Deny-Redis-http'
    definition: json(loadTextContent('policy/policyDefinitions/policy-def-Deny-Redis-http.json'))
  }
  {
    name: 'Deny-Sql-minTLS'
    definition: json(loadTextContent('policy/policyDefinitions/policy-def-Deny-Sql-minTLS.json'))
  }
  {
    name: 'Deny-SqlMi-minTLS'
    definition: json(loadTextContent('policy/policyDefinitions/policy-def-Deny-SqlMi-minTLS.json'))
  }
  {
    name: 'Deny-Storage-minTLS'
    definition: json(loadTextContent('policy/policyDefinitions/policy-def-Deny-Storage-minTLS.json'))
  }
  {
    name: 'Deny-Subnet-Without-Nsg'
    definition: json(loadTextContent('policy/policyDefinitions/policy-def-Deny-Subnet-Without-Nsg.json'))
  }
  {
    name: 'Deny-Subnet-Without-Udr'
    definition: json(loadTextContent('policy/policyDefinitions/policy-def-Deny-Subnet-Without-Udr.json'))
  }
  {
    name: 'Deny-VNET-Peer-Cross-Sub'
    definition: json(loadTextContent('policy/policyDefinitions/policy-def-Deny-VNET-Peer-Cross-Sub.json'))
  }
  {
    name: 'Deny-VNET-Peering-To-Non-Approved-VNETs'
    definition: json(loadTextContent('policy/policyDefinitions/policy-def-Deny-VNET-Peering-To-Non-Approved-VNETs.json'))
  }
  {
    name: 'Deny-VNet-Peering'
    definition: json(loadTextContent('policy/policyDefinitions/policy-def-Deny-VNet-Peering.json'))
  }
  {
    name: 'Deploy-ASC-SecurityContacts'
    definition: json(loadTextContent('policy/policyDefinitions/policy-def-Deploy-ASC-SecurityContacts.json'))
  }
  {
    name: 'Deploy-Budget'
    definition: json(loadTextContent('policy/policyDefinitions/policy-def-Deploy-Budget.json'))
  }
  {
    name: 'Deploy-DDoSProtection'
    definition: json(loadTextContent('policy/policyDefinitions/policy-def-Deploy-DDoSProtection.json'))
  }
  {
    name: 'Deploy-Default-Udr'
    definition: json(loadTextContent('policy/policyDefinitions/policy-def-Deploy-Default-Udr.json'))
  }
  {
    name: 'Deploy-Diagnostics-AA'
    definition: json(loadTextContent('policy/policyDefinitions/policy-def-Deploy-Diagnostics-AA.json'))
  }
  {
    name: 'Deploy-Diagnostics-ACI'
    definition: json(loadTextContent('policy/policyDefinitions/policy-def-Deploy-Diagnostics-ACI.json'))
  }
  {
    name: 'Deploy-Diagnostics-ACR'
    definition: json(loadTextContent('policy/policyDefinitions/policy-def-Deploy-Diagnostics-ACR.json'))
  }
  {
    name: 'Deploy-Diagnostics-AnalysisService'
    definition: json(loadTextContent('policy/policyDefinitions/policy-def-Deploy-Diagnostics-AnalysisService.json'))
  }
  {
    name: 'Deploy-Diagnostics-ApiForFHIR'
    definition: json(loadTextContent('policy/policyDefinitions/policy-def-Deploy-Diagnostics-ApiForFHIR.json'))
  }
  {
    name: 'Deploy-Diagnostics-APIMgmt'
    definition: json(loadTextContent('policy/policyDefinitions/policy-def-Deploy-Diagnostics-APIMgmt.json'))
  }
  {
    name: 'Deploy-Diagnostics-ApplicationGateway'
    definition: json(loadTextContent('policy/policyDefinitions/policy-def-Deploy-Diagnostics-ApplicationGateway.json'))
  }
  {
    name: 'Deploy-Diagnostics-Bastion'
    definition: json(loadTextContent('policy/policyDefinitions/policy-def-Deploy-Diagnostics-Bastion.json'))
  }
  {
    name: 'Deploy-Diagnostics-CDNEndpoints'
    definition: json(loadTextContent('policy/policyDefinitions/policy-def-Deploy-Diagnostics-CDNEndpoints.json'))
  }
  {
    name: 'Deploy-Diagnostics-CognitiveServices'
    definition: json(loadTextContent('policy/policyDefinitions/policy-def-Deploy-Diagnostics-CognitiveServices.json'))
  }
  {
    name: 'Deploy-Diagnostics-CosmosDB'
    definition: json(loadTextContent('policy/policyDefinitions/policy-def-Deploy-Diagnostics-CosmosDB.json'))
  }
  {
    name: 'Deploy-Diagnostics-Databricks'
    definition: json(loadTextContent('policy/policyDefinitions/policy-def-Deploy-Diagnostics-Databricks.json'))
  }
  {
    name: 'Deploy-Diagnostics-DataExplorerCluster'
    definition: json(loadTextContent('policy/policyDefinitions/policy-def-Deploy-Diagnostics-DataExplorerCluster.json'))
  }
  {
    name: 'Deploy-Diagnostics-DataFactory'
    definition: json(loadTextContent('policy/policyDefinitions/policy-def-Deploy-Diagnostics-DataFactory.json'))
  }
  {
    name: 'Deploy-Diagnostics-DLAnalytics'
    definition: json(loadTextContent('policy/policyDefinitions/policy-def-Deploy-Diagnostics-DLAnalytics.json'))
  }
  {
    name: 'Deploy-Diagnostics-EventGridSub'
    definition: json(loadTextContent('policy/policyDefinitions/policy-def-Deploy-Diagnostics-EventGridSub.json'))
  }
  {
    name: 'Deploy-Diagnostics-EventGridSystemTopic'
    definition: json(loadTextContent('policy/policyDefinitions/policy-def-Deploy-Diagnostics-EventGridSystemTopic.json'))
  }
  {
    name: 'Deploy-Diagnostics-EventGridTopic'
    definition: json(loadTextContent('policy/policyDefinitions/policy-def-Deploy-Diagnostics-EventGridTopic.json'))
  }
  {
    name: 'Deploy-Diagnostics-ExpressRoute'
    definition: json(loadTextContent('policy/policyDefinitions/policy-def-Deploy-Diagnostics-ExpressRoute.json'))
  }
  {
    name: 'Deploy-Diagnostics-Firewall'
    definition: json(loadTextContent('policy/policyDefinitions/policy-def-Deploy-Diagnostics-Firewall.json'))
  }
  {
    name: 'Deploy-Diagnostics-FrontDoor'
    definition: json(loadTextContent('policy/policyDefinitions/policy-def-Deploy-Diagnostics-FrontDoor.json'))
  }
  {
    name: 'Deploy-Diagnostics-Function'
    definition: json(loadTextContent('policy/policyDefinitions/policy-def-Deploy-Diagnostics-Function.json'))
  }
  {
    name: 'Deploy-Diagnostics-HDInsight'
    definition: json(loadTextContent('policy/policyDefinitions/policy-def-Deploy-Diagnostics-HDInsight.json'))
  }
  {
    name: 'Deploy-Diagnostics-iotHub'
    definition: json(loadTextContent('policy/policyDefinitions/policy-def-Deploy-Diagnostics-iotHub.json'))
  }
  {
    name: 'Deploy-Diagnostics-LoadBalancer'
    definition: json(loadTextContent('policy/policyDefinitions/policy-def-Deploy-Diagnostics-LoadBalancer.json'))
  }
  {
    name: 'Deploy-Diagnostics-LogicAppsISE'
    definition: json(loadTextContent('policy/policyDefinitions/policy-def-Deploy-Diagnostics-LogicAppsISE.json'))
  }
  {
    name: 'Deploy-Diagnostics-MariaDB'
    definition: json(loadTextContent('policy/policyDefinitions/policy-def-Deploy-Diagnostics-MariaDB.json'))
  }
  {
    name: 'Deploy-Diagnostics-MediaService'
    definition: json(loadTextContent('policy/policyDefinitions/policy-def-Deploy-Diagnostics-MediaService.json'))
  }
  {
    name: 'Deploy-Diagnostics-MlWorkspace'
    definition: json(loadTextContent('policy/policyDefinitions/policy-def-Deploy-Diagnostics-MlWorkspace.json'))
  }
  {
    name: 'Deploy-Diagnostics-MySQL'
    definition: json(loadTextContent('policy/policyDefinitions/policy-def-Deploy-Diagnostics-MySQL.json'))
  }
  {
    name: 'Deploy-Diagnostics-NetworkSecurityGroups'
    definition: json(loadTextContent('policy/policyDefinitions/policy-def-Deploy-Diagnostics-NetworkSecurityGroups.json'))
  }
  {
    name: 'Deploy-Diagnostics-NIC'
    definition: json(loadTextContent('policy/policyDefinitions/policy-def-Deploy-Diagnostics-NIC.json'))
  }
  {
    name: 'Deploy-Diagnostics-PostgreSQL'
    definition: json(loadTextContent('policy/policyDefinitions/policy-def-Deploy-Diagnostics-PostgreSQL.json'))
  }
  {
    name: 'Deploy-Diagnostics-PowerBIEmbedded'
    definition: json(loadTextContent('policy/policyDefinitions/policy-def-Deploy-Diagnostics-PowerBIEmbedded.json'))
  }
  {
    name: 'Deploy-Diagnostics-RedisCache'
    definition: json(loadTextContent('policy/policyDefinitions/policy-def-Deploy-Diagnostics-RedisCache.json'))
  }
  {
    name: 'Deploy-Diagnostics-Relay'
    definition: json(loadTextContent('policy/policyDefinitions/policy-def-Deploy-Diagnostics-Relay.json'))
  }
  {
    name: 'Deploy-Diagnostics-SignalR'
    definition: json(loadTextContent('policy/policyDefinitions/policy-def-Deploy-Diagnostics-SignalR.json'))
  }
  {
    name: 'Deploy-Diagnostics-SQLElasticPools'
    definition: json(loadTextContent('policy/policyDefinitions/policy-def-Deploy-Diagnostics-SQLElasticPools.json'))
  }
  {
    name: 'Deploy-Diagnostics-SQLMI'
    definition: json(loadTextContent('policy/policyDefinitions/policy-def-Deploy-Diagnostics-SQLMI.json'))
  }
  {
    name: 'Deploy-Diagnostics-TimeSeriesInsights'
    definition: json(loadTextContent('policy/policyDefinitions/policy-def-Deploy-Diagnostics-TimeSeriesInsights.json'))
  }
  {
    name: 'Deploy-Diagnostics-TrafficManager'
    definition: json(loadTextContent('policy/policyDefinitions/policy-def-Deploy-Diagnostics-TrafficManager.json'))
  }
  {
    name: 'Deploy-Diagnostics-VirtualNetwork'
    definition: json(loadTextContent('policy/policyDefinitions/policy-def-Deploy-Diagnostics-VirtualNetwork.json'))
  }
  {
    name: 'Deploy-Diagnostics-VM'
    definition: json(loadTextContent('policy/policyDefinitions/policy-def-Deploy-Diagnostics-VM.json'))
  }
  {
    name: 'Deploy-Diagnostics-VMSS'
    definition: json(loadTextContent('policy/policyDefinitions/policy-def-Deploy-Diagnostics-VMSS.json'))
  }
  {
    name: 'Deploy-Diagnostics-VNetGW'
    definition: json(loadTextContent('policy/policyDefinitions/policy-def-Deploy-Diagnostics-VNetGW.json'))
  }
  {
    name: 'Deploy-Diagnostics-WebServerFarm'
    definition: json(loadTextContent('policy/policyDefinitions/policy-def-Deploy-Diagnostics-WebServerFarm.json'))
  }
  {
    name: 'Deploy-Diagnostics-Website'
    definition: json(loadTextContent('policy/policyDefinitions/policy-def-Deploy-Diagnostics-Website.json'))
  }
  {
    name: 'Deploy-Diagnostics-WVDAppGroup'
    definition: json(loadTextContent('policy/policyDefinitions/policy-def-Deploy-Diagnostics-WVDAppGroup.json'))
  }
  {
    name: 'Deploy-Diagnostics-WVDHostPools'
    definition: json(loadTextContent('policy/policyDefinitions/policy-def-Deploy-Diagnostics-WVDHostPools.json'))
  }
  {
    name: 'Deploy-Diagnostics-WVDWorkspace'
    definition: json(loadTextContent('policy/policyDefinitions/policy-def-Deploy-Diagnostics-WVDWorkspace.json'))
  }
  {
    name: 'Deploy-FirewallPolicy'
    definition: json(loadTextContent('policy/policyDefinitions/policy-def-Deploy-FirewallPolicy.json'))
  }
  {
    name: 'Deploy-MySQL-sslEnforcement'
    definition: json(loadTextContent('policy/policyDefinitions/policy-def-Deploy-MySQL-sslEnforcement.json'))
  }
  {
    name: 'Deploy-Nsg-FlowLogs-to-LA'
    definition: json(loadTextContent('policy/policyDefinitions/policy-def-Deploy-Nsg-FlowLogs-to-LA.json'))
  }
  {
    name: 'Deploy-Nsg-FlowLogs'
    definition: json(loadTextContent('policy/policyDefinitions/policy-def-Deploy-Nsg-FlowLogs.json'))
  }
  {
    name: 'Deploy-PostgreSQL-sslEnforcement'
    definition: json(loadTextContent('policy/policyDefinitions/policy-def-Deploy-PostgreSQL-sslEnforcement.json'))
  }
  {
    name: 'Deploy-Sql-AuditingSettings'
    definition: json(loadTextContent('policy/policyDefinitions/policy-def-Deploy-Sql-AuditingSettings.json'))
  }
  {
    name: 'Deploy-SQL-minTLS'
    definition: json(loadTextContent('policy/policyDefinitions/policy-def-Deploy-SQL-minTLS.json'))
  }
  {
    name: 'Deploy-Sql-SecurityAlertPolicies'
    definition: json(loadTextContent('policy/policyDefinitions/policy-def-Deploy-Sql-SecurityAlertPolicies.json'))
  }
  {
    name: 'Deploy-Sql-Tde'
    definition: json(loadTextContent('policy/policyDefinitions/policy-def-Deploy-Sql-Tde.json'))
  }
  {
    name: 'Deploy-Sql-vulnerabilityAssessments'
    definition: json(loadTextContent('policy/policyDefinitions/policy-def-Deploy-Sql-vulnerabilityAssessments.json'))
  }
  {
    name: 'Deploy-SqlMi-minTLS'
    definition: json(loadTextContent('policy/policyDefinitions/policy-def-Deploy-SqlMi-minTLS.json'))
  }
  {
    name: 'Deploy-Storage-sslEnforcement'
    definition: json(loadTextContent('policy/policyDefinitions/policy-def-Deploy-Storage-sslEnforcement.json'))
  }
  {
    name: 'Deploy-VNET-HubSpoke'
    definition: json(loadTextContent('policy/policyDefinitions/policy-def-Deploy-VNET-HubSpoke.json'))
  }
  {
    name: 'Deploy-Windows-DomainJoin'
    definition: json(loadTextContent('policy/policyDefinitions/policy-def-Deploy-Windows-DomainJoin.json'))
  }
]

@description('Variable containing all Custom Policy-Set Definitions info.')
var customPolicySetDefinitions = [
  {
    name: 'Deploy-Diagnostics-LogAnalytics'
    setDefinition: json(loadTextContent('policy/policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.json'))
    setChildDefinitions: [
      {
        definitionReferenceId: 'ACIDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-ACI'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).ACIDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'ACRDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-ACR'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).ACRDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'AKSDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/6c66c325-74c8-42fd-a286-a74b0e2939d8'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).AKSDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'AnalysisServiceDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-AnalysisService'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).AnalysisServiceDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'APIforFHIRDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-ApiForFHIR'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).APIforFHIRDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'APIMgmtDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-APIMgmt'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).APIMgmtDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'ApplicationGatewayDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-ApplicationGateway'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).ApplicationGatewayDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'AppServiceDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-WebServerFarm'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).AppServiceDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'AppServiceWebappDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-Website'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).AppServiceWebappDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'AutomationDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-AA'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).AutomationDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'BastionDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-Bastion'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).BastionDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'BatchDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/c84e5349-db6d-4769-805e-e14037dab9b5'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).BatchDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'CDNEndpointsDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-CDNEndpoints'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).CDNEndpointsDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'CognitiveServicesDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-CognitiveServices'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).CognitiveServicesDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'CosmosDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-CosmosDB'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).CosmosDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'DatabricksDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-Databricks'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).DatabricksDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'DataExplorerClusterDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-DataExplorerCluster'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).DataExplorerClusterDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'DataFactoryDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-DataFactory'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).DataFactoryDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'DataLakeAnalyticsDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-DLAnalytics'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).DataLakeAnalyticsDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'DataLakeStoreDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/d56a5a7c-72d7-42bc-8ceb-3baf4c0eae03'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).DataLakeStoreDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'EventGridSubDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-EventGridSub'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).EventGridSubDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'EventGridTopicDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-EventGridTopic'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).EventGridTopicDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'EventHubDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/1f6e93e8-6b31-41b1-83f6-36e449a42579'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).EventHubDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'EventSystemTopicDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-EventGridSystemTopic'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).EventSystemTopicDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'ExpressRouteDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-ExpressRoute'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).ExpressRouteDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'FirewallDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-Firewall'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).FirewallDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'FrontDoorDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-FrontDoor'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).FrontDoorDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'FunctionAppDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-Function'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).FunctionAppDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'HDInsightDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-HDInsight'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).HDInsightDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'IotHubDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-iotHub'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).IotHubDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'KeyVaultDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/bef3f64c-5290-43b7-85b0-9b254eef4c47'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).KeyVaultDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'LoadBalancerDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-LoadBalancer'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).LoadBalancerDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'LogicAppsISEDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-LogicAppsISE'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).LogicAppsISEDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'LogicAppsWFDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/b889a06c-ec72-4b03-910a-cb169ee18721'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).LogicAppsWFDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'MariaDBDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-MariaDB'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).MariaDBDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'MediaServiceDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-MediaService'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).MediaServiceDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'MlWorkspaceDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-MlWorkspace'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).MlWorkspaceDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'MySQLDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-MySQL'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).MySQLDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'NetworkNICDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-NIC'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).NetworkNICDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'NetworkPublicIPNicDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/752154a7-1e0f-45c6-a880-ac75a7e4f648'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).NetworkPublicIPNicDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'NetworkSecurityGroupsDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-NetworkSecurityGroups'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).NetworkSecurityGroupsDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'PostgreSQLDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-PostgreSQL'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).PostgreSQLDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'PowerBIEmbeddedDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-PowerBIEmbedded'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).PowerBIEmbeddedDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'RecoveryVaultDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/c717fb0c-d118-4c43-ab3d-ece30ac81fb3'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).RecoveryVaultDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'RedisCacheDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-RedisCache'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).RedisCacheDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'RelayDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-Relay'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).RelayDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'SearchServicesDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/08ba64b8-738f-4918-9686-730d2ed79c7d'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).SearchServicesDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'ServiceBusDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/04d53d87-841c-4f23-8a5b-21564380b55e'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).ServiceBusDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'SignalRDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-SignalR'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).SignalRDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'SQLDatabaseDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/b79fa14e-238a-4c2d-b376-442ce508fc84'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).SQLDatabaseDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'SQLElasticPoolsDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-SQLElasticPools'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).SQLElasticPoolsDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'SQLMDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-SQLMI'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).SQLMDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'StorageAccountDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/6f8f98a4-f108-47cb-8e98-91a0d85cd474'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).StorageAccountDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'StreamAnalyticsDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/237e0f7e-b0e8-4ec4-ad46-8c12cb66d673'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).StreamAnalyticsDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'TimeSeriesInsightsDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-TimeSeriesInsights'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).TimeSeriesInsightsDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'TrafficManagerDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-TrafficManager'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).TrafficManagerDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'VirtualMachinesDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-VM'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).VirtualMachinesDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'VirtualNetworkDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-VirtualNetwork'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).VirtualNetworkDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'VMSSDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-VMSS'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).VMSSDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'VNetGWDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-VNetGW'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).VNetGWDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'WVDAppGroupDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-WVDAppGroup'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).WVDAppGroupDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'WVDHostPoolsDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-WVDHostPools'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).WVDHostPoolsDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'WVDWorkspaceDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-WVDWorkspace'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).WVDWorkspaceDeployDiagnosticLogDeployLogAnalytics.parameters
      }
    ]
  }
  {
    name: 'Deploy-MDFC-Config'
    setDefinition: json(loadTextContent('policy/policySetDefinitions/policy-defset-Deploy-MDFC-Config.json'))
    setChildDefinitions: [
      {
        definitionReferenceId: 'ascExport'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/ffb6f416-7bd2-4488-8828-56585fef2be9'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Deploy-MDFC-Config.parameters.json')).ascExport.parameters
      }
      {
        definitionReferenceId: 'defenderForArm'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/b7021b2b-08fd-4dc0-9de7-3c6ece09faf9'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Deploy-MDFC-Config.parameters.json')).defenderForArm.parameters
      }
      {
        definitionReferenceId: 'defenderForContainers'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/c9ddb292-b203-4738-aead-18e2716e858f'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Deploy-MDFC-Config.parameters.json')).defenderForContainers.parameters
      }
      {
        definitionReferenceId: 'defenderForDns'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/2370a3c1-4a25-4283-a91a-c9c1a145fb2f'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Deploy-MDFC-Config.parameters.json')).defenderForDns.parameters
      }
      {
        definitionReferenceId: 'defenderForSqlPaas'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/b99b73e7-074b-4089-9395-b7236f094491'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Deploy-MDFC-Config.parameters.json')).defenderForSqlPaas.parameters
      }
      {
        definitionReferenceId: 'defenderForStorageAccounts'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/74c30959-af11-47b3-9ed2-a26e03f427a3'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Deploy-MDFC-Config.parameters.json')).defenderForStorageAccounts.parameters
      }
      {
        definitionReferenceId: 'defenderForVM'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/8e86a5b6-b9bd-49d1-8e21-4bb8a0862222'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Deploy-MDFC-Config.parameters.json')).defenderForVM.parameters
      }
      {
        definitionReferenceId: 'securityEmailContact'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-ASC-SecurityContacts'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Deploy-MDFC-Config.parameters.json')).securityEmailContact.parameters
      }
    ]
  }
  {
    name: 'Deploy-Sql-Security'
    setDefinition: json(loadTextContent('policy/policySetDefinitions/policy-defset-Deploy-Sql-Security.json'))
    setChildDefinitions: [
      {
        definitionReferenceId: 'SqlDbAuditingSettingsDeploySqlSecurity'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Sql-AuditingSettings'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Deploy-Sql-Security.parameters.json')).SqlDbAuditingSettingsDeploySqlSecurity.parameters
      }
      {
        definitionReferenceId: 'SqlDbSecurityAlertPoliciesDeploySqlSecurity'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Sql-SecurityAlertPolicies'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Deploy-Sql-Security.parameters.json')).SqlDbSecurityAlertPoliciesDeploySqlSecurity.parameters
      }
      {
        definitionReferenceId: 'SqlDbTdeDeploySqlSecurity'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Sql-Tde'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Deploy-Sql-Security.parameters.json')).SqlDbTdeDeploySqlSecurity.parameters
      }
      {
        definitionReferenceId: 'SqlDbVulnerabilityAssessmentsDeploySqlSecurity'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Sql-vulnerabilityAssessments'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Deploy-Sql-Security.parameters.json')).SqlDbVulnerabilityAssessmentsDeploySqlSecurity.parameters
      }
    ]
  }
  {
    name: 'Enforce-Encryption-CMK'
    setDefinition: json(loadTextContent('policy/policySetDefinitions/policy-defset-Enforce-Encryption-CMK.json'))
    setChildDefinitions: [
      {
        definitionReferenceId: 'ACRCmkDeny'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/5b9159ae-1701-4a6f-9a7a-aa9c8ddd0580'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Enforce-Encryption-CMK.parameters.json')).ACRCmkDeny.parameters
      }
      {
        definitionReferenceId: 'AksCmkDeny'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/7d7be79c-23ba-4033-84dd-45e2a5ccdd67'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Enforce-Encryption-CMK.parameters.json')).AksCmkDeny.parameters
      }
      {
        definitionReferenceId: 'AzureBatchCMKEffect'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/99e9ccd8-3db9-4592-b0d1-14b1715a4d8a'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Enforce-Encryption-CMK.parameters.json')).AzureBatchCMKEffect.parameters
      }
      {
        definitionReferenceId: 'CognitiveServicesCMK'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/67121cc7-ff39-4ab8-b7e3-95b84dab487d'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Enforce-Encryption-CMK.parameters.json')).CognitiveServicesCMK.parameters
      }
      {
        definitionReferenceId: 'CosmosCMKEffect'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/1f905d99-2ab7-462c-a6b0-f709acca6c8f'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Enforce-Encryption-CMK.parameters.json')).CosmosCMKEffect.parameters
      }
      {
        definitionReferenceId: 'DataBoxCMKEffect'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/86efb160-8de7-451d-bc08-5d475b0aadae'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Enforce-Encryption-CMK.parameters.json')).DataBoxCMKEffect.parameters
      }
      {
        definitionReferenceId: 'EncryptedVMDisksEffect'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/0961003e-5a0a-4549-abde-af6a37f2724d'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Enforce-Encryption-CMK.parameters.json')).EncryptedVMDisksEffect.parameters
      }
      {
        definitionReferenceId: 'SqlServerTDECMKEffect'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/0d134df8-db83-46fb-ad72-fe0c9428c8dd'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Enforce-Encryption-CMK.parameters.json')).SqlServerTDECMKEffect.parameters
      }
      {
        definitionReferenceId: 'StorageCMKEffect'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/6fac406b-40ca-413b-bf8e-0bf964659c25'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Enforce-Encryption-CMK.parameters.json')).StorageCMKEffect.parameters
      }
      {
        definitionReferenceId: 'StreamAnalyticsCMKEffect'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/87ba29ef-1ab3-4d82-b763-87fcd4f531f7'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Enforce-Encryption-CMK.parameters.json')).StreamAnalyticsCMKEffect.parameters
      }
      {
        definitionReferenceId: 'SynapseWorkspaceCMKEffect'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/f7d52b2d-e161-4dfa-a82b-55e564167385'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Enforce-Encryption-CMK.parameters.json')).SynapseWorkspaceCMKEffect.parameters
      }
      {
        definitionReferenceId: 'WorkspaceCMK'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/ba769a63-b8cc-4b2d-abf6-ac33c7204be8'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Enforce-Encryption-CMK.parameters.json')).WorkspaceCMK.parameters
      }
    ]
  }
  {
    name: 'Enforce-EncryptTransit'
    setDefinition: json(loadTextContent('policy/policySetDefinitions/policy-defset-Enforce-EncryptTransit.json'))
    setChildDefinitions: [
      {
        definitionReferenceId: 'AKSIngressHttpsOnlyEffect'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/1a5b4dca-0b6f-4cf5-907c-56316bc1bf3d'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Enforce-EncryptTransit.parameters.json')).AKSIngressHttpsOnlyEffect.parameters
      }
      {
        definitionReferenceId: 'APIAppServiceHttpsEffect'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deny-AppServiceApiApp-http'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Enforce-EncryptTransit.parameters.json')).APIAppServiceHttpsEffect.parameters
      }
      {
        definitionReferenceId: 'APIAppServiceLatestTlsEffect'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/8cb6aa8b-9e41-4f4e-aa25-089a7ac2581e'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Enforce-EncryptTransit.parameters.json')).APIAppServiceLatestTlsEffect.parameters
      }
      {
        definitionReferenceId: 'AppServiceHttpEffect'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Append-AppService-httpsonly'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Enforce-EncryptTransit.parameters.json')).AppServiceHttpEffect.parameters
      }
      {
        definitionReferenceId: 'AppServiceminTlsVersion'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Append-AppService-latestTLS'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Enforce-EncryptTransit.parameters.json')).AppServiceminTlsVersion.parameters
      }
      {
        definitionReferenceId: 'FunctionLatestTlsEffect'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/f9d614c5-c173-4d56-95a7-b4437057d193'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Enforce-EncryptTransit.parameters.json')).FunctionLatestTlsEffect.parameters
      }
      {
        definitionReferenceId: 'FunctionServiceHttpsEffect'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deny-AppServiceFunctionApp-http'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Enforce-EncryptTransit.parameters.json')).FunctionServiceHttpsEffect.parameters
      }
      {
        definitionReferenceId: 'MySQLEnableSSLDeployEffect'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-MySQL-sslEnforcement'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Enforce-EncryptTransit.parameters.json')).MySQLEnableSSLDeployEffect.parameters
      }
      {
        definitionReferenceId: 'MySQLEnableSSLEffect'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deny-MySql-http'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Enforce-EncryptTransit.parameters.json')).MySQLEnableSSLEffect.parameters
      }
      {
        definitionReferenceId: 'PostgreSQLEnableSSLDeployEffect'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-PostgreSQL-sslEnforcement'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Enforce-EncryptTransit.parameters.json')).PostgreSQLEnableSSLDeployEffect.parameters
      }
      {
        definitionReferenceId: 'PostgreSQLEnableSSLEffect'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deny-PostgreSql-http'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Enforce-EncryptTransit.parameters.json')).PostgreSQLEnableSSLEffect.parameters
      }
      {
        definitionReferenceId: 'RedisDenyhttps'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deny-Redis-http'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Enforce-EncryptTransit.parameters.json')).RedisDenyhttps.parameters
      }
      {
        definitionReferenceId: 'RedisdisableNonSslPort'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Append-Redis-disableNonSslPort'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Enforce-EncryptTransit.parameters.json')).RedisdisableNonSslPort.parameters
      }
      {
        definitionReferenceId: 'RedisTLSDeployEffect'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Append-Redis-sslEnforcement'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Enforce-EncryptTransit.parameters.json')).RedisTLSDeployEffect.parameters
      }
      {
        definitionReferenceId: 'SQLManagedInstanceTLSDeployEffect'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-SqlMi-minTLS'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Enforce-EncryptTransit.parameters.json')).SQLManagedInstanceTLSDeployEffect.parameters
      }
      {
        definitionReferenceId: 'SQLManagedInstanceTLSEffect'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deny-SqlMi-minTLS'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Enforce-EncryptTransit.parameters.json')).SQLManagedInstanceTLSEffect.parameters
      }
      {
        definitionReferenceId: 'SQLServerTLSDeployEffect'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-SQL-minTLS'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Enforce-EncryptTransit.parameters.json')).SQLServerTLSDeployEffect.parameters
      }
      {
        definitionReferenceId: 'SQLServerTLSEffect'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deny-Sql-minTLS'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Enforce-EncryptTransit.parameters.json')).SQLServerTLSEffect.parameters
      }
      {
        definitionReferenceId: 'StorageDeployHttpsEnabledEffect'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Storage-sslEnforcement'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Enforce-EncryptTransit.parameters.json')).StorageDeployHttpsEnabledEffect.parameters
      }
      {
        definitionReferenceId: 'StorageHttpsEnabledEffect'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deny-Storage-minTLS'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Enforce-EncryptTransit.parameters.json')).StorageHttpsEnabledEffect.parameters
      }
      {
        definitionReferenceId: 'WebAppServiceHttpsEffect'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deny-AppServiceWebApp-http'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Enforce-EncryptTransit.parameters.json')).WebAppServiceHttpsEffect.parameters
      }
      {
        definitionReferenceId: 'WebAppServiceLatestTlsEffect'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/f0e6e85b-9b9f-4a4b-b67b-f730d42f1b0b'
        definitionParameters: json(loadTextContent('policy/policySetDefinitions/policy-defset-Enforce-EncryptTransit.parameters.json')).WebAppServiceLatestTlsEffect.parameters
      }
    ]
  }
  
]

// Create Custom Policy Defintions
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

// Create Custom Policy-Set Defintions
module policySetDefinitions '../modules/authorization/policySetDefinitions/managementGroup/deploy.bicep' = [for policySet in customPolicySetDefinitions: {
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
