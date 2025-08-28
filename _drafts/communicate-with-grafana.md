---
title: "Complete Guide to Grafana API Communication"
description: "Learn how to programmatically manage Grafana dashboards, alerts, datasources, folders, and API keys using REST API with practical examples."
author: sagar
date: 2025-01-19 10:00:00 +0000
categories: [DevOps, Monitoring]
tags: [grafana, api, monitoring, dashboards, alerts]
pin: false
math: false
mermaid: true
image:
  path: /assets/img/posts/20250119/grafana-api-guide.webp
  alt: "Grafana API Communication Guide"
---

# Complete Guide to Grafana API Communication

This comprehensive guide covers programmatic interaction with Grafana for managing dashboards, alerts, datasources, folders, API keys, and more using the Grafana HTTP API.

## Prerequisites

- Grafana instance (local or cloud)
- API token or basic authentication
- `curl`, Python, or your preferred HTTP client

## Observability as Code Overview

Observability as Code (OaC) is the practice of managing observability resources (dashboards, alerts, datasources) using code and version control. This approach provides:

- **Version Control:** Track changes to dashboards and alerts
- **Reproducibility:** Deploy consistent configurations across environments
- **Collaboration:** Team-based development with code reviews
- **Automation:** CI/CD integration for automated deployments
- **Rollback:** Easy reversion to previous configurations

### Key Components

1. **Infrastructure as Code (IaC):** Terraform, Pulumi
2. **Configuration Management:** Ansible, Chef, Puppet
3. **GitOps:** Git-based workflows for deployments
4. **SDK/Libraries:** Grafana Foundation SDK, grafanalib
5. **CLI Tools:** grafanactl, grizzly

## 🟢 Beginner Level

### Authentication Setup

#### API Token (Recommended)

1. **Create API Token:**
   - Go to Configuration → API Keys
   - Click "New API Key"
   - Set role (Viewer/Editor/Admin)
   - Copy the generated token

2. **Environment Setup:**
```bash
export GRAFANA_URL="http://localhost:3000"
export GRAFANA_TOKEN="your-api-token-here"
```

#### Basic Authentication
```bash
export GRAFANA_USER="admin"
export GRAFANA_PASS="admin"
```

### Basic Operations with cURL

#### List Dashboards
```bash
curl -X GET "$GRAFANA_URL/api/search?type=dash-db" \
  -H "Authorization: Bearer $GRAFANA_TOKEN"
```

#### Get Dashboard by UID
```bash
curl -X GET "$GRAFANA_URL/api/dashboards/uid/{dashboard-uid}" \
  -H "Authorization: Bearer $GRAFANA_TOKEN"
```

#### List Datasources
```bash
curl -X GET "$GRAFANA_URL/api/datasources" \
  -H "Authorization: Bearer $GRAFANA_TOKEN"
```

#### List Folders
```bash
curl -X GET "$GRAFANA_URL/api/folders" \
  -H "Authorization: Bearer $GRAFANA_TOKEN"
```

### [Grafana Provisioning](https://grafana.com/docs/grafana/latest/administration/provisioning/) (Built-in)

Grafana Provisioning is the built-in method to automatically configure Grafana resources (datasources, dashboards, alerts) using YAML files. When Grafana starts, it reads these configuration files and creates/updates resources accordingly. This approach is ideal for:

- **Container deployments** (Docker, Kubernetes)
- **Immutable infrastructure** patterns
- **Automated setup** without manual UI configuration
- **Version-controlled** configuration management

#### Configuration Structure
```
grafana/
├── provisioning/
│   ├── datasources/
│   │   └── datasources.yaml
│   ├── dashboards/
│   │   ├── dashboards.yaml
│   │   └── json/
│   │       └── system-dashboard.json
│   ├── alerting/
│   │   ├── rules.yaml
│   │   └── policies.yaml
│   └── plugins/
│       └── plugins.yaml
└── grafana.ini
```

#### Datasource Provisioning
```yaml
# provisioning/datasources/datasources.yaml
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
    editable: false

  - name: Loki
    type: loki
    access: proxy
    url: http://loki:3100
    editable: false

  - name: InfluxDB
    type: influxdb
    access: proxy
    url: http://influxdb:8086
    database: telegraf
    user: admin
    secureJsonData:
      password: admin
    editable: false
```

#### Dashboard Provisioning
```yaml
# provisioning/dashboards/dashboards.yaml
apiVersion: 1

providers:
  - name: 'System Dashboards'
    orgId: 1
    folder: 'System Monitoring'
    type: file
    disableDeletion: false
    updateIntervalSeconds: 10
    allowUiUpdates: true
    options:
      path: /etc/grafana/provisioning/dashboards/json

  - name: 'Application Dashboards'
    orgId: 1
    folder: 'Applications'
    type: file
    disableDeletion: true
    options:
      path: /var/lib/grafana/dashboards/apps
```

#### Alert Rule Provisioning
```yaml
# provisioning/alerting/rules.yaml
groups:
  - name: system-alerts
    orgId: 1
    folder: System Alerts
    interval: 1m
    rules:
      - uid: high-cpu-usage
        title: High CPU Usage
        condition: A
        data:
          - refId: A
            queryType: ''
            relativeTimeRange:
              from: 300
              to: 0
            model:
              expr: 100 - (avg(irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)
              refId: A
        noDataState: NoData
        execErrState: Alerting
        for: 5m
        annotations:
          description: 'CPU usage is above 80%'
          summary: 'High CPU usage detected'
        labels:
          severity: warning
```

#### Notification Policy Provisioning
```yaml
# provisioning/alerting/policies.yaml
policies:
  - orgId: 1
    receiver: grafana-default-email
    group_by: ['grafana_folder', 'alertname']
    routes:
      - receiver: slack-alerts
        object_matchers:
          - ['severity', '=', 'critical']
        group_wait: 10s
        group_interval: 5m
        repeat_interval: 12h

contactPoints:
  - orgId: 1
    name: slack-alerts
    receivers:
      - uid: slack-webhook
        type: slack
        settings:
          url: https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK
          channel: '#alerts'
          username: Grafana
```

#### Docker Compose with Provisioning
```yaml
# docker-compose.yml
version: '3.8'
services:
  grafana:
    image: grafana/grafana:latest
    ports:
      - "3000:3000"
    volumes:
      - ./provisioning:/etc/grafana/provisioning
      - ./dashboards:/var/lib/grafana/dashboards
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
      - GF_PATHS_PROVISIONING=/etc/grafana/provisioning
```

