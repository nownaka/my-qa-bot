/*============================================================================
  Parameters
============================================================================*/
param location string
param name string
param isEnabledFreeTier bool
param locations array

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

/*============================================================================
  Outputs
============================================================================*/
output endpoint string = databaseAccount.properties.documentEndpoint
