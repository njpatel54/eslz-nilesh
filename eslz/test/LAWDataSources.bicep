@description('Required. Name of the Log Analytics workspace')
param logAnalyticsWorkspaceName string

@description('Required. Service Tier: Free, Standalone, PerGB or PerNode')
@allowed([
  'Free'
  'Standalone'
  'PerNode'
  'PerGB2018'
])
param serviceTier string = 'PerNode'

@description('Required. Number of days data will be retained for')
@minValue(0)
@maxValue(730)
param dataRetention int = 365

@description('Required. Region used when establishing the workspace')
@allowed([
  'Australia Central'
  'Australia East'
  'Australia Southeast'
  'Canada Central'
  'Central India'
  'Central US'
  'East Asia'
  'East US'
  'East US 2'
  'France Central'
  'Japan East'
  'Korea Central'
  'North Europe'
  'South Central US'
  'Southeast Asia'
  'UK South'
  'West Europe'
  'West US'
  'West US 2'
  'USGov Virginia'
  'USGov Iowa'
  'USGov Arizona'
  'USGov Texas'
  'USDoD Central'
  'USDoD East'
])
param location string

@description('Required. Diagnostic Storage Account name')
param diagnosticStorageAccountName string

@description('Required. Log Analytics workspace resource identifier')
param diagnosticStorageAccountId string

@description('Required. Diagnostic Storage Account key')
@secure()
param diagnosticStorageAccountAccessKey string

@description('Optional. Automation Account resource identifier, value used to create a LinkedService between Log Analytics and an Automation Account.')
param automationAccountId string = ''

@description('Install Azure Sentinel as part of the Log Analytics Workspace.')
param azureSentinel string = 'false'

var logAnalyticsSearchVersion = 1
var azureSentinelSolutionName = 'SecurityInsights(${logAnalyticsWorkspaceName})'
var product = 'OMSGallery/SecurityInsights'
var publisher = 'Microsoft'
var solutions = [
  {
    name: 'Updates(${logAnalyticsWorkspaceName})'
    galleryName: 'Updates'
  }
  {
    name: 'AzureAutomation(${logAnalyticsWorkspaceName})'
    galleryName: 'AzureAutomation'
  }
  {
    name: 'AntiMalware(${logAnalyticsWorkspaceName})'
    galleryName: 'AntiMalware'
  }
  {
    name: 'SQLAssessment(${logAnalyticsWorkspaceName})'
    galleryName: 'SQLAssessment'
  }
  {
    name: 'Security(${logAnalyticsWorkspaceName})'
    galleryName: 'Security'
  }
  {
    name: 'SecurityCenterFree(${logAnalyticsWorkspaceName})'
    galleryName: 'SecurityCenterFree'
  }
  {
    name: 'ChangeTracking(${logAnalyticsWorkspaceName})'
    galleryName: 'ChangeTracking'
  }
  {
    name: 'KeyVaultAnalytics(${logAnalyticsWorkspaceName})'
    galleryName: 'KeyVaultAnalytics'
  }
  {
    name: 'AzureSQLAnalytics(${logAnalyticsWorkspaceName})'
    galleryName: 'AzureSQLAnalytics'
  }
  {
    name: 'ServiceMap(${logAnalyticsWorkspaceName})'
    galleryName: 'ServiceMap'
  }
]

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2017-03-15-preview' = {
  location: location
  name: logAnalyticsWorkspaceName
  properties: {
    features: {
      searchVersion: logAnalyticsSearchVersion
    }
    sku: {
      name: serviceTier
    }
    retentionInDays: dataRetention
  }
}

resource logAnalyticsWorkspaceName_VMSSQueries 'Microsoft.OperationalInsights/workspaces/savedSearches@2017-03-15-preview' = {
  parent: logAnalyticsWorkspace
  name: 'VMSSQueries'
  properties: {
    etag: '*'
    DisplayName: 'VMSS Instance Count'
    Category: 'VDC Saved Searches'
    Query: 'Event | where Source == "ServiceFabricNodeBootstrapAgent" | summarize AggregatedValue = count() by Computer'
  }
}

