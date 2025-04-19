# Git コミットメッセージ自動生成ツール

このツールは、Git のフック機能と各種言語モデルを組み合わせて、一貫性のあるフォーマットでコミットメッセージを自動生成します。開発者の手間を省きながら、プロジェクト全体で統一されたコミットメッセージを維持することができます。変更内容を自動で分析し、適切な説明文を生成することで、コード管理の効率と質を向上させます。

## 特徴

- **自動生成**: 変更内容に基づいた適切なコミットメッセージを自動生成
- **一貫性**: プロジェクト全体で統一されたコミットメッセージフォーマットを維持
- **カスタマイズ可能**: プロジェクトやチームの要件に合わせてメッセージスタイルを調整可能
- **Git フック統合**: 通常の Git ワークフローにシームレスに統合
- **複数の言語モデルサポート**: Amazon Bedrock、OpenAI API、Anthropic、Ollamaなど様々なAIプロバイダーに対応

## 前提条件

- **Git**: バージョン 2.20.0 以上推奨
- **bash または互換シェル**: スクリプト実行環境
- **jq**: JSON 処理用（インストールされていない場合は `apt-get install jq` や `brew install jq` でインストール）
- **curl**: API呼び出し用（OpenAI、Anthropic、Ollamaプロバイダー使用時に必要）

以下は選択したAIプロバイダーによって必要になります：
- **AWS CLI と Bedrock アクセス**: Amazon Bedrockを使用する場合
- **OpenAI API キー**: OpenAI APIを使用する場合
- **Anthropic API キー**: Anthropic Claude APIを直接使用する場合
- **Ollama**: ローカルモデルを使用する場合

## インストールと設定

1. このリポジトリをクローンします：

```bash
git clone https://github.com/yourusername/git-commit-message-generator.git
cd git-commit-message-generator
```

2. 設定ファイルを作成します：

```bash
cp .commit-message-config.sample .commit-message-config
```

3. 設定ファイルを編集して、使用するAIプロバイダーやモデルを設定します：

```bash
# PROVIDER には bedrock, openai, anthropic, ollama のいずれかを指定
PROVIDER="bedrock"
MODEL_ID="amazon.nova-pro-v1:0"
AWS_REGION="us-east-1"
# 他の設定パラメータも必要に応じて変更可能
```

4. 選択したプロバイダーに応じて必要な認証情報を設定します：

- Amazon Bedrock:
  ```bash
  aws configure
  ```
  
- OpenAI:
  ```bash
  export OPENAI_API_KEY="your_openai_api_key_here"
  ```
  
- Anthropic:
  ```bash
  export ANTHROPIC_API_KEY="your_anthropic_api_key_here"
  ```
  
- Ollama:
  ```bash
  # デフォルトでは http://localhost:11434 を使用
  # リモートサーバーの場合は設定ファイルで OLLAMA_HOST を変更
  ```

- OpenAI API:
  ```bash
  export OPENAI_API_KEY="your-api-key"
  ```

- Anthropic API:
  ```bash
  export ANTHROPIC_API_KEY="your-api-key"
  ```

- Ollama:
  ローカルでOllamaを起動し、.commit-message-configファイル内でOLLAMA_HOSTを設定

## 使用方法

### 方法 1: 直接利用

コミット時に以下のコマンドを実行することで、生成されたメッセージを直接使用できます：

```bash
git commit -m "$(bash generate_commit_message.sh)"
```

#### 実行例

```
$ git add README.md
$ git commit -m "$(bash generate_commit_message.sh)"
[main 3a21f8e] ✨ add: READMEに複数AIプロバイダーのサポートを追加

- Amazon Bedrock, OpenAI, Anthropic, Ollamaの使用方法を記載
```

#### プロバイダーの一時的な切り替え

コマンドライン上で別のプロバイダーを一時的に使用することも可能です：

