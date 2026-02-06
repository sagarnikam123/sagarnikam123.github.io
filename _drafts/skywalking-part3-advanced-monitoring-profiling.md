---
title: "Apache SkyWalking Part 3: Advanced Monitoring & eBPF Profiling for Platform Engineers"
description: "Deep dive into Kubernetes monitoring, eBPF-based profiling with Rover, service mesh integration, and infrastructure monitoring"
date: 2026-02-02
categories: [Observability, APM]
tags: [skywalking, kubernetes, ebpf, rover, istio, service-mesh, monitoring]
image:
  path: /assets/img/posts/skywalking-advanced.png
  alt: Apache SkyWalking Advanced Monitoring
---

## Introduction

In [Part 1](/posts/skywalking-part1-introduction-architecture/), we covered SkyWalking's architecture and core concepts. In [Part 2](/posts/skywalking-part2-deployment-instrumentation/), we deployed SkyWalking and instrumented applications.

Now we'll explore advanced capabilities that make SkyWalking a powerful platform for infrastructure teams:

- Kubernetes cluster monitoring
- Event correlation with metrics
- eBPF-based profiling (Rover)
- Service mesh integration (Istio)
- Database and infrastructure monitoring
- Custom analysis with OAL/MAL

---

## Virtual Machine (Linux) Monitoring

SkyWalking monitors Linux VMs using Prometheus node-exporter or InfluxDB Telegraf.

### Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                      Linux VM                                    │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │              Prometheus Node Exporter                    │   │
│  │                    OR                                    │   │
│  │              InfluxDB Telegraf                           │   │
│  └─────────────────────────┬───────────────────────────────┘   │
└─────────────────────────────┼───────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                 OpenTelemetry Collector                          │
│              (Prometheus Receiver → OTLP Exporter)               │
└─────────────────────────────┬───────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    SkyWalking OAP                                │
│                 (Layer: OS_LINUX)                                │
└─────────────────────────────────────────────────────────────────┘
```

### Option 1: Node Exporter + OpenTelemetry

#### Install Node Exporter on VM

```bash
# Download and install
wget https://github.com/prometheus/node_exporter/releases/download/v1.7.0/node_exporter-1.7.0.linux-amd64.tar.gz
tar xvfz node_exporter-1.7.0.linux-amd64.tar.gz
cd node_exporter-1.7.0.linux-amd64

# Run
./node_exporter --web.listen-address=":9100"
```

#### OpenTelemetry Collector Config

```yaml
# otel-collector-vm.yaml
receivers:
  prometheus:
    config:
      scrape_configs:
        - job_name: 'vm-monitoring'
          scrape_interval: 30s
          static_configs:
            - targets:
              - 'vm1.example.com:9100'
              - 'vm2.example.com:9100'
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
    endpoint: skywalking-oap.skywalking:11800
    tls:
      insecure: true

service:
  pipelines:
    metrics:
      receivers: [prometheus]
      processors: [batch]
      exporters: [otlp]
```

### Option 2: Telegraf

#### Telegraf Configuration

```toml
# telegraf.conf
[agent]
  interval = "30s"
  flush_interval = "30s"

# Input plugins
[[inputs.cpu]]
  percpu = true
  totalcpu = true

[[inputs.mem]]

[[inputs.system]]

[[inputs.disk]]
  ignore_fs = ["tmpfs", "devtmpfs"]

[[inputs.diskio]]

[[inputs.net]]

# Output to SkyWalking
[[outputs.http]]
  url = "http://skywalking-oap.skywalking:12800/v3/meter"
  method = "POST"
  data_format = "json"
```

### Supported VM Metrics

| Metric                              | Description          | Unit  |
| ----------------------------------- | -------------------- | ----- |
| `meter_vm_cpu_total_percentage`     | Total CPU usage      | %     |
| `meter_vm_cpu_average_used`         | Per-core CPU usage   | %     |
| `meter_vm_cpu_load1/5/15`           | CPU load averages    | -     |
| `meter_vm_memory_used`              | RAM usage            | MB    |
| `meter_vm_memory_swap_percentage`   | Swap usage           | %     |
| `meter_vm_filesystem_percentage`    | Disk usage per mount | %     |
| `meter_vm_disk_read/written`        | Disk I/O             | KB/s  |
| `meter_vm_network_receive/transmit` | Network I/O          | KB/s  |
| `meter_vm_tcp_curr_estab`           | TCP connections      | count |

### Enable in SkyWalking

```yaml
# OAP configuration
oap:
  env:
    SW_OTEL_RECEIVER: default
    SW_OTEL_RECEIVER_ENABLED_HANDLERS: "otlp-metrics"
```

---

## Kubernetes Cluster Monitoring

SkyWalking can monitor your entire Kubernetes cluster, not just applications.

### Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    Kubernetes Cluster                            │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                 OpenTelemetry Collector                    │  │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐       │  │
│  │  │  K8s API    │  │   cAdvisor  │  │  kube-state │       │  │
│  │  │  Receiver   │  │  Receiver   │  │  Receiver   │       │  │
│  │  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘       │  │
│  │         │                │                │               │  │
│  │         └────────────────┼────────────────┘               │  │
│  │                          ▼                                │  │
│  │                   OTLP Exporter                           │  │
│  └──────────────────────────┬───────────────────────────────┘  │
│                             │                                   │
│                             ▼                                   │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                    SkyWalking OAP                         │  │
│  │              (OTLP Receiver + K8s Analysis)               │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```


