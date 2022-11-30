param firewallPolicyName string = 'GitHubRepoFirewallPolicy'

@description('The Dev HostPool Subnet Address with CIDR xx.xx.xx.xx/yy, IP Ranges, and or IP Address . This will be used in the source address of the Azure Firewall network and app rules')
param DevHostPoolIPGroup array

@description('Threat Intellengence Mode traffic passing hits these rules first and have the following actions Off, Alert, Deny')
@allowed([
  'Off'
  'Alert'
  'Deny'
])
param ThreatIntelMode string = 'Alert'

@description('IDPS inspection and have the following actions Off, Alert, Deny')
@allowed([
  'Off'
  'Alert'
  'Deny'
])
param IDPSMode string = 'Alert'

@description('Array of The specific GitHub Repos URLs for each Repo this must be looked up as it is unique per instance EX. github.com/swiftsolves-msft* and raw.githubusercontent.com/swiftsolves-msft* ')
param GitHubRepoUrls array

@description('Keyvault name that is storing the CA Certificate as a Secret for Azure Firewall TLS Inspection')
param keyVaultName string = ''

@description('Secret name for CA Certificate used in Azure Firewall TLS Inspection')
param keyVaultCASecretName string = 'cacert'

@description('The ResourceID of the User Assigned Identity that was generated for access to KeyVault - cacert - secret')
param userAssignedIdentityId string

var ipGroupname = 'DevHostPools'

resource ipGroup 'Microsoft.Network/ipGroups@2020-05-01' = {
  name: ipGroupname
  location: resourceGroup().location
  tags: {
  }
  properties: {
    ipAddresses: DevHostPoolIPGroup
  }
}

resource firewallPolicy 'Microsoft.Network/firewallPolicies@2020-05-01' = {
  name: firewallPolicyName
  location: resourceGroup().location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userAssignedIdentityId}': {
      }
    }
  }
  properties: {
    sku: {
      tier: 'Premium'
    }
    threatIntelMode: ThreatIntelMode
    threatIntelWhitelist: {
      ipAddresses: []
    }
    transportSecurity: {
      certificateAuthority: {
        name: keyVaultCASecretName
        keyVaultSecretId: '${reference(resourceId('Microsoft.KeyVault/vaults', keyVaultName), '2019-09-01').vaultUri}secrets/${keyVaultCASecretName}'
      }
    }
    intrusionDetection: {
      mode: IDPSMode
      configuration: {
        signatureOverrides: []
        bypassTrafficSettings: []
      }
    }
    dnsSettings: {
      servers: []
      enableProxy: true
    }
  }
}

resource firewallPolicyName_DefaultApplicationRuleCollectionGroup 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2020-05-01' = {
  parent: firewallPolicy
  name: 'DefaultApplicationRuleCollectionGroup'
  location: resourceGroup().location
  properties: {
    priority: 300
    ruleCollections: [
      {
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        action: {
          type: 'Allow'
        }
        rules: [
          {
            ruleType: 'ApplicationRule'
            name: 'AllowGitHubBase'
            protocols: [
              {
                protocolType: 'Https'
                port: 443
              }
            ]
            fqdnTags: []
            targetFqdns: []
            targetUrls: [
              'github.githubassets.com/*'
              'github.com/session'
              'github.com/sessions/two-factor'
              'github.com/login*'
              'github.com/Azure*'
              'raw.githubusercontent.com/Azure*'
            ]
            terminateTLS: true
            sourceAddresses: []
            destinationAddresses: []
            sourceIpGroups: [
              ipGroup.id
            ]
          }
          {
            ruleType: 'ApplicationRule'
            name: 'AllowGitHubRepo'
            protocols: [
              {
                protocolType: 'Https'
                port: 443
              }
            ]
            fqdnTags: []
            targetFqdns: []
            targetUrls: GitHubRepoUrls
            terminateTLS: true
            sourceAddresses: []
            destinationAddresses: []
            sourceIpGroups: [
              ipGroup.id
            ]
          }
        ]
        name: 'AllowGithub'
        priority: 200
      }
    ]
  }
}