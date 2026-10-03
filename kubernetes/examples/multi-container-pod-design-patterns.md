# Multi-container Pod design patterns

_Ref: https://labs.iximiuz.com/challenges/single-node-multi-container-patterns-d24ccff1_

## 1. Sidecar

The sidecar container adds a capability to the main container

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: "sidecar-pod"
spec:
  containers:
    - name: logger
      image: busybox
      command: ["sh", "-c", "while true; do date >> /data/log.txt; sleep 2; done"]
      volumeMounts:
        - name: shared-vol
          mountPath: /data
    - name: app
      image: busybox
      command: ["sh", "-c", "tail -f /data/log.txt"]
      volumeMounts: 
        - name: shared-vol
          mountPath: /data
  volumes:
    - name: shared-vol
      emptyDir: {}
```

Verify

```bash
kubectl logs -f sidecar-pod -c app
```

## 2. Adapter

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: adapter-config
data:
  adapter.conf: |
    server {
      listen 80;
      location /legacy-id {
        proxy_pass http://localhost:8080/uuid;
      }
    }
```

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: adapter-pod
  labels:
    run: adapter-pod
spec:
  containers:
    - name: app
      image: ghcr.io/mccutchen/go-httpbin
    - name: adapter
      image: nginx:alpine
      volumeMounts:
        - name: adapter-config
          mountPath: /etc/nginx/conf.d
  volumes:
    - name: adapter-config
      configMap: 
        name: adapter-config
```

```yaml
apiVersion: v1
kind: Service
metadata:
  name: adapter-svc
spec:
  type: ClusterIP
  selector:
    run: adapter-pod
  ports:
    - port: 80
      targetPort: 80
```

Verify
```
IP_ADDRESS=$(kubectl get svc adapter-svc -o jsonpath='{.spec.clusterIP}')
curl http://${IP_ADDRESS}/legacy-id
```

## 3. Ambassador

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: ambassador-token-config
data:
  default.conf: |
    server {
      listen 80;
      location / {
        proxy_pass http://httpbin.infra;
        proxy_set_header X-Api-Key secret-token-123;
      }
    }
```

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: ambassador-pod
spec:
  containers:
    - name: app
      image: busybox
      command: 
        - sh 
        - -c 
        - "while true; do wget -qO- http://localhost:80/headers; echo; sleep 3; done"
    - name: ambassador
      image: nginx:alpine
      volumeMounts:
        - name: ambassador-token-config
          mountPath: /etc/nginx/conf.d
  volumes:
    - name: ambassador-token-config
      configMap:
        name: ambassador-token-config
```

Pre-requirement:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: httpbin
  name: httpbin
  namespace: infra
spec:
  replicas: 1
  selector:
    matchLabels:
      app: httpbin
  template:
    metadata:
      labels:
        app: httpbin
    spec:
      containers:
      - image: ghcr.io/mccutchen/go-httpbin
        name: go-httpbin
        ports:
        - containerPort: 8080
          protocol: TCP
```

Verify
```bash
kubectl exec ambassador-pod -c app -- wget -qO- http://httpbin.infra/headers  # No header X-Api-Key
kubectl exec ambassador-pod -c app -- wget -qO- http://localhost:80/headers   # Shows the header X-Api-Key
```


## 4. Init container

- Init containers run in sequential order
- Each init container must exist with a `0` before the next one starts.
- Init containers terminate before main container

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: init-pod
spec:
  initContainers:
    - name: init1
      image: busybox
      command:
        - sh 
        - -c 
        - "echo init1 >> /data/log.txt"
      volumeMounts:
        - name: shared-vol
          mountPath: /data
    - name: init2
      image: busybox
      command:
        - sh
        - -c
        - "echo init2 >> /data/log.txt"
      volumeMounts:
        - name: shared-vol
          mountPath: /data
  containers:
    - name: app
      image: busybox
      command: 
        - sh 
        - -c 
        - "cat /data/log.txt; sleep infinity"
      volumeMounts:
        - name: shared-vol
          mountPath: /data
  volumes:
    - name: shared-vol
      emptyDir: {}
```

## 5. Native Sidecar

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: native-sidecar-pod
spec:
  initContainers:
    - name: logger
      image: busybox
      command: 
        - sh
        - -c
        - "sleep 30; date >> /data/log.txt; sleep infinity"
      startupProbe:
        exec: 
          command: ["test", "-s", "/data/log.txt"]
        periodSeconds: 2
        failureThreshold: 30
      restartPolicy: Always
      volumeMounts:
        - name: shared-vol
          mountPath: /data
  containers:
    - name: app
      image: busybox
      command:
        - sh
        - -c
        - "cat /data/log.txt; sleep infinity"
      volumeMounts:
        - name: shared-vol
          mountPath: /data
  volumes:
    - name: shared-vol
      emptyDir: {}
```
