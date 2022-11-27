@description('Required. Name of the Azure Bastion resource.')
param name string

@description('Optional. Location for all resources.')
param location string = resourceGroup().location

@description('Required. Shared services Virtual Network resource identifier.')
param vNetId string

@description('Optional. The public ip resource ID to associate to the azureBastionSubnet. If empty, then the public ip that is created as part of this module will be applied to the azureBastionSubnet.')
param azureBastionSubnetPublicIpId string = ''

@description('Optional. This is to add any additional public ip configurations on top of the public ip with subnet ip configuration.')
param additionalPublicIpConfigurations array = []

@description('Optional. Specifies if a public ip should be created by default if one is not provided.')
param isCreateDefaultPublicIP bool = true

@description('Optional. Specifies the properties of the public IP to create and be used by Azure Bastion. If it\'s not provided and publicIPAddressResourceId is empty, a \'-pip\' suffix will be appended to the Bastion\'s name.')
param publicIPAddressObject object = {}

@description('Optional. Enable/Disable Copy/Paste feature of the Bastion Host resource.')
param disableCopyPaste bool = false

@description('Optional. Enable/Disable File Copy feature of the Bastion Host resource.')
param enableFileCopy bool = true

@description('Optional. Enable/Disable Tunneling feature of the Bastion Host resource.')
param enableTunneling bool = true

@description('Optional. Enable/Disable IP Connect feature of the Bastion Host resource.')
param enableIpConnect bool = false

@description('Optional. Enable/Disable Shareable Link of the Bastion Host resource.')
param enableShareableLink bool = false

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

@allowed([
  'Basic'
  'Standard'
])
@description('Optional. The SKU of this Bastion Host.')
param skuType string = 'Basic'

@description('Optional. The scale units for the Bastion Host resource.')
param scaleUnits int = 2

@description('Optional. Array of role assignment objects that contain the \'roleDefinitionIdOrName\' and \'principalId\' to define RBAC role assignments on this resource. In the roleDefinitionIdOrName attribute, you can provide either the display name of the role definition, or its fully qualified ID in the following format: \'/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11\'.')
param roleAssignments array = []

@description('Optional. Tags of the resource.')
param tags object = {}

@description('Optional. Optional. The name of bastion logs that will be streamed.')
@allowed([
  'BastionAuditLogs'
])
param diagnosticLogCategoriesToEnable array = [
  'BastionAuditLogs'
]

@description('Optional. The name of the diagnostic setting, if deployed.')
param diagnosticSettingsName string = '${name}-diagnosticSettings'

var diagnosticsLogs = [for category in diagnosticLogCategoriesToEnable: {
  category: category
  enabled: true
  retentionPolicy: {
    enabled: true
    days: diagnosticLogsRetentionInDays
  }
}]

@description('Optional. The name of metrics that will be streamed.')
@allowed([
  'AllMetrics'
])
param diagnosticMetricsToEnable array = [
  'AllMetrics'
]

var diagnosticsMetrics = [for metric in diagnosticMetricsToEnable: {
  category: metric
  timeGrain: null
  enabled: true
  retentionPolicy: {
    enabled: true
    days: diagnosticLogsRetentionInDays
  }
}]

var scaleUnitsVar = skuType == 'Basic' ? 2 : scaleUnits

var additionalPublicIpConfigurationsVar = [for ipConfiguration in additionalPublicIpConfigurations: {
  name: ipConfiguration.name
  properties: {
    publicIPAddress: contains(ipConfiguration, 'publicIPAddressResourceId') ? {
      id: ipConfiguration.publicIPAddressResourceId
    } : null
  }
}]

// ----------------------------------------------------------------------------
// Prep ipConfigurations object AzureBastionSubnet for different uses cases:
// 1. Use existing public ip
// 2. Use new public ip created in this module
// 3. Do not use a public ip if isCreateDefaultPublicIP is false
var subnetVar = {
  subnet: {
    id: '${vNetId}/subnets/AzureBastionSubnet' // The subnet name must be AzureBastionSubnet
  }
}
var existingPip = {
  publicIPAddress: {
    id: azureBastionSubnetPublicIpId
  }
}
var newPip = {
  publicIPAddress: (empty(azureBastionSubnetPublicIpId) && isCreateDefaultPublicIP) ? {
    id: publicIPAddress.outputs.resourceId
  } : null
}

var ipConfigurations = concat([
  {
    name: 'IpConfAzureBastionSubnet'
    //Use existing public ip, new public ip created in this module, or none if isCreateDefaultPublicIP is false
    properties: union(subnetVar, !empty(azureBastionSubnetPublicIpId) ? existingPip : {}, (isCreateDefaultPublicIP ? newPip : {}))
  }
], additionalPublicIpConfigurationsVar)

// ----------------------------------------------------------------------------