resource logAnalyticsWorkspaceName_AzureFirewallThreatDeny 'Microsoft.OperationalInsights/workspaces/savedSearches@2017-03-15-preview' = {
  parent: logAnalyticsWorkspace
  name: 'AzureFirewallThreatDeny'
  properties: {
    etag: '*'
    DisplayName: 'Azure Threat Deny'
    Category: 'VDC Saved Searches'
    Query: 'AzureDiagnostics | where ResourceType == \'AZUREFIREWALLS\' and msg_s contains \'Deny\''
  }
}

resource logAnalyticsWorkspaceName_subscriptionId 'Microsoft.OperationalInsights/workspaces/datasources@2015-11-01-preview' = {
  parent: logAnalyticsWorkspace
  kind: 'AzureActivityLog'
  name: '${subscription().subscriptionId}'
  location: location
  properties: {
    linkedResourceId: '${subscription().id}/providers/microsoft.insights/eventTypes/management'
  }
}

resource logAnalyticsWorkspaceName_applicationEvent 'Microsoft.OperationalInsights/workspaces/datasources@2015-11-01-preview' = {
  parent: logAnalyticsWorkspace
  name: 'applicationEvent'
  kind: 'WindowsEvent'
  properties: {
    eventLogName: 'Application'
    eventTypes: [
      {
        eventType: 'Error'
      }
      {
        eventType: 'Warning'
      }
      {
        eventType: 'Information'
      }
    ]
  }
}

resource logAnalyticsWorkspaceName_systemEvent 'Microsoft.OperationalInsights/workspaces/datasources@2015-11-01-preview' = {
  parent: logAnalyticsWorkspace
  name: 'systemEvent'
  kind: 'WindowsEvent'
  properties: {
    eventLogName: 'System'
    eventTypes: [
      {
        eventType: 'Error'
      }
      {
        eventType: 'Warning'
      }
      {
        eventType: 'Information'
      }
    ]
  }
}

resource logAnalyticsWorkspaceName_windowsPerfCounter1 'Microsoft.OperationalInsights/workspaces/datasources@2015-11-01-preview' = {
  parent: logAnalyticsWorkspace
  name: 'windowsPerfCounter1'
  kind: 'WindowsPerformanceCounter'
  properties: {
    objectName: 'Processor'
    instanceName: '*'
    intervalSeconds: 60
    counterName: '% Processor Time'
  }
}

resource logAnalyticsWorkspaceName_windowsPerfCounter2 'Microsoft.OperationalInsights/workspaces/datasources@2015-11-01-preview' = {
  parent: logAnalyticsWorkspace
  name: 'windowsPerfCounter2'
  kind: 'WindowsPerformanceCounter'
  properties: {
    objectName: 'Processor'
    instanceName: '*'
    intervalSeconds: 60
    counterName: '% Privileged Time'
  }
}

resource logAnalyticsWorkspaceName_windowsPerfCounter3 'Microsoft.OperationalInsights/workspaces/datasources@2015-11-01-preview' = {
  parent: logAnalyticsWorkspace
  name: 'windowsPerfCounter3'
  kind: 'WindowsPerformanceCounter'
  properties: {
    objectName: 'Processor'
    instanceName: '*'
    intervalSeconds: 60
    counterName: '% User Time'
  }
}

resource logAnalyticsWorkspaceName_windowsPerfCounter4 'Microsoft.OperationalInsights/workspaces/datasources@2015-11-01-preview' = {
  parent: logAnalyticsWorkspace
  name: 'windowsPerfCounter4'
  kind: 'WindowsPerformanceCounter'
  properties: {
    objectName: 'Processor'
    instanceName: '*'
    intervalSeconds: 60
    counterName: 'Processor Frequency'
  }
}

resource logAnalyticsWorkspaceName_windowsPerfCounter5 'Microsoft.OperationalInsights/workspaces/datasources@2015-11-01-preview' = {
  parent: logAnalyticsWorkspace
  name: 'windowsPerfCounter5'
  kind: 'WindowsPerformanceCounter'
  properties: {
    objectName: 'Process'
    instanceName: '*'
    intervalSeconds: 60
    counterName: 'Thread Count'
  }
}

