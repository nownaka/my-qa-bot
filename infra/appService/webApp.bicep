/*============================================================================
  Parameters
============================================================================*/
param location string
param name string
param appServicePlanId string
param userAssignedIdentityId string

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
output defaultHostName string = webApp.properties.defaultHostName