module publicIPAddress '../publicIPAddresses/deploy.bicep' = if (empty(azureBastionSubnetPublicIpId) && isCreateDefaultPublicIP) {
  name: '${uniqueString(deployment().name, location)}-Bastion-PIP'
  params: {
    name: contains(publicIPAddressObject, 'name') ? publicIPAddressObject.name : '${name}-pip'
    diagnosticLogCategoriesToEnable: contains(publicIPAddressObject, 'diagnosticLogCategoriesToEnable') ? publicIPAddressObject.diagnosticLogCategoriesToEnable : [
      'DDoSProtectionNotifications'
      'DDoSMitigationFlowLogs'
      'DDoSMitigationReports'
    ]
    diagnosticMetricsToEnable: contains(publicIPAddressObject, 'diagnosticMetricsToEnable') ? publicIPAddressObject.diagnosticMetricsToEnable : [
      'AllMetrics'
    ]
    diagnosticStorageAccountId: diagnosticStorageAccountId
    diagnosticLogsRetentionInDays: diagnosticLogsRetentionInDays
    diagnosticWorkspaceId: diagnosticWorkspaceId
    diagnosticEventHubAuthorizationRuleId: diagnosticEventHubAuthorizationRuleId
    diagnosticEventHubName: diagnosticEventHubName
    location: location
    lock: lock
    publicIPAddressVersion: contains(publicIPAddressObject, 'publicIPAddressVersion') ? publicIPAddressObject.publicIPAddressVersion : 'IPv4'
    publicIPAllocationMethod: contains(publicIPAddressObject, 'publicIPAllocationMethod') ? publicIPAddressObject.publicIPAllocationMethod : 'Static'
    publicIPPrefixResourceId: contains(publicIPAddressObject, 'publicIPPrefixResourceId') ? publicIPAddressObject.publicIPPrefixResourceId : ''
    roleAssignments: contains(publicIPAddressObject, 'roleAssignments') ? publicIPAddressObject.roleAssignments : []
    skuName: contains(publicIPAddressObject, 'skuName') ? publicIPAddressObject.skuName : 'Standard'
    skuTier: contains(publicIPAddressObject, 'skuTier') ? publicIPAddressObject.skuTier : 'Regional'
    tags: tags
    zones: contains(publicIPAddressObject, 'zones') ? publicIPAddressObject.zones : []
  }
}

resource azureBastion 'Microsoft.Network/bastionHosts@2021-05-01' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: skuType
  }
  properties: {
    scaleUnits: scaleUnitsVar
    ipConfigurations: ipConfigurations
    disableCopyPaste: disableCopyPaste
    enableFileCopy: enableFileCopy
    enableTunneling: enableTunneling
    enableIpConnect: enableIpConnect
    enableShareableLink: enableShareableLink
  }
}

resource azureBastion_lock 'Microsoft.Authorization/locks@2017-04-01' = if (lock != 'NotSpecified') {
  name: '${azureBastion.name}-${lock}-lock'
  properties: {
    level: any(lock)
    notes: lock == 'CanNotDelete' ? 'Cannot delete resource or child resources.' : 'Cannot modify the resource or child resources.'
  }
  scope: azureBastion
}

resource azureBastion_diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(diagnosticStorageAccountId) || !empty(diagnosticWorkspaceId) || !empty(diagnosticEventHubAuthorizationRuleId) || !empty(diagnosticEventHubName)) {
  name: diagnosticSettingsName
  properties: {
    storageAccountId: !empty(diagnosticStorageAccountId) ? diagnosticStorageAccountId : null
    workspaceId: !empty(diagnosticWorkspaceId) ? diagnosticWorkspaceId : null
    eventHubAuthorizationRuleId: !empty(diagnosticEventHubAuthorizationRuleId) ? diagnosticEventHubAuthorizationRuleId : null
    eventHubName: !empty(diagnosticEventHubName) ? diagnosticEventHubName : null
    metrics: diagnosticsMetrics
    logs: diagnosticsLogs
  }
  scope: azureBastion
}

module azureBastion_rbac '.bicep/nested_roleAssignments.bicep' = [for (roleAssignment, index) in roleAssignments: {
  name: '${uniqueString(deployment().name, location)}-Bastion-Rbac-${index}'
  params: {
    description: contains(roleAssignment, 'description') ? roleAssignment.description : ''
    principalIds: roleAssignment.principalIds
    principalType: contains(roleAssignment, 'principalType') ? roleAssignment.principalType : ''
    roleDefinitionIdOrName: roleAssignment.roleDefinitionIdOrName
    resourceId: azureBastion.id
  }
}]

@description('The resource group the Azure Bastion was deployed into.')
output resourceGroupName string = resourceGroup().name

@description('The name the Azure Bastion.')
output name string = azureBastion.name

@description('The resource ID the Azure Bastion.')
output resourceId string = azureBastion.id

@description('The location the resource was deployed into.')
output location string = azureBastion.location

@description('The public ipconfiguration object for the AzureBastionSubnet.')
output ipConfAzureBastionSubnet object = azureBastion.properties.ipConfigurations[0]
