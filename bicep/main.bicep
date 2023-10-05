// Execute this main file to configure Azure Machine Learning end-to-end in a moderately secure set up

/*
------------------------------------------------------------------------------
PARAMETERS FOR AZURE MLOps RESOURCES
------------------------------------------------------------------------------
*/

@description('Azure region used for the deployment of all resources.')
param location string = resourceGroup().location

@description('Region for deployment of resource')
param region string

@description('project name')
param project string 

@description('deployment environment for the resources')
param env string

@description('Tags to add to the resources')
param tag1 string 

@description('Tags to add to the resources')
param tag2 string 

// @description('Machine learning workspace display name')
// param machineLearningFriendlyName string 

// @description('Machine learning workspace description')
// param machineLearningDescription string


// Variables
var name = concat('${project}-${location}-${env}')

// Dependent resources for the Azure Machine Learning workspace

// /*
// --------------------------------------------------------------------------------------------------------
// CREATION OF USER ASSIGNED MANAGED IDENTITY 
// --------------------------------------------------------------------------------------------------------
// */

// module UserIdentityDeploy './modules/managed_identity/managed_identity.bicep' = {
//   name: 'ct-id-${name}-deployment'
//   scope: resourceGroup()
//   params:{
//     project : project
//     env : env
//     location:location
//     tag1: tag1
//     tag2: tag2    
//   }
// }

// /*
// ------------------------------------------------------------------------------
// MODULE FOR CREATING AZURE LOGIC APP
// ------------------------------------------------------------------------------
// */
// module logicapp './modules/logicapp/logicapp.bicep' = {
//   name: 'logicapp-${name}-deployment'
//   params: {
//     location: location
//     project: project
//     tag1: tag1
//     tag2: tag2
//     env: env
//     managed_identity_name: UserIdentityDeploy.outputs.managed_identity_name
//     keyVaultName: keyvault.outputs.keyVaultName
//   }
// }

/*
------------------------------------------------------------------------------
MODULE FOR CREATING AZURE KEY VAULT
------------------------------------------------------------------------------
*/

module keyvault './modules/keyvault/keyvault.bicep' = {
  name: 'kv-${name}-deployment'
  params: {
    location: location
    //project: project
    region: region
    tag1: tag1
    tag2: tag2
  }
}

// /*
// ------------------------------------------------------------------------------
// MODULE FOR CREATING AZURE STORAGE ACCOUNT
// ------------------------------------------------------------------------------
// */

// module storage './modules/storage/storage.bicep' = {
//   name: 'st-${name}-deployment'
//   params: {
//     location: location
//     region: region
//     project: project
//     env: env
//     storageSkuName: 'Standard_LRS'
//     tag1: tag1
//     tag2: tag2
//   }
// }

// // /*
// // ------------------------------------------------------------------------------
// // MODULE FOR CREATING AZURE CONTAINER REGISTRY
// // ------------------------------------------------------------------------------
// // */

// module containerRegistry './modules/containerregistry/containerregistry.bicep' = {
//   name: 'cr-${name}-deployment'
//   params: {
//     location: location
//     project: project
//     env: env
//     tag1: tag1
//     tag2: tag2
//   }
// }

// /*
// ------------------------------------------------------------------------------
// MODULE FOR CREATING APPLICATION INSIGHTS AND LOG ANALYTICS
// ------------------------------------------------------------------------------
// */

// module applicationInsights './modules/applicationinsights/applicationinsights.bicep' = {
//   name: 'appi-${name}-deployment'
//   params: {
//     location: location
//     project: project
//     env: env
//     tag1: tag1
//     tag2: tag2
//   }
// }

// /*
// ------------------------------------------------------------------------------
// MODULE FOR CREATING AZURE MACHINE LEARNING WORKSPACE
// ------------------------------------------------------------------------------
// */

// module azuremlWorkspace './modules/machinelearning/machinelearning.bicep' = {
//   name: 'mlw-${name}-deployment'
//   params: {
//     // workspace organization
//     project: project
//     env: env
//     machineLearningFriendlyName: machineLearningFriendlyName
//     machineLearningDescription: machineLearningDescription
//     location: location
//     tag1: tag1
//     tag2: tag2

//     // dependent resources
//     applicationInsightsId: applicationInsights.outputs.applicationInsightsId
//     containerRegistryId: containerRegistry.outputs.containerRegistryId
//     keyVaultId: keyvault.outputs.keyvaultId
//     storageAccountId: storage.outputs.storageId
//   }
//   dependsOn: [
//     keyvault
//     containerRegistry
//     applicationInsights
//     storage
//   ]
// }


/*
------------------------------------------------------------------------------
END OF MODULES
------------------------------------------------------------------------------
*/
