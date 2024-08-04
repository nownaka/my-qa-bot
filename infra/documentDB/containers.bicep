/*============================================================================
  Parameters
============================================================================*/
param databaseName string
param containerName string

/*============================================================================
  Resources
============================================================================*/
resource container 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2024-05-15' = {
  name: '${databaseName}/${containerName}'
  properties: {
    resource: {
      id: containerName
      partitionKey: {
        kind: 'Hash'
        paths: [
          '/userId'
        ]
      }
    }
  }
}

/*============================================================================
  Outputs
============================================================================*/
output containerId string = container.properties.resource.id