### Deploy OpenTelemetry Collector for K8s Metrics

```yaml
# otel-collector-k8s.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: otel-collector-config
  namespace: skywalking
data:
  config.yaml: |
    receivers:
      k8s_cluster:
        collection_interval: 30s
        node_conditions_to_report:
          - Ready
          - MemoryPressure
          - DiskPressure
        allocatable_types_to_report:
          - cpu
          - memory
          - storage

      kubeletstats:
        collection_interval: 30s
        auth_type: serviceAccount
        endpoint: "${K8S_NODE_NAME}:10250"
        insecure_skip_verify: true
        metric_groups:
          - node
          - pod
          - container

    processors:
      batch:
        timeout: 10s

      resource:
        attributes:
          - key: k8s.cluster.name
            value: my-cluster
            action: upsert

    exporters:
      otlp:
        endpoint: skywalking-oap.skywalking:11800
        tls:
          insecure: true

    service:
      pipelines:
        metrics:
          receivers: [k8s_cluster, kubeletstats]
          processors: [batch, resource]
          exporters: [otlp]
---
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: otel-collector
  namespace: skywalking
spec:
  selector:
    matchLabels:
      app: otel-collector
  template:
    metadata:
      labels:
        app: otel-collector
    spec:
      serviceAccountName: otel-collector
      containers:
      - name: collector
        image: otel/opentelemetry-collector-contrib:0.96.0
        args:
          - --config=/etc/otel/config.yaml
        env:
          - name: K8S_NODE_NAME
            valueFrom:
              fieldRef:
                fieldPath: spec.nodeName
        volumeMounts:
          - name: config
            mountPath: /etc/otel
      volumes:
        - name: config
          configMap:
            name: otel-collector-config
```

### Available Kubernetes Metrics

| Category      | Metrics                                             |
| ------------- | --------------------------------------------------- |
| **Node**      | CPU usage, memory usage, disk I/O, network I/O      |
| **Pod**       | CPU/memory requests vs limits, restart count, phase |
| **Container** | Resource utilization, throttling                    |
| **Cluster**   | Node count, pod count, deployment status            |

### SkyWalking K8s Dashboard

Once configured, SkyWalking provides:
- Node health overview
- Pod resource utilization
- Namespace-level aggregations
- Cluster capacity planning views

---

## Kubernetes Event Exporter

Correlate Kubernetes events with your metrics to understand cause and effect.

### Why Event Correlation?

```
Timeline:
─────────────────────────────────────────────────────────────────▶
     │                    │                    │
     ▼                    ▼                    ▼
  Pod OOMKilled      Latency Spike       Error Rate Up
     │                    │                    │
     └────────────────────┴────────────────────┘
                          │
                    Root Cause: Memory pressure
```

### Deploy Event Exporter

{% raw %}
```yaml
# event-exporter-config.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: skywalking-event-exporter-config
  namespace: skywalking
data:
  config.yaml: |
    filters:
      - reason: ""
        type: ""
        # Export all events, or filter specific ones:
        # - reason: "OOMKilled"
        # - reason: "FailedScheduling"
        # - type: "Warning"

    exporters:
      skywalking:
        address: skywalking-oap.skywalking:11800
        enableTLS: false
        # Map K8s objects to SkyWalking services
        template:
          source:
            service: "{{ .Service.Name }}"
            serviceInstance: "{{ .Pod.Name }}"
          message: "{{ .Event.Message }}"
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: skywalking-event-exporter
  namespace: skywalking
spec:
  replicas: 1
  selector:
    matchLabels:
      app: skywalking-event-exporter
  template:
    metadata:
      labels:
        app: skywalking-event-exporter
    spec:
      serviceAccountName: skywalking-event-exporter
      containers:
      - name: exporter
        image: apache/skywalking-kubernetes-event-exporter:1.0.0
        args:
          - start
          - -c
          - /etc/config/config.yaml
        volumeMounts:
          - name: config
            mountPath: /etc/config
      volumes:
        - name: config
          configMap:
            name: skywalking-event-exporter-config
```
{% endraw %}

### Event Types Captured

| Event Type  | Example                     | Use Case             |
| ----------- | --------------------------- | -------------------- |
| **Warning** | OOMKilled, FailedScheduling | Incident correlation |
| **Normal**  | Scheduled, Pulled, Started  | Deployment tracking  |
| **Custom**  | HPA scaling events          | Capacity analysis    |

### Viewing Events in SkyWalking

Events appear in:
- Service dashboard timeline
- Trace detail view
- Alarm correlation panel

---

## SkyWalking Rover - eBPF Profiling

Rover uses eBPF to profile applications without code changes or restarts.

### What is eBPF?

```
┌─────────────────────────────────────────────────────────────────┐
│                        User Space                                │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐             │
│  │    App 1    │  │    App 2    │  │    App 3    │             │
│  └─────────────┘  └─────────────┘  └─────────────┘             │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ System Calls
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                       Kernel Space                               │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                    eBPF Programs                         │   │
│  │  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐    │   │
│  │  │ kprobes │  │tracepoint│  │  XDP    │  │  TC     │    │   │
│  │  └─────────┘  └─────────┘  └─────────┘  └─────────┘    │   │
│  └─────────────────────────────────────────────────────────┘   │
│                              │                                   │
│                              ▼                                   │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                    eBPF Maps                             │   │
│  │              (Data shared with user space)               │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                     SkyWalking Rover                             │
│              (Reads eBPF maps, sends to OAP)                    │
└─────────────────────────────────────────────────────────────────┘
```


