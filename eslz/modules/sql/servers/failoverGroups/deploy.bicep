
@description('Required. Azure SQL Server Name (Primary)')
param sqlPrimaryServerName string

@description('Optional. SQL Server Failover Group Name.')
param sqlFailOverGroupName string

@description('Optional. The databases array')
param databases array

@description('Optional. The partners server array.')
param partnerServers array

@description('Optional. Tags of the resource.')
param tags object = {}

resource symbolicname 'Microsoft.Sql/servers/failoverGroups@2022-02-01-preview' = {
  name: '${sqlPrimaryServerName}/${sqlFailOverGroupName}'
  tags: tags
  properties: {
    databases: databases
    partnerServers: partnerServers
    readWriteEndpoint: {
      failoverPolicy: 'Automatic'
      failoverWithDataLossGracePeriodMinutes: 60
    }
    readOnlyEndpoint: {
      failoverPolicy: 'Disabled'
    }
  }
}
