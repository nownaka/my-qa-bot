/*============================================================================
  Parameters
============================================================================*/
param databaseAccountName string
param databaseName string

/*============================================================================
  Resources
============================================================================*/
resource database 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2024-05-15' = {
  name: '${databaseAccountName}/${databaseName}'
  properties: {
    resource: {
      id: databaseName
    }
  }
}

/*============================================================================
  Outputs
============================================================================*/
output databaseId string = database.properties.resource.id
