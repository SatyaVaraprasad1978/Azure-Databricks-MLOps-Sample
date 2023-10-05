/*
------------------------------------------------------------------------------
PARAMETERS FOR AZURE CONTAINER REGISTRY RESOURCE
------------------------------------------------------------------------------
*/
@description('Azure region of the deployment')
param location string = resourceGroup().location

// @description('region name')
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


@description('Container registry name')
var containerRegistryName = concat('cr-${name}-${uniqueSuffix}')

var containerRegistryNameCleaned = replace(containerRegistryName, '-', '')

/*
------------------------------------------------------------------------------
CREATION OF AZURE CONTAINER REGISTRY
------------------------------------------------------------------------------
*/
resource containerRegistry 'Microsoft.ContainerRegistry/registries@2021-09-01' = {
  name: containerRegistryNameCleaned
  location: location
  tags: {
    environment: tag1
    location: tag2
  }
  sku: {
    name: 'Premium'
  }
  properties: {
    adminUserEnabled: true
    dataEndpointEnabled: false
    networkRuleBypassOptions: 'AzureServices'
    networkRuleSet: {
      defaultAction: 'Deny'
    }
    policies: {
      quarantinePolicy: {
        status: 'disabled'
      }
      retentionPolicy: {
        status: 'enabled'
        days: 7
      }
      trustPolicy: {
        status: 'disabled'
        type: 'Notary'
      }
    }
    publicNetworkAccess: 'Disabled'
    zoneRedundancy: 'Disabled'
}
}


output containerRegistryId string = containerRegistry.id