resource logAnalyticsWorkspaceName_windowsPerfCounter6 'Microsoft.OperationalInsights/workspaces/datasources@2015-11-01-preview' = {
  parent: logAnalyticsWorkspace
  name: 'windowsPerfCounter6'
  kind: 'WindowsPerformanceCounter'
  properties: {
    objectName: 'Process'
    instanceName: '*'
    intervalSeconds: 60
    counterName: 'Handle Count'
  }
}

resource logAnalyticsWorkspaceName_windowsPerfCounter7 'Microsoft.OperationalInsights/workspaces/datasources@2015-11-01-preview' = {
  parent: logAnalyticsWorkspace
  name: 'windowsPerfCounter7'
  kind: 'WindowsPerformanceCounter'
  properties: {
    objectName: 'System'
    instanceName: '*'
    intervalSeconds: 60
    counterName: 'System Up Time'
  }
}

resource logAnalyticsWorkspaceName_windowsPerfCounter8 'Microsoft.OperationalInsights/workspaces/datasources@2015-11-01-preview' = {
  parent: logAnalyticsWorkspace
  name: 'windowsPerfCounter8'
  kind: 'WindowsPerformanceCounter'
  properties: {
    objectName: 'System'
    instanceName: '*'
    intervalSeconds: 60
    counterName: 'Context Switches/sec'
  }
}

resource logAnalyticsWorkspaceName_windowsPerfCounter9 'Microsoft.OperationalInsights/workspaces/datasources@2015-11-01-preview' = {
  parent: logAnalyticsWorkspace
  name: 'windowsPerfCounter9'
  kind: 'WindowsPerformanceCounter'
  properties: {
    objectName: 'System'
    instanceName: '*'
    intervalSeconds: 60
    counterName: 'Processor Queue Length'
  }
}

resource logAnalyticsWorkspaceName_windowsPerfCounter10 'Microsoft.OperationalInsights/workspaces/datasources@2015-11-01-preview' = {
  parent: logAnalyticsWorkspace
  name: 'windowsPerfCounter10'
  kind: 'WindowsPerformanceCounter'
  properties: {
    objectName: 'System'
    instanceName: '*'
    intervalSeconds: 60
    counterName: 'Processes'
  }
}

resource logAnalyticsWorkspaceName_windowsPerfCounter11 'Microsoft.OperationalInsights/workspaces/datasources@2015-11-01-preview' = {
  parent: logAnalyticsWorkspace
  name: 'windowsPerfCounter11'
  kind: 'WindowsPerformanceCounter'
  properties: {
    objectName: 'Memory'
    instanceName: '*'
    intervalSeconds: 60
    counterName: '% Committed Bytes In Use'
  }
}

resource logAnalyticsWorkspaceName_windowsPerfCounter12 'Microsoft.OperationalInsights/workspaces/datasources@2015-11-01-preview' = {
  parent: logAnalyticsWorkspace
  name: 'windowsPerfCounter12'
  kind: 'WindowsPerformanceCounter'
  properties: {
    objectName: 'Memory'
    instanceName: '*'
    intervalSeconds: 60
    counterName: 'Available MBytes'
  }
}

resource logAnalyticsWorkspaceName_windowsPerfCounter13 'Microsoft.OperationalInsights/workspaces/datasources@2015-11-01-preview' = {
  parent: logAnalyticsWorkspace
  name: 'windowsPerfCounter13'
  kind: 'WindowsPerformanceCounter'
  properties: {
    objectName: 'Memory'
    instanceName: '*'
    intervalSeconds: 60
    counterName: 'Available Bytes'
  }
}

resource logAnalyticsWorkspaceName_windowsPerfCounter14 'Microsoft.OperationalInsights/workspaces/datasources@2015-11-01-preview' = {
  parent: logAnalyticsWorkspace
  name: 'windowsPerfCounter14'
  kind: 'WindowsPerformanceCounter'
  properties: {
    objectName: 'Memory'
    instanceName: '*'
    intervalSeconds: 60
    counterName: 'Committed Bytes'
  }
}

