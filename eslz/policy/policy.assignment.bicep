targetScope = 'managementGroup'

@description('Required. Array containing all Policy Assignments at Management Group Scope.')
param mgPolicyAssignments array = []

@description('Required. Array containing all Policy Assignments at Subscription Scope.')
param subPolicyAssignments array = []

@description('Required. Array containing all Policy Assignments at Resource Group Scope.')
param rgPolicyAssignments array = []

// 1 - Create Policy Assignment at Management Group Scope
module policyAssignment_mg '../modules/authorization/policyAssignments/managementGroup/deploy.bicep' = [ for (policyAssignment, i) in mgPolicyAssignments :  {
  name: '${policyAssignment.name}-policyAssignment-${i}'
  scope: managementGroup(policyAssignment.managementGroupId)
  params: {
    name: policyAssignment.name
    location: policyAssignment.location
    policyDefinitionId: policyAssignment.policyDefinitionId
    displayName: !empty(policyAssignment.displayName) ? policyAssignment.displayName : ''
    description: !empty(policyAssignment.description) ? policyAssignment.description : ''
    parameters: !empty(policyAssignment.parameters) ? policyAssignment.parameters : {}
    identity: policyAssignment.identity
    roleDefinitionIds: !empty(policyAssignment.roleDefinitionIds) ? policyAssignment.roleDefinitionIds : []
    metadata: !empty(policyAssignment.metadata) ? policyAssignment.metadata : {}
    nonComplianceMessage: !empty(policyAssignment.nonComplianceMessage) ? policyAssignment.nonComplianceMessage : ''
    enforcementMode: policyAssignment.enforcementMode
    notScopes: !empty(policyAssignment.notScopes) ? policyAssignment.notScopes : []
    managementGroupId: policyAssignment.managementGroupId    
  }
}]

// 2 - Create Policy Assignment at Subscription Scope
module policyAssignment_sub '../modules/authorization/policyAssignments/subscription/deploy.bicep' = [ for (policyAssignment, i) in subPolicyAssignments :  {
  name: '${policyAssignment.name}-policyAssignment-${i}'
  scope: subscription(policyAssignment.subscriptionId)
  params: {
    name: policyAssignment.name
    location: policyAssignment.location
    policyDefinitionId: policyAssignment.policyDefinitionId
    displayName: !empty(policyAssignment.displayName) ? policyAssignment.displayName : ''
    description: !empty(policyAssignment.description) ? policyAssignment.description : ''
    parameters: !empty(policyAssignment.parameters) ? policyAssignment.parameters : {}
    identity: policyAssignment.identity
    roleDefinitionIds: !empty(policyAssignment.roleDefinitionIds) ? policyAssignment.roleDefinitionIds : []
    metadata: !empty(policyAssignment.metadata) ? policyAssignment.metadata : {}
    nonComplianceMessage: !empty(policyAssignment.nonComplianceMessage) ? policyAssignment.nonComplianceMessage : ''
    enforcementMode: policyAssignment.enforcementMode
    notScopes: !empty(policyAssignment.notScopes) ? policyAssignment.notScopes : []
    subscriptionId: policyAssignment.subscriptionId
  }
}]

// 3 - Create Policy Assignment at Resource Group Scope
module policyAssignment_rg '../modules/authorization/policyAssignments/resourceGroup/deploy.bicep' = [ for (policyAssignment, i) in rgPolicyAssignments :  {
  name: '${policyAssignment.name}-policyAssignment-${i}'
  scope: resourceGroup(policyAssignment.subscriptionId, policyAssignment.resourceGroupName)
  params: {
    name: policyAssignment.name
    location: policyAssignment.location
    policyDefinitionId: policyAssignment.policyDefinitionId
    displayName: !empty(policyAssignment.displayName) ? policyAssignment.displayName : ''
    description: !empty(policyAssignment.description) ? policyAssignment.description : ''
    parameters: !empty(policyAssignment.parameters) ? policyAssignment.parameters : {}
    identity: policyAssignment.identity
    roleDefinitionIds: !empty(policyAssignment.roleDefinitionIds) ? policyAssignment.roleDefinitionIds : []
    metadata: !empty(policyAssignment.metadata) ? policyAssignment.metadata : {}
    nonComplianceMessage: !empty(policyAssignment.nonComplianceMessage) ? policyAssignment.nonComplianceMessage : ''
    enforcementMode: policyAssignment.enforcementMode
    notScopes: !empty(policyAssignment.notScopes) ? policyAssignment.notScopes : []
    subscriptionId: policyAssignment.subscriptionId
    resourceGroupName: policyAssignment.resourceGroupName
  }
}]
