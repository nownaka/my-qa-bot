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
      embedding: checkEnvValue("OPENAI_MODEL_EMBEDDING"),
    },
    maxTokens: Number(process.env.OPENAI_MAX_TOKENS) || 1000,
    temperature: Number(process.env.OPENAI_TEMPERATURE) || 1.0,
    topP: Number(process.env.OPENAI_TOP_P) || 1.0,
  },
  cosmosDB: {
    endpoint: checkEnvValue("COSMOSDB_ENDPOINT"),
    databaseName: checkEnvValue("COSMOSDB_DATABASE_NAME"),
    containerNames: {
      chatHistory: checkEnvValue("COSMOSDB_CONTAINER_NAME_CHAT"),
      index: checkEnvValue("COSMOSDB_CONTAINER_NAME_INDEX"),
    },
    includesRecords: {
      chat: Number(process.env.INCLUDE_CHAT_RECORDS) || 6,
      index: Number(process.env.INCLUDE_INDEX_TOP_RECORDS) || 3,
    },
    similarityRank: Number(process.env.SIMILARITY_RANK) || 0.5,
  },
  prompt: {
    welcome: process.env.WELCOME_MESSAGE,
    system: `
    ${process.env.OPENAI_AI_SETTING}
    Follow the rules below when generating your answer.
    - Match the answer language to the user's language.
    - Generates answers only from the information provided, while also taking into account conversations with users.
    - If there is no information, answer that you don't know.
    - If the provided information includes a reference URL, include it in your answer.
    - Display the URL in list format for easy viewing. 
    - Use the following format:
    [Your answer]
    [URL here]
    
    The information provided is below.
    `,
  },
};
