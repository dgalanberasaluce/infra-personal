# kind 

`kind` helps to set up local Kubernetes clusters with Docker for testing

**Prerequisites**
- Docker running.
- `kind` installed.
- `kubectl` installed.

Examples are provided in `kind/examples`


Quick start
- Quick single-node cluster:

```bash
kind create cluster --name quick
```

- Multi-node cluster (`examples/multi/kind.yaml`):

```bash
kind create cluster --name multi --config examples/multi/kind.yaml
```

- Ingress mapping (`examples/ingress/kind.yaml`):

```bash
kind create cluster --name ingress --config examples/ingress/kind.yaml
```

- Local registry (start registry then create):

```bash
docker run -d --name kind-registry -p 5000:5000 registry:2
kind create cluster --name registry --config examples/registry/kind.yaml
```

- Flux CD integration (see `examples/flux/README.md` for details):

```bash
kind create cluster --name flux --config examples/flux/kind.yaml
```

Kubeconfig and contexts
- Switch context: `kubectl config use-context kind-<name>`

Tips
- Keep small config files in `kind/examples/` and reference them with `--config`.
- Use unique cluster names for parallel tests.
- Delete clusters after tests: `kind delete cluster --name <name>`

Troubleshooting
- Inspect node container logs: `docker logs kind-control-plane`.
- Increase Docker CPU/memory for multi-node clusters.

Examples folder
- `kind/examples/quick` — quick start notes
- `kind/examples/multi` — multi-node config
- `kind/examples/ingress` — port mappings for ingress
- `kind/examples/registry` — registry integration
- `kind/examples/flux` — Flux CD integration

Docs
- https://kind.sigs.k8s.io
