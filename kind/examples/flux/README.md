# Flux example

**Summary**

This example shows how to use Flux v2 to manage a simple nginx app via GitOps. It provides a minimal app in `manifests/` and example Flux resources to point Flux at a Git repository.

**Requirements**

- A running kind cluster (`kind create cluster --name flux`)
- `kubectl` installed and pointing at the cluster
- `flux` CLI installed (https://fluxcd.io)
- A Git repository (public or private) that will contain the app manifests. Replace placeholders below with your repo.

**Quick steps**

1. Install Flux in the cluster:

_For testing purposes you can install the Flux controllers without storing their manifests in a Git repository_

```bash
flux install
```

2. Bootstrap Flux to your git repository (example uses an internal forgejo server):

```bash
flux bootstrap gitea \
    --hostname=https://<forgejo-server> \
    --ssh-hostname=<forgejo-server> \
    --owner=<repository-owner> \
    --repository=fleet-infra \
    --branch=main \
    --path=./manifests \
    --ca-file=ca-cert.pem  # Optional, if your forgejo server uses a self-signed certificate
```

This will ask for a **PAT token** that requires the following permissions: `write:organization, write:repositor`. You can create a token in forgejo by going to `Settings > Applications > Generate Tokens`


Some notes on bootstrapping:
- `<forgejo-server>` may be different on the hostname and on the ssh-hostname, depending on your network setup. You can use domain server name or IP address instead.
    - The hostname is used by Flux to pull manifests via HTTPS, while the ssh-hostname is used for pushing changes via SSH.
- Create a git repository (`fleet-infra`) before bootstrapping, as Flux will push the initial commit with the manifests
- The `--path` is the directory in the repository where Flux will look for manifests. You can change this to fit your repo structure.
    - Flux will create the `manifests/flux-system` directory containing flux system components (`gotk-components.yaml`) and a `gotk-sync.yaml` which is a file that configures the `GitRepository` and `Kustomization` to point to the specified path.
- Resources within the [manifests](./manifests) folder are not deployed yet. They will be deployed once you push them to the specified path in your repository
- If using MacOs, make sure that the docker daemon is configured to not overlap the IP range used by kind or by the lan
    - Docker Desktop > Settings > Docker Engine: 
    ```json
    "default-address-pools": [
        {
        "base": "172.17.0.0/16",
        "size": 16
        },
        {
        "base": "172.18.0.0/16",
        "size": 16
        },
        {
        "base": "172.19.0.0/16",
        "size": 16
        },
        {
        "base": "10.200.0.0/16",
        "size": 24
        }
    ],
    ```
    - Restart docker daemon after making this change
    - If required, recreate the kind cluster. Make sure to remove the existing network attached to the kind cluster

3. (Alternative to step 2) If you cannot bootstrap, push the `manifests/` folder to a repo and create a `GitRepository`/`Kustomization` as shown in `flux-gitrepo.yaml`.

Apply the example locally (manual)

```bash
kubectl apply -f flux-gitrepo.yaml
kubectl apply -f flux-kustomization.yaml
```

---

**post-bootstrap steps**

Right now, Flux is running inside your cluster, actively polling your Git repository for changes, and keeping itself up to date. The easiest way to see GitOps in action is to drop a Kubernetes manifest into that repository.

1. Pull the repository into another folder. Add `clusters-kind-01-kustomization.yaml` to the `manifests/` directory and push the changes.
2. Copy the contents of `manifests` directory to `clusters/kind-01/` folder in the repository. Commit and push the changes
3. Watch the changes being applied in the cluster:

```bash
kubectl get all -n nginx-example
```


Files in this example
- `manifests/` — sample nginx Deployment and Service managed by Flux.
- `flux-gitrepo.yaml` — example `GitRepository` resource (replace `url` and `branch`).
- `flux-kustomization.yaml` — example `Kustomization` pointing to the `GitRepository`.


## Notes
- Flux reconciles resources from the referenced repo path; ensure manifests are present there.
- Check Flux status: `flux get kustomizations --all-namespaces` and `flux get sources git`.
- Flux applies resources in the corect order: It is able to create `Namespaces` and `CustomResourceDefinitions` before applying resources that depend on them
- Flux creates the `flux-system` namespace outside of the standard GitOps flow. It is created by the `flux bootstrap` command. Everything else after that should be declarative
- Kubernetes **namespaces** should be created and managed by Flux [Core rule of GitOps: Git must be the single source of truth for the cluster's desired state]
    - If an application owns a namespace exclusively -> Include the `Namespace` yaml in the same directory as the application's resources
    - If using a centralized tenante/namespace management:
        - It is often managed by infrastructure team instead of development teams
        - Developers would have access to push code to app's directory, but not to create new namespaces or alter quotas