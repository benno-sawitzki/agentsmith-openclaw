#!/bin/bash
set -e

CONFIG_PATH="/data/openclaw.json"
SOUL_PATH="/data/workspace/SOUL.md"

# Write openclaw config from env var (pushed by Agent Smith on provision/sync)
# Falls back to the default baked into the image
if [ -n "$OPENCLAW_CONFIG_JSON" ]; then
  echo "$OPENCLAW_CONFIG_JSON" > "$CONFIG_PATH"
  echo "[agentsmith] openclaw.json written from env"
else
  if [ ! -f "$CONFIG_PATH" ]; then
    cp /app/openclaw.json.default "$CONFIG_PATH"
    echo "[agentsmith] openclaw.json initialized from default"
  fi
fi

# Decode brand data from env var (base64-encoded SOUL.md pushed by brand sync)
if [ -n "$SOUL_MD" ]; then
  echo "$SOUL_MD" | base64 -d > "$SOUL_PATH"
  echo "[agentsmith] SOUL.md written ($(wc -c < "$SOUL_PATH") bytes)"
else
  if [ ! -f "$SOUL_PATH" ]; then
    cp /app/workspace/SOUL.md.default "$SOUL_PATH"
    echo "[agentsmith] SOUL.md initialized from default"
  fi
fi

echo "[agentsmith] Starting OpenClaw gateway (version: ${OPENCLAW_VERSION:-unknown})"

exec openclaw start --config "$CONFIG_PATH"