resource logAnalyticsWorkspaceName_windowsPerfCounter15 'Microsoft.OperationalInsights/workspaces/datasources@2015-11-01-preview' = {
  parent: logAnalyticsWorkspace
  name: 'windowsPerfCounter15'
  kind: 'WindowsPerformanceCounter'
  properties: {
    objectName: 'Memory'
    instanceName: '*'
    intervalSeconds: 60
    counterName: 'Cache Bytes'
  }
}

resource logAnalyticsWorkspaceName_windowsPerfCounter16 'Microsoft.OperationalInsights/workspaces/datasources@2015-11-01-preview' = {
  parent: logAnalyticsWorkspace
  name: 'windowsPerfCounter16'
  kind: 'WindowsPerformanceCounter'
  properties: {
    objectName: 'Memory'
    instanceName: '*'
    intervalSeconds: 60
    counterName: 'Pool Paged Bytes'
  }
}

resource logAnalyticsWorkspaceName_windowsPerfCounter17 'Microsoft.OperationalInsights/workspaces/datasources@2015-11-01-preview' = {
  parent: logAnalyticsWorkspace
  name: 'windowsPerfCounter17'
  kind: 'WindowsPerformanceCounter'
  properties: {
    objectName: 'Memory'
    instanceName: '*'
    intervalSeconds: 60
    counterName: 'Pool Nonpaged Bytes'
  }
}

resource logAnalyticsWorkspaceName_windowsPerfCounter18 'Microsoft.OperationalInsights/workspaces/datasources@2015-11-01-preview' = {
  parent: logAnalyticsWorkspace
  name: 'windowsPerfCounter18'
  kind: 'WindowsPerformanceCounter'
  properties: {
    objectName: 'Memory'
    instanceName: '*'
    intervalSeconds: 60
    counterName: 'Pages/sec'
  }
}

resource logAnalyticsWorkspaceName_windowsPerfCounter19 'Microsoft.OperationalInsights/workspaces/datasources@2015-11-01-preview' = {
  parent: logAnalyticsWorkspace
  name: 'windowsPerfCounter19'
  kind: 'WindowsPerformanceCounter'
  properties: {
    objectName: 'Memory'
    instanceName: '*'
    intervalSeconds: 60
    counterName: 'Page Faults/sec'
  }
}

resource logAnalyticsWorkspaceName_windowsPerfCounter20 'Microsoft.OperationalInsights/workspaces/datasources@2015-11-01-preview' = {
  parent: logAnalyticsWorkspace
  name: 'windowsPerfCounter20'
  kind: 'WindowsPerformanceCounter'
  properties: {
    objectName: 'Process'
    instanceName: '*'
    intervalSeconds: 60
    counterName: 'Working Set'
  }
}

resource logAnalyticsWorkspaceName_windowsPerfCounter21 'Microsoft.OperationalInsights/workspaces/datasources@2015-11-01-preview' = {
  parent: logAnalyticsWorkspace
  name: 'windowsPerfCounter21'
  kind: 'WindowsPerformanceCounter'
  properties: {
    objectName: 'Process'
    instanceName: '*'
    intervalSeconds: 60
    counterName: 'Working Set - Private'
  }
}

resource logAnalyticsWorkspaceName_windowsPerfCounter22 'Microsoft.OperationalInsights/workspaces/datasources@2015-11-01-preview' = {
  parent: logAnalyticsWorkspace
  name: 'windowsPerfCounter22'
  kind: 'WindowsPerformanceCounter'
  properties: {
    objectName: 'LogicalDisk'
    instanceName: '*'
    intervalSeconds: 60
    counterName: '% Disk Time'
  }
}

resource logAnalyticsWorkspaceName_windowsPerfCounter23 'Microsoft.OperationalInsights/workspaces/datasources@2015-11-01-preview' = {
  parent: logAnalyticsWorkspace
  name: 'windowsPerfCounter23'
  kind: 'WindowsPerformanceCounter'
  properties: {
    objectName: 'LogicalDisk'
    instanceName: '*'
    intervalSeconds: 60
    counterName: '% Disk Read Time'
  }
}

