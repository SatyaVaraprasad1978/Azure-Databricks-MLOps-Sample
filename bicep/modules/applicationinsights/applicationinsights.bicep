/*
------------------------------------------------------------------------------
PARAMETERS FOR AZURE APPLICATION INSIGHTS AND AZURE LOG ANALYTICS RESOURCE
------------------------------------------------------------------------------
*/
@description('Azure region of the deployment')
param location string = resourceGroup().location

// @description('project name')
// param project string 

// @description('region name')
// param region string 

// @description('deployment environment for the resources')
// param env string

@description('name')
param name string

@description('Tags to add to the resources')
param tag1 string 

@description('Tags to add to the resources')
param tag2 string 

@description('Application Insights resource name')
var applicationInsightsName = concat('appi-${name}')

@description('Log Analytics resource name')
var logAnalyticsWorkspaceName = concat('ws-${name}') 

/*
------------------------------------------------------------------------------
CREATION OF AZURE LOG ANALYTICS
------------------------------------------------------------------------------
*/

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: logAnalyticsWorkspaceName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Disabled'
  }
}

/*
------------------------------------------------------------------------------
CREATION OF AZURE APPLICATION INSIGHTS
------------------------------------------------------------------------------
*/
resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: applicationInsightsName
  location: location
  tags: {
    environment: tag1
    location: tag2
  }
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspace.id
    Flow_Type: 'Bluefield'
  }
}

output applicationInsightsId string = applicationInsights.id
