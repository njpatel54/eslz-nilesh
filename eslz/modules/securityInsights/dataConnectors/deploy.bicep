@description('The kind of data connectors that can be deployed via ARM templates: ["AmazonWebServicesCloudTrail", "AzureActivityLog", "AzureAdvancedThreatProtection", "AzureSecurityCenter", "MicrosoftCloudAppSecurity", "MicrosoftDefenderAdvancedThreatProtection", "Office365", "ThreatIntelligence"]')
param dataConnectors array = []

@description('Name for the Log Analytics workspace used to aggregate data')
param workspaceName string

@description('Sbscription Id to monitor')
param subscriptionId string

@description('Azure AD tenant ID')
param tenantId string = subscription().tenantId

resource loga 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' existing = {
  name: workspaceName
}

resource logaOnboardingStatus 'Microsoft.SecurityInsights/onboardingStates@2022-08-01' existing = {
  scope: loga
  name: workspaceName
}

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

/*
resource deployDataConnectors 'Microsoft.OperationalInsights/workspaces/providers/dataConnectors@2022-10-01' = [for (dataConnector, index) in dataConnectors: if (!empty(dataConnectors)) {
  name: '${dataConnector}/Microsoft.SecurityInsights/${workspaceName}'
  scope: loga
  kind: contains(sources, dataConnector) ? sources[dataConnector].kind : ''
  dependsOn: [
    logaOnboardingStatus
  ]
  properties: contains(sources, dataConnector) ? sources[dataConnector].properties : ''
}]
*/



// Reference for connectors can be found here:
// https://docs.microsoft.com/en-us/azure/templates/microsoft.operationalinsights/workspaces/datasources?tabs=bicep#workspacesdatasources
// Microsoft.SecurityInsights/dataConnectors@2022-08-01


resource awsCloudTrailDataConnector 'Microsoft.OperationalInsights/workspaces/providers/dataConnectors@2022-10-01' = if (contains(dataConnectors, 'AmazonWebServicesCloudTrail')) {
  name: 'AmazonWebServicesCloudTrail-Microsoft.SecurityInsights-${workspaceName}'
  scope: loga
  kind: 'AmazonWebServicesCloudTrail'
  dependsOn: [
    logaOnboardingStatus
  ]
  properties: {
    dataTypes: {
      logs: {
        state: 'enabled'
      }
    }
  }
}

// Azure Active Directory
// Note: commenting out as Azure Active Directory diagnostic settings
// It is being deployed by /eslz/management-services/.scripts/set-aaddiagsettings.ps1

resource aadDataConnector 'Microsoft.OperationalInsights/workspaces/providers/dataConnectors@2022-10-01' = if (contains(dataConnectors, 'AzureActiveDirectory')) {
  name: 'AzureActiveDirectory-Microsoft.SecurityInsights-${workspaceName}'
  scope: loga
  kind: 'AzureActiveDirectory'
  dependsOn: [
    logaOnboardingStatus
  ]
  properties: {
    dataTypes: {
      alerts: {
        state: 'enabled'
      }
    }
    tenantId: tenantId
  }
}

// Defender for Identity
// (Formerly Azure Advanced Threat Protection)

resource aatpDataConnector 'Microsoft.OperationalInsights/workspaces/providers/dataConnectors@2022-10-01' = if (contains(dataConnectors, 'AzureAdvancedThreatProtection')) {
  name: 'AzureAdvancedThreatProtection-Microsoft.SecurityInsights-${workspaceName}'
  scope: loga
  kind: 'AzureAdvancedThreatProtection'
  dependsOn: [
    logaOnboardingStatus
  ]
  properties: {
    dataTypes: {
      alerts: {
        state: 'enabled'
      }
    }
    tenantId: tenantId
  }
}

// Defender for Cloud
// (Formerly Azure Security Center)
// Enabled through Defender for Cloud Bicep code

resource ascDataConnector 'Microsoft.OperationalInsights/workspaces/providers/dataConnectors@2022-10-01' = if (contains(dataConnectors, 'AzureSecurityCenter')) {
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

// Microsoft Cloud App Security (MCAS)
// Note: MCAS not available in Il6

resource mcasDataConnector 'Microsoft.OperationalInsights/workspaces/providers/dataConnectors@2022-10-01' = if (contains(dataConnectors, 'MicrosoftCloudAppSecurity')) {
  name: 'MicrosoftCloudAppSecurity-Microsoft.SecurityInsights-${workspaceName}'
  scope: loga
  kind: 'MicrosoftCloudAppSecurity'
  dependsOn: [
    logaOnboardingStatus
  ]
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

// Defender for Endpoint
// (Formerly Defender Advanced Threat Protection)
// Note: Requires license

resource mdatpDataConnector 'Microsoft.OperationalInsights/workspaces/providers/dataConnectors@2022-10-01' = if (contains(dataConnectors, 'MicrosoftDefenderAdvancedThreatProtection')) {
  name: 'MicrosoftDefenderAdvancedThreatProtection-Microsoft.SecurityInsights-${workspaceName}'
  scope: loga
  kind: 'MicrosoftDefenderAdvancedThreatProtection'
  dependsOn: [
    logaOnboardingStatus
  ]
  properties: {
    dataTypes: {
      alerts: {
        state: 'enabled'
      }
    }
    tenantId: tenantId
  }
}

// Office 365 Logs
// Note: Not available in IL6

resource O365DataConnector 'Microsoft.OperationalInsights/workspaces/providers/dataConnectors@2022-10-01' = if (contains(dataConnectors, 'Office365')) {
  name: 'Office365-Microsoft.SecurityInsights-${workspaceName}'
  scope: loga
  kind: 'Office365'
  dependsOn: [
    logaOnboardingStatus
  ]
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

// Threat Intelligence
// Note: Threat Intelligence connector not available in IL6

resource ThreatIntelligenceDataConnector 'Microsoft.OperationalInsights/workspaces/providers/dataConnectors@2022-10-01' = if (contains(dataConnectors, 'ThreatIntelligence')) {
  name: 'ThreatIntelligence-Microsoft.SecurityInsights-${workspaceName}'
  scope: loga
  kind: 'ThreatIntelligence'
  dependsOn: [
    logaOnboardingStatus
  ]
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
