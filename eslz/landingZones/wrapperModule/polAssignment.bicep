targetScope = 'managementGroup'

@description('subscriptionId for the deployment')
param subscriptionId string

@description('Required. Parameter for policyAssignments')
param policyAssignments array

// 1 - Create Policy Assignment at Subscription Scope
module policyAssignment_sub '../../modules/authorization/policyAssignments/subscription/deploy.bicep' = [for (policyAssignment, i) in policyAssignments: {
  name: 'policyAssignment_sub-${policyAssignment.name}'
  scope: subscription(subscriptionId)
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
    subscriptionId: subscriptionId
  }
}]

// 2. Create Policy Remediation for Exisitng Resources
module remediation_sub '../../modules/policyInsights/remediations/subscription/deploy.bicep' = [for (policyAssignment, i) in policyAssignments: {
  name: 'remediation_sub-${policyAssignment.name}'
  scope: subscription(subscriptionId)
  dependsOn: [
    policyAssignment_sub
  ]
  params: {
    name: '${policyAssignment.name}-remediation'
    policyAssignmentId: subscriptionResourceId(subscriptionId, 'Microsoft.Authorization/policyAssignments', policyAssignment.name)
    filterLocations: [
      'usgovvirginia'
    ]
  }
}]
