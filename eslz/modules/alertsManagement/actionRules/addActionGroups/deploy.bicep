@description('An alert processing rule lets you associate alerts to action groups. Edit this field if you wish to use a custom name for the alert processing rule, otherwise, you can leave this unchanged. An alert processing rule name can have a length of 1-260 characters. You cannot use <,>,*,%,&,:,\\,?,+,/,#,@,{,}.')
param alertProcessingRuleName string

@description('Description of the alert processing rule.')
param alertProcessingRuleDescription string

@description('Required. The condition that will cause this alert to activate. Array of objects.')
param conditions array

@description('Resource group where the Action Groups are located. This can be different than resource group of the vault.')
param actionGroupIds array

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
        actionGroupIds: actionGroupIds
      }
    ]
  }
}

output alertProcessingRuleId string = alertProcessingRule.id
