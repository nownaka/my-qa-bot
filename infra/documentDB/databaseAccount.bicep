/*============================================================================
  Parameters
============================================================================*/
param location string
param name string
param isEnabledFreeTier bool
param locations array
param roleAssignmentConfigs {
  principalId: string
  roleDefinitionId: string
}[] = []

/*============================================================================
  Resources
============================================================================*/
resource databaseAccount 'Microsoft.DocumentDB/databaseAccounts@2024-05-15' = {
  location: location
  name: name
  properties: {
    databaseAccountOfferType: 'Standard'
    enableFreeTier: isEnabledFreeTier
    locations: locations
  }
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = [ for config in roleAssignmentConfigs: {
  name: guid(config.principalId, config.roleDefinitionId, resourceGroup().id)
  scope: databaseAccount
  properties: {
    principalId: config.principalId
    roleDefinitionId: config.roleDefinitionId
  }
}]

/*============================================================================
  Outputs
============================================================================*/
output endpoint string = databaseAccount.properties.documentEndpoint
