/*============================================================================
  Parameters
============================================================================*/
param location string
param name string

/*============================================================================
  Resources
============================================================================*/
resource userAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-07-31-preview' = {
  name: name
  location: location
}

/*============================================================================
  Outputs
============================================================================*/
output resourceId string = userAssignedIdentity.id
output clientId string = userAssignedIdentity.properties.clientId
output principalId string = userAssignedIdentity.properties.principalId
output tenantId string = userAssignedIdentity.properties.tenantId
