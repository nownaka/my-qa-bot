const checkEnvValue = (envName: string): string => {
  const value = process.env[envName];
  if (!value) {
    console.error(`環境変数 ${envName} が正しく設定されていません。`);
    process.exit();
  }
  return value as string;
};

export const config = {
  azureAppType: process.env.AZURE_APP_TYPE || "UserAssignedMSI",
  azureClientId: checkEnvValue("AZURE_CLIENT_ID"),
  azureClientSecret: process.env.AZURE_CLIENT_SECRET,
  azureTenantId: checkEnvValue("AZURE_TENANT_ID"),
  openAI: {
    apiKey: checkEnvValue("OPENAI_API_KEY"),
    models: {
      chat: checkEnvValue("OPENAI_MODEL_CHAT"),
    },
  },
  cosmosDB: {
    endpoint: checkEnvValue("COSMOSDB_ENDPOINT"),
    databaseName: checkEnvValue("COSMOSDB_DATABASE_NAME"),
    containerName: checkEnvValue("COSMOSDB_CONTAINER_NAME"),
    includesRecords: Number(process.env.COSMOSDB_INCLUDE_CHAT_RECORDS) || 6,
  },
  prompt: {
    welcome: process.env.WELCOME_MESSAGE,
  },
};
