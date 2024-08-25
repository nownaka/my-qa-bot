/*============================================================================
  Parameters
============================================================================*/
param isExsisting bool = false
param databaseName string
param containerName string
param partitionKey { kind: string , paths: string[], version: int? }

/*============================================================================
  Resources
============================================================================*/
/* exsisting */
resource containerExsisting 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2024-05-15' existing = if(isExsisting){
  name: '${databaseName}/${containerName}'
  scope: resourceGroup()
}


/* new */
resource container 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2024-05-15' = if(!isExsisting){
  name: '${databaseName}/${containerName}'
  properties: {
    resource: {
      id: containerName
      partitionKey: partitionKey
    }
  }
}

/*============================================================================
  Outputs
============================================================================*/
output containerId string = isExsisting ? containerExsisting.properties.resource.id : container.properties.resource.id