### Rover Capabilities

| Feature                  | Description                       |
| ------------------------ | --------------------------------- |
| **CPU Profiling**        | On-CPU and off-CPU analysis       |
| **Network Profiling**    | TCP/HTTP latency, retransmissions |
| **Process Discovery**    | Auto-detect processes in K8s      |
| **Continuous Profiling** | Always-on, low-overhead profiling |

### Deploy Rover

```yaml
# rover-values.yaml (for Helm)
rover:
  enabled: true
  image:
    tag: "0.7.0"
  resources:
    requests:
      cpu: "100m"
      memory: "256Mi"
  # Process discovery configuration
  processDiscovery:
    kubernetes:
      enabled: true
      namespaces:
        - default
        - my-app
      # Label selector for pods to profile
      selector:
        matchLabels:
          profiling: enabled
```

```bash
# Deploy with showcase
make deploy.kubernetes FEATURE_FLAGS=cluster,agent,banyandb,rover
```

### Standalone Rover Deployment

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: skywalking-rover
  namespace: skywalking
spec:
  selector:
    matchLabels:
      app: skywalking-rover
  template:
    metadata:
      labels:
        app: skywalking-rover
    spec:
      hostPID: true
      hostNetwork: true
      containers:
      - name: rover
        image: apache/skywalking-rover:0.7.0
        securityContext:
          privileged: true
        env:
          - name: ROVER_BACKEND_ADDR
            value: "skywalking-oap.skywalking:11800"
          - name: ROVER_PROCESS_DISCOVERY_KUBERNETES_ACTIVE
            value: "true"
          - name: ROVER_PROCESS_DISCOVERY_KUBERNETES_NAMESPACES
            value: "default,my-app"
        volumeMounts:
          - name: sys
            mountPath: /sys
            readOnly: true
          - name: proc
            mountPath: /host/proc
            readOnly: true
      volumes:
        - name: sys
          hostPath:
            path: /sys
        - name: proc
          hostPath:
            path: /proc
```

### Profiling Configuration

```yaml
# rover-config.yaml
core:
  backend:
    addr: skywalking-oap.skywalking:11800

process_discovery:
  kubernetes:
    active: true
    namespaces:
      - default
      - production
    # Only profile pods with this label
    selector:
      matchLabels:
        skywalking.apache.org/profiling: "true"

profiling:
  # On-CPU profiling
  oncpu:
    enabled: true
    period: 9ms

  # Off-CPU profiling (waiting time)
  offcpu:
    enabled: true

  # Network profiling
  network:
    enabled: true
    # Protocol analysis
    protocol_analyze:
      - http
      - mysql
      - redis
```

### Viewing Profiling Data

In SkyWalking UI:
1. Navigate to **Service** → **Profiling**
2. Select time range and process
3. View flame graphs for CPU analysis
4. Analyze network latency breakdown

### Use Cases

| Scenario        | Rover Feature               |
| --------------- | --------------------------- |
| High CPU usage  | On-CPU flame graph          |
| Slow responses  | Off-CPU analysis (I/O wait) |
| Network latency | TCP/HTTP profiling          |
| Memory issues   | Process memory tracking     |

---

## Service Mesh Integration (Istio)

SkyWalking can observe service mesh traffic without application agents.

### Access Log Service (ALS)

```
┌─────────────────────────────────────────────────────────────────┐
│                    Service Mesh (Istio)                          │
│                                                                  │
│  ┌─────────────┐         ┌─────────────┐         ┌───────────┐ │
│  │   Service   │◀───────▶│   Envoy     │◀───────▶│  Service  │ │
│  │      A      │         │   Sidecar   │         │     B     │ │
│  └─────────────┘         └──────┬──────┘         └───────────┘ │
│                                 │                               │
│                                 │ Access Logs                   │
│                                 ▼                               │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                    SkyWalking OAP                         │  │
│  │                   (ALS Receiver)                          │  │
│  │                                                           │  │
│  │  Extracts:                                                │  │
│  │  - Service topology                                       │  │
│  │  - Request metrics (latency, throughput, errors)         │  │
│  │  - TCP metrics                                            │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

### Enable ALS in Istio

```yaml
# istio-config.yaml
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
spec:
  meshConfig:
    enableEnvoyAccessLogService: true
    defaultConfig:
      envoyAccessLogService:
        address: skywalking-oap.skywalking:11800
```

### Configure SkyWalking for ALS

```yaml
# OAP configuration
oap:
  env:
    # Enable ALS receiver
    SW_ENVOY_METRIC_ALS_HTTP_ANALYSIS: "k8s-mesh"
    SW_ENVOY_METRIC_ALS_TCP_ANALYSIS: "k8s-mesh"

    # Kubernetes metadata enrichment
    SW_ENVOY_METRIC_ALS_K8S_NAMESPACE: "istio-system"
```

### Deploy with Showcase

```bash
# Deploy agentless services with Istio ALS
make deploy.kubernetes FEATURE_FLAGS=cluster,als,banyandb
```

### ALS vs Agent Comparison