### Observability as Code Workflow

#### 1. Define Resources as Code
```yaml
# dashboard.yaml
apiVersion: grizzly.grafana.com/v1alpha1
kind: Dashboard
metadata:
  name: system-overview
spec:
  title: "System Overview"
  tags: ["system", "monitoring"]
  panels:
    - title: "CPU Usage"
      type: "stat"
      targets:
        - expr: "100 - (avg(irate(node_cpu_seconds_total{mode='idle'}[5m])) * 100)"
```

#### 2. Version Control
```bash
# Initialize Git repository
git init observability-config
cd observability-config

# Add dashboard configurations
mkdir dashboards datasources alerts
echo "dashboard.yaml" > dashboards/
git add .
git commit -m "Initial observability configuration"
```

#### 3. Automated Deployment
```yaml
# .github/workflows/deploy.yml
name: Deploy Observability Config
on:
  push:
    branches: [main]
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Deploy to Grafana
        run: |
          grafanactl apply -f dashboards/
          grafanactl apply -f datasources/
```

### [Grafanactl](https://github.com/grafana/grafanactl) - CLI Tool

#### Installation
```bash
# Homebrew (macOS/Linux)
brew install grafana/tap/grafanactl

# Download binary
wget https://github.com/grafana/grafanactl/releases/latest/download/grafanactl-linux-amd64
chmod +x grafanactl-linux-amd64
sudo mv grafanactl-linux-amd64 /usr/local/bin/grafanactl

# Go install
go install github.com/grafana/grafanactl@latest

# Docker
docker run --rm grafana/grafanactl:latest --help
```

#### Configuration

**Method 1: Environment Variables**
```bash
export GRAFANA_URL="http://localhost:3000"
export GRAFANA_TOKEN="xxxxxxxxxxxxxxxxxxxxxxxxx"
```

**Method 2: Configuration File**
```bash
# Create config directory
mkdir -p ~/.config/grafanactl

# Create configuration file
cat > ~/.config/grafanactl/config.yaml << EOF
contexts:
  local:
    url: http://localhost:3000
    token: xxxxxxxxxxxxxxxxxxxxxxxxx
  production:
    url: https://grafana.company.com
    token: glsa_prod_token_here
current-context: local
EOF
```

**Method 3: Command Line Flags**
```bash
# Use flags with each command
grafanactl get dashboards --server http://localhost:3000 --token xxxxxxxxxxxxxxxxxxxxxxxxx
```

**Switch Contexts**
```bash
# List available contexts
grafanactl config get-contexts

# Switch to different context
grafanactl config use-context production

# View current configuration
grafanactl config current-context
```

#### Dashboard Management
```bash
# List dashboards
grafanactl get dashboards
grafanactl get dashboards --folder monitoring

# Get dashboard details
grafanactl get dashboard my-dashboard-uid
grafanactl get dashboard my-dashboard-uid -o yaml
grafanactl get dashboard my-dashboard-uid -o json

# Export dashboard
grafanactl get dashboard my-dashboard-uid -o json > dashboard.json

# Create/Update dashboard
grafanactl apply -f dashboard.json
grafanactl apply -f dashboard.yaml

# Delete dashboard
grafanactl delete dashboard my-dashboard-uid

# Search dashboards
grafanactl get dashboards --search "system"
```ly -f dashboard.json
grafanactl apply -f dashboard.yaml

# Delete dashboard
grafanactl delete dashboard my-dashboard-uid

# Search dashboards
grafanactl get dashboards --search "system"
```

#### Folder Management
```bash
# List folders
grafanactl get folders

# Create folder
grafanactl create folder --title "Monitoring" --uid monitoring

# Get folder
grafanactl get folder monitoring

# Delete folder
grafanactl delete folder monitoring
```

#### Datasource Management
```bash
# List datasources
grafanactl get datasources

# Get datasource
grafanactl get datasource prometheus

# Create datasource
grafanactl apply -f datasource.yaml

# Delete datasource
grafanactl delete datasource prometheus

# Test datasource
grafanactl test datasource prometheus
```

#### Alert Management
```bash
# List alert rules
grafanactl get alert-rules

# Get alert rule
grafanactl get alert-rule my-alert-uid

# Create/Update alert rule
grafanactl apply -f alert-rule.yaml

# Delete alert rule
grafanactl delete alert-rule my-alert-uid

# List notification policies
grafanactl get notification-policies
```

#### Dashboards as Code
```bash
# Initialize dashboard project
mkdir my-dashboards && cd my-dashboards
grafanactl dashboard init

# Generate dashboard from template
grafanactl dashboard generate --template prometheus

# Validate dashboards
grafanactl dashboard validate .

# Deploy dashboards
grafanactl dashboard deploy .

# Watch for changes
grafanactl dashboard watch .
```

#### Resource Exploration
```bash
# Describe resource
grafanactl describe dashboard my-dashboard-uid
grafanactl describe datasource prometheus

# Get resource in different formats
grafanactl get dashboard my-dashboard-uid -o wide
grafanactl get dashboard my-dashboard-uid -o yaml
grafanactl get dashboard my-dashboard-uid -o json

# Filter resources
grafanactl get dashboards --selector "tag=monitoring"
grafanactl get dashboards --field-selector "folder=monitoring"
```

#### Bulk Operations
```bash
# Export all dashboards
grafanactl get dashboards -o yaml > all-dashboards.yaml

# Export specific folder
grafanactl get dashboards --folder monitoring -o yaml > monitoring-dashboards.yaml

# Apply multiple resources
grafanactl apply -f dashboards/
grafanactl apply -R -f .

# Delete multiple resources
grafanactl delete -f dashboards/
```

#### Configuration File Example
```yaml
# ~/.config/grafanactl/config.yaml
apiVersion: v1
kind: Config
contexts:
- name: local
  context:
    server: http://localhost:3000
    token: xxxxxxxxxxxxxxxxxxxxxxxxx
- name: production
  context:
    server: https://grafana.company.com
    token: xxxxxxxxxxxxxxxxxxxxxxxxx
current-context: local
```

#### Environment Variables
```bash
# Authentication
GRAFANA_URL="http://localhost:3000"
GRAFANA_TOKEN="your-api-token"
GRAFANA_USER="admin"
GRAFANA_PASSWORD="admin"

# Configuration
GRAFANA_CONFIG_HOME="~/.config/grafanactl"
GRAFANA_CONTEXT="local"

