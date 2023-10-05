/*
------------------------------------------------------------------------------
PARAMETERS FOR AZURE SQL SERVER
------------------------------------------------------------------------------
*/

@description('name')
param name string

@description('The administrator username of the SQL logical server')
param sqlAdministratorLogin string

@description('The administrator password of the SQL logical server.')
@secure()
param sqlAdministratorLoginPassword string

@description('Location for all resources.')
param location string = resourceGroup().location

// @description('project name')
// param project string 

// @description('deployment environment for the resources')
// param env string

@description('Tags to add to the resources')
param tag1 string 

@description('Tags to add to the resources')
param tag2 string 

@description('Value of the Subscription Id')
param subscriptionId string = subscription().subscriptionId

@description('Name of the resource group')
param resourceGroupName string = resourceGroup().name

@description('Name of the Managed Identity')
param managed_identity_name string

@description('Name of the sql login administrator')
param administratorLogin string

@description('Object Id of the service principle for sql login')
param administratorSid string

@description('Tenant Id')
param tenantId string = tenant().tenantId

@description('Resource ID of the managed identity')
param userAssignedIdentityId string = '/subscriptions/${subscriptionId}/resourceGroups/${resourceGroupName}/providers/Microsoft.ManagedIdentity/userAssignedIdentities/${managed_identity_name}'

/*
------------------------------------------------------------------------------
VARIABLES FOR AZURE SQL SERVER
------------------------------------------------------------------------------
*/

@description('Name of the sql server')
var sqlServerName = concat('ct-sqlserver-${name}')

@description('Name of the sql server database')
var databaseName = '${sqlServerName}/ct-sqldb-${name}'

/*
------------------------------------------------------------------------------
CREATION OF AZURE SQL SERVER
------------------------------------------------------------------------------
*/

resource sqlServer 'Microsoft.Sql/servers@2021-11-01-preview' = {
  name: sqlServerName
  location: location
  tags: {
    environment: tag1
    location: tag2
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '/subscriptions/${subscriptionId}/resourceGroups/${resourceGroupName}/providers/Microsoft.ManagedIdentity/userAssignedIdentities/${managed_identity_name}': {}
    }
  }
  properties: {
    administratorLogin: sqlAdministratorLogin
    administratorLoginPassword: sqlAdministratorLoginPassword
    version: '12.0'
    publicNetworkAccess: 'Enabled'
    primaryUserAssignedIdentityId: userAssignedIdentityId
  }
  
}

// SQL server Administrator
resource aad_admin 'Microsoft.Sql/servers/administrators@2022-05-01-preview' = {
  name: 'ActiveDirectory'
  parent: sqlServer
  properties: {
    administratorType: 'ActiveDirectory'
    login: administratorLogin
    sid: administratorSid
    tenantId: tenantId
  }
}

/*
------------------------------------------------------------------------------
CREATION OF AZURE SQL DATABASE
------------------------------------------------------------------------------
*/

resource database 'Microsoft.Sql/servers/databases@2021-11-01-preview' = {
  name: databaseName
  location: location
  sku: {
    name: 'Basic'
    tier: 'Basic'
    capacity: 5
  }
  tags: {
    displayName: databaseName
  }
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: 104857600
  }
  dependsOn: [
    sqlServer
  ]
}

output sqlserver_resource_id string = sqlServer.id
output sqlserver_name string = sqlServer.name
