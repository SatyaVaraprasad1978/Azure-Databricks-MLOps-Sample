/*
------------------------------------------------------------------------------
PARAMETERS FOR AZURE SYNAPSE WORKSPACE
------------------------------------------------------------------------------
*/

@description('Location for all resources.')
param location string = resourceGroup().location

@description('name')
param name string 

// @description('Region for deployment of resource')
// param region string

// @description('project name')
// param project string 

// @description('deployment environment for the resources')
// param env string

@description('Tags to add to the resources')
param tag1 string 

@description('Tags to add to the resources')
param tag2 string 

@description('The administrator username of the SQL logical server')
param sqlAdministratorLogin string

@description('The administrator password of the SQL logical server.')
@secure()
param sqlAdministratorLoginPassword string

@description('Value of the Subscription Id')
param subscriptionId string = subscription().subscriptionId

@description('Name of the resource group')
param resourceGroupName string = resourceGroup().name

@description('Name of the Managed Identity')
param managed_identity_name string


@description('Name of the Azure Data Lake fetching from data_lake.bicep')
param adls_name string

@description('Object Id of the service principle for sql login')
param administratorSid string

/*
------------------------------------------------------------------------------
VARIABLES FOR AZURE SYNAPSE WORKSPACE
------------------------------------------------------------------------------
*/
// Create a short, unique suffix, that will be unique to each resource group
var uniqueSuffix = substring(uniqueString(resourceGroup().id), 0, 2)


@description('Name of the synapse workspace')
var SynapseWorkspace = concat('syn-${name}-${uniqueSuffix}')

@description('Cleaned Name of the synapse workspace')
var SynapseWorkspaceCleaned = replace(SynapseWorkspace, '-', '')

@description('Name of the synapse workspace')
var BigDataPoolName = concat('${SynapseWorkspaceCleaned}/sp-${name}')

@description('Cleaned Name of the synapse workspace')
var BigDataPoolNameCleaned = replace(BigDataPoolName, '-', '')

@description('Name of the firewall rules name')
var firewallRulesname = concat('${SynapseWorkspaceCleaned}/allowAll')

@description('Resource ID of the Azure Data Lake Storage')
var adls_resource_id = '/subscriptions/${subscriptionId}/resourceGroups/${resourceGroupName}/providers/Microsoft.Storage/storageAccounts/${adls_name}'

@description('URL of the Azure Data Lake Storage')
var adlsURL = 'https://${adls_name}.dfs.core.windows.net/'

/*
------------------------------------------------------------------------------
CREATION OF AZURE SYNAPSE WORKSPACE
------------------------------------------------------------------------------
*/

resource synapseWorkspace 'Microsoft.Synapse/workspaces@2021-06-01' = {
  name: SynapseWorkspaceCleaned
  location: location
  tags: {
    environment: tag1
    location: tag2
  }
  identity: {
    type: 'SystemAssigned,UserAssigned'
    userAssignedIdentities: {
      '/subscriptions/${subscriptionId}/resourceGroups/${resourceGroupName}/providers/Microsoft.ManagedIdentity/userAssignedIdentities/${managed_identity_name}': {}
    }
  }
  properties: {
    azureADOnlyAuthentication: false
    defaultDataLakeStorage: {
      accountUrl: adlsURL
      createManagedPrivateEndpoint: true
      filesystem: 'synapse'
      resourceId: adls_resource_id
    }
    managedVirtualNetwork: 'default'
    managedVirtualNetworkSettings: {
      allowedAadTenantIdsForLinking: []
      preventDataExfiltration: false
    }
    publicNetworkAccess: 'Enabled'
// workspace admin id of the user group in active directory
    cspWorkspaceAdminProperties: {
      initialWorkspaceAdminObjectId: administratorSid
    }
    sqlAdministratorLogin: sqlAdministratorLogin
    sqlAdministratorLoginPassword: sqlAdministratorLoginPassword
    trustedServiceBypassEnabled: false
  }
}


resource firewallRules 'Microsoft.Synapse/workspaces/firewallRules@2021-06-01' = {
  name: firewallRulesname
  dependsOn: [
    synapseWorkspace
  ]
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '255.255.255.255'
  }
}

resource bigDataPool 'Microsoft.Synapse/workspaces/bigDataPools@2021-06-01-preview' = {
  name: BigDataPoolNameCleaned
  location: location
  properties: {
    sparkVersion: '3.1'
    nodeCount: 0
    nodeSize: 'Medium'
    nodeSizeFamily: 'MemoryOptimized'
    autoScale: {
      enabled: true
      minNodeCount: 3
      maxNodeCount: 6
    }
    autoPause: {
      delayInMinutes: 15
      enabled: true
    }
    isComputeIsolationEnabled: false
    sessionLevelPackagesEnabled: true
    cacheSize: 50
    dynamicExecutorAllocation: {
      enabled: false
      // minExecutors: 1
      // maxExecutors: 5
    }
    isAutotuneEnabled: false
    provisioningState: 'Succeeded'
  }
  tags: {
    environment: tag1
    location: tag2
  }
  dependsOn: [
      synapseWorkspace
    ]
}

output sqlserver_resource_id string = synapseWorkspace.id
output sqlserver_name string = synapseWorkspace.name
