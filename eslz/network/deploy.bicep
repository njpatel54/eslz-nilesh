
@description('Optional. Hub Virtual Network configurations.')
param spokeVnets array = []

@description('Required. The Virtual Network (vNet) Name.')
param name string

@description('Optional. Location for all resources.')
param location string = resourceGroup().location

@description('Optional. The subscription ID of the subscription for the virtual network')
param subscriptionId string = ''

@description('Optional. The name of the resource group for the virtual network')
param resourceGroupName string = ''

@description('Required. An Array of 1 or more IP Address Prefixes for the Virtual Network.')
param addressPrefixes array

@description('Optional. An Array of subnets to deploy to the Virtual Network.')
param subnets array = []

@description('Optional. Tags of the resource.')
param tags object = {}

@description('Optional. DNS Servers associated to the Virtual Network.')
param dnsServers array = []

@description('Optional. Resource ID of the DDoS protection plan to assign the VNET to. If it\'s left blank, DDoS protection will not be configured. If it\'s provided, the VNET created by this template will be attached to the referenced DDoS protection plan. The DDoS protection plan can exist in the same or in a different subscription.')
param ddosProtectionPlanId string = ''

var dnsServers_var = {
  dnsServers: array(dnsServers)
}
var ddosProtectionPlan = {
  id: ddosProtectionPlanId
}

@description('Optional. The name of the diagnostic setting, if deployed.')
param diagnosticSettingsName string = '${name}-diagnosticSettings'

@description('Optional. Specifies the number of days that logs will be kept for; a value of 0 will retain data indefinitely.')
@minValue(0)
@maxValue(365)
param diagnosticLogsRetentionInDays int = 365

/*
@description('Optional. The name of logs that will be streamed.')
@allowed([
  'VMProtectionAlerts'
])
param diagnosticLogCategoriesToEnable array = [
  'VMProtectionAlerts'
]

var diagnosticsLogs = [for category in diagnosticLogCategoriesToEnable: {
  category: category
  enabled: true
  retentionPolicy: {
    enabled: true
    days: diagnosticLogsRetentionInDays
  }
}]
*/
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

resource hubVnet 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: addressPrefixes
    }
    ddosProtectionPlan: !empty(ddosProtectionPlanId) ? ddosProtectionPlan : null
    dhcpOptions: !empty(dnsServers) ? dnsServers_var : null
    enableDdosProtection: !empty(ddosProtectionPlanId)
    subnets: [for subnet in subnets: {
      name: subnet.name
      properties: {
        addressPrefix: subnet.addressPrefix
        addressPrefixes: contains(subnet, 'addressPrefixes') ? subnet.addressPrefixes : []
        applicationGatewayIpConfigurations: contains(subnet, 'applicationGatewayIpConfigurations') ? subnet.applicationGatewayIpConfigurations : []
        delegations: contains(subnet, 'delegations') ? subnet.delegations : []
        ipAllocations: contains(subnet, 'ipAllocations') ? subnet.ipAllocations : []
        natGateway: contains(subnet, 'natGatewayId') ? {
          'id': subnet.natGatewayId
        } : json('null')
        networkSecurityGroup: contains(subnet, 'networkSecurityGroupId') ? {
          'id': subnet.networkSecurityGroupId
        } : json('null')
        privateEndpointNetworkPolicies: contains(subnet, 'privateEndpointNetworkPolicies') ? subnet.privateEndpointNetworkPolicies : null
        privateLinkServiceNetworkPolicies: contains(subnet, 'privateLinkServiceNetworkPolicies') ? subnet.privateLinkServiceNetworkPolicies : null
        routeTable: contains(subnet, 'routeTableId') ? {
          'id': subnet.routeTableId
        } : json('null')
        serviceEndpoints: contains(subnet, 'serviceEndpoints') ? subnet.serviceEndpoints : []
        serviceEndpointPolicies: contains(subnet, 'serviceEndpointPolicies') ? subnet.serviceEndpointPolicies : []
      }
    }]
  }
}

