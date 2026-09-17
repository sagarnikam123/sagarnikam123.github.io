---
title: "Open Knowledge Format (OKF): AI Agent Knowledge in Markdown"
description: "Learn Google's Open Knowledge Format (OKF) v0.2 spec to build portable, agent-readable markdown knowledge bases with OpenWiki, trust tiers, and Archify."
author: sagarnikam123
date: 2026-08-27 10:00:00 +0530
categories: [AI, Context-Engineering]
tags: [okf, open-knowledge-format, ai-agents, context-engineering, knowledge-graph]
mermaid: true
image:
  path: assets/img/posts/20260827/open-knowledge-format-okf-ai-agent-context.jpg
  alt: Open Knowledge Format bundle structure showing markdown files with YAML frontmatter connecting into a knowledge graph
---

Your agent can write perfect Go, but it doesn't know that `customer_id` in the orders table joins to `id` in the customers table. It doesn't know your revenue metric follows a specific fiscal-year recognition policy. It doesn't know that the deprecated v1 API still handles 40% of traffic.

That knowledge exists — scattered across Confluence pages, Notion docs, code comments, Slack threads, and the heads of three senior engineers who've been here since 2019. AI agents are getting smarter every month, but smarter models still produce garbage when they lack the right context. The real bottleneck in production AI systems isn't intelligence — it's **knowledge discovery**.

**Open Knowledge Format (OKF)** is Google Cloud's answer: an open, vendor-neutral specification that turns organizational knowledge into portable, agent-readable markdown files. No SDK. No database. No vendor lock-in. Just files.

> **Spec version:** OKF v0.2 (June 2026). Last verified August 2026.

---

## Table of Contents

