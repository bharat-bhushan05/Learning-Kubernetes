# eksctl Cheat Sheet

**eksctl** is a simple command-line tool to create and manage Kubernetes clusters on AWS EKS.

---

## Table of Contents
- [Installation](#installation)
- [Cluster Management](#cluster-management)
  - [Create Cluster](#create-cluster)
  - [Delete Cluster](#delete-cluster)
  - [List Clusters](#list-clusters)
- [Node Group Management](#node-group-management)
  - [Create Node Group](#create-node-group)
  - [Delete Node Group](#delete-node-group)
  - [Scale Node Group](#scale-node-group)
- [Querying Resources](#querying-resources)
  - [List Node Groups](#list-node-groups)
  - [List Add-ons](#list-add-ons)
  - [List Fargate Profiles](#list-fargate-profiles)
  - [Describe Cluster](#describe-cluster)
  - [Describe Node Group](#describe-node-group)
  - [View Cluster Logs](#view-cluster-logs)
- [Kubernetes Configuration](#kubernetes-configuration)
- [Cluster Upgrades](#cluster-upgrades)
- [Add-ons](#add-ons)
- [Cluster Information](#cluster-information)
- [Advanced Usage](#advanced-usage)
- [Troubleshooting](#troubleshooting)

---

## Installation

1. Download `eksctl` from its [official releases page](https://github.com/weaveworks/eksctl/releases).
2. Install using Homebrew (macOS and Linux):
   ```bash
   brew tap weaveworks/tap
   brew install weaveworks/tap/eksctl
   ```
3. Verify installation:
   ```bash
   eksctl version
   ```

---

## Cluster Management

### Create Cluster
Create a new cluster with default settings:
```bash
eksctl create cluster --name <cluster-name> --region <region>
```
Create a cluster with a config file:
```bash
eksctl create cluster -f cluster-config.yaml
```

### Delete Cluster
Delete an existing cluster:
```bash
eksctl delete cluster --name <cluster-name> --region <region>
```

### List Clusters
List all clusters in a specific region:
```bash
eksctl get cluster --region <region>
```

---

## Node Group Management

### Create Node Group
Add a new node group to an existing cluster:
```bash
eksctl create nodegroup --cluster <cluster-name> --name <node-group-name>
```

### Delete Node Group
Delete a node group from a cluster:
```bash
eksctl delete nodegroup --cluster <cluster-name> --name <node-group-name>
```

### Scale Node Group
Scale a node group to a specific size:
```bash
eksctl scale nodegroup --cluster <cluster-name> --nodes <desired-count> --name <node-group-name>
```

---

## Querying Resources

### List Node Groups
Get all node groups in a cluster:
```bash
eksctl get nodegroup --cluster <cluster-name> --region <region>
```

### List Add-ons
List all add-ons installed in a cluster:
```bash
eksctl get addons --cluster <cluster-name> --region <region>
```

### List Fargate Profiles
List all Fargate profiles in a cluster:
```bash
eksctl get fargateprofile --cluster <cluster-name> --region <region>
```

### Describe Cluster
Get detailed information about a cluster:
```bash
eksctl describe cluster --name <cluster-name> --region <region>
```

### Describe Node Group
Get detailed information about a specific node group:
```bash
eksctl describe nodegroup --cluster <cluster-name> --name <node-group-name> --region <region>
```

### View Cluster Logs
Retrieve logs for your cluster:
```bash
eksctl utils describe-stacks --region <region> --cluster <cluster-name>
```

---

## Kubernetes Configuration

Update your `kubeconfig` file to use the EKS cluster:
```bash
eksctl utils write-kubeconfig --cluster <cluster-name> --region <region>
```

Check the connection between your CLI and cluster:
```bash
kubectl get nodes
```

---

## Cluster Upgrades

Upgrade the control plane version:
```bash
eksctl upgrade cluster --name <cluster-name> --region <region>
```

Upgrade a node group to a new Kubernetes version:
```bash
eksctl upgrade nodegroup --cluster <cluster-name> --name <node-group-name>
```

---

## Add-ons

Install a new add-on:
```bash
eksctl create addon --name <addon-name> --cluster <cluster-name>
```

Update an existing add-on:
```bash
eksctl update addon --name <addon-name> --cluster <cluster-name>
```

Delete an add-on:
```bash
eksctl delete addon --name <addon-name> --cluster <cluster-name>
```

---

## Cluster Information

Get cluster metadata:
```bash
eksctl get cluster --name <cluster-name>
```

List all clusters in your AWS account:
```bash
eksctl get cluster
```

---

## Advanced Usage

Create a highly customized cluster with a config file:
```bash
eksctl create cluster -f cluster-config.yaml
```

Generate a cluster configuration file:
```bash
eksctl generate cluster-config --region <region> --name <cluster-name>
```

Enable logging for API requests:
```bash
eksctl utils update-cluster-logging --cluster <cluster-name> --enable-types all --approve
```

Enable IAM roles for service accounts:
```bash
eksctl utils associate-iam-oidc-provider --region <region> --cluster <cluster-name> --approve
```

---

## Troubleshooting

### Common Commands
- **Verify eksctl installation**:
  ```bash
  eksctl version
  ```
- **Check AWS CLI version**:
  ```bash
  aws --version
  ```
- **Ensure Kubernetes access**:
  ```bash
  kubectl get svc
  ```

### Debugging
Enable verbose logging:
```bash
eksctl <command> --verbose 4
```
