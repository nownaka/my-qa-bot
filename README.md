# my-qa-bot

Azure サービスと OpenAI API を使用した カスタム Q&A チャットボットを実装できます。このボットは、事前に準備した FAQ などに基づいて回答を提供するように設計されており、誰でも簡単にセットアップして使用できるようになっています。

# 構成図と各コンポーネントの役割

![構成図](https://github.com/user-attachments/assets/c0817c5d-9344-425e-a521-c7cc43c8cb9b)

## Azure コンポーネント

| リソース                       | 説明                                                                       |
| :----------------------------- | :------------------------------------------------------------------------- |
| Azure Bot Service              | チャットボットのインターフェースを提供し、ユーザーとの対話を管理する       |
| Azure App Service              | ユーザーからのリクエストを処理する                                         |
| Azure CosmosDB                 | 会話履歴や回答に利用するベクトルデータを保存する                           |
| Azure Storage                  | 静的 Web サイトホスティング機能を利用し、チャット UI を表示する            |
| User Assigned Managed Identity | Azure 関連コンポーネントへのパスワードレス認証を実現し、安全にアクセスする |

## その他

| リソース | 説明                                                           |
| :------- | :------------------------------------------------------------- |
| OpenAI   | ChatGPT モデルを利用した回答生成やプロンプトのベクトル化を行う |

# 前提条件

## Azure

- 有効な Azure `サブスクリプション`を保有していること
- `リソースグループ`が作成済みであること
- 下記権限が付与されていること

  | ロール種別 | スコープ         | 権限                   | 用途                                     |
  | :--------- | :--------------- | :--------------------- | :--------------------------------------- |
  | Entra ID   | ー               | アプリケーション管理者 | Entra ID 上へのアプリ登録                |
  | Azure      | リソースグループ | 所有者                 | リソース作成とマネージド ID への権限付与 |

## OpenAI

- API キーを取得していること

## ローカル環境

- 下記ソフトウェアがインストールされていること

  | 対象 OS         | 名前      | 用途                                         |
  | :-------------- | :-------- | :------------------------------------------- |
  | Windows / macOS | Azure CLI | Azure 環境へ各種コンポーネントをデプロイする |
  | Windows / macOS | Node.js   | JavaScript ランタイム環境として使用          |
  | Windows / macOS | Npm       | Node.js パッケージマネージャーとして使用     |
  | macOS           | jq        | JSON データの処理と操作に使用                |

# セットアップ

> [!IMPORTANT]
> 実行する OS に合わせてタスクを選択してください。

## 1. ターミナルから Azure にログインする。

```
az login
```

## 2. 環境変数を設定する

### 2-1. ショートカットキーを入力し、「タスク：タスクの実行」を選択する。

( macOS: `⌘(command)` + `shift` + `p` / windows: `control` + `shift` + `p` )

![image](https://github.com/user-attachments/assets/d3196bf5-13c5-4317-9f1a-594d6b429126)

### 2-2. 「環境変数を設定する」を選択する。

![image](https://github.com/user-attachments/assets/60ac2172-87fa-4cb4-ba3a-54d3d57b6786)

### 2-3. 環境を選択する。

![image](https://github.com/user-attachments/assets/2b23058c-b407-4cdb-8ded-e02653b3296c)

### 2-4. パラメータを入力する。

#### 必須パラメータ

| 名前                | 説明                                                       |
| :------------------ | :--------------------------------------------------------- |
| RESOURCE_GROUP_NAME | コンポーネントをデプロイするリソースグループを指定します。 |
| OPENAI_API_KEY      | OpenAI で取得した API キー                                 |

#### 推奨パラメータ

| 名前        | デフォルト値 | 説明                               |
| :---------- | :----------- | :--------------------------------- |
| SYSTEM_NAME | myqabot      | システム名                         |
| SUFFIX      | 自動生成     | 接頭辞。リソース名に利用されます。 |

## 3. インフラを構築する

### 3-1. ショートカットキーを入力し、「タスク：タスクの実行」を選択する。

( macOS: `⌘(command)` + `shift` + `p` / windows: `control` + `shift` + `p` )`

![image](https://github.com/user-attachments/assets/d3196bf5-13c5-4317-9f1a-594d6b429126)

### 3-2. 「Azure 上にコンポーネントを作成する」を選択する。

![image](https://github.com/user-attachments/assets/9505d98c-3f61-45b9-b5d5-20131667625b)

### 3-3. 環境を選択する。

![image](https://github.com/user-attachments/assets/2b23058c-b407-4cdb-8ded-e02653b3296c)

## 4. アプリをデプロイする

### 4-1. ショートカットキーを入力し、「タスク：タスクの実行」を選択する。

( macOS: `⌘(command)` + `shift` + `p` / windows: `control` + `shift` + `p` )

![image](https://github.com/user-attachments/assets/d3196bf5-13c5-4317-9f1a-594d6b429126)

### 4-2. 「アプリをデプロイする」を選択する。

![image](https://github.com/user-attachments/assets/e06026d6-fafd-456c-b7bb-c5816a8ae1a0)

### 4-3. 環境を選択する。

![image](https://github.com/user-attachments/assets/2b23058c-b407-4cdb-8ded-e02653b3296c)

# 利用方法

## 1. 回答生成に利用する FAQ データを Azure CosmosDB に登録する

### 登録するデータの JSON スキーマ

```
{
    "$schema": "http://json-schema.org/draft-07/schema#",
    "type": "object",
    "properties": {
        "id": {
            "type": "string"
        },
        "question": {
            "type": "string"
        },
        "answer": {
            "type": "string"
        },
        "urls": {
            "type": "array",
            "items": {
                "type": "string",
                "format": "uri"
            }
        },
        "embedding": {
            "type": "array",
            "items": {
                "type": "number"
            }
        }
    },
    "required": ["id", "question", "answer", "urls", "embedding"]
}
```

### サンプルデータ

![image](https://github.com/user-attachments/assets/d275de12-d3fe-4ce4-89f9-6a152a552269)

## 2. チャットボットの URL を取得する

作成したストレージアカウントにアクセスし、下記画面から URL を取得します。

![image](https://github.com/user-attachments/assets/801935dd-c436-4bc4-9ce8-c37f5fe617fe)

## 3. ブラウザから利用する

![image-002](https://github.com/user-attachments/assets/5a8eb8e1-b73f-467b-9a1c-ccd59da42210)
