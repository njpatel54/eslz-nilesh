//targetScope = 'subscription'

@description('The kind of data connectors that can be deployed via ARM templates: ["AzureActivityLog","SecurityEvents","WindowsFirewall","DnsAnalytics"]')
param dataConnectors array = []

@description('Name for the Log Analytics workspace used to aggregate data')
param workspaceName string

@description('Log Analytics workspace ID')
param workspaceId string = ''

@description('Sbscription Id to monitor')
param subscriptionId string = subscription().subscriptionId

@description('Azure AD tenant ID')
param tenantId string = subscription().tenantId

@description('Connect Microsoft 365 Defender incidents to your Microsoft Sentinel. Incidents will appear in the incidents queue')
param connectM365Incidents bool = false

var m365DefenderName = 'm365defender${uniqueString(resourceGroup().id)}'
var o365Name = 'o365${uniqueString(resourceGroup().id)}'
var officeATPName = 'oatp${uniqueString(resourceGroup().id)}'
var threatIntelligenceName = 'ti${uniqueString(resourceGroup().id)}'
var mdatpName = 'mdatp${uniqueString(resourceGroup().id)}'
var aatpName = 'aatp${uniqueString(resourceGroup().id)}'
var ascName = 'asc${uniqueString(resourceGroup().id)}'
var mcasName = 'mcas${uniqueString(resourceGroup().id)}'
var aadipName = 'aadip${uniqueString(resourceGroup().id)}'

@description('Required. Project Owner (projowner) parameter.')
@allowed([
  'ccs'
  'proj'
])
param projowner string = 'ccs'

@description('Required. Operational Scope (opscope) parameter.')
@allowed([
  'prod'
  'dev'
  'qa'
  'stage'
  'test'
  'sand'
])
param opscope string = 'prod'

@description('Required. Region (region) parameter.')
@allowed([
  'usva'
  'ustx'
  'usaz'
])
param region string = 'usva'
/*
@description('Required. Subscription ID of Management Subscription.')
param mgmtsubid string

@description('Required. SIEM Resource Group Name.')
param siemRgName string = 'rg-${projowner}-${opscope}-${region}-siem'


@description('Required. Log Ananlytics Workspace Name for Azure Sentinel.')
param sentinelLawName string = 'log-${projowner}-${opscope}-${region}-siem'

resource logaSentinel 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' existing = {
  //scope:  resourceGroup(mgmtsubid, siemRgName)
  name: sentinelLawName
  id: resourceId(mgmtsubid, siemRgName, 'Microsoft.OperationalInsights/workspaces', sentinelLawName)
}
*/

param logaSentinel string 

resource workspaceName_Microsoft_SecurityInsights_m365DefenderName 'Microsoft.SecurityInsights/dataConnectors@2022-07-01-preview' = if (connectM365Incidents || contains(dataConnectors, 'MicrosoftThreatProtection')) {
  name: '${workspaceName}-Microsoft.SecurityInsights-${m365DefenderName}'
  scope: resource
  kind: 'MicrosoftThreatProtection'
  properties: {
    tenantId: tenantId
    dataTypes: {
      incidents: {
        state: 'enabled'
      }
    }
  }
}

resource workspaceName_Microsoft_SecurityInsights_o365Name 'Microsoft.SecurityInsights/dataConnectors@2022-07-01-preview' = if (contains(dataConnectors, 'Office365')) {
  name: '${workspaceName}-Microsoft.SecurityInsights-${o365Name}'
  scope: logaSentinel
  kind: 'Office365'
  properties: {
    tenantId: tenantId
    dataTypes: {
      exchange: {
        state: 'enabled'
      }
      sharePoint: {
        state: 'enabled'
      }
      teams: {
        state: 'enabled'
      }
    }
  }
}

resource workspaceName_Microsoft_SecurityInsights_officeATPName 'Microsoft.SecurityInsights/dataConnectors@2022-07-01-preview' = if (contains(dataConnectors, 'OfficeATP') || contains(dataConnectors, 'MicrosoftThreatProtection')) {
  name: '${workspaceName}-Microsoft.SecurityInsights-${officeATPName}'
  scope: logaSentinel
  kind: 'OfficeATP'
  properties: {
    tenantId: tenantId
    dataTypes: {
      alerts: {
        state: 'enabled'
      }
    }
  }
}

