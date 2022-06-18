targetScope = 'tenant'

@description('Required. The group ID of the Management group.')
param name string

@description('Optional. The friendly name of the management group. If no value is passed then this field will be set to the group ID.')
param displayName string = ''

@description('Optional. The management group parent ID. Defaults to current scope.')
param parentMGName string = ''

@description('Optional. Array of role assignment objects to define RBAC on this resource.')
param roleAssignments array = []

// Create Management Groups
resource managementGroup 'Microsoft.Management/managementGroups@2021-04-01' = {
    name: name
    properties:{
        displayName: displayName
        details:!empty(parentMGName) ? {
            parent:{
                id: '/providers/Microsoft.Management/managementGroups/${parentMGName}'
            }
        } : null
    }    
}

module managementGroup_rbac '.bicep/nested_rbac.bicep' = [ for (roleAssignment, index) in roleAssignments :{
  name: 'ManagementGroup-Rbac-${name}-${index}'
  params: {
    description: contains(roleAssignment, 'description') ? roleAssignment.description : ''
    principalIds: roleAssignment.principalIds
    principalType: contains(roleAssignment, 'principalType') ? roleAssignment.principalType : ''
    roleDefinitionIdOrName: roleAssignment.roleDefinitionIdOrName
    resourceId: managementGroup.id
  }
  scope: managementGroup
}]

@description('The name of the management group')
output name string = managementGroup.name

@description('The resource ID of the management group')
output resourceId string = managementGroup.id
