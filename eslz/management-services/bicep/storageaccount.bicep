@description('Specify the storage account name.')
param storageAccountName string

@description('Specify a location for the resources.')
param location string

@description('Specify the storage account type.')
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_RAGRS'
  'Standard_ZRS'
  'Premium_LRS'
  'Premium_ZRS'
  'Standard_GZRS'
  'Standard_RAGZRS'
])
param storageSKU string

@allowed([
  'Storage'
  'StorageV2'
  'BlobStorage'
  'FileStorage'
  'BlockBlobStorage'
])
@description('Optional. Type of Storage Account to create.')
param storageAccountKind string = 'StorageV2'

@allowed([
  'Hot'
  'Cool'
])
@description('Optional. Storage Account Access Tier.')
param storageAccountAccessTier string = 'Hot'

@description('Optional. Enables system assigned managed identity on the resource.')
param systemAssignedIdentity bool = false

@description('Optional. The ID(s) to assign to the resource.')
param userAssignedIdentities object = {}

@description('Optional. Provides the identity based authentication settings for Azure Files.')
param azureFilesIdentityBasedAuthentication object = {}

@description('Optional. Blob service and containers to deploy')
param blobServices object = {}

@description('Optional. Networks ACLs, this value contains IPs to whitelist and/or Subnet information. For security reasons, it is recommended to set the DefaultAction Deny')
param networkAcls object = {}

@description('Optional. A boolean indicating whether or not the service applies a secondary layer of encryption with platform managed keys for data at rest. For security reasons, it is recommended to set it to true.')
param requireInfrastructureEncryption bool = true

@description('Optional. Indicates whether public access is enabled for all blobs or containers in the storage account. For security reasons, it is recommended to set it to false.')
param allowBlobPublicAccess bool = false

@allowed([
  'TLS1_0'
  'TLS1_1'
  'TLS1_2'
])
@description('Optional. Set the minimum TLS version on request to storage.')
param minimumTlsVersion string = 'TLS1_2'

@description('Optional. If true, enables Hierarchical Namespace for the storage account')
param enableHierarchicalNamespace bool = false

@description('Optional. Specifies the number of days that logs will be kept for; a value of 0 will retain data indefinitely.')
@minValue(0)
@maxValue(365)
param diagnosticLogsRetentionInDays int = 365

@description('Optional. Resource ID of the diagnostic storage account.')
param diagnosticStorageAccountId string = ''

@description('Optional. Resource ID of the diagnostic log analytics workspace.')
param diagnosticWorkspaceId string = ''

@description('Optional. Resource ID of the diagnostic event hub authorization rule for the Event Hubs namespace in which the event hub should be created or streamed to.')
param diagnosticEventHubAuthorizationRuleId string = ''

@description('Optional. Name of the diagnostic event hub within the namespace to which logs are streamed. Without this, an event hub is created for each log category.')
param diagnosticEventHubName string = ''

@allowed([
  'CanNotDelete'
  'NotSpecified'
  'ReadOnly'
])
@description('Optional. Specify the type of lock.')
param lock string = 'NotSpecified'

@description('Optional. Tags of the resource.')
param tags object = {}

@allowed([
  'Enabled'
  'Disabled'
])
@description('Optional. Enable or disallow public network access to Storage Account..')
param publicNetworkAccess string = 'Enabled'

@description('Optional. Allows HTTPS traffic only to storage service if sets to true.')
param supportsHttpsTrafficOnly bool = true

@description('Optional. The name of metrics that will be streamed.')
@allowed([
  'Transaction'
])
param diagnosticMetricsToEnable array = [
  'Transaction'
]

@description('Optional. The name of the diagnostic setting, if deployed.')
param diagnosticSettingsName string = '${storageAccountName}-diagnosticSettings'

var diagnosticsMetrics = [for metric in diagnosticMetricsToEnable: {
  category: metric
  timeGrain: null
  enabled: true
  retentionPolicy: {
    enabled: true
    days: diagnosticLogsRetentionInDays
  }
}]

var supportsBlobService = storageAccountKind == 'BlockBlobStorage' || storageAccountKind == 'BlobStorage' || storageAccountKind == 'StorageV2' || storageAccountKind == 'Storage'
var supportsFileService = storageAccountKind == 'FileStorage' || storageAccountKind == 'StorageV2' || storageAccountKind == 'Storage'

