targetScope = 'managementGroup'

@sys.description('Optional. The Target Scope for the Policy. The name of the management group for the policy assignment. If not provided, will use the current scope for deployment.')
param managementGroupId string

@sys.description('Required. The ID Of the Azure Role Definition that is used to assign permissions to the identity. You need to provide either the fully qualified ID in the following format: \'/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11\'.. See https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles for the list IDs for built-in Roles. They must match on what is on the policy definition')
param roleDefinitionId string

@sys.description('Optional. principalId of the managed identity of the assignment.')
param principalId string


resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  name: guid(managementGroupId, roleDefinitionId, principalId)   //guid(managementGroupId, roleDefinitionId, location, name)
  properties: {
    roleDefinitionId: roleDefinitionId
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}

@sys.description('Role Assignment Name')
output name string = roleAssignment.name

@sys.description('Role Assignment principal ID')
output principalId string = principalId

@sys.description('Role Assignment resource ID')
output resourceId string = extensionResourceId(tenantResourceId('Microsoft.Management/managementGroups', managementGroupId), 'Microsoft.Authorization/roleAssignments', roleAssignment.name)
