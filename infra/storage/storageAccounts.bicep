/*============================================================================
  Parameters
============================================================================*/
param location string
param name string
param sku string = 'Standard_LRS'
param kind string = 'StorageV2'
param accessTier string = 'Hot'
param minimumTlsVersion string = 'TLS1_2'

/*============================================================================
  Resources
============================================================================*/
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: name
  location: location
  sku: {
    name: sku
  }
  kind: kind
  properties: {
    accessTier: accessTier
    minimumTlsVersion: minimumTlsVersion
  }
}

/*============================================================================
  Outputs
============================================================================*/
output name string = storageAccount.name
