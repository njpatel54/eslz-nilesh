targetScope = 'managementGroup'

@description('Location for the deployments and the resources')
param location string

@description('Required. Combine Tags in dynamoctags object with Tags from parameter file.')
param combinedTags object

@description('subscriptionId for the deployment')
param subscriptionId string

@description('Required. Name of the resourceGroup, where application workload will be deployed.')
param wlRgName string

@description('Optional. The name of the virtual machine to be created. You should use a unique prefix to reduce name collisions in Active Directory. If no value is provided, a 10 character long unique string will be generated based on the Resource Group\'s name.')
param name string

@description('Required. Subnet resoruceId for Network Interface Card.')
param subnetResourceId string

@description('Optional. Resource ID of the diagnostic log analytics workspace.')
param diagnosticWorkspaceId string = ''

@description('Required. The administrator login for the Virtual Machine.')
@secure()
param vmAdmin string

@description('Required. The administrator login password for the Virtual Machine.')
@secure()
param vmAdminPassword string

@description('Required. The chosen OS type.')
@allowed([
  'Windows'
  'Linux'
])
param osType string

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

@description('Optional. Specifies the time zone of the virtual machine. e.g. \'Pacific Standard Time\'. Possible values can be `TimeZoneInfo.id` value from time zones returned by `TimeZoneInfo.GetSystemTimeZones`.')
param timeZone string = 'Eastern Standard Time'

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

module lzVm '../../modules/compute/virtualMachines/deploy.bicep' = {
  name: 'lzVm-${take(uniqueString(deployment().name, location), 4)}-${name}'
  scope: resourceGroup(subscriptionId, wlRgName)
  params: {
    name: name
    location: location
    tags: combinedTags
    adminUsername: vmAdmin
    adminPassword: vmAdminPassword
    vmComputerNamesTransformation: 'lowercase'
    osType: osType
    vmSize: virtualMachineSize
    licenseType: licenseType
    timeZone: timeZone
    availabilityZone: availabilityZone
    imageReference: {
      publisher: operatingSystemValues[operatingSystem].publisher
      offer: operatingSystemValues[operatingSystem].offer
      sku: operatingSystemValues[operatingSystem].sku
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
    dataDisks: [for (dataDisk, index) in dataDisks: {
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
  }
}

/*
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
