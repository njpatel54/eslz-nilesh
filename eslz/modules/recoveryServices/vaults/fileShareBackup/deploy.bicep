@description('subscriptionId for the deployment')
param subscriptionId string

@description('Name of the existing Resource Group in which the existing Storage Account is present.')
param stgAcctRgName string

@description('Name of the existing Storage Account in which the existing File Share to be protected is present.')
param stgAcctName string

@description('Name of the existing File Share to be protected.')
param fileShareName string

@description('Resource group where the Recovery Services Vault is located. This can be different than resource group of the Virtual Machines.')
param vaultRgName string

@description('Name of the Recovery Services Vault')
param vaultName string

@description('Name of the Backup policy to be used to backup VMs. Backup Policy defines the schedule of the backup and how long to retain backup copies. By default every vault comes with a \'DefaultPolicy\' which canbe used here.')
param backupPolicyName string

@description('Set to true if the existing Storage Account has to be registered to the Recovery Services Vault; set to false otherwise.')
param registerStorageAccount bool = true

var backupFabric = 'Azure'
var backupManagementType = 'AzureStorage'

resource protectionContainer 'Microsoft.RecoveryServices/vaults/backupFabrics/protectionContainers@2022-09-01-preview' = if (registerStorageAccount) {
  name: '${vaultName}/${backupFabric}/storagecontainer;Storage;${stgAcctRgName};${stgAcctName}'
  properties: {
    backupManagementType: backupManagementType
    containerType: 'StorageContainer'
    sourceResourceId: resourceId(stgAcctRgName, 'Microsoft.Storage/storageAccounts', stgAcctName)
  }
}

resource protectedItem 'Microsoft.RecoveryServices/vaults/backupFabrics/protectionContainers/protectedItems@2022-09-01-preview' = {
  parent: protectionContainer
  name: 'AzureFileShare;${fileShareName}'
  properties: {
    protectedItemType: 'AzureFileShareProtectedItem'
    sourceResourceId: resourceId(stgAcctRgName, 'Microsoft.Storage/storageAccounts', stgAcctName)
    policyId: resourceId(subscriptionId, vaultRgName, 'Microsoft.RecoveryServices/vaults/backupPolicies', vaultName, backupPolicyName)
    //isInlineInquiry: true
  }
}
