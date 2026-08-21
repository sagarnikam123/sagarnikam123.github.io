---
title: "Open-Source Observability Platforms Compared: 12 Tools, 25 Criteria (Part 1)"
description: "A practical comparison of 12 self-hosted open-source observability platforms that unify logs, metrics, and traces. Evaluates SigNoz, OpenObserve, ClickStack, OneUptime, Uptrace, Coroot, Grafana LGTM, Apache SkyWalking, OpenSearch Observability, VictoriaMetrics stack, Highlight.io, and Elastic Observability across architecture, features, licensing, and operational complexity."
author: sagarnikam123
date: 2026-08-20 12:00:00 +0530
categories: [Observability, DevOps]
tags: [observability, open-source, signoz, openobserve, clickstack, oneuptime, uptrace, coroot, grafana, skywalking, opensearch, victoriametrics, highlight-io, elastic-stack, opentelemetry, logs, metrics, traces, comparison]
mermaid: true
image:
  path: assets/img/posts/20260820/open-source-observability-comparison.webp
  alt: Open Source Observability Platform Comparison - 12 Tools Evaluated
---

> **A checkmark indicates that a feature exists. It does not indicate that the feature is good.**

Choosing a self-hosted observability platform that handles logs, metrics, and traces together — without vendor lock-in — requires more than counting feature checkboxes. This is Part 1 of a two-part comparison: here we document capabilities, classify architectures, and help you shortlist 2-3 candidates. [Part 2](/posts/open-source-observability-benchmark/) benchmarks the shortlisted platforms on identical hardware with identical workloads.

The questions that matter:

- Can I send standard OTLP without vendor-specific transformations?
- Can I correlate a metric spike → trace → log in few clicks?
- Can one engineer operate this stack?
- Can I do all of that using only the free self-hosted edition?

---

## Table of Contents

