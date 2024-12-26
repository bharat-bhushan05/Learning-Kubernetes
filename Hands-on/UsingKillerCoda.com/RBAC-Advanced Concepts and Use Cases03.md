### **22. Dynamic Role Aggregation (Label-Based Role Expansion)**  
- **What it does:**  
  Allows dynamic aggregation of permissions by grouping multiple `ClusterRoles` under a single role using labels.  

**Example (Aggregated Role Definition):**  
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: aggregated-developer-role
  labels:
    rbac.example.com/aggregate-to-developer: "true"
aggregationRule:
  clusterRoleSelectors:
  - matchLabels:
      rbac.example.com/aggregate-to-developer: "true"
rules: []
```
- **Child Roles to Aggregate:**  
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: pod-reader
  labels:
    rbac.example.com/aggregate-to-developer: "true"
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list"]
```
- **Explanation:**  
  - Kubernetes dynamically aggregates all `ClusterRoles` with the matching label `rbac.example.com/aggregate-to-developer: true` under `aggregated-developer-role`.  

**Use Case:**  
- Easily extend developer permissions by creating more granular `ClusterRoles` and aggregating them under a parent role.

---

### **23. Impersonation Permissions (Acting as Another User or ServiceAccount)**  
- **What it does:**  
  Grants the ability to impersonate users or service accounts to troubleshoot, test, or access resources on behalf of another identity.  

**Example (Impersonation Role):**  
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: impersonator
rules:
- apiGroups: [""]
  resources: ["users", "groups", "serviceaccounts"]
  verbs: ["impersonate"]
- apiGroups: ["authentication.k8s.io"]
  resources: ["tokenreviews"]
  verbs: ["create"]
```
- **Use Case:**  
  - Cluster administrators or support teams can troubleshoot and debug applications under different user contexts without logging in as that user.  

- **Testing Impersonation:**  
  ```bash
  kubectl auth can-i get pods --as=developer-user
  ```  

---

### **24. Restricting Resource Creation but Allowing Updates**  
- **What it does:**  
  Developers can update existing deployments but cannot create new ones.  

**Example (Restrict Creation Role):**  
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: dev
  name: deployment-updater
rules:
- apiGroups: ["apps"]
  resources: ["deployments"]
  verbs: ["update", "patch"]
```
- **Use Case:**  
  - Prevent accidental deployment creation while still allowing updates to existing resources.  

---

### **25. Fine-Grained Role for ConfigMaps**  
- **What it does:**  
  Grants access to view specific `ConfigMaps` while restricting access to sensitive configuration.  

**Example:**  
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: monitoring
  name: configmap-reader
rules:
- apiGroups: [""]
  resources: ["configmaps"]
  resourceNames: ["grafana-config"]
  verbs: ["get", "list"]
```
- **Explanation:**  
  - `resourceNames` specifies which `ConfigMap` can be accessed.  

**Use Case:**  
  - Developers can view Grafana’s configuration but cannot access other secrets stored in `ConfigMaps`.  

---

### **26. Restricting Resource Deletion**  
- **What it does:**  
  Grants permissions to create and update resources but denies `delete` actions.  

**Example (No Delete Role):**  
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: dev
  name: create-update-only
rules:
- apiGroups: [""]
  resources: ["pods", "services"]
  verbs: ["create", "update"]
```
- **Use Case:**  
  - Developers can manage resources but cannot delete critical workloads by mistake.  

---

### **27. Environment-Specific Access Control**  
- **What it does:**  
  Grants access to `staging` environments while restricting production access.  

**Example (Staging Access Only):**  
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: staging
  name: staging-access
rules:
- apiGroups: [""]
  resources: ["pods", "services", "configmaps"]
  verbs: ["*"]
```
- **Production Restriction (No Access to Production):**  
  ```yaml
  apiVersion: rbac.authorization.k8s.io/v1
  kind: Role
  metadata:
    namespace: production
    name: restricted-access
  rules: []
  ```
- **Use Case:**  
  - Developers freely manage `staging` environments but cannot alter production.  

---

### **28. Emergency Access (Break-Glass Account)**  
- **What it does:**  
  Temporarily grants admin access during emergencies, requiring a time-limited role binding.  

**Example (Emergency Admin Role):**  
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: emergency-cluster-admin
rules:
- apiGroups: [""]
  resources: ["*"]
  verbs: ["*"]
```
- **Time-Limited Binding:**  
  ```yaml
  apiVersion: rbac.authorization.k8s.io/v1
  kind: ClusterRoleBinding
  metadata:
    name: temp-admin-binding
  subjects:
  - kind: User
    name: emergency-user
  roleRef:
    kind: ClusterRole
    name: emergency-cluster-admin
    apiGroup: rbac.authorization.k8s.io
  ```
- **Use Case:**  
  - Break-glass accounts for production outages, revoked after resolving the incident.  

---

### **29. Pod Security Policy (Restricting Pod Capabilities)**  
- **What it does:**  
  Grants the ability to enforce pod security policies (PSP).  

**Example (Restrict Privileged Pods):**  
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: psp-enforcer
rules:
- apiGroups: ["policy"]
  resources: ["podsecuritypolicies"]
  verbs: ["use"]
  resourceNames: ["restricted"]
```
- **Use Case:**  
  - Only specific users can run privileged pods or pods that modify the host.  

---

### **30. ResourceQuota and LimitRange Management**  
- **What it does:**  
  Grants permissions to manage resource quotas and limits in namespaces.  

**Example (Quota Manager Role):**  
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: finance
  name: quota-manager
rules:
- apiGroups: [""]
  resources: ["resourcequotas", "limitranges"]
  verbs: ["create", "delete", "update", "get", "list"]
```
- **Use Case:**  
  - Admins managing quotas and limits to ensure fair resource distribution.  

---

### **Best Practices for Advanced RBAC:**
1. **Implement Logging:** Enable API audit logging to track RBAC-related access attempts.  
2. **Review Bindings Regularly:** Identify misconfigurations or privilege escalations.  
3. **Dynamic Rebinding:** Use automation to rebind roles if unauthorized changes occur.  
4. **ServiceAccount Isolation:** Assign minimal privileges to default `ServiceAccounts` to avoid over-permissioning.
