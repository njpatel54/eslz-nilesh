@sys.description('Required. Project Owner (projowner) parameter.')
@allowed([
  'ccs'
  'proj'
])
param projowner string = 'ccs'

@sys.description('Required. Operational Scope (opscope) parameter.')
@allowed([
  'prod'
  'dev'
  'qa'
  'stage'
  'test'
  'sand'
])
param opscope string = 'prod'

@sys.description('Required. Region (region) parameter.')
@allowed([
  'usva'
  'ustx'
  'usaz'
])
param region string = 'usva'

@sys.description('Required. Resource Group name.')
param resourceGroupName string = 'rg-${projowner}-${opscope}-${region}-vnet'

@sys.description('Optional. Hub Virtual Network configurations.')
param spokeVnets array = []

@sys.description('Required. Name of the custom RBAC role to be created.')
param roleName string

@sys.description('Optional. Description of the custom RBAC role to be created.')
param description string = ''

@sys.description('Optional. List of allowed actions.')
param actions array = []

@sys.description('Optional. List of denied actions.')
param notActions array = []

@sys.description('Optional. List of allowed data actions. This is not supported if the assignableScopes contains Management Group Scopes.')
param dataActions array = []

@sys.description('Optional. List of denied data actions. This is not supported if the assignableScopes contains Management Group Scopes.')
param notDataActions array = []

@sys.description('Optional. The group ID of the Management Group where the Role Definition and Target Scope will be applied to. If not provided, will use the current scope for deployment.')
param managementGroupId string

@sys.description('Optional. The subscription ID where the Role Definition and Target Scope will be applied to. Use for both Subscription level and Resource Group Level.')
param subscriptionId string = ''

@sys.description('Optional. Role definition assignable scopes. If not provided, will use the current scope provided.')
param assignableScopes array = []

@sys.description('Required. Load content from json file.')
var vNets = json(loadTextContent('../platformVNets/.parameters/parameters.json'))

// Variables created to be used as an 'assignableScopes' for Custom RBAC Role(s)
@sys.description('Required. Iterate over each "spokeVnets" and build "resourceId" of ResourceGroup using "subscriptionId" and "resourceGroupName".')
var spokeVNetsRgResourceIdsAssignableScopes = [for vNet in vNets.parameters.spokeVnets.value: '/subscriptions/${vNet.subscriptionId}/resourceGroups/${resourceGroupName}']

@sys.description('Required. Build "resourceId" of ResourceGroup using "hubVnetSubscriptionId" and "resourceGroupName".')
var hubVNetRgResourceIdsAssignableScopes = ['/subscriptions/${vNets.parameters.hubVnetSubscriptionId.value}/resourceGroups/${resourceGroupName}']

// 1 - Create Custom RBAC Role Definition(s) at RG Scope (Spoke Networks)
// Role Definition Name --> "Deploy Private Endpoint - Networking Permissions)"
module vNetRgCustomRbacSpoke '../modules/authorization/roleDefinitions/resourceGroup/deploy.bicep' = [ for (spokeVnet, index) in spokeVnets: {
  name: 'vNetRgCustomRbac-${resourceGroupName}-${index}'
  scope: resourceGroup(spokeVnet.subscriptionId, resourceGroupName)
  params: { 
    roleName: roleName
    description: description
    actions: actions
    notActions: notActions
    dataActions: dataActions
    notDataActions: notDataActions
    assignableScopes: spokeVNetsRgResourceIdsAssignableScopes
    subscriptionId: subscriptionId
    resourceGroupName: resourceGroupName
  }
}]

// 2 - Create Custom RBAC Role Definition(s) at RG Scope (Hub Network)
// Role Definition Name --> "Deploy Private Endpoint - Networking Permissions)"
module vNetRgCustomRbacHub '../modules/authorization/roleDefinitions/resourceGroup/deploy.bicep' = {
  name: 'vNetRgCustomRbac-${resourceGroupName}'
  scope: resourceGroup(vNets.parameters.hubVnetSubscriptionId.value, resourceGroupName)
  params: { 
    roleName: roleName
    description: description
    actions: actions
    notActions: notActions
    dataActions: dataActions
    notDataActions: notDataActions
    assignableScopes: hubVNetRgResourceIdsAssignableScopes
    subscriptionId: subscriptionId
    resourceGroupName: resourceGroupName
  }
}


// Start - Outputs to supress warnings - "unused parameters"
output managementGroupId string = managementGroupId
output assignableScopes array = assignableScopes
// End - Outputs to supress warnings - "unused parameters"
