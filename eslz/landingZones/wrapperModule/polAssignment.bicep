targetScope = 'managementGroup'

@description('subscriptionId for the deployment')
param subscriptionId string

@description('Required. Parameter for "Deploy-VM-Backup" policy assignment')
param deployVMBackup object

// 1 - Create Policy Assignment (Deploy-VM-Backup) at Subscription Scope
module policyAssignment_sub '../../modules/authorization/policyAssignments/subscription/deploy.bicep' = {
  name: 'policyAssignment_sub-${deployVMBackup.name}'
  scope: subscription(subscriptionId)
  params: {
    name: deployVMBackup.name
    location: deployVMBackup.location
    policyDefinitionId: deployVMBackup.policyDefinitionId
    displayName: !empty(deployVMBackup.displayName) ? deployVMBackup.displayName : ''
    description: !empty(deployVMBackup.description) ? deployVMBackup.description : ''
    parameters: !empty(deployVMBackup.parameters) ? deployVMBackup.parameters : {}
    identity: deployVMBackup.identity
    roleDefinitionIds: !empty(deployVMBackup.roleDefinitionIds) ? deployVMBackup.roleDefinitionIds : []
    metadata: !empty(deployVMBackup.metadata) ? deployVMBackup.metadata : {}
    nonComplianceMessage: !empty(deployVMBackup.nonComplianceMessage) ? deployVMBackup.nonComplianceMessage : ''
    enforcementMode: deployVMBackup.enforcementMode
    notScopes: !empty(deployVMBackup.notScopes) ? deployVMBackup.notScopes : []
    subscriptionId: subscriptionId
  }
}

// 2. Create Policy Remediation (Deploy-VM-Backup Policy Assignment) for Exisitng Resources
module remediation_sub '../../modules/policyInsights/remediations/subscription/deploy.bicep' = {
  name: 'remediation_sub-${deployVMBackup.name}'
  scope: subscription(subscriptionId)
  dependsOn: [
    policyAssignment_sub
  ]
  params: {
    name: '${deployVMBackup.name}-remediation'
    policyAssignmentId: subscriptionResourceId(subscriptionId, 'Microsoft.Authorization/policyAssignments', deployVMBackup.name)
    filterLocations: [
      'usgovvirginia'
    ]
  }
}