- [Approach](#approach)
- [The 12 Candidates](#the-12-candidates)
- [Architecture Classification](#architecture-classification)
- [Legend](#legend)
- [Core Telemetry Matrix](#core-telemetry-matrix)
- [Architecture & Deployment Matrix](#architecture--deployment-matrix)
- [Operator/SRE Capability Matrix](#operatorsre-capability-matrix)
- [Developer / Query Experience Matrix](#developer--query-experience-matrix)
- [Licensing / "Actually Free" Matrix](#licensing--actually-free-matrix)
- [The 25 Scored Criteria](#the-25-scored-criteria)
- [When to Use What](#when-to-use-what)
- [Honorable Mentions](#honorable-mentions)
- [Next: Part 2 — Benchmarks](#next-part-2--benchmarks)
- [References](#references)

---

## Approach

We evaluate platforms that provide **all three observability signals** — logs, metrics, and traces — in a single self-hostable deployment. No SaaS-only tools. No tools that only handle one signal.

| Selection Criterion | Requirement |
| :--- | :--- |
| **Signals** | Must support logs + metrics + traces natively |
| **License** | Open-source or source-available, free to self-host |
| **Self-hosted** | Can run entirely on your infra, no cloud dependency |
| **Active** | Actively maintained, commits in last 3 months |
| **OTel support** | Accepts OpenTelemetry data (OTLP) |

**Excluded:** Datadog, New Relic, Splunk (commercial SaaS), Jaeger (traces only), Prometheus (metrics only).

---

## The 12 Candidates

| Platform | Language | Storage Backend | License | GitHub |
| :--- | :--- | :--- | :--- | :--- |
| **[SigNoz](https://github.com/SigNoz/signoz)** | Go, TypeScript | ClickHouse | MIT (Enterprise: paid) | ~20k stars |
| **[OpenObserve](https://github.com/openobserve/openobserve)** | Rust | Object storage (S3/MinIO/disk) | AGPL v3 | ~14k stars |
| **[ClickStack](https://github.com/ClickHouse/ClickStack)** | TypeScript, Go | ClickHouse | Apache 2.0 + MIT (HyperDX) | ~22k stars |
| **[OneUptime](https://github.com/OneUptime/oneuptime)** | TypeScript | PostgreSQL + ClickHouse | Apache 2.0 | ~5k stars |
| **[Uptrace](https://github.com/uptrace/uptrace)** | Go | ClickHouse | AGPL v3 (BSL enterprise) | ~4k stars |
| **[Coroot](https://github.com/coroot/coroot)** | Go | Prometheus + ClickHouse | Apache 2.0 | ~4k stars |
| **[Grafana LGTM](https://github.com/grafana)** | Go | Loki / Mimir / Tempo (object storage) | AGPL v3 | ~75k stars |
| **[Apache SkyWalking](https://github.com/apache/skywalking)** | Java | BanyanDB / Elasticsearch | Apache 2.0 | ~24k stars |
| **[OpenSearch Observability](https://github.com/opensearch-project/OpenSearch)** | Java | OpenSearch + Data Prepper | Apache 2.0 | ~10k stars |
| **[VictoriaMetrics stack](https://github.com/VictoriaMetrics/VictoriaMetrics)** | Go | VM / VL / VT (specialized DBs) | Apache 2.0 | ~13k stars |
| **[Highlight.io](https://github.com/highlight/highlight)** | Go, TypeScript | ClickHouse + PostgreSQL | Apache 2.0 | ~15k stars |
| **[Elastic Observability](https://github.com/elastic/elasticsearch)** | Java, TypeScript | Elasticsearch | AGPL v3 / Apache 2.0 | ~70k stars |

> Star counts approximate as of mid-2026. Always check GitHub for current numbers.

---

## Architecture Classification

Understanding architecture philosophy is more important than feature lists. A composable stack with 5+ services to operate is fundamentally different from a single-binary platform, even if both tick the same feature boxes.

```mermaid
graph TB
    subgraph "All-in-One Platforms"
        direction LR
        SN[SigNoz<br/>ClickHouse unified]
        OO[OpenObserve<br/>Rust + object storage]
        CS[ClickStack<br/>ClickHouse + HyperDX]
        OU[OneUptime<br/>Full reliability platform]
        UP[Uptrace<br/>Go + ClickHouse]
        HL[Highlight.io<br/>ClickHouse + full-stack]
    end

    subgraph "Composable / Multi-Backend Stacks"
        direction LR
        GF[Grafana LGTM<br/>Loki + Mimir + Tempo]
        VM[VictoriaMetrics<br/>VM + VL + VT]
    end

    subgraph "Specialized / Search Architecture"
        direction LR
        CO[Coroot<br/>eBPF + Prometheus + CH]
        SW[SkyWalking<br/>APM-first, pluggable storage]
        OS[OpenSearch<br/>Search-engine-centric]
        EL[Elastic Stack<br/>ES|QL + Lucene unified]
    end
```

| Classification | Platforms | Trade-off |
| :--- | :--- | :--- |
| **All-in-one** | SigNoz, OpenObserve, ClickStack, OneUptime, Uptrace, Highlight.io | Unified UX, single team to operate; less flexibility per signal |
| **Composable** | Grafana LGTM, VictoriaMetrics stack | Best-of-breed per signal; higher operational complexity |
| **eBPF-centric** | Coroot | Auto-discovery, zero-code; different ingestion model |
| **APM-first** | SkyWalking | Deep service topology; Java ecosystem heritage |
| **Search-centric** | OpenSearch, Elastic Observability | Full-text search strength; analytics heritage |

---

## Legend

| Symbol | Meaning |
| :---: | :--- |
| ✅ | Clearly supported / documented |
| ◐ | Supported through another component / integration / more setup |
| ⭐ | Particular strength worth testing |
| 🧪 | Must benchmark — don't trust documentation alone |
| — | Not a major focus / not confirmed |
| EE | Enterprise/paid edition boundary — verify before committing |

---

## Core Telemetry Matrix

| Criterion | SigNoz | OpenObserve | ClickStack | OneUptime | Uptrace | Coroot | Grafana LGTM | SkyWalking | OpenSearch | VictoriaMetrics | Highlight.io | Elastic Observability |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **Logs** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ Loki | ✅ | ✅ | ✅ VictoriaLogs | ✅ | ✅ |
| **Metrics** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ Prometheus | ✅ Mimir/Prom | ✅ | ✅ | ✅ VictoriaMetrics | ✅ | ✅ TSDB/OTel |
| **Traces** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ Tempo | ✅ | ✅ | ✅ VictoriaTraces | ✅ | ✅ APM |
| **Native OTLP ingestion** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ logs/traces | ✅ via Alloy | ✅ | ✅ via Data Prepper | ✅ | ✅ | ✅ |
| **OTLP HTTP** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **OTLP gRPC** | ✅ | ✅ | ✅ | ✅ | ✅ | 🧪 | ✅ | ✅ | ✅ | 🧪 | ✅ | ✅ |
| **Prometheus compat** | ✅ | ✅ | ◐ | ◐ | ✅ | ⭐ | ⭐ | ✅ | ✅ | ⭐ | ✅ | ✅ |
| **Trace ↔ logs correlation** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Metrics ↔ traces** | ✅ | ✅ | ✅ | 🧪 | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Metrics ↔ logs** | ✅ | ✅ | ✅ | 🧪 | 🧪 | ✅ | ✅ | ◐ | ✅ | ✅ | ✅ | ✅ |
| **Single-query cross-signal** | ⭐ | ⭐ | ⭐ | ⭐ | ⭐ | ⭐ | ◐ | ◐ | ◐ | ◐ | ⭐ | ⭐ ES\|QL |

**Key insight:** All-in-one platforms (SigNoz, OpenObserve, ClickStack, Highlight.io) naturally provide tighter cross-signal correlation because all data lives in one backend. Composable stacks (Grafana, VictoriaMetrics) require explicit linking between separate databases.

Sources: [SigNoz docs](https://signoz.io/docs/), [OpenObserve docs](https://openobserve.ai/docs/), [Uptrace OTel](https://uptrace.dev/ingest/opentelemetry), [OpenSearch observability](https://docs.opensearch.org/latest/observing-your-data/), [SkyWalking concepts](https://skywalking.apache.org/docs/), [VictoriaMetrics OTel](https://docs.victoriametrics.com/opentelemetry/readme/), [Highlight.io docs](https://www.highlight.io/docs), [Elastic Observability docs](https://www.elastic.co/docs/current/observability)

---

## Architecture & Deployment Matrix

> This table may be **more valuable than the feature table** — it explains what you actually have to operate.

| Criterion | SigNoz | OpenObserve | ClickStack | OneUptime | Uptrace | Coroot | Grafana LGTM | SkyWalking | OpenSearch | VictoriaMetrics | Highlight.io | Elastic Observability |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **Free self-host** | ✅ | ✅ | ✅ | ✅ | ✅ Community | ✅ Community | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Primary storage** | ClickHouse | Own engine + obj storage | ClickHouse | PG + ClickHouse | ClickHouse | Prom + CH | Loki/Mimir/Tempo | Pluggable | OpenSearch | VM/VL/VT | ClickHouse + PG | Elasticsearch |
| **Backend systems count** | Low (2-3) | Low (1) | Low (2-3) | Medium (4+) | Medium (2-3) | Medium (3+) | **High (5+)** | Medium (2-3) | Medium (2-3) | **3 specialized DBs** | Medium (3-4) | Medium (2-3) |
| **Single binary option** | ◐ | ⭐ | ◐ | — | ✅ (+ CH) | ◐ | — | ◐ | — | ✅ per backend | — | — |
| **Docker Compose** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Kubernetes/Helm** | ✅ | ✅ | ✅ | ✅ | ✅ | ⭐ | ⭐ | ✅ | ✅ | ⭐ | ✅ | ⭐ |
| **K8s Operator** | — | — | — | — | — | — | ✅ (Loki, Mimir) | ✅ (SWCK) | ✅ | ✅ (operator) | — | ✅ (ECK) |
| **HA deployment** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ⭐ | ✅ | ⭐ | ⭐ | ✅ | ⭐ |
| **Object storage native** | ◐ CH tiered | ⭐ | ◐ CH tiered | ◐ CH | ◐ CH | Depends | ⭐ | Depends | ⭐ | ⭐ | ◐ CH tiered | ⭐ Frozen tier |
| **Horizontal scaling** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ⭐ | ✅ | ⭐ | ⭐ | ✅ | ⭐ |
| **Operational complexity** | 🧪 Medium | 🧪 Low | 🧪 Medium | 🧪 High | 🧪 Medium | 🧪 Medium | 🧪 High | 🧪 Medium | 🧪 Medium | 🧪 Medium-High | 🧪 Medium | 🧪 Medium-High |
| **Upgrade complexity** | 🧪 | 🧪 | 🧪 | 🧪 | 🧪 | 🧪 | 🧪 | 🧪 | 🧪 | 🧪 | 🧪 | 🧪 |

Sources: [OneUptime architecture](https://oneuptime.com/docs/en/self-hosted/architecture), [Uptrace self-hosting](https://uptrace.dev/get/hosted), [Coroot architecture](https://docs.coroot.com/installation/architecture/), [VictoriaMetrics OTel](https://docs.victoriametrics.com/opentelemetry/readme/)

---

## Operator/SRE Capability Matrix

| Criterion | SigNoz | OpenObserve | ClickStack | OneUptime | Uptrace | Coroot | Grafana LGTM | SkyWalking | OpenSearch | VictoriaMetrics | Highlight.io | Elastic Observability |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **K8s monitoring** | ✅ | ✅ | ✅/OTel | ✅ | ✅/OTel | ⭐ | ⭐ | ✅ | ✅ | ✅ | ✅ | ⭐ |
| **Host monitoring** | ✅ | ✅ | ✅/OTel | ✅ | ✅ | ⭐ | ⭐ | ✅ | ✅ | ⭐ | ✅ | ⭐ |
| **Service map** | ✅ | ✅ | ✅ | ✅ | ✅ | ⭐ | ✅ | ⭐ | ✅ | ◐ Grafana | ✅ | ⭐ |
| **APM views** | ⭐ | ✅ | ✅ | ✅ | ⭐ | ⭐ | ✅ | ⭐ | ✅ | ◐ | ⭐ | ⭐ |
| **RED metrics** | ✅ | ✅ | ✅ | ✅ | ✅ | ⭐ | ✅ | ⭐ | ✅ | ◐ | ✅ | ✅ |
| **eBPF auto-instrumentation** | ◐ | ✅ OBI | ◐ | — | ◐ | ⭐ native | ◐ Beyla | ◐ | ◐ | ◐ | ◐ | ◐ Profiling |
| **Continuous profiling** | EE | EE | — | ✅ | — | ⭐ | ✅ Pyroscope | ✅ | — | ◐ | — | ⭐ Universal Prof |
| **Alerting** | ✅ | ✅ | ✅ | ⭐ | ✅ | ✅ | ⭐ | ✅ | ⭐ | ✅ vmalert | ✅ | ⭐ |
| **SLO management** | EE | 🧪 | 🧪 | ⭐ | 🧪 | ⭐ | ✅ | 🧪 | 🧪 | ✅ | 🧪 | ⭐ |
| **Incident management** | — | — | — | ⭐ | — | — | ◐ IRM | — | — | — | — | ◐ |
| **On-call scheduling** | — | — | — | ⭐ | — | — | ◐ OnCall | — | — | — | — | — |
| **Status pages** | — | — | — | ⭐ | — | — | — | — | — | — | — | — |
| **Session replay / RUM** | — | ✅ | ✅ | — | — | — | ◐ Faro | — | — | — | ⭐ native | ◐ RUM |

**Key insight:** OneUptime is uniquely positioned as a full reliability platform (monitoring + incident + status pages + on-call). Coroot is uniquely positioned for eBPF-first, zero-code observability. Highlight.io bridges developer-focused session replay and error monitoring with backend OTel telemetry.

Sources: [OneUptime profiling](https://oneuptime.com/docs/en/telemetry/profiles), [Coroot eBPF](https://docs.coroot.com/installation/performance-impact/), [OpenObserve OBI](https://openobserve.ai/docs/ingestion/traces/obi/), [Highlight session replay](https://www.highlight.io/docs/general/product-features/session-replay/overview)

---

## Developer / Query Experience Matrix

| Criterion | SigNoz | OpenObserve | ClickStack | OneUptime | Uptrace | Coroot | Grafana LGTM | SkyWalking | OpenSearch | VictoriaMetrics | Highlight.io | Elastic Observability |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Log query** | Builder | SQL | CH SQL / Lucene | UI | UI | UI | LogQL | LAL / UI | PPL | LogsQL | UI / SQL | ES\|QL / KQL |
| **Metrics language** | Builder / PromQL | PromQL / SQL | SQL / UI | UI | PromQL / UI | PromQL | PromQL | MAL / Prom | PromQL / PPL | MetricsQL | PromQL / UI | ES\|QL / PromQL |
| **Trace query** | UI / API | UI / SQL | SQL / UI | UI | UI | UI | TraceQL | Native UI | PPL / UI | LogsQL / Jaeger | UI / Waterfall | ES\|QL / UI |
| **SQL access** | ◐ | ⭐ | ⭐ | ◐ | ◐ | — | — | — | ✅ SQL/PPL | — | ⭐ CH SQL | ⭐ ES\|QL / SQL |
| **Full-text search** | ✅ | ⭐ | ⭐ | ✅ | ✅ | ✅ | ✅ | ✅ | ⭐ | ⭐ | ⭐ | ⭐ |
| **Built-in dashboards** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ⭐ | ✅ | ✅ | ◐ Grafana | ✅ | ⭐ |
| **Grafana plugin** | — | ✅ | — | — | — | — | N/A | ✅ | ✅ | ⭐ | — | ✅ |
| **High-cardinality** | 🧪 | 🧪 | 🧪 | 🧪 | 🧪 | 🧪 | 🧪 | 🧪 | 🧪 | 🧪 | 🧪 | 🧪 |
| **Query UX** | 🧪 | 🧪 | 🧪 | 🧪 | 🧪 | 🧪 | 🧪 | 🧪 | 🧪 | 🧪 | 🧪 | 🧪 |

**Key insight:** Query-language fragmentation is itself a decision criterion. If your team already knows PromQL, platforms that speak it natively (Grafana, VictoriaMetrics, Coroot) have lower adoption friction. If you prefer SQL, OpenObserve, ClickStack, and Highlight.io give you that directly, while Elastic gives you ES|QL.

Sources: [OpenSearch PPL](https://docs.opensearch.org/latest/observing-your-data/exploring-observability-data/discover-logs/), [VictoriaLogs querying](https://docs.victoriametrics.com/victorialogs/querying/), [Tempo TraceQL](https://grafana.com/docs/tempo/latest/), [Elastic ES|QL](https://www.elastic.co/guide/en/elasticsearch/reference/current/esql.html)

---

## Licensing / "Actually Free" Matrix

> Don't score "open source = 10" because a GitHub repo exists. Score: **How much observability functionality can I operate without purchasing a license?**

| Platform | License | Free self-host | Issue to verify |
| :--- | :--- | :---: | :--- |
| **SigNoz** | MIT (core) | ✅ | Which SSO/RBAC/collaboration features require Enterprise |
| **OpenObserve** | AGPL v3 | ✅ | AGPL suitability for your org; OSS vs Enterprise feature gap |
| **ClickStack** | Apache 2.0 + MIT | ✅ | Managed-only extras on ClickHouse Cloud |
| **OneUptime** | Apache 2.0 | ✅ | Verify no cloud-only operational capability |
| **Uptrace** | AGPL v3 (Community) | ✅ | Community vs paid on-prem feature boundaries |
| **Coroot** | Apache 2.0 | ✅ | Community vs Enterprise functions (profiling, etc.) |
| **Grafana LGTM** | AGPL v3 (each component) | ✅ | Enterprise feature boundaries per component |
| **SkyWalking** | Apache 2.0 | ✅ | Straightforward — full ASF project |
| **OpenSearch** | Apache 2.0 | ✅ | Plugin/managed-service feature differences |
| **VictoriaMetrics stack** | Apache 2.0 | ✅ | Enterprise/cloud features (downsampling, etc.) |
| **Highlight.io** | Apache 2.0 | ✅ | Cloud-managed features vs self-hosted Docker core |
| **Elastic Observability** | AGPL v3 / Apache 2.0 | ✅ | Platinum/Enterprise features (ML, advanced security) vs Free basic |

Sources: [OpenObserve FAQ](https://openobserve.ai/faqs/), [ClickStack](https://clickhouse.com/clickstack), [OneUptime](https://oneuptime.com/), [Uptrace pricing](https://uptrace.dev/pricing)

---

## The 25 Scored Criteria

These criteria form the evaluation framework for both Part 1 (documentation-based) and [Part 2](/posts/open-source-observability-benchmark/) (benchmark-based).

| # | Criterion | Weight | Source |
| ---: | :--- | ---: | :--- |
| 1 | Free self-hosted completeness | **7%** | Licensing matrix |
| 2 | OSS/license friendliness | 4% | Licensing matrix |
| 3 | Logs capability | **5%** | Core matrix + benchmark |
| 4 | Metrics capability | **5%** | Core matrix + benchmark |
| 5 | Distributed tracing | **5%** | Core matrix + benchmark |
| 6 | Native OpenTelemetry support | **5%** | Core matrix |
| 7 | Prometheus compatibility | 3% | Core matrix |
| 8 | Signal correlation | 4% | Benchmark (Part 2) |
| 9 | APM experience | 4% | Operator matrix |
| 10 | Kubernetes monitoring | 4% | Operator matrix |
| 11 | Infrastructure monitoring | 3% | Operator matrix |
| 12 | eBPF/zero-code observability | 3% | Operator matrix |
| 13 | Profiling | 2% | Operator matrix |
| 14 | Dashboards/exploration UX | 4% | Query matrix + benchmark |
| 15 | Alerting/SLO | 4% | Operator matrix |
| 16 | Query language/UX | 4% | Query matrix + benchmark |
| 17 | Installation complexity | 3% | Benchmark (Part 2: TTFT) |
| 18 | Operational complexity | 4% | Benchmark (Part 2) |
| 19 | Ingestion throughput | **5%** | Benchmark (Part 2) |
| 20 | Query performance | **5%** | Benchmark (Part 2) |
| 21 | Storage efficiency | **5%** | Benchmark (Part 2) |
| 22 | CPU efficiency | 3% | Benchmark (Part 2) |
| 23 | Memory efficiency | 3% | Benchmark (Part 2) |
| 24 | High-cardinality behavior | 3% | Benchmark (Part 2) |
| 25 | HA/scalability | 3% | Architecture matrix |
| | **Total** | **100%** | |

> RUM, session replay, on-call, status pages scored as **bonus features** — otherwise platforms solving a wider problem get rewarded for scope rather than observability quality.

---

## When to Use What

| If you need... | Best fit | Runner-up |
| :--- | :--- | :--- |
| **Fastest time to value, single binary** | OpenObserve | Uptrace |
| **ClickHouse SQL power + full observability** | SigNoz | ClickStack |
| **Maximum flexibility, mature ecosystem** | Grafana LGTM | VictoriaMetrics stack |
| **APM-first with deep Java/K8s tracing** | Apache SkyWalking | SigNoz |
| **All-in-one reliability platform (monitoring + incidents + on-call)** | OneUptime | Grafana (with OnCall/IRM) |
| **Minimal resource footprint** | OpenObserve | Uptrace |
| **Existing ClickHouse investment** | ClickStack | SigNoz |
| **Object-storage-first, cost-optimized at scale** | OpenObserve | Grafana LGTM |
| **Session replay + frontend error monitoring** | Highlight.io | ClickStack |
| **OpenTelemetry-native from day one** | SigNoz | Uptrace |
| **Zero-code/eBPF auto-discovery** | Coroot | Grafana (Beyla) |
| **Existing Prometheus/Grafana investment** | VictoriaMetrics stack | Grafana LGTM |
| **Full-text search, analytics & ES|QL** | Elastic Observability | OpenSearch |
| **Kubernetes-native with auto-topology** | Coroot | Grafana LGTM |

---

## Honorable Mentions

### Sentry (Self-Hosted)

[Sentry](https://github.com/getsentry/sentry) — Developer-first error tracking with strong distributed tracing, performance monitoring, session replay, and custom metrics (backed by Snuba/ClickHouse and Kafka). While historically error-centric, self-hosted Sentry has expanded to cover traces, metrics, and logs/breadcrumbs under the FSL/BSL license.

### GreptimeDB

[GreptimeDB](https://github.com/GreptimeTeam/greptimedb) — A single unified observability database handling metrics, logs, and traces with SQL and PromQL support. Architecturally interesting (one engine vs many), but the complete observability experience (dashboards, alerting, APM views) requires additional tooling on top. Worth watching as a backend building block.

### HyperDX

[HyperDX](https://github.com/hyperdxio/hyperdx) — The UI/platform layer that powers ClickStack. After ClickHouse's acquisition, HyperDX and ClickStack share the same ecosystem. We evaluate ClickStack as the complete stack rather than double-counting the same platform.

### Parseable

[Parseable](https://github.com/parseablehq/parseable) — Rust-based, object-storage-first log engine expanding toward full observability. Strong for log-heavy workloads but metrics and traces support is still maturing. Not yet a full three-signal platform.

### Quickwit

[Quickwit](https://github.com/quickwit-oss/quickwit) — Rust search engine optimized for logs and traces on object storage. Excellent search performance but requires Grafana for dashboards and external alerting. A storage/search backend, not a complete observability platform.

---

## Next: Part 2 — Benchmarks

Feature tables tell you what exists. They don't tell you what works well.

In [Part 2: Benchmarking Open-Source Observability](/posts/open-source-observability-benchmark/), we deploy each platform on identical hardware (8 vCPU, 32 GB RAM, 500 GB NVMe) and run 15 standardized benchmarks:

- **Idle footprint** — what does it cost to run with zero traffic?
- **Ingestion throughput** — logs, traces, and metrics under increasing load
- **Storage efficiency** — same data in, how much disk consumed?
- **Query latency** — p50/p95/p99 for real-world query patterns
- **Signal correlation** — clicks to root-cause from each signal
- **Failure recovery** — what happens when the backend dies?
- **TTFT (Time To First Telemetry)** — how fast can a new engineer get value?

All using the [OpenTelemetry Astronomy Shop](https://github.com/open-telemetry/opentelemetry-demo) as the baseline workload, supplemented with custom high-cardinality generators.

**Phase 1 benchmark candidates:** SigNoz, OpenObserve, ClickStack, Grafana LGTM, VictoriaMetrics stack, Uptrace — covering the clearest architectural comparison.

**Phase 2:** Coroot (eBPF model differs), OneUptime (reliability platform evaluation), Highlight.io, Elastic Observability, SkyWalking, OpenSearch.

---

## References

- [SigNoz Documentation](https://signoz.io/docs/)
- [OpenObserve Documentation](https://openobserve.ai/docs/)
- [ClickStack Documentation](https://clickhouse.com/docs/use-cases/observability/clickstack)
- [OneUptime Documentation](https://oneuptime.com/docs)
- [Uptrace Documentation](https://uptrace.dev/get/overview.html)
- [Coroot Documentation](https://docs.coroot.com/)
- [Grafana LGTM Stack](https://grafana.com/oss/)
- [Apache SkyWalking Documentation](https://skywalking.apache.org/docs/)
- [OpenSearch Observability](https://docs.opensearch.org/latest/observing-your-data/)
- [VictoriaMetrics Documentation](https://docs.victoriametrics.com/)
- [VictoriaLogs](https://docs.victoriametrics.com/victorialogs/)
- [VictoriaTraces](https://docs.victoriametrics.com/victoriatraces/)
- [Highlight.io Documentation](https://www.highlight.io/docs)
- [Elastic Observability Documentation](https://www.elastic.co/docs/current/observability)
- [OpenTelemetry](https://opentelemetry.io/)

---

*Last verified: August 2026. Star counts, features, and licensing can change — always check official sources.*