resource logAnalyticsWorkspaceName_windowsPerfCounter24 'Microsoft.OperationalInsights/workspaces/datasources@2015-11-01-preview' = {
  parent: logAnalyticsWorkspace
  name: 'windowsPerfCounter24'
  kind: 'WindowsPerformanceCounter'
  properties: {
    objectName: 'LogicalDisk'
    instanceName: '*'
    intervalSeconds: 60
    counterName: '% Disk Write Time'
  }
}

resource logAnalyticsWorkspaceName_windowsPerfCounter25 'Microsoft.OperationalInsights/workspaces/datasources@2015-11-01-preview' = {
  parent: logAnalyticsWorkspace
  name: 'windowsPerfCounter25'
  kind: 'WindowsPerformanceCounter'
  properties: {
    objectName: 'LogicalDisk'
    instanceName: '*'
    intervalSeconds: 60
    counterName: '% Idle Time'
  }
}

resource logAnalyticsWorkspaceName_windowsPerfCounter26 'Microsoft.OperationalInsights/workspaces/datasources@2015-11-01-preview' = {
  parent: logAnalyticsWorkspace
  name: 'windowsPerfCounter26'
  kind: 'WindowsPerformanceCounter'
  properties: {
    objectName: 'LogicalDisk'
    instanceName: '*'
    intervalSeconds: 60
    counterName: 'Disk Bytes/sec'
  }
}

resource logAnalyticsWorkspaceName_windowsPerfCounter27 'Microsoft.OperationalInsights/workspaces/datasources@2015-11-01-preview' = {
  parent: logAnalyticsWorkspace
  name: 'windowsPerfCounter27'
  kind: 'WindowsPerformanceCounter'
  properties: {
    objectName: 'LogicalDisk'
    instanceName: '*'
    intervalSeconds: 60
    counterName: 'Disk Read Bytes/sec'
  }
}

resource logAnalyticsWorkspaceName_windowsPerfCounter28 'Microsoft.OperationalInsights/workspaces/datasources@2015-11-01-preview' = {
  parent: logAnalyticsWorkspace
  name: 'windowsPerfCounter28'
  kind: 'WindowsPerformanceCounter'
  properties: {
    objectName: 'LogicalDisk'
    instanceName: '*'
    intervalSeconds: 60
    counterName: 'Disk Write Bytes/sec'
  }
}

resource logAnalyticsWorkspaceName_windowsPerfCounter29 'Microsoft.OperationalInsights/workspaces/datasources@2015-11-01-preview' = {
  parent: logAnalyticsWorkspace
  name: 'windowsPerfCounter29'
  kind: 'WindowsPerformanceCounter'
  properties: {
    objectName: 'LogicalDisk'
    instanceName: '*'
    intervalSeconds: 60
    counterName: 'Disk Transfers/sec'
  }
}

resource logAnalyticsWorkspaceName_windowsPerfCounter30 'Microsoft.OperationalInsights/workspaces/datasources@2015-11-01-preview' = {
  parent: logAnalyticsWorkspace
  name: 'windowsPerfCounter30'
  kind: 'WindowsPerformanceCounter'
  properties: {
    objectName: 'LogicalDisk'
    instanceName: '*'
    intervalSeconds: 60
    counterName: 'Disk Reads/sec'
  }
}

resource logAnalyticsWorkspaceName_windowsPerfCounter31 'Microsoft.OperationalInsights/workspaces/datasources@2015-11-01-preview' = {
  parent: logAnalyticsWorkspace
  name: 'windowsPerfCounter31'
  kind: 'WindowsPerformanceCounter'
  properties: {
    objectName: 'LogicalDisk'
    instanceName: '*'
    intervalSeconds: 60
    counterName: 'Disk Writes/sec'
  }
}

resource logAnalyticsWorkspaceName_windowsPerfCounter32 'Microsoft.OperationalInsights/workspaces/datasources@2015-11-01-preview' = {
  parent: logAnalyticsWorkspace
  name: 'windowsPerfCounter32'
  kind: 'WindowsPerformanceCounter'
  properties: {
    objectName: 'LogicalDisk'
    instanceName: '*'
    intervalSeconds: 60
    counterName: 'Avg. Disk sec/Transfer'
  }
}

