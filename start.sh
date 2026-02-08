#!/bin/bash
set -e

CONFIG_PATH="/data/.openclaw/openclaw.json"
SOUL_PATH="/data/workspace/SOUL.md"

# Ensure subdirectories exist — Railway volume mount wipes build-time dirs
mkdir -p /data/workspace /data/.openclaw

# resolve_config: expand ${VAR:-default} patterns and coerce JSON types.
# OpenClaw >=2026.1.30 no longer interpolates env vars in config JSON.
resolve_config() {
  node -e '
    const raw = require("fs").readFileSync(0, "utf8");
    const resolved = raw.replace(/\$\{([^}]+)\}/g, (_, expr) => {
      const [name, fallback] = expr.split(":-");
      return process.env[name] || fallback || "";
    });
    const cfg = JSON.parse(resolved);
    if (typeof cfg.gateway?.port === "string") {
      cfg.gateway.port = parseInt(cfg.gateway.port) || 3000;
    }
    for (const [, ch] of Object.entries(cfg.channels || {})) {
      if (ch && typeof ch.enabled === "string") ch.enabled = ch.enabled === "true";
    }
    process.stdout.write(JSON.stringify(cfg, null, 2));
  '
}

# Write openclaw config from env var (pushed by Agent Smith on provision/sync)
# Falls back to the default baked into the image
if [ -n "$OPENCLAW_CONFIG_JSON" ]; then
  echo "$OPENCLAW_CONFIG_JSON" | resolve_config > "$CONFIG_PATH"
  echo "[agentsmith] openclaw.json written from env"
else
  if [ ! -f "$CONFIG_PATH" ]; then
    resolve_config < /app/openclaw.json.default > "$CONFIG_PATH"
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

exec openclaw gateway
