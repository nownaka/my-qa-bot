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
};
