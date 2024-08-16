const checkEnvValue = (envName: string): string => {
  const value = process.env[envName];
  if (!value) {
    console.error(`環境変数 ${envName} が正しく設定されていません。`);
    process.exit();
  }
  return value as string;
};

export const config = {
  bot: {
    id: checkEnvValue("ENTRA_APP_CLIENT_ID"),
    secret: checkEnvValue("ENTRA_APP_SECRET"),
  },
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
};
