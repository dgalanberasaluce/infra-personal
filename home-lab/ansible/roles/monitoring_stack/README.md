# Monitoring Stack

| Service | Purpose | Port |
| ------- | ---- | -----|
| VictoriaMetrics | TSDB | 8428 |
| Grafana Loki | Logs aggregation | 3100 |
| Grafana | Data Visualization | 3000 |
| Grafana Alloy | Agent (Metrics + Logs + Traces) | 12345 (Debug) |


## Notes
- Grafana Loki runs as user 10001 within the container.

## Troubleshooting

Verify that containers are running
```bash
docker compose -f /opt/monitoring/docker-compose.yml ps
```

Check the logs of a container
```bash
docker compose -f /opt/monitoring/docker-compose.yml logs <service-name> --tail 50
```

Verify that Alloy agent is running:
- Check for component's Health
- Errors
- Discovery (`discovery.docker.containers`)
```text
http://<VM_IP>:12345
```

(Metrics) Check VictoriaMetrics 
```text
http://<VM_IP>:8428/vmui

- Try: scrape_samples_scraped
```

(Logs) Check Loki
```bash
curl -s "http://<VM_IP>:3100/loki/api/v1/labels" | jq
```


