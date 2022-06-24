targetScope = 'tenant'

@description('Required. The group ID of the Management group.')
param name string

@description('Optional. The friendly name of the management group. If no value is passed then this field will be set to the group ID.')
param displayName string = ''

@description('Optional. The management group parent ID. Defaults to current scope.')
param parentId string = ''

@sys.description('Optional. Location deployment metadata.')
param location string = deployment().location

resource managementGroup 'Microsoft.Management/managementGroups@2021-04-01' = {
  name: name
  scope: tenant()
  properties: {
    displayName: displayName
    details: !empty(parentId) ? {
      parent: {
        id: '/providers/Microsoft.Management/managementGroups/${parentId}'
      }
    } : null
  }
}

@description('The name of the management group.')
output name string = managementGroup.name

@description('The resource ID of the management group.')
output resourceId string = managementGroup.id

output location string = location
