### **Real-World RBAC Hands-On Lab for Kubernetes Admin**

This lab will simulate a scenario where you manage a Kubernetes cluster with multiple teams and namespaces. Each team will have different levels of access to the resources they need.

### **Objective**

By the end of this lab, you will:

- Create and manage multiple `Roles` and `RoleBindings` for different teams.
- Create `ClusterRoles` and `ClusterRoleBindings` for managing permissions across namespaces.
- Implement and enforce least privilege access to specific Kubernetes resources.
- Simulate real-world access scenarios, such as read-only access, write access, and admin access.

---

## **Step 1: Set Up Multiple Namespaces**

First, we’ll create three namespaces for different teams: **dev**, **qa**, and **prod**.

```bash
kubectl create namespace dev
kubectl create namespace qa
kubectl create namespace prod
```

Verify the namespaces:

```bash
kubectl get namespaces
```

---

## **Step 2: Create a Service Account for the Development Team**

Create a service account for the **dev** team.

```bash
kubectl create serviceaccount dev-user -n dev
```

Verify the service account:

```bash
kubectl get serviceaccount dev-user -n dev
```

---

## **Step 3: Create a Role for the Development Team**

In the **dev** namespace, create a `Role` that allows the **dev** team to manage Pods, but not to delete them.

Create a file named `dev-role.yaml`:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: dev
  name: pod-manager
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list", "create", "update"]
```

Apply the `Role`:

```bash
kubectl apply -f dev-role.yaml
```

Verify the `Role`:

```bash
kubectl get role pod-manager -n dev
```

---

## **Step 4: Bind the Role to the Service Account**

Now, bind the `pod-manager` role to the `dev-user` service account in the **dev** namespace.

Create a file named `dev-rolebinding.yaml`:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: pod-manager-binding
  namespace: dev
subjects:
- kind: ServiceAccount
  name: dev-user
  namespace: dev
roleRef:
  kind: Role
  name: pod-manager
  apiGroup: rbac.authorization.k8s.io
```

Apply the `RoleBinding`:

```bash
kubectl apply -f dev-rolebinding.yaml
```

Verify the `RoleBinding`:

```bash
kubectl get rolebinding pod-manager-binding -n dev
```

---

## **Step 5: Test Permissions for the Development Team**

Impersonate the `dev-user` service account and test if it can list Pods in the **dev** namespace:

```bash
kubectl auth can-i list pods --as=system:serviceaccount:dev:dev-user -n dev
```

Expected output:

```bash
yes
```

Now, test if the `dev-user` can delete Pods (which should be restricted):

```bash
kubectl auth can-i delete pods --as=system:serviceaccount:dev:dev-user -n dev
```

Expected output:

```bash
no
```

---

## **Step 6: Create a Service Account for the QA Team**

Create a service account for the **qa** team:

```bash
kubectl create serviceaccount qa-user -n qa
```

Verify the service account:

```bash
kubectl get serviceaccount qa-user -n qa
```

---

## **Step 7: Create a ClusterRole for the QA Team**

Create a `ClusterRole` that allows the **qa** team to view Pods across the entire cluster (read-only access).

Create a file named `qa-clusterrole.yaml`:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: pod-reader
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list"]
```

Apply the `ClusterRole`:

```bash
kubectl apply -f qa-clusterrole.yaml
```

Verify the `ClusterRole`:

```bash
kubectl get clusterrole pod-reader -o yaml
```

---

## **Step 8: Create a ClusterRoleBinding for the QA Team**

Bind the `pod-reader` `ClusterRole` to the `qa-user` service account across the entire cluster using a `ClusterRoleBinding`.

Create a file named `qa-clusterrolebinding.yaml`:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: pod-reader-binding
subjects:
- kind: ServiceAccount
  name: qa-user
  namespace: qa
roleRef:
  kind: ClusterRole
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```

Apply the `ClusterRoleBinding`:

