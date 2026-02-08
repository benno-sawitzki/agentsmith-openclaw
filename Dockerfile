# Agent Smith — OpenClaw Gateway
# Pinned version for supply-chain safety. Update deliberately after testing.

FROM node:22-slim AS base

# Pin the OpenClaw version — bump this when you've tested a new release
ENV OPENCLAW_VERSION=2026.2.6-3

# node:22-slim doesn't ship git; openclaw needs it for git-based deps
# Rewrite SSH git URLs to HTTPS so we don't need SSH keys in the image
RUN apt-get update && apt-get install -y --no-install-recommends git ca-certificates && rm -rf /var/lib/apt/lists/* \
    && git config --global url."https://github.com/".insteadOf "ssh://git@github.com/"

# Install openclaw globally at a locked version
RUN npm install -g openclaw@${OPENCLAW_VERSION} && npm cache clean --force

# /data is the Railway Volume mount point — persists across redeploys
# Note: Railway mounts the volume at runtime as root, so build-time chown
# has no effect. We run as root since it's a single-purpose container.
RUN mkdir -p /data/workspace /data/.openclaw

WORKDIR /app
COPY start.sh ./
COPY openclaw.json ./openclaw.json.default
COPY workspace/SOUL.md ./workspace/SOUL.md.default
RUN chmod +x start.sh

# OpenClaw state and workspace live on the persistent volume
ENV OPENCLAW_STATE_DIR=/data/.openclaw
ENV OPENCLAW_WORKSPACE_DIR=/data/workspace
ENV NODE_ENV=production
ENV PORT=3000

EXPOSE 3000

CMD ["bash", "start.sh"]
