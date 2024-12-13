#!/bin/sh

echo "Starting Grafana entrypoint script..."

SOURCE_DASHBOARD_DIR="/tmp/dashboards"
TARGET_DASHBOARD_DIR="/var/lib/grafana/dashboards"

# Remove all dashboards from the target directory
rm -f "${TARGET_DASHBOARD_DIR}"/*.json
mkdir -p "${TARGET_DASHBOARD_DIR}"

# Add dashboards based on environment variables
if [ -n "${WALRUS_NODE_TARGET}" ]; then
    echo "Enabling Storage Node Dashboard..."
    cp "${SOURCE_DASHBOARD_DIR}/walrus_storage_node.json" "${TARGET_DASHBOARD_DIR}/"
fi

if [ -n "${WALRUS_AGGREGATOR_TARGET}" ]; then
    echo "Enabling Aggregator Dashboard..."
    cp "${SOURCE_DASHBOARD_DIR}/walrus_aggregator.json" "${TARGET_DASHBOARD_DIR}/"
fi

if [ -n "${WALRUS_PUBLISHER_TARGET}" ]; then
    echo "Enabling Publisher Dashboard..."
    cp "${SOURCE_DASHBOARD_DIR}/walrus_publisher.json" "${TARGET_DASHBOARD_DIR}/"
fi

# Start Grafana server
exec grafana server
