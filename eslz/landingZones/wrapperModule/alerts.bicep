@description('subscriptionId for the deployment')
param subscriptionId string

@description('Required. Name of the resourceGroup, where application workload will be deployed.')
param wlRgName string

@description('Optional. Tags of the resource.')
param tags object = {}

@description('Required - Action Groups Array')
param actionGroups array

@description('Variable containing all Activity Log Alerts.')
var activityLogAlertRulesVar = [
  {
    rule: json(loadTextContent('alerts/activityLogAlerts/virtualNetwork-Created.json'))
  }
]

// 1. Create Activity Log Alerts
module activityLogAlertRules '../../modules/insights/activityLogAlerts/deploy.bicep' = [for (activityLogAlertRule, i) in activityLogAlertRulesVar: {
  name: 'activityLogAlertRules-${activityLogAlertRule.rule.alertName}'
  params: {
    name: activityLogAlertRule.rule.alertName
    alertDescription: activityLogAlertRule.rule.alertDescription
    conditions: activityLogAlertRule.rule.condition.value
    location: 'global'
    tags: tags
    actions: [for (actionGroup, i) in actionGroups: {
      actionGroupId: resourceId(subscriptionId, wlRgName, 'Microsoft.insights/actiongroups', actionGroup.name)    
    }]
  }
}]
