
@description('Optional. Hub Virtual Network configurations.')
param spokeVnets array = []

@description('Optional. Hub Virtual Network configurations.')
param hubVirtualNetwork array = []

@description('Required. The Virtual Network (vNet) Name.')
param name string

@description('Optional. Location for all resources.')
param location string = resourceGroup().location

@description('Required. An Array of 1 or more IP Address Prefixes for the Virtual Network.')
param addressPrefixes array

@description('Optional. An Array of subnets to deploy to the Virtual Network.')
param subnets array = []

@description('Optional. Virtual Network Peerings configurations.')
param virtualNetworkPeerings array = []

@sys.description('Optional. The subscription ID of the subscription for the virtual network')
param subscriptionId string = ''

@sys.description('Optional. The name of the resource group for the virtual network')
param resourceGroupName string = ''

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

// Spoke vNets to HubvNet Peering
module virtualNetwork_peering_local 'virtualNetworks/virtualNetworkPeerings/deploy.bicep' = [ for (vNet, index) in spokeVnets : {
  name: '${uniqueString(deployment().name, vNet.name)}-virtualNetworkPeering-local-${index}'
  scope: resourceGroup(vNet.subscriptionId, vNet.resourceGroupName)
  params: {
    localVnetName: vNet.name
    remoteVirtualNetworkId: '/subscriptions/e6c61ac5-feea-4459-93fc-7131f8352553/resourceGroups/rg-ccs-prod-usva-vnet/providers/Microsoft.Network/virtualNetworks/vnet-ccs-prod-usva-conn' //hubVnet.id  
  }
}]






























