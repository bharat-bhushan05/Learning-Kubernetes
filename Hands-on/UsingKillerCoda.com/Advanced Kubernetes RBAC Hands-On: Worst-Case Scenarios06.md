Here are additional advanced Kubernetes RBAC scenarios that Kubernetes administrators may face in real-world environments. These cover advanced access control, service account management, multi-tenant security, and troubleshooting complex RBAC issues.

---

## **Scenario 29: Managing Access for Different Teams in Multi-Tenant Clusters**

In a multi-tenant cluster, multiple teams share the same Kubernetes cluster, but each team should have restricted access to their own namespace and resources.

### **Step 1: Create Namespaces for Different Teams**

Create namespaces for different teams:

```bash
kubectl create namespace team-a
kubectl create namespace team-b
```

### **Step 2: Create Roles for Each Team**

Create a role for each team to allow access to their respective resources (e.g., pods).

#### Role for `team-a`:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-reader
  namespace: team-a
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list"]
```

#### Role for `team-b`:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-reader
  namespace: team-b
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list"]
```

Apply both roles:

```bash
kubectl apply -f team-a-pod-reader-role.yaml
kubectl apply -f team-b-pod-reader-role.yaml
```

### **Step 3: Create RoleBindings for Each Team**

Bind the roles to the respective service accounts.

#### RoleBinding for `team-a`:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: pod-reader-binding
  namespace: team-a
subjects:
- kind: ServiceAccount
  name: team-a-sa
  namespace: team-a
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```

#### RoleBinding for `team-b`:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: pod-reader-binding
  namespace: team-b
subjects:
- kind: ServiceAccount
  name: team-b-sa
  namespace: team-b
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```

Apply both RoleBindings:

```bash
kubectl apply -f team-a-pod-reader-binding.yaml
kubectl apply -f team-b-pod-reader-binding.yaml
```

### **Step 4: Test Access**

Verify if `team-a-sa` can access pods only in `team-a`'s namespace:

```bash
kubectl auth can-i get pods --as=system:serviceaccount:team-a:team-a-sa -n team-a
kubectl auth can-i get pods --as=system:serviceaccount:team-a:team-a-sa -n team-b
```

Expected Output:

```bash
yes
no
```

Similarly, test for `team-b-sa` in `team-b`'s namespace.

### **Step 5: Apply Resource Quotas**

In multi-tenant environments, setting resource quotas helps prevent any team from consuming all resources.

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: team-a-quota
  namespace: team-a
spec:
  hard:
    pods: "10"
    requests.cpu: "2"
    requests.memory: "4Gi"
    limits.cpu: "4"
    limits.memory: "8Gi"
```

Apply the resource quota for `team-a`:

```bash
kubectl apply -f team-a-quota.yaml
```

Repeat the same for `team-b` with different resource limits.

---

## **Scenario 30: Managing Access for External Users (OIDC + RoleBinding)**

In organizations that use OIDC (e.g., AWS Cognito, Google Identity), users can authenticate using an external identity provider. This scenario shows how to assign roles based on an external user’s identity.

### **Step 1: Configure OIDC with Kubernetes**

Ensure that Kubernetes is configured to integrate with an external identity provider (e.g., Google Identity). Set up OIDC authentication for Kubernetes API server.

In your Kubernetes API server configuration:

```yaml
apiServer:
  oidc-issuer-url: https://accounts.google.com
  oidc-client-id: <your-client-id>
  oidc-ca-file: /etc/kubernetes/pki/ca.crt
  oidc-username-claim: email
  oidc-groups-claim: groups
```

### **Step 2: Create Role and ClusterRoleBinding**

Let's assume we have a group in the external identity provider called `developers`.

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: developers-rolebinding
subjects:
- kind: Group
  name: developers
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: view
  apiGroup: rbac.authorization.k8s.io
```

This `ClusterRoleBinding` allows all users in the `developers` group to have read-only access to cluster resources.

Apply the binding:

```bash
kubectl apply -f developers-rolebinding.yaml
```

### **Step 3: Test External User Access**

Test access using a user from the `developers` group:

```bash
kubectl auth can-i get pods --as=external-user@google.com
```

Expected Output:

```bash
yes
```

---

## **Scenario 31: Access Review for Service Accounts in Namespaces**

