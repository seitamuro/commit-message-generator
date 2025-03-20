# Git コミットメッセージ自動生成ツール

このツールは、Git のフック機能と Amazon Bedrock の言語モデルを組み合わせて、一貫性のあるフォーマットでコミットメッセージを自動生成します。開発者の手間を省きながら、プロジェクト全体で統一されたコミットメッセージを維持することができます。変更内容を自動で分析し、適切な説明文を生成することで、コード管理の効率と質を向上させます。

## 特徴

- **自動生成**: 変更内容に基づいた適切なコミットメッセージを自動生成
- **一貫性**: プロジェクト全体で統一されたコミットメッセージフォーマットを維持
- **カスタマイズ可能**: プロジェクトやチームの要件に合わせてメッセージスタイルを調整可能
- **Git フック統合**: 通常の Git ワークフローにシームレスに統合

## 前提条件

- **Git**: バージョン 2.20.0 以上推奨
- **AWS CLI**: バージョン 2.0 以上、適切に設定済みであること
- **Amazon Bedrock アクセス**: 適切な IAM 権限が設定されていること
- **bash または互換シェル**: スクリプト実行環境
- **jq**: JSON 処理用（インストールされていない場合は `apt-get install jq` や `brew install jq` でインストール）

## インストールと設定

1. このリポジトリをクローンします：

```bash
git clone https://github.com/yourusername/git-commit-message-generator.git
cd git-commit-message-generator
```

2. AWS CLI が正しく設定されていることを確認します：

```bash
aws configure list
```

必要な場合は以下のコマンドで設定してください：

```bash
aws configure
```

3. generate_commit_message.sh スクリプトを編集して、使用する Bedrock モデルとリージョンを設定します：

```bash
# スクリプト内の以下の部分を編集
MODEL_ID="anthropic.claude-v2"
AWS_REGION="us-west-2"
```

## 使用方法

### 方法 1: 直接利用

コミット時に以下のコマンドを実行することで、生成されたメッセージを直接使用できます：

```bash
git commit -m "$(bash generate_commit_message.sh | tr -d '"')"
```

#### 実行例

```
$ git add README.md
$ git commit -m "$(bash generate_commit_message.sh | tr -d '"')"
[main 3a21f8e] READMEを更新: インストール手順を明確化し、使用例を追加
```

### 方法 2: Git フックとして利用

1. commit-msg ファイルを .git/hooks/ ディレクトリにコピーします：

```bash
cp commit-msg .git/hooks/
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

## カスタマイズ

### プロンプトのカスタマイズ

generate_commit_message.sh スクリプト内のプロンプト部分を編集することで、メッセージ生成のスタイルや内容を調整できます：

```bash
# 例: より詳細なメッセージを生成するプロンプト
PROMPT="以下の Git 差分を分析し、変更内容を要約した簡潔かつ詳細なコミットメッセージを生成してください。
- タイトルは50文字以内
- 詳細な説明は72文字で改行
- 変更理由と影響についても言及
- 関連するチケット番号があれば含める

git diff:
$GIT_DIFF"
```

## トラブルシューティング

### AWS 認証エラー

```
An error occurred (AccessDeniedException) when calling the InvokeModel operation
```

解決策:

- AWS CLI の設定が正しいか確認: `aws configure list`
- IAM ユーザーに適切な Bedrock 権限があるか確認
- AWS_PROFILE 環境変数を設定: `export AWS_PROFILE=your-profile`

### スクリプト実行エラー

```
-bash: generate_commit_message.sh: Permission denied
```

解決策:

```bash
chmod +x generate_commit_message.sh
```

### 生成されたメッセージの品質問題

- プロンプトを調整して、より詳細な指示を追加
- 異なる Bedrock モデルを試す（例: Claude 3 はより高品質な結果を生成）
- 差分のサイズが大きすぎる場合は、小さな単位でコミットを行う

## セキュリティに関する注意点

- スクリプトは AWS 認証情報を使用するため、認証情報の適切な管理が重要です
- 機密コードを含む差分はクラウドサービスに送信されるため、内部プロジェクトでは注意が必要です
- AWS IAM ポリシーを適切に設定し、必要最小限の権限を付与してください

## 貢献方法

このプロジェクトへの貢献を歓迎します。以下の方法で参加できます：

1. イシューの報告：バグや機能リクエストは GitHub イシューで報告してください
2. プルリクエスト：コードの改善や新機能の追加は PR でお送りください
3. ドキュメント：説明の改善や使用例の追加にご協力ください
