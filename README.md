# Walrus Tools

This repository contains configurations and tools for monitoring and managing the Walrus network. It currently includes setup files for Grafana and Prometheus, along with a pre-configured dashboard for monitoring the Walrus Storage Node.

---

## **Directory Structure**

```plaintext
.
├── docker-compose.yml           # Docker Compose file for deploying Grafana and Prometheus
├── grafana                      # Grafana configuration and assets
│   ├── dashboards               # Grafana dashboards in JSON format
│   │   └── walrus_storage_node.json  # Pre-configured dashboard for Walrus Storage Node
│   └── provisioning             # Grafana provisioning files
│       ├── dashboards
│       │   └── dashboard.yml    # Dashboard provisioning config
│       └── datasources
│           └── main.yml         # Datasource configuration for Prometheus
└── prometheus                   # Prometheus configuration
    └── prometheus.yml
```

## Setup and Deployment

1. Clone the Repository

```bash
git clone https://github.com/walrus-network/walrus-tools.git
```

2. Navigate to the directory

```bash
cd walrus-tools
```

3. Set Environment Variables

```bash
cp .env.tmp .env
```

Edit the .env file as needed to configure Grafana and Prometheus. Example .env.tmp:

```plaintext
# Grafana Configuration
GF_SECURITY_ADMIN_USER=<admin_user>
GF_SECURITY_ADMIN_PASSWORD=<admin_password>
GF_PORT=3000

# Prometheus Configuration
PROMETHEUS_PORT=9090
```

4. Start the Services

```bash
docker compose up -d
```

This will deploy Grafana and Prometheus containers. Grafana will be accessible at `http://localhost:3000`, and Prometheus at `http://localhost:9090`.

5. Access the Pre-Configured Dashboard

Log in to Grafana with the credentials set in your `.env` file.
The dashboard will be automatically provisioned and available in the Grafana UI.

## Currently Supported Dashboards

- **Walrus Storage Node Dashboard**
  - Description: This dashboard provides insights into the performance and status of the Walrus Storage Node, including metrics such as storage usage, retrieval rates, and operation latency.
  - Dashboard File: [walrus_storage_node.json](./grafana/dashboards/walrus_storage_node.json)

  <img src="./assets/walrus_storage_node.png" alt="Walrus Storage Node Dashboard" width="100%">

## Customizing Configuration

### Prometheus Targets

The Prometheus scrape configuration is located in `prometheus/prometheus.yml`. To add or modify scrape targets:

```yaml
scrape_configs:
  - job_name: 'walrus_storage_node'
    static_configs:
      - targets: ['localhost:9184']
```

Replace `localhost:9184` with your desired target for storage node metrics.

## Contributing

Feel free to contribute enhancements or additional tools for the Walrus network. Submit pull requests or issues to this repository.

## License

This repository is licensed under the MIT License. See the LICENSE file for details.