resource logAnalyticsWorkspaceName_windowsPerfCounter33 'Microsoft.OperationalInsights/workspaces/datasources@2015-11-01-preview' = {
  parent: logAnalyticsWorkspace
  name: 'windowsPerfCounter33'
  kind: 'WindowsPerformanceCounter'
  properties: {
    objectName: 'LogicalDisk'
    instanceName: '*'
    intervalSeconds: 60
    counterName: 'Avg. Disk sec/Read'
  }
}

resource logAnalyticsWorkspaceName_windowsPerfCounter34 'Microsoft.OperationalInsights/workspaces/datasources@2015-11-01-preview' = {
  parent: logAnalyticsWorkspace
  name: 'windowsPerfCounter34'
  kind: 'WindowsPerformanceCounter'
  properties: {
    objectName: 'LogicalDisk'
    instanceName: '*'
    intervalSeconds: 60
    counterName: 'Avg. Disk sec/Write'
  }
}

resource logAnalyticsWorkspaceName_windowsPerfCounter35 'Microsoft.OperationalInsights/workspaces/datasources@2015-11-01-preview' = {
  parent: logAnalyticsWorkspace
  name: 'windowsPerfCounter35'
  kind: 'WindowsPerformanceCounter'
  properties: {
    objectName: 'LogicalDisk'
    instanceName: '*'
    intervalSeconds: 60
    counterName: 'Avg. Disk Queue Length'
  }
}

resource logAnalyticsWorkspaceName_windowsPerfCounter36 'Microsoft.OperationalInsights/workspaces/datasources@2015-11-01-preview' = {
  parent: logAnalyticsWorkspace
  name: 'windowsPerfCounter36'
  kind: 'WindowsPerformanceCounter'
  properties: {
    objectName: 'LogicalDisk'
    instanceName: '*'
    intervalSeconds: 60
    counterName: 'Avg. Disk Write Queue Length'
  }
}

resource logAnalyticsWorkspaceName_windowsPerfCounter37 'Microsoft.OperationalInsights/workspaces/datasources@2015-11-01-preview' = {
  parent: logAnalyticsWorkspace
  name: 'windowsPerfCounter37'
  kind: 'WindowsPerformanceCounter'
  properties: {
    objectName: 'LogicalDisk'
    instanceName: '*'
    intervalSeconds: 60
    counterName: '% Free Space'
  }
}

resource logAnalyticsWorkspaceName_windowsPerfCounter38 'Microsoft.OperationalInsights/workspaces/datasources@2015-11-01-preview' = {
  parent: logAnalyticsWorkspace
  name: 'windowsPerfCounter38'
  kind: 'WindowsPerformanceCounter'
  properties: {
    objectName: 'LogicalDisk'
    instanceName: '*'
    intervalSeconds: 60
    counterName: 'Free Megabytes'
  }
}

resource logAnalyticsWorkspaceName_windowsPerfCounter39 'Microsoft.OperationalInsights/workspaces/datasources@2015-11-01-preview' = {
  parent: logAnalyticsWorkspace
  name: 'windowsPerfCounter39'
  kind: 'WindowsPerformanceCounter'
  properties: {
    objectName: 'Network Interface'
    instanceName: '*'
    intervalSeconds: 60
    counterName: 'Bytes Total/sec'
  }
}

resource logAnalyticsWorkspaceName_windowsPerfCounter40 'Microsoft.OperationalInsights/workspaces/datasources@2015-11-01-preview' = {
  parent: logAnalyticsWorkspace
  name: 'windowsPerfCounter40'
  kind: 'WindowsPerformanceCounter'
  properties: {
    objectName: 'Network Interface'
    instanceName: '*'
    intervalSeconds: 60
    counterName: 'Bytes Sent/sec'
  }
}

