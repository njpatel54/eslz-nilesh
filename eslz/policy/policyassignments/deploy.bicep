targetScope = 'managementGroup'

@sys.description('Required. Array containing one or more policy assignments.')
param policyAssignments array = []

/*
@sys.description('Required. Specifies the name of the policy assignment. Maximum length is 24 characters for management group scope, 64 characters for subscription and resource group scopes.')
param name string

@sys.description('Required. Specifies the ID of the policy definition or policy set definition being assigned.')
param policyDefinitionId string

@sys.description('Optional. This message will be part of response in case of policy violation.')
param description string = ''

@sys.description('Optional. The display name of the policy assignment. Maximum length is 128 characters.')
@maxLength(128)
param displayName string = ''

@sys.description('Optional. Parameters for the policy assignment if needed.')
param parameters object = {}

@sys.description('Optional. The managed identity associated with the policy assignment. Policy assignments must include a resource identity when assigning \'Modify\' policy definitions.')
@allowed([
  'SystemAssigned'
  'None'
])
param identity string = 'SystemAssigned'

@sys.description('Required. The IDs Of the Azure Role Definition list that is used to assign permissions to the identity. You need to provide either the fully qualified ID in the following format: \'/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11\'.. See https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles for the list IDs for built-in Roles. They must match on what is on the policy definition')
param roleDefinitionIds array = []

@sys.description('Optional. The policy assignment metadata. Metadata is an open ended object and is typically a collection of key-value pairs.')
param metadata object = {}

@sys.description('Optional. The messages that describe why a resource is non-compliant with the policy.')
param nonComplianceMessage string = ''

@sys.description('Optional. The policy assignment enforcement mode. Possible values are Default and DoNotEnforce. - Default or DoNotEnforce')
@allowed([
  'Default'
  'DoNotEnforce'
])
param enforcementMode string = 'Default'

@sys.description('Optional. The policy excluded scopes')
param notScopes array = []

@sys.description('Optional. The Target Scope for the Policy. The name of the management group for the policy assignment. If not provided, will use the current scope for deployment.')
param managementGroupId string = managementGroup().name


@sys.description('Optional. Location for all resources.')
param location string = deployment().location
*/


@sys.description('Optional. The Target Scope for the Policy. The subscription ID of the subscription for the policy assignment')
param subscriptionId string = ''

@sys.description('Optional. The Target Scope for the Policy. The name of the resource group for the policy assignment')
param resourceGroupName string = ''


module policyAssignment_mg 'managementGroup/deploy.bicep' = [for (policyAssignment, i) in policyAssignments: if (empty(subscriptionId) && empty(resourceGroupName)) {
  name: '${policyAssignment.name}-PolicyAssignment-MG-Module'
  scope: managementGroup(policyAssignment.managementGroupId)
  params: {
    name: policyAssignment.name
    policyDefinitionId: policyAssignment.policyDefinitionId
    displayName: !empty(policyAssignment.displayName) ? policyAssignment.displayName : ''
    description: !empty(policyAssignment.description) ? policyAssignment.description : ''
    parameters: !empty(policyAssignment.parameters) ? policyAssignment.parameters : {}
    identity: policyAssignment.identity.type
    roleDefinitionIds: !empty(policyAssignment.roleDefinitionIds) ? policyAssignment.roleDefinitionIds : []
    metadata: !empty(policyAssignment.metadata) ? policyAssignment.metadata : {}
    nonComplianceMessage: !empty(policyAssignment.nonComplianceMessage) ? policyAssignment.nonComplianceMessage : ''
    enforcementMode: policyAssignment.enforcementMode
    notScopes: !empty(policyAssignment.notScopes) ? policyAssignment.notScopes : []
    managementGroupId: policyAssignment.managementGroupId
    location: policyAssignment.location
  }
}]

/*
module policyAssignment_sub 'subscription/deploy.bicep' = if (!empty(subscriptionId) && empty(resourceGroupName)) {
  name: '${uniqueString(deployment().name, location)}-PolicyAssignment-Sub-Module'
  scope: subscription(subscriptionId)
  params: {
    name: name
    policyDefinitionId: policyDefinitionId
    displayName: !empty(displayName) ? displayName : ''
    description: !empty(description) ? description : ''
    parameters: !empty(parameters) ? parameters : {}
    identity: identity
    roleDefinitionIds: !empty(roleDefinitionIds) ? roleDefinitionIds : []
    metadata: !empty(metadata) ? metadata : {}
    nonComplianceMessage: !empty(nonComplianceMessage) ? nonComplianceMessage : ''
    enforcementMode: enforcementMode
    notScopes: !empty(notScopes) ? notScopes : []
    subscriptionId: subscriptionId
    location: location
  }
}

module policyAssignment_rg 'resourceGroup/deploy.bicep' = if (!empty(resourceGroupName) && !empty(subscriptionId)) {
  name: '${uniqueString(deployment().name, location)}-PolicyAssignment-RG-Module'
  scope: resourceGroup(subscriptionId, resourceGroupName)
  params: {
    name: name
    policyDefinitionId: policyDefinitionId
    displayName: !empty(displayName) ? displayName : ''
    description: !empty(description) ? description : ''
    parameters: !empty(parameters) ? parameters : {}
    identity: identity
    roleDefinitionIds: !empty(roleDefinitionIds) ? roleDefinitionIds : []
    metadata: !empty(metadata) ? metadata : {}
    nonComplianceMessage: !empty(nonComplianceMessage) ? nonComplianceMessage : ''
    enforcementMode: enforcementMode
    notScopes: !empty(notScopes) ? notScopes : []
    subscriptionId: subscriptionId
    location: location
  }
}


@sys.description('Policy Assignment Name')
output name string = empty(subscriptionId) && empty(resourceGroupName) ? policyAssignment_mg.outputs.name : (!empty(subscriptionId) && empty(resourceGroupName) ? policyAssignment_sub.outputs.name : policyAssignment_rg.outputs.name)

@sys.description('Policy Assignment principal ID')
output principalId string = empty(subscriptionId) && empty(resourceGroupName) ? policyAssignment_mg.outputs.principalId : (!empty(subscriptionId) && empty(resourceGroupName) ? policyAssignment_sub.outputs.principalId : policyAssignment_rg.outputs.principalId)

@sys.description('Policy Assignment resource ID')
output resourceId string = empty(subscriptionId) && empty(resourceGroupName) ? policyAssignment_mg.outputs.resourceId : (!empty(subscriptionId) && empty(resourceGroupName) ? policyAssignment_sub.outputs.resourceId : policyAssignment_rg.outputs.resourceId)
*/
