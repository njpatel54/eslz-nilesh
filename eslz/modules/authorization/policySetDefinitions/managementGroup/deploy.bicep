targetScope = 'managementGroup'

@sys.description('Required. Specifies the name of the policy Set Definition (Initiative).')
@maxLength(64)
param name string

@sys.description('Optional. The display name of the Set Definition (Initiative). Maximum length is 128 characters.')
@maxLength(128)
param displayName string = ''

@sys.description('Optional. The description name of the Set Definition (Initiative).')
param description string = ''

@sys.description('Optional. The group ID of the Management Group. If not provided, will use the current scope for deployment.')
param managementGroupId string = managementGroup().name

@sys.description('Optional. The Set Definition (Initiative) metadata. Metadata is an open ended object and is typically a collection of key-value pairs.')
param metadata object = {}

@sys.description('Required. The array of Policy definitions object to include for this policy set. Each object must include the Policy definition ID, and optionally other properties like parameters.')
param policyDefinitions array

@sys.description('Optional. The metadata describing groups of policy definition references within the Policy Set Definition (Initiative).')
param policyDefinitionGroups array = []

@sys.description('Optional. The Set Definition (Initiative) parameters that can be used in policy definition references.')
param parameters object = {}

@sys.description('Optional. Location deployment metadata.')
param location string = deployment().location


resource policySetDefinition 'Microsoft.Authorization/policySetDefinitions@2021-06-01' = {
  name: name
  properties: {
    policyType: 'Custom'
    displayName: !empty(displayName) ? displayName : null
    description: !empty(description) ? description : null
    metadata: !empty(metadata) ? metadata : null
    parameters: !empty(parameters) ? parameters : null
    policyDefinitions: policyDefinitions
    policyDefinitionGroups: !empty(policyDefinitionGroups) ? policyDefinitionGroups : []
  }
}

@sys.description('Policy Set Definition Name.')
output name string = policySetDefinition.name

@sys.description('Policy Set Definition resource ID.')
output resourceId string = extensionResourceId(tenantResourceId('Microsoft.Management/managementGroups', managementGroupId), 'Microsoft.Authorization/policySetDefinitions', policySetDefinition.name)

output location string = location
