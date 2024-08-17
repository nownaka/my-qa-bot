/*============================================================================
  Parameters
============================================================================*/
param location string = resourceGroup().location
param systemName string
param environment string
param suffix string

/* app service */
// app service plan
param appServicePlanName string = 'asp-${systemName}-${suffix}'
param appServicePlanSku string = 'F1'

// web app
param webAppName string = 'app-${systemName}-${suffix}'

// app settings
@secure()
param openAIApiKey string
param openAIChatModel string

// bot service
param botName string = 'bot-${systemName}-${environment}-${suffix}'
param botDisplayName string
param botSku string = 'F0'

// User Assigned Identity
param userAssignedIdentityName string = 'id-${systemName}-${environment}-${suffix}'

/* cosmosDB*/
// database account
param databaseAccountName string = 'cosno-${systemName}-${environment}-${suffix}'
param cosmosDBIsEnabledFreeTier bool = false
param cosmosDBDatabaseAccountLocations array = [
  {
    failoverPriority: 0
    locationName: location
    isZoneRedundant: false
  }
]

// databases
param databaseName string = systemName

// containers
param containerNames array = ['chatHistory']

/* storage account */
param storageAccountName string = 'st${systemName}${environment}${suffix}'

/*============================================================================
  Variables
============================================================================*/
var role = {
  cosmosDBBuiltInDataContributor: '00000000-0000-0000-0000-000000000002'
}

/*============================================================================
  Resources
============================================================================*/
// app service plan
module appServicePlan './appService/appServicePlan.bicep' = {
  name: 'Deploy_${appServicePlanName}'
  params: {
    name: appServicePlanName
    location: location
    sku: appServicePlanSku
  }
}

// web app
module webApp './appService/webApp.bicep' = {
  name: 'Deploy_${webAppName}'
  params: {
    name: webAppName
    location: location
    appServicePlanId: appServicePlan.outputs.id
    userAssignedIdentityId: userAssignedIdentity.outputs.resourceId
    appSettings: [
      {
        name: 'WEBSITE_NODE_DEFAULT_VERSION'
        value: '~18'
      }
      {
        name: 'RUNNING_ON_AZURE'
        value: '1'
      }
      {
        name: 'OPENAI_API_KEY'
        value: openAIApiKey
      }
      {
        name: 'OPENAI_MODEL_CHAT'
        value: openAIChatModel
      }
      {
        name: 'COSMOSDB_ENDPOINT'
        value: databaseAccount.outputs.endpoint
      }
      {
        name: 'COSMOSDB_DATABASE_NAME'
        value: databaseName
      }
      {
        name: 'COSMOSDB_CONTAINER_NAME'
        value: containerNames[0]
      }
      {
        name: 'AZURE_CLIENT_ID'
        value: userAssignedIdentity.outputs.clientId
      }
      {
        name: 'AZURE_TENANT_ID'
        value: userAssignedIdentity.outputs.tenantId
      }
    ]
  }
}

// bot service
module botService 'botService.bicep' = {
  name: 'Deploy_${botName}'
  params: {
    name: botName
    botAppDomain: webApp.outputs.defaultHostName
    displayName: botDisplayName
    msaAppId: userAssignedIdentity.outputs.clientId
    msaAppMSIResourceId:userAssignedIdentity.outputs.resourceId
    msaAppTenantId: userAssignedIdentity.outputs.tenantId
    sku: botSku
  }
}

// User Assigned Identity
module userAssignedIdentity 'userAssignedIdentity.bicep' = {
  name: 'Deploy_${userAssignedIdentityName}'
  params: {
    name: userAssignedIdentityName
    location: location
  }
}

/* cosmosDB*/
// database account
module databaseAccount 'documentDB/databaseAccount.bicep' = {
  name: 'Deploy_${databaseAccountName}'
  params: {
    name: databaseAccountName
    location: location
    isEnabledFreeTier: cosmosDBIsEnabledFreeTier
    locations: cosmosDBDatabaseAccountLocations
    roleAssignmentConfigs: [
      {
        principalId: userAssignedIdentity.outputs.principalId
        roleDefinitionId: role.cosmosDBBuiltInDataContributor
      }
    ]
  }
}

// databases
module database 'documentDB/database.bicep' = {
  name: 'Deploy_${databaseAccountName}_${databaseName}'
  params: {
    databaseAccountName: databaseAccountName
    databaseName: databaseName
  }
  dependsOn: [
    databaseAccount
  ]
}

// container
@batchSize(1)
module containers 'documentDB/containers.bicep' = [for name in containerNames: {
  name: 'Deploy_${databaseAccountName}_${databaseName}_${name}'
  params: {
    containerName: name
    databaseName: '${databaseAccountName}/${databaseName}'
  }
  dependsOn: [
    database
  ]
}]

/* storage*/
module storageAccount 'storage/storageAccounts.bicep' = {
  name: 'Deploy_${storageAccountName}'
  params: {
    name: storageAccountName
    location: location
  }
}

/*============================================================================
  Outputs
============================================================================*/
output AZURE_CLIENT_ID string = userAssignedIdentity.outputs.clientId
output AZURE_TENANT_ID string = userAssignedIdentity.outputs.tenantId
output STORAGE_ACCOUNT_NAME string = storageAccount.outputs.name
