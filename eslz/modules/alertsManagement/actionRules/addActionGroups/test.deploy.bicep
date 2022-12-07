@description('An alert processing rule lets you associate alerts to action groups. Edit this field if you wish to use a custom name for the alert processing rule, otherwise, you can leave this unchanged. An alert processing rule name can have a length of 1-260 characters. You cannot use <,>,*,%,&,:,\\,?,+,/,#,@,{,}.')
param alertProcessingRuleName string

@description('Description of the alert processing rule.')
param alertProcessingRuleDescription string

@description('Required. The condition that will cause this alert to activate. Array of objects.')
param conditions array

@description('subscriptionId for the deployment')
param subscriptionId string

@description('Required. Name of the resourceGroup, where application workload will be deployed.')
param wlRgName string

/*
param actionGroups array

var actions = [for actionGroup in actionGroups: {
  actionType: 'AddActionGroups'
  actionGroupIds: [
    actionGroup.actionGroupId
  ]
}]

@description('Optional. The list of actions to take when alert triggers.')
param actions array = []

var actionGroups = [for action in actions: {
  actionType: 'AddActionGroups'
  actionGroupIds: [
    action.actionGroupId
  ]
}]
*/
@description('The scope of resources for which the alert processing rule will apply. You can leave this field unchanged if you wish to apply the rule for all Recovery Services vault within the subscription. If you wish to apply the rule on smaller scopes, you can specify an array of ARM URLs representing the scopes, eg. [\'/subscriptions/<sub-id>/resourceGroups/RG1\', \'/subscriptions/<sub-id>/resourceGroups/RG2\']')
param alertProcessingRuleScope array = [
  subscription().id
]

resource alertProcessingRule 'Microsoft.AlertsManagement/actionRules@2021-08-08' = {
  name: alertProcessingRuleName
  location: 'Global'
  properties: {
    scopes: alertProcessingRuleScope
    conditions: conditions
    description: alertProcessingRuleDescription
    enabled: true
    actions: [
      {
        actionType: 'AddActionGroups'
        actionGroupIds: [
          //resourceId(subscriptionId, wlRgName, 'Microsoft.insights/actiongroups', 'ag-lz50-usva-001')
          //resourceId(subscriptionId, wlRgName, 'Microsoft.insights/actiongroups', 'test-ag')
          '/subscriptions/df3b1809-17d0-47a0-9241-d2724780bdac/resourceGroups/rg-lz50-usva-wl01/providers/microsoft.insights/actiongroups/ag-lz50-usva-001'
          '/subscriptions/df3b1809-17d0-47a0-9241-d2724780bdac/resourceGroups/rg-lz50-usva-wl01/providers/microsoft.insights/actiongroups/test-ag'
        ]
      }
    ]
  }
}

output alertProcessingRuleId string = alertProcessingRule.id

/*
@description('Optional. The list of actions to take when alert triggers.')
param actions array = []

@description('Action Group Names. ')
param actionGroupNames array

param actionGroupRgName string

param subscriptionId string

var actionGroups = [for actionGroupId in actionGroupIds: {
  actionType: 'AddActionGroups'
  actionGroupIds: [
    actionGroupId
  ]
}]

var actions = [for actionGroupName in actionGroupNames: {
  actionType: 'AddActionGroups'
  actionGroupIds: [
    resourceId(subscriptionId, wlRgName, 'Microsoft.insights/actiongroups', actionGroupName)
  ]
}]

var actions = [for actionGroupName in actionGroupNames: {
  actionType: 'AddActionGroups'
  actionGroupIds: [
    resourceId(subscriptionId, actionGroupRgName, 'Microsoft.insights/actiongroups', actionGroupName)
  ]
}]


****** Working*******
var actions = [for actionGroup in actionGroups: {
  actionType: 'AddActionGroups'
  actionGroupIds: [
    actionGroup.actionGroupId
  ]
}]

param actionType string

var test = json(replace(replace(replace(string(actionGroups), '[{', '{'), '}]', '}'), '}},{', '},'))
var test2 = replace(replace(replace(string(actionGroups), '{"actionGroupId":"', '\''), '"}', '\''), '"},', '')

[{"actionGroupId":"/subscriptions/df3b1809-17d0-47a0-9241-d2724780bdac/resourceGroups/rg-lz50-usva-wl01/providers/Microsoft.insights/actiongroups/ag-lz50-usva-001"}]

// var actionGroupIds = json(replace(replace(replace(string(actionGroups), '[{"actionGroupId":"', '"'), '"},', '",'), '"}]', '"')) ---> Working only for 1 Action Group
var actionGroupIds = replace(replace(replace(string(actionGroups), '{"actionGroupId":', ''), '"}', '"'), '"},', '')


var actions = [
  {
  actionType: 'AddActionGroups'
  actionGroupIds: [
    actionGroupIds
  ]
}
]

output testObject object = test
output test2object string = test2
output actionGroupIds string = actionGroupIds

*/


param test array = [
  {
    actionGroupId: '/subscriptions/df3b1809-17d0-47a0-9241-d2724780bdac/resourceGroups/rg-lz50-usva-wl01/providers/Microsoft.insights/actiongroups/ag-lz50-usva-00'
  }
  {
    actionGroupId: '/subscriptions/df3b1809-17d0-47a0-9241-d2724780bdac/resourceGroups/rg-lz50-usva-wl01/providers/Microsoft.insights/actiongroups/test-ag'
  }
]
