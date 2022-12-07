@description('subscriptionId for the deployment')
param subscriptionId string

@description('Required. Name of the resourceGroup, where application workload will be deployed.')
param wlRgName string

@description('Optional. Tags of the resource.')
param tags object = {}

@description('Required. Suffix to be used in resource naming with 4 characters.')
param suffix string

@description('Required - Action Groups Array')
param actionGroups array

@description('Variable containing all Activity Log Alert Rules.')
var activityLogAlertRulesVar = [
  {
    rule: json(loadTextContent('../../alerts/activityLogAlerts/Azure-Advisor-Cost-Recommendations.json'))
  }
  {
    rule: json(loadTextContent('../../alerts/activityLogAlerts/Azure-Advisor-HighAvailability-Recommendations.json'))
  }
  {
    rule: json(loadTextContent('../../alerts/activityLogAlerts/Azure-Advisor-Performance-Recommendations.json'))
  }
  {
    rule: json(loadTextContent('../../alerts/activityLogAlerts/Custom-Policy-Definition-Created.json'))
  }
  {
    rule: json(loadTextContent('../../alerts/activityLogAlerts/Custom-Policy-Definition-Deleted.json'))
  }
  {
    rule: json(loadTextContent('../../alerts/activityLogAlerts/Custom-Policy-Set-Definition-Created-Updated.json'))
  }
  {
    rule: json(loadTextContent('../../alerts/activityLogAlerts/Custom-Policy-Set-Definition-Deleted.json'))
  }
  {
    rule: json(loadTextContent('../../alerts/activityLogAlerts/Custom-Role-Definition-Created-Updated.json'))
  }
  {
    rule: json(loadTextContent('../../alerts/activityLogAlerts/Custom-Role-Definition-Deleted.json'))
  }
  {
    rule: json(loadTextContent('../../alerts/activityLogAlerts/Disk-Accesses-Created-Updated.json'))
  }
  {
    rule: json(loadTextContent('../../alerts/activityLogAlerts/Disk-Accesses-Deleted.json'))
  }
  {
    rule: json(loadTextContent('../../alerts/activityLogAlerts/Key-Vault-Certificate-Deleted.json'))
  }
  {
    rule: json(loadTextContent('../../alerts/activityLogAlerts/Key-Vault-Certificate-Purged.json'))
  }
  {
    rule: json(loadTextContent('../../alerts/activityLogAlerts/Key-Vault-Created-Updated.json'))
  }
  {
    rule: json(loadTextContent('../../alerts/activityLogAlerts/Key-Vault-Deleted.json'))
  }
  {
    rule: json(loadTextContent('../../alerts/activityLogAlerts/Key-Vault-Key-Deleted.json'))
  }
  {
    rule: json(loadTextContent('../../alerts/activityLogAlerts/Key-Vault-Key-Purged.json'))
  }
  {
    rule: json(loadTextContent('../../alerts/activityLogAlerts/Key-Vault-Secret-Deleted.json'))
  }
  {
    rule: json(loadTextContent('../../alerts/activityLogAlerts/Key-Vault-Secret-Purged.json'))
  }
  {
    rule: json(loadTextContent('../../alerts/activityLogAlerts/Network-Security-Group-Created-Updated.json'))
  }
  {
    rule: json(loadTextContent('../../alerts/activityLogAlerts/Network-Security-Group-Deleted.json'))
  }
  {
    rule: json(loadTextContent('../../alerts/activityLogAlerts/Network-Security-Group-Security-Rule-Created-Updated.json'))
  }
  {
    rule: json(loadTextContent('../../alerts/activityLogAlerts/Network-Security-Group-Security-Rule-Deleted.json'))
  }
  {
    rule: json(loadTextContent('../../alerts/activityLogAlerts/Policy-Assignment-Created-Updated.json'))
  }
  {
    rule: json(loadTextContent('../../alerts/activityLogAlerts/Policy-Assignment-Deleted.json'))
  }
  {
    rule: json(loadTextContent('../../alerts/activityLogAlerts/Policy-Assignment-Exemption-Created.json'))
  }
  {
    rule: json(loadTextContent('../../alerts/activityLogAlerts/Policy-Exemption-Created.json'))
  }
  {
    rule: json(loadTextContent('../../alerts/activityLogAlerts/Policy-Exemption-Deleted.json'))
  }
  {
    rule: json(loadTextContent('../../alerts/activityLogAlerts/Private-DNS-Zone-Created-Updated.json'))
  }
  {
    rule: json(loadTextContent('../../alerts/activityLogAlerts/Resource-Diagnostics-Settings-Created-Updated.json'))
  }
  {
    rule: json(loadTextContent('../../alerts/activityLogAlerts/Resource-Diagnostics-Settings-Deleted.json'))
  }
  {
    rule: json(loadTextContent('../../alerts/activityLogAlerts/Role-Assignment-Created.json'))
  }
  {
    rule: json(loadTextContent('../../alerts/activityLogAlerts/Role-Assignment-Deleted.json'))
  }
  {
    rule: json(loadTextContent('../../alerts/activityLogAlerts/Virtual-Network-Created-Updated.json'))
  }
  {
    rule: json(loadTextContent('../../alerts/activityLogAlerts/Virtual-Network-Deleted.json'))
  }
  {
    rule: json(loadTextContent('../../alerts/activityLogAlerts/Virtual-Network-Peering-Created-Updated.json'))
  }
  {
    rule: json(loadTextContent('../../alerts/activityLogAlerts/Virtual-Network-Peering-Deleted.json'))
  }
  {
    rule: json(loadTextContent('../../alerts/activityLogAlerts/Virtual-Network-Subnet-Created-Updated.json'))
  }
  {
    rule: json(loadTextContent('../../alerts/activityLogAlerts/Virtual-Network-Subnet-Deleted.json'))
  }  
]

