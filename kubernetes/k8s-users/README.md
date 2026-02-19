# Kubernetes Users

_Note: These exercises where created using Gemini 3.0. They were reviewed and updated_

## Exercise 1: The manual certificate method (External Users)
Kubernetes identifies users by the `Common Name (CN)` field in a valid x509 certificate.

The goal of this exercise is to create a user named `auditor` who can only read pods in the `team-blue` namespace.

**List of Tasks**

1. Generate keys using `openssl`
    - Tip: Set the subject to `\CN=auditor\O=team-a`. The `O` (Organization) maps to k8s groups
2. Sign via API: Don't self-sign. Wrap the CSR in kubernetes
    - Tip: `CertificateSigningRequest`
    - Tip: `kubectl certificate approve`
3. Retrieve the signed certificate from the API and decode it from **base64**
4. Setup RBAC
    - Create a `Role/RoleBinding` allowing `get/list` on `pods`
5. Create a new kubeconfig file that uses these credentials
6. Test
    - Try to list nodes. It should fail
    - Try to list pods in `team-blue` namespace. It should pass

<details>
<summary><b>Solution</b></summary>

1. Generate keys using `openssl`
```bash
# Generate keys using openssl
openssl genrsa -out auditor.key 2048
openssl req -new -key auditor.key -out auditor.csr -subj "/CN=auditor/O=team-a"
```

2. Sign via API: Don't self-sign. Wrap the CSR in kubernetes
```bash
CSR_BASE64=$(cat auditor.csr | base64 | tr -d "\n")

cat > auditor-csr.yaml <<EOF
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: auditor-csr
spec:
  request: ${CSR_BASE64}
  signerName: kubernetes.io/kube-apiserver-client
  expirationSeconds: 86400  # 1 day validity
  usages:
  - client auth
EOF

kubectl apply -f auditor-csr.yaml

# Approve csr
kubectl certificate approve auditor-csr
```

3. Retrieve the signed certificate from the API

```bash
kubectl get csr auditor-csr -o jsonpath='{.status.certificate}' | base64 -d > auditor.crt
```

4. Setup RBAC

```bash
# Create Role
cat > team-blue-pods-readonly-role.yml <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: team-blue
  name: pods-readonly
rules:
- apiGroups: [""] # "" indicates the core API group
  resources: ["pods", "pods/log"]
  verbs: ["get", "watch", "list"]
EOF

kubectl apply -f team-blue-pods-readonly-role.yml

# Create RoleBinding
cat > team-blue-pods-readonly-rolebinding.yml <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  namespace: team-blue
  name: pods-readonly
subjects:
- kind: User
  name: auditor # This must match the CN in the certificate
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: pods-readonly
  apiGroup: rbac.authorization.k8s.io
EOF

kubectl apply -f team-blue-pods-readonly-rolebinding.yml
```

5. Create kubeconfig
```bash
CLUSTER_NAME=$(kubectl config view --minify -o jsonpath='{.clusters[0].name}')
SERVER_URL=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')
CA_DATA=$(kubectl config view --minify --raw -o jsonpath='{.clusters[0].cluster.certificate-authority-data}')

cat > kubeconfig <<EOF
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: ${CA_DATA}
    server: ${SERVER_URL}
  name: ${CLUSTER_NAME}
contexts:
- context:
    cluster: ${CLUSTER_NAME}
    namespace: team-blue
    user: audit
  name: audit-context
current-context: audit-context
kind: Config
preferences: {}
users:
- name: audit
  user:
    client-certificate: ${PWD}/auditor.crt
    client-key: ${PWD}/auditor.key
EOF
```

</details>


## Exercise 2: Service Accounts

External CI/CD systems should use Service Accounts (SA) instead of user certificates.

Goal: Create an automated `deployer` identity that can update images but not delete the database

**List of Tasks**

1. Create a `ServiceAccount` named `ci-bot`
2. Generate Token:
-  Use `kubectl create token ci-bot --duration=24h` (short-lived token)
3. Use `curl` instead of `kubectl` to hit the Kubernetes API directly using the token as a `Bearer` header
```bash
curl -k -H "Authorization: Bearer <TOKEN>" https://<API_IP>/api/v1/namespaces/default/pods
```
4. Refine RBAC: Bind a role that allows patch on deployments but explicitly nothing else


## Exercise 3: Context and Kubeconfig management

Goal: Merge a new user context into the existing config seamlessly

1. Take the certs/keys from Exercise 1 and create a standalone file `auditor-config.yaml`
2. Use the `KUBECONFIG` environment variable to load both files:
```bash
export KUBECONFIG=~/.kube/config:./auditor-config.yaml
```
3. Run `kubectl config view --flatten > merged_config.yaml`
4. Set up `kubectx` and practice switching between the admin context and the `auditor` context instantly.


## (WIP) Exercise 4: OIDC Integration

Goal: Implement a production-grade OIDC setup and understand `kubelogin`

Requirements:
- OIDC server (e.g Authentik)

**List of Tasks**
1. Read about the OIDC (OpenID Connect) flow in Kubernetes
2. Install `kubelogin` plugin

**Step 1: Authentik Configuration**
1. Create Provider
- Applications > Pr