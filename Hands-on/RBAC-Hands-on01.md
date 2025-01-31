# Kubernetes RBAC Hands-on with EKS

![Kubernetes RBAC](https://img.shields.io/badge/Kubernetes-RBAC-blue)
![EKS](https://img.shields.io/badge/Cloud-AWS%20EKS-orange)

A practical demonstration of Kubernetes Role-Based Access Control (RBAC) with three distinct users in an EKS cluster, featuring customized Nginx deployments that display user-specific information.

## 📋 Objectives
- Create 3 users with different access levels:
  - `dev-user1`: Full access in `dev` namespace
  - `qa-user1`: Read-only access in `qa` namespace
  - `test-user1`: Pod exec access in `test` namespace
- Deploy Nginx with dynamic display of:
  - Pod Name
  - User Role
  - Username
  - Pod IP
- Verify access restrictions through CLI and web interface

## 🛠 Prerequisites
- AWS CLI configured with IAM permissions
- `eksctl` and `kubectl` installed
- OpenSSL for certificate generation
- GitHub account (for final push)

## 📂 Repository Structure
```text
k8s-rbac-demo/
└── manifests/
    ├── 01-namespaces.yaml
    ├── 02-rbac-dev.yaml
    ├── 03-rbac-qa.yaml
    ├── 04-rbac-test.yaml
    ├── 05-nginx-dev.yaml
    ├── 06-nginx-qa.yaml
    └── 07-nginx-test.yaml
```

## 🚀 Setup Guide

### 1. Create EKS Cluster
```bash
eksctl create cluster \
  --name rbac-demo \
  --region us-west-2 \
  --node-type t3.medium \
  --nodes 2
```

### 2. Apply Kubernetes Manifests
```bash
kubectl apply -f manifests/
```

### 3. User Setup & Authentication
#### Generate Client Certificates:
```bash
for user in dev-user1 qa-user1 test-user1; do
  openssl genrsa -out ${user}.key 2048
  openssl req -new -key ${user}.key -out ${user}.csr -subj "/CN=${user}"
  openssl x509 -req -in ${user}.csr \
    -CA <PATH_TO_CLUSTER_CA>.crt \
    -CAkey <PATH_TO_CLUSTER_CA>.key \
    -CAcreateserial -out ${user}.crt -days 365
done
```

#### Configure kubeconfig:
```bash
for user in dev-user1 qa-user1 test-user1; do
  kubectl config set-credentials ${user} \
    --client-certificate=${user}.crt \
    --client-key=${user}.key
  
  kubectl config set-context ${user}@rbac-demo \
    --cluster=rbac-demo \
    --user=${user} \
    --namespace=$(echo ${user} | cut -d'-' -f1)
done
```

## 🔍 Verification

### Test RBAC Rules
```bash
# Dev user should have full access
kubectl --context=dev-user1@rbac-demo get pods -n dev

# QA user should fail write operations
kubectl --context=qa-user1@rbac-demo delete pods -n qa --all

# Test user should exec into pods
kubectl --context=test-user1@rbac-demo exec -it <pod-name> -n test -- /bin/sh
```

### Access Nginx Services
Get LoadBalancer URLs:
```bash
kubectl get svc -n dev
kubectl get svc -n qa
kubectl get svc -n test
```

Sample output should show:
```html
Pod Name: nginx-7cfd87b6f5-abcde
User Role: Developer
Username: dev-user1
Pod IP: 192.168.1.5
```

## 🧹 Cleanup
```bash
eksctl delete cluster --name rbac-demo --region us-west-2
rm -f *.{key,csr,crt}  # Remove generated certificates
```

## 📝 Important Notes
1. Replace `<PATH_TO_CLUSTER_CA>` with your actual cluster CA path
2. Nginx uses `envsubst` for real-time environment variable substitution
3. LoadBalancer creation might take 2-3 minutes
4. EKS authentication typically uses IAM - this demo uses certificates for simplicity

## 📥 Push to GitHub
```bash
git init
git add .
git commit -m "Initial commit: EKS RBAC demo"
git remote add origin https://github.com/<YOUR_USERNAME>/k8s-rbac-demo.git
git push -u origin main
```

## 🔗 Helpful Resources
- [Kubernetes RBAC Documentation](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)
- [EKS Authentication Best Practices](https://aws.github.io/aws-eks-best-practices/security/docs/iam/)
- [envsubst Command Documentation](https://linux.die.net/man/1/envsubst)

```

This README provides:
1. Clear setup instructions with copy-paste commands
2. Visual hierarchy with badges and headers
3. Verification steps for both CLI and web interface
4. Important warnings about EKS authentication
5. Cleanup instructions to avoid unnecessary AWS charges
6. GitHub integration guidance

The structure emphasizes practical usability while maintaining important security considerations for EKS environments.
