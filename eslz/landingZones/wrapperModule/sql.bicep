targetScope = 'managementGroup'

@description('subscriptionId for the deployment')
param subscriptionId string

@description('Location for the deployments and the resources')
param location string

@description('Required. Combine Tags in dynamoctags object with Tags from parameter file.')
param combinedTags object

@description('Required. Name of the resourceGroup, where application workload will be deployed.')
param wlRgName string

@description('Required. Name of the resourceGroup, where networking components will be.')
param vnetRgName string

@description('Required. Virtual Network name in Landing Zone Subscription.')
param vnetName string

@description('Required. Subnet name to be used for Private Endpoint.')
param mgmtSubnetName string

@description('Required. Subscription ID of Connectivity Subscription')
param connsubid string

@description('Required. Resource Group name for Private DNS Zones.')
param priDNSZonesRgName string

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
// This is required for it to send Vulnerability Assessment data.
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
// This is required for it to send Vulnerability Assessment data.
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

// 6. Create Private Endpoint for Primary Azure SQL Server
module sqlPrimaryServerPe '../../modules/network/privateEndpoints/deploy.bicep' = {
  name: 'sqlPrimaryServerPe-${take(uniqueString(deployment().name, location), 4)}-${sqlPrimaryServerName}'
  scope: resourceGroup(subscriptionId, wlRgName)
  dependsOn: [
    sqlPrimaryServer
  ]
  params: {
    name: '${sqlPrimaryServerName}-sqlServer-pe'
    location: location
    tags: combinedTags
    serviceResourceId: sqlPrimaryServer.outputs.resourceId
    groupIds: [
      'sqlServer'
    ]
    subnetResourceId: resourceId(subscriptionId, vnetRgName, 'Microsoft.Network/virtualNetworks/subnets', vnetName, mgmtSubnetName)
    privateDnsZoneGroup: {
      privateDNSResourceIds: [
        resourceId(connsubid, priDNSZonesRgName, 'Microsoft.Network/privateDnsZones', 'privatelink.database.usgovcloudapi.net')
      ]
    }
  }
}

// 7. Create Private Endpoint for Secondary Azure SQL Server
module sqlSecondaryServerPe '../../modules/network/privateEndpoints/deploy.bicep' = {
  name: 'sqlSecondaryServerPe-${take(uniqueString(deployment().name, location), 4)}-${sqlSecondaryServerName}'
  scope: resourceGroup(subscriptionId, wlRgName)
  dependsOn: [
    sqlSecondaryServer
  ]
  params: {
    name: '${sqlSecondaryServerName}-sqlServer-pe'
    location: location
    tags: combinedTags
    serviceResourceId: sqlSecondaryServer.outputs.resourceId
    groupIds: [
      'sqlServer'
    ]
    subnetResourceId: resourceId(subscriptionId, vnetRgName, 'Microsoft.Network/virtualNetworks/subnets', vnetName, mgmtSubnetName)
    privateDnsZoneGroup: {
      privateDNSResourceIds: [
        resourceId(connsubid, priDNSZonesRgName, 'Microsoft.Network/privateDnsZones', 'privatelink.database.usgovcloudapi.net')
      ]
    }
  }
}

// 8. Configure AuditSettings for Primary SQL Server
module auditSettingsPrimary '../../modules/sql/servers//auditingSettings/deploy.bicep' = {
  name: 'auditSettingsPrimary${take(uniqueString(deployment().name, location), 4)}-${sqlPrimaryServerName}'
  scope: resourceGroup(subscriptionId, wlRgName)
  dependsOn: [
    sqldb
    sqlPrimaryServer
    sqlSecondaryServer
  ]
  params: {
    sqlServerName: sqlPrimaryServerName
    diagnosticWorkspaceId: diagnosticWorkspaceId
  }
}

// 9. Configure AuditSettings for Secondary SQL Server
module auditSettingsSecondary '../../modules/sql/servers//auditingSettings/deploy.bicep' = {
  name: 'auditSettingsSecondary${take(uniqueString(deployment().name, location), 4)}-${sqlSecondaryServerName}'
  scope: resourceGroup(subscriptionId, wlRgName)
  dependsOn: [
    sqldb
    sqlPrimaryServer
    sqlSecondaryServer
  ]
  params: {
    sqlServerName: sqlSecondaryServerName
    diagnosticWorkspaceId: diagnosticWorkspaceId
  }
}
