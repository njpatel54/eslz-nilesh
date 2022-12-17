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
    name: 'Deploy-Diag-AA-StgAcct'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-stg-AA.json'))
  }
  {
    name: 'Deploy-Diagnostics-ACI-StgAcct'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-stg-ACI.json'))
  }
  {
    name: 'Deploy-Diagnostics-ACR-StgAcct'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-stg-ACR.json'))
  }
  {
    name: 'Deploy-Diagnostics-AnalysisService-StgAcct'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-stg-AnalysisService.json'))
  }
  {
    name: 'Deploy-Diagnostics-ApiForFHIR-StgAcct'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-stg-ApiForFHIR.json'))
  }
  {
    name: 'Deploy-Diagnostics-APIMgmt-StgAcct'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-stg-APIMgmt.json'))
  }
  {
    name: 'Deploy-Diagnostics-AppGateway-StgAcct'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-stg-ApplicationGateway.json'))
  }
  {
    name: 'Deploy-Diagnostics-Bastion-StgAcct'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-stg-Bastion.json'))
  }
  {
    name: 'Deploy-Diagnostics-Batch-StgAcct'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-stg-Batch.json'))
  }
  {
    name: 'Deploy-Diagnostics-CDNEndpoints-StgAcct'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-stg-CDNEndpoints.json'))
  }
  {
    name: 'Deploy-Diagnostics-CognitiveServices-StgAcct'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-stg-CognitiveServices.json'))
  }
  {
    name: 'Deploy-Diagnostics-CosmosDB-StgAcct'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-stg-CosmosDB.json'))
  }
  {
    name: 'Deploy-Diagnostics-Databricks-StgAcct'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-stg-Databricks.json'))
  }
  {
    name: 'Deploy-Diagnostics-DataExplorerCluster-StgAcct'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-stg-DataExplorerCluster.json'))
  }
  {
    name: 'Deploy-Diagnostics-DataFactory-StgAcct'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-stg-DataFactory.json'))
  }
  {
    name: 'Deploy-Diagnostics-DLAnalytics-StgAcct'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-stg-DLAnalytics.json'))
  }
  {
    name: 'Deploy-Diagnostics-EventGridSub-StgAcct'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-stg-EventGridSub.json'))
  }
  {
    name: 'Deploy-Diag-EventGridSystemTopic-StgAcct'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-stg-EventGridSystemTopic.json'))
  }
  {
    name: 'Deploy-Diag-EventGridTopic-StgAcct'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-stg-EventGridTopic.json'))
  }
  {
    name: 'Deploy-Diagnostics-EventHub-StgAcct'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-stg-EventHub.json'))
  }
  {
    name: 'Deploy-Diag-ExpressRoute-StgAcct'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-stg-ExpressRoute.json'))
  }
  {
    name: 'Deploy-Diagnostics-Firewall-StgAcct'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-stg-Firewall.json'))
  }
  {
    name: 'Deploy-Diagnostics-FrontDoor-StgAcct'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-stg-FrontDoor.json'))
  }
  {
    name: 'Deploy-Diagnostics-Function-StgAcct'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-stg-Function.json'))
  }
  {
    name: 'Deploy-Diagnostics-HDInsight-StgAcct'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-stg-HDInsight.json'))
  }
  {
    name: 'Deploy-Diagnostics-iotHub-StgAcct'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-stg-iotHub.json'))
  }
  {
    name: 'Deploy-Diagnostics-KeyVault-StgAcct'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-stg-KeyVault.json'))
  }
  {
    name: 'Deploy-Diagnostics-AKS-StgAcct'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-stg-Kubernetes.json'))
  }
  {
    name: 'Deploy-Diagnostics-LoadBalancer-StgAcct'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-stg-LoadBalancer.json'))
  }
  {
    name: 'Deploy-Diagnostics-LogicAppsWF-StgAcct'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-stg-LogicApps.json'))
  }
  {
    name: 'Deploy-Diagnostics-LogicAppsISE-StgAcct'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-stg-LogicAppsISE.json'))
  }
  {
    name: 'Deploy-Diagnostics-MariaDB-StgAcct'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-stg-MariaDB.json'))
  }
  {
    name: 'Deploy-Diagnostics-MediaService-StgAcct'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-stg-MediaService.json'))
  }
  {
    name: 'Deploy-Diagnostics-MlWorkspace-StgAcct'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-stg-MlWorkspace.json'))
  }
  {
    name: 'Deploy-Diagnostics-MySQL-StgAcct'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-stg-MySQL.json'))
  }
  {
    name: 'Deploy-Diag-NetworkSecurityGroups-StgAcct'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-stg-NetworkSecurityGroups.json'))
  }
  {
    name: 'Deploy-Diagnostics-NIC-StgAcct'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-stg-NIC.json'))
  }
  {
    name: 'Deploy-Diagnostics-PostgreSQL-StgAcct'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-stg-PostgreSQL.json'))
  }
  {
    name: 'Deploy-Diag-PowerBIEmbedded-StgAcct'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-stg-PowerBIEmbedded.json'))
  }
  {
    name: 'Deploy-Diagnostics-PublicIP-StgAcct'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-stg-PublicIP.json'))
  }
  {
    name: 'Deploy-Diagnostics-RedisCache-StgAcct'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-stg-RedisCache.json'))
  }
  {
    name: 'Deploy-Diagnostics-Relay-StgAcct'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-stg-Relay.json'))
  }
  {
    name: 'Deploy-Diagnostics-SearchServices-StgAcct'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-stg-SearchService.json'))
  }
  {
    name: 'Deploy-Diagnostics-ServiceBus-StgAcct'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-stg-ServiceBus.json'))
  }
  {
    name: 'Deploy-Diagnostics-SignalR-StgAcct'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-stg-SignalR.json'))
  }
  {
    name: 'Deploy-Diagnostics-SQLDBs-StgAcct'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-stg-SQLDatabase.json'))
  }
  {
    name: 'Deploy-Diagnostics-SQLElasticPools-StgAcct'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-stg-SQLElasticPools.json'))
  }
  {
    name: 'Deploy-Diagnostics-SQLMI-StgAcct'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-stg-SQLMI.json'))
  }
  {
    name: 'Deploy-Diagnostics-StorageAccounts-StgAcct'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-stg-StorageAccount.json'))
  }
  {
    name: 'Deploy-Diagnostics-StreamAnalytics-StgAcct'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-stg-StreamAnalytics.json'))
  }
  {
    name: 'Deploy-Diagnostics-TimeSeriesInsights-StgAcct'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-stg-TimeSeriesInsights.json'))
  }
  {
    name: 'Deploy-Diagnostics-TrafficManager-StgAcct'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-stg-TrafficManager.json'))
  }
  {
    name: 'Deploy-Diagnostics-VirtualNetwork-StgAcct'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-stg-VirtualNetwork.json'))
  }
  {
    name: 'Deploy-Diagnostics-VM-StgAcct'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-stg-VM.json'))
  }
  {
    name: 'Deploy-Diagnostics-VMSS-StgAcct'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-stg-VMSS.json'))
  }
  {
    name: 'Deploy-Diagnostics-VNetGW-StgAcct'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-stg-VNetGW.json'))
  }
  {
    name: 'Deploy-Diagnostics-WebServerFarm-StgAcct'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-stg-WebServerFarm.json'))
  }
  {
    name: 'Deploy-Diagnostics-Website-StgAcct'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-stg-Website.json'))
  }
  {
    name: 'Deploy-Diagnostics-WVDAppGroup-StgAcct'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-stg-WVDAppGroup.json'))
  }
  {
    name: 'Deploy-Diagnostics-WVDHostPools-StgAcct'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-stg-WVDHostPools.json'))
  }
  {
    name: 'Deploy-Diagnostics-WVDWorkspace-StgAcct'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-stg-WVDWorkspace.json'))
  }
  {
    name: 'Deploy-Diagnostics-RSV-StgAcct'
    definition: json(loadTextContent('policyDefinitions/policy-def-Deploy-Diagnostics-stg-RecoveryServicesVault.json'))
  }  
]