@description('Variable containing all Service Health Alert Rules.')
var serviceHealthAlertRulesVar = [
  {
    rule: json(loadTextContent('../../alerts/serviceHealthAlerts/Health-Advisories-Selected-Regions.json'))
  }
  {
    rule: json(loadTextContent('../../alerts/serviceHealthAlerts/Planned-Maintenance-Selected-Regions.json'))
  }
  {
    rule: json(loadTextContent('../../alerts/serviceHealthAlerts/Security-Advisory-Selected-Regions.json'))
  }
  {
    rule: json(loadTextContent('../../alerts/serviceHealthAlerts/Service-Issue-Selected-Regions.json'))
  }  
]

@description('Variable containing Metric Alert Rules for All Resoruces in Subscription.')
var metricAlertRules = [
  {
    rule: json(loadTextContent('../../alerts/metricAlerts/Percentage-CPU-GreaterOrLessThan-Dynamic-Thresholds.json'))
  }
  {
    rule: json(loadTextContent('../../alerts/metricAlerts/Percentage-CPU-GreaterThan-80-Percent-Static-Thresholds.json'))
  }
  {
    rule: json(loadTextContent('../../alerts/metricAlerts/Percentage-CPU-LessThan-30-Percent-Static-Thresholds.json'))
  }
]

@description('Variable containing Alert Processing Rules - Add Action Groups.')
var alertProcessingRulesAddActionGroups = [
  {
    rule: json(loadTextContent('../../alerts/alertProcessingRules/addActionGroups/Alerts-Apply-ActionGroup.json'))
  }
]

@description('Variable containing Alert Processing Rules - Suppress Notifications.')
var alertProcessingRulesSuppressNotifications = [
  {
    rule: json(loadTextContent('../../alerts/alertProcessingRules/suppressNotifications/Suppress-Notifications-Weekly-No-End-Dates.json'))
  }
]

// 1. Create Activity Log Alert Rules
module activityLogAlertRules '../../modules/insights/activityLogAlerts/deploy.bicep' = [for (activityLogAlertRule, i) in activityLogAlertRulesVar: {
  name: 'activityLogAlertRules-${i}'
  params: {
    name: '${suffix} - Activity Log - ${activityLogAlertRule.rule.alertName}'
    location: 'global'
    tags: tags
    alertDescription: activityLogAlertRule.rule.alertDescription
    conditions: activityLogAlertRule.rule.condition.value
    actions: [for (actionGroup, i) in actionGroups: {
      actionGroupId: resourceId(subscriptionId, wlRgName, 'Microsoft.insights/actiongroups', actionGroup.name)
    }]
  }
}]

// 2. Create Service Health Alert Rules
module serviceHealthAlertRules '../../modules/insights/activityLogAlerts/deploy.bicep' = [for (serviceHealthAlertRule, i) in serviceHealthAlertRulesVar: {
  name: 'serviceHealthAlertRules-${i}'
  params: {
    name: '${suffix} - Service Health - ${serviceHealthAlertRule.rule.alertName}'
    location: 'global'
    tags: tags
    alertDescription: serviceHealthAlertRule.rule.alertDescription
    conditions: serviceHealthAlertRule.rule.condition.value
    actions: [for (actionGroup, i) in actionGroups: {
      actionGroupId: resourceId(subscriptionId, wlRgName, 'Microsoft.insights/actiongroups', actionGroup.name)
    }]
  }
}]

// 3. Create Metric Alert Rules - All Resources in Subscription
module metricAlertRulesAllResorucesinSub '../../modules/insights/metricAlerts/deploy.bicep' = [for (metricAlertRule, i) in metricAlertRules: {
  name: 'metricAlertRulesAllResorucesinSub-${i}'
  params: {
    name: '${suffix} - Metric - ${metricAlertRule.rule.name} - All Resoruces in Subscription'
    location: 'global'
    tags: tags
    windowSize: metricAlertRule.rule.windowSize
    targetResourceType: metricAlertRule.rule.targetResourceType
    targetResourceRegion: metricAlertRule.rule.targetResourceRegion
    alertCriteriaType: metricAlertRule.rule.alertCriteriaType
    criterias: metricAlertRule.rule.criterias.value
    actions: [for (actionGroup, i) in actionGroups: {
      actionGroupId: resourceId(subscriptionId, wlRgName, 'Microsoft.insights/actiongroups', actionGroup.name)
    }]
  }
}]

