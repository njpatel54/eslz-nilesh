param administratorLogin string = ''

@secure()
param administratorLoginPassword string = ''
param administrators object = {
}
param location string
param serverName string
param enableADS bool = false

@description('To enable vulnerability assessments, the user deploying this template must have an administrator or owner permissions.')
param useVAManagedIdentity bool = false
param allowAzureIps bool = true
param enableVA bool = false
param serverTags object = {
}

var subscriptionId = subscription().subscriptionId
var resourceGroupName = resourceGroup().name
var uniqueStorage = uniqueString(subscriptionId, resourceGroupName, location)
var storageName_var = toLower('sqlva${uniqueStorage}')
var uniqueRoleGuid = guid(storageName.id, StorageBlobContributor, serverName_resource.id)
var StorageBlobContributor = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'ba92f5b4-2d11-453d-a403-e96b0029c9fe')

resource storageName 'Microsoft.Storage/storageAccounts@2019-04-01' = if (enableVA) {
  name: storageName_var
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: 'true'
    allowBlobPublicAccess: 'false'
  }
}

resource storageName_Microsoft_Authorization_uniqueRoleGuid 'Microsoft.Storage/storageAccounts/providers/roleAssignments@2018-09-01-preview' = if (enableVA) {
  name: '${storageName_var}/Microsoft.Authorization/${uniqueRoleGuid}'
  properties: {
    roleDefinitionId: StorageBlobContributor
    principalId: reference(serverName_resource.id, '2018-06-01-preview', 'Full').identity.principalId
    scope: storageName.id
    principalType: 'ServicePrincipal'
  }
}

resource serverName_resource 'Microsoft.Sql/servers@2020-11-01-preview' = {
  name: serverName
  location: location
  properties: {
    version: '12.0'
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    administrators: administrators
  }
  identity: ((enableVA && useVAManagedIdentity) ? json('{"type":"SystemAssigned"}') : json('null'))
  tags: serverTags
}

resource serverName_AllowAllWindowsAzureIps 'Microsoft.Sql/servers/firewallRules@2014-04-01-preview' = if (allowAzureIps) {
  parent: serverName_resource
  name: 'AllowAllWindowsAzureIps'
  location: location
  properties: {
    endIpAddress: '0.0.0.0'
    startIpAddress: '0.0.0.0'
  }
}

resource serverName_Default 'Microsoft.Sql/servers/securityAlertPolicies@2017-03-01-preview' = if (enableADS) {
  parent: serverName_resource
  name: 'Default'
  properties: {
    state: 'Enabled'
    emailAccountAdmins: true
  }
}

resource Microsoft_Sql_servers_vulnerabilityAssessments_serverName_Default 'Microsoft.Sql/servers/vulnerabilityAssessments@2018-06-01-preview' = if (enableVA) {
  parent: serverName_resource
  name: 'Default'
  properties: {
    storageContainerPath: (enableVA ? '${storageName.properties.primaryEndpoints.blob}vulnerability-assessment' : '')
    storageAccountAccessKey: ((enableVA && (!useVAManagedIdentity)) ? listKeys(storageName_var, '2018-02-01').keys[0].value : '')
    recurringScans: {
      isEnabled: true
      emailSubscriptionAdmins: true
    }
  }
  dependsOn: [

    serverName_Default
  ]
}