# Output
GRAFANA_OUTPUT="json"  # json, yaml, table, wide
GRAFANA_NO_HEADERS="false"

# Debugging
GRAFANA_DEBUG="true"
GRAFANA_LOG_LEVEL="debug"
```metheus" \
  --type "prometheus" \
  --url "http://prometheus:9090" \
  --default

# Test datasource
grafana-cli datasource test prometheus
```

##### Bulk Operations
```bash
# Export all dashboards
grafana-cli dashboard export-all --output-dir ./backups

# Import all dashboards from directory
grafana-cli dashboard import-all ./backups

# Backup entire Grafana instance
grafana-cli backup create \
  --output grafana-backup.tar.gz \
  --include-dashboards \
  --include-datasources \
  --include-alerts
```

### Grafanactl - Community CLI Tool

#### Installation
```bash
# Homebrew (macOS/Linux)
brew install grafana/tap/grafanactl

# Download binary
wget https://github.com/grafana/grafanactl/releases/latest/download/grafanactl-linux-amd64
chmod +x grafanactl-linux-amd64
sudo mv grafanactl-linux-amd64 /usr/local/bin/grafanactl
```

#### Configuration
```bash
export GRAFANA_URL="http://localhost:3000"
export GRAFANA_TOKEN="your-api-token"

# Or use config file
grafanactl config init
grafanactl config set-context local --url http://localhost:3000 --token your-token
grafanactl config use-context local
```

#### Basic Commands
```bash
# List resources
grafanactl get dashboards
grafanactl get datasources
grafanactl get folders

# Export dashboard
grafanactl get dashboard my-dashboard-uid -o json > dashboard.json

# Import dashboard
grafanactl apply -f dashboard.json
```

## 🟡 Intermediate Level

### API Key Management

#### Create API Key
```bash
curl -X POST "$GRAFANA_URL/api/auth/keys" \
  -H "Authorization: Bearer $GRAFANA_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "automation-key",
    "role": "Editor",
    "secondsToLive": 86400
  }'
```

#### List API Keys
```bash
curl -X GET "$GRAFANA_URL/api/auth/keys" \
  -H "Authorization: Bearer $GRAFANA_TOKEN"
```

#### Delete API Key
```bash
curl -X DELETE "$GRAFANA_URL/api/auth/keys/{id}" \
  -H "Authorization: Bearer $GRAFANA_TOKEN"
```

### Folder Management

#### Create Folder
```bash
curl -X POST "$GRAFANA_URL/api/folders" \
  -H "Authorization: Bearer $GRAFANA_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "uid": "monitoring",
    "title": "Monitoring Dashboards"
  }'
```

#### Update Folder
```bash
curl -X PUT "$GRAFANA_URL/api/folders/monitoring" \
  -H "Authorization: Bearer $GRAFANA_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Updated Monitoring Dashboards",
    "version": 1
  }'
```

#### Delete Folder
```bash
curl -X DELETE "$GRAFANA_URL/api/folders/monitoring" \
  -H "Authorization: Bearer $GRAFANA_TOKEN"
```

### Datasource Management

#### Create Prometheus Datasource
```bash
curl -X POST "$GRAFANA_URL/api/datasources" \
  -H "Authorization: Bearer $GRAFANA_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Prometheus",
    "type": "prometheus",
    "url": "http://localhost:9090",
    "access": "proxy",
    "isDefault": true
  }'
```

#### Create InfluxDB Datasource
```bash
curl -X POST "$GRAFANA_URL/api/datasources" \
  -H "Authorization: Bearer $GRAFANA_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "InfluxDB",
    "type": "influxdb",
    "url": "http://localhost:8086",
    "access": "proxy",
    "database": "telegraf",
    "user": "admin",
    "password": "admin"
  }'
```

#### Test Datasource
```bash
curl -X POST "$GRAFANA_URL/api/datasources/{id}/health" \
  -H "Authorization: Bearer $GRAFANA_TOKEN"
```

### Dashboard Management

#### Create Dashboard
```bash
curl -X POST "$GRAFANA_URL/api/dashboards/db" \
  -H "Authorization: Bearer $GRAFANA_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "dashboard": {
      "id": null,
      "title": "System Metrics",
      "tags": ["system", "monitoring"],
      "timezone": "browser",
      "panels": [
        {
          "id": 1,
          "title": "CPU Usage",
          "type": "stat",
          "targets": [
            {
              "expr": "100 - (avg(irate(node_cpu_seconds_total{mode=\"idle\"}[5m])) * 100)",
              "refId": "A"
            }
          ],
          "gridPos": {"h": 8, "w": 12, "x": 0, "y": 0}
        }
      ],
      "time": {"from": "now-1h", "to": "now"},
      "refresh": "5s"
    },
    "folderUid": "monitoring",
    "overwrite": false
  }'
```

#### Export Dashboard
```bash
curl -X GET "$GRAFANA_URL/api/dashboards/uid/{dashboard-uid}" \
  -H "Authorization: Bearer $GRAFANA_TOKEN" | \
  jq '.dashboard' > dashboard-backup.json
```

#### Import Dashboard
```bash
curl -X POST "$GRAFANA_URL/api/dashboards/db" \
  -H "Authorization: Bearer $GRAFANA_TOKEN" \
  -H "Content-Type: application/json" \
  -d @dashboard-backup.json
```

### [Ansible Grafana Collection](https://docs.ansible.com/ansible/latest/collections/grafana/grafana/)

#### Installation
```bash
ansible-galaxy collection install grafana.grafana
```

#### Basic Configuration Playbook
```yaml
# grafana-basic.yml
---
- name: Configure Grafana Basic Resources
  hosts: localhost
  vars:
    grafana_url: "http://localhost:3000"
    grafana_user: "admin"
    grafana_password: "admin"

  tasks:
    - name: Create Prometheus datasource
      grafana.grafana.grafana_datasource:
        grafana_url: "{{ grafana_url }}"
        grafana_user: "{{ grafana_user }}"
        grafana_password: "{{ grafana_password }}"
        name: "Prometheus"
        ds_type: "prometheus"
        ds_url: "http://prometheus:9090"
        access: "proxy"
        is_default: true

    - name: Create folder
      grafana.grafana.grafana_folder:
        grafana_url: "{{ grafana_url }}"
        grafana_user: "{{ grafana_user }}"
        grafana_password: "{{ grafana_password }}"
        title: "Monitoring"
        uid: "monitoring"

    - name: Import dashboard
      grafana.grafana.grafana_dashboard:
        grafana_url: "{{ grafana_url }}"
        grafana_user: "{{ grafana_user }}"
        grafana_password: "{{ grafana_password }}"
        dashboard: "{{ lookup('file', 'dashboard.json') | from_json }}"
        folder: "Monitoring"
        overwrite: true
```

