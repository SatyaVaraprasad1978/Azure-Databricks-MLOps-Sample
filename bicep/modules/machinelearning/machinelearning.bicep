/*
------------------------------------------------------------------------------
PARAMETERS FOR AZURE MACHINE LEARNING WORKSPACE RESOURCE
------------------------------------------------------------------------------
*/
@description('Azure region of the deployment')
param location string = resourceGroup().location

@description('name')
param name string 

// @description('project name')
// param project string 

// @description('region name')
// param regiion string 

// @description('deployment environment for the resources')
// param env string

@description('Tags to add to the resources')
param tag1 string 

@description('Tags to add to the resources')
param tag2 string

@description('Machine learning workspace name')
var machineLearningName = concat('mlw-${name}')

@description('Machine learning workspace display name')
param machineLearningFriendlyName string 

@description('Machine learning workspace description')
param machineLearningDescription string

@description('Resource ID of the application insights resource')
param applicationInsightsId string

@description('Resource ID of the container registry resource')
param containerRegistryId string

@description('Resource ID of the key vault resource')
param keyVaultId string

@description('Resource ID of the storage account resource')
param storageAccountId string

/*
------------------------------------------------------------------------------
CREATION OF AZURE MACHINE LEARNING WORKSPACE
------------------------------------------------------------------------------
*/
resource machineLearning 'Microsoft.MachineLearningServices/workspaces@2022-05-01' = {
  name: machineLearningName
  location: location
  tags: {
    environment: tag1
    location: tag2
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    // workspace organization
    friendlyName: machineLearningFriendlyName
    description: machineLearningDescription

    // dependent resources
    applicationInsights: applicationInsightsId
    containerRegistry: containerRegistryId
    keyVault: keyVaultId
    storageAccount: storageAccountId

  }
}

output machineLearningId string = machineLearning.id
