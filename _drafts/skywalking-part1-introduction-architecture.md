---
title: "Apache SkyWalking Part 1: Complete Guide to Modern Observability"
description: "Deep dive into Apache SkyWalking architecture, storage options, visualization tools, and how it compares to other observability platforms"
date: 2026-02-02
categories: [Observability, APM]
tags: [skywalking, observability, distributed-tracing, metrics, banyandb, grafana]
image:
  path: /assets/img/posts/skywalking-architecture.png
  alt: Apache SkyWalking Architecture
---

## Introduction

Apache SkyWalking is an open-source Application Performance Monitoring (APM) and observability platform designed for distributed systems, microservices, cloud-native, and container-based architectures. Originally created at Huawei in 2015 and donated to the Apache Software Foundation in 2017, it has evolved into one of the most comprehensive observability solutions available.

### What Makes SkyWalking Different?

Unlike traditional APM tools that focus solely on tracing, SkyWalking provides a unified platform for:
- **Distributed Tracing** - End-to-end request tracking across services
- **Metrics Aggregation** - Service, instance, and endpoint-level metrics
- **Logging Integration** - Correlated logs with traces
- **Profiling** - CPU and memory profiling without code changes
- **Alerting** - Configurable alerts based on metrics and traces

### Who Should Use SkyWalking?

- Platform engineers managing Kubernetes clusters
- DevOps teams implementing observability strategies
- Developers debugging distributed applications
- SREs monitoring production systems

---

## When to Use SkyWalking

### Decision Guide

| Scenario                                        | SkyWalking? | Why                                                        |
| ----------------------------------------------- | ----------- | ---------------------------------------------------------- |
| **Microservices with multiple languages**       | ✅ Yes       | Native agents for 10+ languages, unified view              |
| **Kubernetes-native environment**               | ✅ Yes       | Built-in K8s monitoring, Helm charts, SWCK operator        |
| **Service mesh (Istio/Envoy)**                  | ✅ Yes       | Agentless observability via ALS, mesh-aware topology       |
| **Need all-in-one observability**               | ✅ Yes       | Traces, metrics, logs, profiling in single platform        |
| **Already using Zipkin/Jaeger**                 | ✅ Yes       | Accepts Zipkin/Jaeger formats, gradual migration possible  |
| **OpenTelemetry ecosystem**                     | ✅ Yes       | Full OTLP support, can be OTel backend                     |
| **eBPF-based profiling needed**                 | ✅ Yes       | Rover provides kernel-level profiling without code changes |
| **Simple single-service app**                   | ⚠️ Maybe     | Might be overkill, consider simpler solutions              |
| **Vendor-managed APM preferred**                | ❌ No        | SkyWalking is self-hosted, consider Datadog/New Relic      |
| **Only basic tracing needed**                   | ❌ No        | Jaeger/Zipkin might be simpler                             |
| **Heavy investment in existing Elastic/Splunk** | ⚠️ Maybe     | Can integrate, but may duplicate functionality             |

### SkyWalking vs Build Your Own Stack

| Approach                                | Pros                                | Cons                                 |
| --------------------------------------- | ----------------------------------- | ------------------------------------ |
| **SkyWalking (All-in-One)**             | Single platform, unified UI, native | Learning curve, single vendor        |
| **Jaeger + Prometheus + ELK + Grafana** | Best-of-breed, flexibility          | Integration complexity, multiple UIs |
| **OpenTelemetry + Backend**             | Vendor-neutral collection           | Still need analysis backend          |

SkyWalking excels when you want a **cohesive, cloud-native observability platform** without stitching together multiple tools.

---

## Design Goals & Principles

SkyWalking is built around six core design principles:

| Principle                              | Description                                                                                                       |
| -------------------------------------- | ----------------------------------------------------------------------------------------------------------------- |
| **Maintaining Observability**          | Provide integration solutions regardless of deployment method - supports multiple runtime forms and probes        |
| **Topology, Metrics & Trace Together** | Visualize the big picture (topology) down to details (traces) - understand relationships and drill into specifics |
| **Lightweight**                        | Minimal probe footprint (prefer gRPC), simple backend tech stack - no big data platform dependencies              |
| **Pluggable**                          | Extensible architecture - default implementations provided but customizable for any scenario                      |
| **Portability**                        | Run anywhere - traditional registries, RPC frameworks, service mesh, cloud services, or across clouds             |
| **Interoperability**                   | Accept data from other systems - Zipkin, Jaeger, OpenTelemetry - no library switching required                    |

