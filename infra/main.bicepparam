using 'main.bicep'

param systemName = readEnvironmentVariable('SYSTEM_NAME')
param environment = readEnvironmentVariable('ENVIRONMENT')
param suffix = readEnvironmentVariable('SUFFIX')
param botDisplayName = readEnvironmentVariable('BOT_DISPLAY_NAME')
param openAIApiKey = readEnvironmentVariable('OPENAI_API_KEY')
param openAIChatModel = readEnvironmentVariable('OPENAI_MODEL_CHAT')
