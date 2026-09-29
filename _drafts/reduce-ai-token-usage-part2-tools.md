---
title: "18 Open-Source Tools to Reduce AI Token Usage (Part 2)"
description: "Compare 18 open-source tools that cut AI coding agent token usage, including RTK, Headroom, LeanCTX, Graphify, and Serena with setup commands."
author: sagarnikam123
date: 2026-09-28 12:00:00 +0530
categories: [AI, Coding-Agents]
tags: [reduce-token-usage, token-reduction-tools, open-source-ai, mcp-tools, context-compression, lean-ctx]
mermaid: true
image:
  path: assets/img/posts/20260928/reduce-ai-token-usage-part2-tools.webp
  lqip: data:image/webp;base64,UklGRnoAAABXRUJQVlA4IG4AAAAwBACdASogABEAPpE+m0kloyKhKAqosBIJYwC7L3+A6Nb7wWygY2wntIAA/vkMv0J7D0238oEpiIPw/X6jfOQeKmhLL7eWxRFC4xVU1yk8I8kSqNhF8DHIH1f3c1wAeHeYQ4QeOcSbJy0oWAAAAA==
  alt: Open-source tools that reduce AI coding agent token usage across shell, MCP, and proxy layers
---

In **[Part 1: The Techniques]({% post_url 2026-09-28-reduce-ai-token-usage-part1-techniques %})**, we explored the architectural mechanisms of agent token bloat and the 25 core optimization principles. 

In this article (**Part 2**), we move from principles to software. If you want to **reduce token usage** with minimal effort, these are the open-source tools that do it for you. We evaluate **18 open-source tools, MCP middleware, CLI proxies, and context compressors** engineered specifically to cut token consumption across every layer of the agent stack.

> **Last verified:** September 2026. Repository URLs, licenses, and install commands re-checked against current releases. GitHub ★ counts are snapshots and change quickly. Savings figures are **author/vendor-reported** unless noted otherwise.

---

## Series Navigation

* **[Part 1: The Techniques]({% post_url 2026-09-28-reduce-ai-token-usage-part1-techniques %})** — What causes token bloat and 25 methods to prevent it.
* **Part 2 (This Guide):** *The Tools* — Standardized catalog, comparison matrix, and layer breakdown of token-saving software.

### TL;DR

* **Zero-runtime quick win:** Start with **Caveman** (terse output prose) + **Ponytail** (YAGNI code rules).
* **Terminal noise filter:** Add **RTK** to compress shell command outputs by 60–90%.
* **Code intelligence:** Pick **one** graph tool (**Graphify**, **Graft**, or **CodeGraph**) plus **Serena** for symbol lookup.
* **Proxy / cache layer:** Pick **one** (**Headroom**, **LeanCTX**, **Token Optimizer MCP**, or **context-mode**)—never nest them.
* **Web LLM audits:** Use **Repomix** to pack codebases for browser chats (ChatGPT / Claude web).

---

## The Agent Optimization Stack

