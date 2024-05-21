# Grafana

```bash
docker-compose up -d
```

```bash
docker-compose exec -it grafana bash
```

```
/var/lib/grafana
- alerting/
- csv/
- pdf/
- plugins/
- png/
- grafana.db


/etc/grafana
- grafana.ini
- ldap.toml
- provisioning/
  - access-control
  - alerting
  - dashboards
  - datasources
  - notifiers
  - plugins
```

- [ ] Include Testdata Data source during the initial setup
  - https://grafana.com/docs/grafana/latest/datasources/testdata/
  - It creates simulated time series data for any panel
  - Helps to verify dashboard functionality since it can safely an easily share the data