#!/bin/sh

# Debug: Print environment variables
echo "PROMETHEUS_TARGET=${PROMETHEUS_TARGET}"
echo "WALRUS_TARGET=${WALRUS_TARGET}"

# Perform substitution with sed
sed "s|\${PROMETHEUS_TARGET}|${PROMETHEUS_TARGET}|g; s|\${WALRUS_TARGET}|${WALRUS_TARGET}|g" /etc/prometheus/prometheus.yml.tmpl > /etc/prometheus/prometheus.yml

exec prometheus --config.file=/etc/prometheus/prometheus.yml
