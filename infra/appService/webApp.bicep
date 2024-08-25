/*============================================================================
  Parameters
============================================================================*/
param location string
param name string
param appServicePlanId string
param userAssignedIdentityId string
param appSettings array = []

/*============================================================================
  Resources
============================================================================*/
// app service plan
resource webApp 'Microsoft.Web/sites@2023-12-01' = {
  name: name
  location: location
  properties: {
    serverFarmId: appServicePlanId
    siteConfig: {
      linuxFxVersion: 'NODE|18-lts'
      appSettings: appSettings
    }
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userAssignedIdentityId}': {}
    }
  }
}

/*============================================================================
  Outputs
============================================================================*/
output name string = webApp.name
output defaultHostName string = webApp.properties.defaultHostName
