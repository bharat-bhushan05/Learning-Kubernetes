# Minikube Installation Guide

This guide will walk you through the installation of Minikube to run Kubernetes locally. Follow the steps to install Minikube on various operating systems and verify your setup.

## Prerequisites

- A hypervisor to run Minikube’s virtual machines:
  - **Windows**: Hyper-V or VirtualBox
  - **macOS**: Docker, VirtualBox, or HyperKit
  - **Linux**: KVM, VirtualBox, or Docker
- **kubectl**: Kubernetes command-line tool.
- 2GB of free memory and 20GB of free disk space.

---

## Installation Steps

### 1. Choose your Operating System:

- [Windows](#windows)
- [macOS](#macos)
- [Linux](#linux)

---

### Windows

1. **Install a Hypervisor**

   Enable Hyper-V or install VirtualBox.

   - To enable **Hyper-V**:
     1. Open **PowerShell** as Administrator.
     2. Run the command:
     ```bash
     Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
     ```
     3. Reboot your system if prompted.

   - To install **VirtualBox**, download it from the official [VirtualBox website](https://www.virtualbox.org/) and follow the installation instructions.

2. **Install Minikube**

   - Download the Minikube executable from the official [Minikube Releases](https://github.com/kubernetes/minikube/releases).
   - Add Minikube to your system's PATH:
     1. Right-click **This PC** → **Properties** → **Advanced System Settings** → **Environment Variables**.
     2. Edit the **Path** variable and add the directory containing `minikube.exe`.

3. **Install kubectl**
   - Download `kubectl` from the official Kubernetes [release page](https://kubernetes.io/docs/tasks/tools/install-kubectl/).
   - Add it to the PATH in a similar way to Minikube.

4. **Start Minikube**
   - Open **Command Prompt** or **PowerShell** as Administrator.
   - Run the following command to start Minikube:
     ```bash
     minikube start --driver=hyperv
     ```

   If you're using VirtualBox:
   ```bash
   minikube start --driver=virtualbox
   ```

### macOS

1. **Install Homebrew**
   - Open the terminal and install Homebrew if you don’t have it:
     ```bash
     /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
     ```

2. **Install Minikube**
   - In the terminal, run the following commands:
     ```bash
     brew install minikube
     ```

3. **Install kubectl**
   - To install `kubectl` via Homebrew, run:
     ```bash
     brew install kubectl
     ```

4. **Start Minikube**
   - You can start Minikube with the preferred driver:
     ```bash
     minikube start --driver=docker
     ```
   Or if you want to use VirtualBox:
     ```bash
     minikube start --driver=virtualbox
     ```

### Linux

1. **Install a Hypervisor**
   - You can use **KVM**, **VirtualBox**, or **Docker** as your hypervisor.

   To install VirtualBox on Ubuntu:
   ```bash
   sudo apt-get update
   sudo apt-get install virtualbox
   ```

2. **Install Minikube**
   - Download the Minikube binary and make it executable:
     ```bash
     curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
     sudo install minikube-linux-amd64 /usr/local/bin/minikube
     ```

3. **Install kubectl**
   - Download and install `kubectl`:
     ```bash
     curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
     chmod +x kubectl
     sudo mv kubectl /usr/local/bin/
     ```

4. **Start Minikube**
   - Start Minikube with:
     ```bash
     minikube start --driver=virtualbox
     ```

   If you are using Docker:
   ```bash
   minikube start --driver=docker
   ```

---

## Verifying Installation

Once the installation is complete, verify that Minikube is running properly by checking the cluster status:

```bash
minikube status
```

To interact with the Kubernetes cluster using `kubectl`, check that the nodes are up and running:

```bash
kubectl get nodes
```

---

## Common Commands

- **Start Minikube**:  
  ```bash
  minikube start
  ```

- **Stop Minikube**:  
  ```bash
  minikube stop
  ```

- **Delete Minikube Cluster**:  
  ```bash
  minikube delete
  ```

- **Open Minikube Dashboard**:  
  ```bash
  minikube dashboard
  ```

---

## Troubleshooting

1. **Minikube fails to start:**
   - Ensure that your hypervisor is installed and running.
   - Check if your system has enough resources (memory, CPU).

2. **kubectl not found:**
   - Ensure `kubectl` is installed and in your system's PATH.
   - Verify the installation using:
     ```bash
     kubectl version --client
     ```

3. **Minikube commands not found:**
   - Ensure Minikube is installed correctly and added to your system's PATH.

---

## Conclusion

Congratulations! You have successfully installed Minikube and set up a local Kubernetes cluster. You can now use it to create, test, and manage Kubernetes workloads locally.
```
