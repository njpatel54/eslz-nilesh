param name string = 'testampls'
param tags object = {}

@description('Optional. Specifies the default access mode of ingestion through associated private endpoints in scope. If not specified default value is "Open".')
@allowed([
  'Open'
  'PrivateOnly'
])
param ingestionAccessMode string = 'PrivateOnly'

@description('Optional. Specifies the default access mode of queries through associated private endpoints in scope. If not specified default value is "Open".')
@allowed([
  'Open'
  'PrivateOnly'
])
param queryAccessMode string = 'PrivateOnly'

@description('Optional. List of exclusions that override the default access mode settings for specific private endpoint connections.')
param exclusions array = []


resource privateLinkScope 'microsoft.insights/privateLinkScopes@2021-07-01-preview' = {
  name: name
  location: 'Global'
  tags: tags
  properties: {
    accessModeSettings: {
      exclusions: !empty(exclusions) ? exclusions : []
      ingestionAccessMode: !empty(ingestionAccessMode) ? ingestionAccessMode : 'Open'
      queryAccessMode: !empty(queryAccessMode) ? queryAccessMode : 'Open'
    }
  }
}





/*
tags: contains(privateEndpoint, 'tags') ? privateEndpoint.tags : {}
manualPrivateLinkServiceConnections: contains(privateEndpoint, 'manualPrivateLinkServiceConnections') ? privateEndpoint.manualPrivateLinkServiceConnections : []
customDnsConfigs: contains(privateEndpoint, 'customDnsConfigs') ? privateEndpoint.customDnsConfigs : []
*/
