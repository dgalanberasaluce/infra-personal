# Kind & ArgoCD

Set up cluster
```bash
kind create cluster --config kind-config.yaml --name argo-cluster
```

Deploy argocd using helm
```bash
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

helm install argocd argo/argo-cd \
  --namespace argocd \
  --create-namespace \
  --set server.service.type=NodePort \
  --set server.service.nodePort=30080 \
  --set repoServer.service.type=NodePort \
  --set repoServer.service.nodePort=30081 \
  --set dex.service.type=NodePort \
  --set dex.service.nodePort=30082 \
  --set grafana.service.type=NodePort \
  --set grafana.service.nodePort=30083
```

**Access argocd**

1. Get the initial admin password

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

2. Access the ArgoCD UI

```bash
# Get the service URL
kubectl -n argocd get svc argocd-server -o jsonpath="{.spec.ports[0].nodePort}"
# Default port is 30080

# Or use port forwarding for local access
kubectl -n argocd port-forward svc/argocd-server 8080:443
```


**Set up argocd cli**

```bash
# Add the cluster to argocd
argocd login localhost:30080 --insecure --username admin --password <initial-password>

# Or if using port-forwarding:
argocd login localhost:8080 --insecure --username admin --password <initial-password>
```

**Cleanup**

```bash
kind delete cluster --name argo-cluster
```