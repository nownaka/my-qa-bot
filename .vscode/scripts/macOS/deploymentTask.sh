#!/bin/bash

# env/.env.* から環境変数を読み込む
export $(grep -v '^#' ${ENVIRONMENT_FILE_PATH} | xargs )

# .temp ディレクトリを作成
mkdir -p .temp

# Azure 上にコンポーネントを作成し、出力をJSON形式で保存
az deployment group create \
  --name Deploy_${SYSTEM_NAME} \
  --resource-group ${RESOURCE_GROUP_NAME} \
  --template-file ${BICEP_FILE_PATH} \
  --parameters ${BICEPPARAM_FILE_PATH} \
  --output json | tee .temp/outputs.json

# デプロイ結果から環境変数を更新する
jq -r '.properties.outputs | to_entries | map("\(.key | ascii_upcase)=\(.value.value)") | .[]' .temp/outputs.json | while IFS='=' read -r key value; do
  if grep -q "^${key}=" "${ENVIRONMENT_FILE_PATH}"; then
    # 定義済みの場合：更新
      sed -i '' "s/^${key}=.*/${key}=${value}/" "${ENVIRONMENT_FILE_PATH}"
  else
    # 未定義の場合：追加
      echo "${key}=${value}" >> "${ENVIRONMENT_FILE_PATH}"
  fi
done

# Azure Storage の静的ウェブサイト機能を有効化する
export $(grep "^STORAGE_ACCOUNT_NAME=" "${ENVIRONMENT_FILE_PATH}" | xargs)
az storage blob service-properties update \
  --account-name ${STORAGE_ACCOUNT_NAME} \
  --static-website \
  --404-document error.html \
  --index-document index.html \
  --auth-mode login

# Azure Bot Service DirectLine の情報を取得
export $( grep "^BOT_NAME=" "${ENVIRONMENT_FILE_PATH}" )
az bot directline show \
  --name ${BOT_NAME} \
  --resource-group ${RESOURCE_GROUP_NAME} \
  --with-secrets true | \
tee .temp/directline.json

# DirectLine シークレットを取得し出力する
jq -r '.properties.properties.sites[] | "BOT_DIRECTLINE_SECRET=\(.key)"' .temp/directline.json | \
while IFS='=' read -r key value; do
  if grep -q "^BOT_DIRECTLINE_SECRET=" "${ENVIRONMENT_FILE_PATH}"; then
    # 定義済みの場合：更新
    sed -i '' "s/^BOT_DIRECTLINE_SECRET=.*/BOT_DIRECTLINE_SECRET=${value}/" "${ENVIRONMENT_FILE_PATH}"
  else
    # 未定義の場合：追加
    echo "BOT_DIRECTLINE_SECRET=${value}" >> "${ENVIRONMENT_FILE_PATH}"
  fi
  export BOT_DIRECTLINE_SECRET=${value}
done

# webChatUI の getToken.js に DirectLine シークレット情報を出力する
sed -i '' "s/<your direct line secret>/${BOT_DIRECTLINE_SECRET}/g" "webChatUI/getToken.js"

# Azure Blob ファイルをアップロードするための SAS を取得する
EXPIRY_DATE=$(date -u -v+5M +"%Y-%m-%dT%H:%M:%SZ")
SAS_TOKEN=$(az storage container generate-sas \
  --account-name  ${STORAGE_ACCOUNT_NAME} \
  --name \$web \
  --permissions rwdl \
  --expiry "$EXPIRY_DATE" \
  --output tsv)

# ディレクトリ構造を保持してファイルをアップロード
LOCAL_PATH=webChatUI
find $LOCAL_PATH -type f ! -name '.DS_Store' | while read -r FILE; do
    BLOB_NAME="${FILE#$LOCAL_PATH/}"
    az storage blob upload \
      --account-name ${STORAGE_ACCOUNT_NAME} \
      --container-name \$web \
      --file "$FILE" \
      --name "$BLOB_NAME" \
      --overwrite \
      --sas-token "$SAS_TOKEN"
done

# .temp ディレクトリを削除
rm -rf .temp
