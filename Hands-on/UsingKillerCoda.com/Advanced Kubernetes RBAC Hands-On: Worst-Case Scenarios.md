### **Advanced Kubernetes RBAC Hands-On: Worst-Case Scenarios**

In this advanced hands-on lab, we will simulate worst-case scenarios that Kubernetes Administrators might face when dealing with misconfigurations, escalating privileges, and unauthorized access attempts. These situations will help you better understand how to mitigate security risks in a real-world Kubernetes cluster.

### **Objective**

By the end of this lab, you will:

- Simulate scenarios where a user has excessive privileges and how to mitigate this.
- Explore the risks of too broad access and how to implement least privilege.
- Understand how to audit and detect privilege escalations and misuse of service accounts.
- Implement security best practices to harden RBAC policies.

---

## **Scenario 1: Privilege Escalation (Misconfigured Role/ClusterRole)**

In this scenario, we will simulate a user having more privileges than necessary, leading to a potential privilege escalation.

### **Step 1: Create an Excessively Powerful ClusterRole**

Imagine you’ve mistakenly given a user full access to resources across all namespaces.

Create a file named `excessive-clusterrole.yaml` that grants full permissions across the entire cluster.

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: excessive-access
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

Apply the `ClusterRole`:

```bash
kubectl apply -f excessive-clusterrole.yaml
```

### **Step 2: Bind the ClusterRole to a Service Account**

Bind the `excessive-access` `ClusterRole` to a service account in a specific namespace (e.g., **dev**).

Create a file named `excessive-access-binding.yaml`:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: excessive-access-binding
subjects:
- kind: ServiceAccount
  name: dev-user
  namespace: dev
roleRef:
  kind: ClusterRole
  name: excessive-access
  apiGroup: rbac.authorization.k8s.io
```

Apply the binding:

```bash
kubectl apply -f excessive-access-binding.yaml
```

### **Step 3: Test the Escalated Privileges**

Impersonate the `dev-user` service account and check if it has full access:

```bash
kubectl auth can-i '*' --as=system:serviceaccount:dev:dev-user --all-namespaces
```

Expected Output: 

```bash
yes
```

This `dev-user` now has full access across the cluster, even though the role should be restricted to a limited set of operations. This is a dangerous misconfiguration.

### **Step 4: Mitigate the Privilege Escalation**

To fix this, delete the `ClusterRoleBinding` and `ClusterRole`:

```bash
kubectl delete clusterrolebinding excessive-access-binding
kubectl delete clusterrole excessive-access
```

---

## **Scenario 2: Restricting Access to Critical Resources**

In this scenario, we will restrict access to a **Deployment** resource while giving access to other resources like Pods and Services.

### **Step 1: Create a Role for Restricted Access**

Create a `Role` that allows access to **Pods** and **Services** but restricts access to **Deployments**.

Create a file named `restricted-access-role.yaml`:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: dev
  name: restricted-access
rules:
- apiGroups: [""]
  resources: ["pods", "services"]
  verbs: ["get", "list", "create", "update"]
- apiGroups: ["apps"]
  resources: ["deployments"]
  verbs: []
```

Apply the `Role`:

```bash
kubectl apply -f restricted-access-role.yaml
```

### **Step 2: Bind the Role to a Service Account**

Bind the `restricted-access` `Role` to a service account in the **dev** namespace.

Create a file named `restricted-access-binding.yaml`:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: restricted-access-binding
  namespace: dev
subjects:
- kind: ServiceAccount
  name: dev-user
  namespace: dev
roleRef:
  kind: Role
  name: restricted-access
  apiGroup: rbac.authorization.k8s.io
