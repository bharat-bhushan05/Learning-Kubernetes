Here are more advanced, real-world Kubernetes RBAC hands-on scenarios that cover a wider range of use cases and best practices for Kubernetes administrators. These scenarios address different facets of RBAC, including managing access for external systems, fine-grained access control, automating RBAC management, and securing service-to-service communications.

---

## **Scenario 19: Granting Limited Permissions to Automated Systems (CI/CD)**

Automated systems like CI/CD pipelines often require access to specific resources but with limited permissions to avoid potential misuse. In this scenario, we'll create a service account for a CI/CD pipeline and assign it specific permissions.

### **Step 1: Create a CI/CD Namespace**

```bash
kubectl create namespace ci-cd
```

### **Step 2: Create Service Account for CI/CD System**

```bash
kubectl create serviceaccount ci-cd-system -n ci-cd
```

### **Step 3: Define Permissions for CI/CD System**

The CI/CD system needs permission to create deployments and read configmaps, but not full control over all resources.

Create a `Role` for limited CI/CD access:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: ci-cd-limited-access
  namespace: ci-cd
rules:
- apiGroups: [""]
  resources: ["configmaps"]
  verbs: ["get", "list"]
- apiGroups: ["apps"]
  resources: ["deployments"]
  verbs: ["create", "get", "list"]
```

Apply the `Role`:

```bash
kubectl apply -f ci-cd-limited-access-role.yaml
```

### **Step 4: Bind Role to CI/CD Service Account**

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: ci-cd-limited-access-binding
  namespace: ci-cd
subjects:
- kind: ServiceAccount
  name: ci-cd-system
  namespace: ci-cd
roleRef:
  kind: Role
  name: ci-cd-limited-access
  apiGroup: rbac.authorization.k8s.io
```

Apply the `RoleBinding`:

```bash
kubectl apply -f ci-cd-limited-access-binding.yaml
```

### **Step 5: Test the CI/CD Service Account Access**

Check if the CI/CD system can access only the allowed resources:

```bash
kubectl auth can-i create deployments -n ci-cd --as=system:serviceaccount:ci-cd:ci-cd-system
```

Expected Output:

```bash
yes
```

Test if it can access resources outside the allowed scope:

```bash
kubectl auth can-i create pods -n ci-cd --as=system:serviceaccount:ci-cd:ci-cd-system
```

Expected Output:

```bash
no
```

This ensures that the CI/CD system has only the permissions it needs, minimizing security risks.

---

## **Scenario 20: Implementing a "Least Privilege" Access Policy**

In a production environment, the principle of "least privilege" is essential. This scenario demonstrates how to ensure that users or service accounts only have access to the minimal set of resources they need to perform their job.

### **Step 1: Create a Namespace for Developers**

```bash
kubectl create namespace developers
```

### **Step 2: Define a Role with Limited Permissions**

Create a role that only allows `get` and `list` actions on `pods` within the `developers` namespace.

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-reader
  namespace: developers
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list"]
```

Apply the `Role`:

```bash
kubectl apply -f pod-reader-role.yaml
```

### **Step 3: Create a Service Account for Developer Users**

```bash
kubectl create serviceaccount developer-user -n developers
```

### **Step 4: Bind Role to Developer Service Account**

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: pod-reader-binding
  namespace: developers
subjects:
- kind: ServiceAccount
  name: developer-user
  namespace: developers
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```

Apply the `RoleBinding`:

```bash
kubectl apply -f pod-reader-binding.yaml
```

### **Step 5: Verify Permissions for Developer User**

Test if the `developer-user` can access only the allowed resources:

```bash
kubectl auth can-i get pods -n developers --as=system:serviceaccount:developers:developer-user
```

Expected Output:

```bash
yes
```

Test if the user can access a resource outside their allowed permissions:

```bash
kubectl auth can-i create deployments -n developers --as=system:serviceaccount:developers:developer-user
```

Expected Output:

```bash
no
```

---

## **Scenario 21: Using ClusterRole for Global Access Control**