Rather than installing ten overlapping tools, think of token optimization as a multi-tier pipeline. Each layer addresses a different point in the [Model Context Protocol (MCP)](https://modelcontextprotocol.io/) and agent lifecycle:

```mermaid
graph TD
    subgraph "Layer 1: Prompt steering — stack freely"
        CAVE[Caveman: Terse Technical Prose]
        PONY[Ponytail: YAGNI Code Minimization]
    end

    subgraph "Layer 2: Proxy / cache / smart tools — pick ONE"
        HEADROOM[Headroom: Semantic Proxy Compression]
        LCTX_P[LeanCTX: Cached Reads + Memory]
        TOMCP[Token Optimizer MCP: Caching Middleware]
        CMODE[context-mode: Sandbox Tool Output]
    end

    subgraph "Layer 3a: Code graph — pick ONE"
        GRAPH[Graphify: AST Architecture Graph]
        GRAFT[Graft: Prose + Symbol Wiring]
        CGRAPH[CodeGraph: SQLite Call Graph]
        TSAVE[TokenSave: Rust Semantic Graph]
    end

    subgraph "Layer 3b: Symbol lookup — pick ONE graph-or-LSP path"
        SERENA[Serena: LSP Symbol Tools]
    end

    subgraph "Layer 3c: Semantic search — pick ONE"
        SEMBLE[semble: CPU NL Search]
        CCONTEXT[Code Context: Hybrid RAG]
    end

    subgraph "Layer 4: Shell interception — pick ONE"
        RTK[RTK: CLI Output Filtering]
        LCTX_S[LeanCTX Shell: Command Filtering]
    end
```

Peers marked **“pick ONE”** are alternatives, not a shopping list—details in [Conflicts & Overlaps](#conflicts--overlaps-what-stacks-safely). Serena pairs with **one** graph tool. Caveman + Ponytail stack with everything.

---

## Comprehensive Tool Comparison Matrix

Use this matrix to quickly evaluate tools by layer, mechanism, target use case, and claimed savings. Click any tool name to jump to its fast-decision profile.

<div style="overflow-x: auto;" markdown="1">

| Tool | ★ Stars | Layer | How It Cuts Tokens | Best For (When to Use) | Claimed Savings |
| :--- | ---: | :--- | :--- | :--- | :--- |
| **[Ponytail](#1-ponytail--yagni-code-rules)** | 147k | Code Rules | 7-step ladder forces stdlib/native reuse over new code | Preventing agent code bloat with zero runtime | ~20–30% (code) |
| **[Graphify](#2-graphify--local-ast-knowledge-graph)** | 122.1k | Knowledge Graph | Tree-sitter AST (`graph.json`) replaces multi-file reads | Architecture navigation in 37+ languages | 5–70× vs reads |
| **[Caveman](#3-caveman--terse-output-prose)** | 108k | Output Prose | Strips conversational pleasantries and filler text | Slashing output token cost across 30+ agents | 60–80% (output) |
| **[RTK](#4-rtk--cli-output-interception)** | 81.9k | Shell Intercept | Filters and deduplicates terminal noise (`git`, tests, builds) | Terminal-heavy agent workflows | 60–90% (shell) |
| **[Headroom](#5-headroom--api-proxy-compression)** | 74k | API Proxy | Reversible semantic compression on full session payloads | Full-session API payload compression | 60–95% (payloads) |
| **[CodeGraph](#6-codegraph--sqlite-symbolcall-graph)** | 72k | Knowledge Graph | Tree-sitter AST → SQLite symbol/call/import graph | Local-first structural code queries | ~62% fewer tokens |
| **[Context7](#7-context7--live-library-docs)** | 62k | Live Docs (MCP) | Injects current, version-specific library documentation | Eliminating hallucinated and outdated APIs | Eliminates retries |
| **[Serena](#8-serena--lsp-symbol-tools)** | 29.9k | Symbol Lookup | Connects agent to LSP servers for symbol-level lookups | Precise IDE-grade refactoring without raw reads | Eliminates raw reads |
| **[Repomix](#9-repomix--offline-repo-pack-for-web-llms)** | 29k | Offline Bundler | Packs codebase into a single token-counted file | One-shot code reviews in web LLMs (Claude web/ChatGPT) | N/A (offline) |
| **[context-mode](#10-context-mode--sandbox-bulky-tool-output)** | 24k | Context Sandbox | Sandboxes bulky tool dumps outside LLM, retrieves via FTS5 | Heavy tool users (Playwright, test logs) | Up to 98% (tool logs) |
| **[Code Context](#11-code-context--hybrid-code-rag)** | 12.6k | Semantic RAG | Hybrid BM25 + Milvus vector indexing over code chunks | Natural language conceptual search in large repos | ~40% token cut |
| **[Graft](#12-graft--plain-english-codebase-graph)** | 9.3k | Architecture Map | Plain-English summary + symbol wiring in `.graft/` | Fast developer & agent orientation on unfamiliar repos | 66% SWE-bench |
| **[semble](#13-semble--nl-code-search-cpu)** | 6.2k | NL Code Search | 100% CPU search via Model2Vec (`potion-code-16M`) + BM25 RRF | Fast, private code search without GPU or vector DB | ~98% vs grep+read |
| **[LeanCTX](#14-leanctx--cached-reads--session-memory)** | 3.8k | Context & Memory | Cached reads (~13 tokens), AST signatures, shell filter, memory | Monorepos and multi-session projects | 60–90% + cache |
| **[dirac](#15-dirac--hash-anchored-agent-harness)** | 1.5k | Agent Harness | Standalone agent with hash-anchored diffs & AST edits | Replacing heavy agent wrappers with an efficient harness | 50–80% cost cut |
| **[Token Savior](#16-token-savior--pointer-navigation--memory)** | 1.2k | Navigation & Memory | Indexes symbols for pointer navigation + SQLite/vector memory | Multi-session memory and pointer-based navigation | Up to 97% injected tokens |
| **[TokenSave](#17-tokensave--rust-semantic-code-graph)** | 650 | Rust Code Graph | Pre-indexed semantic graph in Rust for symbol/caller lookups | Fast, lightweight symbol graphing without Python/LSP | 60–90% file read tokens |
| **[Token Optimizer MCP](#18-token-optimizer-mcp--smart-tool-caching)** | 537 | Tool Caching | Content-hash caching and compression for repeated MCP calls | Workflows with redundant/repetitive tool invocations | >95% on repeated calls |

</div>

---

## Quick Decision Guide: Which Stack Do You Need?

* **Solo developer wanting instant wins with zero setup?**
  Install **Caveman + Ponytail**. They are pure prompt steering rules with zero runtime overhead that immediately stop verbose pleasantries and boilerplate code generation.
* **Active daily coding in a medium codebase?**
  Use **RTK + Graphify + Serena**. RTK cleans your shell noise, Graphify maps your architecture, and Serena provides IDE-grade symbol lookups without dumping raw files.
* **Large monorepo or persistent multi-session workflows?**
  Choose **LeanCTX** (cached reads + durable session memory) **or** **Headroom** (API proxy compression)—not both. Layer Graphify and Serena on top. *(Note: If LeanCTX shell filtering is enabled, skip RTK to prevent double-filtering).*
* **Pasting repositories into web interfaces (Claude web, ChatGPT, Gemini)?**
  Run **Repomix** to pack your repository into a single structured, token-counted XML file.

---

## 1. [Ponytail](https://github.com/DietrichGebert/ponytail) — YAGNI Code Rules

* **How it works:** Injects an always-on ruleset into your agent (`AGENTS.md` / Cursor rules) enforcing a 7-step "ladder": YAGNI → Reuse → Stdlib → Native → Dependencies → One-liner → Minimum code.
* **When to use:** Whenever you want your AI agent to act like a disciplined senior engineer and avoid writing unnecessary helper libraries or boilerplate.
* **License:** MIT
* **Quick Install:**
  ```bash
  curl -o ~/.claude/AGENTS.md https://raw.githubusercontent.com/DietrichGebert/ponytail/main/AGENTS.md
  # Or copy into your project .cursor/rules/ or AGENTS.md
  ```
* **Watch out:** Pure steering rules—no background runtime. Pair with Caveman for combined output and generation discipline.

---

## 2. [Graphify](https://github.com/Graphify-Labs/graphify) — Local AST Knowledge Graph

* **How it works:** Parses your codebase using Tree-sitter into a local `graph.json` knowledge graph across 37+ languages. Agents query the graph to understand relationships instead of reading dozens of source files.
* **When to use:** Best for exploring codebase architecture, tracing dependency paths, and finding cross-module connections in medium to large projects.
* **License:** Apache 2.0
* **Quick Install:**
  ```bash
  uv tool install graphifyy   # Note: PyPI package is graphifyy (two y's)
  graphify install            # Registers skill with detected agents
  cd your-project && graphify extract . --code-only
  ```
* **Watch out:** Remember to run `graphify hook install` to keep the graph updated on commit. Pick **one** graph tool (vs Graft, CodeGraph, or TokenSave).

---

## 3. [Caveman](https://github.com/JuliusBrussee/caveman) — Terse Output Prose

* **How it works:** Instructs coding agents across 30+ platforms to communicate in a compact, terse style. It strips pleasantries and filler text while keeping code blocks, paths, and commands completely intact.
* **When to use:** Whenever you want an instant 60–80% reduction in output tokens with zero installation complexity or runtime cost.
* **License:** MIT
* **Quick Install:**
  ```bash
  npx skills add JuliusBrussee/caveman -g
  # Trigger manually if needed: /caveman
  ```
* **Watch out:** May feel too abrupt for educational or onboarding conversations where conversational explanations are desired.

---

## 4. [RTK](https://github.com/rtk-ai/rtk) — CLI Output Interception

* **How it works:** A Rust-based CLI wrapper that intercepts terminal commands run by agents (`git`, `cargo`, `npm`, `pytest`, `docker`) and strips out redundant noise, progress bars, and repetitive logs before they reach the model.
* **When to use:** Essential for terminal-heavy agents (Claude Code, Cursor, Gemini CLI) running builds, tests, or git commands.
* **License:** Apache 2.0
* **Quick Install:**
  ```bash
  # macOS / Linux
  brew install rtk && rtk init -g
  # Windows
  winget install rtk-ai.rtk
  # Check savings anytime
  rtk gain
  ```
* **Watch out:** Only filters CLI commands run in the terminal. File reads and MCP payloads bypass it.

---

## 5. [Headroom](https://github.com/headroomlabs-ai/headroom) — API Proxy Compression

* **How it works:** Sits as an intelligent HTTP proxy between your coding agent and LLM providers. It semantically compresses payloads (tool outputs, file contents, conversation history) before they reach the API, with reversible retrieval if the model requests details.
* **When to use:** Ideal when using API-direct agents (Claude Code, Aider, Codex) where you want automatic whole-session payload compression.
* **License:** Apache 2.0
* **Quick Install:**
  ```bash
  pipx install --python python3.13 "headroom-ai[all]"
  # Wrap your agent directly:
  headroom wrap claude
  # View live compression metrics:
  headroom perf
  ```
* **Watch out:** Adds a minor network hop (~50–100ms) and requires Python 3.10+. Pick **one** proxy/cache layer—do not nest with LeanCTX or context-mode.

---

## 6. [CodeGraph](https://github.com/colbymchenry/codegraph) — SQLite Symbol/Call Graph

* **How it works:** Uses Tree-sitter to parse your codebase into an AST, storing symbols, call graphs, import chains, and framework routes in a local SQLite database (`.codegraph/`), exposed directly via MCP.
* **When to use:** Best for developers wanting a 100% local, zero-config structural graph that auto-syncs on file changes across 30+ languages.
* **License:** MIT
* **Quick Install:**
  ```bash
  npm i -g @colbymchenry/codegraph
  codegraph install           # Auto-configures detected MCP agents
  cd your-project && codegraph init
  ```
* **Watch out:** Pick **one** graph tool (vs Graphify, Graft, or TokenSave). Benchmarks show fewer active tokens processed but higher residual context after answers.

---

## 7. [Context7](https://github.com/upstash/context7) — Live Library Docs

* **How it works:** An MCP server by Upstash that retrieves up-to-date, version-specific library documentation and verified code snippets at query time, injecting only relevant doc sections into context.
* **When to use:** Use when working with rapidly evolving frameworks (Next.js, Tailwind, LangChain) where AI agents frequently hallucinate deprecated methods.
* **License:** MIT
* **Quick Install:**
  ```bash
  npx ctx7 setup
  ```
  *Or add directly to your `claude_desktop_config.json` / agent MCP config:*
  ```json
  {
    "mcpServers": {
      "context7": {
        "command": "npx",
        "args": ["-y", "@upstash/context7-mcp@latest"]
      }
    }
  }
  ```
* **Watch out:** Requires internet access. Stacks cleanly with all local graph, shell, and proxy tools.

---

## 8. [Serena](https://github.com/oraios/serena) — LSP Symbol Tools

* **How it works:** Integrates Language Server Protocol (LSP) engines with MCP. Enables agents to perform precise operations (`find_symbol`, `get_references`, `goto_definition`, diagnostics) without reading whole source files.
* **When to use:** Best for complex refactoring, type checking, and navigating deeply nested codebases across 30+ languages.
* **License:** GPL-3.0-or-later / MIT
* **Quick Install:**
  ```bash
  uv tool install serena-agent
  cd your-project && serena init
  ```
* **Watch out:** Requires the relevant language server (e.g., Pyright, TS server) to be installed locally. Pairs with **one** architecture graph tool (like Graphify).

---

## 9. [Repomix](https://github.com/yamadashy/repomix) — Offline Repo Pack for Web LLMs

* **How it works:** Packs an entire repository into a single structured, token-counted XML, Markdown, or JSON file with automatic `.gitignore` adherence and security secret scrubbing.
* **When to use:** When performing one-off architectural reviews, debugging sessions, or security audits using browser-based LLMs (Claude web, ChatGPT, Gemini).
* **License:** MIT
* **Quick Install:**
  ```bash
  # Pack current directory instantly:
  npx repomix@latest
  # With token compression:
  npx repomix --compress
  ```
* **Watch out:** Static snapshot; not intended for iterative, multi-turn CLI agent loops where code is actively changing.

---

## 10. [context-mode](https://github.com/mksglu/context-mode) — Sandbox Bulky Tool Output

* **How it works:** An MCP server that executes tools in isolated subprocesses and captures bulky outputs (Playwright browser snapshots, voluminous test logs, git dumps), storing them in a local SQLite FTS5 database and returning compact summaries.
* **When to use:** Best for workflows involving browser automation, large test suite outputs, or heavy terminal scraping that quickly blow up context windows.
* **License:** Elastic License 2.0
* **Quick Install:**
  ```bash
  claude mcp add context-mode -- npx -y context-mode
  ```
* **Watch out:** Sits in the proxy/sandbox layer—**pick one** (do not combine with Headroom or LeanCTX).

---

## 11. [Code Context](https://github.com/zilliztech/claude-context) — Hybrid Code RAG

* **How it works:** An MCP server from Zilliz combining dense vector search (via Milvus or Zilliz Cloud) with BM25 lexical search. It retrieves relevant code snippets dynamically instead of forcing agents to read full folders.
* **When to use:** When you need natural language semantic search across very large codebases where simple keyword grep fails.
* **License:** MIT
* **Quick Install:**
  ```bash
  claude mcp add claude-context \
    -e OPENAI_API_KEY=your-key \
    -e MILVUS_ADDRESS=your-milvus-endpoint \
    -e MILVUS_TOKEN=your-token \
    -- npx @zilliz/claude-context-mcp@latest
  ```
* **Watch out:** Requires an embedding provider and Milvus instance. For a 100% offline, CPU-only alternative without external DBs, choose **semble**.

---

## 12. [Graft](https://github.com/trailhq/Graft) — Plain-English Codebase Graph

* **How it works:** Builds a local knowledge graph of plain-English file explanations and symbol wiring stored in a `.graft/` directory. Provides AI agents with an instant mental model upon opening a project.
* **When to use:** Excellent for onboarding onto unfamiliar or legacy codebases, giving agents immediate orientation without repeated file scanning.
* **License:** MIT
* **Quick Install:**
  ```bash
  npm install -g @nanonets/graft
  cd your-project && graft init
  ```
* **Watch out:** The `.graft/` cache is local and gitignored. To disable optional telemetry, run `graft telemetry disable` or set `DO_NOT_TRACK=1`. Pick **one** graph tool.

---

## 13. [semble](https://github.com/MinishLab/semble) — NL Code Search (CPU)

* **How it works:** A local code search engine running 100% on CPU. Combines static embeddings from Model2Vec (`potion-code-16M`) with BM25 lexical search using Reciprocal Rank Fusion (RRF).
* **When to use:** When you want fast, private semantic search (“find token refresh logic”) without setting up a vector database or paying for embedding APIs.
* **License:** MIT
* **Quick Install:**
  ```bash
  pip install semble
  semble index .
  semble search "authentication token validation"
  ```
* **Watch out:** Optimized for codebases under ~500K LOC. Pairs smoothly with CodeGraph or Serena for structural navigation.

---

## 14. [LeanCTX](https://github.com/yvgude/lean-ctx) — Cached Reads & Session Memory

* **How it works:** A local Rust binary providing an MCP context intelligence layer. Caches file reads (subsequent reads of unchanged files cost ~13 tokens), provides AST signature views, filters shell commands, and retains cross-session memory.
* **When to use:** The top choice for long-running, multi-session tasks and monorepos where repetitive file re-reading is the primary cost driver.
* **License:** Apache 2.0
* **Quick Install:**
  ```bash
  brew tap yvgude/lean-ctx && brew install lean-ctx
  lean-ctx setup              # Auto-configures detected agents
  lean-ctx gain               # View token savings ledger
  ```
* **Watch out:** If LeanCTX's shell filtering is enabled, disable RTK to avoid double-filtering. Sits in the proxy/cache layer—do not combine with Headroom.

---

## 15. [dirac](https://github.com/dirac-run/dirac) — Hash-Anchored Agent Harness

* **How it works:** A standalone token-efficient agent harness ([dirac.run](https://dirac.run/), fork of Cline) featuring hash-anchored edits, AST-level manipulation, parallel tool operations, and smart model routing.
* **When to use:** When you want an all-in-one alternative agent harness designed from the ground up to reduce API costs instead of wrapping Claude Code or Cursor.
* **License:** Apache 2.0
* **Quick Install:**
  ```bash
  npm install -g dirac-cli
  # Or install the VS Code / Open VSX extension: dirac-run.dirac
  ```
* **Watch out:** Dirac is a complete agent harness. Do not run Dirac and another agent on the same workspace concurrently.

---

## 16. [Token Savior](https://github.com/Mibayy/token-savior) — Pointer Navigation & Memory

* **How it works:** Indexes codebases by symbols so agents navigate via pointers rather than reading whole files. Includes a persistent memory engine using SQLite (WAL + FTS5) and vector embeddings to inject compact session state into new runs.
* **When to use:** When your agent repeatedly loses context across multi-turn sessions and wastes tokens re-reading files to locate definitions.
* **License:** MIT
* **Quick Install:**
  ```bash
  pip install "token-savior-recall[mcp]"
  ts init --agent claude --yes
  ```
* **Watch out:** Navigation and memory layer. Best paired with an architecture graph tool (Graphify) or Serena.

---

## 17. [TokenSave](https://github.com/aovestdipaperino/tokensave) — Rust Semantic Code Graph

* **How it works:** A high-performance Rust MCP tool that indexes code into a semantic knowledge graph for symbol and caller lookups without requiring a heavy Python runtime or LSP daemon.
* **When to use:** When you want lightweight, fast symbol graphing and caller lookups in a single standalone binary.
* **License:** MIT
* **Quick Install:**
  ```bash
  cargo install tokensave
  tokensave install           # Auto-configures MCP coding agents
  ```
* **Watch out:** Supports fewer language grammars than Tree-sitter in Graphify or Serena. Counts as your **one** graph pick (skip Serena if using TokenSave for symbol lookups).

---

## 18. [Token Optimizer MCP](https://github.com/ooples/token-optimizer-mcp) — Smart Tool Caching

* **How it works:** An MCP server that intercepts repeated tool calls. When an agent invokes tools with identical or similar parameters, it delivers a compressed, cached response rather than re-executing and returning full payloads.
* **When to use:** When your agent repeatedly calls inspection or test tools with identical parameters during complex debugging loops.
* **License:** MIT
* **Quick Install:**
  Add to your agent's MCP configuration:
  ```json
  {
    "mcpServers": {
      "token-optimizer": {
        "command": "npx",
        "args": ["-y", "@ooples/token-optimizer-mcp@latest"]
      }
    }
  }
  ```
* **Watch out:** Sits in the proxy/cache layer. Do not stack beside Headroom or LeanCTX.

---

## Cost & Token Monitoring Utilities

To verify your savings after installing these tools, use these monitoring utilities:

* **`rtk gain`:** Displays a real-time terminal dashboard of tokens and dollars saved by RTK across your shell commands.
* **`headroom perf`:** Shows live compression ratios, latency impact, and token reductions for Headroom proxy sessions.
* **`npx ccusage`:** Tracks daily and historical dollar and token expenditures for Claude Code.
* **LiteLLM Proxy:** Tracks costs, implements budget guardrails, and provides caching across multiple LLM providers.

---

## Conflicts & Overlaps: What Stacks Safely

<div style="overflow-x: auto;" markdown="1">

| Layer / Capability | Tools | Compatibility Rule | Explanation & Guidance |
| :--- | :--- | :--- | :--- |
| **Prompt steering** | Caveman (terse prose) + Ponytail (YAGNI code) | ✅ **Stack with everything** | Pure prompt rules; zero runtime overhead. They do different jobs (output style vs. code generation discipline)—use both. |
| **Shell interception** | RTK vs. LeanCTX shell filter | ⚠️ **Pick ONE** | Both rewrite terminal output (`git`, `cargo`, `npm`, tests). If using LeanCTX, disable its shell hook to use RTK, or use LeanCTX for both. |
| **Proxy / cache / sandbox** | Headroom vs. LeanCTX (cached reads) vs. Token Optimizer MCP vs. context-mode | ⚠️ **Pick ONE** | Different architectures (HTTP reverse proxy, cached MCP reads, tool-call deduplication, subprocess sandbox). Nesting them creates competing tool definitions and compression artifacts. |
| **Code architecture graph** | Graphify vs. Graft vs. CodeGraph vs. TokenSave | ⚠️ **Pick ONE** | All build structural codebase maps. Choose **Graphify** for broad 37+ language coverage, **Graft** for human-readable prose maps, **CodeGraph** for SQLite MCP queries, or **TokenSave** for a standalone Rust binary. |
| **Symbol lookup** | Serena vs. TokenSave | ⚠️ **Pick ONE** | Both answer symbol/caller queries. **Serena** uses LSP and pairs with an architecture graph (Graphify/Graft/CodeGraph). **TokenSave** replaces both the graph and symbol layer in Rust. |
| **Semantic code search** | semble vs. Code Context | ⚠️ **Pick ONE** | Both provide natural language code search. **semble** is 100% local, CPU-only (Model2Vec + BM25, 0 config). **Code Context** uses Milvus/Zilliz and requires an embedding provider. |
| **Session memory & pointers** | Token Savior vs. LeanCTX memory | ℹ️ **Conditional add-on** | Adds symbol pointer navigation and persistent memory across sessions. Redundant if using LeanCTX (which has built-in memory); ideal add-on if using the RTK + Graphify stack. |
| **Live library docs** | Context7 | ✅ **Stack with everything** | Network-based docs CDN via MCP. Fills a knowledge gap that local code graph and search tools cannot touch. |
| **Offline repository pack** | Repomix | ✅ **Orthogonal (web chat)** | One-shot snapshot bundler for browser chats (ChatGPT, Claude web). Not intended for active multi-turn CLI agent loops. |
| **Agent harness** | Dirac vs. Claude Code / Cursor / Aider | ⚠️ **Pick ONE** | Dirac is a standalone agent with its own hash-anchored edit engine; do not run Dirac and another agent simultaneously on the same workspace. |

</div>

---

## Frequently Asked Questions

**Which tool should I install first to reduce token usage?**
Start with **Caveman** (zero setup, 60–80% output token reduction) and **RTK** (`brew install rtk`, 60–90% shell output reduction). These two eliminate the highest-volume token waste without altering your coding workflow.

**RTK vs Headroom vs LeanCTX — which should I choose?**
They operate at different layers:
- **RTK** filters CLI command output only.
- **Headroom** acts as an API proxy, compressing full payloads (file reads, conversation history, tool outputs).
- **LeanCTX** caches file reads (~13 tokens on re-reads), provides AST signatures, and adds session memory.
Pick **one** proxy/cache tool (Headroom or LeanCTX). If LeanCTX's shell filter is enabled, skip RTK.

**Do these tools work with Claude Code, Cursor, and Gemini CLI?**
Yes. RTK, Caveman, Ponytail, Graphify, and Serena work across all major coding agents via MCP or shell hooks. Headroom is strongest with Anthropic-compatible API agents (Claude Code, Codex, Aider). Check each tool's section for specific setup commands.

**Will these tools break my existing MCP setup?**
No, as long as you do not run multiple proxy-layer tools simultaneously. Prompt rules, CLI hooks, and MCP servers register alongside existing tools.

**Are these tools free and open source?**
Most are open-source under MIT or Apache 2.0. Notable exceptions: Serena's application layer is GPL-3.0-or-later, and context-mode uses Elastic License 2.0. Context7 and Code Context use external network connections for docs and embeddings respectively.

**How do I measure actual savings after installing these tools?**
Run `rtk gain` for RTK terminal savings, `headroom perf` for proxy compression metrics, or `npx ccusage` for Claude Code dollar tracking. Compare your tokens-per-task before and after installation.

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "Which tool should I install first to reduce token usage?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Start with Caveman (zero setup, 60–80% output token reduction) and RTK (brew install rtk, 60–90% shell output reduction). These two eliminate the highest-volume token waste without altering your coding workflow."
      }
    },
    {
      "@type": "Question",
      "name": "RTK vs Headroom vs LeanCTX — which should I choose?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "They operate at different layers. RTK filters CLI command output only. Headroom acts as an API proxy compressing full payloads. LeanCTX caches file reads and adds session memory. Pick one proxy/cache tool."
      }
    },
    {
      "@type": "Question",
      "name": "Do these tools work with Claude Code, Cursor, and Gemini CLI?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. RTK, Caveman, Ponytail, Graphify, and Serena work across all major coding agents via MCP or shell hooks."
      }
    },
    {
      "@type": "Question",
      "name": "Will these tools break my existing MCP setup?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "No, as long as you do not run multiple proxy-layer tools simultaneously. Prompt rules, CLI hooks, and MCP servers register alongside existing tools."
      }
    },
    {
      "@type": "Question",
      "name": "Are these tools free and open source?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Most are open-source under MIT or Apache 2.0. Serena includes GPL-3.0-or-later components and context-mode uses Elastic License 2.0."
      }
    },
    {
      "@type": "Question",
      "name": "How do I measure actual savings after installing these tools?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Run rtk gain for RTK terminal savings, headroom perf for proxy compression metrics, or npx ccusage for Claude Code dollar tracking."
      }
    }
  ]
}
</script>

---

## Next in the Series

Now that you know the tools and their compatibility rules, revisit **[Part 1: The Techniques]({% post_url 2026-09-28-reduce-ai-token-usage-part1-techniques %})** for the architectural playbook—or install the Quick Start stack above and measure your token savings on your next task.

---

*Last verified: September 2026. Tool ecosystems evolve rapidly — always check official repositories for the latest release notes and compatibility updates.*
