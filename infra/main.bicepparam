using 'main.bicep'

/** Required **/
param systemName = empty(readEnvironmentVariable('SYSTEM_NAME', '')) ? '' : '-${readEnvironmentVariable('SYSTEM_NAME', '')}'
param environment = empty(readEnvironmentVariable('ENVIRONMENT', '')) ? '' : '-${readEnvironmentVariable('ENVIRONMENT', '')}'
param suffix = empty(readEnvironmentVariable('SUFFIX', '')) ? '' : '-${readEnvironmentVariable('SUFFIX', '')}'

/** app service **/
//* app service plan
param appServicePlanName = empty(readEnvironmentVariable('APP_SERVICE_PLAN_NAME', '')) ?'asp${systemName}${environment}${suffix}' : readEnvironmentVariable('APP_SERVICE_PLAN_NAME', '')
param appServicePlanSku = empty(readEnvironmentVariable('APP_SERVICE_PLAN_SKU', 'F1')) ? 'F1' : readEnvironmentVariable('APP_SERVICE_PLAN_SKU', 'F1')
//* app service web app
param webAppName = empty(readEnvironmentVariable('APP_SERVICE_WEB_APP_NAME', '')) ? 'app${systemName}${environment}${suffix}' : readEnvironmentVariable('APP_SERVICE_WEB_APP_NAME', '')
//* app settings
param openAIApiKey = empty(readEnvironmentVariable('OPENAI_API_KEY', '')) ? null : readEnvironmentVariable('OPENAI_API_KEY', '')
param openAIChatModel = empty(readEnvironmentVariable('OPENAI_MODEL_CHAT', '')) ? 'gpt-3.5-turbo-0125' : readEnvironmentVariable('OPENAI_MODEL_CHAT', '')
param openAIEmbeddingModel = empty(readEnvironmentVariable('OPENAI_MODEL_EMBEDDING', '')) ? 'text-embedding-3-small' : readEnvironmentVariable('OPENAI_MODEL_EMBEDDING', '')
param openAIAISetting = empty(readEnvironmentVariable('OPENAI_AI_SETTING', '')) ? null : readEnvironmentVariable('OPENAI_AI_SETTING', '')
param openAIMaxTokens = empty(readEnvironmentVariable('OPENAI_MAX_TOKENS', '')) ? '1000' : readEnvironmentVariable('OPENAI_MAX_TOKENS', '')
param openAITemperature = empty(readEnvironmentVariable('OPENAI_TEMPERATURE', '')) ? '1.0' : readEnvironmentVariable('OPENAI_TEMPERATURE', '')
param openAITopP = empty(readEnvironmentVariable('OPENAI_TOP_P', '')) ? '1.0' : readEnvironmentVariable('OPENAI_TOP_P', '')
param welcomeMessage = empty(readEnvironmentVariable('WELCOME_MESSAGE', '')) ? null : readEnvironmentVariable('WELCOME_MESSAGE', '')

/** bot service **/
param botName = empty(readEnvironmentVariable('BOT_NAME', '')) ? 'bot${systemName}${environment}${suffix}' : readEnvironmentVariable('BOT_NAME', '')
param botDisplayName = empty(readEnvironmentVariable('BOT_DISPLAY_NAME', '')) ? 'bot${systemName}${environment}${suffix}' : replace(readEnvironmentVariable('BOT_DISPLAY_NAME', ''), '\t', ' ')
param botSku = empty(readEnvironmentVariable('BOT_SKU', 'F0')) ? 'F0' : readEnvironmentVariable('BOT_SKU', 'F0')

/** user assigned identity **/
param userAssignedIdentityName = empty(readEnvironmentVariable('USER_ASSIGNED_IDENTITY_NAME', '')) ? 'id${systemName}${environment}${suffix}' : readEnvironmentVariable('USER_ASSIGNED_IDENTITY_NAME', '')

/** cosmosdb **/
//* database account
param isExsistingDataBaseAccount =  empty(readEnvironmentVariable('IS_EXSISTING_DATABASE_ACCOUNT', 'false')) ? false : bool(readEnvironmentVariable('IS_EXSISTING_DATABASE_ACCOUNT', 'false'))
param databaseAccountResourceGroupName = empty(readEnvironmentVariable('COSMOSDB_DATABASE_ACCOUNT_RESOURCE_GROUP_NAME', '')) ? null : readEnvironmentVariable('COSMOSDB_DATABASE_ACCOUNT_RESOURCE_GROUP_NAME', '')
param databaseAccountName = empty(readEnvironmentVariable('COSMOSDB_DATABASE_ACCOUNT_NAME', '')) ? 'cosno${systemName}${environment}${suffix}' : readEnvironmentVariable('COSMOSDB_DATABASE_ACCOUNT_NAME', '')
param cosmosDBIsEnabledFreeTier = empty(readEnvironmentVariable('COSMOSDB_IS_ENABLED_FREE_TIER', 'false')) ? false : bool(readEnvironmentVariable('COSMOSDB_IS_ENABLED_FREE_TIER', 'false'))
//* database
param isExsistingDataBase = empty(readEnvironmentVariable('IS_EXSISTING_DATABASE', 'false')) ? false  : bool(readEnvironmentVariable('IS_EXSISTING_DATABASE', 'false'))
param databaseName = empty(readEnvironmentVariable('COSMOSDB_DATABASE_NAME', '')) ? 'QABot' : readEnvironmentVariable('COSMOSDB_DATABASE_NAME', 'QABot')
//* container
param isExistingContainer = empty(readEnvironmentVariable('IS_EXISTING_CONTAINER', 'false')) ? false : bool(readEnvironmentVariable('IS_EXISTING_CONTAINER', 'false'))
param chatHistoryContainerName = empty(readEnvironmentVariable('COSMOSDB_CONTAINER_NAME_CHAT', '')) ? 'ChatHistory' : readEnvironmentVariable('COSMOSDB_CONTAINER_NAME_CHAT', '')
param indexContainerName = empty(readEnvironmentVariable('COSMOSDB_CONTAINER_NAME_INDEX', '')) ? 'Index' : readEnvironmentVariable('COSMOSDB_CONTAINER_NAME_INDEX', '')

/** storage **/
param storageAccountName = empty(readEnvironmentVariable('STORAGE_ACCOUNT_NAME', '')) ? toLower(replace('st${systemName}${environment}${suffix}', '-', '')) : readEnvironmentVariable('STORAGE_ACCOUNT_NAME', '')
