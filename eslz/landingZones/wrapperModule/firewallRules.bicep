
@description('Location for the deployments and the resources')
param location string

@description('Required. Subscription ID of Connectivity Subscription')
param connsubid string

@description('Required. Subscription ID of Connectivity Subscription')
param connVnetRgName string

@description('Required. Firewall Policy name.')
param firewallPolicyName string

@description('Optional. Rule collection groups.')
param firewallPolicyRuleCollectionGroups array

// 1. Update Firewall Policy Rule Collection Groups
module afwp '../../modules/network/firewallPolicies/ruleCollectionGroups/deploy.bicep' = [for (firewallPolicyRuleCollectionGroup, i) in firewallPolicyRuleCollectionGroups: {
  name: 'afwp-${take(uniqueString(deployment().name, location), 4)}-${firewallPolicyRuleCollectionGroup.name}'
  scope: resourceGroup(connsubid, connVnetRgName)
  params: {
    firewallPolicyName: firewallPolicyName
    name: firewallPolicyRuleCollectionGroup.name
    ruleCollections: firewallPolicyRuleCollectionGroup.ruleCollections
    priority: firewallPolicyRuleCollectionGroup.priority
  }
}]
