#!/bin/bash

# 環境変数ファイルが存在しない場合に作成
if [ ! -f "$ENVIRONMENT_FILE_PATH" ]; then
    if [ -f "env/.env" ]; then
        cp "env/.env" "$ENVIRONMENT_FILE_PATH"
    else
        echo "env/.env が見つかりません。"
        exit 1
    fi
fi

# ENVIRONMENT
if grep -q "^ENVIRONMENT=" "$ENVIRONMENT_FILE_PATH"; then
    # 定義済みの場合：更新
    sed -i '' "s/^ENVIRONMENT=.*$/ENVIRONMENT=${ENVIRONMENT}/" "$ENVIRONMENT_FILE_PATH"
else
    # 未定義の場合：追加
    echo "ENVIRONMENT=${ENVIRONMENT}" >> "$ENVIRONMENT_FILE_PATH"
fi

# SYSTEM_NAME
DEFAULT_SYSTEM_NAME="myqabot"
if grep -q "^SYSTEM_NAME=" "$ENVIRONMENT_FILE_PATH"; then
    # 定義済みの場合：
    if grep -q "^SYSTEM_NAME=$" "$ENVIRONMENT_FILE_PATH"; then
        # 値が空の場合：デフォルト値で更新
        sed -i '' "s/^SYSTEM_NAME=.*$/SYSTEM_NAME=${DEFAULT_SYSTEM_NAME}/" "$ENVIRONMENT_FILE_PATH"
    fi
else
    # 未定義の場合：追加
    echo "SYSTEM_NAME=${DEFAULT_SYSTEM_NAME}" >> "$ENVIRONMENT_FILE_PATH"
fi

# SUFFIX の設定がファイル内に存在し、かつ空でない場合に更新
TIMESTAMP=$(date +%y%m%d%H%M%S)
if grep -q "^SUFFIX=" "$ENVIRONMENT_FILE_PATH"; then
    # 定義済みの場合：
    if grep -q "^SUFFIX=$" "$ENVIRONMENT_FILE_PATH"; then
        # 値が空の場合：タイムスタンプで更新
        sed -i '' "s/^SUFFIX=.*$/SUFFIX=${TIMESTAMP}/" "$ENVIRONMENT_FILE_PATH"
    fi
else
    # 未定義の場合：追加
    echo "SUFFIX=${TIMESTAMP}" >> "$ENVIRONMENT_FILE_PATH"
fi
