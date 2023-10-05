// Execute this main file to configure Azure Machine Learning end-to-end in a moderately secure set up

/*
------------------------------------------------------------------------------
PARAMETERS FOR AZURE MLOps RESOURCES
------------------------------------------------------------------------------
*/

@description('Name of the Resource Group')
param resourceGroupName string = resourceGroup().name

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

@description('Machine learning workspace display name')
param machineLearningFriendlyName string 

@description('Machine learning workspace description')
param machineLearningDescription string


@description('Value of the Subscription Id')
param subscriptionId string = subscription().subscriptionId

@description('Name of the sql login administrator')
param administratorLogin string

@description('Object Id of the service principle for sql login')
param administratorSid string

@description('The administrator username of the SQL logical server')
param sqlAdministratorLogin string

@description('The administrator password of the SQL logical server.')
@secure()
param sqlAdministratorLoginPassword string

param isSQLResourceExists bool

@description('Tenant Id')
param tenantId string = tenant().tenantId

// Variables
var name = concat('${project}-${region}-${env}')

/*
------------------------------------------------------------------------------
COMMON RESOURCES
------------------------------------------------------------------------------
*/

// /*
// --------------------------------------------------------------------------------------------------------
// CREATION OF USER ASSIGNED MANAGED IDENTITY 
// --------------------------------------------------------------------------------------------------------
// */

module UserIdentityDeploy './modules/managed_identity/managed_identity.bicep' = {
  name: 'id-${name}-deployment'
  scope: resourceGroup()
  params:{
    // project : project
    // region: region
    // env : env
    name: name
    location:location
    tag1: tag1
    tag2: tag2    
  }
}

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
    name: name
    location: location
    // env : env
    // project: project
    // region: region
    tag1: tag1
    tag2: tag2
  }
}

/*
------------------------------------------------------------------------------
AZURE MLOPS RESOURCES
------------------------------------------------------------------------------
*/

/*
------------------------------------------------------------------------------
MODULE FOR CREATING AZURE STORAGE ACCOUNT
------------------------------------------------------------------------------
*/

module storage './modules/storage/storage.bicep' = {
  name: 'stg-${name}-deployment'
  params: {
    name: name
    location: location
    // region: region
    // project: project
    // env: env
    storageSkuName: 'Standard_LRS'
    tag1: tag1
    tag2: tag2
  }
}

// /*
// ------------------------------------------------------------------------------
// MODULE FOR CREATING AZURE CONTAINER REGISTRY
// ------------------------------------------------------------------------------
// */

module containerRegistry './modules/containerregistry/containerregistry.bicep' = {
  name: 'cr-${name}-deployment'
  params: {
    name: name
    location: location
    // region: region
    // project: project
    // env: env
    tag1: tag1
    tag2: tag2
  }
}

// /*
// ------------------------------------------------------------------------------
// MODULE FOR CREATING APPLICATION INSIGHTS AND LOG ANALYTICS
// ------------------------------------------------------------------------------
// */

module applicationInsights './modules/applicationinsights/applicationinsights.bicep' = {
  name: 'appi-${name}-deployment'
  params: {
    name: name
    location: location
    // project: project
    // region: region
    // env: env
    tag1: tag1
    tag2: tag2
  }
}

/*
------------------------------------------------------------------------------
MODULE FOR CREATING AZURE MACHINE LEARNING WORKSPACE
------------------------------------------------------------------------------
*/

module azuremlWorkspace './modules/machinelearning/machinelearning.bicep' = {
  name: 'mlw-${name}-deployment'
  params: {
    // workspace organization
    name: name
    // project: project
    // region: region
    // env: env
    machineLearningFriendlyName: machineLearningFriendlyName
    machineLearningDescription: machineLearningDescription
    location: location
    tag1: tag1
    tag2: tag2

    // dependent resources
    applicationInsightsId: applicationInsights.outputs.applicationInsightsId
    containerRegistryId: containerRegistry.outputs.containerRegistryId
    keyVaultId: keyvault.outputs.keyvaultId
    storageAccountId: storage.outputs.storageId
  }
  dependsOn: [
    keyvault
    containerRegistry
    applicationInsights
    storage
  ]
}

/*
------------------------------------------------------------------------------
DATAOPS RESOURCES
------------------------------------------------------------------------------
*/

/*
------------------------------------------------------------------------------
MODULE FOR CREATING INITIAL SQL SERVER AND DATABASE
------------------------------------------------------------------------------
*/

module sqlServerModule './modules/sql_server/sql_server.bicep' = if(!isSQLResourceExists) {
  name: 'sql-${name}-deployment'
  params: {
    sqlAdministratorLogin: sqlAdministratorLogin
    sqlAdministratorLoginPassword: sqlAdministratorLoginPassword
    location: location
    name: name
    tag1: tag1
    tag2: tag2
    // project: project
    // env: env
    subscriptionId: subscriptionId
    resourceGroupName: resourceGroupName
    managed_identity_name: UserIdentityDeploy.outputs.managed_identity_name
    administratorLogin: administratorLogin
    administratorSid: administratorSid
    tenantId: tenantId
}
}

/*
------------------------------------------------------------------------------
MODULE FOR CREATING INCREMENTAL SQL SERVER AND DATABASE
------------------------------------------------------------------------------
*/

module sqlServerModuleinc './modules/sql_server_inc/sql_server_inc.bicep' = if(isSQLResourceExists) {
  name: 'sqlinc-${name}-deployment'
  params: {
    sqlAdministratorLogin: sqlAdministratorLogin
    sqlAdministratorLoginPassword: sqlAdministratorLoginPassword
    location: location
    name: name
    tag1: tag1
    tag2: tag2
    // project: project
    // env: env
    subscriptionId: subscriptionId
    resourceGroupName: resourceGroupName
    managed_identity_name: UserIdentityDeploy.outputs.managed_identity_name
    administratorLogin: administratorLogin
    administratorSid: administratorSid
    tenantId: tenantId
  }
}

/*
------------------------------------------------------------------------------
MODULE FOR CREATING DATA LAKE STORAGE
------------------------------------------------------------------------------
*/

module DataLakeStorageModule './modules/data_lake/data_lake.bicep' = {
  name: 'adl-${name}-deployment'
    scope: resourceGroup()
  params: {
    location: location
    name: name    
    tag1: tag1
    tag2: tag2
    // project: project
    // env: env
    // region: region
    subscriptionId: subscriptionId
    resourceGroupName: resourceGroupName
    managed_identity_name: UserIdentityDeploy.outputs.managed_identity_name

  }
}

/*
------------------------------------------------------------------------------
MODULE FOR CREATING SYNAPSE WORKSPACE
------------------------------------------------------------------------------
*/

module synapseModule './modules/synapse/synapse.bicep' = {
  name: 'syn-${name}-deployment'
  params: {
    sqlAdministratorLogin: sqlAdministratorLogin
    sqlAdministratorLoginPassword: sqlAdministratorLoginPassword
    location: location    
    tag1: tag1
    tag2: tag2
    name: name
    // project: project
    // env: env
    // region: region
    subscriptionId: subscriptionId
    resourceGroupName: resourceGroupName
    managed_identity_name: UserIdentityDeploy.outputs.managed_identity_name
    adls_name: DataLakeStorageModule.outputs.adls_name
    administratorSid: administratorSid
  }
  dependsOn: [
    DataLakeStorageModule
  ]
}

/*
------------------------------------------------------------------------------
END OF MODULES
------------------------------------------------------------------------------
*/
