targetScope = 'managementGroup'

@description('Location for the deployments and the resources')
param location string

@description('Required. Combine Tags in dynamoctags object with Tags from parameter file.')
param combinedTags object

@description('subscriptionId for the deployment')
param subscriptionId string

@description('Required. Name of the resourceGroup, where application workload will be deployed.')
param wlRgName string

@description('Required. Subnet resoruceId for Network Interface Card.')
param subnetResourceId string

@description('Optional. Resource ID of the diagnostic log analytics workspace.')
param diagnosticWorkspaceId string = ''

@description('Optional. Resource ID of the monitoring log analytics workspace. Must be set when extensionMonitoringAgentConfig is set to true.')
param monitoringWorkspaceId string = ''

@description('Optional. Specifies the time zone of the virtual machine. e.g. \'Pacific Standard Time\'. Possible values can be `TimeZoneInfo.id` value from time zones returned by `TimeZoneInfo.GetSystemTimeZones`.')
param timeZone string = 'Eastern Standard Time'

/*
@description('Optional. The configuration for the [Key Vault] extension. Must at least contain the ["enabled": true] property to be executed.')
param extensionKeyVaultConfig object = {
  enabled: false
}
*/
var operatingSystemValues = {
  Server2012R2: {
    publisher: 'MicrosoftWindowsServer'
    offer: 'WindowsServer'
    sku: '2012-R2-Datacenter'
  }
  Server2016: {
    publisher: 'MicrosoftWindowsServer'
    offer: 'WindowsServer'
    sku: '2016-Datacenter'
  }
  Server2019: {
    publisher: 'MicrosoftWindowsServer'
    offer: 'WindowsServer'
    sku: '2019-Datacenter'
  }
  Server2022: {
    publisher: 'MicrosoftWindowsServer'
    offer: 'WindowsServer'
    sku: '2022-datacenter'
  }
  UbuntuServer1604LTS: {
    publisher: 'Canonical'
    offer: 'UbuntuServer'
    sku: '16.04-LTS'
  }
  UbuntuServer1804LTS: {
    publisher: 'Canonical'
    offer: 'UbuntuServer'
    sku: '18.04-LTS'
  }
  UbuntuServer1904: {
    publisher: 'Canonical'
    offer: 'UbuntuServer'
    sku: '19.04'
  }
  RedHat85Gen2: {
    publisher: 'RedHat'
    offer: 'RHEL'
    sku: '85-gen2'
  }
  RedHat86Gen2: {
    publisher: 'RedHat'
    offer: 'RHEL'
    sku: '86-gen2'
  }
  RedHat90Gen2: {
    publisher: 'RedHat'
    offer: 'RHEL'
    sku: '90-gen2'
  }
}

@description('Name of the virtual machine to be created')
@maxLength(15)
param virtualMachineNamePrefix string

@description('Optional. The array of Virtual Machines.')
param virtualMachines array

@description('Required. "projowner" parameter used for Platform.')
param platformProjOwner string

@description('Required. "opscope" parameter used for Platform.')
param platformOpScope string

@description('Required. Region (region) parameter.')
@allowed([
  'usva'
  'ustx'
  'usaz'
])
param region string

@description('Required. Subscription ID of Management Subscription.')
param mgmtsubid string

@description('Required. SIEM Resource Group Name.')
param siemRgName string = 'rg-${platformProjOwner}-${platformOpScope}-${region}-siem'

