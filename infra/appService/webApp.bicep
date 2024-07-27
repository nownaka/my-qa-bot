/*============================================================================
  Parameters
============================================================================*/
param location string
param name string
param appServicePlanId string

/*============================================================================
  Resources
============================================================================*/
// app service plan
resource webApp 'Microsoft.Web/sites@2023-12-01' = {
  name: name
  location: location
  properties: {
    serverFarmId: appServicePlanId
  }
}

/*============================================================================
  Outputs
============================================================================*/
output defaultHostName string = webApp.properties.defaultHostName