| Aspect               | ALS (Agentless)    | Agent-based       |
| -------------------- | ------------------ | ----------------- |
| **Setup**            | Mesh config only   | Per-service agent |
| **Trace Depth**      | Service-to-service | Full span detail  |
| **Language Support** | Any (mesh handles) | Language-specific |
| **Overhead**         | Minimal            | Agent overhead    |
| **Best For**         | Topology, metrics  | Deep tracing      |

### Hybrid Approach

Combine ALS with agents for comprehensive observability:

```yaml
# Services with agents get full tracing
# Services without agents still appear in topology via ALS
FEATURE_FLAGS=cluster,agent,als,banyandb
```

---

## Database Monitoring

SkyWalking monitors various databases through OpenTelemetry.

### Supported Databases

| Database      | Metrics | Slow Queries | Logs |
| ------------- | ------- | ------------ | ---- |
| MySQL         | ✅       | ✅            | ✅    |
| PostgreSQL    | ✅       | ✅            | ✅    |
| MongoDB       | ✅       | ❌            | ❌    |
| Elasticsearch | ✅       | ❌            | ❌    |
| Redis         | ✅       | ❌            | ❌    |

### MySQL Monitoring Setup

```yaml
# otel-mysql-config.yaml
receivers:
  mysql:
    endpoint: mysql.database:3306
    username: ${MYSQL_USER}
    password: ${MYSQL_PASSWORD}
    collection_interval: 30s
    metrics:
      mysql.buffer_pool.pages:
        enabled: true
      mysql.commands:
        enabled: true
      mysql.handlers:
        enabled: true
      mysql.locks:
        enabled: true
      mysql.threads:
        enabled: true

exporters:
  otlp:
    endpoint: skywalking-oap.skywalking:11800
    tls:
      insecure: true

service:
  pipelines:
    metrics:
      receivers: [mysql]
      exporters: [otlp]
```

### MySQL Slow Query Logs

```yaml
# fluent-bit config for slow query logs
[INPUT]
    Name              tail
    Path              /var/log/mysql/slow.log
    Parser            mysql-slow
    Tag               mysql.slow

[OUTPUT]
    Name              skywalking
    Match             mysql.*
    Host              skywalking-oap.skywalking
    Port              12800
```


### PostgreSQL Monitoring

```yaml
receivers:
  postgresql:
    endpoint: postgres.database:5432
    username: ${PG_USER}
    password: ${PG_PASSWORD}
    databases:
      - mydb
    collection_interval: 30s

exporters:
  otlp:
    endpoint: skywalking-oap.skywalking:11800
    tls:
      insecure: true

service:
  pipelines:
    metrics:
      receivers: [postgresql]
      exporters: [otlp]
```

---

## Infrastructure Monitoring

### Message Queues

#### RabbitMQ

```yaml
receivers:
  rabbitmq:
    endpoint: http://rabbitmq.messaging:15672
    username: ${RABBITMQ_USER}
    password: ${RABBITMQ_PASSWORD}
    collection_interval: 30s

exporters:
  otlp:
    endpoint: skywalking-oap.skywalking:11800
```

#### Kafka (via JMX)

```yaml
receivers:
  jmx:
    jar_path: /opt/opentelemetry-jmx-metrics.jar
    endpoint: kafka.messaging:9999
    target_system: kafka
    collection_interval: 30s
```

#### RocketMQ / Pulsar / ActiveMQ

Similar OTel receiver configurations available for each.

### Web Servers

#### Nginx

```yaml
# nginx.conf - enable stub_status
server {
    location /nginx_status {
        stub_status on;
        allow 127.0.0.1;
        deny all;
    }
}
```

```yaml
# OTel collector config
receivers:
  nginx:
    endpoint: http://nginx.web:80/nginx_status
    collection_interval: 30s
```

#### APISIX

```yaml
receivers:
  prometheus:
    config:
      scrape_configs:
        - job_name: 'apisix'
          static_configs:
            - targets: ['apisix.gateway:9091']
```

### Stream Processing

#### Apache Flink

```yaml
receivers:
  prometheus:
    config:
      scrape_configs:
        - job_name: 'flink'
          static_configs:
            - targets: ['flink-jobmanager:9249']
```

---

## OpenTelemetry Receiver

SkyWalking's OpenTelemetry receiver ingests metrics from various sources via OTLP protocol.

### Enable OTel Receiver

```yaml
oap:
  env:
    SW_OTEL_RECEIVER: default
    SW_OTEL_RECEIVER_ENABLED_HANDLERS: "otlp-metrics,otlp-logs"
```

### Supported Data Sources via OTel

| Category               | Source                                        | Rule File                                           |
| ---------------------- | --------------------------------------------- | --------------------------------------------------- |
| **Infrastructure**     | Linux (node_exporter)                         | `otel-rules/vm.yaml`                                |
| **Infrastructure**     | Windows (windows_exporter)                    | `otel-rules/windows.yaml`                           |
| **Kubernetes**         | kube-state-metrics, cAdvisor                  | `otel-rules/k8s/*.yaml`                             |
| **Databases**          | MySQL, PostgreSQL, MongoDB, Redis, ClickHouse | `otel-rules/<db>/*.yaml`                            |
| **Message Queues**     | Kafka, RabbitMQ, RocketMQ                     | `otel-rules/<mq>/*.yaml`                            |
| **Gateways**           | APISIX                                        | `otel-rules/apisix.yaml`                            |
| **Search**             | Elasticsearch                                 | `otel-rules/elasticsearch/*.yaml`                   |
| **Stream**             | Flink                                         | `otel-rules/flink/*.yaml`                           |
| **Self-Observability** | SkyWalking OAP, BanyanDB                      | `otel-rules/oap.yaml`, `otel-rules/banyandb/*.yaml` |
| **Service Mesh**       | Istio Control Plane                           | `otel-rules/istio-controlplane.yaml`                |
| **AWS**                | EKS (Container Insights)                      | `otel-rules/aws-eks/*.yaml`                         |

