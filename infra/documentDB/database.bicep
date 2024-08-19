/*============================================================================
  Parameters
============================================================================*/
param isExsisting bool = false
param databaseAccountName string
param databaseName string

/*============================================================================
  Resources
============================================================================*/
/* existing */
resource databaseExsisting 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2024-05-15' existing = if(isExsisting){
  name: '${databaseAccountName}/${databaseName}'
  scope: resourceGroup()
}

/* new */
resource database 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2024-05-15' = if(!isExsisting){
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
output databaseId string =  isExsisting ? databaseExsisting.properties.resource.id : database.properties.resource.id
