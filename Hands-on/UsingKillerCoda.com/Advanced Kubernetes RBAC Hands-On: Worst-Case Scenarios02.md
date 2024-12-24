Here are additional advanced scenarios that Kubernetes administrators might face in real-world RBAC configurations. These cases help further solidify your understanding of Kubernetes RBAC and security best practices.

---

## **Scenario 6: Preventing a Service Account from Accessing Logs**

In this case, we simulate a scenario where a service account needs to be restricted from accessing **Logs** of Pods running in a cluster.

### **Step 1: Create a Role to Restrict Log Access**

Create a `Role` that allows access to **Pods** but denies access to **Pod Logs**.

Create a file named `restrict-log-access-role.yaml`:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: dev
  name: restrict-log-access
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list", "create", "update"]
- apiGroups: [""]
  resources: ["pods/log"]
  verbs: []
```

Apply the `Role`:

```bash
kubectl apply -f restrict-log-access-role.yaml
```

### **Step 2: Bind the Role to a Service Account**

Create a `RoleBinding` to bind the `restrict-log-access` role to a `serviceAccount` in the **dev** namespace.

Create a file named `restrict-log-access-binding.yaml`:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: restrict-log-access-binding
  namespace: dev
subjects:
- kind: ServiceAccount
  name: dev-user
  namespace: dev
roleRef:
  kind: Role
  name: restrict-log-access
  apiGroup: rbac.authorization.k8s.io
```

Apply the binding:

```bash
kubectl apply -f restrict-log-access-binding.yaml
```

### **Step 3: Test Log Access**

Now, test if the service account can access logs for the Pods:

```bash
kubectl logs <pod-name> --as=system:serviceaccount:dev:dev-user -n dev
```

Expected Output: 

```bash
Error from server (Forbidden): pods "pod-name" is forbidden: User "system:serviceaccount:dev:dev-user" cannot get resource "pods/logs" in API group "" in the namespace "dev".
```

### **Step 4: Mitigate if Log Access is Needed**

If you need the service account to access the logs, update the role with `verbs: ["get", "list"]` on the `pods/log` resource. Otherwise, delete the binding when no longer needed.

---

## **Scenario 7: Risk of Using Wildcard `*` in Permissions**

In this scenario, we will simulate the risks associated with overly permissive rules using the wildcard `*`, which grants unrestricted access.

### **Step 1: Create a ClusterRole with Wildcard Access**

Create a `ClusterRole` with a wildcard permission.

Create a file named `wildcard-clusterrole.yaml`:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: wildcard-access
rules:
- apiGroups: [""]
  resources: ["*"]
  verbs: ["*"]
```

Apply the `ClusterRole`:

```bash
kubectl apply -f wildcard-clusterrole.yaml
```

### **Step 2: Bind the Wildcard Role to a Service Account**

Bind the `wildcard-access` `ClusterRole` to a `serviceAccount` in the **dev** namespace.

Create a file named `wildcard-access-binding.yaml`:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: wildcard-access-binding
subjects:
- kind: ServiceAccount
  name: dev-user
  namespace: dev
roleRef:
  kind: ClusterRole
  name: wildcard-access
  apiGroup: rbac.authorization.k8s.io
```

Apply the binding:

```bash
kubectl apply -f wildcard-access-binding.yaml
```

### **Step 3: Test Access**

Impersonate the `dev-user` and check if it can perform any action.

```bash
kubectl auth can-i '*' --as=system:serviceaccount:dev:dev-user --all-namespaces
```

Expected Output: 

```bash
yes
```

This `dev-user` has unrestricted access to all resources across the entire cluster, which is a major security risk.

### **Step 4: Mitigate the Risk**

Delete the `ClusterRoleBinding` and `ClusterRole` immediately to reduce this risk:

```bash
kubectl delete clusterrolebinding wildcard-access-binding
kubectl delete clusterrole wildcard-access
```

---

## **Scenario 8: Service Account Hijacking (Implication of Using Weak Names)**

In this scenario, we simulate the risk of service account hijacking due to weak or easily guessable names. Attackers might guess names of service accounts and escalate privileges.

### **Step 1: Create a Service Account with a Guessable Name**

Create a service account named `admin-sa` in the `dev` namespace (which could be a targeted name for attackers):

```bash
kubectl create serviceaccount admin-sa -n dev
```

### **Step 2: Bind a ClusterRole to the Service Account**

