@description('Required. Array of Action Groups')
param actionGroups array

@description('Optional. Tags of the resource.')
param tags object = {}

// 1. Create Action Group(s)
module actionGroup '../../modules/insights/actionGroups/deploy.bicep' = [for (actionGroup, i) in actionGroups: {
  name: 'actionGroup-${actionGroup.name}'
  params: {
    name: actionGroup.name
    groupShortName: actionGroup.groupShortName
    location: 'global'
    tags: tags
    emailReceivers: actionGroup.emailReceivers
    smsReceivers: actionGroup.smsReceivers
  }
}]

@description('Output - Action Groups Array')
output actionGroups array = [for (actionGroup, i) in actionGroups: {
  resourceId: actionGroup[i].outputs.resourceId
}]
