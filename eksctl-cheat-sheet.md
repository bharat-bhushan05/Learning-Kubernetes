# EKSCTL Cheat Sheet

## Introduction
`eksctl` is a command-line tool to simplify the creation, management, and deletion of Kubernetes clusters on Amazon EKS. Below is a comprehensive cheat sheet covering essential commands, examples, and tips.

---

## Prerequisites

- Install `eksctl`: [Installation Guide](https://eksctl.io/introduction/#installation)
- AWS CLI configured with appropriate permissions.
- Kubernetes `kubectl` installed.

---

## Cluster Management

### Create a Cluster
```bash
eksctl create cluster \
  --name <cluster-name> \
  --region <region> \
  --version <k8s-version> \
  --nodegroup-name <nodegroup-name> \
  --nodes <num-nodes> \
  --nodes-min <min-nodes> \
  --nodes-max <max-nodes> \
  --node-type <instance-type> \
  --ssh-access \
  --ssh-public-key <key-name> \
  --managed
```

### Delete a Cluster
```bash
eksctl delete cluster --name <cluster-name> --region <region>
```

### List Clusters
```bash
eksctl get clusters --region <region>
```

---

## Node Group Management

### Create a Node Group
```bash
eksctl create nodegroup \
  --cluster <cluster-name> \
  --region <region> \
  --name <nodegroup-name> \
  --nodes <num-nodes> \
  --nodes-min <min-nodes> \
  --nodes-max <max-nodes> \
  --node-type <instance-type> \
  --ssh-access \
  --ssh-public-key <key-name> \
  --managed
```

### Delete a Node Group
```bash
eksctl delete nodegroup \
  --cluster <cluster-name> \
  --region <region> \
  --name <nodegroup-name>
```

### Scale Node Group
```bash
eksctl scale nodegroup \
  --cluster <cluster-name> \
  --name <nodegroup-name> \
  --nodes <desired-nodes>
```

---

## Add-Ons Management

### List Add-Ons
```bash
eksctl get addons --cluster <cluster-name> --region <region>
```

### Install an Add-On
```bash
eksctl install addon \
  --name <addon-name> \
  --cluster <cluster-name> \
  --region <region>
```

### Update an Add-On
```bash
eksctl update addon \
  --name <addon-name> \
  --cluster <cluster-name> \
  --region <region>
```

---

## Cluster Configuration

### View Cluster Info
```bash
eksctl utils describe-stacks --cluster <cluster-name> --region <region>
```

### Update Kubernetes Version
```bash
eksctl upgrade cluster --name <cluster-name> --region <region> --version <k8s-version>
```

### Enable Logging
```bash
eksctl utils update-cluster-logging \
  --cluster <cluster-name> \
  --region <region> \
  --enable-types all
```

---

## IAM Roles and Policies

### Associate IAM OIDC Provider
```bash
eksctl utils associate-iam-oidc-provider \
  --region <region> \
  --cluster <cluster-name> \
  --approve
```

### Create an IAM Service Account
```bash
eksctl create iamserviceaccount \
  --name <service-account-name> \
  --namespace <namespace> \
  --cluster <cluster-name> \
  --region <region> \
  --attach-policy-arn <policy-arn> \
  --approve
```

---

## Troubleshooting

### Check Cluster Logs
```bash
eksctl utils describe-cluster-logs --region <region> --cluster <cluster-name>
```

### Check Nodes
```bash
eksctl get nodegroup --cluster <cluster-name> --region <region>
```

---

## Advanced Usage

### Create a Cluster with a Config File
```yaml
# cluster-config.yaml
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig
metadata:
  name: <cluster-name>
  region: <region>
  version: "<k8s-version>"
nodeGroups:
  - name: <nodegroup-name>
    instanceType: <instance-type>
    desiredCapacity: <num-nodes>
    ssh:
      allow: true
      publicKeyName: <key-name>
```

```bash
eksctl create cluster -f cluster-config.yaml
```

---

## Useful Tips

- Use `--dry-run` to preview commands without executing them.
- Always use `--managed` for managed node groups for ease of updates.
- Combine `eksctl` with Terraform for Infrastructure as Code (IaC).

---

## Resources

- [eksctl Documentation](https://eksctl.io/)
- [Amazon EKS User Guide](https://docs.aws.amazon.com/eks/latest/userguide/)
- [GitHub Repository](https://github.com/weaveworks/eksctl)