### OTel Collector Configuration Pattern

```yaml
# otel-collector-config.yaml
receivers:
  prometheus:
    config:
      scrape_configs:
        - job_name: 'mysql'
          static_configs:
            - targets: ['mysql-exporter:9104']

processors:
  batch:
    timeout: 10s

exporters:
  otlp:
    endpoint: skywalking-oap.skywalking:11800
    tls:
      insecure: true

service:
  pipelines:
    metrics:
      receivers: [prometheus]
      processors: [batch]
      exporters: [otlp]
```

---

## AWS Cloud Monitoring

### AWS Firehose Receiver

SkyWalking can receive AWS CloudWatch metrics via Kinesis Data Firehose.

```
CloudWatch Metrics → Metric Stream (OTel format) → Kinesis Firehose → SkyWalking OAP
```

#### Supported AWS Services

| Service         | Metrics                          |
| --------------- | -------------------------------- |
| **S3**          | Bucket metrics, request metrics  |
| **DynamoDB**    | Table metrics, operation metrics |
| **API Gateway** | Request count, latency, errors   |
| **EKS**         | Cluster, node, service metrics   |

#### Enable Firehose Receiver

```yaml
oap:
  env:
    SW_RECEIVER_FIREHOSE: default
    # Optional: access key for authentication
    SW_RECEIVER_FIREHOSE_ACCESS_KEY: "your-access-key"
```

Firehose endpoint: `http://<oap-host>:12801/aws/firehose/metrics`

---

## Custom Analysis with OAL

Observability Analysis Language (OAL) lets you define custom metrics from traces.

### OAL Overview

OAL is a streaming analysis language that processes traces and service mesh traffic to generate metrics. It focuses on three primary scopes: Service, Service Instance, and Endpoint.

Key characteristics:
- **Compiled language** - OAL scripts generate Java code at OAP startup
- **Streaming processing** - Analyzes data in real-time as it arrives
- **Scope-based** - Metrics are grouped by service, instance, or endpoint
- **Extensible** - Custom aggregation functions can be added

### OAL Basics

```oal
// Define a custom metric
service_resp_time = from(Service.latency).longAvg();

// With conditions
service_error_rate = from(Service.*).filter(status == false).percent();

// Endpoint-level
endpoint_cpm = from(Endpoint.*).cpm();

// With tags
service_percentile = from(Service.latency).percentile(10);
```

### OAL Grammar

```oal
// Basic structure
METRICS_NAME = from(SCOPE.FIELD)
  [.filter(FIELD OP VALUE)]
  .FUNCTION([PARAMS])

// Disable built-in metrics
disable(METRICS_NAME);
```

### Available Aggregation Functions

| Function        | Description                     | Example                                              |
| --------------- | ------------------------------- | ---------------------------------------------------- |
| `longAvg()`     | Average of long values          | `from(Service.latency).longAvg()`                    |
| `doubleAvg()`   | Average of double values        | `from(ServiceInstanceJVMCPU.usePercent).doubleAvg()` |
| `count()`       | Count of occurrences            | `from(Service.*).count()`                            |
| `cpm()`         | Calls per minute                | `from(Endpoint.*).cpm()`                             |
| `percent()`     | Percentage matching condition   | `from(Endpoint.*).filter(status==true).percent()`    |
| `rate()`        | Ratio of two conditions         | `from(Service.*).rate(cond1, cond2)`                 |
| `percentile2()` | P50/P75/P90/P95/P99 percentiles | `from(Service.latency).percentile2(10)`              |
| `histogram()`   | Latency distribution heatmap    | `from(Service.latency).histogram(100, 20)`           |
| `apdex()`       | Apdex score calculation         | `from(Service.latency).apdex(name, status)`          |

### Filter Operators

| Operator       | Description             | Example                              |
| -------------- | ----------------------- | ------------------------------------ |
| `==`, `!=`     | Equality                | `status == true`                     |
| `>`, `<`, `>=` | Comparison              | `latency > 1000`                     |
| `in [...]`     | Collection membership   | `name in ("Endpoint1", "Endpoint2")` |
| `like`         | String pattern matching | `name like "serv%"`                  |
| `contain`      | Tag matching            | `tags contain "http.method:GET"`     |

### Custom OAL Rules

```yaml
# custom-oal.yaml
# Add to OAP configuration

# Track slow endpoints (>1s)
slow_endpoint_count = from(Endpoint.latency).filter(latency > 1000).count();

# Error rate by HTTP status
http_5xx_rate = from(Endpoint.*).filter(httpStatusCode >= 500).percent();

# Database call duration
db_call_duration = from(DatabaseAccess.latency).longAvg();
```

### Deploying Custom OAL

```yaml
# values.yaml
oap:
  config:
    oal:
      - |
        // Custom metrics
        slow_endpoint_count = from(Endpoint.latency).filter(latency > 1000).count();
        http_5xx_rate = from(Endpoint.*).filter(httpStatusCode >= 500).percent();
```

