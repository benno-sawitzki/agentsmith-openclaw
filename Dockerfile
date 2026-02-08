# Agent Smith — OpenClaw Gateway
# Pinned version for supply-chain safety. Update deliberately after testing.

FROM node:22-slim AS base

# Build from PR #8409 branch for WhatsApp pairing code support (issue #4686)
# Revert to pinned release once this is merged: npm install -g openclaw@2026.2.6-3
ENV OPENCLAW_VERSION=fix-4686

# node:22-slim doesn't ship git; openclaw needs it for git-based deps
# Rewrite SSH git URLs to HTTPS so we don't need SSH keys in the image
RUN apt-get update && apt-get install -y --no-install-recommends git ca-certificates proxychains4 curl && rm -rf /var/lib/apt/lists/* \
    && git config --global url."https://github.com/".insteadOf "ssh://git@github.com/"

# Build OpenClaw from PR #8409 branch (pairing code auth)
RUN git clone --branch fix/4686-whatsapp-timeout --depth 1 https://github.com/battman21/openclaw.git /tmp/openclaw \
    && cd /tmp/openclaw && npm install && npm run build && npm install -g . \
    && rm -rf /tmp/openclaw && npm cache clean --force

# /data is the Railway Volume mount point — persists across redeploys
# Note: Railway mounts the volume at runtime as root, so build-time chown
# has no effect. We run as root since it's a single-purpose container.
RUN mkdir -p /data/workspace /data/.openclaw

WORKDIR /app
COPY start.sh ./
COPY openclaw.json ./openclaw.json.default
COPY workspace/SOUL.md ./workspace/SOUL.md.default
COPY proxychains.conf /etc/proxychains4.conf
RUN chmod +x start.sh

# OpenClaw state and workspace live on the persistent volume
ENV OPENCLAW_STATE_DIR=/data/.openclaw
ENV OPENCLAW_WORKSPACE_DIR=/data/workspace
ENV NODE_ENV=production
ENV PORT=8080

EXPOSE 8080

CMD ["bash", "start.sh"]
