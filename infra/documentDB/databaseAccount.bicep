/*============================================================================
  Parameters
============================================================================*/
param isExsinting bool = false
param location string
param name string
param isEnabledFreeTier bool
param locations array

/*============================================================================
  Resources
============================================================================*/
/* exsisting */
resource databaseAccountExisting 'Microsoft.DocumentDB/databaseAccounts@2024-05-15' existing =  if(isExsinting) {
  name: name
  scope: resourceGroup()
}

/* new */
resource databaseAccount 'Microsoft.DocumentDB/databaseAccounts@2024-05-15' = if(!isExsinting){
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
output resourceName string = isExsinting ? databaseAccountExisting.name : databaseAccount.name
output endpoint string = isExsinting ? databaseAccountExisting.properties.documentEndpoint : databaseAccount.properties.documentEndpoint
