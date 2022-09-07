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
    name: 'Deploy-Diagnostics-AA'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-AA.json'))
  }
  {
    name: 'Deploy-Diagnostics-ACI'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-ACI.json'))
  }
  {
    name: 'Deploy-Diagnostics-ACR'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-ACR.json'))
  }
  {
    name: 'Deploy-Diagnostics-AnalysisService'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-AnalysisService.json'))
  }
  {
    name: 'Deploy-Diagnostics-ApiForFHIR'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-ApiForFHIR.json'))
  }
  {
    name: 'Deploy-Diagnostics-APIMgmt'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-APIMgmt.json'))
  }
  {
    name: 'Deploy-Diagnostics-ApplicationGateway'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-ApplicationGateway.json'))
  }
  {
    name: 'Deploy-Diagnostics-Bastion'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-Bastion.json'))
  }
  {
    name: 'Deploy-Diagnostics-CDNEndpoints'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-CDNEndpoints.json'))
  }
  {
    name: 'Deploy-Diagnostics-CognitiveServices'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-CognitiveServices.json'))
  }
  {
    name: 'Deploy-Diagnostics-CosmosDB'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-CosmosDB.json'))
  }
  {
    name: 'Deploy-Diagnostics-Databricks'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-Databricks.json'))
  }
  {
    name: 'Deploy-Diagnostics-DataExplorerCluster'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-DataExplorerCluster.json'))
  }
  {
    name: 'Deploy-Diagnostics-DataFactory'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-DataFactory.json'))
  }
  {
    name: 'Deploy-Diagnostics-DLAnalytics'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-DLAnalytics.json'))
  }
  {
    name: 'Deploy-Diagnostics-EventGridSub'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-EventGridSub.json'))
  }
  {
    name: 'Deploy-Diagnostics-EventGridSystemTopic'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-EventGridSystemTopic.json'))
  }
  {
    name: 'Deploy-Diagnostics-EventGridTopic'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-EventGridTopic.json'))
  }
  {
    name: 'Deploy-Diagnostics-ExpressRoute'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-ExpressRoute.json'))
  }
  {
    name: 'Deploy-Diagnostics-Firewall'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-Firewall.json'))
  }
  {
    name: 'Deploy-Diagnostics-FrontDoor'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-FrontDoor.json'))
  }
  {
    name: 'Deploy-Diagnostics-Function'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-Function.json'))
  }
  {
    name: 'Deploy-Diagnostics-HDInsight'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-HDInsight.json'))
  }
  {
    name: 'Deploy-Diagnostics-iotHub'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-iotHub.json'))
  }
  {
    name: 'Deploy-Diagnostics-LoadBalancer'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-LoadBalancer.json'))
  }
  {
    name: 'Deploy-Diagnostics-LogicAppsISE'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-LogicAppsISE.json'))
  }
  {
    name: 'Deploy-Diagnostics-MariaDB'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-MariaDB.json'))
  }
  {
    name: 'Deploy-Diagnostics-MediaService'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-MediaService.json'))
  }
  {
    name: 'Deploy-Diagnostics-MlWorkspace'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-MlWorkspace.json'))
  }
  {
    name: 'Deploy-Diagnostics-MySQL'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-MySQL.json'))
  }
  {
    name: 'Deploy-Diagnostics-NetworkSecurityGroups'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-NetworkSecurityGroups.json'))
  }
  {
    name: 'Deploy-Diagnostics-NIC'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-NIC.json'))
  }
  {
    name: 'Deploy-Diagnostics-PostgreSQL'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-PostgreSQL.json'))
  }
  {
    name: 'Deploy-Diagnostics-PowerBIEmbedded'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-PowerBIEmbedded.json'))
  }
  {
    name: 'Deploy-Diagnostics-RedisCache'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-RedisCache.json'))
  }
  {
    name: 'Deploy-Diagnostics-Relay'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-Relay.json'))
  }
  {
    name: 'Deploy-Diagnostics-SignalR'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-SignalR.json'))
  }
  {
    name: 'Deploy-Diagnostics-SQLElasticPools'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-SQLElasticPools.json'))
  }
  {
    name: 'Deploy-Diagnostics-SQLMI'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-SQLMI.json'))
  }
  {
    name: 'Deploy-Diagnostics-TimeSeriesInsights'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-TimeSeriesInsights.json'))
  }
  {
    name: 'Deploy-Diagnostics-TrafficManager'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-TrafficManager.json'))
  }
  {
    name: 'Deploy-Diagnostics-VirtualNetwork'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-VirtualNetwork.json'))
  }
  {
    name: 'Deploy-Diagnostics-VM'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-VM.json'))
  }
  {
    name: 'Deploy-Diagnostics-VMSS'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-VMSS.json'))
  }
  {
    name: 'Deploy-Diagnostics-VNetGW'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-VNetGW.json'))
  }
  {
    name: 'Deploy-Diagnostics-WebServerFarm'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-WebServerFarm.json'))
  }
  {
    name: 'Deploy-Diagnostics-Website'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-Website.json'))
  }
  {
    name: 'Deploy-Diagnostics-WVDAppGroup'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-WVDAppGroup.json'))
  }
  {
    name: 'Deploy-Diagnostics-WVDHostPools'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-WVDHostPools.json'))
  }
  {
    name: 'Deploy-Diagnostics-WVDWorkspace'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-WVDWorkspace.json'))
  }
  {
    name: 'Deploy-Diagnostics-AzureActivity'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-AzureActivity.json'))
  }
]

