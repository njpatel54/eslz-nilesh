targetScope = 'managementGroup'

@description('Required. Specifies the name of the remediation.')
param name string

@description('A number between 0.0 to 1.0 representing the percentage failure threshold. The remediation will fail if the percentage of failed remediation operations (i.e. failed deployments) exceeds this threshold.')
param failureThresholdPercentage int = 1

@description('The resource locations that will be remediated.')
param filterLocations array

@description('The number of concurrent remediation deployments at any given time. Can be between 1-30. Default value is 10. Higher values will cause the remediation to complete more quickly, but increase the risk of throttling.')
param parallelDeployments int = 10

@description('The resource ID of the policy assignment that should be remediated.')
param policyAssignmentId string

@description('The policy definition reference ID of the individual definition that should be remediated. Required when the policy assignment being remediated assigns a policy set definition.')
param policyDefinitionReferenceId string = ''

@description('The number of non-compliant resources to remediate. Can be between 1-50000. Default value is 500.')
param resourceCount int = 500

@description('The way resources to remediate are discovered. Defaults to ExistingNonCompliant if not specified.')
@allowed([
'ExistingNonCompliant'
'ReEvaluateCompliance'
])
param resourceDiscoveryMode string = 'ReEvaluateCompliance'

resource remediation 'Microsoft.PolicyInsights/remediations@2021-10-01' = {
  name: name
  properties: {
    failureThreshold: {
      percentage: failureThresholdPercentage
    }
    filters: {
      locations: !empty(filterLocations) ? filterLocations : [
        'USGovVirginia'
      ]
    }
    parallelDeployments: parallelDeployments
    policyAssignmentId: policyAssignmentId
    policyDefinitionReferenceId: policyDefinitionReferenceId
    resourceCount: resourceCount
    resourceDiscoveryMode: resourceDiscoveryMode
  }
}
