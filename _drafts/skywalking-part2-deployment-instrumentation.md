---
title: "Apache SkyWalking Part 2: Deploying on Kubernetes - From Zero to Full Observability"
description: "Hands-on guide to deploying SkyWalking with Helm, instrumenting Java and Python applications, and running the showcase demo"
date: 2026-02-02
categories: [Observability, APM]
tags: [skywalking, kubernetes, helm, java-agent, python-agent, swck, satellite]
image:
  path: /assets/img/posts/skywalking-deployment.png
  alt: Apache SkyWalking Kubernetes Deployment
---

## Introduction

In [Part 1](/posts/skywalking-part1-introduction-architecture/), we explored SkyWalking's architecture, storage options, and visualization capabilities. Now it's time to get hands-on.

This post covers:
- Deploying SkyWalking on Kubernetes using Helm
- Setting up BanyanDB as the storage backend
- Instrumenting Java and Python applications
- Using SWCK for automatic agent injection
- Deploying Satellite for load balancing
- Running the official showcase demo

### Prerequisites

- Kubernetes cluster (1.19+) OR Docker with Docker Compose
- `kubectl` configured (for K8s deployment)
- Helm 3.x installed (for K8s deployment)
- 8 CPU cores, 16GB RAM (minimum for full demo)

---

## Docker Compose Deployment (Non-Kubernetes)

For local development or non-Kubernetes environments, use Docker Compose.

### Quick Start Script

```bash
# Linux, macOS, Windows (WSL)
bash <(curl -sSL https://skywalking.apache.org/quickstart.sh)

# Windows (PowerShell)
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://skywalking.apache.org/quickstart.ps1'))
```

You'll be prompted to choose storage (BanyanDB or Elasticsearch), then the script starts the full stack.

### Manual Docker Compose

```yaml
# docker-compose.yml
version: '3.8'

services:
  banyandb:
    image: apache/skywalking-banyandb:0.8.0
    container_name: banyandb
    ports:
      - "17912:17912"
    command: standalone
    healthcheck:
      test: ["CMD", "sh", "-c", "nc -z 127.0.0.1 17912"]
      interval: 5s
      timeout: 60s
      retries: 120

  oap:
    image: apache/skywalking-oap-server:10.3.0
    container_name: oap
    depends_on:
      banyandb:
        condition: service_healthy
    ports:
      - "11800:11800"  # gRPC
      - "12800:12800"  # HTTP
    environment:
      SW_STORAGE: banyandb
      SW_STORAGE_BANYANDB_TARGETS: banyandb:17912
      SW_HEALTH_CHECKER: default
      SW_TELEMETRY: prometheus
    healthcheck:
      test: ["CMD", "sh", "-c", "nc -z 127.0.0.1 11800"]
      interval: 5s
      timeout: 60s
      retries: 120

  ui:
    image: apache/skywalking-ui:10.3.0
    container_name: ui
    depends_on:
      oap:
        condition: service_healthy
    ports:
      - "8080:8080"
    environment:
      SW_OAP_ADDRESS: http://oap:12800
```

```bash
# Start
docker-compose up -d

# Access UI at http://localhost:8080

# Tear down
docker-compose down
```

### With Elasticsearch Storage

```yaml
# docker-compose-es.yml
version: '3.8'

services:
  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:8.15.0
    container_name: elasticsearch
    environment:
      - discovery.type=single-node
      - xpack.security.enabled=false
      - "ES_JAVA_OPTS=-Xms512m -Xmx512m"
    ports:
      - "9200:9200"
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:9200"]
      interval: 5s
      timeout: 60s
      retries: 120

  oap:
    image: apache/skywalking-oap-server:10.3.0
    container_name: oap
    depends_on:
      elasticsearch:
        condition: service_healthy
    ports:
      - "11800:11800"
      - "12800:12800"
    environment:
      SW_STORAGE: elasticsearch
      SW_STORAGE_ES_CLUSTER_NODES: elasticsearch:9200

  ui:
    image: apache/skywalking-ui:10.3.0
    container_name: ui
    depends_on:
      - oap
    ports:
      - "8080:8080"
    environment:
      SW_OAP_ADDRESS: http://oap:12800
```

### Extending Docker Images

```dockerfile
# Custom OAP with additional configs
FROM apache/skywalking-oap-server:10.3.0

# Override config files
COPY my-alarm-settings.yml /skywalking/config/alarm-settings.yml

# Add custom OAL rules
COPY my-oal-rules.yaml /skywalking/config/oal/

# Add extra JARs to classpath
COPY my-custom-plugin.jar /skywalking/ext-libs/
```

---

## Deploying SkyWalking with Helm

