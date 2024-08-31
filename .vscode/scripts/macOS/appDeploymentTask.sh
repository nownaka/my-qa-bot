# 環境変数をロード
export $(grep -v '^#' ${ENVIRONMENT_FILE_PATH} | xargs)

# .deployment ディレクトリを作成
mkdir -p .deployment

# deployment.zip の作成
zip -r .deployment/deployment.zip src lib node_modules package-lock.json package.json tsconfig.json

# 自動ビルド有効化
az webapp config appsettings set \
    --resource-group $RESOURCE_GROUP_NAME \
    --name $APP_SERVICE_WEB_APP_NAME \
    --settings SCM_DO_BUILD_DURING_DEPLOYMENT=true

# デプロイ
az webapp deploy \
    --resource-group $RESOURCE_GROUP_NAME \
    --name $APP_SERVICE_WEB_APP_NAME \
    --src-path ".deployment/deployment.zip"

# .deployment ディレクトリを削除
rm -rf .deployment
