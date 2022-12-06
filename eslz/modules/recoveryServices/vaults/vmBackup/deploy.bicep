@description('subscriptionId for the deployment')
param subscriptionId string

@description('Resource group where the virtual machines are located. This can be different than resource group of the vault.')
param vmRgName string

@description('Name of the Virtual Machine. e.g. "vm1"')
param vmName string

@description('Resource group where the Recovery Services Vault is located. This can be different than resource group of the Virtual Machines.')
param vaultRgName string

@description('Name of the Recovery Services Vault')
param vaultName string

@description('Name of the Backup policy to be used to backup VMs. Backup Policy defines the schedule of the backup and how long to retain backup copies. By default every vault comes with a \'DefaultPolicy\' which canbe used here.')
param backupPolicyName string

@description('Location for all resources.')
param location string = resourceGroup().location

var backupFabric = 'Azure'
var v2VmType = 'Microsoft.Compute/virtualMachines'
var v2VmContainer = 'iaasvmcontainer;iaasvmcontainerv2;'
var v2Vm = 'vm;iaasvmcontainerv2;'

resource protectedItems 'Microsoft.RecoveryServices/vaults/backupFabrics/protectionContainers/protectedItems@2021-03-01' = {
  name: '${vaultName}/${backupFabric}/${v2VmContainer}${vmRgName};${vmName}/${v2Vm}${vmRgName};${vmName}'
  location: location
  properties: {
    protectedItemType: v2VmType
    policyId: resourceId(subscriptionId, vaultRgName, 'Microsoft.RecoveryServices/vaults/backupPolicies', vaultName, backupPolicyName)
    sourceResourceId: resourceId(subscriptionId, vmRgName, 'Microsoft.Compute/virtualMachines', vmName)
  }
}
