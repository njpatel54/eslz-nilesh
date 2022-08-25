@description('subscriptionId for the deployment')
param subscriptionId string

@description('Location for the deployments and the resources')
param location string

@description('Required. Combine Tags in dynamoctags object with Tags from parameter file.')
param combinedTags object

@description('Required. Name of the resourceGroup, where application workload will be deployed.')
param wlRgName string

@description('Required. Azure SQL Server Name (Primary)')
param sqlPrimaryServerName string

@description('Required. Azure SQL Server Name (Secondary)')
param sqlSecondaryServerName string

@description('Conditional. The Azure Active Directory (AAD) administrator authentication. Required if no `administratorLogin` & `administratorLoginPassword` is provided.')
param administrators object

@description('Optional. The databases to create in the server.')
param databases array

@description('Conditional. The administrator username for the server. Required if no `administrators` object for AAD authentication is provided.')
@secure()
param administratorLogin string

@description('Conditional. The administrator login password. Required if no `administrators` object for AAD authentication is provided.')
@secure()
param administratorLoginPassword string

@description('Optional. SQL Server Failover Group Name.')
param sqlFailOverGroupName string

@description('Required. Load content from json file to iterate over database in "databases".')
var params = json(loadTextContent('../.parameters/parameters.json'))

@description('Required. Name for the Diagnostics Setting Configuration.')
param diagSettingName string = ''

@description('Optional. Resource ID of the diagnostic log analytics workspace - Local.')
param localDiagnosticWorkspaceId string = ''

/*
@description('Optional. Resource ID of the diagnostic storage account.')
param diagnosticStorageAccountId string = ''

@description('Optional. Resource ID of the diagnostic log analytics workspace.')
param diagnosticWorkspaceId string = ''

@description('Optional. Resource ID of the diagnostic event hub authorization rule for the Event Hubs namespace in which the event hub should be created or streamed to.')
param diagnosticEventHubAuthorizationRuleId string = ''

@description('Optional. Name of the diagnostic event hub within the namespace to which logs are streamed. Without this, an event hub is created for each log category.')
param diagnosticEventHubName string = ''

@description('Optional. Resource ID of the diagnostic storage account - Local.')
param localDiagnosticStorageAccountId string = ''

@description('Optional. Resource ID of the diagnostic event hub authorization rule for the Event Hubs namespace in which the event hub should be created or streamed to - Local.')
param localDiagnosticEventHubAuthorizationRuleId string = ''

@description('Optional. Name of the diagnostic event hub within the namespace to which logs are streamed. Without this, an event hub is created for each log category - Local.')
param localDiagnosticEventHubName string = ''
*/

// 1. Create Primary Azure SQL Server
module sqlPrimaryServer '../../modules/sql/servers/deploy.bicep' = {
  name: 'sqlPrimaryServer-${take(uniqueString(deployment().name, location), 4)}-${sqlPrimaryServerName}'
  scope: resourceGroup(subscriptionId, wlRgName)
  params: {
    name: sqlPrimaryServerName
    location: location
    tags: combinedTags
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword 
    administrators: {
      administratorType: administrators.administratorType
      azureADOnlyAuthentication: administrators.azureADOnlyAuthentication
      login: administrators.login
      principalType: administrators.principalType
      sid: administrators.sid
      tenantId: administrators.tenantId
    }
    systemAssignedIdentity: true
  }
}

// 2. Create Secondary Azure SQL Server
module sqlSecondaryServer '../../modules/sql/servers/deploy.bicep' = {
  name: 'sqlSecondaryServer-${take(uniqueString(deployment().name, location), 4)}-${sqlSecondaryServerName}'
  scope: resourceGroup(subscriptionId, wlRgName)
  params: {
    name: sqlSecondaryServerName
    location: location
    tags: combinedTags
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword 
    administrators: {
      administratorType: administrators.administratorType
      azureADOnlyAuthentication: administrators.azureADOnlyAuthentication
      login: administrators.login
      principalType: administrators.principalType
      sid: administrators.sid
      tenantId: administrators.tenantId
    }
    systemAssignedIdentity: true
  }
}

// 3. Create Azure SQL Database
module sqldb '../../modules/sql/servers/databases/deploy.bicep' = [for database in databases: {
  name: 'sqldb-${take(uniqueString(deployment().name, location), 4)}-${database.name}'
  scope: resourceGroup(subscriptionId, wlRgName)
  params: {
    name: database.name
    serverName: sqlPrimaryServerName
    location: location
    tags: combinedTags
    skuTier: database.skuTier
    skuName: database.skuName
    skuCapacity: database.skuCapacity
    skuFamily: database.skuFamily
    maxSizeBytes: database.maxSizeBytes
    licenseType: database.licenseType
    diagnosticSettingsName: '${diagSettingName}-${database.name}'
    //diagnosticSettingsName: diagSettingName
    //diagnosticStorageAccountId: diagnosticStorageAccountId
    //diagnosticWorkspaceId: diagnosticWorkspaceId
    //diagnosticEventHubAuthorizationRuleId: diagnosticEventHubAuthorizationRuleId
    //diagnosticEventHubName: diagnosticEventHubName
    localDiagnosticWorkspaceId: localDiagnosticWorkspaceId
    //localDiagnosticStorageAccountId: localDiagnosticStorageAccountId
    //localDiagnosticEventHubAuthorizationRuleId: localDiagnosticEventHubAuthorizationRuleId
    //localDiagnosticEventHubName: localDiagnosticEventHubName   
  }
}]

// 4. Create Azure SQL Server Failover Group
resource symbolicname 'Microsoft.Sql/servers/failoverGroups@2022-02-01-preview' = {
  name: '${sqlPrimaryServerName}/${sqlFailOverGroupName}'
  tags: combinedTags
  properties: {
    databases: [for database in params.parameters.databases.value: resourceId(subscriptionId, wlRgName, 'Microsoft.Sql/servers/databases', sqlPrimaryServerName, database.name)]
    partnerServers: [
      {
        id: sqlSecondaryServer.outputs.resourceId
      }
    ]
    readWriteEndpoint: {
      failoverPolicy: 'Automatic'
      failoverWithDataLossGracePeriodMinutes: 60
    }
    readOnlyEndpoint: {
      failoverPolicy: 'Disabled'
    }
  }
}