---

## Core Concepts & Terminology

Understanding SkyWalking's object hierarchy is essential:

### Service Hierarchy

```
┌───────────────────────────────────────────────────────────────────┐
│                            LAYER                                  │
│    (Abstract framework: OS_LINUX, K8S, MESH, GENERAL, etc.)       │
│                                                                   │
│  ┌─────────────────────────────────────────────────────────────┐  │
│  │                         SERVICE                             │  │
│  │    (Group of workloads with same behavior)                  │  │
│  │                                                             │  │
│  │  ┌───────────────────────────────────────────────────────┐  │  │
│  │  │                  SERVICE INSTANCE                     │  │  │
│  │  │    (Individual workload - pod, process, container)    │  │  │
│  │  │                                                       │  │  │
│  │  │  ┌─────────────────────────────────────────────────┐  │  │  │
│  │  │  │                   ENDPOINT                      │  │  │  │
│  │  │  │    (Request path - HTTP URI, gRPC method)       │  │  │  │
│  │  │  └─────────────────────────────────────────────────┘  │  │  │
│  │  │                                                       │  │  │
│  │  │  ┌─────────────────────────────────────────────────┐  │  │  │
│  │  │  │                   PROCESS                       │  │  │  │
│  │  │  │    (OS process - multiple per instance)         │  │  │  │
│  │  │  └─────────────────────────────────────────────────┘  │  │  │
│  │  └───────────────────────────────────────────────────────┘  │  │
│  └─────────────────────────────────────────────────────────────┘  │
└───────────────────────────────────────────────────────────────────┘
```

### Layer Types

| Layer                | Description                | Example Services           |
| -------------------- | -------------------------- | -------------------------- |
| **GENERAL**          | Application services       | Java apps, Python services |
| **K8S_SERVICE**      | Kubernetes workloads       | Pods, Deployments          |
| **MESH**             | Service mesh control plane | Istio services             |
| **MESH_DP**          | Service mesh data plane    | Envoy sidecars             |
| **OS_LINUX**         | Linux virtual machines     | VMs with node-exporter     |
| **MYSQL**            | MySQL databases            | MySQL instances            |
| **POSTGRESQL**       | PostgreSQL databases       | PostgreSQL instances       |
| **VIRTUAL_DATABASE** | Detected database calls    | DB calls from traces       |
| **VIRTUAL_MQ**       | Detected MQ calls          | MQ calls from traces       |
| **NGINX**            | Nginx servers              | Nginx instances            |
| **APISIX**           | APISIX gateways            | APISIX instances           |
| **KAFKA**            | Kafka clusters             | Kafka brokers              |

### Service Hierarchy Relationships

SkyWalking v10 introduced Service Hierarchy - connecting logically same services across layers:

```
Example: Java app in Kubernetes with Istio

┌─────────────────┐
│  GENERAL Layer  │  ← Java Agent detects "payment-service"
│ payment-service │
└────────┬────────┘
         │ hierarchy
         ▼
┌─────────────────┐
│   MESH Layer    │  ← Istio detects "payment-service"
│ payment-service │
└────────┬────────┘
         │ hierarchy
         ▼
┌─────────────────┐
│ K8S_SERVICE     │  ← K8s monitoring detects "payment-service"
│ payment-service │
└─────────────────┘
```

This hierarchy enables:
- Unified view of the same service across different monitoring sources
- Correlation between application metrics and infrastructure metrics
- Root cause analysis across layers

---

## Probe Types

SkyWalking uses four categories of probes to collect telemetry data:

### 1. Language-Based Native Agents

Agents that run in target service user space, integrated with application code.

| Type                | Mechanism                       | Languages       |
| ------------------- | ------------------------------- | --------------- |
| **Auto-Instrument** | Runtime bytecode manipulation   | Java, PHP, .NET |
| **Compile-Time**    | Code weaving during compilation | Go              |
| **Manual SDK**      | Library integration             | C++, Rust       |

### 2. Service Mesh Probes

Collect data from sidecars and control planes without touching application code.

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  Service A  │────▶│   Envoy     │────▶│  Service B  │
└─────────────┘     │  (Sidecar)  │     └─────────────┘
                    └──────┬──────┘
                           │ Access Logs / Metrics
                           ▼
                    ┌─────────────┐
                    │ SkyWalking  │
                    │     OAP     │
                    └─────────────┘
