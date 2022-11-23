@description('The kind of data connectors that can be deployed via ARM templates: ["AmazonWebServicesCloudTrail", "AzureActivityLog", "AzureAdvancedThreatProtection", "AzureSecurityCenter", "MicrosoftCloudAppSecurity", "MicrosoftDefenderAdvancedThreatProtection", "Office365", "ThreatIntelligence"]')
param dataConnectors array = []

@description('Name for the Log Analytics workspace used to aggregate data')
param workspaceName string

@description('Sbscription Id to monitor')
param subscriptionId string

resource loga 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' existing = {
  name: workspaceName
}

resource logaOnboardingStatus 'Microsoft.SecurityInsights/onboardingStates@2022-08-01' existing = {
  scope: loga
  name: workspaceName
}

// Defender for Cloud
// (Formerly Azure Security Center)
// Enabled through Defender for Cloud Bicep code
resource ascDataConnector 'Microsoft.SecurityInsights/dataConnectors@2022-08-01' = if (contains(dataConnectors, 'AzureSecurityCenter')) {
  name: 'AzureSecurityCenter-Microsoft.SecurityInsights-${workspaceName}'
  scope: loga
  kind: 'AzureSecurityCenter'
  dependsOn: [
    logaOnboardingStatus
  ]
  properties: {
    dataTypes: {
      alerts: {
        state: 'enabled'
      }
    }
    subscriptionId: subscriptionId
  }
}


/*
var sources = {
  AmazonWebServicesCloudTrail: {
    kind: 'AmazonWebServicesCloudTrail'
    properties: {
      dataTypes: {
        logs: {
          state: 'enabled'
        }
      }
    }
  }
  AzureActiveDirectory: {
    kind: 'AzureActiveDirectory'
    properties: {
      dataTypes: {
        alerts: {
          state: 'enabled'
        }
      }
      tenantId: tenantId
    }
  }
  AzureAdvancedThreatProtection: {
    kind: 'AzureAdvancedThreatProtection'
    properties: {
      dataTypes: {
        alerts: {
          state: 'enabled'
        }
      }
      tenantId: tenantId
    }
  }
  AzureSecurityCenter: {
    kind: 'AzureSecurityCenter'
    properties: {
      dataTypes: {
        alerts: {
          state: 'enabled'
        }
      }
      subscriptionId: subscriptionId
    }
  }
  MicrosoftCloudAppSecurity: {
    kind: 'MicrosoftCloudAppSecurity'
    properties: {
      dataTypes: {
        alerts: {
          state: 'enabled'
        }
        discoveryLogs: {
          state: 'enabled'
        }
      }
      tenantId: tenantId
    }
  }
  MicrosoftDefenderAdvancedThreatProtection: {
    kind: 'MicrosoftDefenderAdvancedThreatProtection'
    properties: {
      dataTypes: {
        alerts: {
          state: 'enabled'
        }
      }
      tenantId: tenantId
    }
  }
  office365: {
    kind: 'Office365'
    properties: {
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
      tenantId: tenantId
    }
  }
  ThreatIntelligence: {
    kind: 'ThreatIntelligence'
    properties: {
      dataTypes: {
        indicators: {
          state: 'string'
        }
      }
      tenantId: tenantId
      tipLookbackPeriod: '60'
    }
  }
}

resource deployDataConnectors 'Microsoft.SecurityInsights/dataConnectors@2022-08-01' = [for (dataConnector, index) in dataConnectors: if (!empty(dataConnectors)) {
  name: '${dataConnector}/Microsoft.SecurityInsights/${workspaceName}'
  scope: loga
  kind: contains(sources, dataConnector) ? sources[dataConnector].kind : ''
  dependsOn: [
    logaOnboardingStatus
  ]
  properties: contains(sources, dataConnector) ? sources[dataConnector].properties : ''
}]
*/