@description('Variable containing all Custom Policy-Set Definitions info.')
var customPolicySetDefinitions = [
  {
    name: 'Deploy-Diagnostics-StorageAcct'
    setDefinition: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-StorageAcct.json'))
    setChildDefinitions: [
      {
        definitionReferenceId: 'ACIDeployDiagnosticLogDeployStorageAcct'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-ACI-StgAcct'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-StorageAcct.parameters.json')).ACIDeployDiagnosticLogDeployStorageAcct.parameters
      }
      {
        definitionReferenceId: 'ACRDeployDiagnosticLogDeployStorageAcct'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-ACR-StgAcct'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-StorageAcct.parameters.json')).ACRDeployDiagnosticLogDeployStorageAcct.parameters
      }
      {
        definitionReferenceId: 'AKSDeployDiagnosticLogDeployStorageAcct'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-AKS-StgAcct'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-StorageAcct.parameters.json')).AKSDeployDiagnosticLogDeployStorageAcct.parameters
      }
      {
        definitionReferenceId: 'AnalysisServiceDeployDiagnosticLogDeployStorageAcct'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-AnalysisService-StgAcct'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-StorageAcct.parameters.json')).AnalysisServiceDeployDiagnosticLogDeployStorageAcct.parameters
      }
      {
        definitionReferenceId: 'APIforFHIRDeployDiagnosticLogDeployStorageAcct'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-ApiForFHIR-StgAcct'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-StorageAcct.parameters.json')).APIforFHIRDeployDiagnosticLogDeployStorageAcct.parameters
      }
      {
        definitionReferenceId: 'APIMgmtDeployDiagnosticLogDeployStorageAcct'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-APIMgmt-StgAcct'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-StorageAcct.parameters.json')).APIMgmtDeployDiagnosticLogDeployStorageAcct.parameters
      }
      {
        definitionReferenceId: 'ApplicationGatewayDeployDiagnosticLogDeployStorageAcct'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-AppGateway-StgAcct'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-StorageAcct.parameters.json')).ApplicationGatewayDeployDiagnosticLogDeployStorageAcct.parameters
      }
      {
        definitionReferenceId: 'AppServiceDeployDiagnosticLogDeployStorageAcct'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-WebServerFarm-StgAcct'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-StorageAcct.parameters.json')).AppServiceDeployDiagnosticLogDeployStorageAcct.parameters
      }
      {
        definitionReferenceId: 'AppServiceWebappDeployDiagnosticLogDeployStorageAcct'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-Website-StgAcct'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-StorageAcct.parameters.json')).AppServiceWebappDeployDiagnosticLogDeployStorageAcct.parameters
      }
      {
        definitionReferenceId: 'AutomationDeployDiagnosticLogDeployStorageAcct'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diag-AA-StgAcct'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-StorageAcct.parameters.json')).AutomationDeployDiagnosticLogDeployStorageAcct.parameters
      }
      {
        definitionReferenceId: 'BastionDeployDiagnosticLogDeployStorageAcct'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-Bastion-StgAcct'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-StorageAcct.parameters.json')).BastionDeployDiagnosticLogDeployStorageAcct.parameters
      }
      {
        definitionReferenceId: 'BatchDeployDiagnosticLogDeployStorageAcct'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-Batch-StgAcct'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-StorageAcct.parameters.json')).BatchDeployDiagnosticLogDeployStorageAcct.parameters
      }
      {
        definitionReferenceId: 'CDNEndpointsDeployDiagnosticLogDeployStorageAcct'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-CDNEndpoints-StgAcct'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-StorageAcct.parameters.json')).CDNEndpointsDeployDiagnosticLogDeployStorageAcct.parameters
      }
      {
        definitionReferenceId: 'CognitiveServicesDeployDiagnosticLogDeployStorageAcct'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-CognitiveServices-StgAcct'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-StorageAcct.parameters.json')).CognitiveServicesDeployDiagnosticLogDeployStorageAcct.parameters
      }
      {
        definitionReferenceId: 'CosmosDeployDiagnosticLogDeployStorageAcct'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-CosmosDB-StgAcct'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-StorageAcct.parameters.json')).CosmosDeployDiagnosticLogDeployStorageAcct.parameters
      }
      {
        definitionReferenceId: 'DatabricksDeployDiagnosticLogDeployStorageAcct'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-Databricks-StgAcct'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-StorageAcct.parameters.json')).DatabricksDeployDiagnosticLogDeployStorageAcct.parameters
      }
      {
        definitionReferenceId: 'DataExplorerClusterDeployDiagnosticLogDeployStorageAcct'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-DataExplorerCluster-StgAcct'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-StorageAcct.parameters.json')).DataExplorerClusterDeployDiagnosticLogDeployStorageAcct.parameters
      }
      {
        definitionReferenceId: 'DataFactoryDeployDiagnosticLogDeployStorageAcct'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-DataFactory-StgAcct'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-StorageAcct.parameters.json')).DataFactoryDeployDiagnosticLogDeployStorageAcct.parameters
      }
      {
        definitionReferenceId: 'DataLakeAnalyticsDeployDiagnosticLogDeployStorageAcct'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-DLAnalytics-StgAcct'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-StorageAcct.parameters.json')).DataLakeAnalyticsDeployDiagnosticLogDeployStorageAcct.parameters
      }
      {
        definitionReferenceId: 'EventGridSubDeployDiagnosticLogDeployStorageAcct'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-EventGridSub-StgAcct'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-StorageAcct.parameters.json')).EventGridSubDeployDiagnosticLogDeployStorageAcct.parameters
      }
      {
        definitionReferenceId: 'EventGridTopicDeployDiagnosticLogDeployStorageAcct'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diag-EventGridTopic-StgAcct'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-StorageAcct.parameters.json')).EventGridTopicDeployDiagnosticLogDeployStorageAcct.parameters
      }
      {
        definitionReferenceId: 'EventHubDeployDiagnosticLogDeployStorageAcct'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-EventHub-StgAcct'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-StorageAcct.parameters.json')).EventHubDeployDiagnosticLogDeployStorageAcct.parameters
      }
      {
        definitionReferenceId: 'EventSystemTopicDeployDiagnosticLogDeployStorageAcct'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diag-EventGridSystemTopic-StgAcct'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-StorageAcct.parameters.json')).EventSystemTopicDeployDiagnosticLogDeployStorageAcct.parameters
      }
      {
        definitionReferenceId: 'ExpressRouteDeployDiagnosticLogDeployStorageAcct'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diag-ExpressRoute-StgAcct'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-StorageAcct.parameters.json')).ExpressRouteDeployDiagnosticLogDeployStorageAcct.parameters
      }
      {
        definitionReferenceId: 'FirewallDeployDiagnosticLogDeployStorageAcct'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-Firewall-StgAcct'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-StorageAcct.parameters.json')).FirewallDeployDiagnosticLogDeployStorageAcct.parameters
      }
      {
        definitionReferenceId: 'FrontDoorDeployDiagnosticLogDeployStorageAcct'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-FrontDoor-StgAcct'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-StorageAcct.parameters.json')).FrontDoorDeployDiagnosticLogDeployStorageAcct.parameters
      }
      {
        definitionReferenceId: 'FunctionAppDeployDiagnosticLogDeployStorageAcct'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-Function-StgAcct'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-StorageAcct.parameters.json')).FunctionAppDeployDiagnosticLogDeployStorageAcct.parameters
      }
      {
        definitionReferenceId: 'HDInsightDeployDiagnosticLogDeployStorageAcct'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-HDInsight-StgAcct'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-StorageAcct.parameters.json')).HDInsightDeployDiagnosticLogDeployStorageAcct.parameters
      }
      {
        definitionReferenceId: 'IotHubDeployDiagnosticLogDeployStorageAcct'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-iotHub-StgAcct'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-StorageAcct.parameters.json')).IotHubDeployDiagnosticLogDeployStorageAcct.parameters
      }
      {
        definitionReferenceId: 'KeyVaultDeployDiagnosticLogDeployStorageAcct'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-KeyVault-StgAcct'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-StorageAcct.parameters.json')).KeyVaultDeployDiagnosticLogDeployStorageAcct.parameters
      }
      {
        definitionReferenceId: 'LoadBalancerDeployDiagnosticLogDeployStorageAcct'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-LoadBalancer-StgAcct'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-StorageAcct.parameters.json')).LoadBalancerDeployDiagnosticLogDeployStorageAcct.parameters
      }
      {
        definitionReferenceId: 'LogicAppsISEDeployDiagnosticLogDeployStorageAcct'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-LogicAppsISE-StgAcct'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-StorageAcct.parameters.json')).LogicAppsISEDeployDiagnosticLogDeployStorageAcct.parameters
      }
      {
        definitionReferenceId: 'LogicAppsWFDeployDiagnosticLogDeployStorageAcct'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-LogicAppsWF-StgAcct'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-StorageAcct.parameters.json')).LogicAppsWFDeployDiagnosticLogDeployStorageAcct.parameters
      }
      {
        definitionReferenceId: 'MariaDBDeployDiagnosticLogDeployStorageAcct'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-MariaDB-StgAcct'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-StorageAcct.parameters.json')).MariaDBDeployDiagnosticLogDeployStorageAcct.parameters
      }
      {
        definitionReferenceId: 'MediaServiceDeployDiagnosticLogDeployStorageAcct'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-MediaService-StgAcct'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-StorageAcct.parameters.json')).MediaServiceDeployDiagnosticLogDeployStorageAcct.parameters
      }
      {
        definitionReferenceId: 'MlWorkspaceDeployDiagnosticLogDeployStorageAcct'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-MlWorkspace-StgAcct'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-StorageAcct.parameters.json')).MlWorkspaceDeployDiagnosticLogDeployStorageAcct.parameters
      }
      {
        definitionReferenceId: 'MySQLDeployDiagnosticLogDeployStorageAcct'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-MySQL-StgAcct'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-StorageAcct.parameters.json')).MySQLDeployDiagnosticLogDeployStorageAcct.parameters
      }
      {
        definitionReferenceId: 'NetworkNICDeployDiagnosticLogDeployStorageAcct'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-NIC-StgAcct'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-StorageAcct.parameters.json')).NetworkNICDeployDiagnosticLogDeployStorageAcct.parameters
      }
      {
        definitionReferenceId: 'NetworkSecurityGroupsDeployDiagnosticLogDeployStorageAcct'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diag-NetworkSecurityGroups-StgAcct'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-StorageAcct.parameters.json')).NetworkSecurityGroupsDeployDiagnosticLogDeployStorageAcct.parameters
      }
      {
        definitionReferenceId: 'PostgreSQLDeployDiagnosticLogDeployStorageAcct'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-PostgreSQL-StgAcct'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-StorageAcct.parameters.json')).PostgreSQLDeployDiagnosticLogDeployStorageAcct.parameters
      }
      {
        definitionReferenceId: 'PowerBIEmbeddedDeployDiagnosticLogDeployStorageAcct'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diag-PowerBIEmbedded-StgAcct'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-StorageAcct.parameters.json')).PowerBIEmbeddedDeployDiagnosticLogDeployStorageAcct.parameters
      }
      {
        definitionReferenceId: 'PublicIPDeployDiagnosticLogDeployStorageAcct'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-PublicIP-StgAcct'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-StorageAcct.parameters.json')).PublicIPDeployDiagnosticLogDeployStorageAcct.parameters
      }
      {
        definitionReferenceId: 'RedisCacheDeployDiagnosticLogDeployStorageAcct'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-RedisCache-StgAcct'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-StorageAcct.parameters.json')).RedisCacheDeployDiagnosticLogDeployStorageAcct.parameters
      }
      {
        definitionReferenceId: 'RelayDeployDiagnosticLogDeployStorageAcct'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-Relay-StgAcct'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-StorageAcct.parameters.json')).RelayDeployDiagnosticLogDeployStorageAcct.parameters
      }
      {
        definitionReferenceId: 'SearchServicesDeployDiagnosticLogDeployStorageAcct'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-SearchServices-StgAcct'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-StorageAcct.parameters.json')).SearchServicesDeployDiagnosticLogDeployStorageAcct.parameters
      }
      {
        definitionReferenceId: 'ServiceBusDeployDiagnosticLogDeployStorageAcct'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-ServiceBus-StgAcct'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-StorageAcct.parameters.json')).ServiceBusDeployDiagnosticLogDeployStorageAcct.parameters
      }
      {
        definitionReferenceId: 'SignalRDeployDiagnosticLogDeployStorageAcct'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-SignalR-StgAcct'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-StorageAcct.parameters.json')).SignalRDeployDiagnosticLogDeployStorageAcct.parameters
      }
      {
        definitionReferenceId: 'SQLElasticPoolsDeployDiagnosticLogDeployStorageAcct'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-SQLElasticPools-StgAcct'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-StorageAcct.parameters.json')).SQLElasticPoolsDeployDiagnosticLogDeployStorageAcct.parameters
      }
      {
        definitionReferenceId: 'SQLMDeployDiagnosticLogDeployStorageAcct'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-SQLMI-StgAcct'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-StorageAcct.parameters.json')).SQLMDeployDiagnosticLogDeployStorageAcct.parameters
      }
      {
        definitionReferenceId: 'StorageAccountsDeployDiagnosticLogDeployStorageAcct'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-StorageAccounts-StgAcct'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-StorageAcct.parameters.json')).StorageAccountsDeployDiagnosticLogDeployStorageAcct.parameters
      }
      {
        definitionReferenceId: 'StreamAnalyticsDeployDiagnosticLogDeployStorageAcct'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-StreamAnalytics-StgAcct'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-StorageAcct.parameters.json')).StreamAnalyticsDeployDiagnosticLogDeployStorageAcct.parameters
      }
      {
        definitionReferenceId: 'TimeSeriesInsightsDeployDiagnosticLogDeployStorageAcct'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-TimeSeriesInsights-StgAcct'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-StorageAcct.parameters.json')).TimeSeriesInsightsDeployDiagnosticLogDeployStorageAcct.parameters
      }
      {
        definitionReferenceId: 'TrafficManagerDeployDiagnosticLogDeployStorageAcct'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-TrafficManager-StgAcct'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-StorageAcct.parameters.json')).TrafficManagerDeployDiagnosticLogDeployStorageAcct.parameters
      }
      {
        definitionReferenceId: 'VirtualMachinesDeployDiagnosticLogDeployStorageAcct'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-VM-StgAcct'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-StorageAcct.parameters.json')).VirtualMachinesDeployDiagnosticLogDeployStorageAcct.parameters
      }
      {
        definitionReferenceId: 'VirtualNetworkDeployDiagnosticLogDeployStorageAcct'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-VirtualNetwork-StgAcct'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-StorageAcct.parameters.json')).VirtualNetworkDeployDiagnosticLogDeployStorageAcct.parameters
      }
      {
        definitionReferenceId: 'VMSSDeployDiagnosticLogDeployStorageAcct'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-VMSS-StgAcct'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-StorageAcct.parameters.json')).VMSSDeployDiagnosticLogDeployStorageAcct.parameters
      }
      {
        definitionReferenceId: 'VNetGWDeployDiagnosticLogDeployStorageAcct'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-VNetGW-StgAcct'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-StorageAcct.parameters.json')).VNetGWDeployDiagnosticLogDeployStorageAcct.parameters
      }
      {
        definitionReferenceId: 'WVDAppGroupDeployDiagnosticLogDeployStorageAcct'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-WVDAppGroup-StgAcct'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-StorageAcct.parameters.json')).WVDAppGroupDeployDiagnosticLogDeployStorageAcct.parameters
      }
      {
        definitionReferenceId: 'WVDHostPoolsDeployDiagnosticLogDeployStorageAcct'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-WVDHostPools-StgAcct'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-StorageAcct.parameters.json')).WVDHostPoolsDeployDiagnosticLogDeployStorageAcct.parameters
      }
      {
        definitionReferenceId: 'WVDWorkspaceDeployDiagnosticLogDeployStorageAcct'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-WVDWorkspace-StgAcct'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-StorageAcct.parameters.json')).WVDWorkspaceDeployDiagnosticLogDeployStorageAcct.parameters
      }
      {
        definitionReferenceId: 'RecoveryVaultDeployDiagnosticLogDeployStorageAcct'
        definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deploy-Diagnostics-RSV-StgAcct'
        definitionParameters: json(loadTextContent('policySetDefinitions/policy-defset-Deploy-Diagnostics-StorageAcct.parameters.json')).RecoveryVaultDeployDiagnosticLogDeployStorageAcct.parameters
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