Managing and auditing service accounts in namespaces is crucial for security. This scenario demonstrates how to audit and review the access of service accounts.

### **Step 1: List All Service Accounts**

```bash
kubectl get serviceaccounts --all-namespaces
```

### **Step 2: Review Roles and RoleBindings**

Check what roles are assigned to service accounts:

```bash
kubectl get rolebindings --all-namespaces
kubectl get clusterrolebindings --all-namespaces
```

### **Step 3: Verify Permissions of a Service Account**

Use the `kubectl auth can-i` command to check the permissions of a service account. For example, check if the `default` service account in the `team-a` namespace can access pods:

```bash
kubectl auth can-i get pods --as=system:serviceaccount:team-a:default -n team-a
```

Expected Output:

```bash
yes
```

### **Step 4: Audit Service Account Access in Detail**

Audit all service accounts in a specific namespace to verify the permissions of each account. This can help you identify accounts that have excessive privileges.

```bash
kubectl auth can-i --list --as=system:serviceaccount:team-a:default -n team-a
```

This lists all the actions the service account can perform within the `team-a` namespace.

---

## **Scenario 32: Service Account Impersonation for Debugging**

When troubleshooting, Kubernetes allows you to impersonate a service account to debug RBAC issues.

### **Step 1: Impersonate a Service Account**

Impersonate the `pod-reader-sa` service account to test if it can access certain resources:

```bash
kubectl auth can-i get pods --as=system:serviceaccount:team-a:pod-reader-sa -n team-a
```

Expected Output:

```bash
yes
```

### **Step 2: Debug Access Issues**

If you’re debugging why a service account is unable to access a resource, use `kubectl auth can-i` commands to test permissions in different namespaces and contexts.

### **Step 3: Impersonate Other Users or Service Accounts**

Impersonate other users or service accounts to verify their access to resources, such as `kubectl auth can-i get pods --as=someuser`.

---

## **Scenario 33: Granular Permissions for Cluster Operators (Non-Admin)**

In large Kubernetes clusters, cluster operators may need specific permissions to manage cluster-wide resources but not full admin access. This scenario demonstrates how to create such roles.

### **Step 1: Create a Custom ClusterRole**

A `ClusterRole` that grants access to some cluster-wide resources, such as nodes or namespaces, but not full admin access.

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: cluster-operator
rules:
- apiGroups: [""]
  resources: ["nodes", "namespaces"]
  verbs: ["get", "list"]
```

### **Step 2: Create ClusterRoleBinding for the Operator**

Bind the `ClusterRole` to the user `cluster-operator-user`:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: cluster-operator-binding
subjects:
- kind: User
  name: cluster-operator-user
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: cluster-operator
  apiGroup: rbac.authorization.k8s.io
```

Apply the binding:

```bash
kubectl apply -f cluster-operator-binding.yaml
```

### **Step 3: Test Cluster Operator Access**

Verify that the `cluster-operator-user` can list nodes and namespaces but cannot create or delete them:

```bash
kubectl auth can-i get nodes --as=cluster-operator-user
kubectl auth can-i delete nodes --as=cluster-operator-user
```

Expected Output:

```bash
yes
no
```

---

## **Scenario 34: Dynamic Role Creation Using Helm Charts**

In environments where Helm charts are used for deployment, dynamic role creation can be automated based on the services or applications being deployed.

### **Step 1: Create a Helm Chart with RBAC**

Define a `Role` and `RoleBinding` in your Helm chart’s `templates/` folder.

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: app-role
  namespace: {{ .Release.Namespace }}
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list"]
```

### **Step 2: Install Helm Chart**

Install the Helm chart to create the resources dynamically:

```bash
helm install app-name ./chart-directory
```

### **Step 3: Test Role and RoleBinding**

Once the chart is deployed, test if the role and role binding work by impersonating the service account:

```bash
kubectl auth can-i get pods --as=system:serviceaccount:app-name:default -n {{ .Release.Namespace }}
```

---

These scenarios cover more advanced use cases and illustrate how you might handle real-world RBAC challenges in Kubernetes. They focus on multi-tenant management, external identity integration, troubleshooting RBAC issues, and securing Kubernetes clusters with fine-grained access controls.