```

Apply the binding:

```bash
kubectl apply -f restricted-access-binding.yaml
```

### **Step 3: Test Restricted Access**

Impersonate the `dev-user` service account and test access to **Pods** and **Deployments**.

Test access to Pods:

```bash
kubectl auth can-i get pods --as=system:serviceaccount:dev:dev-user -n dev
```

Expected Output: 

```bash
yes
```

Test access to Deployments:

```bash
kubectl auth can-i get deployments --as=system:serviceaccount:dev:dev-user -n dev
```

Expected Output:

```bash
no
```

### **Step 4: Audit and Review Access Logs**

As a Kubernetes administrator, you should always audit the access control logs to detect misconfigurations or unauthorized access attempts. 

Run the following command to see the audit logs:

```bash
kubectl logs -n kube-system $(kubectl get pods -n kube-system -l component=kube-apiserver -o jsonpath='{.items[0].metadata.name}')
```

Look for unusual activity or requests that shouldn't be made by the service account.

---

## **Scenario 3: Preventing Service Account from Accessing Sensitive Resources (Pod Secrets)**

In this scenario, we'll prevent a service account from accessing **Secrets** in the **dev** namespace.

### **Step 1: Create a Role to Restrict Access to Secrets**

Create a `Role` that denies access to **Secrets** in the **dev** namespace.

Create a file named `restrict-secrets-role.yaml`:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: dev
  name: restrict-secrets
rules:
- apiGroups: [""]
  resources: ["secrets"]
  verbs: []
```

Apply the `Role`:

```bash
kubectl apply -f restrict-secrets-role.yaml
```

### **Step 2: Bind the Role to the Service Account**

Bind the `restrict-secrets` `Role` to the `dev-user` service account.

Create a file named `restrict-secrets-binding.yaml`:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: restrict-secrets-binding
  namespace: dev
subjects:
- kind: ServiceAccount
  name: dev-user
  namespace: dev
roleRef:
  kind: Role
  name: restrict-secrets
  apiGroup: rbac.authorization.k8s.io
```

Apply the binding:

```bash
kubectl apply -f restrict-secrets-binding.yaml
```

### **Step 3: Test Secrets Access**

Impersonate the `dev-user` service account and test if it can access **Secrets** in the **dev** namespace:

```bash
kubectl auth can-i get secrets --as=system:serviceaccount:dev:dev-user -n dev
```

Expected Output:

```bash
no
```

---

## **Scenario 4: Detecting Privilege Escalation Attempts via Impersonation**

In this scenario, we will simulate a privilege escalation attempt where a service account tries to impersonate an admin account.

### **Step 1: Create a ClusterRoleBinding with Admin Privileges**

Create an `admin` `ClusterRole` binding for a service account:

```bash
kubectl create clusterrolebinding admin-binding --clusterrole=cluster-admin --user=dev-user
```

### **Step 2: Test Impersonation**

Impersonate the `dev-user` and check if it can escalate to `cluster-admin` privileges.

```bash
kubectl auth can-i get nodes --as=dev-user
```

Expected Output:

```bash
yes
```

This is an unauthorized privilege escalation attempt. To mitigate this:

### **Step 3: Revoke the Privileges**

Delete the `ClusterRoleBinding`:

```bash
kubectl delete clusterrolebinding admin-binding
```

---

## **Scenario 5: Enforcing Best Practices for RBAC (Least Privilege)**

As an administrator, the best practice is to assign the **least privilege** to users. In this scenario, we’ll:

1. Assign roles with only the necessary permissions.
2. Periodically audit RBAC policies to ensure compliance with security best practices.

### **Step 1: Apply the Least Privilege Principle**

Ensure that service accounts only have access to the specific resources they need to perform their tasks. For example, in the **dev** namespace, only give access to Pods and Deployments:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: dev-role
  namespace: dev
rules:
- apiGroups: [""]
  resources: ["pods", "deployments"]
  verbs: ["get", "list", "create", "update"]
```

### **Step 2: Apply Periodic Audits**

Set up periodic audits using tools like **kube-bench**, **kube-hunter**, or **OPA (Open Policy Agent)** to ensure compliance with security policies.

Install and configure OPA for policy enforcement:

```bash
kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/release-3.6/deploy/gatekeeper.yaml
```

---

### **Conclusion**

In this hands-on lab, we simulated several **worst-case scenarios** Kubernetes admins might face:

- **Privilege escalation** due to overly permissive roles.
- **Unauthorized access** to critical resources like secrets.
- **Impersonation attempts** to gain admin access.
- **Auditing** and detecting misuse of RBAC.

By following best practices such as **least privilege access** and conducting regular audits, you can prevent these security vulnerabilities from affecting your Kubernetes cluster.