resource logAnalyticsWorkspaceName_windowsPerfCounter41 'Microsoft.OperationalInsights/workspaces/datasources@2015-11-01-preview' = {
  parent: logAnalyticsWorkspace
  name: 'windowsPerfCounter41'
  kind: 'WindowsPerformanceCounter'
  properties: {
    objectName: 'Network Interface'
    instanceName: '*'
    intervalSeconds: 60
    counterName: 'Bytes Received/sec'
  }
}

resource logAnalyticsWorkspaceName_windowsPerfCounter42 'Microsoft.OperationalInsights/workspaces/datasources@2015-11-01-preview' = {
  parent: logAnalyticsWorkspace
  name: 'windowsPerfCounter42'
  kind: 'WindowsPerformanceCounter'
  properties: {
    objectName: 'Network Interface'
    instanceName: '*'
    intervalSeconds: 60
    counterName: 'Packets/sec'
  }
}

resource logAnalyticsWorkspaceName_windowsPerfCounter43 'Microsoft.OperationalInsights/workspaces/datasources@2015-11-01-preview' = {
  parent: logAnalyticsWorkspace
  name: 'windowsPerfCounter43'
  kind: 'WindowsPerformanceCounter'
  properties: {
    objectName: 'Network Interface'
    instanceName: '*'
    intervalSeconds: 60
    counterName: 'Packets Sent/sec'
  }
}

resource logAnalyticsWorkspaceName_windowsPerfCounter44 'Microsoft.OperationalInsights/workspaces/datasources@2015-11-01-preview' = {
  parent: logAnalyticsWorkspace
  name: 'windowsPerfCounter44'
  kind: 'WindowsPerformanceCounter'
  properties: {
    objectName: 'Network Interface'
    instanceName: '*'
    intervalSeconds: 60
    counterName: 'Packets Received/sec'
  }
}

resource logAnalyticsWorkspaceName_windowsPerfCounter45 'Microsoft.OperationalInsights/workspaces/datasources@2015-11-01-preview' = {
  parent: logAnalyticsWorkspace
  name: 'windowsPerfCounter45'
  kind: 'WindowsPerformanceCounter'
  properties: {
    objectName: 'Network Interface'
    instanceName: '*'
    intervalSeconds: 60
    counterName: 'Packets Outbound Errors'
  }
}

resource logAnalyticsWorkspaceName_windowsPerfCounter46 'Microsoft.OperationalInsights/workspaces/datasources@2015-11-01-preview' = {
  parent: logAnalyticsWorkspace
  name: 'windowsPerfCounter46'
  kind: 'WindowsPerformanceCounter'
  properties: {
    objectName: 'Network Interface'
    instanceName: '*'
    intervalSeconds: 60
    counterName: 'Packets Received Errors'
  }
}

resource logAnalyticsWorkspaceName_sampleIISLog1 'Microsoft.OperationalInsights/workspaces/datasources@2015-11-01-preview' = if (false) {
  parent: logAnalyticsWorkspace
  name: 'sampleIISLog1'
  kind: 'IISLogs'
  properties: {
    state: 'OnPremiseEnabled'
  }
}

resource logAnalyticsWorkspaceName_sampleSyslog1 'Microsoft.OperationalInsights/workspaces/datasources@2015-11-01-preview' = {
  parent: logAnalyticsWorkspace
  name: 'sampleSyslog1'
  kind: 'LinuxSyslog'
  properties: {
    syslogName: 'kern'
    syslogSeverities: [
      {
        severity: 'emerg'
      }
      {
        severity: 'alert'
      }
      {
        severity: 'crit'
      }
      {
        severity: 'err'
      }
      {
        severity: 'warning'
      }
    ]
  }
}

resource logAnalyticsWorkspaceName_sampleSyslogCollection1 'Microsoft.OperationalInsights/workspaces/datasources@2015-11-01-preview' = {
  parent: logAnalyticsWorkspace
  name: 'sampleSyslogCollection1'
  kind: 'LinuxSyslogCollection'
  properties: {
    state: 'Enabled'
  }
}