resource workspaceName_Microsoft_SecurityInsights_threatIntelligenceName 'Microsoft.SecurityInsights/dataConnectors@2022-07-01-preview' = if (contains(dataConnectors, 'ThreatIntelligence')) {
  name: '${workspaceName}-Microsoft.SecurityInsights-${threatIntelligenceName}'
  scope: logaSentinel
  kind: 'ThreatIntelligence'
  properties: {
    tenantId: tenantId
    dataTypes: {
      indicators: {
        state: 'enabled'
      }
    }
  }
}

resource workspaceName_Microsoft_SecurityInsights_mdatpName 'Microsoft.SecurityInsights/dataConnectors@2022-07-01-preview' = if (contains(dataConnectors, 'MicrosoftDefenderAdvancedThreatProtection') || contains(dataConnectors, 'MicrosoftThreatProtection')) {
name: '${workspaceName}-Microsoft.SecurityInsights-${mdatpName}'
scope: logaSentinel
  kind: 'MicrosoftDefenderAdvancedThreatProtection'
  properties: {
    tenantId: tenantId
    dataTypes: {
      alerts: {
        state: 'enabled'
      }
    }
  }
}

resource workspaceName_Microsoft_SecurityInsights_mcasName 'Microsoft.SecurityInsights/dataConnectors@2022-07-01-preview' = if (contains(dataConnectors, 'MicrosoftCloudAppSecurity') || contains(dataConnectors, 'MicrosoftThreatProtection')) {
name: '${workspaceName}-Microsoft.SecurityInsights-${mcasName}'
scope: logaSentinel
  kind: 'MicrosoftCloudAppSecurity'
  properties: {
    tenantId: tenantId
    dataTypes: {
      alerts: {
        state: 'enabled'
      }
      discoveryLogs: {
        state: 'enabled'
      }
    }
  }
}

resource workspaceName_Microsoft_SecurityInsights_ascName 'Microsoft.SecurityInsights/dataConnectors@2022-07-01-preview' = if (contains(dataConnectors, 'AzureSecurityCenter')) {
name: '${workspaceName}-Microsoft.SecurityInsights-${ascName}'
scope: logaSentinel
  kind: 'AzureSecurityCenter'
  properties: {
    subscriptionId: subscriptionId
    dataTypes: {
      alerts: {
        state: 'enabled'
      }
    }
  }
}

resource workspaceName_Microsoft_SecurityInsights_aatpName 'Microsoft.SecurityInsights/dataConnectors@2022-07-01-preview' = if (contains(dataConnectors, 'AzureAdvancedThreatProtection') || contains(dataConnectors, 'MicrosoftThreatProtection')) {
name: '${workspaceName}-Microsoft.SecurityInsights-${aatpName}'
scope: logaSentinel
  kind: 'AzureAdvancedThreatProtection'
  properties: {
    tenantId: tenantId
    dataTypes: {
      alerts: {
        state: 'enabled'
      }
    }
  }
}

resource workspaceName_Microsoft_SecurityInsights_aadipName 'Microsoft.SecurityInsights/dataConnectors@2022-07-01-preview' = if (contains(dataConnectors, 'AzureActiveDirectoryIdentityProtection')) {
name: '${workspaceName}-Microsoft.SecurityInsights-${aadipName}'
scope: logaSentinel
  kind: 'AzureActiveDirectory'
  properties: {
    tenantId: tenantId
    dataTypes: {
      alerts: {
        state: 'enabled'
      }
    }
  }
}




/*

################################################################################
To be used in Microsoft.OperationalInsights/Worspace/deploy.bicep" file
################################################################################
@description('The kind of data connectors that can be deployed via ARM templates: ["AzureActivityLog","SecurityEvents","WindowsFirewall","DnsAnalytics"]')
param dataConnectors array = []

@description('Azure AD tenant ID')
param tenantId string = subscription().tenantId

@description('Connect Microsoft 365 Defender incidents to your Microsoft Sentinel. Incidents will appear in the incidents queue')
param connectM365Incidents bool = false

var m365DefenderName = 'm365defender${uniqueString(resourceGroup().id)}'

resource workspaceName_Microsoft_SecurityInsights_m365DefenderName 'Microsoft.SecurityInsights/dataConnectors@2022-07-01-preview' = if (connectM365Incidents || contains(dataConnectors, 'MicrosoftThreatProtection')) {
  name: '${name}-Microsoft.SecurityInsights-${m365DefenderName}'
  scope: logAnalyticsWorkspace
  kind: 'MicrosoftThreatProtection'
  properties: {
    tenantId: tenantId
    dataTypes: {
      incidents: {
        state: 'enabled'
      }
    }
  }
}
*/
