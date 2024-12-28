#!/bin/sh

# Display configuration environment variables
echo "PROMETHEUS_TARGET=${PROMETHEUS_TARGET}"
echo "WALRUS_NODE_TARGET=${WALRUS_NODE_TARGET}"
echo "WALRUS_AGGREGATOR_TARGET=${WALRUS_AGGREGATOR_TARGET}"
echo "WALRUS_PUBLISHER_TARGET=${WALRUS_PUBLISHER_TARGET}"
echo "ALERTMANAGER_TARGET=${ALERTMANAGER_TARGET}"

# Function to extract the scheme and clean the target
sanitize_target() {
  TARGET="$1"
  if echo "$TARGET" | grep -q '^https://'; then
    echo "https"  # Return https as the scheme
    echo "$TARGET" | sed 's|^https://||'  # Remove https:// from target
  elif echo "$TARGET" | grep -q '^http://'; then
    echo "http"  # Return http as the scheme
    echo "$TARGET" | sed 's|^http://||'  # Remove http:// from target
  else
    echo "http"  # Default to http if no scheme is detected
    echo "$TARGET"
  fi
}

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
  echo "Adding scrape config for Walrus Storage Node"
  NODE_SCHEME=$(sanitize_target "${WALRUS_NODE_TARGET}" | head -n 1)
  NODE_TARGET=$(sanitize_target "${WALRUS_NODE_TARGET}" | tail -n 1)

  cat <<EOF >> /etc/prometheus/prometheus.yml
  - job_name: 'walrus_storage_node'
EOF
  if [ "$NODE_SCHEME" = "https" ]; then
    cat <<EOF >> /etc/prometheus/prometheus.yml
    scheme: 'https'
EOF
  fi
  cat <<EOF >> /etc/prometheus/prometheus.yml
    static_configs:
      - targets: ['${NODE_TARGET}']
        labels:
          service: 'storage_node'
EOF
fi

# Add Walrus Aggregator Job
if [ -n "${WALRUS_AGGREGATOR_TARGET}" ]; then
  echo "Adding scrape config for Walrus Aggregator"
  AGGREGATOR_SCHEME=$(sanitize_target "${WALRUS_AGGREGATOR_TARGET}" | head -n 1)
  AGGREGATOR_TARGET=$(sanitize_target "${WALRUS_AGGREGATOR_TARGET}" | tail -n 1)

  cat <<EOF >> /etc/prometheus/prometheus.yml
  - job_name: 'walrus_aggregator'
EOF
  if [ "$AGGREGATOR_SCHEME" = "https" ]; then
    cat <<EOF >> /etc/prometheus/prometheus.yml
    scheme: 'https'
EOF
  fi
  cat <<EOF >> /etc/prometheus/prometheus.yml
    static_configs:
      - targets: ['${AGGREGATOR_TARGET}']
        labels:
          service: 'aggregator'
EOF
fi

# Add Walrus Publisher Job
if [ -n "${WALRUS_PUBLISHER_TARGET}" ]; then
  echo "Adding scrape config for Walrus Publisher"
  PUBLISHER_SCHEME=$(sanitize_target "${WALRUS_PUBLISHER_TARGET}" | head -n 1)
  PUBLISHER_TARGET=$(sanitize_target "${WALRUS_PUBLISHER_TARGET}" | tail -n 1)

  cat <<EOF >> /etc/prometheus/prometheus.yml
  - job_name: 'walrus_publisher'
EOF
  if [ "$PUBLISHER_SCHEME" = "https" ]; then
    cat <<EOF >> /etc/prometheus/prometheus.yml
    scheme: 'https'
EOF
  fi
  cat <<EOF >> /etc/prometheus/prometheus.yml
    static_configs:
      - targets: ['${PUBLISHER_TARGET}']
        labels:
          service: 'publisher'
EOF
fi

# Start Prometheus with the generated configuration
exec prometheus --config.file=/etc/prometheus/prometheus.yml "$@"
