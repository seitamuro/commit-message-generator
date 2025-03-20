#!/bin/bash

git_diff=$(git diff HEAD | jq -sR .)
prompt=$(cat <<EOF | jq -sR .
コミットメッセージを日本語で作成してください。このとき、コミットメッセージのみを返してください。コミットメッセージのprefixとして「feat: 新機能の追加」のように変更内容に応じてprefixをつけてください。プレフィックスには<prefix>タグ内の値を利用してください。
<prefix>
  - fix：バグ修正
  - hotfix：クリティカルなバグ修正
  - add：新規（ファイル）機能追加
  - update：機能修正（バグではない）
  - change：仕様変更
  - clean：整理（リファクタリング等）
  - disable：無効化（コメントアウト等）
  - remove：削除（ファイル）
  - upgrade：バージョンアップ
  - revert：変更取り消し
</prefix>

一行目をprefix付きの変更内容、2行目よりあとで箇条書きで変更内容の詳細を記述してください。
原則
以下のフォーマットとします。

1行目：変更内容の要約（タイトル、概要）
2行目 ：空行
3行目以降：変更した理由（内容、詳細）

日本語でも英語でもOKですが、リポジトリで統一してください。

1行目
コミット種別と要約を書きます。フォーマットは以下とします。

[コミット種別]要約

コミット種別
以下の中から適切な種別を選びます。
（多すぎても悩むのでこれぐらいで）

通常版
🐛 fix：バグ修正
🚨 hotfix：クリティカルなバグ修正
✨ add：新規（ファイル）機能追加
🔧 update：機能修正（バグではない）
🔄 change：仕様変更
🧹 clean：整理（リファクタリング等）
🚫 disable：無効化（コメントアウト等）
🗑️ remove：削除（ファイル）
⬆️ upgrade：バージョンアップ
⏪ revert：変更取り消し

要約
変更内容の概要を書きます。シンプルかつ分かりやすく。（難しい）

【例】削除フラグが更新されない不具合の修正

3行目
変更した理由を出来るかぎり具体的に書きます。
Redmine等のチケットと連携している場合はここで紐付けを行います。

【例】refs #110 更新SQLの対象カラムに削除フラグが含まれていなかったため追加しました。

<example>タグ内にあなたが出力するべき内容の例を示します。このとき\`\`\`plaintextや\`\`\`markdownなどで「「絶対に」」囲わず、<example>の中身のみを出力してください。

<example>
feat: ホームページに検索窓を追加
- UI上に検索窓を追加
- hookを利用して検索APIを呼び出す機能を追加
</example>

以下は変更内容です：
EOF
)

aws bedrock-runtime converse \
--model-id amazon.nova-pro-v1:0 \
--messages "[{\"role\":\"user\",\"content\":[{\"text\":$prompt}]},{\"role\":\"user\",\"content\":[{\"text\":$git_diff}]}]" \
--inference-config '{"maxTokens": 512, "temperature": 0.5, "topP": 0.9}' | jq -r '.output.message.content[0].text'

echo -e $(echo $msg | tr -d '"' | sed 's/^```//')
