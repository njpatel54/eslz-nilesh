targetScope = 'managementGroup'

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

@description('Location for the Primary Azure SQL Server & Azure SQL Database')
param primaryLocation string = 'USGovVirginia'

@description('Required. Azure SQL Server Name (Secondary)')
param sqlSecondaryServerName string

@description('Location for the Primary Azure SQL Server')
param secondaryLocation string = 'USGovTexas'

@description('Conditional. The Azure Active Directory (AAD) administrator authentication. Required if no `administratorLogin` & `administratorLoginPassword` is provided.')
param administrators object

@description('Optional. Whether or not public endpoint access is allowed for this server. Value is optional but if passed in, must be "Enabled" or "Disabled".')
param publicNetworkAccess string = 'Disabled'

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

@description('Optional. Resource ID of the diagnostic log analytics workspace.')
param diagnosticWorkspaceId string = ''

@description('Required. Subscription ID of Management Subscription.')
param mgmtsubid string

@description('Required. SIEM Resource Group Name.')
param siemRgName string

@description('Optional. The security alert policies to create in the server.')
param securityAlertPolicies array

@description('Optional. The vulnerability assessment configuration.')
param vulnerabilityAssessmentsObj object

// 1. Create Primary Azure SQL Server
module sqlPrimaryServer '../../modules/sql/servers/deploy.bicep' = {
  name: 'sqlPrimaryServer-${take(uniqueString(deployment().name, location), 4)}-${sqlPrimaryServerName}'
  scope: resourceGroup(subscriptionId, wlRgName)
  params: {
    name: sqlPrimaryServerName
    location: primaryLocation
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
    publicNetworkAccess: publicNetworkAccess
    securityAlertPolicies: securityAlertPolicies
    vulnerabilityAssessmentsObj: vulnerabilityAssessmentsObj 
  }
}

// 2. Role Assignment to Primary SQL Server's System Assigned MI (Storage Blob Data Contributor)
module roleAssignmentBlobDataContributorPrimary '../../modules/authorization/roleAssignments/resourceGroup/deploy.bicep' = {
  name: 'roleAssignmentBlobDataContributorPrimary-${take(uniqueString(deployment().name, location), 4)}-${sqlPrimaryServerName}'
  scope: resourceGroup(mgmtsubid, siemRgName)
  dependsOn: [
    sqlPrimaryServer
  ]
  params: {
    roleDefinitionIdOrName: 'Storage Blob Data Contributor'
    principalType: 'ServicePrincipal'
    principalIds: [
      sqlPrimaryServer.outputs.systemAssignedPrincipalId
    ]
  }
}

// 3. Create Secondary Azure SQL Server
module sqlSecondaryServer '../../modules/sql/servers/deploy.bicep' = {
  name: 'sqlSecondaryServer-${take(uniqueString(deployment().name, location), 4)}-${sqlSecondaryServerName}'
  scope: resourceGroup(subscriptionId, wlRgName)
  params: {
    name: sqlSecondaryServerName
    location: secondaryLocation
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
    publicNetworkAccess: publicNetworkAccess
    securityAlertPolicies: securityAlertPolicies
    vulnerabilityAssessmentsObj: vulnerabilityAssessmentsObj 
  }
}

// 4. Role Assignment to Secondary SQL Server's System Assigned MI (Storage Blob Data Contributor)
module roleAssignmentBlobDataContributorSecondary '../../modules/authorization/roleAssignments/resourceGroup/deploy.bicep' = {
  name: 'roleAssignmentBlobDataContributorSecondary-${take(uniqueString(deployment().name, location), 4)}-${sqlSecondaryServerName}'
  scope: resourceGroup(mgmtsubid, siemRgName)
  dependsOn: [
    sqlSecondaryServer
  ]
  params: {
    roleDefinitionIdOrName: 'Storage Blob Data Contributor'
    principalType: 'ServicePrincipal'
    principalIds: [
      sqlSecondaryServer.outputs.systemAssignedPrincipalId
    ]
  }
}

// 4. Create Azure SQL Database
module sqldb '../../modules/sql/servers/databases/deploy.bicep' = [for database in databases: {
  name: 'sqldb-${take(uniqueString(deployment().name, location), 4)}-${database.name}'
  scope: resourceGroup(subscriptionId, wlRgName)
  dependsOn: [
    sqlPrimaryServer
  ]
  params: {
    name: database.name
    serverName: sqlPrimaryServerName
    location: primaryLocation
    tags: combinedTags
    skuTier: database.skuTier
    skuName: database.skuName
    skuCapacity: database.skuCapacity
    skuFamily: database.skuFamily
    maxSizeBytes: database.maxSizeBytes
    licenseType: database.licenseType
    diagnosticSettingsName: diagSettingName
    diagnosticWorkspaceId: diagnosticWorkspaceId
  }
}]

// 5. Create Azure SQL Server Failover Group
module sqlfailovergrp '../../modules/sql/servers/failoverGroups/deploy.bicep' = {
  name: 'sqlfailovergrp-${take(uniqueString(deployment().name, location), 4)}-${sqlFailOverGroupName}'
  scope: resourceGroup(subscriptionId, wlRgName)
  dependsOn: [
    sqldb
    sqlSecondaryServer
  ]
  params: {
    databases: [for database in params.parameters.databases.value: resourceId(subscriptionId, wlRgName, 'Microsoft.Sql/servers/databases', sqlPrimaryServerName, database.name)]
    partnerServers: [
      {
        id: sqlSecondaryServer.outputs.resourceId
      }
    ]
    sqlFailOverGroupName: sqlFailOverGroupName
    sqlPrimaryServerName: sqlPrimaryServerName
  }
}