```

### 3. Third-Party Instrument Libraries

Accept data from existing instrumentation ecosystems:
- **Zipkin** - v1 and v2 trace formats
- **OpenTelemetry** - OTLP gRPC format
- **Jaeger** - Converted via Zipkin format

### 4. eBPF Agent (Rover)

Kernel-level observability without code changes:
- CPU profiling (on-CPU, off-CPU)
- Network profiling (TCP, HTTP)
- Process discovery

### Probe Selection Guide

| Scenario                    | Recommended Probes            |
| --------------------------- | ----------------------------- |
| Application-only monitoring | Language agents               |
| Already using Zipkin/Jaeger | 3rd-party receivers           |
| Service mesh environment    | Mesh probes (ALS)             |
| Mesh + deep tracing         | Mesh probes + Language agents |
| Performance profiling       | eBPF agent (Rover)            |
| Full observability          | Language agents + eBPF agent  |

---

## Core Architecture

SkyWalking follows a modular architecture with clear separation of concerns.

### High-Level Components

```
┌────────────────────────────────────────────────────────────────┐
│                        Data Sources                            │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐            │
│  │  Java   │  │ Python  │  │  Envoy  │  │  OTel   │  ...       │
│  │  Agent  │  │  Agent  │  │ (Istio) │  │Collector│            │
│  └────┬────┘  └────┬────┘  └────┬────┘  └────┬────┘            │
└───────┼────────────┼────────────┼────────────┼─────────────────┘
        │            │            │            │
        ▼            ▼            ▼            ▼
┌─────────────────────────────────────────────────────────────────┐
│                    SkyWalking Satellite (Optional)              │
│              Load balancing & edge data collection              │
└─────────────────────────────┬───────────────────────────────────┘
                              │
                              ▼
┌────────────────────────────────────────────────────────────────┐
│                     OAP Server (Backend)                       │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │   Receiver   │  │   Analyzer   │  │    Query     │          │
│  │   (gRPC/HTTP)│  │   (OAL/MAL)  │  │  (GraphQL)   │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
└─────────────────────────────┬──────────────────────────────────┘
                              │
                              ▼