#### Datasource Management Playbook
```yaml
# grafana-datasources.yml
---
- name: Manage Grafana Datasources
  hosts: localhost
  vars:
    grafana_url: "http://localhost:3000"
    grafana_token: "{{ vault_grafana_token }}"

  tasks:
    - name: Create Prometheus datasource
      grafana.grafana.datasource:
        grafana_url: "{{ grafana_url }}"
        grafana_api_key: "{{ grafana_token }}"
        name: "Prometheus"
        ds_type: "prometheus"
        ds_url: "http://prometheus:9090"
        access: "proxy"
        is_default: true
        tls_skip_verify: false
        with_credentials: false
        state: present

    - name: Create InfluxDB datasource with custom settings
      grafana.grafana.datasource:
        grafana_url: "{{ grafana_url }}"
        grafana_api_key: "{{ grafana_token }}"
        name: "InfluxDB"
        ds_type: "influxdb"
        ds_url: "http://influxdb:8086"
        database: "telegraf"
        user: "grafana"
        password: "{{ vault_influxdb_password }}"
        access: "proxy"
        additional_json_data:
          httpMode: "GET"
          keepCookies: []
        state: present

    - name: Create Loki datasource
      grafana.grafana.datasource:
        grafana_url: "{{ grafana_url }}"
        grafana_api_key: "{{ grafana_token }}"
        name: "Loki"
        ds_type: "loki"
        ds_url: "http://loki:3100"
        access: "proxy"
        additional_json_data:
          maxLines: 1000
        state: present

    - name: Remove old datasource
      grafana.grafana.datasource:
        grafana_url: "{{ grafana_url }}"
        grafana_api_key: "{{ grafana_token }}"
        name: "Old-Prometheus"
        state: absent
```

#### Folder Management Playbook
```yaml
# grafana-folders.yml
---
- name: Manage Grafana Folders
  hosts: localhost
  vars:
    grafana_url: "http://localhost:3000"
    grafana_token: "{{ vault_grafana_token }}"

  tasks:
    - name: Create monitoring folder
      grafana.grafana.folder:
        grafana_url: "{{ grafana_url }}"
        grafana_api_key: "{{ grafana_token }}"
        title: "System Monitoring"
        uid: "system-monitoring"
        state: present

    - name: Create application folder
      grafana.grafana.folder:
        grafana_url: "{{ grafana_url }}"
        grafana_api_key: "{{ grafana_token }}"
        title: "Application Dashboards"
        uid: "app-dashboards"
        state: present

    - name: Create team-specific folder
      grafana.grafana.folder:
        grafana_url: "{{ grafana_url }}"
        grafana_api_key: "{{ grafana_token }}"
        title: "{{ item.team }} Team"
        uid: "{{ item.uid }}"
        state: present
      loop:
        - { team: "DevOps", uid: "devops-team" }
        - { team: "Platform", uid: "platform-team" }
        - { team: "Security", uid: "security-team" }

    - name: Remove deprecated folder
      grafana.grafana.folder:
        grafana_url: "{{ grafana_url }}"
        grafana_api_key: "{{ grafana_token }}"
        uid: "deprecated-folder"
        state: absent
```

#### Dashboard Management Playbook
```yaml
# grafana-dashboards.yml
---
- name: Manage Grafana Dashboards
  hosts: localhost
  vars:
    grafana_url: "http://localhost:3000"
    grafana_token: "{{ vault_grafana_token }}"

  tasks:
    - name: Import dashboard from file
      grafana.grafana.dashboard:
        grafana_url: "{{ grafana_url }}"
        grafana_api_key: "{{ grafana_token }}"
        dashboard: "{{ lookup('file', 'dashboards/system-overview.json') | from_json }}"
        folder: "System Monitoring"
        overwrite: true
        state: present

    - name: Import dashboard from Grafana.com
      grafana.grafana.dashboard:
        grafana_url: "{{ grafana_url }}"
        grafana_api_key: "{{ grafana_token }}"
        dashboard_id: 1860  # Node Exporter Full
        dashboard_revision: 27
        folder: "System Monitoring"
        datasource: "Prometheus"
        overwrite: true
        state: present

    - name: Create dashboard with template variables
      grafana.grafana.dashboard:
        grafana_url: "{{ grafana_url }}"
        grafana_api_key: "{{ grafana_token }}"
        dashboard:
          title: "Custom Application Dashboard"
          tags: ["application", "custom"]
          templating:
            list:
              - name: "environment"
                type: "custom"
                options:
                  - { text: "Production", value: "prod" }
                  - { text: "Staging", value: "staging" }
          panels: []
        folder: "Application Dashboards"
        state: present

    - name: Remove old dashboard
      grafana.grafana.dashboard:
        grafana_url: "{{ grafana_url }}"
        grafana_api_key: "{{ grafana_token }}"
        dashboard_uid: "old-dashboard-uid"
        state: absent
```

