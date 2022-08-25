@description('The name of the primary SQL Server.')
param sqlServerPrimaryName string

@description('The administrator username of the primary SQL Server.')
param sqlServerPrimaryAdminUsername string

@description('The administrator password of the primary SQL Server.')
@secure()
param sqlServerPrimaryAdminPassword string

@description('The name of the secondary SQL Server.')
param sqlServerSecondaryName string

@description('The location of the secondary SQL Server.')
param sqlServerSecondaryRegion string

@description('The administrator username of the secondary SQL Server.')
param sqlServerSecondaryAdminUsername string

@description('The administrator password of the secondary SQL Server.')
@secure()
param sqlServerSecondaryAdminPassword string

@description('The name of the failover group.')
param sqlFailoverGroupName string

@description('Location for all resources.')
param location string = resourceGroup().location

var sqlDatabaseName = 'MyData'
var sqlDatabaseServiceObjective = 'Basic'
var sqlDatabaseEdition = 'Basic'

resource sqlServerPrimaryName_resource 'Microsoft.Sql/servers@2020-02-02-preview' = {
  kind: 'v12.0'
  name: sqlServerPrimaryName
  location: location
  properties: {
    administratorLogin: sqlServerPrimaryAdminUsername
    administratorLoginPassword: sqlServerPrimaryAdminPassword
    version: '12.0'
  }
}

resource sqlServerPrimaryName_sqlFailoverGroupName 'Microsoft.Sql/servers/failoverGroups@2020-02-02-preview' = {
  parent: sqlServerPrimaryName_resource
  name: '${sqlFailoverGroupName}'
  properties: {
    serverName: sqlServerPrimaryName
    partnerServers: [
      {
        id: sqlServerSecondaryName_resource.id
      }
    ]
    readWriteEndpoint: {
      failoverPolicy: 'Automatic'
      failoverWithDataLossGracePeriodMinutes: 60
    }
    readOnlyEndpoint: {
      failoverPolicy: 'Disabled'
    }
    databases: [
      sqlServerPrimaryName_sqlDatabaseName.id
    ]
  }
}

resource sqlServerPrimaryName_sqlDatabaseName 'Microsoft.Sql/servers/databases@2020-02-02-preview' = {
  parent: sqlServerPrimaryName_resource
  name: '${sqlDatabaseName}'
  location: location
  properties: {
    edition: sqlDatabaseEdition
    requestedServiceObjectiveName: sqlDatabaseServiceObjective
  }
}

resource sqlServerSecondaryName_resource 'Microsoft.Sql/servers@2020-02-02-preview' = {
  kind: 'v12.0'
  name: sqlServerSecondaryName
  location: sqlServerSecondaryRegion
  properties: {
    administratorLogin: sqlServerSecondaryAdminUsername
    administratorLoginPassword: sqlServerSecondaryAdminPassword
    version: '12.0'
  }
}