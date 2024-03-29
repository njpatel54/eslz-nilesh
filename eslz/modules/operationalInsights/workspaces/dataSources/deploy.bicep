@description('Conditional. The name of the parent Log Analytics workspace. Required if the template is used in a standalone deployment.')
param logAnalyticsWorkspaceName string

@description('Required. Name of the solution.')
param name string

@description('Required. The kind of the DataSource.')
@allowed([
  'AzureActivityLog'
  'WindowsEvent'
  'WindowsPerformanceCounter'
  'SecurityInsightsSecurityEventCollectionConfiguration'
  'IISLogs'
  'LinuxSyslog'
  'LinuxSyslogCollection'
  'LinuxPerformanceObject'
  'LinuxPerformanceCollection'
])
param kind string = 'AzureActivityLog'

@description('Optional. Tags to configure in the resource.')
param tags object = {}

@description('Optional. Resource ID of the resource to be linked.')
param linkedResourceId string = ''

@description('Optional. Windows event log name to configure when kind is WindowsEvent.')
param eventLogName string = ''

@description('Optional. Windows event types to configure when kind is WindowsEvent.')
param eventTypes array = []

@description('Optional. Tier determines which security events to stream for Windows Security Event using "Security Events via Legacy Agent" Data Connector in Sentinel..')
@allowed([
  'All'              //All - All Windows security and AppLocker events.
  'Recommended'      //Common - A standard set of events for auditing purposes.
  'Minimal'          //A small set of events that might indicate potential threats. By enabling this option, you won't be able to have a full audit trail.
  'None'             //No security or AppLocker events.
])
param tier string = 'All'

@description('Optional. Tier set method for Windows Security Event using "Security Events via Legacy Agent" Data Connector in Sentinel.')
param tierSetMethod string = 'Custom' 

@description('Optional. Name of the object to configure when kind is WindowsPerformanceCounter or LinuxPerformanceObject.')
param objectName string = ''

@description('Optional. Name of the instance to configure when kind is WindowsPerformanceCounter or LinuxPerformanceObject.')
param instanceName string = '*'

@description('Optional. Interval in seconds to configure when kind is WindowsPerformanceCounter or LinuxPerformanceObject.')
param intervalSeconds int = 60

@description('Optional. List of counters to configure when the kind is LinuxPerformanceObject.')
param performanceCounters array = []

@description('Optional. Counter name to configure when kind is WindowsPerformanceCounter.')
param counterName string = ''

@description('Optional. State to configure when kind is IISLogs or LinuxSyslogCollection or LinuxPerformanceCollection.')
param state string = ''

@description('Optional. System log to configure when kind is LinuxSyslog.')
param syslogName string = ''

@description('Optional. Severities to configure when kind is LinuxSyslog.')
param syslogSeverities array = []

resource workspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = {
  name: logAnalyticsWorkspaceName
}

resource dataSource 'Microsoft.OperationalInsights/workspaces/dataSources@2020-08-01' = {
  name: name
  parent: workspace
  kind: kind
  tags: tags
  properties: {
    linkedResourceId: !empty(kind) && kind == 'AzureActivityLog' ? linkedResourceId : null
    eventLogName: !empty(kind) && kind == 'WindowsEvent' ? eventLogName : null
    eventTypes: !empty(kind) && kind == 'WindowsEvent' ? eventTypes : null
    tier: !empty(kind) && kind == 'SecurityInsightsSecurityEventCollectionConfiguration' ? tier : null
    tierSetMethod: !empty(kind) && kind == 'SecurityInsightsSecurityEventCollectionConfiguration' ? tierSetMethod : null
    objectName: !empty(kind) && (kind == 'WindowsPerformanceCounter' || kind == 'LinuxPerformanceObject') ? objectName : null
    instanceName: !empty(kind) && (kind == 'WindowsPerformanceCounter' || kind == 'LinuxPerformanceObject') ? instanceName : null
    intervalSeconds: !empty(kind) && (kind == 'WindowsPerformanceCounter' || kind == 'LinuxPerformanceObject') ? intervalSeconds : null
    counterName: !empty(kind) && kind == 'WindowsPerformanceCounter' ? counterName : null
    state: !empty(kind) && (kind == 'IISLogs' || kind == 'LinuxSyslogCollection' || kind == 'LinuxPerformanceCollection') ? state : null
    syslogName: !empty(kind) && kind == 'LinuxSyslog' ? syslogName : null
    syslogSeverities: !empty(kind) && (kind == 'LinuxSyslog' || kind == 'LinuxPerformanceObject') ? syslogSeverities : null
    performanceCounters: !empty(kind) && kind == 'LinuxPerformanceObject' ? performanceCounters : null
  }
}

@description('The resource ID of the deployed data source.')
output resourceId string = dataSource.id

@description('The resource group where the data source is deployed.')
output resourceGroupName string = resourceGroup().name

@description('The name of the deployed data source.')
output name string = dataSource.name
