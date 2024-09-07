#!/bin/pwsh

# env/.env.* から環境変数を読み込む
Write-Output $env:ENVIRONMENT_FILE_PATH
Get-Content -Path $env:ENVIRONMENT_FILE_PATH -Encoding UTF8 | Where-Object { $_.Trim() -ne "" -and $_ -notmatch '^#' } | ForEach-Object {
  $name, $value = $_ -split '='
  Set-Item -Path "Env:$name" -Value $value
}

# .deployment ディレクトリを作成
New-Item -ItemType Directory -Path ".deployment" -Force

# deployment.zip の作成
$filesToZip = @('src', 'lib', 'node_modules', 'package-lock.json', 'package.json', 'tsconfig.json')
Compress-Archive -Path $filesToZip -DestinationPath '.deployment/deployment.zip' -Force

# 自動ビルド有効化
az webapp config appsettings set `
--resource-group $env:RESOURCE_GROUP_NAME `
--name $env:APP_SERVICE_WEB_APP_NAME `
--settings SCM_DO_BUILD_DURING_DEPLOYMENT=true

# アプリデプロイ
az webapp deploy `
--resource-group $env:RESOURCE_GROUP_NAME `
--name $env:APP_SERVICE_WEB_APP_NAME `
--src-path ".deployment/deployment.zip"

# .deployment ディレクトリを削除
Remove-Item -Path ".deployment" -Recurse -Force