#### Alert Configuration Playbook
```yaml
# grafana-alerts.yml
---
- name: Configure Grafana Alerts
  hosts: localhost
  vars:
    grafana_url: "http://localhost:3000"
    grafana_token: "{{ vault_grafana_token }}"

  tasks:
    - name: Create Slack contact point
      grafana.grafana.alert_contact_point:
        grafana_url: "{{ grafana_url }}"
        grafana_api_key: "{{ grafana_token }}"
        name: "slack-alerts"
        type: "slack"
        settings:
          url: "https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK"
          channel: "#alerts"
          username: "Grafana"
          title: "🚨 Grafana Alert"
          text: |
            {{ range .Alerts }}
            **{{ .Annotations.summary }}**
            {{ .Annotations.description }}
            {{ end }}
        disable_resolve_message: false
        state: present

    - name: Create email contact point
      grafana.grafana.alert_contact_point:
        grafana_url: "{{ grafana_url }}"
        grafana_api_key: "{{ grafana_token }}"
        name: "email-alerts"
        type: "email"
        settings:
          addresses:
            - "alerts@company.com"
            - "oncall@company.com"
          subject: "[{{ .Status | toUpper }}] {{ .GroupLabels.alertname }}"
          message: |
            {{ range .Alerts }}
            Alert: {{ .Annotations.summary }}
            Description: {{ .Annotations.description }}
            Labels: {{ range .Labels.SortedPairs }}{{ .Name }}={{ .Value }} {{ end }}
            {{ end }}
        state: present

    - name: Create PagerDuty contact point
      grafana.grafana.alert_contact_point:
        grafana_url: "{{ grafana_url }}"
        grafana_api_key: "{{ grafana_token }}"
        name: "pagerduty-critical"
        type: "pagerduty"
        settings:
          integrationKey: "{{ vault_pagerduty_key }}"
          severity: "critical"
          component: "Grafana"
          group: "Infrastructure"
        state: present

    - name: Create notification policy
      grafana.grafana.alert_notification_policy:
        grafana_url: "{{ grafana_url }}"
        grafana_api_key: "{{ grafana_token }}"
        receiver: "slack-alerts"
        group_by:
          - "grafana_folder"
          - "alertname"
        group_wait: "10s"
        group_interval: "5m"
        repeat_interval: "12h"
        routes:
          - receiver: "email-alerts"
            matchers:
              - "severity = warning"
            group_wait: "30s"
            repeat_interval: "6h"
          - receiver: "pagerduty-critical"
            matchers:
              - "severity = critical"
            group_wait: "5s"
            repeat_interval: "1h"
        state: present
```

#### Cloud Plugin Management Playbook
```yaml
# grafana-plugins.yml
---
- name: Manage Grafana Cloud Plugins
  hosts: localhost
  vars:
    grafana_url: "http://localhost:3000"
    grafana_token: "{{ vault_grafana_token }}"
    grafana_cloud_api_key: "{{ vault_grafana_cloud_key }}"

  tasks:
    - name: Install Grafana Cloud plugin
      grafana.grafana.cloud_plugin:
        grafana_url: "{{ grafana_url }}"
        grafana_api_key: "{{ grafana_token }}"
        grafana_cloud_api_key: "{{ grafana_cloud_api_key }}"
        plugin_slug: "grafana-synthetic-monitoring-app"
        version: "latest"
        state: present

    - name: Install specific plugin version
      grafana.grafana.cloud_plugin:
        grafana_url: "{{ grafana_url }}"
        grafana_api_key: "{{ grafana_token }}"
        grafana_cloud_api_key: "{{ grafana_cloud_api_key }}"
        plugin_slug: "grafana-oncall-app"
        version: "1.0.0"
        state: present

    - name: Remove plugin
      grafana.grafana.cloud_plugin:
        grafana_url: "{{ grafana_url }}"
        grafana_api_key: "{{ grafana_token }}"
        grafana_cloud_api_key: "{{ grafana_cloud_api_key }}"
        plugin_slug: "old-plugin"
        state: absent
```

#### Multi-Environment Playbook
```yaml
# grafana-multi-env.yml
---
- name: Configure Grafana for Multiple Environments
  hosts: localhost
  vars:
    environments:
      dev:
        grafana_url: "https://dev-grafana.company.com"
        grafana_token: "{{ vault_dev_token }}"
      staging:
        grafana_url: "https://staging-grafana.company.com"
        grafana_token: "{{ vault_staging_token }}"
      prod:
        grafana_url: "https://grafana.company.com"
        grafana_token: "{{ vault_prod_token }}"

  tasks:
    - name: Create datasources for all environments
      grafana.grafana.grafana_datasource:
        grafana_url: "{{ item.value.grafana_url }}"
        grafana_api_key: "{{ item.value.grafana_token }}"
        name: "Prometheus-{{ item.key }}"
        ds_type: "prometheus"
        ds_url: "http://prometheus-{{ item.key }}:9090"
        access: "proxy"
        is_default: true
      loop: "{{ environments | dict2items }}"

    - name: Deploy dashboards to all environments
      grafana.grafana.grafana_dashboard:
        grafana_url: "{{ item.value.grafana_url }}"
        grafana_api_key: "{{ item.value.grafana_token }}"
        dashboard: "{{ lookup('file', 'dashboards/system-metrics.json') | from_json }}"
        folder: "{{ item.key | title }} Monitoring"
        overwrite: true
      loop: "{{ environments | dict2items }}"
```

#### Running Playbooks
```bash
# Run individual playbooks
ansible-playbook grafana-datasources.yml
ansible-playbook grafana-folders.yml
ansible-playbook grafana-dashboards.yml
ansible-playbook grafana-alerts.yml
ansible-playbook grafana-plugins.yml

# Run all playbooks in sequence
ansible-playbook site.yml

# Run with inventory file
ansible-playbook -i inventory grafana-basic.yml

# Run with extra variables
ansible-playbook grafana-basic.yml -e "grafana_url=https://my-grafana.com"

# Run with vault for secrets
ansible-playbook grafana-alerts.yml --ask-vault-pass

# Run specific tags
ansible-playbook grafana-multi-env.yml --tags "datasources,folders"

# Dry run (check mode)
ansible-playbook grafana-basic.yml --check

# Verbose output
ansible-playbook grafana-basic.yml -vvv

# Run on specific hosts
ansible-playbook grafana-basic.yml --limit "grafana_servers"
```

#### Master Playbook
```yaml
# site.yml
---
- import_playbook: grafana-folders.yml
- import_playbook: grafana-datasources.yml
- import_playbook: grafana-dashboards.yml
- import_playbook: grafana-alerts.yml
- import_playbook: grafana-plugins.yml
```

#### Inventory Example
```ini
# inventory/hosts
[grafana_servers]
localhost ansible_connection=local

[grafana_servers:vars]
grafana_url=http://localhost:3000
grafana_user=admin
grafana_password=admin
```

#### Ansible Vault for Secrets
```bash
# Create encrypted vault file
ansible-vault create group_vars/all/vault.yml

# Edit vault file
ansible-vault edit group_vars/all/vault.yml

# Vault content example:
# vault_grafana_token: "xxxxxxxxxxxxxxxxxxxxxxxxx"
# vault_dev_token: "xxxxxxxxxxxxxxxxxxxxxxxxx"
# vault_prod_token: "xxxxxxxxxxxxxxxxxxxxxxxxx"
```

### [Terraform Grafana Provider](https://registry.terraform.io/providers/grafana/grafana/latest/docs)

