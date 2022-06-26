// Create Custom Policy-Set Defintions
targetScope = 'managementGroup'

param location string

@description('The management group scope to which the policy definitions are to be created at.')
param targetMgId string

@description('The management group resoruceId.')
var targetMgResourceId = tenantResourceId('Microsoft.Management/managementGroups', targetMgId)

//param policyDefinitions array
param policySetDefinitions array
/*
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
*/

module policySetDefs '../modules/authorization/policySetDefinitions/managementGroup/deploy.bicep' = [for policySet in policySetDefinitions: {
  name: '${policySet.properties.name}'
  //dependsOn: [
  //  policyDefs
  //]
  params: {
    name: policySet.properties.name
    location: location
    description: policySet.properties.description
    displayName: policySet.properties.displayName
    metadata: policySet.properties.metadata
    parameters: policySet.properties.parameters
    policyDefinitions: [for policyDefinition in policySet.properties.policyDefinitions: {
      policyDefinitionReferenceId: policyDefinition.policyDefinitionReferenceId
      policyDefinitionId: policyDefinition.policyDefinitionId
      parameters: policyDefinition.parameters
    }]
    policyDefinitionGroups: policySet.properties.policyDefinitionGroups
    
  }
}]


output targetMgResourceId string = targetMgResourceId
