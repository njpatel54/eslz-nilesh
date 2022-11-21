targetScope = 'subscription'

@description('subscriptionId for the deployment')
param subscriptionId string

@description('Location for the deployments and the resources')
param location string

@description('Required. Alias to assign to the subscription')
param subscriptionAlias string

@description('Required. The full Azure ID of the workspace to save the data in.')
param workspaceId string

@description('Optional. Security contact data.')
param defenderSecurityContactProperties object

module defender '../../modules/security/azureSecurityCenter/deploy.bicep' = {
  name: 'defender-${take(uniqueString(deployment().name, location), 4)}-${subscriptionAlias}'
  scope: subscription(subscriptionId)
  params: {
    scope: '/subscriptions/${subscriptionId}'
    workspaceId: workspaceId
    securityContactProperties: defenderSecurityContactProperties
  }
}