#### Installation
```hcl
terraform {
  required_providers {
    grafana = {
      source  = "grafana/grafana"
      version = "~> 2.0"
    }
  }
}

provider "grafana" {
  url  = "http://localhost:3000"
  auth = var.grafana_token
}
```

#### Examples
```hcl
# Create datasource
resource "grafana_data_source" "prometheus" {
  type       = "prometheus"
  name       = "Prometheus"
  url        = "http://prometheus:9090"
  is_default = true
}

# Create dashboard
resource "grafana_dashboard" "system_metrics" {
  config_json = jsonencode({
    title = "System Metrics"
    panels = [
      {
        id    = 1
        title = "CPU Usage"
        type  = "stat"
        targets = [{
          expr  = "100 - (avg(irate(node_cpu_seconds_total{mode=\"idle\"}[5m])) * 100)"
          refId = "A"
        }]
      }
    ]
  })
}
```

## 🟠 Advanced Level

### Alert Management

#### Create Alert Rule
```bash
curl -X POST "$GRAFANA_URL/api/ruler/grafana/api/v1/rules/monitoring" \
  -H "Authorization: Bearer $GRAFANA_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "interval": "1m",
    "rules": [
      {
        "uid": "high-cpu-alert",
        "title": "High CPU Usage",
        "condition": "A",
        "data": [
          {
            "refId": "A",
            "queryType": "",
            "relativeTimeRange": {
              "from": 300,
              "to": 0
            },
            "model": {
              "expr": "100 - (avg(irate(node_cpu_seconds_total{mode=\"idle\"}[5m])) * 100)",
              "refId": "A"
            }
          }
        ],
        "noDataState": "NoData",
        "execErrState": "Alerting",
        "for": "5m",
        "annotations": {
          "description": "CPU usage is above 80%",
          "summary": "High CPU usage detected"
        },
        "labels": {
          "severity": "warning"
        }
      }
    ]
  }'
```

#### Create Notification Channel
```bash
curl -X POST "$GRAFANA_URL/api/alert-notifications" \
  -H "Authorization: Bearer $GRAFANA_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "slack-alerts",
    "type": "slack",
    "settings": {
      "url": "https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK",
      "channel": "#alerts",
      "username": "Grafana"
    }
  }'
```

### Python Integration

#### Grafana API Client
```python
import requests
import json
from typing import Dict, List, Optional

class GrafanaAPI:
    def __init__(self, url: str, token: str):
        self.url = url.rstrip('/')
        self.headers = {
            'Authorization': f'Bearer {token}',
            'Content-Type': 'application/json'
        }

    def create_datasource(self, config: Dict) -> Dict:
        response = requests.post(
            f'{self.url}/api/datasources',
            headers=self.headers,
            json=config
        )
        return response.json()

    def create_dashboard(self, dashboard: Dict, folder_uid: str = None) -> Dict:
        payload = {
            'dashboard': dashboard,
            'overwrite': False
        }
        if folder_uid:
            payload['folderUid'] = folder_uid

        response = requests.post(
            f'{self.url}/api/dashboards/db',
            headers=self.headers,
            json=payload
        )
        return response.json()

    def search_dashboards(self, query: str = '') -> List[Dict]:
        response = requests.get(
            f'{self.url}/api/search',
            headers=self.headers,
            params={'query': query, 'type': 'dash-db'}
        )
        return response.json()

    def get_dashboard(self, uid: str) -> Dict:
        response = requests.get(
            f'{self.url}/api/dashboards/uid/{uid}',
            headers=self.headers
        )
        return response.json()

# Usage Example
grafana = GrafanaAPI('http://localhost:3000', 'your-token')
result = grafana.create_datasource({
    'name': 'Prometheus',
    'type': 'prometheus',
    'url': 'http://localhost:9090',
    'access': 'proxy',
    'isDefault': True
})
print(f"Datasource created: {result}")
```

#### Bulk Dashboard Operations
```python
import os
import glob

def backup_all_dashboards(grafana_api: GrafanaAPI, backup_dir: str):
    os.makedirs(backup_dir, exist_ok=True)
    dashboards = grafana_api.search_dashboards()

    for dashboard in dashboards:
        uid = dashboard['uid']
        title = dashboard['title']
        full_dashboard = grafana_api.get_dashboard(uid)

        filename = f"{backup_dir}/{uid}-{title.replace(' ', '-')}.json"
        with open(filename, 'w') as f:
            json.dump(full_dashboard['dashboard'], f, indent=2)
        print(f"Backed up: {title}")

def restore_dashboards(grafana_api: GrafanaAPI, backup_dir: str):
    json_files = glob.glob(f"{backup_dir}/*.json")

    for file_path in json_files:
        with open(file_path, 'r') as f:
            dashboard = json.load(f)

        dashboard['id'] = None
        dashboard.pop('version', None)

        result = grafana_api.create_dashboard(dashboard)
        print(f"Restored: {dashboard['title']}")
```

### [Grafana Foundation SDK](https://grafana.com/docs/grafana/latest/observability-as-code/foundation-sdk/)

#### Installation
```bash
# Go
go get github.com/grafana/grafana-foundation-sdk/go

# TypeScript/JavaScript
npm install @grafana/foundation-sdk

# Python
pip install grafana-foundation-sdk
```

#### Go Example
```go
package main

import (
    "encoding/json"
    "fmt"
    "github.com/grafana/grafana-foundation-sdk/go/dashboard"
    "github.com/grafana/grafana-foundation-sdk/go/stat"
)

func main() {
    // Create a stat panel
    panel := stat.NewPanelBuilder().
        Title("CPU Usage").
        Unit("percent").
        Min(0).
        Max(100).
        Build()

    // Create dashboard
    dash := dashboard.NewDashboardBuilder("System Metrics").
        Tags([]string{"system", "monitoring"}).
        Panel(panel).
        Build()

    // Convert to JSON
    jsonData, _ := json.MarshalIndent(dash, "", "  ")
    fmt.Println(string(jsonData))
}
```

#### TypeScript Example
```typescript
import { DashboardBuilder } from '@grafana/foundation-sdk/dashboard';
import { StatPanelBuilder } from '@grafana/foundation-sdk/stat';

// Create stat panel
const panel = new StatPanelBuilder()
  .title('CPU Usage')
  .unit('percent')
  .min(0)
  .max(100)
  .build();

// Create dashboard
const dashboard = new DashboardBuilder('System Metrics')
  .tags(['system', 'monitoring'])
  .panel(panel)
  .build();

console.log(JSON.stringify(dashboard, null, 2));
```