@description('Variable containing all Custom Policy-Set Definitions info.')
var customPolicySetDefinitions = [
  {
    name: 'Deploy-Diagnostics-LogAnalytics'
    setDefinition: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.json'))
    setChildDefinitions: [
      {
        definitionReferenceId: 'ACIDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-ACI'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).ACIDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'ACRDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-ACR'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).ACRDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'AKSDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/6c66c325-74c8-42fd-a286-a74b0e2939d8'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).AKSDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'AnalysisServiceDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-AnalysisService'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).AnalysisServiceDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'APIforFHIRDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-ApiForFHIR'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).APIforFHIRDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'APIMgmtDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-APIMgmt'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).APIMgmtDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'ApplicationGatewayDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-ApplicationGateway'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).ApplicationGatewayDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'AppServiceDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-WebServerFarm'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).AppServiceDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'AppServiceWebappDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-Website'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).AppServiceWebappDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'AutomationDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-AA'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).AutomationDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'BastionDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-Bastion'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).BastionDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'BatchDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/c84e5349-db6d-4769-805e-e14037dab9b5'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).BatchDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'CDNEndpointsDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-CDNEndpoints'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).CDNEndpointsDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'CognitiveServicesDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-CognitiveServices'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).CognitiveServicesDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'CosmosDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-CosmosDB'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).CosmosDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'DatabricksDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-Databricks'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).DatabricksDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'DataExplorerClusterDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-DataExplorerCluster'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).DataExplorerClusterDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'DataFactoryDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-DataFactory'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).DataFactoryDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'DataLakeAnalyticsDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-DLAnalytics'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).DataLakeAnalyticsDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'DataLakeStoreDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/d56a5a7c-72d7-42bc-8ceb-3baf4c0eae03'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).DataLakeStoreDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'EventGridSubDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-EventGridSub'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).EventGridSubDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'EventGridTopicDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-EventGridTopic'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).EventGridTopicDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'EventHubDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/1f6e93e8-6b31-41b1-83f6-36e449a42579'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).EventHubDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'EventSystemTopicDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-EventGridSystemTopic'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).EventSystemTopicDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'ExpressRouteDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-ExpressRoute'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).ExpressRouteDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'FirewallDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-Firewall'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).FirewallDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'FrontDoorDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-FrontDoor'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).FrontDoorDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'FunctionAppDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-Function'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).FunctionAppDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'HDInsightDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-HDInsight'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).HDInsightDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'IotHubDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-iotHub'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).IotHubDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'KeyVaultDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/bef3f64c-5290-43b7-85b0-9b254eef4c47'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).KeyVaultDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'LoadBalancerDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-LoadBalancer'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).LoadBalancerDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'LogicAppsISEDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-LogicAppsISE'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).LogicAppsISEDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'LogicAppsWFDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/b889a06c-ec72-4b03-910a-cb169ee18721'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).LogicAppsWFDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'MariaDBDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-MariaDB'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).MariaDBDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'MediaServiceDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-MediaService'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).MediaServiceDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'MlWorkspaceDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-MlWorkspace'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).MlWorkspaceDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'MySQLDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-MySQL'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).MySQLDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'NetworkNICDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-NIC'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).NetworkNICDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'NetworkPublicIPNicDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/752154a7-1e0f-45c6-a880-ac75a7e4f648'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).NetworkPublicIPNicDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'NetworkSecurityGroupsDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-NetworkSecurityGroups'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).NetworkSecurityGroupsDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'PostgreSQLDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-PostgreSQL'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).PostgreSQLDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'PowerBIEmbeddedDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-PowerBIEmbedded'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).PowerBIEmbeddedDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'RecoveryVaultDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/c717fb0c-d118-4c43-ab3d-ece30ac81fb3'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).RecoveryVaultDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'RedisCacheDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-RedisCache'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).RedisCacheDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'RelayDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-Relay'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).RelayDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'SearchServicesDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/08ba64b8-738f-4918-9686-730d2ed79c7d'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).SearchServicesDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'ServiceBusDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/04d53d87-841c-4f23-8a5b-21564380b55e'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).ServiceBusDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'SignalRDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-SignalR'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).SignalRDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'SQLDatabaseDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/b79fa14e-238a-4c2d-b376-442ce508fc84'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).SQLDatabaseDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'SQLElasticPoolsDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-SQLElasticPools'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).SQLElasticPoolsDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'SQLMDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-SQLMI'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).SQLMDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'StorageAccountDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/6f8f98a4-f108-47cb-8e98-91a0d85cd474'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).StorageAccountDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'StreamAnalyticsDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/237e0f7e-b0e8-4ec4-ad46-8c12cb66d673'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).StreamAnalyticsDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'TimeSeriesInsightsDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-TimeSeriesInsights'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).TimeSeriesInsightsDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'TrafficManagerDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-TrafficManager'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).TrafficManagerDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'VirtualMachinesDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-VM'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).VirtualMachinesDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'VirtualNetworkDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-VirtualNetwork'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).VirtualNetworkDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'VMSSDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-VMSS'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).VMSSDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'VNetGWDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-VNetGW'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).VNetGWDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'WVDAppGroupDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-WVDAppGroup'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).WVDAppGroupDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'WVDHostPoolsDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-WVDHostPools'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).WVDHostPoolsDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'WVDWorkspaceDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-WVDWorkspace'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics.parameters.json')).WVDWorkspaceDeployDiagnosticLogDeployLogAnalytics.parameters
      }
    ]
  }
  {
    name: 'Deploy-Diagnostics-LogAnalytics-Sentinel'
    setDefinition: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics-Sentinel.json'))
    setChildDefinitions: [
      {
        definitionReferenceId: 'AzureActivityDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-AzureActivity'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics-Sentinel.parameters.json')).AzureActivityDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'FirewallDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-Firewall'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics-Sentinel.parameters.json')).FirewallDeployDiagnosticLogDeployLogAnalytics.parameters
      }
      {
        definitionReferenceId: 'KeyVaultDeployDiagnosticLogDeployLogAnalytics'
        definitionId: '/providers/Microsoft.Authorization/policyDefinitions/bef3f64c-5290-43b7-85b0-9b254eef4c47'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-LogAnalytics-Sentinel.parameters.json')).KeyVaultDeployDiagnosticLogDeployLogAnalytics.parameters
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
