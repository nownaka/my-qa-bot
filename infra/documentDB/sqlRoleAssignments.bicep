/*============================================================================
  Parameters
============================================================================*/
param databaseAccountName string
param principalId string
param roleDefinitionId string

/*============================================================================
  Resources
============================================================================*/
/* database account*/
resource databaseAccount 'Microsoft.DocumentDB/databaseAccounts@2024-05-15' existing = {
  name: databaseAccountName
}

/* sqlRoleAssignments */
resource sqlRoleAssignments 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2024-05-15' =  {
  name: guid(principalId, roleDefinitionId, resourceGroup().id)
  parent: databaseAccount
  properties: {
    principalId: principalId
    roleDefinitionId: '/${subscription().id}/resourceGroups/${resourceGroup().name}/providers/Microsoft.DocumentDB/databaseAccounts/${databaseAccountName}/sqlRoleDefinitions/${roleDefinitionId}'
    scope: databaseAccount.id
  }
}
