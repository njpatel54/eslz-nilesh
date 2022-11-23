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

@description('Variable containing all Activity Log Alerts.')
var activityLogAlertRulesVar = [
  {
    rule: json(loadTextContent('alerts/activityLogAlerts/Custom-Policy-Definition-Created.json'))
  }
  {
    rule: json(loadTextContent('alerts/activityLogAlerts/Custom-Policy-Definition-Deleted.json'))
  }
  {
    rule: json(loadTextContent('alerts/activityLogAlerts/Custom-Policy-Set-Definition-Created-Updated.json'))
  }
  {
    rule: json(loadTextContent('alerts/activityLogAlerts/Custom-Policy-Set-Definition-Deleted.json'))
  }
  {
    rule: json(loadTextContent('alerts/activityLogAlerts/Custom-Role-Definition-Created-Updated.json'))
  }
  {
    rule: json(loadTextContent('alerts/activityLogAlerts/Custom-Role-Definition-Deleted.json'))
  }
  {
    rule: json(loadTextContent('alerts/activityLogAlerts/Disk-Accesses-Created-Updated.json'))
  }
  {
    rule: json(loadTextContent('alerts/activityLogAlerts/Disk-Accesses-Deleted.json'))
  }
  {
    rule: json(loadTextContent('alerts/activityLogAlerts/Key-Vault-Certificate-Deleted.json'))
  }
  {
    rule: json(loadTextContent('alerts/activityLogAlerts/Key-Vault-Certificate-Purged.json'))
  }
  {
    rule: json(loadTextContent('alerts/activityLogAlerts/Key-Vault-Created-Updated.json'))
  }
  {
    rule: json(loadTextContent('alerts/activityLogAlerts/Key-Vault-Deleted.json'))
  }
  {
    rule: json(loadTextContent('alerts/activityLogAlerts/Key-Vault-Key-Deleted.json'))
  }
  {
    rule: json(loadTextContent('alerts/activityLogAlerts/Key-Vault-Key-Purged.json'))
  }
  {
    rule: json(loadTextContent('alerts/activityLogAlerts/Key-Vault-Secret-Deleted.json'))
  }
  {
    rule: json(loadTextContent('alerts/activityLogAlerts/Key-Vault-Secret-Purged.json'))
  }
  {
    rule: json(loadTextContent('alerts/activityLogAlerts/Network-Security-Group-Created-Updated.json'))
  }
  {
    rule: json(loadTextContent('alerts/activityLogAlerts/Network-Security-Group-Deleted.json'))
  }
  {
    rule: json(loadTextContent('alerts/activityLogAlerts/Network-Security-Group-Security-Rule-Created-Updated.json'))
  }
  {
    rule: json(loadTextContent('alerts/activityLogAlerts/Network-Security-Group-Security-Rule-Deleted.json'))
  }
  {
    rule: json(loadTextContent('alerts/activityLogAlerts/Policy-Assignment-Created-Updated.json'))
  }
  {
    rule: json(loadTextContent('alerts/activityLogAlerts/Policy-Assignment-Deleted.json'))
  }
  {
    rule: json(loadTextContent('alerts/activityLogAlerts/Policy-Assignment-Exemption-Created.json'))
  }
  {
    rule: json(loadTextContent('alerts/activityLogAlerts/Policy-Exemption-Created.json'))
  }
  {
    rule: json(loadTextContent('alerts/activityLogAlerts/Policy-Exemption-Deleted.json'))
  }
  {
    rule: json(loadTextContent('alerts/activityLogAlerts/Private-DNS-Zone-Created-Updated.json'))
  }
  {
    rule: json(loadTextContent('alerts/activityLogAlerts/Resource-Diagnostics-Settings-Created-Updated.json'))
  }
  {
    rule: json(loadTextContent('alerts/activityLogAlerts/Resource-Diagnostics-Settings-Deleted.json'))
  }
  {
    rule: json(loadTextContent('alerts/activityLogAlerts/Role-Assignment-Created.json'))
  }
  {
    rule: json(loadTextContent('alerts/activityLogAlerts/Role-Assignment-Deleted.json'))
  }
  {
    rule: json(loadTextContent('alerts/activityLogAlerts/Virtual-Network-Created-Updated.json'))
  }
  {
    rule: json(loadTextContent('alerts/activityLogAlerts/Virtual-Network-Deleted.json'))
  }
  {
    rule: json(loadTextContent('alerts/activityLogAlerts/Virtual-Network-Peering-Created-Updated.json'))
  }
  {
    rule: json(loadTextContent('alerts/activityLogAlerts/Virtual-Network-Peering-Deleted.json'))
  }
  {
    rule: json(loadTextContent('alerts/activityLogAlerts/Virtual-Network-Subnet-Created-Updated.json'))
  }
  {
    rule: json(loadTextContent('alerts/activityLogAlerts/Virtual-Network-Subnet-Deleted.json'))
  }
]

// 1. Create Activity Log Alerts
module activityLogAlertRules '../../modules/insights/activityLogAlerts/deploy.bicep' = [for (activityLogAlertRule, i) in activityLogAlertRulesVar: {
  name: 'activityLogAlertRules-${activityLogAlertRule.rule.alertName}'
  params: {
    name: '${suffix}-${activityLogAlertRule.rule.alertName}'
    alertDescription: activityLogAlertRule.rule.alertDescription
    conditions: activityLogAlertRule.rule.condition.value
    location: 'global'
    tags: tags
    actions: [for (actionGroup, i) in actionGroups: {
      actionGroupId: resourceId(subscriptionId, wlRgName, 'Microsoft.insights/actiongroups', actionGroup.name)
    }]
  }
}]
