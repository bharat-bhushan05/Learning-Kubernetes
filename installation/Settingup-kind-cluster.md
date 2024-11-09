# Kubernetes Cluster Setup Using `kind` and `kubectl`

## 1. Create Directories

```bash
#!/bin/bash

sudo mkdir /kube
cd /kube
```

## 2. Installing Docker

```bash
#### Installing Docker ####
sudo yum install docker
sudo systemctl start docker
sudo systemctl enable docker
```

## 3. Installing Kind

### For AMD64 / x86_64:

```bash
[ $(uname -m) = x86_64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.24.0/kind-linux-amd64
```

### For ARM64:

```bash
[ $(uname -m) = aarch64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.24.0/kind-linux-arm64
```

Make the downloaded file executable and move it to `/usr/local/bin`:

```bash
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
```

## 4. Installing `kubectl`

```bash
#### Installing kubectl ####
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/arm64/kubectl"
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/arm64/kubectl.sha256"
echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
kubectl version --client
```

## 5. Creating a Kind Cluster

### Cluster Configuration File: `cluster.yaml`

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
    extraPortMappings:
      - containerPort: 30001
        hostPort: 30001 
  - role: worker
  - role: worker
```

### Creating the Cluster:

```bash
kind create cluster --image kindest/node:v1.31.0@sha256:53df588e04085fd41ae12de0c3fe4c72f7013bba32a20e7325357a1ac94ba865 --name cka-cluster1 --name cka-cluster2 --config cluster.yaml
```

### Verify Cluster Contexts:

```bash
kubectl config get-contexts
kubectl config use-context kind-cka-cluster1
kubectl config view
```

## 6. Useful `kubectl` Commands

### Get API Resources:

```bash
kubectl api-resources
```

### Explain Resources and Their Fields:

- Get the documentation of the resource and its fields:

```bash
kubectl explain pods
```

- Get all the fields in the resource:

```bash
kubectl explain pods --recursive
```

- Get the explanation for deployments in supported API versions:

```bash
kubectl explain deployments --api-version=apps/v1
```

- Get the documentation of a specific field of a resource:

```bash
kubectl explain pods.spec.containers
```

### Get Resource Documentation in Different Formats:

```bash
kubectl explain deployment --output=plaintext-openapiv2
```
### KindCluster Security Group Ports on AWS EC2
![Alt text](/images/KindCluster-SG.png)

