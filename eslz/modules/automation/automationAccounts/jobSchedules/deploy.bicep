@description('Optional. Name of the Automation Account job schedule. Must be a GUID. If not provided, a new GUID is generated.')
param name string = newGuid()

@description('Conditional. The name of the parent Automation Account. Required if the template is used in a standalone deployment.')
param automationAccountName string

@description('Required. The runbook property associated with the entity.')
param runbookName string

@description('Required. The schedule property associated with the entity.')
param scheduleName string

@description('Optional. List of job properties.')
param parameters object = {}

@description('Optional. The hybrid worker group that the scheduled job should run on.')
param runOn string = ''

resource automationAccount 'Microsoft.Automation/automationAccounts@2020-01-13-preview' existing = {
  name: automationAccountName
}

resource jobSchedule 'Microsoft.Automation/automationAccounts/jobSchedules@2020-01-13-preview' = {
  // For each job schedule deployed with an ARM template, the GUID must be unique. Even if you're rescheduling an existing schedule, you'll need to change the GUID. This applies even if you've previously deleted an existing job schedule that was created with the same template. Reusing the same GUID results in a failed deployment.
  #disable-next-line use-stable-resource-identifiers
  name: name
  parent: automationAccount
  properties: {
    parameters: parameters
    runbook: {
      name: runbookName
    }
    runOn: !empty(runOn) ? runOn : null
    schedule: {
      name: scheduleName
    }
  }
}

@description('The name of the deployed job schedule.')
output name string = jobSchedule.name

@description('The resource ID of the deployed job schedule.')
output resourceId string = jobSchedule.id

@description('The resource group of the deployed job schedule.')
output resourceGroupName string = resourceGroup().name