┌────────────────────────────────────────────────────────────────┐
│                        Storage Layer                           │
│     ┌──────────┐    ┌──────────────┐    ┌────────────┐         │
│     │ BanyanDB │    │Elasticsearch │    │ PostgreSQL │         │
│     │(Default) │    │              │    │            │         │
│     └──────────┘    └──────────────┘    └────────────┘         │
└────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌────────────────────────────────────────────────────────────────┐
│                      Visualization Layer                       │
│        ┌────────────────┐      ┌────────────────┐              │
│        │   Booster UI   │      │ Grafana Plugin │              │
│        │    (Vue3)      │      │   (Optional)   │              │
│        └────────────────┘      └────────────────┘              │
└────────────────────────────────────────────────────────────────┘
```

### OAP Server (Observability Analysis Platform)

The OAP server is the brain of SkyWalking. It handles:

#### Receivers
- **gRPC Receiver** - Primary protocol for agents
- **HTTP Receiver** - REST API for data ingestion
- **Kafka Receiver** - For high-throughput scenarios
- **Zipkin/Jaeger Receivers** - Compatibility with other tracing formats

#### Analyzers
- **OAL (Observability Analysis Language)** - Define custom metrics from traces
- **MAL (Meter Analysis Language)** - Process meter data
- **LAL (Log Analysis Language)** - Extract metrics from logs

#### Query Engine
- **GraphQL API** - Unified query interface for UI and CLI
- **PromQL Support** - Prometheus-compatible queries for Grafana

### Data Flow

1. **Collection** - Agents/exporters send telemetry to OAP
2. **Analysis** - OAP processes data using OAL/MAL/LAL
3. **Storage** - Processed data persisted to storage backend
4. **Query** - UI/CLI retrieves data via GraphQL/PromQL

---

## Storage Options Deep Dive

Choosing the right storage backend is critical for SkyWalking performance.

### BanyanDB (Default & Recommended)

BanyanDB is SkyWalking's native, purpose-built observability database.

#### Pros & Cons

| ✅ Pros                                                  | ❌ Cons                                        |
| ------------------------------------------------------- | --------------------------------------------- |
| Optimized for APM data patterns (traces, metrics, logs) | Newer project, smaller community              |
| Lower CPU/memory compared to Elasticsearch              | Limited full-text search capabilities         |
| No external dependencies (no JVM tuning)                | Less mature ecosystem                         |
| Built-in TTL, compaction, downsampling                  | Fewer third-party integrations                |
| Horizontal scaling with cluster mode                    | Learning curve for BanyanDB-specific concepts |
| Single binary deployment option                         |                                               |

#### Architecture

```
┌────────────────────────────────────────────────────────┐
│                      BanyanDB                          │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │
│  │   Liaison   │  │    Data     │  │    Meta     │     │
│  │   (Query)   │  │   (Storage) │  │  (Schema)   │     │
│  └─────────────┘  └─────────────┘  └─────────────┘     │
│                                                        │
│  Data Model:                                           │
│  - Stream (Traces, Logs)                               │
│  - Measure (Metrics)                                   │
│  - Property (Metadata)                                 │
└────────────────────────────────────────────────────────┘
```

#### When to Use BanyanDB

- ✅ New SkyWalking deployments
- ✅ Resource-constrained environments
- ✅ Simplified operations preferred
- ✅ SkyWalking-only observability stack

---

### Elasticsearch

Traditional choice for SkyWalking storage with mature ecosystem.

#### Pros & Cons

| ✅ Pros                                   | ❌ Cons                                           |
| ---------------------------------------- | ------------------------------------------------ |
| Mature ecosystem and extensive tooling   | Higher resource consumption (CPU, memory, disk)  |
| Advanced full-text search capabilities   | Complex JVM tuning required                      |
| Large community and documentation        | Overkill for pure APM use cases                  |
| Existing expertise in many organizations | License changes (OpenSearch fork considerations) |
| Integration with ELK/Elastic stack       | Cluster management complexity                    |
| Kibana for additional visualization      | Index management overhead                        |

#### When to Use Elasticsearch

- ✅ Existing Elasticsearch cluster available
- ✅ Need advanced full-text search on traces
- ✅ Integration with ELK stack required
- ✅ Team has Elasticsearch expertise

---

### PostgreSQL

Relational database option for smaller deployments.

#### Pros & Cons

| ✅ Pros                        | ❌ Cons                                   |
| ----------------------------- | ---------------------------------------- |
| Simple setup and operations   | Limited horizontal scalability           |
| Low resource footprint        | Not optimized for time-series data       |
| Familiar SQL interface        | Performance degrades at scale            |
| Existing infrastructure reuse | Manual partitioning for large datasets   |
| Strong ACID compliance        | No native full-text search for traces    |
| Mature backup/restore tools   | Single point of failure without HA setup |

#### When to Use PostgreSQL

- ✅ Small-scale deployments (<100 services)
- ✅ Existing PostgreSQL infrastructure
- ✅ Simpler operational model preferred
- ✅ Development/testing environments

---

### Storage Comparison Matrix

| Aspect                     | BanyanDB        | Elasticsearch | PostgreSQL   |
| -------------------------- | --------------- | ------------- | ------------ |
| **Performance**            | ⭐⭐⭐⭐⭐ Excellent | ⭐⭐⭐⭐ Good     | ⭐⭐⭐ Moderate |
| **Resource Usage**         | ⭐⭐⭐⭐⭐ Low       | ⭐⭐ High       | ⭐⭐⭐⭐ Low     |
| **Scalability**            | Horizontal      | Horizontal    | Vertical     |
| **Operational Complexity** | ⭐⭐⭐⭐⭐ Low       | ⭐⭐ High       | ⭐⭐⭐⭐ Low     |
| **Full-text Search**       | Basic           | Advanced      | Basic        |
| **Community/Ecosystem**    | Growing         | Mature        | Mature       |
| **Best For**               | APM-focused     | Search-heavy  | Small scale  |
| **Recommended Scale**      | Any             | Large         | Small-Medium |

---

## Visualization & UI

### Booster UI (Native)

SkyWalking's official UI, built with Vue3 and TypeScript.

#### Key Features

- **Service Topology** - Visual service dependency map
- **Trace Explorer** - Detailed span analysis
- **Dashboard** - Customizable metric dashboards
- **Alarm View** - Alert management interface
- **Profile Analysis** - CPU/memory profiling results

#### Dashboard Capabilities

```
┌────────────────────────────────────────────────────────┐
│                    Booster UI                          │
├────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │
│  │  General    │  │   Service   │  │  Instance   │     │
│  │  Service    │  │  Topology   │  │   Metrics   │     │
│  └─────────────┘  └─────────────┘  └─────────────┘     │
│                                                        │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │
│  │   Trace     │  │   Profile   │  │    Alarm    │     │
│  │  Explorer   │  │   Analysis  │  │    View     │     │
│  └─────────────┘  └─────────────┘  └─────────────┘     │
│                                                        │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │
│  │    Log      │  │  Database   │  │ Kubernetes  │     │
│  │   Viewer    │  │  Dashboard  │  │  Dashboard  │     │
│  └─────────────┘  └─────────────┘  └─────────────┘     │
└────────────────────────────────────────────────────────┘
```

### Grafana Integration

SkyWalking provides official Grafana plugins for teams already using Grafana.

#### SkyWalking Grafana Plugins

1. **Data Source Plugin** - Connect Grafana to SkyWalking OAP
2. **Topology Panel** - Service map visualization
3. **PromQL Support** - Use familiar Prometheus queries

#### Configuration Example

```yaml
# Grafana data source configuration
datasources:
  - name: SkyWalking
    type: skywalking
    url: https://skywalking.example.com/graphql
    access: proxy
