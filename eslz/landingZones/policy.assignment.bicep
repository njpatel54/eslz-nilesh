targetScope = 'managementGroup'

@description('Required. Location for all resources.')
param location string

@description('subscriptionId for the deployment')
param subscriptionId string = ''

@description('Required. Parameter for policyAssignments')
param policyAssignments array

// 20. Create Policy Assignment and Remediation
module lzPolicyAssignment 'wrapperModule/polAssignment.bicep' = {
  name: 'mod-policyAssignment-${take(uniqueString(deployment().name, location), 4)}'
  params: {
    subscriptionId: subscriptionId
    policyAssignments: policyAssignments
  }
}
