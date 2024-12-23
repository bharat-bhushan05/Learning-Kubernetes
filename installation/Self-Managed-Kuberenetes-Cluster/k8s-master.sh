#!/bin/bash

# For Ubuntu DISTRIB_RELEASE=22

# Update the system
sudo apt-get update
sudo apt-get upgrade -y

# Install Containerd as container runtime
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt-get install containerd.io -y
mkdir -p /etc/containerd
containerd config default | tee /etc/containerd/config.toml
sed -e 's/SystemdCgroup = false/SystemdCgroup = true/g' -i /etc/containerd/config.toml
systemctl restart containerd
systemctl enable containerd
cat <<EOF | tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

# Disable swap
# Predictable performance: Swap can lead to unpredictable node performance.
# Resource management: Kubernetes manages container resources, and swap can interfere with this.
# Consistency: Ensures consistent behavior across all nodes in the cluster.
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab


# Add some settings to sysctl
# These settings are crucial for Kubernetes networking to function correctly.
# They allow Kubernetes services to communicate with each other and the outside world.
# They ensure that iptables rules are properly applied to bridge traffic.
sudo tee /etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF


# Enable kernel modules
# overlay: Needed for efficient container filesystem operations.
# br_netfilter: Enables transparent masquerading and facilitates Virtual Extensible LAN (VxLAN) traffic for communication between Kubernetes pods across nodes.
sudo modprobe overlay
sudo modprobe br_netfilter

# Reload sysctl
sudo sysctl --system

systemctl status containerd

# Add Kubernetes repo
sudo apt-get install -y apt-transport-https ca-certificates curl
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | tee /etc/apt/sources.list.d/kubernetes.list

# Install Kubernetes components
sudo apt-get update
sudo apt-get install -y kubelet=1.30.3-1.1 kubeadm=1.30.3-1.1 kubectl=1.30.3-1.1
sudo apt-mark hold kubelet kubeadm kubectl
# apt-mark hold command marks the kubelet, kubeadm, and kubectl packages as "held back".
# When you run apt-get upgrade, these packages will not be upgraded, even if newer versions are available.


# Install critctl: CRI-O is an implementation of the Container Runtime Interface (CRI) used by the kubelet to interact with container runtimes.
export CRICTL_VERSION="v1.30.1"
export CRICTL_ARCH=$(dpkg --print-architecture)
wget https://github.com/kubernetes-sigs/cri-tools/releases/download/$CRICTL_VERSION/crictl-$CRICTL_VERSION-linux-$CRICTL_ARCH.tar.gz
tar zxvf crictl-$CRICTL_VERSION-linux-$CRICTL_ARCH.tar.gz -C /usr/local/bin
rm -f crictl-$CRICTL_VERSION-linux-$CRICTL_ARCH.tar.gz
crictl version

# Initialize the cluster
kubeadm init --control-plane-endpoint <master-node-public-ip>:<PORT> --kubernetes-version 1.30.3 --pod-network-cidr 192.168.0.0/16 --v=5

# Breakdown the above command:

# kubeadm init: This is the primary command used to initialize a Kubernetes control-plane node.
# It bootstraps the Kubernetes control plane, which includes components like the API server, controller manager, and scheduler.

# --pod-network-cidr=192.168.0.0/16: It specifies the subnet range to be used for pod IP addresses.
# 192.168.0.0/16 is the CIDR (Classless Inter-Domain Routing) notation representing this subnet.
# This CIDR range is used to assign IP addresses to pods across the cluster.
# It helps in setting up the overlay network that allows pods to communicate across different nodes.
# The chosen CIDR should not overlap with your node network or any other network in your infrastructure.

# Set up kubectl for the root user
# This command will setup connection from kubectl to the kubernetes cluster
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# CNI plugin installation with Cilium CLI
export CILIUM_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
export CILIUM_ARCH=$(dpkg --print-architecture)
# Download the Cilium CLI binary and its sha256sum
curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/$CILIUM_VERSION/cilium-linux-$CILIUM_ARCH.tar.gz{,.sha256sum}

# Verify sha256sum
sha256sum --check cilium-linux-$CILIUM_ARCH.tar.gz.sha256sum

# Move binary to correct location and remove tarball
tar xzvf cilium-linux-$CILIUM_ARCH.tar.gz -C /usr/local/bin 
rm cilium-linux-$CILIUM_ARCH.tar.gz{,.sha256sum}

# Verify the Cilium CLI is installed
cilium version --client

# Install network plugin.
cilium install

# Wait for the CNI plugin to be installed.
cilium status --wait

echo "Kubernetes master node setup complete!"

# Print the join command for worker nodes
echo "Run the following command on your worker nodes to join the cluster:"
kubeadm token create --print-join-command

# kubeadm token create: This part of the command creates a new bootstrap token.
# Bootstrap tokens are used for establishing bidirectional trust between a node wanting to join the cluster and the control plane node.
# --print-join-command: This flag tells kubeadm to print out the full kubeadm join command that can be used to join a new node to the cluster