```bash
# OpenAIを一時的に使用
PROVIDER=openai MODEL_ID=gpt-4 git commit -m "$(bash generate_commit_message.sh)"

# Anthropicを一時的に使用
PROVIDER=anthropic MODEL_ID=claude-3-sonnet-20240229 git commit -m "$(bash generate_commit_message.sh)"
```
- 設定ファイルのサンプルと説明を追加
- 各プロバイダーごとの認証情報設定手順を明確化
```

### 方法 2: Git フックとして利用

1. commit-msg ファイルとconfig.shを .git/hooks/ ディレクトリにコピーします：

```bash
cp commit-msg config.sh .commit-message-config.sample .git/hooks/
cp .commit-message-config .git/hooks/ # 既に設定済みの場合
```

2. フックファイルに実行権限を付与します：

```bash
chmod +x .git/hooks/commit-msg
```

3. 通常通り Git コミットを行います：

```bash
git commit
```

このセットアップにより、コミット時に自動的に AI 生成されたメッセージが適用されます。エディタが開いた際に、AI 生成メッセージが既に入力されていることを確認できます。

生成されたメッセージが気に入らない場合：
- エディタで直接編集して保存
- または後から `git commit --amend` でコミットメッセージを修正

## AIプロバイダーの設定

### Amazon Bedrock

```
PROVIDER="bedrock"
MODEL_ID="amazon.nova-pro-v1:0"  # または anthropic.claude-v2 など
AWS_REGION="us-east-1"
```

### OpenAI API

```
PROVIDER="openai"
MODEL_ID="gpt-3.5-turbo"  # または gpt-4 など
OPENAI_API_KEY="your-api-key"  # 環境変数として設定推奨
```

### Anthropic Claude API

```
PROVIDER="anthropic"
MODEL_ID="claude-3-sonnet-20240229"  # または claude-3-opus-20240229 など
ANTHROPIC_API_KEY="your-api-key"  # 環境変数として設定推奨
```

### Ollama (ローカルモデル)

```
PROVIDER="ollama"
MODEL_ID="llama2"  # または mistral, gemma など
OLLAMA_HOST="http://localhost:11434"
```

## カスタマイズ

### 設定ファイル

設定は以下の優先順位で読み込まれます：

1. 環境変数（`PROVIDER_ENV`, `MODEL_ID_ENV`など）
2. プロジェクト設定ファイル（`.commit-message-config`）
3. ユーザーホーム設定ファイル（`$HOME/.commit-message-config`）
4. デフォルト設定

### プロンプトのカスタマイズ

generate_commit_message.sh スクリプト内のプロンプト部分を編集することで、メッセージ生成のスタイルや内容を調整できます：

```bash
# 例: より詳細なメッセージを生成するプロンプト
prompt=$(cat <<EOF | jq -sR .
以下の Git 差分を分析し、変更内容を要約した簡潔かつ詳細なコミットメッセージを生成してください。
- タイトルは50文字以内
- 詳細な説明は72文字で改行
- 変更理由と影響についても言及
- 関連するチケット番号があれば含める

git diff:
EOF
)
```

## トラブルシューティング

### API認証エラー

```
An error occurred (AccessDeniedException) when calling the InvokeModel operation
```

または

```
Error: 401 Unauthorized
```

解決策:
- 選択したプロバイダーの認証情報が正しく設定されているか確認
- API キーの有効期限や利用制限を確認
- プロバイダーのサービスステータスを確認

### スクリプト実行エラー

```
-bash: generate_commit_message.sh: Permission denied
```

解決策:

```bash
chmod +x generate_commit_message.sh
```

### 特定のモデルやプロバイダーの問題

- 別のモデルやプロバイダーを試す
- 各サービスの公式ドキュメントを参照
- モデルのパラメータ（温度など）を調整

## セキュリティに関する注意点

- API キーは環境変数として設定し、設定ファイルには直接書かないようにしましょう
- 機密コードを含む差分はクラウドサービスに送信されるため、内部プロジェクトでは注意が必要です
- 適切なIAMポリシーやAPI利用制限を設定し、必要最小限の権限を付与してください

## 貢献方法

このプロジェクトへの貢献を歓迎します。以下の方法で参加できます：

1. イシューの報告：バグや機能リクエストは GitHub イシューで報告してください
2. プルリクエスト：コードの改善や新機能の追加は PR でお送りください
3. ドキュメント：説明の改善や使用例の追加にご協力ください
