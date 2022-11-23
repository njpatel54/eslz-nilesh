@description('Required. The name of the action group.')
param name string

@description('Required. The short name of the action group.')
param groupShortName string

@description('Optional. The list of email receivers that are part of this action group.')
param emailReceivers array = []

@description('Optional. The list of SMS receivers that are part of this action group.')
param smsReceivers array = []

@description('Optional. The list of webhook receivers that are part of this action group.')
param webhookReceivers array = []

@description('Optional. The list of ITSM receivers that are part of this action group.')
param itsmReceivers array = []

@description('Optional. The list of AzureAppPush receivers that are part of this action group.')
param azureAppPushReceivers array = []

@description('Optional. The list of AutomationRunbook receivers that are part of this action group.')
param automationRunbookReceivers array = []

@description('Optional. The list of voice receivers that are part of this action group.')
param voiceReceivers array = []

@description('Optional. The list of logic app receivers that are part of this action group.')
param logicAppReceivers array = []

@description('Optional. The list of function receivers that are part of this action group.')
param azureFunctionReceivers array = []

@description('Optional. The list of ARM role receivers that are part of this action group. Roles are Azure RBAC roles and only built-in roles are supported.')
param armRoleReceivers array = []

@description('Optional. Tags of the resource.')
param tags object = {}

// 1. Create Action Group(s)
module actionGroup '../../modules/insights/actionGroups/deploy.bicep' = {
  name: 'actionGroup-${name}'
  params: {
    name: name
    groupShortName: groupShortName
    location: 'global'
    tags: tags
    emailReceivers: emailReceivers
    smsReceivers: smsReceivers
    webhookReceivers: webhookReceivers
    itsmReceivers: itsmReceivers
    azureAppPushReceivers: azureAppPushReceivers
    automationRunbookReceivers: automationRunbookReceivers
    voiceReceivers: voiceReceivers
    logicAppReceivers: logicAppReceivers
    azureFunctionReceivers: azureFunctionReceivers
    armRoleReceivers: armRoleReceivers
  }
}

