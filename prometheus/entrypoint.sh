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
EOF

# Include Alert Rules Conditionally
if [ -n "${WALRUS_NODE_TARGET}" ]; then
  echo "  - /etc/prometheus/rules/walrus_node_alerts.yml" >> /etc/prometheus/prometheus.yml
fi

if [ -n "${WALRUS_AGGREGATOR_TARGET}" ]; then
  echo "  - /etc/prometheus/rules/walrus_aggregator_alerts.yml" >> /etc/prometheus/prometheus.yml
fi

if [ -n "${WALRUS_PUBLISHER_TARGET}" ]; then
  echo "  - /etc/prometheus/rules/walrus_publisher_alerts.yml" >> /etc/prometheus/prometheus.yml
fi

# Add Scrape Configurations
cat <<EOF >> /etc/prometheus/prometheus.yml
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

# Start Prometheus with the generated configuration
exec prometheus --config.file=/etc/prometheus/prometheus.yml "$@"
