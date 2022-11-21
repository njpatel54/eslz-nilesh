@description('Optional. The name of the Disk Accesses resource.')
param name string

@description('Optional. Location for all resources.')
param location string = resourceGroup().location

@description('Optional. Tags of the resource.')
param tags object = {}

resource diskAccesses 'Microsoft.Compute/diskAccesses@2022-07-02' = {
  name: name
  location: location
  tags: tags
}

@description('The name of the Disk Accesses resource.')
output name string = diskAccesses.name

@description('The resource ID of the Disk Accesses resource.')
output resourceId string = diskAccesses.id
