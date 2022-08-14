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
    name: 'Deploy-Diagnostics-AA-EH'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-eh-AA.json'))
  }
  {
    name: 'Deploy-Diagnostics-ACI-EH'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-eh-ACI.json'))
  }
  {
    name: 'Deploy-Diagnostics-ACR-EH'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-eh-ACR.json'))
  }
  {
    name: 'Deploy-Diagnostics-AnalysisService-EH'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-eh-AnalysisService.json'))
  }
  {
    name: 'Deploy-Diagnostics-ApiForFHIR-EH'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-eh-ApiForFHIR.json'))
  }
  {
    name: 'Deploy-Diagnostics-APIMgmt-EH'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-eh-APIMgmt.json'))
  }
  {
    name: 'Deploy-Diagnostics-ApplicationGateway-EH'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-eh-ApplicationGateway.json'))
  }
  {
    name: 'Deploy-Diagnostics-Bastion-EH'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-eh-Bastion.json'))
  }
  {
    name: 'Deploy-Diagnostics-Batch-EH'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-eh-Batch.json'))
  }
  {
    name: 'Deploy-Diagnostics-CDNEndpoints-EH'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-eh-CDNEndpoints.json'))
  }
  {
    name: 'Deploy-Diagnostics-CognitiveServices-EH'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-eh-CognitiveServices.json'))
  }
  {
    name: 'Deploy-Diagnostics-CosmosDB-EH'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-eh-CosmosDB.json'))
  }
  {
    name: 'Deploy-Diagnostics-Databricks-EH'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-eh-Databricks.json'))
  }
  {
    name: 'Deploy-Diagnostics-DataExplorerCluster-EH'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-eh-DataExplorerCluster.json'))
  }
  {
    name: 'Deploy-Diagnostics-DataFactory-EH'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-eh-DataFactory.json'))
  }
  {
    name: 'Deploy-Diagnostics-DLAnalytics-EH'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-eh-DLAnalytics.json'))
  }
  {
    name: 'Deploy-Diagnostics-EventGridSub-EH'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-eh-EventGridSub.json'))
  }
  {
    name: 'Deploy-Diagnostics-EventGridSystemTopic-EH'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-eh-EventGridSystemTopic.json'))
  }
  {
    name: 'Deploy-Diagnostics-EventGridTopic-EH'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-eh-EventGridTopic.json'))
  }
  {
    name: 'Deploy-Diagnostics-ExpressRoute-EH'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-eh-ExpressRoute.json'))
  }
  {
    name: 'Deploy-Diagnostics-Firewall-EH'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-eh-Firewall.json'))
  }
  {
    name: 'Deploy-Diagnostics-FrontDoor-EH'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-eh-FrontDoor.json'))
  }
  {
    name: 'Deploy-Diagnostics-Function-EH'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-eh-Function.json'))
  }
  {
    name: 'Deploy-Diagnostics-HDInsight-EH'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-eh-HDInsight.json'))
  }
  {
    name: 'Deploy-Diagnostics-iotHub-EH'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-eh-iotHub.json'))
  }
  {
    name: 'Deploy-Diagnostics-Kubernetes-EH'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-eh-Kubernetes.json'))
  }
  {
    name: 'Deploy-Diagnostics-LoadBalancer-EH'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-eh-LoadBalancer.json'))
  }
  {
    name: 'Deploy-Diagnostics-LogicAppsISE-EH'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-eh-LogicAppsISE.json'))
  }
  {
    name: 'Deploy-Diagnostics-MariaDB-EH'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-eh-MariaDB.json'))
  }
  {
    name: 'Deploy-Diagnostics-MediaService-EH'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-eh-MediaService.json'))
  }
  {
    name: 'Deploy-Diagnostics-MlWorkspace-EH'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-eh-MlWorkspace.json'))
  }
  {
    name: 'Deploy-Diagnostics-MySQL-EH'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-eh-MySQL.json'))
  }
  {
    name: 'Deploy-Diagnostics-NetworkSecurityGroups-EH'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-eh-NetworkSecurityGroups.json'))
  }
  {
    name: 'Deploy-Diagnostics-NIC-EH'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-eh-NIC.json'))
  }
  {
    name: 'Deploy-Diagnostics-PostgreSQL-EH'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-eh-PostgreSQL.json'))
  }
  {
    name: 'Deploy-Diagnostics-PowerBIEmbedded-EH'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-eh-PowerBIEmbedded.json'))
  }
  {
    name: 'Deploy-Diagnostics-PublicIP-EH'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-eh-PublicIP.json'))
  }
  {
    name: 'Deploy-Diagnostics-RedisCache-EH'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-eh-RedisCache.json'))
  }
  {
    name: 'Deploy-Diagnostics-Relay-EH'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-eh-Relay.json'))
  }
  {
    name: 'Deploy-Diagnostics-SignalR-EH'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-eh-SignalR.json'))
  }
  {
    name: 'Deploy-Diagnostics-SQLDatabase-EH'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-eh-SQLDatabase.json'))
  }
  {
    name: 'Deploy-Diagnostics-SQLElasticPools-EH'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-eh-SQLElasticPools.json'))
  }
  {
    name: 'Deploy-Diagnostics-SQLMI-EH'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-eh-SQLMI.json'))
  }
  {
    name: 'Deploy-Diagnostics-StorageAccount-EH'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-eh-StorageAccount.json'))
  }
  {
    name: 'Deploy-Diagnostics-TimeSeriesInsights-EH'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-eh-TimeSeriesInsights.json'))
  }
  {
    name: 'Deploy-Diagnostics-TrafficManager-EH'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-eh-TrafficManager.json'))
  }
  {
    name: 'Deploy-Diagnostics-VirtualNetwork-EH'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-eh-VirtualNetwork.json'))
  }
  {
    name: 'Deploy-Diagnostics-VM-EH'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-eh-VM.json'))
  }
  {
    name: 'Deploy-Diagnostics-VMSS-EH'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-eh-VMSS.json'))
  }
  {
    name: 'Deploy-Diagnostics-VNetGW-EH'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-eh-VNetGW.json'))
  }
  {
    name: 'Deploy-Diagnostics-WebServerFarm-EH'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-eh-WebServerFarm.json'))
  }
  {
    name: 'Deploy-Diagnostics-Website-EH'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-eh-Website.json'))
  }
  {
    name: 'Deploy-Diagnostics-WVDAppGroup-EH'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-eh-WVDAppGroup.json'))
  }
  {
    name: 'Deploy-Diagnostics-WVDHostPools-EH'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-eh-WVDHostPools.json'))
  }
  {
    name: 'Deploy-Diagnostics-WVDWorkspace-EH'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-eh-WVDWorkspace.json'))
  }
  {
    name: 'Deploy-Diag-AA-StgAcct'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-stg-AA.json'))
  }
  {
    name: 'Deploy-Diagnostics-ACI-StgAcct'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-stg-ACI.json'))
  }
  {
    name: 'Deploy-Diagnostics-ACR-StgAcct'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-stg-ACR.json'))
  }
  {
    name: 'Deploy-Diagnostics-AnalysisService-StgAcct'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-stg-AnalysisService.json'))
  }
  {
    name: 'Deploy-Diagnostics-ApiForFHIR-StgAcct'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-stg-ApiForFHIR.json'))
  }
  {
    name: 'Deploy-Diagnostics-APIMgmt-StgAcct'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-stg-APIMgmt.json'))
  }
  {
    name: 'Deploy-Diagnostics-AppGateway-StgAcct'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-stg-ApplicationGateway.json'))
  }
  {
    name: 'Deploy-Diagnostics-Bastion-StgAcct'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-stg-Bastion.json'))
  }
  {
    name: 'Deploy-Diagnostics-Batch-StgAcct'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-stg-Batch.json'))
  }
  {
    name: 'Deploy-Diagnostics-CDNEndpoints-StgAcct'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-stg-CDNEndpoints.json'))
  }
  {
    name: 'Deploy-Diagnostics-CognitiveServices-StgAcct'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-stg-CognitiveServices.json'))
  }
  {
    name: 'Deploy-Diagnostics-CosmosDB-StgAcct'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-stg-CosmosDB.json'))
  }
  {
    name: 'Deploy-Diagnostics-Databricks-StgAcct'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-stg-Databricks.json'))
  }
  {
    name: 'Deploy-Diagnostics-DataExplorerCluster-StgAcct'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-stg-DataExplorerCluster.json'))
  }
  {
    name: 'Deploy-Diagnostics-DataFactory-StgAcct'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-stg-DataFactory.json'))
  }
  {
    name: 'Deploy-Diagnostics-DLAnalytics-StgAcct'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-stg-DLAnalytics.json'))
  }
  {
    name: 'Deploy-Diagnostics-EventGridSub-StgAcct'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-stg-EventGridSub.json'))
  }
  {
    name: 'Deploy-Diag-EventGridSystemTopic-StgAcct'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-stg-EventGridSystemTopic.json'))
  }
  {
    name: 'Deploy-Diag-EventGridTopic-StgAcct'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-stg-EventGridTopic.json'))
  }
  {
    name: 'Deploy-Diagnostics-EventHub-StgAcct'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-stg-EventHub.json'))
  }
  {
    name: 'Deploy-Diag-ExpressRoute-StgAcct'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-stg-ExpressRoute.json'))
  }
  {
    name: 'Deploy-Diagnostics-Firewall-StgAcct'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-stg-Firewall.json'))
  }
  {
    name: 'Deploy-Diagnostics-FrontDoor-StgAcct'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-stg-FrontDoor.json'))
  }
  {
    name: 'Deploy-Diagnostics-Function-StgAcct'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-stg-Function.json'))
  }
  {
    name: 'Deploy-Diagnostics-HDInsight-StgAcct'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-stg-HDInsight.json'))
  }
  {
    name: 'Deploy-Diagnostics-iotHub-StgAcct'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-stg-iotHub.json'))
  }
  {
    name: 'Deploy-Diagnostics-KeyVault-StgAcct'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-stg-KeyVault.json'))
  }
  {
    name: 'Deploy-Diagnostics-Kubernetes-StgAcct'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-stg-Kubernetes.json'))
  }
  {
    name: 'Deploy-Diagnostics-LoadBalancer-StgAcct'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-stg-LoadBalancer.json'))
  }
  {
    name: 'Deploy-Diagnostics-LogicApps-StgAcct'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-stg-LogicApps.json'))
  }
  {
    name: 'Deploy-Diagnostics-LogicAppsISE-StgAcct'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-stg-LogicAppsISE.json'))
  }
  {
    name: 'Deploy-Diagnostics-MariaDB-StgAcct'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-stg-MariaDB.json'))
  }
  {
    name: 'Deploy-Diagnostics-MediaService-StgAcct'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-stg-MediaService.json'))
  }
  {
    name: 'Deploy-Diagnostics-MlWorkspace-StgAcct'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-stg-MlWorkspace.json'))
  }
  {
    name: 'Deploy-Diagnostics-MySQL-StgAcct'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-stg-MySQL.json'))
  }
  {
    name: 'Deploy-Diag-NSGs-StgAcct'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-stg-NetworkSecurityGroups.json'))
  }
  {
    name: 'Deploy-Diagnostics-NIC-StgAcct'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-stg-NIC.json'))
  }
  {
    name: 'Deploy-Diagnostics-PostgreSQL-StgAcct'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-stg-PostgreSQL.json'))
  }
  {
    name: 'Deploy-Diag-PowerBIEmbedded-StgAcct'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-stg-PowerBIEmbedded.json'))
  }
  {
    name: 'Deploy-Diagnostics-PublicIP-StgAcct'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-stg-PublicIP.json'))
  }
  {
    name: 'Deploy-Diagnostics-RedisCache-StgAcct'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-stg-RedisCache.json'))
  }
  {
    name: 'Deploy-Diagnostics-Relay-StgAcct'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-stg-Relay.json'))
  }
  {
    name: 'Deploy-Diagnostics-SearchService-StgAcct'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-stg-SearchService.json'))
  }
  {
    name: 'Deploy-Diagnostics-ServiceBus-StgAcct'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-stg-ServiceBus.json'))
  }
  {
    name: 'Deploy-Diagnostics-SignalR-StgAcct'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-stg-SignalR.json'))
  }
  {
    name: 'Deploy-Diagnostics-SQLDatabase-StgAcct'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-stg-SQLDatabase.json'))
  }
  {
    name: 'Deploy-Diagnostics-SQLElasticPools-StgAcct'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-stg-SQLElasticPools.json'))
  }
  {
    name: 'Deploy-Diagnostics-SQLMI-StgAcct'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-stg-SQLMI.json'))
  }
  {
    name: 'Deploy-Diagnostics-StorageAccount-StgAcct'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-stg-StorageAccount.json'))
  }
  {
    name: 'Deploy-Diagnostics-StreamAnalytics-StgAcct'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-stg-StreamAnalytics.json'))
  }
  {
    name: 'Deploy-Diagnostics-TimeSeriesInsights-StgAcct'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-stg-TimeSeriesInsights.json'))
  }
  {
    name: 'Deploy-Diagnostics-TrafficManager-StgAcct'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-stg-TrafficManager.json'))
  }
  {
    name: 'Deploy-Diagnostics-VirtualNetwork-StgAcct'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-stg-VirtualNetwork.json'))
  }
  {
    name: 'Deploy-Diagnostics-VM-StgAcct'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-stg-VM.json'))
  }
  {
    name: 'Deploy-Diagnostics-VMSS-StgAcct'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-stg-VMSS.json'))
  }
  {
    name: 'Deploy-Diagnostics-VNetGW-StgAcct'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-stg-VNetGW.json'))
  }
  {
    name: 'Deploy-Diagnostics-WebServerFarm-StgAcct'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-stg-WebServerFarm.json'))
  }
  {
    name: 'Deploy-Diagnostics-Website-StgAcct'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-stg-Website.json'))
  }
  {
    name: 'Deploy-Diagnostics-WVDAppGroup-StgAcct'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-stg-WVDAppGroup.json'))
  }
  {
    name: 'Deploy-Diagnostics-WVDHostPools-StgAcct'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-stg-WVDHostPools.json'))
  }
  {
    name: 'Deploy-Diagnostics-WVDWorkspace-StgAcct'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-stg-WVDWorkspace.json'))
  }  
]

// 1 - Create Custom Policy Defintions
module policyDefinitions '../modules/authorization/policyDefinitions/managementGroup/deploy.bicep' = [for policy in customPolicyDefinitions: {
  name: policy.name
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