- [The Fragmented Context Problem](#the-fragmented-context-problem)
- [The LLM Wiki Pattern](#the-llm-wiki-pattern)
- [What is Open Knowledge Format (OKF)?](#what-is-open-knowledge-format-okf)
- [OKF v0.2 Spec Walkthrough](#okf-v02-spec-walkthrough)
  - [Bundle Structure](#bundle-structure)
  - [Concept Documents](#concept-documents)
  - [Provenance, Trust, and Lifecycle](#provenance-trust-and-lifecycle)
  - [Cross-Linking](#cross-linking)
  - [Attested Computations](#attested-computations)
- [OKF vs Existing Knowledge Systems](#okf-vs-existing-knowledge-systems)
- [Building Your First OKF Bundle](#building-your-first-okf-bundle)
- [Consuming OKF: Agents, Viewers, and Search](#consuming-okf-agents-viewers-and-search)
- [OpenWiki: The Practical Bridge Between OKF and Coding Agents](#openwiki-the-practical-bridge-between-okf-and-coding-agents)
  - [How OpenWiki Works](#how-openwiki-works)
  - [Installation & Configuration](#installation--configuration)
  - [Generating and Updating the Wiki](#generating-and-updating-the-wiki)
  - [Integrating with Google Antigravity & Coding Agents](#integrating-with-google-antigravity--coding-agents)
  - [Why OpenWiki Matters for OKF Adoption](#why-openwiki-matters-for-okf-adoption)
  - [Related Tools for Agent-Readable Architecture](#related-tools-for-agent-readable-architecture)
- [Visualizing Knowledge with Archify](#visualizing-knowledge-with-archify)
- [Practical Integration Patterns](#practical-integration-patterns)
- [Early Adoption](#early-adoption)
- [Limitations and What's Next](#limitations-and-whats-next)
- [Frequently Asked Questions](#frequently-asked-questions)
- [Getting Started](#getting-started)

---

## The Fragmented Context Problem

In most organizations, the knowledge AI agents need is overwhelmingly internal:

- The schema of a table and what each column actually means
- The business definition of a metric ("Weekly Active Users" means different things to different teams)
- The runbook for an incident
- The join paths between two systems
- The deprecation notice for an old API
- Which team owns which service

Today, these atoms of knowledge live across incompatible surfaces:

```mermaid
graph TD
    Agent([AI Agent needs context]) --> Q{Where is it?}
    Q --> A[Metadata Catalogs<br/>with proprietary APIs]
    Q --> B[Wikis & Shared Drives<br/>Confluence, Notion, GDocs]
    Q --> C[Code Comments<br/>& Docstrings]
    Q --> D[Senior Engineers' Heads<br/>Tribal Knowledge]
    Q --> E[Slack Threads<br/>Ephemeral & Unsearchable]

    style Agent fill:#f9f,stroke:#333
    style A fill:#fdd,stroke:#c33
    style B fill:#fdd,stroke:#c33
    style C fill:#fdd,stroke:#c33
    style D fill:#fdd,stroke:#c33
    style E fill:#fdd,stroke:#c33
```

Every agent builder solves the same context-assembly problem from scratch. Every catalog vendor reinvents the same data models. The knowledge itself is locked behind whichever surface created it.

---

## The LLM Wiki Pattern

A different approach has been emerging organically across teams. Instead of building another service, teams are giving their agents a **shared markdown library** that grows more useful over time.

Andrej Karpathy articulated this most clearly: LLMs don't get bored, don't forget to update cross-references, and can touch 15 files in one pass. The bookkeeping that causes humans to abandon personal wikis is exactly what LLMs are good at.

The pattern keeps reappearing under different names:

| Implementation | Pattern |
| :--- | :--- |
| Obsidian vaults wired to coding agents | Personal knowledge base → agent context |
| `AGENTS.md` / `CLAUDE.md` / `GEMINI.md` | Convention files for agent instructions |
| `index.md` + `log.md` repos | Agent-maintained wikis consulted before doing work |
| "Metadata as code" repositories | Data team context living in git |

The pattern works. But each instance is bespoke. Your team's wiki and another team's wiki look alike — markdown, frontmatter, cross-links — but they aren't designed to cooperate. There's no agreed answer to what fields every document should carry, or what filenames mean.

**What's missing is a format, not another service.**

---

## What is Open Knowledge Format (OKF)?

[OKF](https://github.com/GoogleCloudPlatform/knowledge-catalog/blob/main/okf/SPEC.md) formalizes the LLM-wiki pattern into a portable, interoperable specification. It is:

- **Just markdown** — readable in any editor, renderable on GitHub, indexable by any search tool
- **Just files** — shippable as a tarball, hostable in any git repo, mountable on any filesystem
- **Just YAML frontmatter** — for the small set of structured fields that need to be queryable

Three design principles:

1. **Minimally opinionated** — OKF requires exactly one field: `type`. Everything else is left to the producer.
2. **Producer/consumer independence** — A bundle authored by a human can be consumed by an agent. A bundle generated by an LLM can be browsed in a visualizer. The format is the contract.
3. **Format, not platform** — Not tied to any cloud, database, or model provider. No proprietary SDK required.

**What OKF is NOT:**
- Not a database or query engine — you can't `SELECT` from a bundle
- Not a replacement for domain-specific schemas (Avro, Protobuf, OpenAPI) — OKF references them, it doesn't subsume them
- Not a runtime or agent framework — it's a data format that any runtime can consume
- Not a fixed taxonomy — `type` values are freeform, not registered centrally

---

## OKF v0.2 Spec Walkthrough

### Bundle Structure

An OKF bundle is a directory tree of markdown files:

```text
sales/
├── index.md                    # Directory listing (progressive disclosure)
├── log.md                      # Chronological history of updates
├── datasets/
│   ├── index.md
│   └── orders_db.md
├── tables/
│   ├── index.md
│   ├── orders.md
│   └── customers.md
├── metrics/
│   ├── index.md
│   └── weekly_active_users.md
└── computations/
    ├── revenue.md
    └── profit.md
```

Reserved filenames:
- `index.md` — Directory listing for progressive disclosure (agents can browse before opening individual concepts)
- `log.md` — Chronological update history

Everything else is a **concept document**.

---

### Concept Documents

Every concept is one UTF-8 markdown file with two parts:

```yaml
---
type: BigQuery Table              # REQUIRED — the only mandatory field
title: Customer Orders
description: One row per completed customer order across all channels.
resource: https://console.cloud.google.com/bigquery?p=acme&d=sales&t=orders
tags: [sales, orders, revenue]
generated: { by: reference_agent/gemini-2.5-pro, at: 2026-05-28T14:30:00Z }
---

# Schema

| Column        | Type      | Description                              |
|---------------|-----------|------------------------------------------|
| `order_id`    | STRING    | Globally unique order identifier.        |
| `customer_id` | STRING    | FK to [customers](/tables/customers.md). |
| `total_usd`   | NUMERIC   | Order total in US dollars.               |
| `placed_at`   | TIMESTAMP | When the customer submitted the order.   |

# Joins

Joined with [customers](/tables/customers.md) on `customer_id`.
```

Key points:
- `type` is the **only required field** — a concept carrying just `type` is fully conformant
- Producers can add any additional frontmatter keys they need
- The body uses structural markdown (headings, tables, code blocks) for both human and agent readability
- Cross-links use standard markdown links, turning the directory into a navigable graph

---

### Provenance, Trust, and Lifecycle

OKF v0.2 makes three questions answerable from frontmatter alone:

| Question | Field Family | Example |
| :--- | :--- | :--- |
| Where did this come from? | `sources` | External docs, APIs, dashboards the concept derives from |
| How much should I trust it? | `generated` + `verified` | Who wrote it, who confirmed it, and when |
| Is it still current? | `status` + `stale_after` | Lifecycle state and expiration |

#### Sources (Provenance)

```yaml
sources:
  - id: ga4-schema
    resource: https://developers.google.com/analytics/bigquery/export-schema
    title: GA4 BigQuery Export schema
    author: team:ga4-docs
    usage_count: 5000
    last_modified: 2026-05-30T00:00:00Z
usage_window: { from: 2026-06-01T00:00:00Z, to: 2026-06-30T00:00:00Z }
```

Each source carries **credibility signals** — `author`, `usage_count`, `last_modified` — so consumers can judge trustworthiness without OKF having to store a subjective score.

#### Trust Tiers (derived from `verified`)

```yaml
generated: { by: reference_agent/gemini-2.5-pro, at: 2026-06-20T22:53:05Z }
verified:
  - { by: human:ahormati, at: 2026-06-25T09:00:00Z }
  - { by: process:finance-nightly, at: 2026-06-26T02:00:00Z }
```

Trust is derived, not stored:

| Condition | Trust Tier |
| :--- | :--- |
| No `verified` key | `unverified` |
| Verified by non-human actors only | `machine-confirmed` |
| Verified by a `human:<id>` actor | `human-reviewed` |

#### Lifecycle

```yaml
status: stable          # draft | stable | deprecated
stale_after: 2026-09-23T00:00:00Z
```

A concept is stale when `now >= stale_after`. Simple comparison, no relative TTLs.

---

### Cross-Linking

Concepts link to each other with standard markdown links:

```markdown
Joined with [customers](/tables/customers.md) on `customer_id`.
```

Two forms:
- **Absolute (bundle-relative):** begins with `/`, interpreted relative to bundle root
- **Relative:** standard relative path (`./other.md`, `../metrics/revenue.md`)

Links form the knowledge graph. Consumers can build graph views, trace lineage, and discover relationships — all from parsing plain markdown.

---

### Attested Computations

> **TL;DR:** If you only need to document services, tables, and runbooks — skip this section. Attested Computations are for data/analytics teams that need verified, auditable metric definitions.

This is the most powerful v0.2 addition. An **Attested Computation** concept carries not just what a value means, but a sanctioned way to compute it — so a consumer can confirm the agent ran the blessed computation, not improvised its own.

```yaml
---
type: Attested Computation
title: Revenue for fiscal year
description: Recognized revenue for a fiscal year, per Finance's definition.
runtime: bigquery
parameters:
  - { name: year, type: integer, required: true }
executor:
  resource: references/skills/run-on-bq.md
  receipt: [job_id, executed_sql, result]
attester:
  resource: references/attesters/revenue.py
generated: { by: reference_agent/gemini-2.5-pro, at: 2026-06-28T14:00:00Z }
verified: { by: human:ahormati, at: 2026-06-25T09:00:00Z }
---

# Computation

    SELECT SUM(amount) AS revenue
    FROM finance.recognized_revenue
    WHERE fiscal_year = @year
```

The lifecycle:

```mermaid
graph LR
    A[Agent discovers computation] --> B[Fills declared parameters]
    B --> C[Executor runs the query]
    C --> D[Returns receipt: job_id + SQL + result]
    D --> E[Attester checks receipt]
    E --> F{Verdict}
    F -->|Pass| G[Display result with evidence]
    F -->|Fail| H[Refuse to display / warn user]
```

This separates two concerns:
- **`verified`** confirms the *definition* still matches policy (doc-level, slow, stored in bundle)
- **Attestation** confirms a *single run* produced the value correctly (per-call, runtime, not stored)

---

## OKF vs Existing Knowledge Systems

<div style="overflow-x: auto;" markdown="1">

| Dimension | Traditional Catalogs | Internal Wikis | AGENTS.md / CLAUDE.md | **OKF** |
| :--- | :--- | :--- | :--- | :--- |
| **Format** | Proprietary API + DB | Vendor-specific (Confluence, Notion) | Single flat file | Markdown + YAML in git |
| **Portability** | Locked to vendor | Export is lossy | Copy-paste | `git clone` / tarball |
| **Agent-readable** | Requires SDK | Requires scraping | Yes (limited scope) | Yes (by design) |
| **Human-readable** | Dashboard UI only | Yes | Yes | Yes |
| **Versioned** | Vendor-managed | Limited history | Git | Git (recommended) |
| **Trust signals** | Vendor-specific | None | None | First-class (`verified`, trust tiers) |
| **Provenance** | Some catalogs | None | None | First-class (`sources`, credibility signals) |
| **Cross-org sharing** | Painful exports | Not designed for it | Not applicable | Core use case |
| **Required infrastructure** | Catalog server + API | SaaS subscription | Text editor | Text editor + git |

</div>

---

## Building Your First OKF Bundle

Here's a practical walkthrough for creating an OKF bundle for your team's infrastructure:

### Step 1: Create the directory structure

```bash
mkdir -p knowledge-bundle/{services,tables,metrics,playbooks,computations,references}
```

### Step 2: Write your first concept

Create `knowledge-bundle/services/auth-service.md`:

```yaml
---
type: Service
title: Authentication Service
description: Handles user login, JWT issuance, token validation, and session management.
resource: https://github.com/yourorg/auth-service
tags: [auth, security, core]
generated: { by: human:yourname, at: 2026-08-27T10:00:00Z }
status: stable
---

# Overview

The auth service is the gateway for all authenticated requests. It issues JWTs
with a 15-minute TTL and refresh tokens with a 7-day TTL.

# Dependencies

- [PostgreSQL users table](/tables/users.md) — credential storage
- [Redis session cache](/services/redis.md) — active session lookup
- Auth0 (external) — social login delegation

# Endpoints

| Path | Method | Purpose |
|------|--------|---------|
| `/auth/login` | POST | Issue JWT + refresh token |
| `/auth/refresh` | POST | Rotate refresh token |
| `/auth/validate` | GET | Validate JWT (internal only) |

# Ownership

Team: Platform Security (`#platform-security` on Slack)
On-call: PagerDuty rotation `auth-primary`
```

### Step 3: Add cross-links

Create `knowledge-bundle/tables/users.md`:

```yaml
---
type: PostgreSQL Table
title: Users
description: Core user credential and profile table.
resource: postgresql://prod-db:5432/main/public.users
tags: [auth, users, pii]
generated: { by: human:yourname, at: 2026-08-27T10:00:00Z }
status: stable
---

# Schema

| Column | Type | Description |
|--------|------|-------------|
| `id` | UUID | Primary key |
| `email` | TEXT | Unique, indexed |
| `password_hash` | TEXT | bcrypt, never exposed |
| `created_at` | TIMESTAMPTZ | Account creation |

# Consumers

- [Auth Service](/services/auth-service.md) — login and validation
- [User Profile API](/services/profile-api.md) — display name, avatar

# PII Notice

Contains PII (email, password_hash). Subject to GDPR deletion requests.
Retention: indefinite for active accounts, 90 days post-deletion.
```

### Step 4: Add an index for progressive disclosure

Create `knowledge-bundle/index.md`:

```markdown
# Knowledge Bundle: Acme Platform

## Services

* [Auth Service](/services/auth-service.md) - JWT auth, login, session management
* [Redis Cache](/services/redis.md) - Session and hot-path caching
* [Profile API](/services/profile-api.md) - User profile CRUD

## Tables

* [Users](/tables/users.md) - Core user credentials and profiles
* [Orders](/tables/orders.md) - Completed customer orders

## Metrics

* [Weekly Active Users](/metrics/wau.md) - Product engagement metric

## Playbooks

* [Auth outage runbook](/playbooks/auth-outage.md) - Steps for auth-service incidents
```

### Step 5: Version it

```bash
cd knowledge-bundle
git init
git add .
git commit -m "Initial OKF bundle: auth service, users table, index"
```

That's it. Your bundle is now portable, diffable, and agent-consumable.

---

## Consuming OKF: Agents, Viewers, and Search

### Agent Consumption

An AI agent consumes OKF by:
1. Reading `index.md` for progressive disclosure (what's available?)
2. Following links to specific concepts (what do I need?)
3. Checking `verified` and `stale_after` to gauge trust
4. Using `sources` to trace provenance when challenged

This maps directly to the **progressive context disclosure** pattern — the agent pays only for the knowledge it actually needs. (See [Part 1 of our token reduction series](/posts/reduce-ai-token-usage-part1-techniques/), §3 for more on this technique.)

### Google's Reference Implementations

Google ships three reference artifacts with OKF:

1. **Enrichment Agent** — Walks a BigQuery dataset, drafts an OKF concept per table/view, then enriches with citations, schemas, and join paths via a second LLM pass.

2. **Static HTML Visualizer** — Turns any OKF bundle into an interactive graph view in a single self-contained HTML file. No backend, no install, no data leaves the page.

3. **Sample Bundles** — GA4 e-commerce, Stack Overflow, and Bitcoin public datasets as living examples.

### Custom Consumers

Because OKF is just files, you can build consumers with any stack:
- **Search index:** Parse frontmatter with any YAML library, index bodies with Elasticsearch/Meilisearch
- **Agent context injection:** Load relevant concepts into system prompts based on `tags` or `type`
- **Graph visualization:** Parse markdown links to build a relationship graph
- **Staleness alerting:** Cron job that checks `stale_after` across all concepts

---

## OpenWiki: The Practical Bridge Between OKF and Coding Agents

While OKF defines the *format*, [OpenWiki](https://github.com/langchain-ai/openwiki) by LangChain is the tool that makes it real for daily coding workflows. OpenWiki is a CLI that automatically writes and maintains an agent-readable wiki for your codebase — and as of [v0.2](https://www.langchain.com/blog/openwiki-0-2-adds-okf-support), it emits **Google Open Knowledge Format bundles** natively.

### How OpenWiki Works

```mermaid
graph TD
    A[Your Codebase] --> B[OpenWiki CLI]
    B --> C[Reads source files, architecture, integrations]
    C --> D[Generates openwiki/ directory]
    D --> E[Linked Markdown wiki<br/>OKF-conformant]
    E --> F[Agent reads wiki as durable context]
    E --> G[Human browses interactive visualizer]
    
    H[Code changes] --> I[openwiki update]
    I --> D
```

### Installation & Configuration

Install OpenWiki globally via npm:

```bash
npm install -g openwiki
```

#### Configuring Gemini / Google API Key

OpenWiki natively supports Google Gemini models. You can configure your credentials via environment variables or a global config file:

**Option A: Shell Environment Variables (Recommended for CLI / CI)**
Set the provider and API key directly in your terminal session (get your key from [Google AI Studio](https://aistudio.google.com/)):

```bash
export OPENWIKI_PROVIDER="gemini"
export GEMINI_API_KEY="AIzaSy..."
# Also set GOOGLE_API_KEY as fallback
export GOOGLE_API_KEY="$GEMINI_API_KEY"
```

**Option B: Global Configuration File (`~/.openwiki/.env`)**
Save your preferences in `~/.openwiki/.env` so they persist across sessions:

```env
OPENWIKI_PROVIDER=gemini
GEMINI_API_KEY=AIzaSy...
GOOGLE_API_KEY=AIzaSy...

# Optional: Set specific Gemini model
OPENWIKI_MODEL=gemini-2.0-flash
```

*(For enterprise Google Cloud deployments, set `OPENWIKI_PROVIDER=gemini-enterprise` and supply `GOOGLE_CLOUD_PROJECT=your-project-id` with `gcloud auth application-default login`.)*

### Generating and Updating the Wiki

In your project root:

```bash
# Generate wiki documentation and OKF bundle:
openwiki code

# Output: openwiki/ directory with OKF-conformant markdown
# Update modified files and cross-links after code changes:
openwiki update
```

### Integrating with Google Antigravity & Coding Agents

Autonomous agents like **Google Antigravity**, **Claude Code**, and **Gemini CLI** consume the generated `openwiki/` bundle to understand architecture without spending thousands of tokens re-reading raw source trees.

#### 1. Add Steering Rule to `AGENTS.md` (or `.agents/rules/openwiki.md`)
Add this instruction block to guide Antigravity to use progressive disclosure:

```markdown
<!-- Add to AGENTS.md or .agents/rules/openwiki.md -->
## OpenWiki Architecture Index

This repository contains an auto-generated `openwiki/` knowledge index.

- For architecture questions, service dependencies, or table schemas, consult `openwiki/index.md` first.
- Navigate linked markdown pages within `openwiki/` rather than reading raw repository directories upfront.
- Treat source code and test files as authoritative.
```

#### 2. Automated Regeneration via GitHub Actions
Keep the OKF bundle synchronized automatically whenever PRs merge to `main`:

```yaml
# .github/workflows/openwiki.yml
name: Refresh OpenWiki Context

on:
  push:
    branches: [ main ]
  schedule:
    - cron: '0 0 * * 0' # Weekly refresh

jobs:
  openwiki:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
      - run: npm install -g openwiki
      - run: openwiki update
        env:
          OPENWIKI_PROVIDER: gemini
          GEMINI_API_KEY: ${{ secrets.GEMINI_API_KEY }}
      - uses: stefanzweifel/git-auto-commit-action@v5
        with:
          commit_message: "docs(openwiki): refresh agent knowledge graph"
```

### Why OpenWiki Matters for OKF Adoption

- **Auto-generates OKF bundles** from existing code — no manual authoring required
- **Keeps bundles current** — re-run `openwiki update` on code changes (or wire to CI)
- **Agent-first design** — coding agents (Antigravity, Claude Code, Codex, Gemini) consume the wiki as durable context, spending fewer tokens rediscovering architecture
- **Human-readable too** — ships an interactive visualizer for browsing the same wiki
- **Connects to external sources** — Gmail, Notion, Slack, git repos, web search via 9 built-in connectors ([docs](https://docs.langchain.com/oss/openwiki/overview))

### Related Tools for Agent-Readable Architecture

Several other tools address the same space — giving AI agents structured knowledge about codebases:

| Tool | Approach | Key Difference from OKF |
| :--- | :--- | :--- |
| **[OpenWiki](https://github.com/langchain-ai/openwiki)** | Auto-generated wiki from code, emits OKF bundles | The primary OKF producer for codebases |
| **[mex](https://github.com/mex-memory/mex)** | Repo-local, symbol-grounded wiki with drift detection | Knowledge stays connected to exact code symbols; flags when code changes invalidate facts |
| **[OpenViking](https://github.com/volcengine/OpenViking)** (ByteDance) | Context database with filesystem paradigm | Self-evolving layer that restructures context based on agent usage patterns |
| **[Graft](https://github.com/NanoNets/Graft)** | Linked plain-English explanations + symbol graph via MCP | Persistent prose context that agents query without re-reading files |
| **[DESIGN.md](https://github.com/google-labs-code/design.md)** (Google Labs) | Machine-readable design tokens (YAML) + design rationale (prose) | Specifically for visual identity systems |
| **[harness-experimental](https://github.com/ai-boost/awesome-harness-engineering)** | Structured AGENTS.md + HARNESS.md + FEATURE_INTAKE.md | Repository-level operating context for agents |

### Choosing the Right Tool

- **Want OKF-conformant output?** → Use **OpenWiki** (the only tool that explicitly produces OKF bundles)
- **Need symbol-level precision + staleness detection?** → Use **mex** (flags when code changes break knowledge)
- **Need self-improving context that adapts to usage?** → Use **OpenViking** (ByteDance's context database)
- **Already using MCP-based coding agents?** → Use **Graft** (serves context directly over MCP)
- **Building team-shared knowledge manually?** → Write OKF bundles by hand (the format is designed for this)

---

## Visualizing Knowledge with Archify

OKF handles knowledge *representation*; [Archify](https://github.com/tt-a1i/archify) handles *visualization*. It's an agent skill that turns system descriptions into interactive HTML diagrams.

```mermaid
graph LR
    OKF[OKF Bundle<br/>Knowledge as markdown] --> Agent[AI Agent<br/>Reads & reasons]
    Agent --> Archify[Archify<br/>Generates diagram]
    Archify --> HTML[Self-contained HTML<br/>Interactive, exportable]
```

```bash
# Install the skill:
npx skills add tt-a1i/archify -g

# Then ask your agent:
# "Read the openwiki/ docs, then use Archify to map the auth flow
#  from browser to database. Show 8 core components and trust boundaries."
```

The output is a single HTML file with dark/light themes, semantic search, route tracing, and PNG/SVG/WebM export — shareable by attaching to a PR or Slack message. Five diagram types: architecture, workflow, sequence, data flow, and lifecycle.

---

## Practical Integration Patterns

### Pattern 1: Agent-Maintained Knowledge (The LLM Wiki)

```mermaid
graph TD
    A[Developer makes code changes] --> B[Agent detects schema/API change]
    B --> C[Agent updates relevant OKF concepts]
    C --> D[PR with knowledge diff alongside code diff]
    D --> E[Human reviews knowledge changes]
    E --> F[Merge updates verified field]
```

The agent maintains the wiki. Humans curate and verify.

### Pattern 2: Data Catalog Export

```bash
# Export your BigQuery metadata to OKF
# (using Google's reference enrichment agent)
python enrichment_agent.py \
  --project=acme-prod \
  --dataset=sales \
  --output=./knowledge-bundle/tables/
```

Existing catalogs export into OKF; agents consume the portable format instead of calling proprietary APIs.

### Pattern 3: Incident Context Injection

When an on-call agent investigates an alert:
1. Match alert labels to OKF `tags`
2. Load matching service concepts + playbook concepts
3. Agent has immediate context: ownership, dependencies, runbooks, known failure modes

```python
# Pseudocode: load OKF context for an alert
alert_tags = ["auth", "security"]  # from PagerDuty/OpsGenie alert

relevant_concepts = [
    concept for concept in okf_bundle.all_concepts()
    if set(concept.tags) & set(alert_tags)
]
# Returns: auth-service.md, auth-outage-runbook.md, users-table.md
# Agent now has ownership, dependencies, and runbook in context
```

### Pattern 4: Onboarding Acceleration

New team members (or new agents on a project) start by reading the `index.md` tree. Progressive disclosure means they get the overview first, then drill into specifics as needed — matching the natural learning flow.

---

## Early Adoption

OKF is new (v0.2, June 2026) but already has concrete adoption:
- **Google Cloud Knowledge Catalog** — ingests OKF bundles and serves them to Google's own agents
- **OpenWiki** (LangChain, 11K+ GitHub stars) — produces OKF-conformant wikis from codebases
- **Google's reference enrichment agent** — generates OKF from BigQuery datasets
- The spec is designed for backward-compatible growth, so early bundles will remain valid as the spec evolves

---

## Limitations and What's Next

### Current Limitations

- **v0.2 is early** — The spec will evolve. Expect additive changes as more producers and consumers emerge.
- **No query language** — You can't "SELECT" from an OKF bundle. Consumers must build their own search/filter logic.
- **Manual maintenance burden** — Without agent automation, keeping concepts current requires discipline (same as any documentation).
- **No access control** — OKF is a format, not a platform. If concepts contain sensitive information, access control is your responsibility (git permissions, bundle splitting, etc.).
- **Attested Computations are complex** — The executor/attester pattern is powerful but requires tooling investment to realize.

### What's Coming

- **Ecosystem growth** — More producers (Snowflake, dbt, Postgres exporters) and consumers (VS Code extensions, agent frameworks)
- **Runtime protocol** — Receipt and verdict wire formats for attestation
- **Semantic-layer templates** — Support for Looker/dbt models where attester comparison shifts from SQL equality to model-and-binding equality
- **Community conventions** — Shared type taxonomies for common domains (data engineering, platform engineering, SRE)

---

## Frequently Asked Questions

**Do I need Google Cloud to use OKF?**
No. OKF is a format specification, not a Google product. It's vendor-neutral by design — any text editor, git repo, or filesystem works. Google Cloud's Knowledge Catalog can ingest OKF, but that's just one consumer among many.

**How is OKF different from just writing markdown docs?**
The `type` field and structural conventions (frontmatter schema, `index.md` for progressive disclosure, `log.md` for history, cross-linking rules) make OKF *interoperable*. Random markdown docs can't be consumed programmatically without custom parsing. OKF bundles can.

**Can AI agents write OKF bundles, or is it human-authored only?**
Both. OKF is designed for producer/consumer independence. OpenWiki auto-generates bundles from code. Google's enrichment agent generates them from BigQuery. Humans can write them manually. LLMs can maintain them. The format doesn't care who writes it.

**Does OKF replace AGENTS.md / CLAUDE.md?**
No — they're complementary. `AGENTS.md` gives the agent *behavioral instructions* (what to do, how to work). OKF gives the agent *knowledge* (what exists, how things connect, what's trustworthy). Your `AGENTS.md` should point the agent to the OKF bundle for context.

**How do I keep OKF bundles from going stale?**
Three approaches: (1) Wire OpenWiki to CI so it regenerates on code changes. (2) Use `stale_after` fields and monitor them with a cron job. (3) Let agents maintain the wiki (the LLM Wiki pattern) with human review via PRs.

**Is there a maximum bundle size?**
No hard limit in the spec. Practically, very large bundles (1000+ concepts) benefit from `index.md` at every directory level for progressive disclosure — agents browse the index rather than scanning all files.

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "Do I need Google Cloud to use OKF?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "No. OKF is a format specification, not a Google product. It is vendor-neutral by design — any text editor, git repository, or filesystem works."
      }
    },
    {
      "@type": "Question",
      "name": "How is OKF different from just writing markdown docs?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "The type field and structural conventions (frontmatter schema, index.md for progressive disclosure, log.md for history, cross-linking rules) make OKF interoperable and programmatically consumable."
      }
    },
    {
      "@type": "Question",
      "name": "Can AI agents write OKF bundles, or is it human-authored only?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Both. OKF is designed for producer/consumer independence. OpenWiki auto-generates bundles from code, Google's enrichment agent generates them from BigQuery, and humans can write them manually."
      }
    },
    {
      "@type": "Question",
      "name": "Does OKF replace AGENTS.md / CLAUDE.md?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "No — they are complementary. AGENTS.md provides behavioral instructions, while OKF provides structured domain knowledge."
      }
    },
    {
      "@type": "Question",
      "name": "How do I keep OKF bundles from going stale?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Wire OpenWiki to CI to regenerate on code changes, monitor stale_after fields with cron jobs, or let agents maintain the wiki with human review via PRs."
      }
    },
    {
      "@type": "Question",
      "name": "Is there a maximum bundle size?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "There is no hard limit in the spec. Large bundles benefit from index.md at every directory level for progressive disclosure."
      }
    }
  ]
}
</script>

---

## Getting Started

| Time Available | Action |
| :--- | :--- |
| **5 minutes** | [Read the spec](https://github.com/GoogleCloudPlatform/knowledge-catalog/blob/main/okf/SPEC.md) — it's surprisingly short |
| **30 minutes** | Create a 3-concept bundle for one service your team owns |
| **2 hours** | Build a full bundle for your team's domain, add an `index.md`, commit to git |
| **1 day** | Wire your agent (Claude Code / Gemini CLI) to read the bundle as context before answering questions about your system |

The repo, spec, and sample bundles are available at [github.com/GoogleCloudPlatform/knowledge-catalog](https://github.com/GoogleCloudPlatform/knowledge-catalog).

---

## Further Reading

- [OKF v0.2 Specification](https://github.com/GoogleCloudPlatform/knowledge-catalog/blob/main/okf/SPEC.md) — The full spec
- [How the Open Knowledge Format can improve data sharing](https://cloud.google.com/blog/products/data-analytics/how-the-open-knowledge-format-can-improve-data-sharing) — Google Cloud blog announcement
- [Archify](https://github.com/tt-a1i/archify) — Agent skill for interactive architecture diagrams
- [Andrej Karpathy's LLM Wiki gist](https://gist.github.com/karpathy/1dd0294ef9567971c1e4348a90d69285) — The original LLM Wiki pattern articulation
- [Open Knowledge Format explainer (Medium)](https://medium.com/@tahirbalarabe2/what-is-open-knowledge-format-okf-270b20791802) — Community walkthrough
- [OpenWiki](https://github.com/langchain-ai/openwiki) — LangChain's CLI that auto-generates and maintains OKF-conformant wikis from codebases
- [OpenWiki 0.2 adds OKF support](https://www.langchain.com/blog/openwiki-0-2-adds-okf-support) — LangChain's announcement of native OKF bundle output
- [Graft](https://github.com/NanoNets/Graft) — Plain-English codebase graph served via MCP
- [mex](https://github.com/mex-memory/mex) — Symbol-grounded repo wiki with drift detection
- [Awesome Harness Engineering](https://github.com/ai-boost/awesome-harness-engineering) — Comprehensive list of agent harness tools, patterns, and research
