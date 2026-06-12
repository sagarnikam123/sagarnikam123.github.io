---
title: "Open Design: Install & Run Locally on macOS Apple Silicon"
description: "Step-by-step guide to installing and running Open Design — a local-first, open-source AI design tool — on macOS Apple Silicon using Docker or pnpm dev mode."
author: sagarnikam123
date: 2025-07-15 12:00:00 +0530
categories: [ai, open-source]
tags: [open-design, ai, local-ai, macos, apple-silicon, docker, pnpm, design-tools]
mermaid: false
image:
  path: assets/img/posts/20250715/open-design-install-guide-macos-apple-silicon.webp
  alt: Open Design running locally on macOS Apple Silicon
---

[Open Design](https://github.com/nexu-io/open-design) is a local-first, open-source AI design tool that generates web, mobile, and desktop prototypes, slides, and images using your choice of AI agent — Claude Code, Gemini CLI, Codex, OpenCode, and more. Everything runs on your machine.

This guide covers two ways to run it on macOS Apple Silicon: Docker (easiest) and local dev mode (for hacking on the source).

---

## Prerequisites

| Tool | Required Version | Check |
|------|-----------------|-------|
| macOS | Apple Silicon (M1/M2/M3/M4) | `uname -m` → `arm64` |
| Node.js | `~24` | `node --version` |
| pnpm | `10.33.2` | `pnpm --version` |
| Docker Desktop | Any recent version | `docker --version` |

> Node 24 ships with Corepack built-in. Run `corepack enable` once and it will auto-select the pinned pnpm version from the repo.

---

## Option A: Docker (Recommended)

No Node or pnpm setup needed. Just Docker Desktop.

```bash
git clone https://github.com/nexu-io/open-design.git ~/open-design
cd ~/open-design/deploy
docker compose up -d
```

Open the app: **http://localhost:7456**

The first startup pulls the image and may take a minute. After that it's instant.

### Useful Docker commands

```bash
docker compose logs -f       # stream logs
docker compose restart       # restart containers
docker compose pull && docker compose up -d   # update to latest image
docker compose down          # stop
docker compose down -v       # stop + wipe all app data
```

### Optional: override defaults via `deploy/.env`

```env
OPEN_DESIGN_PORT=7456
OPEN_DESIGN_MEM_LIMIT=384m
OPEN_DESIGN_IMAGE=docker.io/vanjayak/open-design:latest
```

---

## Option B: Local Dev Mode

Use this if you want to modify the source or run the latest unreleased code.

### Step 1: Clone and install

```bash
git clone https://github.com/nexu-io/open-design.git ~/open-design
cd ~/open-design

corepack enable
corepack pnpm --version   # should print 10.33.2

pnpm install
```

You'll see a warning about a missing `od` bin — that's expected. The daemon hasn't been built yet.

### Step 2: Build the daemon

```bash
pnpm --filter @open-design/daemon build
```

This generates `apps/daemon/dist/cli.js` and clears the warning.

### Step 3: Start the app

```bash
pnpm tools-dev run web
```

This starts the daemon and the web UI in the foreground. Open the URL printed in the terminal (usually **http://localhost:5174**).

### Other dev commands

```bash
pnpm tools-dev                          # daemon + web + desktop in background
pnpm tools-dev start web                # daemon + web in background
pnpm tools-dev restart                  # restart all
pnpm tools-dev status                   # inspect managed runtimes
pnpm tools-dev logs                     # show logs
pnpm tools-dev stop                     # stop all
```

> Do not use `pnpm dev`, `pnpm start`, or `pnpm daemon` — these legacy aliases have been removed.

---

## Connect an AI Agent

Open Design auto-detects any of these CLIs on your PATH:

| CLI | Install |
|-----|---------|
| `claude` (Claude Code) | [docs.anthropic.com](https://docs.anthropic.com/en/docs/agents-and-tools/claude-code/overview) |
| `gemini` | [ai.google.dev/gemini-api/docs/gemini-cli](https://ai.google.dev/gemini-api/docs/gemini-cli) |
| `codex` | `npm install -g @openai/codex` |
| `opencode` | `curl -fsSL https://opencode.ai/install.sh \| bash` |

If none are installed, go to **Settings → Execution mode → API mode** and paste a provider key.

### Get a free Gemini API key

1. Go to **https://aistudio.google.com/apikey**
2. Sign in with your Google account
3. Click **Create API key** and copy it
4. In Open Design: **Settings → Execution mode → Google Gemini** → paste the key

Gemini 2.0 Flash has a generous free tier — good enough to get started without any cost.

---

## How It Works

```
Your prompt
    ↓
Open Design (daemon + web UI)
    ↓
AI agent (local CLI or API)
    ↓
<artifact> tag parsed from response
    ↓
Live HTML preview in sandboxed iframe
    ↓
Save to disk → .od/artifacts/<timestamp>/index.html
```

Each prompt is composed from three layers:

1. **Base system prompt** — output contract (wrap in `<artifact>`, no code fences)
2. **Design system** — palette, typography, layout (71 built-in systems)
3. **Skill** — workflow and output rules (web prototype, dashboard, deck, mobile app, etc.)

Swap the skill or design system in the top bar and the next prompt uses the new stack.

---

## Troubleshooting

**`better-sqlite3` ABI mismatch after Node version change**

```bash
pnpm --filter @open-design/daemon rebuild better-sqlite3
```

**"no agents found on PATH"**

Install one of the CLIs above, or switch to API mode in Settings. If you installed via `npm install -g` and Open Design still shows it as not found, the GUI may be starting with a minimal PATH. Launch from a full login shell or add the bin directory to PATH explicitly.

**Media generation fails with `OD_BIN: parameter not set`**

```bash
pnpm --filter @open-design/daemon build
pnpm tools-dev restart --daemon-port 7457 --web-port 5175
```

Then reopen the project from the Open Design app (don't resume the old terminal session).

**Artifact never renders**

The model produced text without wrapping in `<artifact>`. Check the daemon log to confirm the system prompt is going through. Try a more capable model or a stricter skill.

---

## References

- [Open Design GitHub](https://github.com/nexu-io/open-design)
- [QUICKSTART.md](https://github.com/nexu-io/open-design/blob/main/QUICKSTART.md)
- [Google AI Studio — API Keys](https://aistudio.google.com/apikey)
- [Ollama](https://ollama.com) — run local LLMs to use as the AI backend
