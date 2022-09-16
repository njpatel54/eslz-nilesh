targetScope = 'managementGroup'

@description('Required. Location for all resources.')
param location string

@description('subscriptionId for the deployment')
param subscriptionId string = 'df3b1809-17d0-47a0-9241-d2724780bdac'

@description('Required. Parameter for "Deploy-VM-Backup" policy assignment')
param deployVMBackup object

// Create Policy Assignment & Remediation for Exisiting Resources
module policyAssignment 'wrapperModule/polAssignment.bicep' = {
  name: 'mod-policyAssignment-${take(uniqueString(deployment().name, location), 4)}'
  params: {
    subscriptionId: subscriptionId
    deployVMBackup: deployVMBackup
  }
}
