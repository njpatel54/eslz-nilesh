targetScope = 'subscription'

@description('subscriptionId for the deployment')
param subscriptionId string

@description('Required. Resource Group name.')
param vnetRgName string

@description('Required. The Virtual Network (vNet) Name.')
param vnetName string

resource vNet 'Microsoft.Network/virtualNetworks@2022-01-01' existing = {
  name: vnetName
  scope: resourceGroup(subscriptionId, vnetRgName)
}

module lzVnetDiaglocal '../../modules/insights/diagnosticSettings/deploy.bicep' = {
  name: vNet
  scope: vNet
  params: {
    name: vnetName
    location: location
    tags: combinedTags
    addressPrefixes: vnetAddressPrefixes
    subnets: subnets
    virtualNetworkPeerings: virtualNetworkPeerings
    subscriptionId: subscriptionId
    diagnosticSettingsName: diagSettingName
    diagnosticStorageAccountId: diagnosticStorageAccountId
    diagnosticWorkspaceId: diagnosticWorkspaceId
    //diagnosticEventHubAuthorizationRuleId: diagnosticEventHubAuthorizationRuleId
    //diagnosticEventHubName: diagnosticEventHubName
  }
}

module lzVnetDiaglocal '../../modules/insights/diagnosticSettings/deploy.bicep' = {
  
}