---

## Meter Analysis Language (MAL)

MAL processes meter data (Prometheus-style metrics) and transforms them into SkyWalking metrics.

### MAL Overview

MAL is designed for:
- Processing Prometheus metrics from exporters
- Transforming OpenTelemetry metrics
- Creating custom metrics from raw meter data

### MAL Example

```yaml
# mal-rules.yaml
expSuffix: instance(['service'], ['instance'], Layer.GENERAL)
metricPrefix: custom

# Define metrics from Prometheus data
metricsRules:
  - name: jvm_memory_used
    exp: jvm_memory_bytes_used

  - name: jvm_gc_time
    exp: rate(jvm_gc_collection_seconds_sum)

  - name: http_request_rate
    exp: rate(http_requests_total)
```

> 📖 **Deep Dive**: [MAL Documentation](https://skywalking.apache.org/docs/main/next/en/concepts-and-designs/mal/) | [Scope Definitions](https://skywalking.apache.org/docs/main/next/en/concepts-and-designs/scope-definitions/)

---

## Log Analysis Language (LAL)

LAL extracts metrics and context from logs.

### Log Collection Methods

SkyWalking supports multiple ways to collect logs:

| Method                 | Description                        | Use Case               |
| ---------------------- | ---------------------------------- | ---------------------- |
| **Agent Native**       | Agents send logs directly via gRPC | Java, Python, Go apps  |
| **File Collectors**    | Filebeat, Fluentd, Fluent-bit      | Existing log files     |
| **OpenTelemetry**      | OTLP log format                    | OTel-instrumented apps |
| **On-Demand Pod Logs** | Real-time K8s pod logs             | Debugging, experiments |

### Agent-Based Log Collection

Native agents can send logs with automatic trace context injection:

```yaml
# Java - log4j2.xml example
<Appenders>
  <GRPCLogClientAppender name="grpc-log">
    <PatternLayout pattern="%d{yyyy-MM-dd HH:mm:ss.SSS} [%t] %-5level %logger{36} - %msg%n"/>
  </GRPCLogClientAppender>
</Appenders>
```

Supported logging frameworks:
- **Java**: Log4j, Log4j2, Logback
- **Python**: logging module
- **Go**: Native log reporter

### File-Based Log Collection

```yaml
# Fluent-bit config - send to SkyWalking HTTP endpoint
[INPUT]
    Name              tail
    Path              /var/log/app/*.log
    Tag               app.logs

[OUTPUT]
    Name              http
    Match             *
    Host              skywalking-oap.skywalking
    Port              12800
    URI               /v3/logs
    Format            json
```

### OpenTelemetry Log Collection

```yaml
# OTel Collector config
receivers:
  otlp:
    protocols:
      grpc:
        endpoint: 0.0.0.0:4317

exporters:
  otlp:
    endpoint: skywalking-oap.skywalking:11800
    tls:
      insecure: true

service:
  pipelines:
    logs:
      receivers: [otlp]
      exporters: [otlp]
```

### On-Demand Pod Logs (Kubernetes)

Real-time log streaming from K8s pods without persistence:

```yaml
# Enable in OAP
oap:
  env:
    SW_CORE_ENABLE_ON_DEMAND_POD_LOG: "true"
```

Requirements:
- OAP needs RBAC permissions for pods/log
- Service instance must have `namespace` and `pod` properties

### LAL Configuration

```yaml
# lal-rules.yaml
rules:
  - name: error-log-extractor
    layer: GENERAL
    dsl: |
      filter {
        if (parsed.level == "ERROR") {
          tag("error", "true")

          // Extract error type
          extractor {
            if (parsed.message =~ /NullPointerException/) {
              tag("error.type", "NPE")
            }
          }

          // Create metric
          metrics {
            name "error_log_count"
            timestamp parsed.timestamp
            labels service, instance
            value 1
          }
        }
      }
```

---

## Alerting Configuration

SkyWalking's alerting system uses an in-memory, time-window based queue with rules defined in `alarm-settings.yml`.

### Alert Rule Structure

```yaml
rules:
  service_resp_time_rule:
    # MQE expression (must be a Compare Operation)
    expression: sum(service_resp_time > 1000) >= 3
    # Time window in minutes
    period: 10
    # Silence after trigger (default: same as period)
    silence-period: 10
    # Periods to wait before recovery notification
    recovery-observation-period: 2
    # Alert message ({name} is replaced with entity name)
    message: "Service {name} response time > 1000ms"
    # Optional: filter specific services
    include-names:
      - service_a
      - service_b
    exclude-names:
      - service_c
    # Searchable tags
    tags:
      level: WARNING
    # Specific hooks to trigger
    hooks:
      - "slack.custom1"
      - "pagerduty.default"
```

### Default Alert Rules

| Rule                   | Condition                | Period |
| ---------------------- | ------------------------ | ------ |
| Service response time  | > 1s avg                 | 3 min  |
| Service success rate   | < 80%                    | 2 min  |
| Service percentile     | P50/P75/P90/P95/P99 > 1s | 3 min  |
| Instance response time | > 1s avg                 | 2 min  |
| Endpoint response time | > 1s avg                 | 2 min  |
| Database response time | > 1s avg                 | 2 min  |

### Supported Hooks (Notification Channels)

| Hook Type     | Configuration               |
| ------------- | --------------------------- |
| **Webhook**   | Custom HTTP POST endpoint   |
| **gRPC**      | Remote gRPC method          |
| **Slack**     | Incoming Webhooks           |
| **Discord**   | Discord Webhooks            |
| **PagerDuty** | Events API v2               |
| **DingTalk**  | DingTalk Webhooks           |
| **WeChat**    | WeCom (Enterprise) Webhooks |
| **Feishu**    | Feishu Webhooks             |
| **WeLink**    | WeLink Webhooks             |

### Hook Configuration Example

```yaml
hooks:
  webhook:
    default:
      is-default: true
      urls:
        - "http://alertmanager.monitoring:9093/api/v1/alerts"

  slack:
    default:
      is-default: true
      text-template: "SkyWalking Alert: %s"
      webhooks:
        - "https://hooks.slack.com/services/xxx/yyy/zzz"

    custom1:
      is-default: false
      text-template: "Critical: %s"
      webhooks:
        - "https://hooks.slack.com/services/aaa/bbb/ccc"

  pagerduty:
    default:
      is-default: true
      text-template: "SkyWalking: %s"
      integration-keys:
        - "your-pagerduty-integration-key"
```

### Alert State Transitions

```
NORMAL → FIRING → SILENCED_FIRING → OBSERVING_RECOVERY → RECOVERED
   ↑                                                          │
   └──────────────────────────────────────────────────────────┘
```

| State                  | Description                                        |
| ---------------------- | -------------------------------------------------- |
| **NORMAL**             | No alert condition                                 |
| **FIRING**             | Alert triggered, notification sent                 |
| **SILENCED_FIRING**    | Alert active but in silence period                 |
| **OBSERVING_RECOVERY** | Condition false, waiting for recovery confirmation |
| **RECOVERED**          | Recovery notification sent                         |

### Advanced: Baseline-Based Alerts

Use AI-powered baseline predictions (v10.2.0+):

```yaml
rules:
  baseline_alert:
    # Compare with predicted baseline
    expression: sum(service_resp_time > baseline(service_resp_time)) >= 3
    period: 10
    message: "Service {name} response time exceeds predicted baseline"
```

### Dynamic Configuration

Alert rules can be updated at runtime via Dynamic Configuration without OAP restart.

### Supported Dynamic Configurations

| Config Key                                     | Description                      |
| ---------------------------------------------- | -------------------------------- |
| `alarm.default.alarm-settings`                 | Alert rules (alarm-settings.yml) |
| `agent-analyzer.default.slowDBAccessThreshold` | Slow DB query thresholds         |
| `core.default.apdexThreshold`                  | Apdex threshold per service      |
| `core.default.endpoint-name-grouping`          | Endpoint grouping rules          |
| `agent-analyzer.default.traceSamplingPolicy`   | Trace sampling configuration     |

Dynamic configuration requires a configuration center:
- **Zookeeper**
- **Etcd**
- **Consul**
- **Apollo**
- **Nacos**
- **Kubernetes ConfigMap**

> 📖 **Deep Dive**: [Dynamic Configuration](https://skywalking.apache.org/docs/main/next/en/setup/backend/dynamic-config/) | [Configuration Vocabulary](https://skywalking.apache.org/docs/main/next/en/setup/backend/configuration-vocabulary/)

---

## Production Best Practices

### Resource Planning

| Component     | Small          | Medium     | Large       |
| ------------- | -------------- | ---------- | ----------- |
| **OAP**       | 2 CPU, 4GB     | 4 CPU, 8GB | 8 CPU, 16GB |
| **BanyanDB**  | 2 CPU, 4GB     | 4 CPU, 8GB | 8 CPU, 32GB |
| **UI**        | 0.5 CPU, 512MB | 1 CPU, 1GB | 2 CPU, 2GB  |
| **Satellite** | 1 CPU, 1GB     | 2 CPU, 2GB | 4 CPU, 4GB  |

### Data Retention

```yaml
oap:
  env:
    # Trace data (high volume)
    SW_CORE_RECORD_DATA_TTL: 3

    # Metrics (lower volume)
    SW_CORE_METRICS_DATA_TTL: 7

    # Logs
    SW_CORE_LOG_DATA_TTL: 3
```

### High Availability

```yaml
# HA deployment
oap:
  replicas: 3

banyandb:
  cluster:
    liaison:
      replicas: 2
    data:
      replicas: 3

satellite:
  replicas: 2

ui:
  replicas: 2
```

### Sampling Strategy

```properties
# Java agent - sample 10% of traces
agent.sample_n_per_3_secs=100

# Or use adaptive sampling in OAP
SW_RECEIVER_TRACE_SAMPLE_RATE=1000  # per 10000
```

---

## Summary

In this series, we covered the complete Apache SkyWalking ecosystem:

**Part 1: Foundation**
- Architecture and core concepts
- Storage options (BanyanDB, Elasticsearch, PostgreSQL)
- Visualization (Booster UI, Grafana)
- CLI automation

**Part 2: Deployment**
- Helm-based Kubernetes deployment
- Java and Python agent instrumentation
- SWCK operator and agent injection
- Satellite load balancing
- Showcase demo

**Part 3: Advanced (This Post)**
- Kubernetes cluster monitoring
- Event correlation
- eBPF profiling with Rover
- Service mesh integration
- Database and infrastructure monitoring
- Custom analysis (OAL/MAL/LAL)
- Alerting and production best practices

SkyWalking provides a comprehensive, cloud-native observability platform that scales from simple tracing to full infrastructure monitoring.

---

## References

### Core Documentation
- [SkyWalking Official Documentation](https://skywalking.apache.org/docs/main/next/readme/)
- [Configuration Vocabulary](https://skywalking.apache.org/docs/main/next/en/setup/backend/configuration-vocabulary/)
- [Dynamic Configuration](https://skywalking.apache.org/docs/main/next/en/setup/backend/dynamic-config/)
- [Cluster Management](https://skywalking.apache.org/docs/main/next/en/setup/backend/backend-cluster/)

### Monitoring Setup
- [SkyWalking Rover Documentation](https://skywalking.apache.org/docs/skywalking-rover/next/readme/)
- [Kubernetes Event Exporter](https://github.com/apache/skywalking-kubernetes-event-exporter)
- [K8s Monitoring Setup](https://skywalking.apache.org/docs/main/next/en/setup/backend/backend-k8s-monitoring/)
- [K8s Monitoring with cAdvisor](https://skywalking.apache.org/docs/main/next/en/setup/backend/backend-k8s-monitoring-metrics-cadvisor/)
- [K8s Monitoring with Rover](https://skywalking.apache.org/docs/main/next/en/setup/backend/backend-k8s-monitoring-rover/)
- [K8s Network Monitoring](https://skywalking.apache.org/docs/main/next/en/setup/backend/backend-k8s-network-monitoring/)
- [K8s Monitoring with Cilium](https://skywalking.apache.org/docs/main/next/en/setup/backend/backend-k8s-monitoring-cilium/)
- [VM Monitoring Setup](https://skywalking.apache.org/docs/main/next/en/setup/backend/backend-vm-monitoring/)
- [Windows Monitoring Setup](https://skywalking.apache.org/docs/main/next/en/setup/backend/backend-win-monitoring/)

### Profiling
- [Java Application Profiling](https://skywalking.apache.org/docs/main/next/en/setup/backend/backend-java-app-profiling/)
- [Continuous Profiling](https://skywalking.apache.org/docs/main/next/en/setup/backend/backend-continuous-profiling/)
- [eBPF Profiling](https://skywalking.apache.org/docs/main/next/en/setup/backend/backend-ebpf-profiling/)
- [Trace Profiling](https://skywalking.apache.org/docs/main/next/en/setup/backend/backend-trace-profiling/)
- [eBPF CPU Profiling](https://skywalking.apache.org/docs/skywalking-rover/next/en/setup/configuration/profiling/ebpf-cpu-profiling/)
- [SDK Profiling](https://skywalking.apache.org/docs/main/next/en/setup/backend/sdk-profiling/)
- [Diagnose Service Mesh Network Performance with eBPF](https://skywalking.apache.org/blog/diagnose-service-mesh-network-performance-with-ebpf/)

### Service Mesh Integration
- [Istio Integration Guide](https://skywalking.apache.org/docs/main/next/en/setup/istio/readme/)
- [Envoy ALS Settings](https://skywalking.apache.org/docs/main/next/en/setup/envoy/als_setting/)
- [Envoy Metrics Settings](https://skywalking.apache.org/docs/main/next/en/setup/envoy/metrics_service_setting/)
- [Zipkin Tracing](https://skywalking.apache.org/docs/main/next/en/setup/zipkin/tracing/)

### Log Collection
- [Log Collection - Agent Native](https://skywalking.apache.org/docs/main/next/en/setup/backend/log-agent-native/)
- [Log Collection - File Logs](https://skywalking.apache.org/docs/main/next/en/setup/backend/filelog-native/)
- [Log Collection - OpenTelemetry](https://skywalking.apache.org/docs/main/next/en/setup/backend/log-otlp/)
- [Log Analyzer](https://skywalking.apache.org/docs/main/next/en/setup/backend/log-analyzer/)
- [On-Demand Pod Logs](https://skywalking.apache.org/docs/main/next/en/setup/backend/on-demand-pod-log/)

### Data Receivers
- [OpenTelemetry Receiver](https://skywalking.apache.org/docs/main/next/en/setup/backend/opentelemetry-receiver/)
- [AWS Firehose Receiver](https://skywalking.apache.org/docs/main/next/en/setup/backend/aws-firehose-receiver/)

### Analysis Languages
- [OAL Documentation](https://skywalking.apache.org/docs/main/next/en/concepts-and-designs/oal/)
- [OAL Scripts Guide](https://skywalking.apache.org/docs/main/next/en/guides/backend-oal-scripts/)
- [MAL Documentation](https://skywalking.apache.org/docs/main/next/en/concepts-and-designs/mal/)
- [Scope Definitions](https://skywalking.apache.org/docs/main/next/en/concepts-and-designs/scope-definitions/)

### Alerting
- [Alerting Configuration](https://skywalking.apache.org/docs/main/next/en/setup/backend/backend-alarm/)

### Demo & Examples
- [SkyWalking Showcase](https://skywalking.apache.org/docs/skywalking-showcase/next/readme/)

### Further Reading (Academy & Papers)
- [STAM: Scalable Transaction Analysis Model](https://skywalking.apache.org/docs/main/next/en/papers/stam/)
- [Scaling with Apache SkyWalking](https://skywalking.apache.org/blog/scaling-with-apache-skywalking/)