// 4. Create Alert Processing Rules (Add Action Groups)
module alertProcessingRuleAddActionGroup '../../modules/alertsManagement/actionRules/addActionGroups/deploy.bicep' = [for (alertProcessingRule, i) in alertProcessingRulesAddActionGroups:{
  name: 'alertProcessingRuleAddActionGroup-${i}'
  params: {
    alertProcessingRuleName: '${suffix} - ${alertProcessingRule.rule.alertProcessingRuleName}'
    alertProcessingRuleDescription: alertProcessingRule.rule.alertProcessingRuleDescription
    conditions: alertProcessingRule.rule.conditions
    actionGroups: [for (actionGroupName, i) in alertProcessingRule.rule.actionGroupNames: {
      actionGroupId: resourceId(subscriptionId, wlRgName, 'Microsoft.insights/actiongroups', actionGroupName)
    }]
    //actionGroupNames: alertProcessingRule.rule.actionGroupNames
    //actionType: alertProcessingRule.rule.actionType
    //actions: [for actionGroupName in alertProcessingRule.rule.actionGroupNames: {
    //  actionType: 'AddActionGroups'
    //  actionGroupIds: [
    //    resourceId(subscriptionId, wlRgName, 'Microsoft.insights/actiongroups', actionGroupName)
    //  ]
    //}]
  }
}]

// 5. Create Alert Processing Rules (Suppress Notifications)
module alertProcessingRuleSupperssNotification '../../modules/alertsManagement/actionRules/suppressNotifications/deploy.bicep' = [for (alertProcessingRule, i) in alertProcessingRulesSuppressNotifications:{
  name: 'alertProcessingRuleSupperssNotification-${i}'
  params: {
    alertProcessingRuleName: '${suffix} - ${alertProcessingRule.rule.alertProcessingRuleName}'
    alertProcessingRuleDescription: alertProcessingRule.rule.alertProcessingRuleDescription
    conditions: alertProcessingRule.rule.conditions
    schedule: alertProcessingRule.rule.schedule
  }
}]













/*
@description('Output - Resource Group Rescoruce IDs Array to be used to create Azure Monitor Metric Alert Rules.')
param rgResoruceIds array

@description('Required. Virtual Machine Rescoruce IDs Array to be used to create Azure Monitor Metric Alert Rules.')
param vmResourceIDs array

// 4. Create Metric Alert Rules - All Resources in Resource Groups
module metricAlertRulesAllResorucesinRGs '../../modules/insights/metricAlerts/deploy.bicep' = [for (metricAlertRule, i) in metricAlertRules: {
  name: 'metricAlertRulesAllResorucesinRGs-${i}'
  params: {
    name: '${suffix} - Metric - ${metricAlertRule.rule.name} - All Resoruces in Resource Groups'
    location: 'global'
    tags: tags
    windowSize: metricAlertRule.rule.windowSize
    targetResourceType: metricAlertRule.rule.targetResourceType
    targetResourceRegion: metricAlertRule.rule.targetResourceRegion
    alertCriteriaType: metricAlertRule.rule.alertCriteriaType
    criterias: metricAlertRule.rule.criterias.value
    scopes: [
      rgResoruceIds
    ]
    actions: [for (actionGroup, i) in actionGroups: {
      actionGroupId: resourceId(subscriptionId, wlRgName, 'Microsoft.insights/actiongroups', actionGroup.name)
    }]
  }
}]

// 5. Create Metric Alert Rules - List of Resources in Subscription
module metricAlertRulesListOfResourcesInSub '../../modules/insights/metricAlerts/deploy.bicep' = [for (metricAlertRule, i) in metricAlertRules: {
  name: 'metricAlertRulesListOfResourcesInSub-${i}'
  params: {
    name: '${suffix} - Metric - ${metricAlertRule.rule.name} - List of Resources in Subscription'
    location: 'global'
    tags: tags
    windowSize: metricAlertRule.rule.windowSize
    targetResourceType: metricAlertRule.rule.targetResourceType
    targetResourceRegion: metricAlertRule.rule.targetResourceRegion
    alertCriteriaType: metricAlertRule.rule.alertCriteriaType
    criterias: metricAlertRule.rule.criterias.value
    scopes: [
      vmResourceIDs
    ]
    actions: [for (actionGroup, i) in actionGroups: {
      actionGroupId: resourceId(subscriptionId, wlRgName, 'Microsoft.insights/actiongroups', actionGroup.name)
    }]
  }
}]
*/
