targetScope = 'managementGroup'

@sys.description('Required. Location for all resources.')
param location string

@sys.description('Required. Name of the custom RBAC role to be created.')
param roleName string

@sys.description('Optional. Description of the custom RBAC role to be created.')
param description string = ''

@sys.description('Optional. List of allowed actions.')
param actions array = []

@sys.description('Optional. List of denied actions.')
param notActions array = []

@sys.description('Optional. The group ID of the Management Group where the Role Definition and Target Scope will be applied to. If not provided, will use the current scope for deployment.')
param managementGroupId string

@sys.description('Optional. Role definition assignable scopes. If not provided, will use the current scope provided.')
param assignableScopes array = []

// 1 - Create Custom RBAC Role Definition(s) at Management Group Scope
module mgCustomRbac '../modules/authorization/roleDefinitions/managementGroup/deploy.bicep' = {
  name: 'mgCustomRbac-${managementGroupId}'
  scope: managementGroup(managementGroupId)
  params: {
    roleName: roleName
    description: description
    location: location
    actions: actions
    notActions: notActions
    assignableScopes: assignableScopes
    managementGroupId: managementGroupId
  }
}
