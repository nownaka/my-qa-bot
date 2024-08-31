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
param openAIEmbeddingModel string
param openAIMaxTokens string?
param openAITemperature string?
param openAITopP string?
param openAIAISetting string?
param welcomeMessage string?
param includeChatRecords string?
param includeIndexRecords string?
param similarityRank string?

// bot service
param botName string = 'bot-${systemName}-${environment}-${suffix}'
param botDisplayName string
param botSku string = 'F0'

// User Assigned Identity
param userAssignedIdentityName string = 'id-${systemName}-${environment}-${suffix}'

/* cosmosDB */
// database account
param isExsistingDataBaseAccount bool = false
param databaseAccountResourceGroupName string?
param databaseAccountName string = 'cosno-${systemName}-${environment}-${suffix}'
param cosmosDBIsEnabledFreeTier bool = false

// databases
param isExsistingDataBase bool = false
param databaseName string = replace(systemName, '-', '')

// containers
param isExistingContainer bool = false
param chatHistoryContainerName string = 'ChatHistory'
param indexContainerName string = 'Index'

/* storage account */
param storageAccountName string = 'st${systemName}${environment}${suffix}'

/*============================================================================
  Variables
============================================================================*/
var _databaseAccountResourceGroupName = empty(databaseAccountResourceGroupName) ? resourceGroup().name : databaseAccountResourceGroupName

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
        name: 'OPENAI_MODEL_EMBEDDING'
        value: openAIEmbeddingModel
      }
      {
        name: 'OPENAI_MAX_TOKENS'
        value: openAIMaxTokens
      }
      {
        name: 'OPENAI_TEMPERATURE'
        value: openAITemperature
      }
      {
        name: 'OPENAI_TOP_P'
        value: openAITopP
      }
      {
        name: 'OPENAI_AI_SETTING'
        value: openAIAISetting
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
        name: 'COSMOSDB_CONTAINER_NAME_CHAT'
        value: chatHistoryContainer.outputs.containerId
      }
      {
        name: 'COSMOSDB_CONTAINER_NAME_INDEX'
        value: indexContainer.outputs.containerId
      }
      {
        name: 'AZURE_CLIENT_ID'
        value: userAssignedIdentity.outputs.clientId
      }
      {
        name: 'AZURE_TENANT_ID'
        value: userAssignedIdentity.outputs.tenantId
      }
      {
        name: 'WELCOME_MESSAGE'
        value: welcomeMessage
      }
      {
        name: 'INCLUDE_CHAT_RECORDS'
        value: includeChatRecords
      }
      {
        name: 'INCLUDE_INDEX_TOP_RECORDS'
        value: includeIndexRecords
      }
      {
        name: 'SIMILARITY_RANK'
        value: similarityRank
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
    isExsisting: isExsistingDataBaseAccount
    name: databaseAccountName
    location: location
    isEnabledFreeTier: cosmosDBIsEnabledFreeTier
    locations: [
      {
        failoverPriority: 0
        locationName: location
        isZoneRedundant: false
      }
    ]
  }
  scope: resourceGroup(_databaseAccountResourceGroupName)
}

module sqlRoleAssignments 'documentDB/sqlRoleAssignments.bicep' = {
  name: 'Deploy_SqlRoleAssignments_${databaseAccountName}'
  params: {
    databaseAccountName: databaseAccountName
    principalId: userAssignedIdentity.outputs.principalId
    roleDefinitionId: role.cosmosDBBuiltInDataContributor
  }
  scope: resourceGroup(_databaseAccountResourceGroupName)
  dependsOn: [
    databaseAccount
  ]
}

// databases
module database 'documentDB/database.bicep' = {
  name: 'Deploy_${databaseAccountName}_${databaseName}'
  params: {
    isExsisting: isExsistingDataBase
    databaseAccountName: databaseAccountName
    databaseName: databaseName
  }
  scope: resourceGroup(_databaseAccountResourceGroupName)
  dependsOn: [
    databaseAccount
  ]
}

// containers
module chatHistoryContainer 'documentDB/containers.bicep' =  {
  name: 'Deploy_${databaseAccountName}_${databaseName}_${chatHistoryContainerName}'
  params: {
    isExsisting: isExistingContainer
    containerName: chatHistoryContainerName
    databaseName: '${databaseAccountName}/${databaseName}'
    partitionKey: {
        kind: 'MultiHash'
        paths: [
          '/userId'
          '/conversationId'
        ]
        version: 2
      }
  }
  scope: resourceGroup(databaseAccountResourceGroupName)
  dependsOn: [
    database
  ]
}

module indexContainer 'documentDB/containers.bicep' = {
  name: 'Deploy_${databaseAccountName}_${databaseName}_${indexContainerName}'
  params: {
    isExsisting: isExistingContainer
    containerName: indexContainerName
    databaseName: '${databaseAccountName}/${databaseName}'
    partitionKey: {
      kind: 'Hash'
      paths: ['/id']
    }
  }
  scope: resourceGroup(databaseAccountResourceGroupName)
  dependsOn: [
    database
  ]
}

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
output APP_SERVICE_PLAN_NAME string = appServicePlan.outputs.name
output APP_SERVICE_PLAN_SKU string = appServicePlan.outputs.sku
output APP_SERVICE_WEB_APP_NAME string = webApp.outputs.name
output OPENAI_MODEL_CHAT string = openAIChatModel
output OPENAI_MODEL_EMBEDDING string = openAIEmbeddingModel
output OPENAI_MAX_TOKENS string = openAIMaxTokens
output OPENAI_TEMPERATURE string = openAITemperature
output OPENAI_TOP_P string = openAITopP
output INCLUDE_CHAT_RECORDS string = includeChatRecords
output INCLUDE_INDEX_TOP_RECORDS string = includeIndexRecords
output SIMILARITY_RANK string = similarityRank

output BOT_NAME string = botService.outputs.name
output BOT_DISPLAY_NAME string = botService.outputs.displayName
output BOT_SKU string = botService.outputs.sku

output USER_ASSIGNED_IDENTITY_NAME string = userAssignedIdentity.outputs.name
output AZURE_CLIENT_ID string = userAssignedIdentity.outputs.clientId
output AZURE_TENANT_ID string = userAssignedIdentity.outputs.tenantId

output IS_EXSISTING_DATABASE_ACCOUNT bool = isExsistingDataBaseAccount
output COSMOSDB_DATABASE_ACCOUNT_RESOURCE_GROUP_NAME string = _databaseAccountResourceGroupName
output COSMOSDB_IS_ENABLED_FREE_TIER bool = databaseAccount.outputs.enableFreeTier
output IS_EXSISTING_DATABASE bool = isExsistingDataBase
output COSMOSDB_DATABASE_NAME string = database.outputs.databaseId
output IS_EXISTING_CONTAINER bool = isExistingContainer
output COSMOSDB_CONTAINER_NAME_CHAT string = chatHistoryContainer.outputs.containerId
output COSMOSDB_CONTAINER_NAME_INDEX string = indexContainer.outputs.containerId

output STORAGE_ACCOUNT_NAME string = storageAccount.outputs.name