In multi-tenant clusters, you may want to provide users with global roles that span multiple namespaces or even the entire cluster. ClusterRoles enable this level of access.

### **Step 1: Create ClusterRole for Cluster-wide Access**

Create a `ClusterRole` that allows access to `pods` and `deployments` across the entire cluster:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: cluster-wide-reader
rules:
- apiGroups: [""]
  resources: ["pods", "deployments"]
  verbs: ["get", "list"]
```

Apply the `ClusterRole`:

```bash
kubectl apply -f cluster-wide-reader-clusterrole.yaml
```

### **Step 2: Bind ClusterRole to a User**

Bind the `cluster-wide-reader` `ClusterRole` to a specific user or service account for access across all namespaces:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: cluster-wide-reader-binding
subjects:
- kind: User
  name: global-user
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: cluster-wide-reader
  apiGroup: rbac.authorization.k8s.io
```

Apply the `ClusterRoleBinding`:

```bash
kubectl apply -f cluster-wide-reader-binding.yaml
```

### **Step 3: Test Cluster-wide Access for User**

Test if the `global-user` can access resources across the entire cluster:

```bash
kubectl auth can-i get pods --as=global-user
```

Expected Output:

```bash
yes
```

This demonstrates the use of `ClusterRole` for global access control.

---

## **Scenario 22: Using Role Aggregation for Multiple Permissions**

Sometimes, a user or service account may require a combination of permissions from different roles. You can use `Role` aggregation to assign multiple roles to a user.

### **Step 1: Create Multiple Roles**

First, create two roles: one for `pod-reader` and one for `service-reader`.

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-reader
  namespace: developers
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: service-reader
  namespace: developers
rules:
- apiGroups: [""]
  resources: ["services"]
  verbs: ["get", "list"]
```

Apply the roles:

```bash
kubectl apply -f pod-reader-role.yaml
kubectl apply -f service-reader-role.yaml
```

### **Step 2: Aggregate Roles via RoleBinding**

Bind both roles to a single service account:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: role-aggregation-binding
  namespace: developers
subjects:
- kind: ServiceAccount
  name: developer-user
  namespace: developers
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
- kind: Role
  name: service-reader
  apiGroup: rbac.authorization.k8s.io
```

Apply the aggregation binding:

```bash
kubectl apply -f role-aggregation-binding.yaml
```

### **Step 3: Test Combined Permissions**

Test if the `developer-user` can access both `pods` and `services`:

```bash
kubectl auth can-i get pods -n developers --as=system:serviceaccount:developers:developer-user
kubectl auth can-i get services -n developers --as=system:serviceaccount:developers:developer-user
```

Expected Output:

```bash
yes
yes
```

---

## **Scenario 23: Automatically Managing Roles with Helm and RBAC**

Managing RBAC roles can become tedious, especially when there are many microservices that require different permissions. Using Helm charts to manage RBAC roles can help automate this process.

### **Step 1: Install a Helm Chart with RBAC Definitions**

Create a `Chart.yaml` for your Helm chart with RBAC roles included:

```yaml
apiVersion: v2
name: myapp
version: 1.0.0
rbac:
  create: true
```

### **Step 2: Define Roles in Templates**

Inside the `templates` folder, create `role.yaml`:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: myapp-role
  namespace: {{ .Release.Namespace }}
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list"]
```

### **Step 3: Install Helm Chart**

Deploy the chart:

```bash
helm install myapp ./myapp-chart
```

This approach automates RBAC management when deploying applications using Helm.

---

## **Conclusion**

These advanced RBAC scenarios cover a broad spectrum of real-world Kubernetes administrative tasks:

- Managing permissions for **CI/CD systems** with limited access.
- Enforcing **least privilege** access policies.
- Granting **global access** using `ClusterRole`.
- Aggregating multiple roles for **combined permissions**.
- Automating RBAC role management with **Helm charts**.

These scenarios will help you master advanced RBAC configurations and prepare for managing complex Kubernetes environments in production.