resource logAnalyticsWorkspaceName_sampleLinuxPerf1 'Microsoft.OperationalInsights/workspaces/datasources@2015-11-01-preview' = {
  parent: logAnalyticsWorkspace
  name: 'sampleLinuxPerf1'
  kind: 'LinuxPerformanceObject'
  properties: {
    performanceCounters: [
      {
        counterName: '% Used Inodes'
      }
      {
        counterName: 'Free Megabytes'
      }
      {
        counterName: '% Used Space'
      }
      {
        counterName: 'Disk Transfers/sec'
      }
      {
        counterName: 'Disk Reads/sec'
      }
      {
        counterName: 'Disk Writes/sec'
      }
    ]
    objectName: 'Logical Disk'
    instanceName: '*'
    intervalSeconds: 10
  }
}

resource logAnalyticsWorkspaceName_sampleLinuxPerfCollection1 'Microsoft.OperationalInsights/workspaces/datasources@2015-11-01-preview' = {
  parent: logAnalyticsWorkspace
  name: 'sampleLinuxPerfCollection1'
  kind: 'LinuxPerformanceCollection'
  properties: {
    state: 'Enabled'
  }
}

resource logAnalyticsWorkspaceName_diagnosticStorageAccount 'Microsoft.OperationalInsights/workspaces/storageinsightconfigs@2015-03-20' = if ((!empty(diagnosticStorageAccountName)) && (!empty(diagnosticStorageAccountId)) && (!empty(diagnosticStorageAccountAccessKey))) {
  parent: logAnalyticsWorkspace
  name: '${diagnosticStorageAccountName}'
  properties: {
    containers: []
    tables: [
      'WADWindowsEventLogsTable'
      'WADETWEventTable'
      'WADServiceFabric*EventTable'
      'LinuxsyslogVer2v0'
    ]
    storageAccount: {
      id: diagnosticStorageAccountId
      key: diagnosticStorageAccountAccessKey
    }
  }
}

@batchSize(1)
resource solutions_name 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = [for item in solutions: {
  name: concat(item.name)
  location: location
  properties: {
    workspaceResourceId: logAnalyticsWorkspace.id
  }
  plan: {
    name: item.name
    product: 'OMSGallery/${item.galleryName}'
    promotionCode: ''
    publisher: 'Microsoft'
  }
  dependsOn: [
    logAnalyticsWorkspace
  ]
}]

resource logAnalyticsWorkspaceName_Automation 'Microsoft.OperationalInsights/workspaces/linkedServices@2015-11-01-preview' = if (!empty(automationAccountId)) {
  parent: logAnalyticsWorkspace
  name: 'Automation'
  location: location
  properties: {
    resourceId: automationAccountId
  }
}

resource logAnalyticsWorkspaceName_Microsoft_Authorization_logAnalyticsDoNotDelete 'Microsoft.OperationalInsights/workspaces/providers/locks@2016-09-01' = {
  name: '${logAnalyticsWorkspaceName}/Microsoft.Authorization/logAnalyticsDoNotDelete'
  properties: {
    level: 'CannotDelete'
  }
  dependsOn: [
    logAnalyticsWorkspace
  ]
}

resource azureSentinelSolution 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = if (bool(azureSentinel)) {
  name: azureSentinelSolutionName
  location: location
  plan: {
    name: azureSentinelSolutionName
    promotionCode: ''
    product: product
    publisher: publisher
  }
  properties: {
    workspaceResourceId: logAnalyticsWorkspace.id
  }
}

@description('The Resource Id of the Log Analytics workspace deployed.')
output logAnalyticsWorkspaceResourceId string = logAnalyticsWorkspace.id
@description('The Resource Group log analytics was deployed to.')
output logAnalyticsWorkspaceResourceGroup string = resourceGroup().name
@description('The Name of the Log Analytics workspace deployed.')
output logAnalyticsWorkspaceName string = logAnalyticsWorkspaceName
@description('The Workspace Id for Log Analytics.')
output logAnalyticsWorkspaceId string = reference(logAnalyticsWorkspace.id, '2015-03-20').customerId
@description('The Primary Shared Key for Log Analytics.')
output logAnalyticsPrimarySharedKey string = listKeys(logAnalyticsWorkspace.id, '2015-03-20').primarySharedKey