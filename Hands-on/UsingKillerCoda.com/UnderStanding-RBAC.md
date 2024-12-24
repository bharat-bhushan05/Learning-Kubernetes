To create a hands-on Kubernetes RBAC (Role-Based Access Control) exercise on **killercoda.com**, here’s a complete guide you can follow:

### **Objective**: 
This hands-on exercise will guide you through the creation and management of Kubernetes RBAC, where you will learn how to set up roles, role bindings, service accounts, and permissions in a Kubernetes cluster.

### **Steps to Create the Hands-On Exercise**:

1. **Sign up on KillerCoda**:  
   If you haven’t already, sign up on [KillerCoda](https://killercoda.com/) and create your custom scenario.

2. **Create a New Scenario**:
   - Go to your **Dashboard** and click on **Create New Scenario**.
   - Set a **Title** (e.g., "Kubernetes RBAC Hands-On").
   - Set the **Description** (e.g., "Learn how to create and manage RBAC roles, bindings, and service accounts in Kubernetes").
   - Set the **Environment** as **Kubernetes** (if available).
   
3. **Define the Environment**:
   - Choose Kubernetes as the platform for the scenario.
   - You can set the environment based on a Kubernetes cluster already running, or if KillerCoda supports Kubernetes, it may automatically provision an environment for you.

4. **Scenario Steps**:
   Create a detailed step-by-step guide for the learners. Here’s the outline for your RBAC hands-on lab:

---

### **Kubernetes RBAC Hands-On Exercise Outline**:

#### **Introduction**
Welcome to the Kubernetes RBAC (Role-Based Access Control) hands-on lab. In this exercise, you will learn how to manage access and permissions for users and service accounts in a Kubernetes cluster. You will practice creating roles, role bindings, and configuring service accounts with appropriate permissions.

---

#### **Step 1: Understanding RBAC Components**

RBAC in Kubernetes is composed of four key components:
1. **Role**: Defines a set of permissions in a specific namespace.
2. **ClusterRole**: Defines a set of permissions that can be applied across all namespaces in the cluster.
3. **RoleBinding**: Binds a Role to a user or service account within a specific namespace.
4. **ClusterRoleBinding**: Binds a ClusterRole to a user or service account across all namespaces.

---

#### **Step 2: Set Up the Namespace**

Let's begin by creating a new namespace for testing.

```bash
kubectl create namespace rbac-demo
```

Verify the namespace has been created:

```bash
kubectl get namespaces
```

---

#### **Step 3: Create a Role with Permissions**

In this step, you will create a `Role` within the `rbac-demo` namespace. The role will allow users to view pods and deployments.

Create a file named `role.yaml`:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: rbac-demo
  name: pod-reader
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list"]
- apiGroups: ["apps"]
  resources: ["deployments"]
  verbs: ["get", "list"]
```

Apply the role:

```bash
kubectl apply -f role.yaml
```

Verify the role creation:

```bash
kubectl get role pod-reader -n rbac-demo
```

---

#### **Step 4: Create a RoleBinding**

Now, create a `RoleBinding` to assign the `pod-reader` role to a specific service account or user.

Create a file named `rolebinding.yaml`:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: read-pods
  namespace: rbac-demo
subjects:
- kind: ServiceAccount
  name: pod-reader-sa
  namespace: rbac-demo
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io

```

Apply the RoleBinding:

```bash
kubectl apply -f rolebinding.yaml
```

Verify the rolebinding:

```bash
kubectl get rolebinding read-pods -n rbac-demo
```

---

#### **Step 5: Create a Service Account**

To test the RBAC setup, create a service account that will have the `pod-reader` role.

```bash
kubectl create serviceaccount pod-reader-sa -n rbac-demo
```

Check the service account:

```bash
kubectl get serviceaccount -n rbac-demo
```

---

#### **Step 6: Test RBAC Permissions for Service Account**

Now, use the `kubectl` tool to impersonate the service account and verify if the permissions are correctly assigned.

Switch to the service account:

```bash
kubectl auth can-i get pods --as=system:serviceaccount:rbac-demo:pod-reader-sa -n rbac-demo
```

Expected output:

```bash
yes
```

Now, test with a user who doesn't have the role:

```bash
kubectl auth can-i get pods --as=someuser -n rbac-demo
```

Expected output:

```bash
no
```

---

#### **Step 7: Create a ClusterRole and ClusterRoleBinding**

Next, create a `ClusterRole` to allow access to all namespaces. This role will give `get` and `list` permissions for all pods across the cluster.

Create a file named `clusterrole.yaml`:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  # A ClusterRole can be referenced across namespaces
  # Make sure the name is unique
  name: cluster-pod-reader
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list"]
```

Apply the ClusterRole:

```bash
kubectl apply -f clusterrole.yaml
```

---

#### **Step 8: Create ClusterRoleBinding**

Now, bind the `ClusterRole` to a service account across all namespaces.

Create a file named `clusterrolebinding.yaml`:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: cluster-pod-reader-binding
subjects:
- kind: ServiceAccount
  name: pod-reader-sa
  namespace: rbac-demo
roleRef:
  kind: ClusterRole
  name: cluster-pod-reader
  apiGroup: rbac.authorization.k8s.io
```

Apply the ClusterRoleBinding:

```bash
kubectl apply -f clusterrolebinding.yaml
```

Verify the ClusterRoleBinding:

```bash
kubectl get clusterrolebinding cluster-pod-reader-binding
```
---
### **Step 9: Validate Permissions Using `kubectl auth can-i`**
To check if the `pod-reader-sa` service account has the correct permissions from the `ClusterRole`, impersonate the service account and test the permissions for accessing `pods` across all namespaces:

```bash
kubectl auth can-i get pods --as=system:serviceaccount:rbac-demo:pod-reader-sa
```

If the `ClusterRole` is correctly bound and the permissions are applied, this should return `yes`.

## **Test Cluster-Wide Access for ClusterRole**
Test if the `pod-reader-sa` service account can access pods across the entire cluster, not just in the `rbac-demo` namespace, by impersonating the service account:

```bash
kubectl auth can-i get pods --as=system:serviceaccount:rbac-demo:pod-reader-sa --all-namespaces
```

Expected output:

```bash
yes
```

This verifies that the `ClusterRole` provides cluster-wide access as expected.

## **Check the Permissions of the `someuser`**
Since `someuser` doesn't have a `ClusterRoleBinding` or specific roles assigned, the result for `someuser` should still be `no`:

```bash
kubectl auth can-i get pods --as=someuser --all-namespaces
```

This should return `no` unless `someuser` is explicitly granted permissions.

---

#### **Step 10: Clean-Up**

Finally, clean up all the resources you’ve created during the exercise.

```bash
kubectl delete namespace rbac-demo
kubectl delete clusterrole cluster-pod-reader
kubectl delete clusterrolebinding cluster-pod-reader-binding
kubectl delete role pod-reader -n rbac-demo
kubectl delete rolebinding read-pods -n rbac-demo
kubectl delete serviceaccount pod-reader-sa -n rbac-demo
```

---

### **Conclusion**
-
In this hands-on lab, you've learned how to create and manage Kubernetes RBAC configurations, including roles, role bindings, cluster roles, and cluster role bindings. You've also tested RBAC permissions using service accounts and user impersonation.
---