/*

// Local to Remote peering
// Spoke to Hub Peering
module virtualNetwork_peering_local './virtualNetworkPeerings/deploy.bicep' = [for vnets in spokeVirtualNetworks: {
  name: '${uniqueString(vnets.name, location)}-virtualNetworkPeering-local'
  params: {
    localVnetName: virtualNetwork.name    
    remoteVirtualNetworkId: az.resourceId(vnets.subscriptionId, vnets.resourceGroupName, 'Microsoft.Network/virtualNetworks', vnets.name)                                  //peering.virtualNetworkPeerings.remoteVirtualNetworkName
    name: contains(vnets.virtualNetworkPeerings, 'name') ? vnets.virtualNetworkPeerings.name : '${vnets.name}-${last(split(vnets.virtualNetworkPeerings.remoteVirtualNetworkId, '/'))}'
    allowForwardedTraffic: contains(vnets.virtualNetworkPeerings, 'allowForwardedTraffic') ? vnets.virtualNetworkPeerings.allowForwardedTraffic : true
    allowGatewayTransit: contains(vnets.virtualNetworkPeerings, 'allowGatewayTransit') ? vnets.virtualNetworkPeerings.allowGatewayTransit : false
    allowVirtualNetworkAccess: contains(vnets.virtualNetworkPeerings, 'allowVirtualNetworkAccess') ? vnets.virtualNetworkPeerings.allowVirtualNetworkAccess : true
    doNotVerifyRemoteGateways: contains(vnets.virtualNetworkPeerings, 'doNotVerifyRemoteGateways') ? vnets.virtualNetworkPeerings.doNotVerifyRemoteGateways : true
    useRemoteGateways: contains(vnets.virtualNetworkPeerings, 'useRemoteGateways') ? vnets.virtualNetworkPeerings.useRemoteGateways : false
   }
  
}]

// Local to Remote peering
module virtualNetwork_peering_local 'virtualNetworkPeerings/deploy.bicep' = [for (peering, index) in virtualNetworkPeerings: {
  name: '${uniqueString(deployment().name, location)}-virtualNetworkPeering-local-${index}'
  params: {
    localVnetName: virtualNetwork.name
    remoteVirtualNetworkId: peering.remoteVirtualNetworkId
    name: contains(peering, 'name') ? peering.name : '${name}-${last(split(peering.remoteVirtualNetworkId, '/'))}'
    allowForwardedTraffic: contains(peering, 'allowForwardedTraffic') ? peering.allowForwardedTraffic : true
    allowGatewayTransit: contains(peering, 'allowGatewayTransit') ? peering.allowGatewayTransit : false
    allowVirtualNetworkAccess: contains(peering, 'allowVirtualNetworkAccess') ? peering.allowVirtualNetworkAccess : true
    doNotVerifyRemoteGateways: contains(peering, 'doNotVerifyRemoteGateways') ? peering.doNotVerifyRemoteGateways : true
    useRemoteGateways: contains(peering, 'useRemoteGateways') ? peering.useRemoteGateways : false
    enableDefaultTelemetry: enableChildTelemetry
  }
}]

// Remote to local peering (reverse)
module virtualNetwork_peering_remote 'virtualNetworkPeerings/deploy.bicep' = [for (peering, index) in virtualNetworkPeerings: if (contains(peering, 'remotePeeringEnabled') ? peering.remotePeeringEnabled == true : false) {
  name: '${uniqueString(deployment().name, location)}-virtualNetworkPeering-remote-${index}'
  scope: resourceGroup(split(peering.remoteVirtualNetworkId, '/')[2], split(peering.remoteVirtualNetworkId, '/')[4])
  params: {
    localVnetName: last(split(peering.remoteVirtualNetworkId, '/'))
    remoteVirtualNetworkId: virtualNetwork.id
    name: contains(peering, 'remotePeeringName') ? peering.remotePeeringName : '${last(split(peering.remoteVirtualNetworkId, '/'))}-${name}'
    allowForwardedTraffic: contains(peering, 'remotePeeringAllowForwardedTraffic') ? peering.remotePeeringAllowForwardedTraffic : true
    allowGatewayTransit: contains(peering, 'remotePeeringAllowGatewayTransit') ? peering.remotePeeringAllowGatewayTransit : false
    allowVirtualNetworkAccess: contains(peering, 'remotePeeringAllowVirtualNetworkAccess') ? peering.remotePeeringAllowVirtualNetworkAccess : true
    doNotVerifyRemoteGateways: contains(peering, 'remotePeeringDoNotVerifyRemoteGateways') ? peering.remotePeeringDoNotVerifyRemoteGateways : true
    useRemoteGateways: contains(peering, 'remotePeeringUseRemoteGateways') ? peering.remotePeeringUseRemoteGateways : false
    
  }
}]

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

var diagnosticsMetrics = [for metric in diagnosticMetricsToEnable: {
  category: metric
  timeGrain: null
  enabled: true
  retentionPolicy: {
    enabled: true
    days: diagnosticLogsRetentionInDays
  }
}]

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

@description('Optional. Array of role assignment objects that contain the \'roleDefinitionIdOrName\' and \'principalId\' to define RBAC role assignments on this resource. In the roleDefinitionIdOrName attribute, you can provide either the display name of the role definition, or its fully qualified ID in the following format: \'/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11\'')
param roleAssignments array = []

@description('Optional. The name of logs that will be streamed.')
@allowed([
  'VMProtectionAlerts'
])
param diagnosticLogCategoriesToEnable array = [
  'VMProtectionAlerts'
]

@description('Optional. The name of metrics that will be streamed.')
@allowed([
  'AllMetrics'
])
param diagnosticMetricsToEnable array = [
  'AllMetrics'
]



resource virtualNetwork_lock 'Microsoft.Authorization/locks@2017-04-01' = if (lock != 'NotSpecified') {
  name: '${virtualNetwork.name}-${lock}-lock'
  properties: {
    level: lock
    notes: lock == 'CanNotDelete' ? 'Cannot delete resource or child resources.' : 'Cannot modify the resource or child resources.'
  }
  scope: virtualNetwork
}

resource virtualNetwork_diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(diagnosticStorageAccountId) || !empty(diagnosticWorkspaceId) || !empty(diagnosticEventHubAuthorizationRuleId) || !empty(diagnosticEventHubName)) {
  name: diagnosticSettingsName
  properties: {
    storageAccountId: !empty(diagnosticStorageAccountId) ? diagnosticStorageAccountId : null
    workspaceId: !empty(diagnosticWorkspaceId) ? diagnosticWorkspaceId : null
    eventHubAuthorizationRuleId: !empty(diagnosticEventHubAuthorizationRuleId) ? diagnosticEventHubAuthorizationRuleId : null
    eventHubName: !empty(diagnosticEventHubName) ? diagnosticEventHubName : null
    metrics: diagnosticsMetrics
    logs: diagnosticsLogs
  }
  scope: virtualNetwork
}

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
