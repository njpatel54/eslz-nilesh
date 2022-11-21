targetScope = 'subscription'

@description('subscriptionId for the deployment')
param subscriptionId string

@description('Optional. Resource ID of the diagnostic log analytics workspace.')
param diagnosticWorkspaceId string = ''

@description('Location for the deployments and the resources')
param location string

@description('Required. Alias to assign to the subscription')
param subscriptionAlias string

@description('Optional. Security contact data.')
param defenderSecurityContactProperties object

module defender '../../modules/security/azureSecurityCenter/deploy.bicep' = {
  name: 'defender-${take(uniqueString(deployment().name, location), 4)}-${subscriptionAlias}'
  scope: subscription(subscriptionId)
  params: {
    scope: subscriptionId
    workspaceId: diagnosticWorkspaceId
    securityContactProperties: defenderSecurityContactProperties
  }
}
