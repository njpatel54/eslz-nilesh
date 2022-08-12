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

@description('Required. Azure SQL Database Name')
param sqlDbName string

@description('Conditional. The Azure Active Directory (AAD) administrator authentication. Required if no `administratorLogin` & `administratorLoginPassword` is provided.')
param administrators object = {}

@description('Optional. The databases to create in the server.')
param databases array = []

@description('Conditional. The administrator username for the server. Required if no `administrators` object for AAD authentication is provided.')
@secure()
param administratorLogin string = ''

@description('Conditional. The administrator login password. Required if no `administrators` object for AAD authentication is provided.')
@secure()
param administratorLoginPassword string = ''


param sqlFailOverGroupName string

@description('Required. The Virtual Network (vNet) Name.')
param vnetName string

@description('Required. An Array of 1 or more IP Address Prefixes for the Virtual Network.')
param vnetAddressPrefixes array

@description('Required. Hub - Network Security Groups Array.')
param networkSecurityGroups array

@description('Optional. An Array of subnets to deploy to the Virtual Network.')
param subnets array = []

@description('Optional. Virtual Network Peerings configurations')
param virtualNetworkPeerings array = []

@description('Required. Array of Private DNS Zones (Azure US Govrenment).')
param privateDnsZones array

@description('Required. Name for the Diagnostics Setting Configuration.')
param diagSettingName string = ''

@description('Optional. Resource ID of the diagnostic storage account.')
param diagnosticStorageAccountId string = ''

@description('Optional. Resource ID of the diagnostic log analytics workspace.')
param diagnosticWorkspaceId string = ''

@description('Optional. Resource ID of the diagnostic log analytics workspace - Local.')
param localDiagnosticWorkspaceId string = ''

/*
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

@description('Required. Subscription ID of Connectivity Subscription')
param connsubid string

@description('Required. Resource Group name for Private DNS Zones.')
param priDNSZonesRgName string

@description('Required. Resource Group name.')
param vnetRgName string

// 1. Create Primary Azure SQL Server
module sqlPrimaryServer '../../modules/sql/servers/deploy.bicep' = {
  name: 'sqlPrimaryServer-${take(uniqueString(deployment().name, location), 4)}-${sqlPrimaryServerName}'
  scope: resourceGroup(subscriptionId, wlRgName)
  params: {
    name: sqlPrimaryServerName
    location: location
    tags: combinedTags
    administratorLogin: akvtest.getSecret(sqlAdministratorLogin)
    administratorLoginPassword: akvtest.getSecret(sqlAdministratorLoginPassword) 
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
    administratorLogin: akvtest.getSecret(sqlAdministratorLogin)
    administratorLoginPassword: akvtest.getSecret(sqlAdministratorLoginPassword) 
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
    diagnosticStorageAccountId: sa.outputs.resourceId
    diagnosticWorkspaceId: loga.outputs.resourceId
    //diagnosticEventHubAuthorizationRuleId: diagnosticEventHubAuthorizationRuleId
    //diagnosticEventHubName: diagnosticEventHubName    
  }
}]