Now, bind the `cluster-admin` role to the `admin-sa` service account in the **dev** namespace.

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-sa-binding
subjects:
- kind: ServiceAccount
  name: admin-sa
  namespace: dev
roleRef:
  kind: ClusterRole
  name: cluster-admin
  apiGroup: rbac.authorization.k8s.io
```

Apply the binding:

```bash
kubectl apply -f admin-sa-binding.yaml
```

### **Step 3: Test Access**

Impersonate the `admin-sa` service account and check if it has **admin** privileges.

```bash
kubectl auth can-i '*' --as=system:serviceaccount:dev:admin-sa --all-namespaces
```

Expected Output:

```bash
yes
```

This shows that an easily guessable service account name (`admin-sa`) is highly dangerous, especially when bound to critical roles like `cluster-admin`.

### **Step 4: Mitigate Service Account Hijacking Risk**

- Rename service accounts to less guessable names.
- Implement access control tools such as **OPA (Open Policy Agent)** to prevent the creation of such vulnerable service account names.
- Review your RBAC configuration to ensure sensitive service accounts are not bound to highly privileged roles.

Delete the binding and service account for cleanup:

```bash
kubectl delete clusterrolebinding admin-sa-binding
kubectl delete serviceaccount admin-sa -n dev
```

---

## **Scenario 9: Use of `--as` for Privilege Escalation**

Kubernetes allows you to impersonate other users or service accounts via `kubectl auth can-i --as`. This feature can be used for privilege escalation. 

In this case, we’ll simulate unauthorized privilege escalation via the `--as` flag.

### **Step 1: Create a User with Limited Access**

Create a service account `limited-user` with restricted access to resources in the `dev` namespace:

```bash
kubectl create serviceaccount limited-user -n dev
```

### **Step 2: Test Limited Access**

Test that the `limited-user` only has restricted access:

```bash
kubectl auth can-i get pods --as=system:serviceaccount:dev:limited-user -n dev
```

Expected Output:

```bash
no
```

### **Step 3: Test Privilege Escalation**

Now, try impersonating a `cluster-admin` user to escalate privileges:

```bash
kubectl auth can-i get pods --as=system:serviceaccount:dev:limited-user --as=system:serviceaccount:kube-system:admin -n dev
```

Expected Output:

```bash
yes
```

This shows that using `--as` can allow unauthorized privilege escalation if there is no control over who can impersonate whom.

### **Step 4: Mitigate the Risk**

- Control the use of `--as` via **RBAC** by denying the `impersonate` verb on sensitive accounts.
- Use Kubernetes Admission Controllers to enforce strict policies around impersonation.

---

## **Scenario 10: Auditing and Detecting RBAC Misconfigurations**

Finally, this scenario focuses on auditing and detecting RBAC misconfigurations and privilege escalation attempts across the cluster.

### **Step 1: Enable Audit Logs**

Enable and configure Kubernetes audit logs to track all access attempts.

In the **kube-apiserver** configuration file (`/etc/kubernetes/manifests/kube-apiserver.yaml`), add the following flags to enable audit logging:

```yaml
--audit-log-path=/var/log/kubernetes/audit.log
--audit-policy-file=/etc/kubernetes/audit-policy.yaml
```

Create the audit policy file (`/etc/kubernetes/audit-policy.yaml`):

```yaml
apiVersion: audit.k8s.io/v1
kind: Policy
rules:
  - level: Metadata
    resources:
      - resources: ["pods"]
```

### **Step 2: Monitor the Audit Logs**

Use tools like `kubectl logs` or third-party tools (e.g., **Kubeaudit**, **Falco**) to review logs and detect any suspicious RBAC-related events.

For example, search for any suspicious impersonation attempts:

```bash
grep "impersonate" /var/log/kubernetes/audit.log
```

---

## **Conclusion**

In this lab, we’ve covered a variety of advanced real-world RBAC scenarios that Kubernetes administrators commonly face, including:

1. **Privilege Escalation** due to misconfigurations.
2. **Restricting Access** to logs and sensitive resources.
3. **Risk of Wildcard Permissions**.
4. **Service Account Hijacking** and weak account names.
5. **Impersonation and Privilege Escalation** using `--as`.
6. **Auditing and Detecting RBAC Misconfigurations**.

By following **best practices** such as **least privilege**, **restricting impersonation**, and regular **audits**, you can mitigate the risks associated with RBAC misconfigurations in your Kubernetes clusters.
