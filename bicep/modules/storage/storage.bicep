/*
------------------------------------------------------------------------------
PARAMETERS FOR AZURE STORAGE ACCOUNT
------------------------------------------------------------------------------
*/@description('Azure region of the deployment')
param location string = resourceGroup().location

// @description('Region for deployment of resource')
// param region string

// @description('project name')
// param project string 

// @description('deployment environment for the resources')
// param env string

@description('name')
param name string 

@description('Tags to add to the resources')
param tag1 string 

@description('Tags to add to the resources')
param tag2 string

// Create a short, unique suffix, that will be unique to each resource group
var uniqueSuffix = substring(uniqueString(resourceGroup().id), 0, 2)

@description('Name of the storage account')
var storageName = concat('stg-${name}-${uniqueSuffix}')

var storageNameCleaned = replace(storageName, '-', '')

@allowed([
  'Standard_LRS'
  'Standard_ZRS'
  'Standard_GRS'
  'Standard_GZRS'
  'Standard_RAGRS'
  'Standard_RAGZRS'
  'Premium_LRS'
  'Premium_ZRS'
])

@description('Storage SKU')
param storageSkuName string = 'Standard_LRS'



/*
------------------------------------------------------------------------------
CREATION OF AZURE STORAGE ACCOUNT
------------------------------------------------------------------------------
*/
resource storage 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  name: storageNameCleaned
  location: location
  tags: {
    environment: tag1
    location: tag2
  }
  sku: {
    name: storageSkuName
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    allowBlobPublicAccess: false
    allowCrossTenantReplication: false
    allowSharedKeyAccess: true
    encryption: {
      keySource: 'Microsoft.Storage'
      requireInfrastructureEncryption: false
      services: {
        blob: {
          enabled: true
          keyType: 'Account'
        }
        file: {
          enabled: true
          keyType: 'Account'
        }
        queue: {
          enabled: true
          keyType: 'Service'
        }
        table: {
          enabled: true
          keyType: 'Service'
        }
      }
    }
    isHnsEnabled: false
    isNfsV3Enabled: false
    keyPolicy: {
      keyExpirationPeriodInDays: 7
    }
    largeFileSharesState: 'Disabled'
    minimumTlsVersion: 'TLS1_2'
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
    }
    supportsHttpsTrafficOnly: true
  }
}


output storageId string = storage.id