module spokeVnet 'virtualNetworks/deploy.bicep' = [ for (vNet, index) in spokeVnets : {
  name: 'VNet-Module-${vNet.name}'
  scope: resourceGroup(vNet.subscriptionId, vNet.resourceGroupName)
  params: {
    hubVnetName: hubVnet.name
    hubVnetId: hubVnet.id
    name: vNet.name
    location: location
    addressPrefixes: vNet.addressPrefixes
    diagnosticStorageAccountId: diagnosticStorageAccountId
    diagnosticWorkspaceId: diagnosticWorkspaceId
    diagnosticEventHubAuthorizationRuleId: diagnosticEventHubAuthorizationRuleId
    diagnosticEventHubName: diagnosticEventHubName
    //ddosProtectionPlan: !empty(ddosProtectionPlanId) ? ddosProtectionPlan : null
    //dhcpOptions: !empty(dnsServers) ? dnsServers_var : null
    //enableDdosProtection: !empty(ddosProtectionPlanId)
    subnets: [for subnet in vNet.subnets: {
      name: subnet.name
      addressPrefix: subnet.addressPrefix
      addressPrefixes: contains(subnet, 'addressPrefixes') ? subnet.addressPrefixes : []
      applicationGatewayIpConfigurations: contains(subnet, 'applicationGatewayIpConfigurations') ? subnet.applicationGatewayIpConfigurations : []
      delegations: contains(subnet, 'delegations') ? subnet.delegations : []
      ipAllocations: contains(subnet, 'ipAllocations') ? subnet.ipAllocations : []
      natGateway: contains(subnet, 'natGatewayId') ? {
        'id': subnet.natGatewayId
      } : json('null')
      networkSecurityGroup: contains(subnet, 'networkSecurityGroupId') ? {
        'id': subnet.networkSecurityGroupId
      } : json('null')
      privateEndpointNetworkPolicies: contains(subnet, 'privateEndpointNetworkPolicies') ? subnet.privateEndpointNetworkPolicies : null
      privateLinkServiceNetworkPolicies: contains(subnet, 'privateLinkServiceNetworkPolicies') ? subnet.privateLinkServiceNetworkPolicies : null
      routeTable: contains(subnet, 'routeTableId') ? {
        'id': subnet.routeTableId
      } : json('null')
      serviceEndpoints: contains(subnet, 'serviceEndpoints') ? subnet.serviceEndpoints : []
      serviceEndpointPolicies: contains(subnet, 'serviceEndpointPolicies') ? subnet.serviceEndpointPolicies : []
      }]
  }
}]


resource virtualNetwork_lock 'Microsoft.Authorization/locks@2017-04-01' = if (lock != 'NotSpecified') {
  name: '${hubVnet.name}-${lock}-lock'
  properties: {
    level: lock
    notes: lock == 'CanNotDelete' ? 'Cannot delete resource or child resources.' : 'Cannot modify the resource or child resources.'
  }
  scope: hubVnet
}

resource virtualNetwork_diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(diagnosticStorageAccountId) || !empty(diagnosticWorkspaceId) || !empty(diagnosticEventHubAuthorizationRuleId) || !empty(diagnosticEventHubName)) {
  name: diagnosticSettingsName
  properties: {
    storageAccountId: !empty(diagnosticStorageAccountId) ? diagnosticStorageAccountId : null
    workspaceId: !empty(diagnosticWorkspaceId) ? diagnosticWorkspaceId : null
    eventHubAuthorizationRuleId: !empty(diagnosticEventHubAuthorizationRuleId) ? diagnosticEventHubAuthorizationRuleId : null
    eventHubName: !empty(diagnosticEventHubName) ? diagnosticEventHubName : null
    metrics: diagnosticsMetrics
    //logs: diagnosticsLogs
  }
  scope: hubVnet
}






































/*

module virtualNetwork_rbac '.bicep/nested_rbac.bicep' = [for (roleAssignment, index) in roleAssignments: {
  name: '${uniqueString(deployment().name, location)}-VNet-Rbac-${index}'
  params: {
    description: contains(roleAssignment, 'description') ? roleAssignment.description : ''
    principalIds: roleAssignment.principalIds
    principalType: contains(roleAssignment, 'principalType') ? roleAssignment.principalType : ''
    roleDefinitionIdOrName: roleAssignment.roleDefinitionIdOrName
    resourceId: virtualNetwork.id
  }
}]

@description('Optional. Hub Virtual Network configurations.')
param hubVirtualNetwork array = []

@description('Optional. Array of role assignment objects that contain the \'roleDefinitionIdOrName\' and \'principalId\' to define RBAC role assignments on this resource. In the roleDefinitionIdOrName attribute, you can provide either the display name of the role definition, or its fully qualified ID in the following format: \'/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11\'')
param roleAssignments array = []

@description('The resource group the virtual network was deployed into')
output resourceGroupName string = resourceGroup().name

@description('The resource ID of the virtual network')
output resourceId string = virtualNetwork.id

@description('The name of the virtual network')
output name string = virtualNetwork.name

@description('The names of the deployed subnets')
output subnetNames array = [for subnet in subnets: subnet.name]

@description('The resource IDs of the deployed subnets')
output subnetResourceIds array = [for subnet in subnets: az.resourceId('Microsoft.Network/virtualNetworks/subnets', name, subnet.name)]
*/
