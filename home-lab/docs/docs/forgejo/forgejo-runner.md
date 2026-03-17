# Forgejo Runner

## Docker in docker

Docker in Docker (dind) is a configuration where a docker daemon runs inside a container that is itself managed by a Docker instance.
Technically, this is achieved by running a container using the `docker:dind` image.

>[!CAUTION]
> **Docker-in-docker** introduces **several criticial security risks** because it requires the container to run in privileged mode (`--privileged`).
>The `--privileged` flag grats the container nearly all the **capabilities** of the host machine
>
> _"By default, Docker containers are **unprivileged** and cannot, for example, run a Docker daemon inside a Docker container"_
> https://docs.docker.com/engine/containers/run/#runtime-privilege-and-linux-capabilities
>
> **Resources**
> - https://learn.snyk.io/lesson/container-runs-in-privileged-mode

In the current setup, Docker in Docker is integrated with a forgejo runner, which itself runs as a container as well. Forgejo runner need access 
to a docker daemon (aka dind) to run other images.

The forgejo-runner runs a container that is configured with the `DOCKER_HOST` environment variable pointing to the `dind` sidecar.
```yaml
# docker-compose.yml
services:
  dind:
    image: "docker:29.3.0-dind"
    privileged: true
    command: ['dockerd', -'H', 'tcp://0.0.0.0:2375']

  forgejo-runner:
    image: "code.forgejo.org/forgejo/runner"
    environment:
      DOCKER_HOST: tcp://dind:2375
```

**Dind custom configuration**

Having an internal domain served by an internal dns server and having self-signed certificates bring a lot of issues. 
Creating a multilayer approach where a docker daemon runs as a container within docker on a virtual machine adds more complexity.

For example, some containers may have their own `/etc/resolv.conf` or docker may update it pointing out to external servers (e.g `1.1.1.1`, `8.8.8.8`).
These external servers do not resolve internal domains. 

With this set up, I need to take into account the following considerations:
- The dind container has acccess (`--privileged`) to the host kernel (the virtual machine)
- dind maintains its own /var/lib/docker. Be aware of replicated storage (persistent volumes and images)  
- By default, containers spawned inside dind might bypass some host-level network restrictions
- Image layers may be epheral, they may not be cached.

The main `dockerd` is running as rootless (using `docker` user). This adds a layer of security, protecting the host's `root` user.

I had to set up the following configuration in dind:
- (Pre): Set up self signed CA in virtual machine
  - `/usr/local/share/ca-certificates/homelab-ca.crt`
  - Run `update-ca-certificates` 

```yaml
services:
  dind:
    volumes:
      - "./dind-config/daemon.json:/etc/docker/daemon.json:ro"
      - "/etc/ssl/certs:/etc/ssl/certs:ro"
      - "/run/systemd/resolve/resolv.conf:/etc/resolv.conf:ro"
```

which `dind-config/daemon.json`:
```jsonc
{
  "insecure-registries": ["forgejo.internal"], // It didn't work to me
  "tls": false,
  "dns": [<INTERNAL_IP>] 
}
```
- `insecure-registries` tells docker to trust the specified domains. However it did not work to me
- `<INTERNAL_IP` is the IP of the dns resolver (e.g dns server, router server, etc)
- `"tls": false` is used to simplify the connection between runner and daemon in this local "controlled" environent 


**Using self hosted images**

A forgejo job runs in its own docker network isolated for that pipeline. If the forgejo action requires a self hosted image,
forgejo runner is not able to resolve internal domains, then `docker pull` would fail.

Found a fix that actually works without breaking everything: just expose the dind port in docker-compose and set `DOCKER_HOST: tcp://172.17.0.1:2375` in the Forgejo step's env

For example:
```yaml
services:
  dind:
    volumes:
      - "/etc/ssl/certs:/etc/ssl/certs:ro"
    ports:
      - "172.17.0.1:2375:2375"
```

`172.17.0.1` is the internal network endpoint (`docker0` bridge) created by `dind`. It is usually the Gateway IP of docker

It is also required to mount the host certificate directory (`"/etc/ssl/certs:/etc/ssl/certs:ro"`) since `docker pull` ignores linux certificates (`/etc/ssl/certs`). 
I had to copy `/usr/local/share/ca-certificates/homelab-ca.crt` to `/etc/docker/certs.d/forgejo.internal/ca.crt`


## Forgejo Actions
- workflow > job > step
- `GITHUB_ENV` vs `GITHUB_OUTPUT`
  - `echo "MY_TOKEN=$TOKEN" >> $GITHUB_ENV`
- Mask secrets in logs: `echo ::add-mask::$TOKEN`
