param location string
//param deployBlob bool = true
//param deployQueue bool = false
//param deployTable bool = false
//param deployFile bool = false
param entityName string = 'data'
//param prodStgAcctPrefix string = 'prodstg'
//param random string = take(newGuid(), 4)
param filename string = 'start.ps1'
param utcValue string = utcNow()

@description('Required. Project Owner (projowner) parameter.')
@allowed([
  'ccs'
  'proj'
])
param projowner string = 'ccs'

@description('Required. Operational Scope (opscope) parameter.')
@allowed([
  'prod'
  'dev'
  'qa'
  'stage'
  'test'
  'sand'
])
param opscope string = 'prod'

@description('Required. Region (region) parameter.')
@allowed([
  'usva'
  'ustx'
  'usaz'
])
param region string = 'usva'

param suffix string = 'lz01'
param lzPEGrpName string = '${suffix} Private Endpoint Creators'
param lzPEGrpMailNickName string = '${suffix}PrivateEndpointCreators'

@description('Required. Subscription ID of Management Subscription.')
param mgmtsubid string

@description('Required. SIEM Resource Group Name.')
param siemRgName string = 'rg-${projowner}-${opscope}-${region}-siem'

// Upload artifacts to storage account as a blob using Az Cli
resource deploymentScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'deployscript-upload-blob-${utcValue}'
  location: location
  kind: 'AzureCLI'
  properties: {
    azCliVersion: '2.26.1'
    timeout: 'PT5M'
    retentionInterval: 'PT1H'
    //https://docs.microsoft.com/en-us/azure/storage/blobs/authorize-data-operations-cli#set-environment-variables-for-authorization-parameters
    /*environmentVariables: [
      {
        name: 'AZURE_STORAGE_ACCOUNT'
        value: prodStgaAcct.name
      }
      {
        name: 'AZURE_STORAGE_SAS_TOKEN'
        secureValue: sasToken
      }
      {
        name: 'CONTENT'
        value: loadTextContent('../start.ps1')
      }
    ]*/
    scriptContent: 'az ad group create --display-name ${lzPEGrpName} --mail-nickname ${lzPEGrpMailNickName} && az ad group member add --group ${lzPEGrpName} --member-id $(az ad signed-in-user show --query "{ID:id}" -o tsv) && az ad group member add --group "Private Endpoint Creators" --member-id $(az ad group list --display-name ${lzPEGrpName} --query "[].{ID:id}" -o tsv)'
  }
}












/*
// SAS to download blobs in account
// signedServices - https://docs.microsoft.com/en-us/rest/api/storagerp/storage-accounts/list-account-sas#services
// signedPermission - https://docs.microsoft.com/en-us/rest/api/storagerp/storage-accounts/list-account-sas#permissions
// signedResourceTypes - https://docs.microsoft.com/en-us/rest/api/storagerp/storage-accounts/list-account-sas#signedresourcetypes

var accountSasProperties = {
  signedServices: 'b'
  signedPermission: 'rwdlacup'
  signedResourceTypes: 'cos'
  signedProtocol: 'https'
  signedExpiry: '2022-01-31T17:00:00Z'
  }

// SAS Toekn created using "accountSasProperties" and stored into variable "sasToken"
var sasToken = prodStgaAcct.listAccountSas(prodStgaAcct.apiVersion, accountSasProperties).accountSasToken

// create storage account
resource prodStgaAcct 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: '${prodStgAcctPrefix}${random}'
  location: resourceGroup().location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
      minimumTlsVersion: 'TLS1_2'
      supportsHttpsTrafficOnly: true
  }

  resource blobService 'blobServices' = if (deployBlob) {
    name: 'default'
    resource container 'containers' = {
      name: entityName
    }
  }

  resource queueService 'queueServices' = if (deployQueue) {
    name: 'default'
    resource queue 'queues' = {
      name: entityName
    }
  }

  resource tableService 'tableServices' = if (deployTable) {
    name: 'default'
    resource table 'tables' = {
      name: entityName
    }
  }

  resource fileService 'fileServices' = if (deployFile) {
    name: 'default'
    resource share 'shares' = {
      name: entityName
    }
  }
}


output prodStgaAcctName string = prodStgaAcct.name
//output accountKey string = prodStgaAcct.listKeys().keys[0].value
output prodStgaAcctEndpoints object = prodStgaAcct.properties.primaryEndpoints
output prodBloburi string = '${prodStgaAcct.properties.primaryEndpoints['blob']}${entityName}/${filename}'
output sasToken string = sasToken
*/
