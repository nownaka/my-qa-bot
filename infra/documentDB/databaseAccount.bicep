/*============================================================================
  Parameters
============================================================================*/
param isExsisting bool = false
param location string
param name string
param isEnabledFreeTier bool
param locations {
  failoverPriority: int, locationName: string, isZoneRedundant: bool
}[]

/*============================================================================
  Resources
============================================================================*/
/* exsisting */
resource databaseAccountExisting 'Microsoft.DocumentDB/databaseAccounts@2024-05-15' existing =  if(isExsisting) {
  name: name
  scope: resourceGroup()
}

/* new */
resource databaseAccount 'Microsoft.DocumentDB/databaseAccounts@2024-05-15' = if(!isExsisting){
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
output resourceName string = isExsisting ? databaseAccountExisting.name : databaseAccount.name
output endpoint string = isExsisting ? databaseAccountExisting.properties.documentEndpoint : databaseAccount.properties.documentEndpoint
output enableFreeTier bool = isExsisting ? databaseAccountExisting.properties.enableFreeTier : databaseAccount.properties.enableFreeTier
