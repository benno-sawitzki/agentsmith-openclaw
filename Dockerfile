# Agent Smith — OpenClaw Gateway
# Pinned version for supply-chain safety. Update deliberately after testing.

FROM node:22-slim AS base

# Pin the OpenClaw version — bump this when you've tested a new release
ENV OPENCLAW_VERSION=2026.1.30

# Install openclaw globally at a locked version
RUN npm install -g openclaw@${OPENCLAW_VERSION} && npm cache clean --force

# Create a non-root user
RUN groupadd -r openclaw && useradd -r -g openclaw -m openclaw

# /data is the Railway Volume mount point — persists across redeploys
RUN mkdir -p /data/workspace /data/.openclaw && chown -R openclaw:openclaw /data

WORKDIR /app
COPY start.sh ./
COPY openclaw.json ./openclaw.json.default
COPY workspace/SOUL.md ./workspace/SOUL.md.default
RUN chmod +x start.sh && chown -R openclaw:openclaw /app

USER openclaw

# OpenClaw state and workspace live on the persistent volume
ENV OPENCLAW_STATE_DIR=/data/.openclaw
ENV OPENCLAW_WORKSPACE_DIR=/data/workspace
ENV NODE_ENV=production
ENV PORT=3000

EXPOSE 3000

CMD ["bash", "start.sh"]
