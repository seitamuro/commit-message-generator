#!/bin/bash

# 設定ファイルの読み込みとデフォルト設定
# 優先順位: 1.プロジェクト設定 2.ユーザー設定 3.デフォルト設定

# デフォルト設定値
PROVIDER="bedrock"               # AIプロバイダー (bedrock, openai, anthropic, ollama)
MODEL_ID="amazon.nova-pro-v1:0"  # モデルID
AWS_REGION="us-east-1"           # AWSリージョン
TEMPERATURE="0.5"                # 生成温度（高いほどランダム性が増す）
MAX_TOKENS="512"                 # 最大トークン数
TOP_P="0.9"                      # 上位確率（生成の多様性）
LANGUAGE="ja"                    # 言語設定

# プロジェクト設定を読み込み
if [ -f ".commit-message-config" ]; then
  # shellcheck source=./.commit-message-config
  source ./.commit-message-config
# ユーザー設定を読み込み
elif [ -f "${HOME}/.commit-message-config" ]; then
  # shellcheck source=~/.commit-message-config
  source "${HOME}/.commit-message-config"
fi

# 環境変数が設定されている場合はそれを優先
PROVIDER="${PROVIDER_ENV:-$PROVIDER}"
MODEL_ID="${MODEL_ID_ENV:-$MODEL_ID}"
AWS_REGION="${AWS_REGION_ENV:-$AWS_REGION}"
TEMPERATURE="${TEMPERATURE_ENV:-$TEMPERATURE}"
MAX_TOKENS="${MAX_TOKENS_ENV:-$MAX_TOKENS}"
TOP_P="${TOP_P_ENV:-$TOP_P}"
LANGUAGE="${LANGUAGE_ENV:-$LANGUAGE}"

# Provider specific settings check
if [ "$PROVIDER" = "openai" ] && [ -z "$OPENAI_API_KEY" ]; then
  echo "OpenAI APIを使用するにはOPENAI_API_KEYを設定してください" >&2
  exit 1
fi

if [ "$PROVIDER" = "anthropic" ] && [ -z "$ANTHROPIC_API_KEY" ]; then
  echo "Anthropic APIを使用するにはANTHROPIC_API_KEYを設定してください" >&2
  exit 1
fi

if [ "$PROVIDER" = "ollama" ] && [ -z "$OLLAMA_HOST" ]; then
  # Default to localhost if not specified
  OLLAMA_HOST="http://localhost:11434"
fi

# Export settings for other scripts
export PROVIDER
export MODEL_ID
export AWS_REGION
export TEMPERATURE
export MAX_TOKENS
export TOP_P
export LANGUAGE
export OLLAMA_HOST