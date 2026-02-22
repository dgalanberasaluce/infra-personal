# HTTP Proxy

Caddy is configured to act as a reverse proxy for the services running in the home lab. This allows to access them using friendly domain names instead of IP addresses and ports.


**Caddy's default configuration (`/etc/caddy/Caddyfile`):**
```text
# GLOBAL OPTIONS
{
  log default {
    output file /var/log/caddy/caddy.log {
      roll_size 10mb
      roll_keep 5
      roll_keep_for 720h  # 30 days
    }
    format json     
    level INFO
  }

  log errors {
     output file /var/log/caddy/errors.log {
       roll_size 10MiB
       roll_keep 5
       roll_keep_for 720h
    }
    format json
    level ERROR
  }
}

import /etc/cady/sites/*.caddy
```

## Set up caddy
- Create `caddy` service user and `caddy` group
- Create directory to store logs: `/var/log/caddy`
- Update ownership of the log directory: `chown -R caddy:caddy /var/log/caddy`
- (Alpine) Create rc-service `/etc/init.d/caddy` file to manage the caddy service with OpenRC
- (Alpine) Enable and start the caddy service: `rc-update add caddy default` and `rc-service caddy start`


## Best Practices for Log Exporter

1. Log Format to JSON
JSON format makes the logs easier to parse and analyze with log management tools

2. Configure the exporter to track **file inodes**
Using `roll_size`, Caddy will periodically rename `access.log` to something like `access-2026-02-22`...log and create a brand new `access.log`.

>[!WARNING]
>Verify the specific exporter's documentation regarding "log rotation."

If the exporter only watches the name of the file, it will drop logs during that rotation window. **Ensure the exporter is configured to track inodes** or strictly tail active files. (Modern exporters like Filebeat and Promtail do this by default. 

In addition **add Metadata at the Exporter Level** (not in Caddy): 
- Use your exporter's configuration to "enrich" the logs before sending them.
- Add tags/labels: 
    - Attach `hostname`, `environment: <value>`, and `service: caddy` via the exporter

3. Enable exporter buffering
If the centralized logging server goes down or there is a network blip, the exporter needs a place to store logs temporarily so they aren't lost.

>[!WARNING]
> (Alpine) Disk Buffering: configure a maximum disk buffer size for the exporter so it doesn't accidentally fill up the entire Alpine disk while waiting for the network to come back up

5. Keep Local Retention Small
Since the central server is the "source of truth" and holds the long-term log history, we no longer need to retain the logs for a long period on the server

> [!NOTE]
> Set the roll_keep` in Caddy to a small number (e.g., roll_keep 2 or 3). We only need enough local logs to act as a temporary buffer in case the exporter goes offline.
>
> ```text
> `roll_size 10MiB`
> `roll_keep 2`
> `roll_keep_for 72h` 
> ```

## Cheathseet

Validate Caddyfile
```bash
caddy validate --adapter caddyfile --config /etc/caddy/Caddyfile
```

Restart caddy (Alpine) - It is required to take the new config
```bash
rc-service caddy restart
```