```

#### Use Cases for Grafana

- Unified dashboards with other data sources
- Custom visualization requirements
- Team familiarity with Grafana
- PromQL-based alerting

---

## CLI & Automation (swctl)

`swctl` is SkyWalking's command-line interface for automation and scripting.

### Installation

```bash
# Download and extract (contains binaries for all platforms)
curl -L https://dlcdn.apache.org/skywalking/cli/0.14.0/skywalking-cli-0.14.0-bin.tgz | tar xz

# macOS (Intel)
sudo mv skywalking-cli-0.14.0-bin/bin/swctl-0.14.0-darwin-amd64 /usr/local/bin/swctl

# macOS (Apple Silicon)
sudo mv skywalking-cli-0.14.0-bin/bin/swctl-0.14.0-darwin-arm64 /usr/local/bin/swctl

# Linux (amd64)
sudo mv skywalking-cli-0.14.0-bin/bin/swctl-0.14.0-linux-amd64 /usr/local/bin/swctl

# Docker
docker run -it apache/skywalking-cli:0.14.0 swctl
```

### Common Commands

```bash
# Check service list
swctl service list

# Get service metrics
swctl metrics linear --name service_cpm --service-name my-service

# Query traces
swctl trace list --service-name my-service --trace-state ERROR

# Check alarms
swctl alarm list

# Health check
swctl checkHealth
```

### CI/CD Integration

`swctl` can report deployment events to SkyWalking:

```yaml
# GitHub Actions example
- name: Report Deployment Event
  uses: apache/skywalking-cli@main
  with:
    oap-url: ${{ secrets.SKYWALKING_OAP_URL }}
    args: |
      event report --name "Deployment" \
        --service-name my-service \
        --message "Deployed version ${{ github.sha }}"
