# Kubernetes Cluster Manual Upgrade Guide

## Table of Contents
- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Pre-Upgrade Checklist](#pre-upgrade-checklist)
- [Master Node Upgrade](#master-node-upgrade)
- [Worker Node Upgrade](#worker-node-upgrade)
- [Post-Upgrade Verification](#post-upgrade-verification)
- [Troubleshooting](#troubleshooting)
- [Rollback Procedures](#rollback-procedures)

## Overview

This guide provides step-by-step instructions for manually upgrading a Kubernetes cluster from v1.30.x to v1.31.0 using kubeadm. The process involves upgrading the control plane (master node) first, followed by worker nodes.

## Prerequisites

### System Requirements
- **OS**: Ubuntu 20.04/22.04 (AWS optimized)
- **Minimum Resources**: 
  - Master: 2 vCPU, 4GB RAM
  - Worker: 2 vCPU, 2GB RAM
- **Storage**: 20GB free disk space
- **Network**: Stable network connectivity between nodes

### Software Requirements
- Kubernetes: v1.30.x currently running
- Container Runtime: containerd
- CNI: Cilium
- kubeadm, kubelet, kubectl

### Cluster Health Check
Before starting, ensure your cluster is healthy:

```bash
# Check node status
kubectl get nodes

# Check component status
kubectl get componentstatuses

# Check all pods are running
kubectl get pods -A

# Check cluster version
kubectl version --short
```

## Pre-Upgrade Checklist

### 1. Verify Current Cluster State
```bash
# Get current versions
kubeadm version
kubectl version --short
kubelet --version

# List all nodes with versions
kubectl get nodes -o wide

# Check system pod status
kubectl get pods -n kube-system
```

### 2. Check Compatibility
- Verify Cilium CNI compatibility with Kubernetes 1.31.0
- Check application compatibility with new Kubernetes version
- Review Kubernetes 1.31.0 release notes for breaking changes

### 3. Plan Maintenance Window
- Schedule at least 1-2 hours of maintenance time
- Communicate downtime to stakeholders
- Prepare rollback plan

## Master Node Upgrade

### Step 1: Comprehensive Backup

#### Backup etcd (Critical)
```bash
# Method 1: Backup from etcd pod (recommended)
kubectl exec -n kube-system etcd-$(hostname) -- etcdctl snapshot save /tmp/etcd-snapshot-$(date +%Y%m%d-%H%M%S).db \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key

# Verify backup
kubectl exec -n kube-system etcd-$(hostname) -- etcdctl snapshot status /tmp/etcd-snapshot-$(date +%Y%m%d-%H%M%S).db

# Copy backup to host
kubectl cp kube-system/etcd-$(hostname):/tmp/etcd-snapshot-$(date +%Y%m%d-%H%M%S).db /tmp/etcd-snapshot-$(date +%Y%m%d-%H%M%S).db
```

#### Backup Kubernetes Resources
```bash
# Backup all resources
kubectl get all --all-namespaces -o yaml > /tmp/k8s-all-resources-$(date +%Y%m%d).yaml
kubectl get secrets --all-namespaces -o yaml > /tmp/k8s-secrets-$(date +%Y%m%d).yaml
kubectl get configmaps --all-namespaces -o yaml > /tmp/k8s-configmaps-$(date +%Y%m%d).yaml

# Backup critical namespaces
for ns in kube-system default; do
  kubectl get -n $ns all -o yaml > /tmp/${ns}-backup-$(date +%Y%m%d).yaml
done
```

#### Backup Configuration Files
```bash
# Backup Kubernetes configuration
sudo cp -r /etc/kubernetes /etc/kubernetes-backup-$(date +%Y%m%d)
sudo cp -r /var/lib/etcd /var/lib/etcd-backup-$(date +%Y%m%d)
sudo cp $HOME/.kube/config $HOME/.kube/config.backup.$(date +%Y%m%d)
```

### Step 2: Configure Kubernetes Repository
```bash
# Remove existing repository if any
sudo rm -f /etc/apt/sources.list.d/kubernetes.list

# Add Kubernetes v1.31 repository
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Alternative: Google repository
# curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-archive-keyring.gpg
# echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Update package list
sudo apt update
```

### Step 3: Upgrade kubeadm
```bash
# Check available versions
apt-cache madison kubeadm

# Upgrade kubeadm to v1.31.0
sudo apt-mark unhold kubeadm
sudo apt-get install -y kubeadm=1.31.0-1.1

# If specific version not found, try:
# sudo apt-get install -y kubeadm=1.31.0-00
# or
# sudo apt-get install -y kubeadm

# Hold kubeadm to prevent auto-updates
sudo apt-mark hold kubeadm

# Verify version
kubeadm version
```

### Step 4: Plan and Execute Control Plane Upgrade
```bash
# Check upgrade plan
sudo kubeadm upgrade plan

# Apply the upgrade
sudo kubeadm upgrade apply v1.31.0

# If certificate renewal is needed:
# sudo kubeadm upgrade apply v1.31.0 --certificate-renewal=true
```

### Step 5: Upgrade kubelet and kubectl
```bash
# Drain the master node (optional but recommended)
kubectl drain $(hostname) --ignore-daemonsets --delete-emptydir-data

# Upgrade kubelet and kubectl
sudo apt-mark unhold kubelet kubectl
sudo apt-get install -y kubelet=1.31.0-1.1 kubectl=1.31.0-1.1
sudo apt-mark hold kubelet kubectl

# Restart kubelet
sudo systemctl daemon-reload
sudo systemctl restart kubelet

# Verify kubelet status
sudo systemctl status kubelet
```

### Step 6: Verify Master Upgrade
```bash
# Uncordon the master node
kubectl uncordon $(hostname)

# Verify versions
kubectl version --short
kubeadm version

# Check node status
kubectl get nodes

# Verify control plane components
kubectl get pods -n kube-system -l tier=control-plane
```

## Worker Node Upgrade

> **Important**: Upgrade worker nodes one at a time to maintain application availability.

### Step 1: Drain Worker Node (from Master)
```bash
# Drain the worker node
kubectl drain <worker-node-name> --ignore-daemonsets --delete-emptydir-data --timeout=300s

# Verify node is cordoned
kubectl get nodes
```

### Step 2: SSH to Worker Node and Upgrade
```bash
# SSH to worker node
ssh ubuntu@<worker-node-ip>
```

### Step 3: Configure Repository (if not done)
```bash
# Add Kubernetes v1.31 repository
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt update
```

### Step 4: Upgrade kubeadm
```bash
# Upgrade kubeadm
sudo apt-mark unhold kubeadm
sudo apt-get install -y kubeadm=1.31.0-1.1
sudo apt-mark hold kubeadm

# Verify version
kubeadm version
```

### Step 5: Upgrade Node Configuration
```bash
# Upgrade node configuration
sudo kubeadm upgrade node

# Expected output shows kubelet configuration upgrade
```

### Step 6: Upgrade kubelet and kubectl
```bash
# Upgrade kubelet and kubectl
sudo apt-mark unhold kubelet kubectl
sudo apt-get install -y kubelet=1.31.0-1.1 kubectl=1.31.0-1.1
sudo apt-mark hold kubelet kubectl

# Restart kubelet
sudo systemctl daemon-reload
sudo systemctl restart kubelet

# Check status
sudo systemctl status kubelet
```

### Step 7: Verify Worker Node (from Master)
```bash
# Uncordon the worker node
kubectl uncordon <worker-node-name>

# Verify node is ready and shows v1.31.0
kubectl get nodes

# Check node details
kubectl describe node <worker-node-name>
```

### Step 8: Repeat for Other Worker Nodes
Repeat steps 1-7 for each worker node, one at a time.

## Post-Upgrade Verification

### Cluster Health Check
```bash
# Verify all nodes are upgraded
kubectl get nodes

# Check all components are healthy
kubectl get componentstatuses

# Verify all system pods are running
kubectl get pods -A

# Check Cilium status
kubectl get pods -n kube-system -l k8s-app=cilium
```

### Application Testing
```bash
# Test cluster functionality
kubectl create deployment upgrade-test --image=nginx:alpine --replicas=3
kubectl expose deployment upgrade-test --port=80 --type=NodePort

# Verify pods are scheduled and running
kubectl get pods -l app=upgrade-test -o wide

# Test service connectivity
kubectl get svc upgrade-test

# Clean up test resources
kubectl delete deployment upgrade-test
kubectl delete service upgrade-test
```

### Network Verification
```bash
# Test DNS resolution
kubectl run test-dns --image=busybox --rm -it --restart=Never -- nslookup kubernetes.default

# Test network policies (if using Cilium network policies)
kubectl get ciliumnetworkpolicies -A
```

## Troubleshooting

### Common Issues and Solutions

#### 1. Package Version Not Found
```bash
# Check available versions
apt-cache policy kubeadm

# Try alternative version patterns
sudo apt-get install -y kubeadm=1.31.0-00
# or install latest available
sudo apt-get install -y kubeadm
```

#### 2. Upgrade Plan Shows No Versions
```bash
# Refresh repository
sudo apt update
apt-cache madison kubeadm

# Check repository configuration
cat /etc/apt/sources.list.d/kubernetes.list
```

#### 3. etcd Backup Fails
```bash
# Alternative backup method using temporary container
kubectl run -i --rm --restart=Never etcd-client --image=registry.k8s.io/etcd:3.5.12-0 --env ETCDCTL_API=3 --namespace kube-system --command -- etcdctl snapshot save /tmp/etcd-snapshot.db \
  --endpoints=https://etcd-$(hostname):2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key
```

#### 4. Pods Stuck in Terminating State
```bash
# Force delete if necessary
kubectl delete pod <pod-name> --force --grace-period=0

# Check for finalizers
kubectl get pod <pod-name> -o yaml | grep finalizers
```

#### 5. CNI Issues After Upgrade
```bash
# Restart Cilium pods
kubectl delete pods -n kube-system -l k8s-app=cilium

# Check Cilium status
kubectl get pods -n kube-system -l k8s-app=cilium
kubectl logs -n kube-system -l k8s-app=cilium
```

#### 6. Node Not Joining Cluster
```bash
# Check kubelet logs on worker node
sudo journalctl -u kubelet -f

# Verify certificates
sudo kubeadm init phase kubeconfig all --config /etc/kubernetes/kubeadm-config.yaml

# Check network connectivity
ping <master-node-ip>
telnet <master-node-ip> 6443
```

## Rollback Procedures

### Last Resort: etcd Restore
```bash
# Stop kubelet and all control plane pods
sudo systemctl stop kubelet

# Restore etcd from snapshot
sudo docker run --rm \
  -v /etc/kubernetes/pki/etcd:/etc/kubernetes/pki/etcd \
  -v /var/lib/etcd:/var/lib/etcd \
  -v /tmp:/tmp \
  --env ETCDCTL_API=3 \
  registry.k8s.io/etcd:3.5.12-0 \
  etcdctl snapshot restore /tmp/etcd-snapshot.db \
  --data-dir /var/lib/etcd/restored

# Replace etcd data
sudo mv /var/lib/etcd /var/lib/etcd-backup-failed-upgrade
sudo mv /var/lib/etcd/restored /var/lib/etcd

# Restart kubelet
sudo systemctl start kubelet
```

## Maintenance Commands Summary

### Quick Health Check
```bash
kubectl get nodes
kubectl get pods -A
kubectl get cs
kubectl version --short
```

### Quick Upgrade Status
```bash
# Check upgrade progress
kubectl get nodes -o wide | grep -v Ready
kubectl get pods -A --field-selector=status.phase!=Running
```

## Important Notes

1. **Upgrade Order**: Always upgrade master nodes before worker nodes
2. **One at a Time**: Upgrade worker nodes sequentially
3. **Backup**: Always take etcd backup before master node upgrade
4. **Testing**: Test upgrade process in non-production environment first
5. **Documentation**: Keep records of upgrade process and any issues encountered
6. **Monitoring**: Monitor applications closely after upgrade
7. **Rollback Plan**: Always have a rollback plan ready

## Support and References

- [Kubernetes Upgrade Documentation](https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/)
- [Cilium Upgrade Guide](https://docs.cilium.io/en/stable/operations/upgrade/)
- [Kubernetes Release Notes](https://kubernetes.io/releases/)

---

**Remember**: Always test upgrades in a non-production environment first and ensure you have proper backups before proceeding with production upgrades.
