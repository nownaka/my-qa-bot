#!/bin/bash

# 環境変数ファイルが存在しない場合に作成
if [ ! -f "$ENVIRONMENT_FILE_PATH" ]; then
    touch "$ENVIRONMENT_FILE_PATH"
    echo "## ${ENVIRONMENT} environment variables" >> "$ENVIRONMENT_FILE_PATH"
fi

# 環境変数をロード
export $(grep -v '^#' ${ENVIRONMENT_FILE_PATH} | grep -v '^ENVIRONMENT=' | xargs)

# ENVIRONMENT の設定を更新
if grep -q "^ENVIRONMENT=" "$ENVIRONMENT_FILE_PATH"; then
    # ENVIRONMENT が既に存在する場合、設定を更新
    sed -i '' "s/^ENVIRONMENT=.*$/ENVIRONMENT=${ENVIRONMENT}/" "$ENVIRONMENT_FILE_PATH"
else
    # ENVIRONMENT がファイルに存在しない場合、追加
    echo "ENVIRONMENT=${ENVIRONMENT}" >> "$ENVIRONMENT_FILE_PATH"
fi

# SYSTEM_NAME の設定がファイル内に存在し、かつ空でない場合に更新
DEFAULT_SYSTEM_NAME="myqabot"
if [ -z "$SYSTEM_NAME" ]; then
    if grep -q "^SYSTEM_NAME=" "$ENVIRONMENT_FILE_PATH"; then
        if grep -q "^SYSTEM_NAME=$" "$ENVIRONMENT_FILE_PATH"; then
            # SYSTEM_NAME が空の場合、デフォルト値で更新
            sed -i '' "s/^SYSTEM_NAME=.*$/SYSTEM_NAME=${DEFAULT_SYSTEM_NAME}/" "$ENVIRONMENT_FILE_PATH"
        fi
    else
        # SYSTEM_NAME がファイルに存在しない場合、追加
        echo "SYSTEM_NAME=${DEFAULT_SYSTEM_NAME}" >> "$ENVIRONMENT_FILE_PATH"
    fi
fi

# SUFFIX の設定がファイル内に存在し、かつ空でない場合に更新
TIMESTAMP=$(date +%y%m%d%H%M%S)
if [ -z "$SUFFIX" ]; then
    if grep -q "^SUFFIX=" "$ENVIRONMENT_FILE_PATH"; then
        if grep -q "^SUFFIX=$" "$ENVIRONMENT_FILE_PATH"; then
            # SUFFIX が空の場合、タイムスタンプで更新
            sed -i '' "s/^SUFFIX=.*$/SUFFIX=${TIMESTAMP}/" "$ENVIRONMENT_FILE_PATH"
        fi
    else
        # SUFFIX がファイルに存在しない場合、追加
        echo "SUFFIX=${TIMESTAMP}" >> "$ENVIRONMENT_FILE_PATH"
    fi
fi
