targetScope = 'managementGroup'

@sys.description('Required. Location for all resources.')
param location string

@description('Required. Array of Custom RBAC Role Definitions.')
param mgRbacRoleDefinitions array = []

// 1 - Create Custom RBAC Role Definition(s) at Management Group Scope
module mgCustomRbac '../modules/authorization/roleDefinitions/managementGroup/deploy.bicep' = [ for (mgRbacRoleDefinition, index) in mgRbacRoleDefinitions: {
  name: 'mgCustomRbac-${mgRbacRoleDefinition.managementGroupId}-${index}'
  scope: managementGroup(mgRbacRoleDefinition.managementGroupId)
  params: {
    roleName: mgRbacRoleDefinition.roleName
    description: mgRbacRoleDefinition.description
    location: location
    actions: mgRbacRoleDefinition.actions
    notActions: mgRbacRoleDefinition.notActions
    assignableScopes: mgRbacRoleDefinition.assignableScopes
    managementGroupId: mgRbacRoleDefinition.managementGroupId
  }
}]
