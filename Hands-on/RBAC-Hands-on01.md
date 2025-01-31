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

## ⚠️ Important EKS Considerations
- **Default Authentication**: EKS uses IAM instead of client certificates
- **CA Certificate Access**: Cluster CA is managed by AWS and not directly accessible
- **Recommended Approach**: Use IAM authentication for EKS clusters
- **Alternative Method**: Create custom CA for certificate signing (not EKS-native)

## 🛠 Prerequisites
- AWS CLI configured with IAM permissions
- `eksctl` and `kubectl` installed
- OpenSSL for certificate generation (alternative method)
- GitHub account

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

## 🚀 Recommended Setup (IAM Authentication)

### 1. Create EKS Cluster
```bash
eksctl create cluster \
  --name rbac-demo \
  --region us-west-2 \
  --node-type t3.medium \
  --nodes 2
```

### 2. Configure AWS Authenticator
```bash
kubectl edit configmap aws-auth -n kube-system
```
Add user mappings:
```yaml
mapUsers: |
  - userarn: arn:aws:iam::<ACCOUNT_ID>:user/dev-user1
    username: dev-user1
    groups:
    - dev-group
  - userarn: arn:aws:iam::<ACCOUNT_ID>:user/qa-user1
    username: qa-user1
    groups:
    - qa-group
  - userarn: arn:aws:iam::<ACCOUNT_ID>:user/test-user1
    username: test-user1
    groups:
    - test-group
```

### 3. Apply Kubernetes Manifests
```bash
kubectl apply -f manifests/
```

## 🔧 Alternative Setup (Custom Certificates)

### 1. Generate Custom CA
```bash
openssl genrsa -out ca.key 2048
openssl req -new -x509 -key ca.key -out ca.crt -subj "/CN=K8s RBAC Demo CA"
```

### 2. Create User Certificates
```bash
for user in dev-user1 qa-user1 test-user1; do
  openssl genrsa -out ${user}.key 2048
  openssl req -new -key ${user}.key -out ${user}.csr -subj "/CN=${user}"
  openssl x509 -req -in ${user}.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out ${user}.crt -days 365
done
```

### 3. Configure kubeconfig
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

### IAM Authentication
```bash
# Dev user access
kubectl --as dev-user1 get pods -n dev

# QA user denial test
kubectl --as qa-user1 delete pods -n qa --all
```

### Certificate Authentication
```bash
# Dev user access
kubectl --context=dev-user1@rbac-demo get pods -n dev

# Test user exec access
kubectl --context=test-user1@rbac-demo exec -it <pod-name> -n test -- /bin/sh
```

## 🚨 Troubleshooting Certificate Errors
If you encounter `Could not open file or uri for loading CA certificate`:
1. **EKS Limitation**: Cannot access cluster CA directly
2. **Solutions**:
   - Use IAM authentication (recommended)
   - Create custom CA as shown in alternative setup
   - For non-EKS clusters: Use `--certificate-authority` flag with kubeconfig

## 🧹 Cleanup
```bash
eksctl delete cluster --name rbac-demo --region us-west-2
aws iam delete-user --user-name dev-user1
aws iam delete-user --user-name qa-user1
aws iam delete-user --user-name test-user1
rm -f *.{key,csr,crt}  # For certificate method
```

## 📝 Notes
1. Replace `<ACCOUNT_ID>` with your AWS account ID
2. IAM method requires proper policy attachments to users
3. Certificate method works best with self-managed clusters
4. Nginx deployments use `envsubst` for dynamic content

## 📥 Push to GitHub
```bash
git init
git add .
git commit -m "EKS RBAC demo with IAM/certificate auth"
git remote add origin https://github.com/<YOUR_USERNAME>/k8s-rbac-demo.git
git push -u origin main
```

## 🔗 Resources
- [EKS IAM Best Practices](https://aws.github.io/aws-eks-best-practices/security/docs/iam/)
- [Kubernetes RBAC Guide](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)
- [OpenSSL Certificate Authority](https://jamielinux.com/docs/openssl-certificate-authority/)
```

Key changes made:
1. Added EKS authentication considerations section
2. Separated IAM and certificate methods
3. Added explicit troubleshooting section
4. Included cleanup steps for both methods
5. Clarified EKS limitations in certificate approach
6. Added IAM user deletion in cleanup
7. Improved verification steps for both auth methods

This version provides clear paths for both recommended (IAM) and alternative (certificate) authentication methods while highlighting EKS-specific constraints.
