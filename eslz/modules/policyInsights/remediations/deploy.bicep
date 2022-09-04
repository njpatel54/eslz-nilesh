targetScope = 'managementGroup'

@description('Optional. Name of the Resource Group to assign the RBAC role to. If Resource Group name is provided, and Subscription ID is provided, the module deploys at resource group level, therefore assigns the provided RBAC role to the resource group.')
param resourceGroupName string = ''

@description('Optional. Subscription ID of the subscription to assign the RBAC role to. If no Resource Group name is provided, the module deploys at subscription level, therefore assigns the provided RBAC role to the subscription.')
param subscriptionId string = ''

@description('Optional. Group ID of the Management Group to assign the RBAC role to. If not provided, will use the current scope for deployment.')
param managementGroupId string = managementGroup().name

@sys.description('Optional. Location deployment metadata.')
param location string = deployment().location

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


module remediation_mg 'managementGroup/deploy.bicep'= if (empty(subscriptionId) && empty(resourceGroupName)) {
  name: 'remediation_mg-${uniqueString(deployment().name, location)}'
  scope: managementGroup(managementGroupId)
  params: {
    name: name
    failureThresholdPercentage: failureThresholdPercentage
    filterLocations: filterLocations
    parallelDeployments: parallelDeployments
    policyAssignmentId: policyAssignmentId
    policyDefinitionReferenceId: policyDefinitionReferenceId
    resourceCount: resourceCount
    resourceDiscoveryMode: resourceDiscoveryMode
  }
}

module remediation_sub 'subscription/deploy.bicep' = if (!empty(subscriptionId) && empty(resourceGroupName)) {
  name: 'remediation_sub-${uniqueString(deployment().name, location)}'
  scope: subscription(subscriptionId)
  params: {
    name: name
    failureThresholdPercentage: failureThresholdPercentage
    filterLocations: filterLocations
    parallelDeployments: parallelDeployments
    policyAssignmentId: policyAssignmentId
    policyDefinitionReferenceId: policyDefinitionReferenceId
    resourceCount: resourceCount
    resourceDiscoveryMode: resourceDiscoveryMode
  }
}

module remediation_rg 'resourceGroup/deploy.bicep' = if (!empty(resourceGroupName) && !empty(subscriptionId)) {
  name: 'remediation_rg-${uniqueString(deployment().name, location)}'
  scope: resourceGroup(subscriptionId, resourceGroupName)
  params: {
    name: name
    failureThresholdPercentage: failureThresholdPercentage
    filterLocations: filterLocations
    parallelDeployments: parallelDeployments
    policyAssignmentId: policyAssignmentId
    policyDefinitionReferenceId: policyDefinitionReferenceId
    resourceCount: resourceCount
    resourceDiscoveryMode: resourceDiscoveryMode
  }
}
