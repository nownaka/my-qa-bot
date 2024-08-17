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
param scope string = '/'

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

resource roleAssignment 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2024-05-15' = [ for config in roleAssignmentConfigs: {
  name: guid(config.principalId, config.roleDefinitionId, resourceGroup().id)
  parent: databaseAccount
  properties: {
    principalId: config.principalId
    roleDefinitionId: '/${subscription().id}/resourceGroups/${resourceGroup().name}/providers/Microsoft.DocumentDB/databaseAccounts/${name}/sqlRoleDefinitions/${config.roleDefinitionId}'
    scope: databaseAccount.id
  }
}]

/*============================================================================
  Outputs
============================================================================*/
output endpoint string = databaseAccount.properties.documentEndpoint
