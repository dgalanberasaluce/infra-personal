# Kind

## Create cluster
```bash
kind create cluster --config <kind-config-file>
```

## Node images
Get the latest image from https://github.com/kubernetes-sigs/kind/releases

## Expose metricss
```bash
# Install either metrics-server or kube-state-metrics using kustomize
kubectl apply -k metrics-server
kubectl apply -k kube-state-metrics/k8s-v{kubernetes-version}/
```
