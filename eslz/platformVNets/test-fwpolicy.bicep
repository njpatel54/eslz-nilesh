targetScope = 'subscription'

@description('Required. Hub - Network Security Groups Array.')
param hubNetworkSecurityGroups array

@description('Required. Subscription ID.')
param hubVnetSubscriptionId string

@description('Required. The Virtual Network (vNet) Name.')
param hubVnetName string

@description('Required. An Array of 1 or more IP Address Prefixes for the Virtual Network.')
param hubVnetAddressPrefixes array

@description('Optional. An Array of subnets to deploy to the Virtual Network.')
param hubVnetSubnets array = []

@description('Optional. Hub Virtual Network configurations.')
param spokeVnets array = []

@description('Optional. Virtual Network Peerings configurations')
param hubVnetVirtualNetworkPeerings array = []

@description('Optional. Resource ID of the diagnostic storage account.')
param diagnosticStorageAccountId string = ''

@description('Optional. Resource ID of the diagnostic log analytics workspace.')
param diagnosticWorkspaceId string = ''

@description('Optional. Resource ID of the diagnostic event hub authorization rule for the Event Hubs namespace in which the event hub should be created or streamed to.')
param diagnosticEventHubAuthorizationRuleId string = ''

@description('Optional. Name of the diagnostic event hub within the namespace to which logs are streamed. Without this, an event hub is created for each log category.')
param diagnosticEventHubName string = ''

@description('Required. utcfullvalue to be used in Tags.')
param utcfullvalue string = utcNow('F')

@description('Required. Resource Tags.')
param tags object

@description('Required. Assign utffullvaule to "CreatedOn" tag.')
param dynamictags object = ({
  CreatedOn: utcfullvalue
})

@description('Required. Combine Tags in dynamoctags object with Tags from parameter file.')
var combinedTags = union(dynamictags, tags)

@description('Required. Project Owner (projowner) parameter.')
@allowed([
  'ccs'
  'proj'
])
param projowner string

@description('Required. Operational Scope (opscope) parameter.')
@allowed([
  'prod'
  'dev'
  'qa'
  'stage'
  'test'
  'sand'
])
param opscope string

@description('Required. Region (region) parameter.')
@allowed([
  'usva'
  'ustx'
  'usaz'
])
param region string

@description('Required. Location for all resources.')
param location string

@description('Required. Resource Group name.')
param resourceGroupName string = 'rg-${projowner}-${opscope}-${region}-vnet'

@description('Required. Firewall Public IP name.')
param firewallPublicIPName string = 'pip-${projowner}-${opscope}-${region}-fwip'

@description('Required. Firewall Public IP SKU name.')
param publicIPSkuName string

@description('Required. Firewall Public IP allocation method.')
param publicIPAllocationMethod string

@description('Required. Firewall Public IP zones.')
param publicIPzones array

@description('Required. Firewall Policy name.')
param firewallPolicyName string = 'afwp-${projowner}-${opscope}-${region}-0001'

@description('Optional. Rule collection groups.')
param firewallPolicyRuleCollectionGroups array = []

@description('Required. Firewall name.')
param firewallName string = 'afw-${projowner}-${opscope}-${region}-0001'

@description('Optional. Zone numbers e.g. 1,2,3.')
param firewallZones array

@description('Optional. Array of role assignment objects that contain the \'roleDefinitionIdOrName\' and \'principalId\' to define RBAC role assignments on this resource. In the roleDefinitionIdOrName attribute, you can provide either the display name of the role definition, or its fully qualified ID in the following format: \'/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11\'')
param firewallRoleAssignments array = []

@description('Required. Bastion Host Public IP name.')
param bastionHostPublicIPName string = 'pip-${projowner}-${opscope}-${region}-bhip'

@description('Required. Bastion Host name.')
param bastionHostName string = 'bas-${projowner}-${opscope}-${region}-0001'

@description('Required. Bastion Host sku type.')
param bastionHostSkuType string

@description('Required. Bastion Host scale units.')
param bastionHostScaleUnits int

@description('Optional. Array of role assignment objects that contain the \'roleDefinitionIdOrName\' and \'principalId\' to define RBAC role assignments on this resource. In the roleDefinitionIdOrName attribute, you can provide either the display name of the role definition, or its fully qualified ID in the following format: \'/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11\'')
param bastionHostRoleAssignments array = []


module hubRg '../modules/resourceGroups/deploy.bicep'= {
  name: 'rg-${hubVnetSubscriptionId}-${resourceGroupName}'
  scope: subscription(hubVnetSubscriptionId)
  params: {
    name: resourceGroupName
    location: location
    tags: combinedTags
  }
}

module afwp '../modules/network/firewallPolicies/deploy.bicep' = {
  name: 'afwp-${take(uniqueString(deployment().name, location), 4)}-${firewallPolicyName}'
  scope: resourceGroup(hubVnetSubscriptionId, resourceGroupName)
  dependsOn: [
    hubRg
  ]
  params:{
    name: firewallPolicyName
    location: location
    tags: combinedTags
    tier: 'Premium'
    defaultWorkspaceId: '/subscriptions/aa2a513a-47e2-4a0d-8d39-0a3d5dd0f889/resourcegroups/rg-ccs-prod-usva-siem/providers/microsoft.operationalinsights/workspaces/log-ccs-prod-usva-siem'
    insightsIsEnabled: true
    //ruleCollectionGroups: firewallPolicyRuleCollectionGroups    
  }
}