@description('Required. Name of the Key Vault. Must be globally unique.')
@maxLength(24)
param akvName string = toLower(take('kv-${platformProjOwner}-${platformOpScope}-${region}-siem', 24))
/*
@description('Optional. The configuration for the [Custom Script] extension. Must at least contain the ["enabled": true] property to be executed.')
param extensionCustomScriptConfig object = {
  enabled: false
  fileData: []
}
*/
// 1. Retrieve an exisiting Key Vault (From Management Subscription)
resource akv 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: akvName
  scope: resourceGroup(mgmtsubid, siemRgName)
}
// 2. Create Virtual Machines
module lzVm '../../modules/compute/virtualMachines/deploy.bicep' = [for (virtualMachine, i) in virtualMachines: {
  name: 'lzVm-${take(uniqueString(deployment().name, location), 4)}-${virtualMachineNamePrefix}${i + 1}'
  scope: resourceGroup(subscriptionId, wlRgName)
  params: {
    name: '${virtualMachineNamePrefix}${i + 1}'
    location: location
    tags: combinedTags
    adminUsername: akv.getSecret(virtualMachine.vmAdmin)
    adminPassword: akv.getSecret(virtualMachine.vmAdminPassword)
    vmComputerNamesTransformation: 'lowercase'
    osType: virtualMachine.osType
    vmSize: virtualMachine.virtualMachineSize
    licenseType: virtualMachine.licenseType
    timeZone: timeZone
    availabilityZone: virtualMachine.availabilityZone
    imageReference: {
      publisher: operatingSystemValues[virtualMachine.operatingSystem].publisher
      offer: operatingSystemValues[virtualMachine.operatingSystem].offer
      sku: operatingSystemValues[virtualMachine.operatingSystem].sku
      version: 'latest'
    }
    osDisk: {
      createOption: 'FromImage'
      diskSizeGB: '128'
      managedDisk: {
        storageAccountType: 'Premium_LRS'
      }
      caching: 'ReadWrite'
    }
    dataDisks: [for (dataDisk, index) in virtualMachine.dataDisks: {
      diskSizeGB: dataDisk.diskSizeGB
      caching: 'ReadOnly'
      managedDisk: {
        storageAccountType: 'Premium_LRS'
      }
    }]
    nicConfigurations: [
      {
        deleteOption: 'Delete'
        ipConfigurations: [
          {
            applicationSecurityGroups: []
            loadBalancerBackendAddressPools: []
            name: 'ipconfig01'
            subnetResourceId: subnetResourceId
          }
        ]
        nicSuffix: '-nic-01'
      }
    ]
    diagnosticWorkspaceId: diagnosticWorkspaceId
    extensionMonitoringAgentConfig: {
      enabled: false
    }
    monitoringWorkspaceId: monitoringWorkspaceId
    extensionDependencyAgentConfig: {
      enabled: false
    }
    extensionNetworkWatcherAgentConfig: {
      enabled: false
    }
    /*
    extensionKeyVaultConfig: {
      enabled: extensionKeyVaultConfig.enabled
      keyVaultSecretId: [
        '${akv.properties.vaultUri}secrets/${extensionKeyVaultConfig.keyVaultRootCertSecretName}'
      ]
    }
    extensionCustomScriptConfig: extensionCustomScriptConfig
    */
    extensionAntiMalwareConfig: virtualMachine.osType == 'Windows' ? {
      enabled: true
      settings: {
        AntimalwareEnabled: 'true'
        Exclusions: {
          Extensions: '.ext1;.ext2'
          Paths: 'c:\\excluded-path-1;c:\\excluded-path-2'
          Processes: 'excludedproc1.exe;excludedproc2.exe'
        }
        RealtimeProtectionEnabled: 'true'
        ScheduledScanSettings: {
          day: '7'
          isEnabled: 'true'
          scanType: 'Quick'
          time: '120'
        }
      }
    } : {
      enabled: false
    }
  }
}]

@description('Output - Array of Virtual Machine Resoruce IDs')
output vmResourceIDs array = [for (virtualMachine, i) in virtualMachines: {
  vmResourceId: lzVm[i].outputs.resourceId
}]

/*
@description('Required. Administrator username.')
@secure()
param adminUsername string

@description('Optional. When specifying a Windows Virtual Machine, this value should be passed.')
@secure()
param adminPassword string = ''

@description('Optional. The name of the virtual machine to be created. You should use a unique prefix to reduce name collisions in Active Directory. If no value is provided, a 10 character long unique string will be generated based on the Resource Group\'s name.')
param name string

@description('Optional. Specifies that the image or disk that is being used was licensed on-premises. This element is only used for images that contain the Windows Server operating system.')
@allowed([
  'Windows_Client'
  'Windows_Server'
  'RHEL_BYOS'
  'SLES_BYOS'
  ''
])
param licenseType string = ''

@description('Optional. Specifies the data disks. For security reasons, it is recommended to specify DiskEncryptionSet into the dataDisk object. Restrictions: DiskEncryptionSet cannot be enabled if Azure Disk Encryption (guest-VM encryption using bitlocker/DM-Crypt) is enabled on your VMs.')
param dataDisks array = []


@description('Required. The chosen OS type.')
@allowed([
  'Windows'
  'Linux'
])
param osType string

@description('Virtual Machine Size')
param virtualMachineSize string = 'Standard_DS2_v2'

@description('Operating System of the Server')
@allowed([
  'Server2012R2'
  'Server2016'
  'Server2019'
  'Server2022'
  'UbuntuServer1604LTS'
  'UbuntuServer1804LTS'
  'UbuntuServer1904'
  'RedHat85Gen2'
  'RedHat86Gen2'
  'RedHat90Gen2'
])
param operatingSystem string = 'Server2019'

@description('Optional. If set to 1, 2 or 3, the availability zone for all VMs is hardcoded to that value. If zero, then availability zones is not used. Cannot be used in combination with availability set nor scale set.')
@allowed([
  0
  1
  2
  3
])
param availabilityZone int = 0

@description('Availability Set Name where the VM will be placed')
param availabilitySetName string = 'MyAvailabilitySet'

@description('Optional. Resource ID of an availability set. Cannot be used in combination with availability zone nor scale set.')
param availabilitySetResourceId string = ''

var availabilitySetPlatformFaultDomainCount = 2
var availabilitySetPlatformUpdateDomainCount = 5

resource availabilitySet 'Microsoft.Compute/availabilitySets@2020-06-01' = {
  name: availabilitySetName
  location: location
  properties: {
    platformFaultDomainCount: availabilitySetPlatformFaultDomainCount
    platformUpdateDomainCount: availabilitySetPlatformUpdateDomainCount
  }
  sku: {
    name: 'Aligned'
  }
}
*/
