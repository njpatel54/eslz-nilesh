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
    name: 'Deploy-Diagnostics-LoadBalancer-StgAcct'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-stg-LoadBalancer.json'))
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
    name: 'Deploy-Diagnostics-RedisCache-StgAcct'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-stg-RedisCache.json'))
  }
  {
    name: 'Deploy-Diagnostics-Relay-StgAcct'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-stg-Relay.json'))
  }
  {
    name: 'Deploy-Diagnostics-SignalR-StgAcct'
    definition: json(loadTextContent('./policyDefinitions/policy-def-Deploy-Diagnostics-stg-SignalR.json'))
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

