param location string
param mgmtsubid string
param connsubid string
param idensubid string
param sandsubid string
param workspacename string
param aaname string

@description('Optional. Service Tier: PerGB2018, Free, Standalone, PerGB or PerNode')
@allowed([
  'Free'
  'Standalone'
  'PerNode'
  'PerGB2018'
])
param serviceTier string = 'PerGB2018'

@description('Optional. Number of days data will be retained for')
@minValue(0)
@maxValue(730)
param dataRetention int = 365

@description('Optional. The workspace daily quota for ingestion.')
@minValue(-1)
param dailyQuotaGb int = -1

@description('Optional. The network access type for accessing Log Analytics ingestion.')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccessForIngestion string = 'Enabled'

@description('Optional. The network access type for accessing Log Analytics query.')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccessForQuery string = 'Enabled'

@description('Optional. Set to \'true\' to use resource or workspace permissions and \'false\' (or leave empty) to require workspace permissions.')
param useResourcePermissions bool = false

@description('Optional. Specifies the number of days that logs will be kept for; a value of 0 will retain data indefinitely.')
@minValue(0)
@maxValue(365)
param diagnosticLogsRetentionInDays int = 365

@description('Optional. Resource ID of the diagnostic storage account.')
param diagnosticStorageAccountId string = ''

@description('Optional. Resource ID of a log analytics workspace.')
param diagnosticWorkspaceId string = ''

@description('Optional. Resource ID of the diagnostic event hub authorization rule for the Event Hubs namespace in which the event hub should be created or streamed to.')
param diagnosticEventHubAuthorizationRuleId string = ''

@description('Optional. Name of the diagnostic event hub within the namespace to which logs are streamed. Without this, an event hub is created for each log category.')
param diagnosticEventHubName string = ''

@allowed([
  'CanNotDelete'
  'NotSpecified'
  'ReadOnly'
])
@description('Optional. Specify the type of lock.')
param lock string = 'NotSpecified'

@description('Optional. Tags of the resource.')
param tags object = {}

@description('Optional. The name of logs that will be streamed.')
@allowed([
  'Audit'
])
param diagnosticLogCategoriesToEnable array = [
  'Audit'
]

@description('Optional. The name of metrics that will be streamed.')
@allowed([
  'AllMetrics'
])
param diagnosticMetricsToEnable array = [
  'AllMetrics'
]

@description('Optional. The name of the diagnostic setting, if deployed.')
param diagnosticSettingsName string = '${workspacename}-diagnosticSettings'

var diagnosticsLogs = [for category in diagnosticLogCategoriesToEnable: {
  category: category
  enabled: true
  retentionPolicy: {
    enabled: true
    days: diagnosticLogsRetentionInDays
  }
}]

var diagnosticsMetrics = [for metric in diagnosticMetricsToEnable: {
  category: metric
  timeGrain: null
  enabled: true
  retentionPolicy: {
    enabled: true
    days: diagnosticLogsRetentionInDays
  }
}]

var logAnalyticsSearchVersion = 1

targetScope='resourceGroup'

var sentinelsolutionname = 'SecurityInsights(${workspacename})'

// Workspace
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01'= {
  location: location
  name: workspacename
  tags: tags
  properties: {
    features: {
      searchVersion: logAnalyticsSearchVersion
      enableLogAccessUsingOnlyResourcePermissions: useResourcePermissions
    }
    sku: {
      name: serviceTier
    }
    retentionInDays: dataRetention
    workspaceCapping: {
      dailyQuotaGb: dailyQuotaGb
    }
    publicNetworkAccessForIngestion: publicNetworkAccessForIngestion
    publicNetworkAccessForQuery: publicNetworkAccessForQuery
  }
}