```

### Automation Use Cases

- **Deployment Events** - Correlate deployments with metrics
- **Health Checks** - Verify SkyWalking availability
- **Metric Export** - Extract metrics for external processing
- **Alert Integration** - Custom alert workflows

---

## Comparison with Alternatives

### SkyWalking vs Jaeger

| Aspect                   | SkyWalking         | Jaeger              |
| ------------------------ | ------------------ | ------------------- |
| **Focus**                | Full observability | Tracing only        |
| **Metrics**              | Built-in           | Requires Prometheus |
| **Logging**              | Integrated         | Not included        |
| **Profiling**            | eBPF-based (Rover) | Not available       |
| **Auto-instrumentation** | Extensive          | Limited             |
| **Storage**              | Multiple options   | Cassandra/ES/Memory |

### SkyWalking vs Zipkin

| Aspect             | SkyWalking     | Zipkin       |
| ------------------ | -------------- | ------------ |
| **Architecture**   | Comprehensive  | Lightweight  |
| **Analysis**       | OAL/MAL/LAL    | Basic        |
| **UI**             | Feature-rich   | Simple       |
| **Kubernetes**     | Native support | Manual setup |
| **Learning Curve** | Moderate       | Low          |

### SkyWalking vs OpenTelemetry Collector

| Aspect            | SkyWalking    | OTel Collector    |
| ----------------- | ------------- | ----------------- |
| **Type**          | Full platform | Data pipeline     |
| **Analysis**      | Built-in      | Requires backend  |
| **Storage**       | Included      | External required |
| **UI**            | Included      | External required |
| **Compatibility** | OTel receiver | Native OTel       |

### When to Choose SkyWalking

- ✅ Need all-in-one observability platform
- ✅ Want built-in analysis capabilities
- ✅ Prefer native Kubernetes integration
- ✅ Need eBPF-based profiling
- ✅ Want simplified operations

### When to Consider Alternatives

- ❌ Already invested in Jaeger/Zipkin ecosystem
- ❌ Need only basic tracing
- ❌ Prefer vendor-managed solutions
- ❌ Very small scale (single service)

---

## Marketplace - Out-of-Box Monitoring

SkyWalking's Marketplace provides ready-to-use monitoring for a wide range of technologies:

| Category               | Technologies                                                 |
| ---------------------- | ------------------------------------------------------------ |
| **General Services**   | Java, Python, Go, Node.js, PHP, .NET, Rust, Ruby, Lua        |
| **Service Mesh**       | Istio, Envoy (ALS and metrics)                               |
| **Kubernetes**         | Cluster monitoring, pod metrics, network profiling           |
| **Infrastructure**     | Linux VMs, Windows servers                                   |
| **Cloud Services**     | AWS EKS, S3, DynamoDB, API Gateway                           |
| **Gateways**           | Nginx, APISIX, Kong                                          |
| **Databases**          | MySQL, PostgreSQL, Redis, Elasticsearch, MongoDB, ClickHouse |
| **Message Queues**     | Kafka, RabbitMQ, Pulsar, RocketMQ, ActiveMQ                  |
| **Browser**            | Real user monitoring (RUM)                                   |
| **Self Observability** | OAP, Satellite, agents monitoring                            |

Once SkyWalking detects services of a configured type, corresponding menus and dashboards appear automatically in the UI.

---

## SkyWalking Ecosystem Overview

### Component Selection Guide

Use this guide to determine which SkyWalking components you need:

#### Core Components (Required)

| Component      | Always Needed? | Purpose                               |
| -------------- | -------------- | ------------------------------------- |
| **OAP Server** | ✅ Yes          | Backend processing, analysis, storage |
| **Storage**    | ✅ Yes          | Data persistence (BanyanDB/ES/PG)     |
| **UI**         | ✅ Yes          | Visualization (Booster UI or Grafana) |

#### Data Collection (Choose Based on Stack)

| Component             | When to Use                                  |
| --------------------- | -------------------------------------------- |
| **Java Agent**        | Java/JVM applications                        |
| **Python Agent**      | Python applications                          |
| **Go Agent**          | Go applications                              |
| **Node.js Agent**     | Node.js applications                         |
| **PHP Agent**         | PHP applications                             |
| **Envoy/Istio (ALS)** | Service mesh environments (agentless)        |
| **OpenTelemetry**     | Already using OTel, or unsupported languages |
| **Zipkin Receiver**   | Migrating from Zipkin                        |

#### Infrastructure Monitoring (Optional)

| Component              | When to Use                                |
| ---------------------- | ------------------------------------------ |
| **K8s Event Exporter** | Correlate K8s events with metrics          |
| **Rover (eBPF)**       | CPU/network profiling without code changes |
| **OTel Collector**     | VM, database, MQ monitoring                |

#### Scaling Components (Production)

| Component     | When to Use                                  |
| ------------- | -------------------------------------------- |
| **Satellite** | High agent count, need load balancing        |
| **SWCK**      | Kubernetes operator for auto agent injection |

#### Collector Responsibilities: Satellite vs OTel Collector

Understanding when to use Satellite versus OpenTelemetry Collector is crucial for proper architecture:

| Category                    | Collector          | Reason                                                   |
| --------------------------- | ------------------ | -------------------------------------------------------- |
| **Application Traces/Logs** | Satellite          | Buffers and load-balances agent data to OAP              |
| **Self-Observability**      | OTel Collector     | Scrapes Prometheus metrics from OAP, BanyanDB, Satellite |
| **Gateway Metrics**         | OTel Collector     | Scrapes from Nginx, APISIX, Kong exporters               |
| **Database Metrics**        | OTel Collector     | Scrapes from MySQL, PostgreSQL, Redis exporters          |
| **Message Queue Metrics**   | OTel Collector     | Scrapes from Kafka, RabbitMQ exporters                   |
| **Kubernetes Metrics**      | OTel Collector     | Scrapes kube-state-metrics, cAdvisor                     |
| **Infrastructure (VM)**     | OTel Collector     | Scrapes node-exporter metrics                            |
| **Service Mesh**            | OAP directly (ALS) | Envoy Access Log Service - no collector needed           |
| **Cilium Metrics**          | OTel Collector     | Scrapes Hubble/Cilium metrics                            |

> **Key Point**: Satellite is ONLY for application agent data (traces, logs, metrics from language agents). All infrastructure and self-observability metrics flow through OpenTelemetry Collector. They serve complementary purposes and are NOT interchangeable.

```
Architecture Overview:

