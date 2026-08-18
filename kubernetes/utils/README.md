# Utils

## Images

- `curlimages/curl`
- `nginx`
- `busybox`
- `alpine`
- `nicolaka/netshoot`

## Troubleshoot web server

```bash
POD_IP=$(kubectl get pod <pod-name> -o jsonpath='{.status.podIP}')

kubectl run --rm -it --restart Never \
    --image curlimages/curl:latest -- \
    curl -v $POD_IP:80
```