resource logAnalyticsWorkspace_diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if ((!empty(diagnosticStorageAccountId)) || (!empty(diagnosticWorkspaceId)) || (!empty(diagnosticEventHubAuthorizationRuleId)) || (!empty(diagnosticEventHubName))) {
  name: diagnosticSettingsName
  properties: {
    storageAccountId: !empty(diagnosticStorageAccountId) ? diagnosticStorageAccountId : null
    workspaceId: !empty(diagnosticWorkspaceId) ? diagnosticWorkspaceId : null
    eventHubAuthorizationRuleId: !empty(diagnosticEventHubAuthorizationRuleId) ? diagnosticEventHubAuthorizationRuleId : null
    eventHubName: !empty(diagnosticEventHubName) ? diagnosticEventHubName : null
    metrics: diagnosticsMetrics
    logs: diagnosticsLogs
  }
  scope: logAnalyticsWorkspace
}

resource logAnalyticsWorkspace_lock 'Microsoft.Authorization/locks@2017-04-01' = if (lock != 'NotSpecified') {
  name: '${logAnalyticsWorkspace.name}-${lock}-lock'
  properties: {
    level: lock
    notes: (lock == 'CanNotDelete') ? 'Cannot delete resource or child resources.' : 'Cannot modify the resource or child resources.'
  }
  scope: logAnalyticsWorkspace
}

// Add Management Sub Activity Logs as Data Source
resource mgmtsublogs 'Microsoft.OperationalInsights/workspaces/dataSources@2020-08-01'= {
  parent: logAnalyticsWorkspace
  name: mgmtsubid
  kind: 'AzureActivityLog'
  properties:{
    linkedResourceId: '/subscriptions/${mgmtsubid}/providers/microsoft.insights/eventTypes/management'
  }  
}

// Add Connectivity Sub Activity Logs as Data Source
resource connsublogs 'Microsoft.OperationalInsights/workspaces/dataSources@2020-08-01'= {
  parent: logAnalyticsWorkspace
  name: connsubid
  kind: 'AzureActivityLog'
  properties:{
    linkedResourceId: '/subscriptions/${connsubid}/providers/microsoft.insights/eventTypes/management'
  }  
}

// Add Identity Sub Activity Logs as Data Source
resource idensublogs 'Microsoft.OperationalInsights/workspaces/dataSources@2020-08-01'= {
  parent: logAnalyticsWorkspace
  name: idensubid
  kind: 'AzureActivityLog'
  properties:{
    linkedResourceId: '/subscriptions/${idensubid}/providers/microsoft.insights/eventTypes/management'
  }  
}
// Add Sandbox Sub Activity Logs as Data Source
resource sandsublogs 'Microsoft.OperationalInsights/workspaces/dataSources@2020-08-01'= {
  parent: logAnalyticsWorkspace
  name: sandsubid
  kind: 'AzureActivityLog'
  properties:{
    linkedResourceId: '/subscriptions/${sandsubid}/providers/microsoft.insights/eventTypes/management'
  }  
}
// Enable Sentinel Solution (SecurityInsights)
resource sentinelsolution 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = {
  name: sentinelsolutionname
  location: location
  plan:{
    name: sentinelsolutionname
    product: 'OMSGallery/SecurityInsights'
    publisher: 'Microsoft'
    promotionCode: ''
  }
  properties:{
    workspaceResourceId: logAnalyticsWorkspace.id    
  }
}

resource aa 'Microsoft.Automation/automationAccounts@2020-01-13-preview'={
  name: aaname
  location: location
  dependsOn: [
    logAnalyticsWorkspace
  ]
  identity: {
    type: 'SystemAssigned'    
  }
  properties: {
    sku: {
      name: 'Basic'
    }
  }  
}

/* Commenting out LogA link to Automation Account
Known issue causes What-if deployment to fail.
See https://github.com/Azure/arm-template-whatif/issues/220 
resource linkedService 'Microsoft.OperationalInsights/workspaces/linkedServices@2020-08-01' = {
  name: '${workspacename}/Automation'
  dependsOn: [
    loga
    aa
  ]  
  properties: {
    resourceId:  aa.id
  }
}
*/


@description('The resource ID of the deployed log analytics workspace')
output resourceId string = logAnalyticsWorkspace.id

@description('The resource group of the deployed log analytics workspace')
output resourceGroupName string = resourceGroup().name

@description('The name of the deployed log analytics workspace')
output name string = logAnalyticsWorkspace.name

@description('The ID associated with the workspace')
output logAnalyticsWorkspaceId string = logAnalyticsWorkspace.properties.customerId
