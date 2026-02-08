# OpenClaw Channels — Setup & Security Guide

## How Channels Work

### WhatsApp
- Links your **personal WhatsApp account** as a "linked device" (like WhatsApp Web)
- The bot operates **as you** — replies come from your phone number
- Anyone who messages your number talks to the bot
- There is no separate "bot number" — it's your account with AI behind it
- Config: `channels.whatsapp.dmPolicy` controls who the bot responds to

### Telegram
- Uses a **separate bot account** created via [@BotFather](https://t.me/BotFather)
- The bot has its own username (e.g. `@CareerNerdsBot`), name, and avatar
- People know they're talking to a bot
- Share your bot via `t.me/YourBotName` — anyone can tap "Start" and chat
- Config: `channels.telegram.enabled`, `channels.telegram.botToken`
- Tip: long-press the bot chat in Telegram and "Pin" to keep it at the top of your list

## DM Policies

| Policy | Behavior |
|--------|----------|
| `disabled` | Bot doesn't respond to DMs |
| `pairing` | Only for WhatsApp linking flow |
| `everyone` | Bot responds to all incoming DMs |

Set via Railway env var: `WHATSAPP_DM_POLICY=everyone`

## Security: Personal Assistant vs. Public Bot

The bot has access to everything in its workspace (SOUL.md, tools, plugins). Before opening it to the public, understand the two modes:

### Personal Assistant (just for you)
- Give the bot full access: emails, files, documents, browsing
- Lock `dmPolicy` so only you can interact
- The bot is your private AI assistant

### Customer-Facing Bot (open to everyone)
- **Only put public knowledge in SOUL.md** — brand voice, product info, FAQs
- **Remove private tools** — no email access, no file browsing, no document search
- Set `dmPolicy` to `everyone`
- The bot only answers questions based on brand knowledge

### Why This Matters

If the bot has email/file tools enabled and `dmPolicy` is open, **anyone** could:
- Ask to see your emails
- Tell the bot to send emails on your behalf
- Access private documents in the workspace
- Read internal business data

The bot doesn't distinguish between you and a stranger. It serves whoever messages it.

### Checklist Before Going Public

1. Review SOUL.md — remove any private/internal information
2. Disable sensitive tools/plugins in the OpenClaw config (email, file access, browsing)
3. Test with a friend — have them message the bot and try to access private data
4. Set `dmPolicy` to `everyone` only after the above is confirmed safe
5. Monitor conversations initially to make sure the bot behaves correctly

## Current Setup (CareerNerds)

| Setting | Value | Status |
|---------|-------|--------|
| OpenClaw version | `2026.2.6-3` | Latest |
| WhatsApp | `dmPolicy: pairing` | Blocked — pairing fails (Baileys bug #4686) |
| Telegram | `enabled: false` | Not configured yet |
| Proxy | Bright Data ISP (German IP) | Active, working |
| SOUL.md | Brand knowledge loaded | Via `SOUL_MD` env var |
