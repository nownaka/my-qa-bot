#!/bin/pwsh

# 環境変数ファイルが存在しない場合に作成
if (-Not (Test-Path $env:ENVIRONMENT_FILE_PATH)) {
    if (-Not (Test-Path "env/.env")) {
        Write-Error "env/.env が見つかりません"
        exit 1
    }
    $envSourceFile = Get-Content -Path "env/.env" -Raw -Encoding UTF8
    Set-Content -Path $env:ENVIRONMENT_FILE_PATH -Value $envSourceFile
}

# env/.env.* から環境変数を1つの文字列として読み込む
$envFileContent = Get-Content -Path $env:ENVIRONMENT_FILE_PATH -Raw -Encoding UTF8

# ENVIRONMENT
if ($envFileContent -match '(?m)^ENVIRONMENT=') {
    # 定義済みの場合：更新
    $envFileContent = ($envFileContent)-Replace( '(?m)^ENVIRONMENT=.*$', "ENVIRONMENT=$env:ENVIRONMENT")
} else {
    # 未定義の場合：追加
    $envFileContent += "`nENVIRONMENT=$env:ENVIRONMENT"
}

# SYSTEM_NAME
$DEFAULT_SYSTEM_NAME = "myqabot"
if ($envFileContent -match "(?m)^SYSTEM_NAME=") {
    # 定義済みで値がない場合：デフォルト値で更新
    $envFileContent = ($envFileContent)-Replace( '(?m)^SYSTEM_NAME=$', "SYSTEM_NAME=$DEFAULT_SYSTEM_NAME")
} else {
    # 未定義の場合：追加
    $envFileContent += "`nSYSTEM_NAME=$DEFAULT_SYSTEM_NAME"
}


# SUFFIX の設定設定を更新
$TIMESTAMP = (Get-Date -Format "yyMMddHHmmss")
if ($envFileContent -match "(?m)^SUFFIX=") {
    # 定義済みで値がない場合：タイムスタンプで更新
    $envFileContent = ($envFileContent)-Replace( '(?m)^SUFFIX=$', "SUFFIX=$TIMESTAMP")
} else {
    # 未定義の場合：追加
    $envFileContent += "`nSUFFIX=$TIMESTAMP"
}

# env/.env.* を更新する
$envFileContent | Set-Content $env:ENVIRONMENT_FILE_PATH