┌─────────────────────────────────────────────────────────────────────┐
│                     Application Layer                                │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐                              │
│  │  Java   │  │ Python  │  │   Go    │  (Language Agents)           │
│  │  Agent  │  │  Agent  │  │  Agent  │                              │
│  └────┬────┘  └────┬────┘  └────┬────┘                              │
│       └────────────┼────────────┘                                   │
│                    ▼                                                │
│            ┌─────────────┐                                          │
│            │  Satellite  │  ← Traces, Logs, Agent Metrics           │
│            └──────┬──────┘                                          │
└───────────────────┼─────────────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    SkyWalking OAP                                    │
└───────────────────▲─────────────────────────────────────────────────┘
                    │
┌───────────────────┼─────────────────────────────────────────────────┐
│                   │        Infrastructure Layer                      │
│            ┌──────┴──────┐                                          │
│            │    OTel     │  ← Prometheus Metrics                    │
│            │  Collector  │                                          │
│            └──────▲──────┘                                          │
│       ┌───────────┼───────────┬───────────┬───────────┐             │
│  ┌────┴────┐ ┌────┴────┐ ┌────┴────┐ ┌────┴────┐ ┌────┴────┐       │
│  │   OAP   │ │BanyanDB │ │  MySQL  │ │  Kafka  │ │  Nginx  │       │
│  │ Metrics │ │ Metrics │ │Exporter │ │Exporter │ │Exporter │       │
│  └─────────┘ └─────────┘ └─────────┘ └─────────┘ └─────────┘       │
└─────────────────────────────────────────────────────────────────────┘
```

#### Decision Tree

```
Start Here
    │
    ├─► Do you have Java/Python/Go/Node.js apps?
    │       └─► YES: Use native language agents
    │       └─► NO: Use OpenTelemetry or service mesh
    │
    ├─► Are you using Istio/Envoy service mesh?
    │       └─► YES: Enable ALS (can combine with agents)
    │       └─► NO: Skip mesh integration
    │
    ├─► Do you need CPU/network profiling?
    │       └─► YES: Deploy Rover (eBPF agent)
    │       └─► NO: Skip Rover
    │
    ├─► Do you have > 100 agent instances?
    │       └─► YES: Deploy Satellite for load balancing
    │       └─► NO: Agents connect directly to OAP
    │
    └─► Are you on Kubernetes?
            └─► YES: Consider SWCK for auto injection
            └─► NO: Manual agent setup
