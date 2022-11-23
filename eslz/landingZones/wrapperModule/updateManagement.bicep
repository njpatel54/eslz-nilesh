targetScope = 'managementGroup'

@description('subscriptionId for the deployment')
param subscriptionId string

@description('Location for the deployments and the resources')
param location string

@description('Optional. List of softwareUpdateConfigurations to be created in the automation account.')
param softwareUpdateConfigurations array = []

@description('Required. Subscription ID of Management Subscription.')
param mgmtsubid string

@description('Required. SIEM Resource Group Name.')
param siemRgName string

@description('Required. Automation Account Name - LAW - Sentinel')
param sentinelAutomationAcctName string

@description('Required. Suffix to be used in resource naming with 4 characters.')
param suffix string

module automationAccount_softwareUpdateConfigurations '../../modules/automation/automationAccounts/softwareUpdateConfigurations/deploy.bicep' = [for (softwareUpdateConfiguration, index) in softwareUpdateConfigurations: {
  name: '${uniqueString(deployment().name, location)}-AutoAccount-SwUpdateConfig-${index}'
  scope: resourceGroup(mgmtsubid, siemRgName)
  params: {
    name: '${suffix}-${softwareUpdateConfiguration.name}'
    automationAccountName: sentinelAutomationAcctName
    frequency: softwareUpdateConfiguration.frequency
    operatingSystem: softwareUpdateConfiguration.operatingSystem
    rebootSetting: softwareUpdateConfiguration.rebootSetting
    azureVirtualMachines: contains(softwareUpdateConfiguration, 'azureVirtualMachines') ? softwareUpdateConfiguration.azureVirtualMachines : []
    excludeUpdates: contains(softwareUpdateConfiguration, 'excludeUpdates') ? softwareUpdateConfiguration.excludeUpdates : []
    expiryTime: contains(softwareUpdateConfiguration, 'expiryTime') ? softwareUpdateConfiguration.expiryTime : ''
    expiryTimeOffsetMinutes: contains(softwareUpdateConfiguration, 'expiryTimeOffsetMinutes') ? softwareUpdateConfiguration.expiryTimeOffsetMinute : 0
    includeUpdates: contains(softwareUpdateConfiguration, 'includeUpdates') ? softwareUpdateConfiguration.includeUpdates : []
    interval: contains(softwareUpdateConfiguration, 'interval') ? softwareUpdateConfiguration.interval : 1
    isEnabled: contains(softwareUpdateConfiguration, 'isEnabled') ? softwareUpdateConfiguration.isEnabled : true
    maintenanceWindow: contains(softwareUpdateConfiguration, 'maintenanceWindow') ? softwareUpdateConfiguration.maintenanceWindow : 'PT2H'
    monthDays: contains(softwareUpdateConfiguration, 'monthDays') ? softwareUpdateConfiguration.monthDays : []
    monthlyOccurrences: contains(softwareUpdateConfiguration, 'monthlyOccurrences') ? softwareUpdateConfiguration.monthlyOccurrences : []
    nextRun: contains(softwareUpdateConfiguration, 'nextRun') ? softwareUpdateConfiguration.nextRun : ''
    nextRunOffsetMinutes: contains(softwareUpdateConfiguration, 'nextRunOffsetMinutes') ? softwareUpdateConfiguration.nextRunOffsetMinutes : 0
    nonAzureComputerNames: contains(softwareUpdateConfiguration, 'nonAzureComputerNames') ? softwareUpdateConfiguration.nonAzureComputerNames : []
    nonAzureQueries: contains(softwareUpdateConfiguration, 'nonAzureQueries') ? softwareUpdateConfiguration.nonAzureQueries : []
    postTaskParameters: contains(softwareUpdateConfiguration, 'postTaskParameters') ? softwareUpdateConfiguration.postTaskParameters : {}
    postTaskSource: contains(softwareUpdateConfiguration, 'postTaskSource') ? softwareUpdateConfiguration.postTaskSource : ''
    preTaskParameters: contains(softwareUpdateConfiguration, 'preTaskParameters') ? softwareUpdateConfiguration.preTaskParameters : {}
    preTaskSource: contains(softwareUpdateConfiguration, 'preTaskSource') ? softwareUpdateConfiguration.preTaskSource : ''
    scheduleDescription: contains(softwareUpdateConfiguration, 'scheduleDescription') ? softwareUpdateConfiguration.scheduleDescription : ''
    scopeByLocations: contains(softwareUpdateConfiguration, 'scopeByLocations') ? softwareUpdateConfiguration.scopeByLocations : []
    scopeByResources: contains(softwareUpdateConfiguration, 'scopeByResources') ? softwareUpdateConfiguration.scopeByResources : [
      subscriptionId
    ]
    scopeByTags: contains(softwareUpdateConfiguration, 'scopeByTags') ? softwareUpdateConfiguration.scopeByTags : {}
    scopeByTagsOperation: contains(softwareUpdateConfiguration, 'scopeByTagsOperation') ? softwareUpdateConfiguration.scopeByTagsOperation : 'All'
    startTime: contains(softwareUpdateConfiguration, 'startTime') ? softwareUpdateConfiguration.startTime : ''
    timeZone: contains(softwareUpdateConfiguration, 'timeZone') ? softwareUpdateConfiguration.timeZone : 'UTC'
    updateClassifications: contains(softwareUpdateConfiguration, 'updateClassifications') ? softwareUpdateConfiguration.updateClassifications : [
      'Critical'
      'Security'
    ]
    weekDays: contains(softwareUpdateConfiguration, 'weekDays') ? softwareUpdateConfiguration.weekDays : []    
  }
}]
