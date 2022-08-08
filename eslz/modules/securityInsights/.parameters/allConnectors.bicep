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

@description('Tier for gathering Windows Security Events.')
@allowed([
  'All'
  'Recommended'
  'Minimal'
  'None'
])
param securityCollectionTier string = 'Minimal'

@description('Connect Microsoft 365 Defender​ incidents to your Microsoft Sentinel. Incidents will appear in the incidents queue')
param connectM365Incidents bool = false

@description('Location for all resources.')
param location string = resourceGroup().location

var m365DefenderName = 'm365defender${uniqueString(resourceGroup().id)}'
var o365Name = 'o365${uniqueString(resourceGroup().id)}'
var officeATPName = 'oatp${uniqueString(resourceGroup().id)}'
var threatIntelligenceName = 'ti${uniqueString(resourceGroup().id)}'
var mdatpName = 'mdatp${uniqueString(resourceGroup().id)}'
var aatpName = 'aatp${uniqueString(resourceGroup().id)}'
var ascName = 'asc${uniqueString(resourceGroup().id)}'
var mcasName = 'mcas${uniqueString(resourceGroup().id)}'
var aadipName = 'aadip${uniqueString(resourceGroup().id)}'

/*
resource workspaceName_subscriptionId 'Microsoft.OperationalInsights/workspaces/dataSources@2020-03-01-preview' = if (contains(dataConnectors, 'AzureActivityLog')) {
  location: location
  name: '${workspaceName}/${replace(subscriptionId, '-', '')}'
  kind: 'AzureActivityLog'
  properties: {
    linkedResourceId: '/subscriptions/${subscriptionId}/providers/microsoft.insights/eventtypes/management'
  }
}
*/

resource workspaceName_SecurityInsightsSecurityEventCollectionConfiguration 'Microsoft.OperationalInsights/workspaces/dataSources@2020-03-01-preview' = if (contains(dataConnectors, 'SecurityEvents')) {
  location: location
  name: '${workspaceName}/SecurityInsightsSecurityEventCollectionConfiguration'
  kind: 'SecurityInsightsSecurityEventCollectionConfiguration'
  properties: {
    tier: securityCollectionTier
    tierSetMethod: 'Custom'
  }
}

resource WindowsFirewall_workspaceName 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = if (contains(dataConnectors, 'WindowsFirewall')) {
  name: 'WindowsFirewall(${workspaceName})'
  location: location
  plan: {
    name: 'WindowsFirewall(${workspaceName})'
    promotionCode: ''
    product: 'OMSGallery/WindowsFirewall'
    publisher: 'Microsoft'
  }
  properties: {
    workspaceResourceId: workspaceId
    containedResources: []
  }
}

resource DnsAnalytics_workspaceName 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = if (contains(dataConnectors, 'DnsAnalytics')) {
  name: 'DnsAnalytics(${workspaceName})'
  location: location
  plan: {
    name: 'DnsAnalytics(${workspaceName})'
    promotionCode: ''
    product: 'OMSGallery/DnsAnalytics'
    publisher: 'Microsoft'
  }
  properties: {
    workspaceResourceId: workspaceId
    containedResources: []
  }
}

resource workspaceName_syslogCollection 'Microsoft.OperationalInsights/workspaces/dataSources@2020-08-01' = if (contains(dataConnectors, 'LinuxSyslogCollection')) {
  location: location
  name: '${workspaceName}/syslogCollection'
  kind: 'LinuxSyslogCollection'
  properties: {
    state: 'Enabled'
  }
}

resource workspaceName_Microsoft_SecurityInsights_m365DefenderName 'Microsoft.OperationalInsights/workspaces/providers/dataConnectors@2019-01-01-preview' = if (connectM365Incidents || contains(dataConnectors, 'MicrosoftThreatProtection')) {
  location: location
  name: '${workspaceName}/Microsoft.SecurityInsights/${m365DefenderName}'
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

resource workspaceName_Microsoft_SecurityInsights_o365Name 'Microsoft.OperationalInsights/workspaces/providers/dataConnectors@2020-01-01' = if (contains(dataConnectors, 'Office365')) {
  location: location
  name: '${workspaceName}/Microsoft.SecurityInsights/${o365Name}'
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

resource workspaceName_Microsoft_SecurityInsights_officeATPName 'Microsoft.OperationalInsights/workspaces/providers/dataConnectors@2019-01-01-preview' = if (contains(dataConnectors, 'OfficeATP') || contains(dataConnectors, 'MicrosoftThreatProtection')) {
  location: location
  name: '${workspaceName}/Microsoft.SecurityInsights/${officeATPName}'
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

resource workspaceName_Microsoft_SecurityInsights_threatIntelligenceName 'Microsoft.OperationalInsights/workspaces/providers/dataConnectors@2020-01-01' = if (contains(dataConnectors, 'ThreatIntelligence')) {
  location: location
  name: '${workspaceName}/Microsoft.SecurityInsights/${threatIntelligenceName}'
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

resource workspaceName_Microsoft_SecurityInsights_mdatpName 'Microsoft.OperationalInsights/workspaces/providers/dataConnectors@2019-01-01-preview' = if (contains(dataConnectors, 'MicrosoftDefenderAdvancedThreatProtection') || contains(dataConnectors, 'MicrosoftThreatProtection')) {
  location: location
  name: '${workspaceName}/Microsoft.SecurityInsights/${mdatpName}'
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

resource workspaceName_Microsoft_SecurityInsights_mcasName 'Microsoft.OperationalInsights/workspaces/providers/dataConnectors@2020-01-01' = if (contains(dataConnectors, 'MicrosoftCloudAppSecurity') || contains(dataConnectors, 'MicrosoftThreatProtection')) {
  location: location
  name: '${workspaceName}/Microsoft.SecurityInsights/${mcasName}'
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

resource workspaceName_Microsoft_SecurityInsights_ascName 'Microsoft.OperationalInsights/workspaces/providers/dataConnectors@2020-01-01' = if (contains(dataConnectors, 'AzureSecurityCenter')) {
  location: location
  name: '${workspaceName}/Microsoft.SecurityInsights/${ascName}'
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

resource workspaceName_Microsoft_SecurityInsights_aatpName 'Microsoft.OperationalInsights/workspaces/providers/dataConnectors@2020-01-01' = if (contains(dataConnectors, 'AzureAdvancedThreatProtection') || contains(dataConnectors, 'MicrosoftThreatProtection')) {
  location: location
  name: '${workspaceName}/Microsoft.SecurityInsights/${aatpName}'
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

resource workspaceName_Microsoft_SecurityInsights_aadipName 'Microsoft.OperationalInsights/workspaces/providers/dataConnectors@2020-01-01' = if (contains(dataConnectors, 'AzureActiveDirectoryIdentityProtection')) {
  location: location
  name: '${workspaceName}/Microsoft.SecurityInsights/${aadipName}'
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