```

### Active Components (Covered in This Series)

| Component              | Purpose                | Post   |
| ---------------------- | ---------------------- | ------ |
| **OAP Server**         | Core backend           | Part 1 |
| **BanyanDB**           | Native storage         | Part 1 |
| **Booster UI**         | Web interface          | Part 1 |
| **Grafana Plugins**    | Grafana integration    | Part 1 |
| **swctl (CLI)**        | Command-line tool      | Part 1 |
| **Java Agent**         | Java instrumentation   | Part 2 |
| **Python Agent**       | Python instrumentation | Part 2 |
| **Helm Charts**        | Kubernetes deployment  | Part 2 |
| **SWCK**               | Kubernetes operator    | Part 2 |
| **Satellite**          | Load balancer          | Part 2 |
| **Rover**              | eBPF profiler          | Part 3 |
| **K8s Event Exporter** | Event correlation      | Part 3 |

### Protocol/Development Components (Not Covered)

These are for SkyWalking contributors and integrators:
- `skywalking-data-collect-protocol` - gRPC definitions
- `skywalking-query-protocol` - GraphQL schema
- `skywalking-goapi` - Go bindings
- `skywalking-agent-test-tool` - Testing framework
- `skywalking-infra-e2e` - E2E testing
- `skywalking-eyes` - License tooling

---

## Summary

Apache SkyWalking provides a comprehensive observability platform that goes beyond simple tracing:

1. **Unified Platform** - Traces, metrics, logs, and profiling in one place
2. **Flexible Storage** - BanyanDB (recommended), Elasticsearch, or PostgreSQL
3. **Rich Visualization** - Native UI and Grafana integration
4. **Automation Ready** - CLI for scripting and CI/CD integration
5. **Cloud Native** - Built for Kubernetes and microservices

In **Part 2**, we'll dive into hands-on deployment using Helm, agent instrumentation, and running the SkyWalking showcase demo.

---

## References

### Core Concepts
- [SkyWalking Official Documentation](https://skywalking.apache.org/docs/main/next/readme/)
- [SkyWalking Overview](https://skywalking.apache.org/docs/main/next/en/concepts-and-designs/overview/)
- [Backend Overview](https://skywalking.apache.org/docs/main/next/en/setup/backend/backend-overview/)
- [Design Goals](https://skywalking.apache.org/docs/main/next/en/concepts-and-designs/project-goals/)
- [Probe Introduction](https://skywalking.apache.org/docs/main/next/en/concepts-and-designs/probe-introduction/)
- [Service Agent](https://skywalking.apache.org/docs/main/next/en/concepts-and-designs/service-agent/)
- [Manual SDK](https://skywalking.apache.org/docs/main/next/en/concepts-and-designs/manual-sdk/)
- [Service Hierarchy](https://skywalking.apache.org/docs/main/next/en/concepts-and-designs/service-hierarchy/)
- [Service Hierarchy Configuration](https://skywalking.apache.org/docs/main/next/en/setup/backend/service-hierarchy-configuration/)
- [Metrics Additional Attributes](https://skywalking.apache.org/docs/main/next/en/setup/backend/metrics-additional-attributes/)

### Storage
- [BanyanDB Documentation](https://skywalking.apache.org/docs/skywalking-banyandb/next/readme/)
- [Storage Options](https://skywalking.apache.org/docs/main/next/en/setup/backend/backend-storage/)

### Visualization & Tools
- [SkyWalking CLI GitHub](https://github.com/apache/skywalking-cli)
- [SkyWalking Grafana Plugins](https://github.com/apache/skywalking-grafana-plugins)
- [SkyWalking Booster UI](https://github.com/apache/skywalking-booster-ui)

### Configuration
- [Configuration Vocabulary](https://skywalking.apache.org/docs/main/next/en/setup/backend/configuration-vocabulary/)
- [Cluster Management](https://skywalking.apache.org/docs/main/next/en/setup/backend/backend-cluster/)

### Query & API
- [Query Protocol (GraphQL)](https://skywalking.apache.org/docs/main/next/en/api/query-protocol/)
- [Metrics Query Expression (MQE)](https://skywalking.apache.org/docs/main/next/en/api/metrics-query-expression/)
- [PromQL Service](https://skywalking.apache.org/docs/main/next/en/api/promql-service/)
- [LogQL Service](https://skywalking.apache.org/docs/main/next/en/api/logql-service/)
- [Health Check API](https://skywalking.apache.org/docs/main/next/en/api/health-check/)

### Status & Debugging
- [Status APIs](https://skywalking.apache.org/docs/main/next/en/status/status_apis/)
- [Config Dump](https://skywalking.apache.org/docs/main/next/en/debugging/config_dump/)
- [Query Tracing](https://skywalking.apache.org/docs/main/next/en/debugging/query-tracing/)
- [Query TTL Setup](https://skywalking.apache.org/docs/main/next/en/status/query_ttl_setup/)
- [Query Cluster Nodes](https://skywalking.apache.org/docs/main/next/en/status/query_cluster_nodes/)
- [Query Alarm Runtime Status](https://skywalking.apache.org/docs/main/next/en/status/query_alarm_runtime_status/)