The official [Apache SkyWalking Helm Chart](https://github.com/apache/skywalking-helm) provides a production-ready way to deploy SkyWalking on Kubernetes.

### Required Values

When deploying SkyWalking, these values must be set:

| Name              | Description          | Example                                   |
| ----------------- | -------------------- | ----------------------------------------- |
| `oap.image.tag`   | OAP docker image tag | `10.3.0`                                  |
| `oap.storageType` | Storage backend type | `banyandb`, `elasticsearch`, `postgresql` |
| `ui.image.tag`    | UI docker image tag  | `10.3.0`                                  |

### Quick Start (Single Node)

```bash
# Set variables
export SKYWALKING_RELEASE_NAME=skywalking
export SKYWALKING_RELEASE_NAMESPACE=skywalking
export HELM_CHART_VERSION=4.8.0

# Create namespace
kubectl create namespace ${SKYWALKING_RELEASE_NAMESPACE}

# Install using OCI registry (Helm Chart >= 4.3.0)
helm install ${SKYWALKING_RELEASE_NAME} \
  oci://registry-1.docker.io/apache/skywalking-helm \
  --version ${HELM_CHART_VERSION} \
  --namespace ${SKYWALKING_RELEASE_NAMESPACE} \
  --set oap.image.tag=10.3.0 \
  --set oap.storageType=banyandb \
  --set ui.image.tag=10.3.0
```

### Check Available Chart Versions

```bash
# List available versions from OCI registry
curl -s "https://hub.docker.com/v2/repositories/apache/skywalking-helm/tags?page_size=10" | \
  jq -r '.results[].name'

# Or visit: https://hub.docker.com/r/apache/skywalking-helm/tags
```

### Cluster Mode (Production)

For production environments, deploy OAP in cluster mode:

```bash
helm install ${SKYWALKING_RELEASE_NAME} \
  oci://registry-1.docker.io/apache/skywalking-helm \
  --version ${HELM_CHART_VERSION} \
  --namespace ${SKYWALKING_RELEASE_NAMESPACE} \
  --set oap.image.tag=10.3.0 \
  --set oap.storageType=banyandb \
  --set oap.replicas=3 \
  --set ui.image.tag=10.3.0 \
  --set ui.replicas=2
```

### OAP Cluster Roles

SkyWalking OAP supports three deployment roles for scaling and separation of concerns:

| Role           | Receives Data | Aggregates | Queries | Use Case                          |
| -------------- | ------------- | ---------- | ------- | --------------------------------- |
| **Mixed**      | ✅             | ✅          | ✅       | Default, small-medium deployments |
| **Receiver**   | ✅             | L1 only    | ❌       | High-throughput data ingestion    |
| **Aggregator** | ❌             | L2 final   | ✅       | Final aggregation and queries     |

#### Mixed Mode (Default)

All OAP nodes handle everything - suitable for most deployments:

```yaml
oap:
  env:
    SW_CORE_ROLE: Mixed  # Default
```

#### Receiver + Aggregator Mode (Large Scale)

Separate data ingestion from aggregation for high-throughput scenarios:

```
┌─────────────┐     ┌─────────────────────────────────────────┐
│   Agents    │────▶│         Receiver OAP Nodes              │
│  Satellite  │     │  (L1 aggregation, forward to Aggregator)│
└─────────────┘     └─────────────────┬───────────────────────┘
                                      │
                                      ▼
                    ┌─────────────────────────────────────────┐
                    │        Aggregator OAP Nodes             │
                    │  (L2 aggregation, storage, queries)     │
                    └─────────────────────────────────────────┘
                                      │
                                      ▼
                    ┌─────────────────────────────────────────┐
                    │              Storage                     │
                    └─────────────────────────────────────────┘
```

```yaml
# Receiver nodes (scale based on agent count)
oap-receiver:
  env:
    SW_CORE_ROLE: Receiver
    SW_CORE_GRPC_HOST: 0.0.0.0
  replicas: 4

# Aggregator nodes (scale based on query load)
oap-aggregator:
  env:
    SW_CORE_ROLE: Aggregator
  replicas: 2
```

#### When to Use Each Mode

| Deployment Size | Agents/Services | Recommended Mode      |
| --------------- | --------------- | --------------------- |
| Small           | < 50            | Mixed (2 replicas)    |
| Medium          | 50-200          | Mixed (3-5 replicas)  |
| Large           | 200-1000        | Receiver + Aggregator |
| Very Large      | > 1000          | Receiver + Aggregator |

### Cluster Coordinators

OAP cluster nodes need coordination for proper distributed aggregation. Without coordination, metrics may be inaccurate.

| Coordinator    | Best For                   | Notes                         |
| -------------- | -------------------------- | ----------------------------- |
| **Kubernetes** | K8s deployments (default)  | Uses K8s API, no extra infra  |
| **Zookeeper**  | Existing ZK infrastructure | Requires ZK 3.5+              |
| **Consul**     | HashiCorp ecosystem        | Service discovery integration |
| **Etcd**       | Existing etcd cluster      | v3 protocol only              |
| **Nacos**      | Alibaba/China deployments  | Requires Nacos 2.x            |

```yaml
# Kubernetes coordinator (default for Helm)
cluster:
  selector: kubernetes

# Zookeeper coordinator
cluster:
  selector: zookeeper
  zookeeper:
    hostPort: zk1:2181,zk2:2181,zk3:2181
```

> 📖 **Deep Dive**: [Cluster Management Documentation](https://skywalking.apache.org/docs/main/next/en/setup/backend/backend-cluster/)

### Custom Values File

For complex deployments, use a values file:

```yaml
# values-production.yaml
oap:
  image:
    tag: "10.3.0"
  replicas: 2
  storageType: banyandb
  resources:
    requests:
      cpu: "1"
      memory: "2Gi"
    limits:
      cpu: "2"
      memory: "4Gi"
  env:
    SW_CORE_RECORD_DATA_TTL: 7        # Days to keep trace data
    SW_CORE_METRICS_DATA_TTL: 30      # Days to keep metrics
    SW_ENABLE_UPDATE_UI_TEMPLATE: "true"

ui:
  image:
    tag: "10.3.0"
  replicas: 2
  resources:
    requests:
      cpu: "200m"
      memory: "256Mi"

banyandb:
  enabled: true
  image:
    tag: "0.8.0"
  standalone:
    enabled: false
  cluster:
    liaison:
      replicas: 2
    data:
      replicas: 3
  storage:
    persistentVolumeClaim:
      enabled: true
      size: 50Gi
```

```bash
helm install ${SKYWALKING_RELEASE_NAME} skywalking/skywalking \
  --namespace ${SKYWALKING_RELEASE_NAMESPACE} \
  -f values-production.yaml
```

### Verify Installation

```bash
# Check pods
kubectl get pods -n ${SKYWALKING_RELEASE_NAMESPACE}

# Expected output:
# NAME                                    READY   STATUS    RESTARTS   AGE
# skywalking-oap-0                        1/1     Running   0          2m
# skywalking-oap-1                        1/1     Running   0          2m
# skywalking-ui-xxx-xxx                   1/1     Running   0          2m
# skywalking-banyandb-0                   1/1     Running   0          2m

# Access UI (port-forward)
kubectl port-forward svc/skywalking-ui 8080:80 -n ${SKYWALKING_RELEASE_NAMESPACE}
# Open http://localhost:8080
```

---

## BanyanDB Standalone Deployment

For dedicated BanyanDB clusters or advanced configurations:

### Using BanyanDB Helm Chart

```bash
# Add repository
helm repo add banyandb https://apache.jfrog.io/artifactory/skywalking-helm

# Install standalone BanyanDB
helm install banyandb banyandb/banyandb \
  --namespace ${SKYWALKING_RELEASE_NAMESPACE} \
  --set image.tag=0.8.0 \
  --set standalone.enabled=true \
  --set storage.persistentVolumeClaim.enabled=true \
  --set storage.persistentVolumeClaim.size=100Gi
```

### Cluster Mode BanyanDB

```yaml
# banyandb-cluster-values.yaml
image:
  tag: "0.8.0"

standalone:
  enabled: false

cluster:
  liaison:
    replicas: 2
    resources:
      requests:
        cpu: "500m"
        memory: "512Mi"
  data:
    replicas: 3
    resources:
      requests:
        cpu: "1"
        memory: "2Gi"

etcd:
  enabled: true
  replicaCount: 3

storage:
  persistentVolumeClaim:
    enabled: true
    size: 100Gi
    storageClassName: "fast-ssd"
```

```bash
helm install banyandb banyandb/banyandb \
  --namespace ${SKYWALKING_RELEASE_NAMESPACE} \
  -f banyandb-cluster-values.yaml
```

### Connect SkyWalking to External BanyanDB

```yaml
# skywalking-values.yaml
oap:
  storageType: banyandb
  env:
    SW_STORAGE_BANYANDB_TARGETS: "banyandb-liaison.skywalking:17912"

banyandb:
  enabled: false  # Don't deploy BanyanDB with SkyWalking chart
```

### BanyanDB Backup & Restore

```bash
# Create backup
kubectl exec -it banyandb-0 -n ${SKYWALKING_RELEASE_NAMESPACE} -- \
  banyandb backup create --output /backup/$(date +%Y%m%d)

# Restore from backup
kubectl exec -it banyandb-0 -n ${SKYWALKING_RELEASE_NAMESPACE} -- \
  banyandb backup restore --input /backup/20260202
```

### BanyanDB TTL Configuration

Data retention is controlled at the OAP level, which instructs BanyanDB on TTL:

```yaml
# OAP environment variables for TTL
oap:
  env:
    # Record data (traces, logs) - days
    SW_CORE_RECORD_DATA_TTL: 3

    # Metrics data - days
    SW_CORE_METRICS_DATA_TTL: 7
```

#### TTL Settings Reference

| Variable                   | Description                       | Default | Min (v10.3.0+) |
| -------------------------- | --------------------------------- | ------- | -------------- |
| `SW_CORE_RECORD_DATA_TTL`  | Traces, logs, slow queries        | 3 days  | **2 days**     |
| `SW_CORE_METRICS_DATA_TTL` | Service/endpoint/instance metrics | 7 days  | **2 days**     |

#### Recommended Values by Environment

| Environment     | Records (Traces/Logs) | Metrics  | Notes                     |
| --------------- | --------------------- | -------- | ------------------------- |
| **Development** | 2 days                | 2 days   | Minimum storage           |
| **Staging**     | 3 days                | 7 days   | Match production patterns |
| **Production**  | 7 days                | 30 days  | Sufficient for debugging  |
| **Compliance**  | 30+ days              | 90+ days | Regulatory requirements   |

> **Important (v10.3.0+)**: The minimum TTL is 2 days. Setting TTL to 1 day will cause OAP startup errors. This is a BanyanDB requirement for proper data compaction.

#### Storage Estimation

Approximate storage per day (varies by traffic):

| Data Type | Storage per 1M requests/day |
| --------- | --------------------------- |
| Traces    | ~5-10 GB                    |
| Metrics   | ~1-2 GB                     |
| Logs      | ~2-5 GB                     |

Example: 1M requests/day with 7-day trace retention and 30-day metrics retention:
- Traces: 7 × 7.5 GB = ~52 GB
- Metrics: 30 × 1.5 GB = ~45 GB
- Total: ~100 GB

BanyanDB automatically manages data lifecycle based on these TTL settings, including:
- Automatic data expiration
- Background compaction
- Storage reclamation

---

## Backend Configuration

### Configuration Methods

SkyWalking OAP configuration can be set through multiple methods (in order of precedence):

| Method                    | Use Case                        | Example                               |
| ------------------------- | ------------------------------- | ------------------------------------- |
| **System Properties**     | JVM startup overrides           | `-Dcore.default.role=Receiver`        |
| **Environment Variables** | Container/K8s deployments       | `SW_CORE_ROLE=Receiver`               |
| **application.yml**       | Base configuration              | Edit `config/application.yml`         |
| **Dynamic Configuration** | Runtime changes without restart | Via Nacos, Zookeeper, etcd, ConfigMap |

### Key Environment Variables

| Variable                   | Description                          | Default  |
| -------------------------- | ------------------------------------ | -------- |
| `SW_CORE_ROLE`             | OAP role (Mixed/Receiver/Aggregator) | Mixed    |
| `SW_CORE_REST_HOST`        | REST API bind address                | 0.0.0.0  |
| `SW_CORE_REST_PORT`        | REST API port                        | 12800    |
| `SW_CORE_GRPC_HOST`        | gRPC bind address                    | 0.0.0.0  |
| `SW_CORE_GRPC_PORT`        | gRPC port                            | 11800    |
| `SW_STORAGE`               | Storage type                         | banyandb |
| `SW_CORE_RECORD_DATA_TTL`  | Trace/log retention (days)           | 3        |
| `SW_CORE_METRICS_DATA_TTL` | Metrics retention (days)             | 7        |

### Init Mode (Schema Initialization)

For clustered deployments, run one OAP instance in init mode first to create storage schemas:

```bash
# Kubernetes - use init container or Job
./oapServiceInit.sh

# Logs will show:
# "OAP starts up in init mode successfully, exit now…"
```

This prevents race conditions when multiple OAP nodes try to create indexes simultaneously.

### Kafka Fetcher

For high-throughput scenarios, agents can report to Kafka instead of directly to OAP:

```
Agents → Kafka → OAP (Kafka Fetcher)
```

```yaml
oap:
  env:
    SW_KAFKA_FETCHER: default
    SW_KAFKA_FETCHER_SERVERS: kafka:9092
    SW_KAFKA_FETCHER_PARTITIONS: 3
    SW_KAFKA_FETCHER_ENABLE_NATIVE_PROTO_LOG: "true"
```

Required Kafka topics (auto-created if not exist):
- `skywalking-segments`
- `skywalking-metrics`
- `skywalking-logs`
- `skywalking-managements`

### gRPC Security (TLS/mTLS)

Enable TLS for secure agent-to-OAP communication:

```yaml
oap:
  env:
    SW_CORE_GRPC_SSL_ENABLED: "true"
    SW_CORE_GRPC_SSL_KEY_PATH: /certs/server.key
    SW_CORE_GRPC_SSL_CERT_CHAIN_PATH: /certs/server.crt
    SW_CORE_GRPC_SSL_TRUSTED_CA_PATH: /certs/ca.crt  # For mTLS
```

For mTLS (mutual TLS), enable the sharing server:

```yaml
oap:
  env:
    SW_RECEIVER_GRPC_PORT: 11801  # Separate port for mTLS
    SW_RECEIVER_GRPC_SSL_ENABLED: "true"
    SW_RECEIVER_GRPC_SSL_KEY_PATH: /certs/server.key
    SW_RECEIVER_GRPC_SSL_CERT_CHAIN_PATH: /certs/server.crt
    SW_RECEIVER_GRPC_SSL_TRUSTED_CA_PATH: /certs/ca.crt
```

### Self-Observability (OAP Telemetry)

Monitor the OAP cluster itself using Prometheus metrics:

```yaml
oap:
  env:
    SW_TELEMETRY: prometheus
    SW_TELEMETRY_PROMETHEUS_HOST: 0.0.0.0
    SW_TELEMETRY_PROMETHEUS_PORT: 1234
```

Scrape endpoint: `http://oap:1234/metrics`

Use OpenTelemetry Collector to send OAP metrics back to SkyWalking for self-monitoring dashboards.

### Service Auto Grouping

Services are automatically grouped using the naming format:

```
${service name} = [${group name}::]${logic name}
```

Example: `payment-team::order-service` groups under `payment-team`.

### Health Check & Circuit Breaking

```yaml
oap:
  env:
    SW_HEALTH_CHECKER: default
    # Circuit breaking when storage is unhealthy
    SW_CORE_ENABLE_CIRCUIT_BREAKING: "true"
```

Health endpoint: `http://oap:12800/healthcheck`

> 📖 **Deep Dive**: [Backend Setup](https://skywalking.apache.org/docs/main/next/en/setup/backend/backend-setup/) | [gRPC Security](https://skywalking.apache.org/docs/main/next/en/setup/backend/grpc-security/) | [Kafka Fetcher](https://skywalking.apache.org/docs/main/next/en/setup/backend/kafka-fetcher/) | [Backend Telemetry](https://skywalking.apache.org/docs/main/next/en/setup/backend/backend-telemetry/)

---

## Enabling Monitoring Features (Marketplace)

SkyWalking's Marketplace provides out-of-box monitoring for databases, message queues, and infrastructure. Most features require an **OpenTelemetry Collector** to scrape metrics from exporters and send them to OAP.

### How It Works

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│    Exporter     │────▶│  OpenTelemetry  │────▶│  SkyWalking     │
│ (mysqld, redis) │     │    Collector    │     │      OAP        │
└─────────────────┘     └─────────────────┘     └─────────────────┘
        │                       │                       │
   Prometheus              Prometheus              OTLP gRPC
    metrics                 Receiver                Exporter
```

### General Setup Pattern

1. **Deploy the exporter** for your technology (e.g., mysqld_exporter, redis_exporter)
2. **Configure OpenTelemetry Collector** to scrape the exporter
3. **Enable OAP's OpenTelemetry receiver** (enabled by default)
4. **Dashboards appear automatically** in UI when data is detected

### Enable OpenTelemetry Receiver (OAP)

```yaml
oap:
  env:
    SW_OTEL_RECEIVER: default
    SW_OTEL_RECEIVER_ENABLED_HANDLERS: "otlp-metrics"
```

### OpenTelemetry Collector Configuration Template

```yaml
# otel-collector-config.yaml
receivers:
  prometheus:
    config:
      scrape_configs:
        - job_name: 'mysql'
          scrape_interval: 30s
          static_configs:
            - targets: ['mysqld-exporter:9104']
          relabel_configs:
            - source_labels: [__address__]
              target_label: service_instance_id
              regex: '(.+):.*'
              replacement: '$1'

processors:
  batch:
    timeout: 10s

exporters:
  otlp:
    endpoint: skywalking-oap:11800
    tls:
      insecure: true

service:
  pipelines:
    metrics:
      receivers: [prometheus]
      processors: [batch]
      exporters: [otlp]
```

### Database Monitoring

| Database          | Exporter                                    | OAP Layer     | Setup Guide                                                                                                           |
| ----------------- | ------------------------------------------- | ------------- | --------------------------------------------------------------------------------------------------------------------- |
| **MySQL**         | prometheus/mysqld_exporter                  | MYSQL         | [MySQL Monitoring](https://skywalking.apache.org/docs/main/next/en/setup/backend/backend-mysql-monitoring/)           |
| **PostgreSQL**    | prometheus/postgres_exporter                | POSTGRESQL    | [PostgreSQL Monitoring](https://skywalking.apache.org/docs/main/next/en/setup/backend/backend-postgresql-monitoring/) |
| **Redis**         | oliver006/redis_exporter                    | REDIS         | [Redis Monitoring](https://skywalking.apache.org/docs/main/next/en/setup/backend/backend-redis-monitoring/)           |
| **MongoDB**       | percona/mongodb_exporter                    | MONGODB       | [MongoDB Monitoring](https://skywalking.apache.org/docs/main/next/en/setup/backend/backend-mongodb-monitoring/)       |
| **Elasticsearch** | prometheus-community/elasticsearch_exporter | ELASTICSEARCH | [ES Monitoring](https://skywalking.apache.org/docs/main/next/en/setup/backend/backend-elasticsearch-monitoring/)      |

#### MySQL Example

```bash
# 1. Deploy mysqld_exporter
docker run -d --name mysqld-exporter \
  -e DATA_SOURCE_NAME="exporter:password@(mysql:3306)/" \
  -p 9104:9104 \
  prom/mysqld-exporter

# 2. Add to OTel Collector scrape config
# job_name: 'mysql'
# targets: ['mysqld-exporter:9104']

# 3. MySQL dashboard appears in UI under "MySQL" menu
```

### Message Queue Monitoring

| MQ           | Exporter/Method          | OAP Layer | Setup Guide                                                                                                       |
| ------------ | ------------------------ | --------- | ----------------------------------------------------------------------------------------------------------------- |
| **Kafka**    | danielqsj/kafka_exporter | KAFKA     | [Kafka Monitoring](https://skywalking.apache.org/docs/main/next/en/setup/backend/backend-kafka-monitoring/)       |
| **RabbitMQ** | kbudde/rabbitmq_exporter | RABBITMQ  | [RabbitMQ Monitoring](https://skywalking.apache.org/docs/main/next/en/setup/backend/backend-rabbitmq-monitoring/) |
| **Pulsar**   | Built-in Prometheus      | PULSAR    | [Pulsar Monitoring](https://skywalking.apache.org/docs/main/next/en/setup/backend/backend-pulsar-monitoring/)     |
| **RocketMQ** | apache/rocketmq-exporter | ROCKETMQ  | [RocketMQ Monitoring](https://skywalking.apache.org/docs/main/next/en/setup/backend/backend-rocketmq-monitoring/) |

### Gateway Monitoring

| Gateway    | Method                    | OAP Layer | Setup Guide                                                                                                   |
| ---------- | ------------------------- | --------- | ------------------------------------------------------------------------------------------------------------- |
| **Nginx**  | nginx-prometheus-exporter | NGINX     | [Nginx Monitoring](https://skywalking.apache.org/docs/main/next/en/setup/backend/backend-nginx-monitoring/)   |
| **APISIX** | Built-in Prometheus       | APISIX    | [APISIX Monitoring](https://skywalking.apache.org/docs/main/next/en/setup/backend/backend-apisix-monitoring/) |

### Slow Query Collection (Optional)

For databases, you can also collect slow queries using Fluent Bit:

```
MySQL/Redis → Slow Log File → Fluent Bit → SkyWalking OAP (LAL)
```

This enables the "Slow Statements" panel in database dashboards.

### Customizing Dashboards

Each monitoring feature has customizable rules:

| Component | Metrics Rules Location      | Dashboard Location                        |
| --------- | --------------------------- | ----------------------------------------- |
| MySQL     | `/config/otel-rules/mysql/` | `/config/ui-initialized-templates/mysql/` |
| Redis     | `/config/otel-rules/redis/` | `/config/ui-initialized-templates/redis/` |
| Kafka     | `/config/otel-rules/kafka/` | `/config/ui-initialized-templates/kafka/` |

> 📖 **Deep Dive**: [Marketplace Overview](https://skywalking.apache.org/docs/main/next/en/setup/backend/marketplace/)

---

## Language Agents Overview

SkyWalking provides native agents for multiple languages with varying instrumentation approaches:

| Language      | Auto-Instrument  | Manual SDK | Maintained By      |
| ------------- | ---------------- | ---------- | ------------------ |
| **Java**      | ✅ (bytecode)     | ✅          | Apache SkyWalking  |
| **Python**    | ✅ (monkey-patch) | ✅          | Apache SkyWalking  |
| **Go**        | ✅ (compile-time) | ✅          | Apache SkyWalking  |
| **Node.js**   | ✅                | ✅          | Apache SkyWalking  |
| **PHP**       | ✅ (extension)    | ✅          | Apache SkyWalking  |
| **Rust**      | ❌                | ✅          | Apache SkyWalking  |
| **Lua/Nginx** | ❌                | ✅          | Apache SkyWalking  |
| **Kong**      | ❌                | ✅          | Apache SkyWalking  |
| **Ruby**      | ✅                | ✅          | Apache SkyWalking  |
| **.NET Core** | ✅                | ✅          | SkyAPM (3rd party) |
| **C++**       | ❌                | ✅          | SkyAPM (3rd party) |

---

## Java Agent Instrumentation

### Manual Agent Setup

#### Download Agent

```bash
# Download SkyWalking Java Agent
curl -L https://archive.apache.org/dist/skywalking/java-agent/9.3.0/apache-skywalking-java-agent-9.3.0.tgz | tar xz
```

#### Agent Directory Structure

```
skywalking-agent/
├── skywalking-agent.jar          # Main agent JAR
├── config/
│   └── agent.config              # Configuration file
├── plugins/                      # Auto-enabled plugins
├── optional-plugins/             # Manually enabled plugins
├── bootstrap-plugins/            # Bootstrap classloader plugins
└── logs/                         # Agent logs
```

#### Configuration (agent.config)

```properties
# Service identification
agent.service_name=${SW_AGENT_NAME:my-java-service}
agent.namespace=${SW_AGENT_NAMESPACE:default}
agent.instance_name=${SW_AGENT_INSTANCE_NAME:}

# OAP server connection
collector.backend_service=${SW_AGENT_COLLECTOR_BACKEND_SERVICES:skywalking-oap.skywalking:11800}

# Sampling (1.0 = 100%)
agent.sample_n_per_3_secs=${SW_AGENT_SAMPLE:-1}

# Logging
logging.level=${SW_LOGGING_LEVEL:INFO}
logging.dir=${SW_LOGGING_DIR:}
logging.file_name=${SW_LOGGING_FILE_NAME:skywalking-api.log}

# Trace ignore paths
trace.ignore_path=${SW_TRACE_IGNORE_PATH:/health,/ready,/metrics}
```

#### Run Application with Agent

```bash
# Using JVM argument
java -javaagent:/path/to/skywalking-agent/skywalking-agent.jar \
     -Dskywalking.agent.service_name=my-service \
     -Dskywalking.collector.backend_service=skywalking-oap:11800 \
     -jar my-application.jar

# Using environment variables
export SW_AGENT_NAME=my-service
export SW_AGENT_COLLECTOR_BACKEND_SERVICES=skywalking-oap:11800
java -javaagent:/path/to/skywalking-agent/skywalking-agent.jar -jar my-application.jar
```

#### Dockerfile Example

```dockerfile
FROM eclipse-temurin:17-jre

# Download SkyWalking agent
RUN curl -L https://archive.apache.org/dist/skywalking/java-agent/9.3.0/apache-skywalking-java-agent-9.3.0.tgz | tar xz -C /opt

# Copy application
COPY target/my-app.jar /app/my-app.jar

# Set agent path
ENV JAVA_TOOL_OPTIONS="-javaagent:/opt/skywalking-agent/skywalking-agent.jar"
ENV SW_AGENT_NAME=my-java-service
ENV SW_AGENT_COLLECTOR_BACKEND_SERVICES=skywalking-oap.skywalking:11800

ENTRYPOINT ["java", "-jar", "/app/my-app.jar"]
```

### Supported Frameworks (Auto-Instrumentation)

| Category           | Frameworks                                               |
| ------------------ | -------------------------------------------------------- |
| **HTTP Servers**   | Tomcat, Jetty, Undertow, Spring MVC, Spring WebFlux      |
| **HTTP Clients**   | HttpClient, OkHttp, RestTemplate, WebClient, Feign       |
| **Databases**      | MySQL, PostgreSQL, Oracle, MongoDB, Redis, Elasticsearch |
| **Message Queues** | Kafka, RabbitMQ, RocketMQ, Pulsar, ActiveMQ              |
| **RPC**            | gRPC, Dubbo, Motan, SOFARPC                              |
| **Cache**          | Jedis, Lettuce, Redisson, Ehcache                        |
| **Frameworks**     | Spring Boot, Quarkus, Micronaut, Vert.x                  |

---

## Python Agent Instrumentation

### Installation

```bash
pip install apache-skywalking
```

### Basic Usage

```python
# main.py
from skywalking import agent, config

# Configure agent
config.init(
    agent_collector_backend_services='skywalking-oap.skywalking:11800',
    agent_name='my-python-service',
    agent_instance_name='instance-1'
)

# Start agent
agent.start()

# Your application code
from flask import Flask
app = Flask(__name__)

@app.route('/')
def hello():
    return 'Hello, World!'

if __name__ == '__main__':
    app.run()
```

### Environment Variable Configuration

```bash
export SW_AGENT_NAME=my-python-service
export SW_AGENT_COLLECTOR_BACKEND_SERVICES=skywalking-oap.skywalking:11800
export SW_AGENT_LOGGING_LEVEL=INFO

python main.py
```

### Capabilities Matrix

| Feature       | Status    | Details                           |
| ------------- | --------- | --------------------------------- |
| **Tracing**   | ✅ ON      | Auto-instrumentation + Manual SDK |
| **Logging**   | ✅ ON      | Direct reporter                   |
| **Metrics**   | ✅ ON      | Meter API + PVM metrics           |
| **Profiling** | ✅ ON      | Threading and Greenlet            |
| **Events**    | ❌ Planned | Lifecycle events                  |

### Supported Libraries

```python
# Auto-instrumented libraries
# HTTP Frameworks
- Flask
- Django
- FastAPI
- AIOHTTP
- Tornado
- Sanic

# Databases
- PyMySQL
- psycopg2
- pymongo
- redis-py
- elasticsearch-py

# HTTP Clients
- requests
- httpx
- aiohttp client

# Message Queues
- kafka-python
- pika (RabbitMQ)
- celery

# RPC
- grpcio
```

### Manual Instrumentation

```python
from skywalking.decorators import trace, runnable
from skywalking.trace.context import get_context

# Decorator-based tracing
@trace(operation_name='custom_operation')
def my_function():
    # Get current span
    context = get_context()
    span = context.active_span

    # Add tags
    span.tag('custom.key', 'custom.value')

    # Add log
    span.log({'event': 'processing', 'message': 'Started processing'})

    return 'result'

# Async support
@trace(operation_name='async_operation')
async def my_async_function():
    await some_async_call()
```

---

## Go Agent Instrumentation

Go agent uses compile-time instrumentation.

### Installation

```bash
# Install the Go agent toolkit
go install github.com/apache/skywalking-go/tools/go-agent@latest
```

### Usage

```go
// main.go
package main

import (
    "net/http"

    _ "github.com/apache/skywalking-go"
)

func main() {
    http.HandleFunc("/", handler)
    http.ListenAndServe(":8080", nil)
}

func handler(w http.ResponseWriter, r *http.Request) {
    w.Write([]byte("Hello, World!"))
}
```

### Build with Agent

```bash
# Build with SkyWalking instrumentation
go-agent -inject ./...

# Or use go build with toolexec
go build -toolexec "go-agent" -o myapp .
```

### Configuration

```bash
export SW_AGENT_NAME=my-go-service
export SW_AGENT_REPORTER_GRPC_BACKEND_SERVICE=skywalking-oap:11800
```

### Supported Frameworks

- **HTTP**: net/http, Gin, Echo, Fiber
- **Database**: database/sql, GORM
- **Cache**: go-redis
- **RPC**: gRPC
- **Message Queue**: Kafka (segmentio)

---

## Node.js Agent Instrumentation

### Installation

```bash
npm install skywalking-backend-js
```

### Usage

```javascript
// Must be first import
require('skywalking-backend-js').default.start({
  serviceName: 'my-nodejs-service',
  serviceInstance: 'instance-1',
  collectorAddress: 'skywalking-oap.skywalking:11800',
});

// Your application code
const express = require('express');
const app = express();

app.get('/', (req, res) => {
  res.send('Hello World!');
});

app.listen(3000);
```

### Environment Variables

```bash
export SW_AGENT_NAME=my-nodejs-service
export SW_AGENT_COLLECTOR_BACKEND_SERVICES=skywalking-oap:11800
```

### Supported Frameworks

- **HTTP**: Express, Koa, Hapi, Egg.js
- **Database**: MySQL, PostgreSQL, MongoDB
- **Cache**: Redis (ioredis)
- **Message Queue**: Kafka, RabbitMQ

---

## PHP Agent Instrumentation

PHP agent uses a C extension for auto-instrumentation.

### Installation

```bash
# Install via PECL
pecl install skywalking_agent

# Or compile from source
git clone https://github.com/apache/skywalking-php.git
cd skywalking-php
phpize
./configure
make
make install
```

### Configuration (php.ini)

```ini
extension=skywalking_agent.so

skywalking_agent.enable=1
skywalking_agent.service_name=my-php-service
skywalking_agent.server_addr=skywalking-oap.skywalking:11800
skywalking_agent.log_level=INFO
```

### Supported Frameworks

- **HTTP**: Laravel, Symfony, Yii, ThinkPHP
- **Database**: PDO (MySQL, PostgreSQL)
- **Cache**: Redis, Memcached
- **RPC**: gRPC, cURL

---

## Lua/Nginx Agent

For Nginx with Lua module or OpenResty.

### Installation

```bash
# Clone the agent
git clone https://github.com/apache/skywalking-nginx-lua.git

# Add to nginx.conf
lua_package_path "/path/to/skywalking-nginx-lua/lib/?.lua;;";
```

### Configuration (nginx.conf)

```nginx
http {
    lua_shared_dict tracing_buffer 100m;

    init_worker_by_lua_block {
        local skywalking = require('skywalking.tracer')
        skywalking.start_backend_timer{
            backend = 'skywalking-oap.skywalking:11800',
            service_name = 'my-nginx-service',
        }
    }

    server {
        location / {
            rewrite_by_lua_block {
                require('skywalking.tracer'):start()
            }

            proxy_pass http://backend;

            body_filter_by_lua_block {
                require('skywalking.tracer'):finish()
            }
        }
    }
}
```

---

## SWCK - SkyWalking Cloud on Kubernetes

SWCK provides Kubernetes-native management for SkyWalking components.

### Components

1. **Operator** - Manages SkyWalking CRDs
2. **Adapter** - Kubernetes metrics adapter
3. **Java Agent Injector** - Automatic agent injection

### Install SWCK Operator

```bash
# Install cert-manager (required)
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.14.0/cert-manager.yaml

# Wait for cert-manager
kubectl wait --for=condition=Available deployment --all -n cert-manager --timeout=300s

# Install SWCK Operator
helm install swck-operator skywalking/skywalking-swck \
  --namespace skywalking-swck-system \
  --create-namespace
```

### Java Agent Injector

The injector automatically adds SkyWalking Java agent to pods.

#### Enable Injection

```yaml
# Add label to namespace
apiVersion: v1
kind: Namespace
metadata:
  name: my-app
  labels:
    swck-injection: enabled
```

#### Configure Injection

```yaml
# JavaAgent CRD
apiVersion: operator.skywalking.apache.org/v1alpha1
kind: JavaAgent
metadata:
  name: my-java-agent
  namespace: my-app
spec:
  # Pod selector
  podSelector:
    matchLabels:
      app: my-java-app

  # Agent configuration
  serviceName: my-java-service
  backendService: skywalking-oap.skywalking:11800

  # Agent image
  agentImage: apache/skywalking-java-agent:9.3.0-java17

  # Optional: custom configuration
  agentConfiguration:
    agent.sample_n_per_3_secs: "10"
    trace.ignore_path: "/health,/ready"
```

#### Deployment Example

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-java-app
  namespace: my-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: my-java-app
  template:
    metadata:
      labels:
        app: my-java-app
      annotations:
        # Enable injection for this pod
        sidecar.skywalking.apache.org/inject: "true"
    spec:
      containers:
      - name: app
        image: my-java-app:latest
        ports:
        - containerPort: 8080
```

### OAP Server CRD

```yaml
apiVersion: operator.skywalking.apache.org/v1alpha1
kind: OAPServer
metadata:
  name: skywalking-oap
  namespace: skywalking
spec:
  version: "10.3.0"
  instances: 2
  image: apache/skywalking-oap-server:10.3.0
  storage:
    type: banyandb
    banyandb:
      host: banyandb.skywalking
      port: 17912
```

### UI CRD

```yaml
apiVersion: operator.skywalking.apache.org/v1alpha1
kind: UI
metadata:
  name: skywalking-ui
  namespace: skywalking
spec:
  version: "10.3.0"
  instances: 2
  image: apache/skywalking-ui:10.3.0
  OAPServerAddress: http://skywalking-oap:12800
```

---

## SkyWalking Satellite

Satellite is a lightweight sidecar/proxy designed for edge data collection and load balancing in high-traffic environments.

### Primary Use Cases

| Use Case                 | Description                                                                                                    |
| ------------------------ | -------------------------------------------------------------------------------------------------------------- |
| **Edge/Sidecar Proxy**   | Sits close to application pods, receives traces/logs from agents, batches and forwards to OAP                  |
| **Load Balancing**       | Distributes telemetry load across multiple OAP instances                                                       |
| **Buffering**            | Buffers data when OAP is temporarily unavailable, prevents data loss during OAP restarts/upgrades              |
| **Protocol Translation** | Accepts gRPC from agents, can forward via gRPC or Kafka to OAP                                                 |
| **Connection Reduction** | In large clusters, pods connect to local Satellite instead of directly to OAP, reducing long-lived connections |

### What Satellite Does NOT Do

> **Important**: Satellite is NOT a replacement for OpenTelemetry Collector for infrastructure monitoring.

| ❌ Cannot Do                               | Use Instead                         |
| ----------------------------------------- | ----------------------------------- |
| Scrape Prometheus metrics                 | OpenTelemetry Collector             |
| Collect Kubernetes infrastructure metrics | OTel Collector + kube-state-metrics |
| Replace node-exporter for VM monitoring   | OTel Collector + node-exporter      |
| Process cAdvisor container metrics        | OTel Collector                      |

### When to Use Satellite

| Scenario                                                | Use Satellite?            |
| ------------------------------------------------------- | ------------------------- |
| Large cluster with many instrumented apps (>100 agents) | ✅ Yes                     |
| Need buffering during OAP maintenance windows           | ✅ Yes                     |
| Want Kafka as buffer between agents and OAP             | ✅ Yes                     |
| Kubernetes infrastructure monitoring                    | ❌ No (use OTel Collector) |
| Small cluster / dev environment                         | ❌ Overkill                |
| VM/host metrics collection                              | ❌ No (use OTel Collector) |

### Architecture Comparison

```
Without Satellite:
┌─────────┐     ┌─────────┐
│ Agent 1 │────▶│  OAP 1  │  (Unbalanced load)
└─────────┘     └─────────┘
┌─────────┐     ┌─────────┐
│ Agent 2 │────▶│  OAP 1  │
└─────────┘     └─────────┘
┌─────────┐     ┌─────────┐
│ Agent 3 │────▶│  OAP 2  │  (Underutilized)
└─────────┘     └─────────┘

With Satellite:
┌─────────┐     ┌───────────┐     ┌─────────┐
│ Agent 1 │────▶│           │────▶│  OAP 1  │
└─────────┘     │           │     └─────────┘
┌─────────┐     │ Satellite │     ┌─────────┐
│ Agent 2 │────▶│   (LB)    │────▶│  OAP 2  │
└─────────┘     │           │     └─────────┘
┌─────────┐     │           │     ┌─────────┐
│ Agent 3 │────▶│           │────▶│  OAP 3  │
└─────────┘     └───────────┘     └─────────┘

For K8s Infrastructure Monitoring (Satellite NOT used):
┌─────────────────────┐
│  kube-state-metrics │─┐
└─────────────────────┘ │
┌─────────────────────┐ │     ┌─────────────────┐     ┌─────────┐
│      cAdvisor       │─┼────▶│  OTel Collector │────▶│   OAP   │
└─────────────────────┘ │     └─────────────────┘     └─────────┘
┌─────────────────────┐ │
│    node-exporter    │─┘
└─────────────────────┘
```

### Deploy Satellite

```yaml
# satellite-values.yaml
satellite:
  enabled: true
  image:
    tag: "1.2.0"
  replicas: 2
  resources:
    requests:
      cpu: "500m"
      memory: "512Mi"
  env:
    SATELLITE_GRPC_CLIENT_FINDER: static
    SATELLITE_GRPC_CLIENT_STATIC_SERVERS: skywalking-oap:11800
```

```bash
helm install ${SKYWALKING_RELEASE_NAME} skywalking/skywalking \
  --namespace ${SKYWALKING_RELEASE_NAMESPACE} \
  -f satellite-values.yaml
```

### Configure Agents to Use Satellite

```properties
# Java agent config
collector.backend_service=skywalking-satellite.skywalking:11800
```

```python
# Python agent config
config.init(
    agent_collector_backend_services='skywalking-satellite.skywalking:11800'
)
```

---

## Running the Showcase Demo

The SkyWalking Showcase is a complete demo application demonstrating all features.

### Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                     Showcase Application                         │
│                                                                  │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐ │
│  │    UI    │───▶│  APISIX  │───▶│   App    │───▶│ Gateway  │ │
│  │ (React)  │    │(Gateway) │    │(NodeJS)  │    │ (Spring) │ │
│  └──────────┘    └──────────┘    └──────────┘    └──────────┘ │
│                                         │              │        │
│                                         ▼              ▼        │
│                                  ┌──────────┐   ┌──────────┐   │
│                                  │  Songs   │   │  Rcmd    │   │
│                                  │ (Spring) │   │ (Python) │   │
│                                  └──────────┘   └──────────┘   │
│                                         │              │        │
│                                         ▼              ▼        │
│                                  ┌──────────┐   ┌──────────┐   │
│                                  │    H2    │   │  Rating  │   │
│                                  │   (DB)   │   │   (Go)   │   │
│                                  └──────────┘   └──────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

### Quick Start

```bash
# Clone showcase repository
git clone https://github.com/apache/skywalking-showcase.git
cd skywalking-showcase

# Deploy with default features (BanyanDB, agents, cluster mode)
make deploy.kubernetes

# Wait for pods (may take 10+ minutes for image pulls)
kubectl get pods -n skywalking-showcase -w
```

### Feature Flags

Customize deployment with feature flags:

```bash
# Single node with agents only
make deploy.kubernetes FEATURE_FLAGS=single-node,agent,banyandb

# With Elasticsearch storage
make deploy.kubernetes FEATURE_FLAGS=single-node,agent,elasticsearch

# With Satellite load balancer
make deploy.kubernetes FEATURE_FLAGS=cluster,agent,banyandb,satellite

# With Rover (eBPF profiling)
make deploy.kubernetes FEATURE_FLAGS=cluster,agent,banyandb,rover

# With service mesh (Istio)
make deploy.kubernetes FEATURE_FLAGS=cluster,als,banyandb
```

### Available Feature Flags

| Flag                  | Description                    |
| --------------------- | ------------------------------ |
| `single-node`         | Single OAP instance            |
| `cluster`             | OAP cluster mode (2 nodes)     |
| `agent`               | Deploy with SkyWalking agents  |
| `java-agent-injector` | Use SWCK for agent injection   |
| `banyandb`            | BanyanDB storage (default)     |
| `elasticsearch`       | Elasticsearch storage          |
| `postgresql`          | PostgreSQL storage             |
| `satellite`           | Deploy Satellite load balancer |
| `rover`               | Deploy Rover (eBPF profiler)   |
| `als`                 | Istio Access Log Service       |
| `vm-monitor`          | Virtual machine monitoring     |
| `kubernetes-monitor`  | K8s cluster monitoring         |
| `mysql-monitor`       | MySQL monitoring               |
| `grafana`             | Deploy Grafana with plugins    |

### Access the Demo

```bash
# Port-forward UI
kubectl port-forward svc/ui 8080:80 -n skywalking-showcase

# Port-forward SkyWalking UI
kubectl port-forward svc/skywalking-ui 9090:80 -n skywalking-showcase

# Generate traffic
kubectl port-forward svc/loadgen 8081:80 -n skywalking-showcase
```

### Cleanup

```bash
make undeploy.kubernetes
```

---

## Troubleshooting

### Common Issues

#### OAP Not Starting

```bash
# Check logs
kubectl logs -f deployment/skywalking-oap -n skywalking

# Common causes:
# - Storage not ready
# - Insufficient resources
# - Configuration errors
```

#### Agent Not Connecting

```bash
# Verify OAP service
kubectl get svc -n skywalking

# Test connectivity from agent pod
kubectl exec -it <agent-pod> -- nc -zv skywalking-oap.skywalking 11800

# Check agent logs
kubectl logs <agent-pod> | grep -i skywalking
```

#### No Data in UI

1. Verify agent is sending data:
```bash
kubectl logs <agent-pod> | grep -i "segment"
```

2. Check OAP receiver:
```bash
kubectl logs deployment/skywalking-oap | grep -i "received"
```

3. Verify storage connection:
```bash
kubectl logs deployment/skywalking-oap | grep -i "storage"
```

### Debug Mode

```yaml
# Enable debug logging in OAP
oap:
  env:
    SW_LOGGING_LEVEL: DEBUG
```

```properties
# Enable debug in Java agent
logging.level=DEBUG
```

---

## Summary

In this post, we covered:

1. **Helm Deployment** - Single-node and cluster mode setup
2. **BanyanDB** - Standalone deployment and configuration
3. **Java Agent** - Manual setup and auto-instrumentation
4. **Python Agent** - Installation and configuration
5. **SWCK** - Kubernetes operator and agent injection
6. **Satellite** - Load balancing for high-traffic environments
7. **Showcase** - Running the complete demo application

In **Part 3**, we'll explore advanced monitoring capabilities including Kubernetes monitoring, eBPF profiling with Rover, service mesh integration, and database monitoring.

---

## References

### Deployment
- [SkyWalking Helm Chart](https://github.com/apache/skywalking-helm)
- [BanyanDB Helm Chart](https://github.com/apache/skywalking-banyandb-helm)
- [Backend Setup](https://skywalking.apache.org/docs/main/next/en/setup/backend/backend-setup/)
- [Backend Docker Setup](https://skywalking.apache.org/docs/main/next/en/setup/backend/backend-docker/)
- [Backend Kubernetes Setup](https://skywalking.apache.org/docs/main/next/en/setup/backend/backend-k8s/)
- [Advanced Deployment (Roles)](https://skywalking.apache.org/docs/main/next/en/setup/backend/advanced-deployment/)
- [Init Mode](https://skywalking.apache.org/docs/main/next/en/setup/backend/backend-init-mode/)

### Cluster & Configuration
- [Cluster Management](https://skywalking.apache.org/docs/main/next/en/setup/backend/backend-cluster/)
- [Configuration Vocabulary](https://skywalking.apache.org/docs/main/next/en/setup/backend/configuration-vocabulary/)
- [Setting Override](https://skywalking.apache.org/docs/main/next/en/setup/backend/backend-setting-override/)
- [Dynamic Configuration](https://skywalking.apache.org/docs/main/next/en/setup/backend/dynamic-config/)
- [Service Auto Grouping](https://skywalking.apache.org/docs/main/next/en/setup/backend/service-auto-grouping/)
- [Endpoint Grouping Rules](https://skywalking.apache.org/docs/main/next/en/setup/backend/endpoint-grouping-rules/)

### Storage
- [Backend Storage Overview](https://skywalking.apache.org/docs/main/next/en/setup/backend/backend-storage/)
- [BanyanDB Storage](https://skywalking.apache.org/docs/main/next/en/setup/backend/storages/banyandb/)
- [Elasticsearch Storage](https://skywalking.apache.org/docs/main/next/en/setup/backend/storages/elasticsearch/)
- [MySQL Storage](https://skywalking.apache.org/docs/main/next/en/setup/backend/storages/mysql/)
- [PostgreSQL Storage](https://skywalking.apache.org/docs/main/next/en/setup/backend/storages/postgresql/)
- [TTL Configuration](https://skywalking.apache.org/docs/main/next/en/setup/backend/ttl/)

### Security & Operations
- [gRPC Security (TLS/mTLS)](https://skywalking.apache.org/docs/main/next/en/setup/backend/grpc-security/)
- [Backend Load Balancer](https://skywalking.apache.org/docs/main/next/en/setup/backend/backend-load-balancer/)
- [Backend Telemetry (Self-Observability)](https://skywalking.apache.org/docs/main/next/en/setup/backend/backend-telemetry/)
- [Health Check](https://skywalking.apache.org/docs/main/next/en/setup/backend/backend-health-check/)
- [Circuit Breaking](https://skywalking.apache.org/docs/main/next/en/setup/backend/circuit-breaking/)
- [Kafka Fetcher](https://skywalking.apache.org/docs/main/next/en/setup/backend/kafka-fetcher/)
- [Dynamic Logging](https://skywalking.apache.org/docs/main/next/en/setup/backend/dynamical-logging/)

### Agents
- [Server Agents Overview](https://skywalking.apache.org/docs/main/next/en/setup/service-agent/server-agents/)
- [Agent Compatibility](https://skywalking.apache.org/docs/main/next/en/setup/service-agent/agent-compatibility/)
- [Virtual Database](https://skywalking.apache.org/docs/main/next/en/setup/service-agent/virtual-database/)
- [Virtual Cache](https://skywalking.apache.org/docs/main/next/en/setup/service-agent/virtual-cache/)
- [Virtual MQ](https://skywalking.apache.org/docs/main/next/en/setup/service-agent/virtual-mq/)
- [SkyWalking Java Agent](https://skywalking.apache.org/docs/skywalking-java/next/readme/)
- [SkyWalking Python Agent](https://skywalking.apache.org/docs/skywalking-python/next/readme/)
- [SkyWalking Go Agent](https://skywalking.apache.org/docs/skywalking-go/next/readme/)
- [SkyWalking Node.js Agent](https://skywalking.apache.org/docs/skywalking-nodejs/next/readme/)
- [SkyWalking PHP Agent](https://skywalking.apache.org/docs/skywalking-php/next/readme/)

### Kubernetes Tools
- [SWCK Documentation](https://skywalking.apache.org/docs/skywalking-swck/next/readme/)
- [SkyWalking Satellite](https://skywalking.apache.org/docs/skywalking-satellite/next/readme/)

### Marketplace Monitoring
- [Marketplace Overview](https://skywalking.apache.org/docs/main/next/en/setup/backend/marketplace/)
- [MySQL Monitoring](https://skywalking.apache.org/docs/main/next/en/setup/backend/backend-mysql-monitoring/)
- [PostgreSQL Monitoring](https://skywalking.apache.org/docs/main/next/en/setup/backend/backend-postgresql-monitoring/)
- [Redis Monitoring](https://skywalking.apache.org/docs/main/next/en/setup/backend/backend-redis-monitoring/)
- [MongoDB Monitoring](https://skywalking.apache.org/docs/main/next/en/setup/backend/backend-mongodb-monitoring/)
- [Elasticsearch Monitoring](https://skywalking.apache.org/docs/main/next/en/setup/backend/backend-elasticsearch-monitoring/)
- [ClickHouse Monitoring](https://skywalking.apache.org/docs/main/next/en/setup/backend/backend-clickhouse-monitoring/)
- [BookKeeper Monitoring](https://skywalking.apache.org/docs/main/next/en/setup/backend/backend-bookkeeper-monitoring/)
- [AWS DynamoDB Monitoring](https://skywalking.apache.org/docs/main/next/en/setup/backend/backend-aws-dynamodb-monitoring/)
- [Kafka Monitoring](https://skywalking.apache.org/docs/main/next/en/setup/backend/backend-kafka-monitoring/)
- [RabbitMQ Monitoring](https://skywalking.apache.org/docs/main/next/en/setup/backend/backend-rabbitmq-monitoring/)
- [Pulsar Monitoring](https://skywalking.apache.org/docs/main/next/en/setup/backend/backend-pulsar-monitoring/)
- [RocketMQ Monitoring](https://skywalking.apache.org/docs/main/next/en/setup/backend/backend-rocketmq-monitoring/)
- [ActiveMQ Monitoring](https://skywalking.apache.org/docs/main/next/en/setup/backend/backend-activemq-monitoring/)
- [Flink Monitoring](https://skywalking.apache.org/docs/main/next/en/setup/backend/backend-flink-monitoring/)
- [Nginx Monitoring](https://skywalking.apache.org/docs/main/next/en/setup/backend/backend-nginx-monitoring/)
- [APISIX Monitoring](https://skywalking.apache.org/docs/main/next/en/setup/backend/backend-apisix-monitoring/)
- [Kong Monitoring](https://skywalking.apache.org/docs/main/next/en/setup/backend/backend-kong-monitoring/)
- [AWS API Gateway Monitoring](https://skywalking.apache.org/docs/main/next/en/setup/backend/backend-aws-api-gateway-monitoring/)

### Browser Monitoring
- [Browser Agent](https://skywalking.apache.org/docs/main/next/en/setup/service-agent/browser-agent/)

### Demo
- [SkyWalking Showcase](https://skywalking.apache.org/docs/skywalking-showcase/next/readme/)

### Data Protocols (For Agent/Integration Developers)
- [Trace Data Protocol v3](https://skywalking.apache.org/docs/main/next/en/api/trace-data-protocol-v3/)
- [X-Process Propagation Headers v3](https://skywalking.apache.org/docs/main/next/en/api/x-process-propagation-headers-v3/)
- [X-Process Correlation Headers v1](https://skywalking.apache.org/docs/main/next/en/api/x-process-correlation-headers-v1/)
- [Meter Protocol](https://skywalking.apache.org/docs/main/next/en/api/meter/)
- [Browser Protocol](https://skywalking.apache.org/docs/main/next/en/api/browser-protocol/)
- [JVM Protocol](https://skywalking.apache.org/docs/main/next/en/api/jvm-protocol/)
- [Log Data Protocol](https://skywalking.apache.org/docs/main/next/en/api/log-data-protocol/)
- [Instance Properties Protocol](https://skywalking.apache.org/docs/main/next/en/api/instance-properties/)
- [Event Protocol](https://skywalking.apache.org/docs/main/next/en/api/event/)
- [Profiling Protocol](https://skywalking.apache.org/docs/main/next/en/api/profiling-protocol/)
