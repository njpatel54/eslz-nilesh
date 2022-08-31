param armProviderNamespace string
param vaultName string
param vaultRG string
param vaultSubID string
param policyName string
param fabricName string
param protectionContainers array
param protectedItems array
param sourceResourceIds array
param extendedProperties array

resource vaultName_fabricName_protectionContainers_protectedItems 'Microsoft.RecoveryServices/vaults/backupFabrics/protectionContainers/protectedItems@2016-06-01' = [for (item, i) in protectedItems: {
  name: '${vaultName}/${fabricName}/${protectionContainers[i]}/${item}'
  properties: {
    protectedItemType: 'Microsoft.ClassicCompute/virtualMachines'
    policyId: resourceId('${armProviderNamespace}/vaults/backupPolicies', vaultName, policyName)
    sourceResourceId: sourceResourceIds[i]
    extendedProperties: extendedProperties[i]
  }
}]