var identityType = systemAssignedIdentity ? (!empty(userAssignedIdentities) ? 'SystemAssigned,UserAssigned' : 'SystemAssigned') : (!empty(userAssignedIdentities) ? 'UserAssigned' : 'None')
var identity = identityType != 'None' ? {
  type: identityType
  userAssignedIdentities: !empty(userAssignedIdentities) ? userAssignedIdentities : null
} : null


resource storageAccount 'Microsoft.Storage/storageAccounts@2021-08-01' = {
  name: storageAccountName
  location: location
  kind: storageAccountKind
  sku: {
    name: storageSKU
  }
  identity: identity
  tags: tags
  properties: {
    encryption: {
      keySource: 'Microsoft.Storage'
      services: {
        blob: supportsBlobService ? {
          enabled: true
        } : null
        file: supportsFileService ? {
          enabled: true
        } : null
      }
      requireInfrastructureEncryption: storageAccountKind != 'Storage' ? requireInfrastructureEncryption : null
    }
    accessTier: storageAccountKind != 'Storage' ? storageAccountAccessTier : null
    supportsHttpsTrafficOnly: supportsHttpsTrafficOnly
    isHnsEnabled: enableHierarchicalNamespace ? enableHierarchicalNamespace : null
    minimumTlsVersion: minimumTlsVersion
    networkAcls: !empty(networkAcls) ? {
      bypass: !empty(networkAcls) ? networkAcls.bypass : null
      defaultAction: !empty(networkAcls) ? networkAcls.defaultAction : null
      virtualNetworkRules: (!empty(networkAcls) && contains(networkAcls, 'virtualNetworkRules')) ? networkAcls.virtualNetworkRules : []
      ipRules: (!empty(networkAcls) && contains(networkAcls, 'ipRules')) ? networkAcls.ipRules : []
    } : null
    allowBlobPublicAccess: allowBlobPublicAccess
    publicNetworkAccess: publicNetworkAccess
    azureFilesIdentityBasedAuthentication: !empty(azureFilesIdentityBasedAuthentication) ? azureFilesIdentityBasedAuthentication : null
  }
}

resource storageAccount_diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if ((!empty(diagnosticStorageAccountId)) || (!empty(diagnosticWorkspaceId)) || (!empty(diagnosticEventHubAuthorizationRuleId)) || (!empty(diagnosticEventHubName))) {
  name: diagnosticSettingsName
  properties: {
    storageAccountId: !empty(diagnosticStorageAccountId) ? diagnosticStorageAccountId : null
    workspaceId: !empty(diagnosticWorkspaceId) ? diagnosticWorkspaceId : null
    eventHubAuthorizationRuleId: !empty(diagnosticEventHubAuthorizationRuleId) ? diagnosticEventHubAuthorizationRuleId : null
    eventHubName: !empty(diagnosticEventHubName) ? diagnosticEventHubName : null
    metrics: diagnosticsMetrics
  }
  scope: storageAccount
}

resource storageAccount_lock 'Microsoft.Authorization/locks@2017-04-01' = if (lock != 'NotSpecified') {
  name: '${storageAccount.name}-${lock}-lock'
  properties: {
    level: lock
    notes: lock == 'CanNotDelete' ? 'Cannot delete resource or child resources.' : 'Cannot modify the resource or child resources.'
  }
  scope: storageAccount
}


@description('The resource ID of the deployed storage account')
output resourceId string = storageAccount.id

@description('The name of the deployed storage account')
output name string = storageAccount.name

@description('The resource group of the deployed storage account')
output resourceGroupName string = resourceGroup().name

@description('The primary blob endpoint reference if blob services are deployed.')
output primaryBlobEndpoint string = !empty(blobServices) && contains(blobServices, 'containers') ? reference('Microsoft.Storage/storageAccounts/${storageAccount.name}', '2019-04-01').primaryEndpoints.blob : ''

@description('The principal ID of the system assigned identity.')
output systemAssignedPrincipalId string = systemAssignedIdentity && contains(storageAccount.identity, 'principalId') ? storageAccount.identity.principalId : ''
