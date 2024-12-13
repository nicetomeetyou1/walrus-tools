#!/bin/sh

echo "PROMETHEUS_TARGET=${PROMETHEUS_TARGET}"
echo "WALRUS_NODE_TARGET=${WALRUS_NODE_TARGET}"
echo "WALRUS_AGGREGATOR_TARGET=${WALRUS_AGGREGATOR_TARGET}"
echo "WALRUS_PUBLISHER_TARGET=${WALRUS_PUBLISHER_TARGET}"

cat <<EOF > /etc/prometheus/prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['${PROMETHEUS_TARGET:-localhost:9090}']
EOF

if [ -n "${WALRUS_NODE_TARGET}" ]; then
  cat <<EOF >> /etc/prometheus/prometheus.yml
  - job_name: 'walrus_storage_node'
    static_configs:
      - targets: ['${WALRUS_NODE_TARGET}']
        labels:
          service: 'storage_node'
EOF
fi

if [ -n "${WALRUS_AGGREGATOR_TARGET}" ]; then
  cat <<EOF >> /etc/prometheus/prometheus.yml
  - job_name: 'walrus_aggregator'
    static_configs:
      - targets: ['${WALRUS_AGGREGATOR_TARGET}']
        labels:
          service: 'aggregator'
EOF
fi

if [ -n "${WALRUS_PUBLISHER_TARGET}" ]; then
  cat <<EOF >> /etc/prometheus/prometheus.yml
  - job_name: 'walrus_publisher'
    static_configs:
      - targets: ['${WALRUS_PUBLISHER_TARGET}']
        labels:
          service: 'publisher'
EOF
fi

exec prometheus --config.file=/etc/prometheus/prometheus.yml
