#!/bin/sh

# Display configuration environment variables
echo "PROMETHEUS_TARGET=${PROMETHEUS_TARGET}"
echo "WALRUS_NODE_TARGET=${WALRUS_NODE_TARGET}"
echo "WALRUS_AGGREGATOR_TARGET=${WALRUS_AGGREGATOR_TARGET}"
echo "WALRUS_PUBLISHER_TARGET=${WALRUS_PUBLISHER_TARGET}"
echo "ALERTMANAGER_TARGET=${ALERTMANAGER_TARGET}"

# Generate prometheus.yml configuration
cat <<EOF > /etc/prometheus/prometheus.yml
global:
  scrape_interval: 15s

alerting:
  alertmanagers:
    - static_configs:
        - targets: ['${ALERTMANAGER_TARGET:-localhost:9093}']

rule_files:
  - /etc/prometheus/rules/alerts.yml  

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['${PROMETHEUS_TARGET}']
EOF

# Add Walrus Storage Node Job
if [ -n "${WALRUS_NODE_TARGET}" ]; then
  cat <<EOF >> /etc/prometheus/prometheus.yml
  - job_name: 'walrus_storage_node'
    static_configs:
      - targets: ['${WALRUS_NODE_TARGET}']
        labels:
          service: 'storage_node'
EOF
fi

# Add Walrus Aggregator Job
if [ -n "${WALRUS_AGGREGATOR_TARGET}" ]; then
  cat <<EOF >> /etc/prometheus/prometheus.yml
  - job_name: 'walrus_aggregator'
    static_configs:
      - targets: ['${WALRUS_AGGREGATOR_TARGET}']
        labels:
          service: 'aggregator'
EOF
fi

# Add Walrus Publisher Job
if [ -n "${WALRUS_PUBLISHER_TARGET}" ]; then
  cat <<EOF >> /etc/prometheus/prometheus.yml
  - job_name: 'walrus_publisher'
    static_configs:
      - targets: ['${WALRUS_PUBLISHER_TARGET}']
        labels:
          service: 'publisher'
EOF
fi

mkdir -p /etc/prometheus/rules

# Generate alerts configuration
cat <<EOF > /etc/prometheus/rules/alerts.yml
groups:
  - name: walrus_storage_node_alerts
    rules:
EOF

if [ -n "${WALRUS_NODE_TARGET}" ]; then
  cat <<EOF >> /etc/prometheus/rules/alerts.yml
      - alert: WalrusNodeRestarted
        expr: increase(uptime{service="storage_node"}[5m]) == 0
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "Walrus Storage Node Restarted"
          description: "The Walrus Storage Node uptime has not increased in the last 5 minutes, suggesting a restart or failure."

      - alert: EventProcessorCheckpointStuck
        expr: increase(event_processor_latest_downloaded_checkpoint{service="storage_node"}[5m]) == 0
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "Event Processor Checkpoint Stuck"
          description: "No new checkpoints have been downloaded in the last 5 minutes on the Walrus Storage Node."

      - alert: PersistedEventsStuck
        expr: increase(walrus_event_cursor_progress{state="persisted", service="storage_node"}[5m]) == 0
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "Persisted Events Stuck"
          description: "No new persisted events have been recorded in the last 5 minutes on the Walrus Storage Node."
EOF
fi

# Start Prometheus with the generated configuration
exec prometheus --config.file=/etc/prometheus/prometheus.yml "$@"