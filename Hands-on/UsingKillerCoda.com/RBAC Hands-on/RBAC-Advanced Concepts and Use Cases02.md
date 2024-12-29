### **11. Namespace Admin (Full Control Over One Namespace Only)**  
- **What it does:**  
  Grants full administrative control over a specific namespace without affecting cluster-wide resources.  

**Example:**
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: dev-team
  name: namespace-admin
rules:
- apiGroups: [""]
  resources: ["*"]
  verbs: ["*"]
- apiGroups: ["apps"]
  resources: ["*"]
  verbs: ["*"]
- apiGroups: ["batch"]
  resources: ["*"]
  verbs: ["*"]
```
- **RoleBinding Example (Binding to User or Group):**  
  ```yaml
  apiVersion: rbac.authorization.k8s.io/v1
  kind: RoleBinding
  metadata:
    name: admin-binding
    namespace: dev-team
  subjects:
  - kind: User
    name: alice
  roleRef:
    kind: Role
    name: namespace-admin
    apiGroup: rbac.authorization.k8s.io
  ```

**Use Case:**  
- Developers and project teams can manage resources within their namespaces but cannot escalate privileges cluster-wide.  

---

### **12. Read-Only ClusterRole (Auditor Role)**  
- **What it does:**  
  Provides read-only access to all Kubernetes resources, allowing auditors to inspect the cluster without modifying it.  

**Example:**
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: cluster-auditor
rules:
- apiGroups: [""]
  resources: ["*"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["apps", "batch", "networking.k8s.io"]
  resources: ["*"]
  verbs: ["get", "list", "watch"]
```
- **Use Case:**  
  - Third-party audits or internal compliance checks without risking accidental changes.

---

### **13. Node Access (Granting Permissions to Manage Nodes)**  
- **What it does:**  
  Grants access to view and manage Kubernetes nodes directly.  

**Example:**
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: node-manager
rules:
- apiGroups: [""]
  resources: ["nodes", "nodes/proxy"]
  verbs: ["get", "list", "watch", "patch", "update"]
```
- **Use Case:**  
  - Infrastructure teams responsible for managing nodes and performing maintenance tasks.  

---

### **14. Secret Management (Restrict Access to Secrets)**  
- **What it does:**  
  Grants access to view or manage secrets in a namespace while restricting access to sensitive secrets in other namespaces.  

**Example (Read-Only Secrets Role):**
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: production
  name: secret-reader
rules:
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["get", "list"]
```
- **Use Case:**  
  - Developers can view non-sensitive secrets but cannot modify them.  

---

### **15. Custom Resource Definitions (CRD) Management**  
- **What it does:**  
  Grants permissions to manage custom resources (CRDs) without affecting core Kubernetes resources.  

**Example (Managing CRDs):**
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: crd-manager
rules:
- apiGroups: ["apiextensions.k8s.io"]
  resources: ["customresourcedefinitions"]
  verbs: ["create", "update", "delete", "get", "list", "watch"]
```
- **Use Case:**  
  - Teams deploying their own CRDs (e.g., operators or custom controllers).

---

### **16. Log Viewer (Access to Pod Logs Only)**  
- **What it does:**  
  Grants access to view pod logs without modifying any other resources.  

**Example:**
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: rbac-demo
  name: pod-log-reader
rules:
- apiGroups: [""]
  resources: ["pods/log"]
  verbs: ["get", "list"]
```
- **Use Case:**  
  - Developers can view logs for troubleshooting but cannot modify the pods.

---

### **17. NetworkPolicy Management**  
- **What it does:**  
  Grants permissions to create or manage `NetworkPolicies` in a specific namespace.  

**Example:**
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: staging
  name: network-policy-admin
rules:
- apiGroups: ["networking.k8s.io"]
  resources: ["networkpolicies"]
  verbs: ["create", "delete", "update", "get", "list"]
```
- **Use Case:**  
  - Network admins control ingress/egress traffic for pods within a namespace.  

---

### **18. ServiceAccount Token Management**  
- **What it does:**  
  Grants permissions to create or delete ServiceAccount tokens without modifying the entire ServiceAccount.  

**Example:**
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: dev
  name: token-manager
rules:
- apiGroups: [""]
  resources: ["serviceaccounts/token"]
  verbs: ["create", "delete"]
```
- **Use Case:**  
  - CI/CD pipelines manage their own ServiceAccount tokens dynamically.  

---

### **19. Persistent Volume Claims (PVC) Management**  
- **What it does:**  
  Grants permissions to manage `PersistentVolumeClaims` (PVCs) within a namespace.  

**Example:**
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: production
  name: pvc-manager
rules:
- apiGroups: [""]
  resources: ["persistentvolumeclaims"]
  verbs: ["create", "delete", "update", "get", "list"]
```
- **Use Case:**  
  - Storage admins or stateful applications manage PVCs directly.  

---

### **20. Self-Binding (Grant Users Ability to Bind Roles to Themselves)**  
- **What it does:**  
  Grants users the ability to bind specific roles to themselves (or others) without cluster admin intervention.  

**Example:**
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: dev
  name: self-role-binder
rules:
- apiGroups: ["rbac.authorization.k8s.io"]
  resources: ["rolebindings"]
  verbs: ["create", "update"]
```
- **Use Case:**  
  - Developers can bind roles within their namespace for temporary permissions.

---

### **21. Restricting API Access by IP (Admission Controllers)**  
- **What it does:**  
  While RBAC itself doesn’t restrict IP-based access, you can combine it with admission controllers to enforce IP blocks dynamically.

- **Use Case:**  
  - Preventing access to the Kubernetes API server from unauthorized IP addresses.  

---

### **Best Practices for RBAC:**
1. **Principle of Least Privilege:** Start with minimal permissions and gradually add more as needed.  
2. **Role Audits:** Regularly audit roles and bindings for privilege creep.  
3. **Namespace Isolation:** Create distinct roles for each namespace to avoid accidental cross-namespace access.  
4. **Avoid Wildcards (`*`):** Be explicit in permissions; avoid `*` unless necessary.  
5. **Use Role Aggregation:** Dynamically expand permissions through label-based aggregation.