### [Grizzly](https://github.com/grafana/grizzly) - GitOps Tool

#### Installation
```bash
# Download binary
wget https://github.com/grafana/grizzly/releases/latest/download/grr-linux-amd64
chmod +x grr-linux-amd64
sudo mv grr-linux-amd64 /usr/local/bin/grr

# Or using Go
go install github.com/grafana/grizzly/cmd/grr@latest
```

#### Configuration
```bash
# Set Grafana URL and token
export GRAFANA_URL="http://localhost:3000"
export GRAFANA_TOKEN="your-api-token"

# Or use config file
grr config set grafana.url http://localhost:3000
grr config set grafana.token your-api-token
```

#### GitOps Workflow
```bash
# Pull existing resources from Grafana
grr pull

# Show differences
grr diff

# Apply changes
grr apply resources/

# Watch for changes
grr watch resources/
```

### [Grafana Dash Gen](https://github.com/uber/grafana-dash-gen) (Uber)

#### Installation
```bash
pip install grafana-dashboard-generator
```

#### Example
```python
from grafana_dash_gen import DashboardGenerator, Panel, Target

# Create dashboard
dash_gen = DashboardGenerator(
    title="System Monitoring",
    tags=["system", "monitoring"]
)

# Add CPU panel
cpu_panel = Panel(
    title="CPU Usage",
    panel_type="stat",
    targets=[
        Target(
            expr='100 - (avg(irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)',
            ref_id="A"
        )
    ]
)

dash_gen.add_panel(cpu_panel)
dashboard_json = dash_gen.generate()

with open('dashboard.json', 'w') as f:
    f.write(dashboard_json)
```

## 🔴 Expert Level

### [Grafanalib](https://github.com/weaveworks/grafanalib) (Weaveworks)

#### Installation
```bash
pip install grafanalib
```

#### Advanced Dashboard Generation
```python
from grafanalib.core import (
    Dashboard, Graph, Template, Templating, ROUNDING_FACTOR
)
from grafanalib.prometheus import PrometheusTarget

# Create template for instance selection
instance_template = Template(
    name="instance",
    query="label_values(up, instance)",
    dataSource="Prometheus",
    multi=True,
    includeAll=True
)

# Create templating
templating = Templating([instance_template])

# Create panels with template variables
cpu_panel = Graph(
    title="CPU Usage by Instance",
    dataSource="Prometheus",
    targets=[
        PrometheusTarget(
            expr='100 - (avg by (instance) (irate(node_cpu_seconds_total{mode="idle", instance=~"$instance"}[5m])) * 100)',
            refId="A",
            legendFormat="{{instance}}"
        )
    ],
    gridPos={"h": 8, "w": 24, "x": 0, "y": 0}
)

# Create advanced dashboard
dashboard = Dashboard(
    title="Advanced System Monitoring",
    tags=["system", "advanced", "templated"],
    templating=templating,
    panels=[cpu_panel],
    time={"from": "now-6h", "to": "now"},
    refresh="30s"
)

# Generate JSON
import json
with open('advanced-dashboard.json', 'w') as f:
    json.dump(dashboard.to_json_data(), f, indent=2)
```

### Advanced Grafanactl Operations

#### Dashboards as Code
```bash
# Initialize dashboard project
mkdir my-dashboards && cd my-dashboards
grafanactl dashboard init

# Generate dashboard from template
grafanactl dashboard generate --template prometheus

# Validate dashboards
grafanactl dashboard validate .

# Deploy dashboards
grafanactl dashboard deploy .

# Watch for changes
grafanactl dashboard watch .
```

#### Resource Exploration
```bash
# Describe resource
grafanactl describe dashboard my-dashboard-uid
grafanactl describe datasource prometheus

# Get resource in different formats
grafanactl get dashboard my-dashboard-uid -o wide
grafanactl get dashboard my-dashboard-uid -o yaml

# Filter resources
grafanactl get dashboards --selector "tag=monitoring"
grafanactl get dashboards --field-selector "folder=monitoring"
```

#### Bulk Operations
```bash
# Export all dashboards
grafanactl get dashboards -o yaml > all-dashboards.yaml

# Export specific folder
grafanactl get dashboards --folder monitoring -o yaml > monitoring-dashboards.yaml

# Apply multiple resources
grafanactl apply -f dashboards/
grafanactl apply -R -f .
```

### Observability as Code Best Practices

#### 1. Repository Structure
```
observability-config/
├── dashboards/
│   ├── system/
│   │   ├── cpu-metrics.yaml
│   │   └── memory-metrics.yaml
│   └── application/
│       └── api-metrics.yaml
├── datasources/
│   ├── prometheus.yaml
│   └── loki.yaml
├── alerts/
│   ├── system-alerts.yaml
│   └── app-alerts.yaml
├── folders/
│   └── monitoring-folders.yaml
└── .github/
    └── workflows/
        └── deploy.yml
```

#### 2. Environment Management
```yaml
# environments/dev/config.yaml
grafana:
  url: "https://dev-grafana.company.com"
  folder: "dev-monitoring"

# environments/prod/config.yaml
grafana:
  url: "https://grafana.company.com"
  folder: "production-monitoring"
```

#### 3. Validation Pipeline
```yaml
# .github/workflows/validate.yml
name: Validate Observability Config

on:
  pull_request:
    paths: ['dashboards/**', 'alerts/**']

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Validate dashboards
        run: |
          # Validate JSON syntax
          find dashboards/ -name "*.json" -exec jq . {} \;

          # Validate YAML syntax
          find . -name "*.yaml" -exec yamllint {} \;

          # Check for required fields
          grr validate dashboards/
```

### CI/CD Integration

#### GitHub Actions Example
```yaml
name: Deploy Observability Config

on:
  push:
    branches: [main]
    paths: ['dashboards/**', 'datasources/**', 'alerts/**']

jobs:
  deploy:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        environment: [dev, staging, prod]

    steps:
      - uses: actions/checkout@v3

      - name: Setup Grafana CLI
        run: |
          wget https://github.com/grafana/grizzly/releases/latest/download/grr-linux-amd64
          chmod +x grr-linux-amd64
          sudo mv grr-linux-amd64 /usr/local/bin/grr

      - name: Deploy to ${{ matrix.environment }}
        env:
          GRAFANA_URL: ${{ secrets[format('GRAFANA_URL_{0}', matrix.environment)] }}
          GRAFANA_TOKEN: ${{ secrets[format('GRAFANA_TOKEN_{0}', matrix.environment)] }}
        run: |
          # Apply datasources first
          grr apply datasources/

          # Then folders
          grr apply folders/

          # Then dashboards
          grr apply dashboards/

          # Finally alerts
          grr apply alerts/
```

