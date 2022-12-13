targetScope = 'tenant'

@description('subscriptionId for the deployment')
param subscriptionId string

@description('Required. Name of the resourceGroup, where application workload will be deployed.')
param wlRgName string

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

@description('Location for the deployments and the resources')
param location string

@description('Required. Array of Action Groups')
param actionGroups array = []

// 1. Create Action Group(s)
module actionGroup '../../modules/insights/actionGroups/deploy.bicep' = [for (actionGroup, i) in actionGroups: {
  name: 'actionGroup--${take(uniqueString(deployment().name, location), 4)}-${actionGroup.name}'
  scope: resourceGroup(subscriptionId, wlRgName)
  params: {
    name: actionGroup.name
    groupShortName: actionGroup.groupShortName
    location: 'global'
    tags: tags
    emailReceivers: actionGroup.emailReceivers
    smsReceivers: actionGroup.smsReceivers
    webhookReceivers: webhookReceivers
    itsmReceivers: itsmReceivers
    azureAppPushReceivers: azureAppPushReceivers
    automationRunbookReceivers: automationRunbookReceivers
    voiceReceivers: voiceReceivers
    logicAppReceivers: logicAppReceivers
    azureFunctionReceivers: azureFunctionReceivers
    armRoleReceivers: armRoleReceivers
  }
}]

/*
@description('Required. The name of the action group.')
param name string

@description('Required. The short name of the action group.')
param groupShortName string

@description('Optional. The list of email receivers that are part of this action group.')
param emailReceivers array = []

@description('Optional. The list of SMS receivers that are part of this action group.')
param smsReceivers array = []
*/
