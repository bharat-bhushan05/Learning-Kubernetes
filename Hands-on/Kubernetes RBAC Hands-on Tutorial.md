# Kubernetes RBAC Hands-on Tutorial (AWS EKS)

## Overview:

In this tutorial, you'll set up RBAC on an AWS EKS cluster with two nodes. We'll create users, roles, and bindings to control access to specific resources. The goal is to ensure users have appropriate permissions without over-provisioning.

---

## Prerequisites:

- AWS CLI configured with admin permissions
- eksctl installed
- kubectl installed
- AWS IAM user for EKS admin  

### Create AWS IAM User for EKS Admin (Using AWS CLI)

1. Create an IAM user with programmatic access:

```bash
aws iam create-user --user-name eks-admin
```

2. Attach the `AdministratorAccess` policy to the user:

```bash
aws iam attach-user-policy \
  --policy-arn arn:aws:iam::aws:policy/AdministratorAccess \
  --user-name eks-admin
```

3. Create access keys for the IAM user:

```bash
aws iam create-access-key --user-name eks-admin
```

4. Save the `AccessKeyId` and `SecretAccessKey` from the output securely.

5. Configure the AWS CLI with the new IAM user credentials:

```bash
aws configure --profile eks-admin
```

---

## Step 1: Create AWS EKS Cluster with 2 Nodes

```bash
eksctl create cluster \
  --name eks-rbac-demo \
  --version 1.31 \
  --region us-west-2 \
  --nodegroup-name worker-nodes \
  --node-type t3.medium \
  --nodes 2 \
  --nodes-min 2 \
  --nodes-max 2
```

Validate the cluster:

```bash
kubectl get nodes
```

---

## Step 2: Create Namespaces

```bash
kubectl create namespace dev
kubectl create namespace qa
```

---

## Step 3: Create a Role for Pod Management in the 'dev' Namespace

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: dev
  name: pod-manager
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list", "create", "delete"]
```

```bash
kubectl apply -f pod-manager-role.yaml
```

---

## Step 4: Create a RoleBinding for the 'pod-manager' Role

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: pod-manager-binding
  namespace: dev
subjects:
- kind: User
  name: dev-user
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: pod-manager
  apiGroup: rbac.authorization.k8s.io
```

```bash
kubectl apply -f pod-manager-binding.yaml
```

---

## Step 5: Create a Service Account and Bind it to the Role

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: dev-sa
  namespace: dev
```

```bash
kubectl apply -f dev-sa.yaml
```

Bind ServiceAccount to Role:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: sa-binding
  namespace: dev
subjects:
- kind: ServiceAccount
  name: dev-sa
  namespace: dev
roleRef:
  kind: Role
  name: pod-manager
  apiGroup: rbac.authorization.k8s.io
```

```bash
kubectl apply -f sa-binding.yaml
```

---

## Step 6: Test Permissions

Switch to the Service Account:

```bash
kubectl run nginx --image=nginx --namespace=dev --as=system:serviceaccount:dev:dev-sa
kubectl get pods -n dev
```

Try deploying in 'qa' namespace (should fail):

```bash
kubectl run nginx --image=nginx --namespace=qa --as=system:serviceaccount:dev:dev-sa
```

---

## Step 7: Create ClusterRole for Cluster-Wide Read-Only Access

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: cluster-reader
rules:
- apiGroups: [""]
  resources: ["nodes", "pods", "services"]
  verbs: ["get", "list"]
```

```bash
kubectl apply -f cluster-reader.yaml
```

Bind to User:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: cluster-reader-binding
subjects:
- kind: User
  name: qa-user
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: cluster-reader
  apiGroup: rbac.authorization.k8s.io
```

```bash
kubectl apply -f cluster-reader-binding.yaml
```

---

## Step 8: Validate ClusterRole Access

```bash
kubectl auth can-i list pods --as=qa-user
kubectl auth can-i delete pods --as=qa-user
```

---

## Cleanup

```bash
eksctl delete cluster --name eks-rbac-demo
```

