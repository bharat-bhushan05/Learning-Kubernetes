### **31. Limiting API Access by IP Address (Admission Controllers + RBAC)**  
- **What it does:**  
  Restricts Kubernetes API access to specific IP ranges through combination of RBAC and network policies.  

**Example (Role for Admin with IP Restrictions):**  
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: limited-api-access
rules:
- apiGroups: [""]
  resources: ["pods", "nodes"]
  verbs: ["get", "list", "watch"]
- apiGroups: [""]
  resources: ["services"]
  verbs: ["create", "update"]
```
**Binding with IP Whitelisting (Using Network Policies):**  
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: api-access
  namespace: kube-system
spec:
  podSelector:
    matchLabels:
      component: kube-apiserver
  ingress:
  - from:
    - ipBlock:
        cidr: 203.0.113.0/24  # Only allow this IP range
```
- **Explanation:**  
  - Restricts API server access to the specified IP range while enforcing RBAC for resource-level permissions.  

**Use Case:**  
  - Prevent unauthorized API server access from external IPs while allowing internal teams to manage clusters.  

---

### **32. Fine-Grained Management for Secrets**  
- **What it does:**  
  Grants access to specific secrets without exposing all secrets in a namespace.  

**Example (Access to Specific Secrets):**  
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: dev
  name: secret-reader
rules:
- apiGroups: [""]
  resources: ["secrets"]
  resourceNames: ["app-secret", "db-credentials"]
  verbs: ["get"]
```
- **Use Case:**  
  - Developers can retrieve specific secrets required for application configuration without accessing sensitive credentials.  

---

### **33. Temporary Roles with Time-Bound Access (Kubernetes CronJob + RBAC)**  
- **What it does:**  
  Grants temporary permissions through time-limited role bindings that expire after a set period.  

**Example (Role Binding Cleanup with CronJob):**  
```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: role-binding-cleaner
  namespace: kube-system
spec:
  schedule: "0 0 * * *"  # Runs daily
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: cleaner
            image: bitnami/kubectl
            command:
            - kubectl
            - delete
            - rolebinding
            - temp-admin-binding
          restartPolicy: OnFailure
```
- **Use Case:**  
  - Provides admin access to engineers during outages and automatically revokes it after the incident window closes.  

---

### **34. Node-Specific Permissions (Node RBAC)**  
- **What it does:**  
  Grants permissions to access resources on specific nodes but not the entire cluster.  

**Example (Node Reader Role):**  
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: kube-system
  name: node-reader
rules:
- apiGroups: [""]
  resources: ["nodes"]
  verbs: ["get", "list"]
  resourceNames: ["worker-node-1", "worker-node-2"]
```
- **Use Case:**  
  - Node-specific permissions for troubleshooting specific nodes without exposing the full cluster.  

---

### **35. Restricting Helm Tiller Access**  
- **What it does:**  
  Restricts users from modifying or deleting Helm releases but allows viewing.  

**Example (Helm Viewer Role):**  
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: kube-system
  name: helm-viewer
rules:
- apiGroups: ["helm.k8s.io"]
  resources: ["releases"]
  verbs: ["get", "list"]
```
- **Use Case:**  
  - Developers can view Helm releases but cannot perform upgrades or rollbacks.  

---

### **36. Managing Persistent Volumes (PV/PVC Access Control)**  
- **What it does:**  
  Grants permissions to manage persistent volumes and claims without affecting other cluster resources.  

**Example (PV Manager Role):**  
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: storage
  name: pv-manager
rules:
- apiGroups: [""]
  resources: ["persistentvolumes", "persistentvolumeclaims"]
  verbs: ["get", "create", "delete"]
```
- **Use Case:**  
  - Storage admins can create and manage PV/PVC resources in isolation from other workloads.  

---

### **37. Restricting Pod Exec Access**  
- **What it does:**  
  Prevents users from executing commands inside pods (`kubectl exec`) while allowing pod management.  

**Example (Pod Management Without Exec):**  
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: app
  name: pod-manager
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["create", "delete", "patch"]
- apiGroups: [""]
  resources: ["pods/exec"]
  verbs: []
```
- **Use Case:**  
  - Developers can manage pods but cannot run arbitrary commands inside containers, reducing security risks.  

---

### **38. Service Mesh Role Control (Istio RBAC Integration)**  
- **What it does:**  
  Implements RBAC for Istio-managed services at the mesh level.  

**Example (Service-Level RBAC in Istio):**  
```yaml
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: frontend-access
  namespace: frontend
spec:
  action: ALLOW
  rules:
  - from:
    - source:
        principals: ["cluster.local/ns/backend/sa/backend-sa"]
    to:
    - operation:
        methods: ["GET", "POST"]
        paths: ["/api/*"]
```
- **Use Case:**  
  - Ensures that only the backend service account can access frontend APIs, blocking all other traffic.  

---

### **39. NetworkPolicy + RBAC (Layer 3 & 7 Control)**  
- **What it does:**  
  Combines Kubernetes `NetworkPolicy` with RBAC to enforce both network and API-level restrictions.  

**Example (Restrict Pod Communication by Role):**  
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-app-access
  namespace: app
spec:
  podSelector:
    matchLabels:
      role: frontend
  ingress:
  - from:
    - podSelector:
        matchLabels:
          role: backend
    - namespaceSelector:
        matchLabels:
          name: app
```
- **Use Case:**  
  - Only backend pods can communicate with frontend pods, even if they have RBAC permissions.  

---

### **40. Multi-Tenancy with ResourceQuota and RBAC**  
- **What it does:**  
  Enforces tenant isolation using `ResourceQuota` and namespace-specific RBAC.  

**Example (Quota Management for Teams):**  
```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: team-quota
  namespace: team-a
spec:
  hard:
    pods: "10"
    requests.cpu: "4"
    requests.memory: 8Gi
```
- **Use Case:**  
  - Prevents one team from over-consuming cluster resources, ensuring fair resource allocation.  
