#!/bin/sh

# Debug: Print environment variables
echo "PROMETHEUS_TARGET=${PROMETHEUS_TARGET}"
echo "WALRUS_NODE_TARGET=${WALRUS_NODE_TARGET}"
echo "WALRUS_AGGREGATOR_TARGET=${WALRUS_AGGREGATOR_TARGET}"
echo "WALRUS_PUBLISHER_TARGET=${WALRUS_PUBLISHER_TARGET}"

# Perform substitution with sed
sed "s|\${PROMETHEUS_TARGET}|${PROMETHEUS_TARGET}|g; s|\${WALRUS_NODE_TARGET}|${WALRUS_NODE_TARGET}|g; s|\${WALRUS_AGGREGATOR_TARGET}|${WALRUS_AGGREGATOR_TARGET}|g; s|\${WALRUS_PUBLISHER_TARGET}|${WALRUS_PUBLISHER_TARGET}|g" /etc/prometheus/prometheus.yml.tmpl > /etc/prometheus/prometheus.yml

exec prometheus --config.file=/etc/prometheus/prometheus.yml