```bash
kubectl apply -f qa-clusterrolebinding.yaml
```

Verify the `ClusterRoleBinding`:

```bash
kubectl get clusterrolebinding pod-reader-binding -o yaml
```

---

## **Step 9: Test Permissions for the QA Team**

Impersonate the `qa-user` service account and test if it can list Pods across the entire cluster:

```bash
kubectl auth can-i list pods --as=system:serviceaccount:qa:qa-user --all-namespaces
```

Expected output:

```bash
yes
```

Test if the `qa-user` can create Pods (which should be restricted):

```bash
kubectl auth can-i create pods --as=system:serviceaccount:qa:qa-user --all-namespaces
```

Expected output:

```bash
no
```

---

## **Step 10: Create a Service Account for the Admin Team**

Create a service account for the **admin** team:

```bash
kubectl create serviceaccount admin-user -n prod
```

Verify the service account:

```bash
kubectl get serviceaccount admin-user -n prod
```

---

## **Step 11: Create a ClusterRole for the Admin Team**

Create a `ClusterRole` that allows the **admin** team full access to Pods, Deployments, and Services across the entire cluster.

Create a file named `admin-clusterrole.yaml`:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: admin-pod-manager
rules:
- apiGroups: [""]
  resources: ["pods", "services"]
  verbs: ["*"]
- apiGroups: ["apps"]
  resources: ["deployments"]
  verbs: ["*"]
```

Apply the `ClusterRole`:

```bash
kubectl apply -f admin-clusterrole.yaml
```

Verify the `ClusterRole`:

```bash
kubectl get clusterrole admin-pod-manager -o yaml
```

---

## **Step 12: Create a ClusterRoleBinding for the Admin Team**

Bind the `admin-pod-manager` `ClusterRole` to the `admin-user` service account across the entire cluster using a `ClusterRoleBinding`.

Create a file named `admin-clusterrolebinding.yaml`:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-pod-manager-binding
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: prod
roleRef:
  kind: ClusterRole
  name: admin-pod-manager
  apiGroup: rbac.authorization.k8s.io
```

Apply the `ClusterRoleBinding`:

```bash
kubectl apply -f admin-clusterrolebinding.yaml
```

Verify the `ClusterRoleBinding`:

```bash
kubectl get clusterrolebinding admin-pod-manager-binding -o yaml
```

---

## **Step 13: Test Permissions for the Admin Team**

Impersonate the `admin-user` service account and test if it has full access to Pods, Deployments, and Services across the cluster:

```bash
kubectl auth can-i get pods --as=system:serviceaccount:prod:admin-user --all-namespaces
kubectl auth can-i get services --as=system:serviceaccount:prod:admin-user --all-namespaces
kubectl auth can-i get deployments --as=system:serviceaccount:prod:admin-user --all-namespaces
```

Expected output:

```bash
yes
```

---

## **Step 14: Clean Up**

Once the lab is complete, clean up all resources:

```bash
kubectl delete namespace dev
kubectl delete namespace qa
kubectl delete namespace prod
kubectl delete clusterrole pod-reader
kubectl delete clusterrole admin-pod-manager
kubectl delete clusterrolebinding pod-reader-binding
kubectl delete clusterrolebinding admin-pod-manager-binding
kubectl delete serviceaccount dev-user -n dev
kubectl delete serviceaccount qa-user -n qa
kubectl delete serviceaccount admin-user -n prod
```

---

### **Conclusion**

In this real-world hands-on exercise, you’ve learned how to:

- Create and manage **Roles** and **RoleBindings** for different namespaces.
- Assign **ClusterRoles** and **ClusterRoleBindings** for global permissions across namespaces.
- Implement least privilege access control, simulating real-world use cases for development, QA, and admin teams.

RBAC allows you to manage who can do what in your Kubernetes cluster, ensuring that access is granted only to the right users and service accounts based on their roles and responsibilities.