#### GitLab CI Example
```yaml
# .gitlab-ci.yml
stages:
  - validate
  - deploy

variables:
  GRIZZLY_VERSION: "latest"

before_script:
  - wget https://github.com/grafana/grizzly/releases/latest/download/grr-linux-amd64
  - chmod +x grr-linux-amd64
  - mv grr-linux-amd64 /usr/local/bin/grr

validate:
  stage: validate
  script:
    - grr validate .
  only:
    - merge_requests

deploy_dev:
  stage: deploy
  script:
    - grr apply --target dev .
  environment:
    name: development
  only:
    - develop

deploy_prod:
  stage: deploy
  script:
    - grr apply --target prod .
  environment:
    name: production
  only:
    - main
  when: manual
```

### Automation Scripts

#### Dashboard Provisioning
```bash
#!/bin/bash
# provision-grafana.sh

set -e

GRAFANA_URL="${GRAFANA_URL:-http://localhost:3000}"
GRAFANA_TOKEN="$GRAFANA_TOKEN"

if [ -z "$GRAFANA_TOKEN" ]; then
    echo "Error: GRAFANA_TOKEN environment variable is required"
    exit 1
fi

echo "🚀 Starting Grafana provisioning..."

# Create monitoring folder
echo "📁 Creating monitoring folder..."
curl -s -X POST "$GRAFANA_URL/api/folders" \
  -H "Authorization: Bearer $GRAFANA_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "uid": "monitoring",
    "title": "Monitoring Dashboards"
  }' | jq '.'

# Create Prometheus datasource
echo "🔌 Creating Prometheus datasource..."
curl -s -X POST "$GRAFANA_URL/api/datasources" \
  -H "Authorization: Bearer $GRAFANA_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Prometheus",
    "type": "prometheus",
    "url": "http://prometheus:9090",
    "access": "proxy",
    "isDefault": true
  }' | jq '.'

# Import dashboards from directory
echo "📊 Importing dashboards..."
for dashboard_file in dashboards/*.json; do
    if [ -f "$dashboard_file" ]; then
        echo "Importing $(basename "$dashboard_file")..."
        curl -s -X POST "$GRAFANA_URL/api/dashboards/db" \
          -H "Authorization: Bearer $GRAFANA_TOKEN" \
          -H "Content-Type: application/json" \
          -d @"$dashboard_file" | jq '.'
    fi
done

echo "✅ Grafana provisioning completed!"
```

### Best Practices

#### Security
- Use API tokens instead of basic auth
- Set appropriate token expiration
- Use least privilege principle for API keys
- Store tokens in environment variables or secrets management

#### Error Handling
```python
def safe_api_call(func, *args, **kwargs):
    try:
        response = func(*args, **kwargs)
        if response.status_code >= 400:
            print(f"API Error: {response.status_code} - {response.text}")
            return None
        return response.json()
    except requests.exceptions.RequestException as e:
        print(f"Request failed: {e}")
        return None
```

#### Rate Limiting
```python
import time
from functools import wraps

def rate_limit(calls_per_second=10):
    def decorator(func):
        last_called = [0.0]

        @wraps(func)
        def wrapper(*args, **kwargs):
            elapsed = time.time() - last_called[0]
            left_to_wait = 1.0 / calls_per_second - elapsed
            if left_to_wait > 0:
                time.sleep(left_to_wait)
            ret = func(*args, **kwargs)
            last_called[0] = time.time()
            return ret
        return wrapper
    return decorator
```

### Troubleshooting

#### Common Issues

1. **Authentication Failed**
   ```bash
   # Check token validity
   curl -X GET "$GRAFANA_URL/api/user" \
     -H "Authorization: Bearer $GRAFANA_TOKEN"
   ```

2. **Permission Denied**
   - Verify API key has sufficient permissions
   - Check organization membership

3. **Dashboard Import Fails**
   - Remove `id` and `version` fields
   - Check datasource references
   - Validate JSON structure

#### Debug Mode
```bash
# Enable verbose curl output
curl -v -X GET "$GRAFANA_URL/api/health"

# Save response for debugging
curl -X GET "$GRAFANA_URL/api/dashboards/uid/dashboard-uid" \
  -H "Authorization: Bearer $GRAFANA_TOKEN" \
  -o debug-response.json
```

## Tool Comparison

| Tool | Best For | Language | Complexity | OaC Support | Status |
|------|----------|----------|------------|-------------|--------|
| **Grafana Provisioning** | Built-in configuration | YAML | Low | ✅ | 🟢 Stable |
| **grafanactl** | CLI operations | Go | Low | ✅ | 🟡 Experimental |
| **grizzly** | GitOps workflows | Go | Low | ✅ | 🔴 Deprecated |
| **Foundation SDK** | Type-safe code generation | Go/TS/Python | Medium | ✅ | 🟢 Stable |
| **grafana-dash-gen** | Simple dashboard generation | Python | Low | ⚠️ | 🟢 Stable |
| **Ansible** | Infrastructure automation | YAML | Medium | ✅ | 🟢 Stable |
| **Terraform** | Infrastructure as Code | HCL | Medium | ✅ | 🟢 Stable |
| **grafanalib** | Complex dashboard generation | Python | High | ⚠️ | 🟢 Stable |

## References

- [Grafana HTTP API Documentation](https://grafana.com/docs/grafana/latest/developers/http_api/dashboard/)
- [Terraform Grafana Provider](https://registry.terraform.io/providers/grafana/grafana/latest/docs)
- [GitHub Actions Dashboard Automation](https://grafana.com/docs/grafana/latest/observability-as-code/foundation-sdk/dashboard-automation/)

## Conclusion

This guide provides a structured learning path from beginner to expert level:

- 🟢 **Beginner:** Basic API calls, grafanactl CLI
- 🟡 **Intermediate:** Resource management, Ansible, Terraform
- 🟠 **Advanced:** Alerts, Python integration, dashboard generation
- 🔴 **Expert:** Complex automation, CI/CD, advanced libraries

> **Tip:** Always test API calls in a development environment before applying to production!
{: .prompt-tip }

> **Warning:** Store API tokens securely and rotate them regularly for security.
{: .prompt-warning }
