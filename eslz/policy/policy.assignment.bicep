targetScope = 'managementGroup'

param policyAssignments array = []

//Create Policy Assignment at MG Scope
module policyAssignment_mg '../modules/authorization/policyAssignments/managementGroup/deploy.bicep' = [ for (policyAssignment, i) in policyAssignments :  {
  name: '${policyAssignment.name}-policyAssignment-${i}'
  scope: managementGroup(policyAssignment.managementGroupId)
  params: {
    name: policyAssignment.name
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
    location: policyAssignment.location
  }
}]
