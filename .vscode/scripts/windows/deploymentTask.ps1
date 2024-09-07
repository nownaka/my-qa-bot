#!/bin/pwsh

# env/.env.* から環境変数を読み込む
Write-Output $env:ENVIRONMENT_FILE_PATH
Get-Content -Path $env:ENVIRONMENT_FILE_PATH -Encoding UTF8 | Where-Object { $_.Trim() -ne "" -and $_ -notmatch '^#' } | ForEach-Object {
  $name, $value = $_ -split '='
  Set-Item -Path "Env:$name" -Value $value
}

# .temp ディレクトリを作成
New-Item -ItemType Directory -Path ".temp" -Force

# Azure 上にコンポーネントを作成し、出力をJSON形式で保存
Write-Output (az deployment group create `
--name "Deploy_$env:SYSTEM_NAME" `
--resource-group $env:RESOURCE_GROUP_NAME `
--template-file $env:BICEP_FILE_PATH `
--parameters $env:BICEPPARAM_FILE_PATH) | Out-File -FilePath .temp/outputs.json -Force

# 環境変数をを1つの文字列として取得
$envFileContent = Get-Content -Path $env:ENVIRONMENT_FILE_PATH -Raw -Encoding UTF8

# デプロイ結果sから環境変数を更新する
$outputs = Get-Content .temp/outputs.json -Encoding UTF8 | ConvertFrom-Json
$outputs.properties.outputs.PSObject.Properties | ForEach-Object {
  $key = $_.Name.ToUpper()
  $value = $_.Value.value
  if ($envFileContent -match "(?m)^$key=") {
      $envFileContent = ($envFileContent)-Replace( "(?m)^$($key)=$", "$key=$value")
  } else {
      $envFileContent += "`n$key=$value"
  }
  Set-Item -Path "Env:$key" -Value $value
}

# Azure Storage の静的ウェブサイト機能を有効化する
az storage blob service-properties update `
--account-name $env:STORAGE_ACCOUNT_NAME `
--static-website `
--404-document error.html `
--index-document index.html `
--auth-mode login

# Azure Bot Service の情報を取得
$botInfo = az bot directline show `
--name $env:BOT_NAME `
--resource-group $env:RESOURCE_GROUP_NAME `
--with-secrets true | ConvertFrom-Json
$directLineSecret = $botInfo.properties.properties.sites.key

# DirectLine シークレット情報取得する
if ($envFileContent -match "(?m)^BOT_DIRECTLINE_SECRET=") {
    $envFileContent = ($envFileContent)-Replace( '(?m)^BOT_DIRECTLINE_SECRET=.*$', "BOT_DIRECTLINE_SECRET=$directLineSecret")
} else {
    $envFileContent += "`nBOT_DIRECTLINE_SECRET=$directLineSecret"
}

# webChatUI の getToken.js に DirectLine シークレット情報を出力する
(Get-Content "webChatUI/getToken.js") -replace "<your direct line secret>", "$directLineSecret" | Set-Content "webChatUI/getToken.js"

# Azure Blob ファイルをアップロードするための SAS を取得する
$expiryDate = (Get-Date).AddMinutes(5).ToString("yyyy-MM-ddTHH:mm:ssZ")
$sasToken = az storage container generate-sas `
--account-name  $env:STORAGE_ACCOUNT_NAME `
--name '$web' `
--permissions rwdl `
--expiry $expiryDate `
--output tsv

# ディレクトリ構造を保持してファイルをアップロード
$localPath = "webChatUI"
Get-ChildItem -Path $localPath -Recurse -File | Where-Object { $_.Name -ne '.DS_Store' } | ForEach-Object {
  $file = $_.FullName
  $blobName = $file.Substring($localPath.Length + 1)

  Write-Output $blobName

  az storage blob upload `
  --account-name $env:STORAGE_ACCOUNT_NAME `
  --container-name '$web' `
  --file $file `
  --name $blobName `
  --overwrite `
  --sas-token "`"$sasToken`""
}

# .env.* を更新する
$envFileContent | Set-Content $env:ENVIRONMENT_FILE_PATH

# .temp ディレクトリを削除
Remove-Item -Path ".temp" -Recurse -Force