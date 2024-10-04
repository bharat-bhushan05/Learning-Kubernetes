# Minikube Installation on Ubuntu AWS EC2 Instance

This guide provides step-by-step instructions to install and set up Minikube on an Ubuntu EC2 instance in AWS. Follow along to run Kubernetes on your instance.

---

## Prerequisites

- **Ubuntu EC2 instance** running at least **t2.medium** or higher (Minikube needs 2 CPUs and 2GB RAM minimum).
- **SSH access** to the EC2 instance.
- A hypervisor like **Docker** or **KVM**.

---

## Installation Steps

### Step 1: SSH into the EC2 Instance

First, SSH into your EC2 instance from your local machine. Replace `<your-ec2-instance-public-ip>` with your actual EC2 instance's IP address:

```bash
ssh -i <path-to-your-pem-file>.pem ubuntu@<your-ec2-instance-public-ip>
```

---

### Step 2: Update Your System

Before installing any packages, it's good to update the existing packages on your instance:

```bash
sudo apt-get update && sudo apt-get upgrade -y
```

---

### Step 3: Install Docker

1. **Install Docker** as the driver for Minikube. Run the following commands to install Docker:

   ```bash
   sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
   curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
   sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
   sudo apt-get update
   sudo apt-get install -y docker-ce
   ```

2. **Start Docker** and enable it to start at boot:

   ```bash
   sudo systemctl start docker
   sudo systemctl enable docker
   ```

3. **Add your user to the `docker` group** to avoid using `sudo` with Docker:

   ```bash
   sudo usermod -aG docker $USER
   ```

   **Important**: You need to log out and log back in for the group membership to be applied:

   ```bash
   exit
   ```

   Reconnect to the instance:

   ```bash
   ssh -i <path-to-your-pem-file>.pem ubuntu@<your-ec2-instance-public-ip>
   ```

---

### Step 4: Install Minikube

1. **Download Minikube** and make it executable:

   ```bash
   curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
   sudo install minikube-linux-amd64 /usr/local/bin/minikube
   ```

---

### Step 5: Install kubectl

1. **Download and install `kubectl`**, the Kubernetes command-line tool:

   ```bash
   curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
   chmod +x kubectl
   sudo mv kubectl /usr/local/bin/
   ```

2. **Verify the installation**:

   ```bash
   kubectl version --client
   ```

---

### Step 6: Start Minikube

1. **Start Minikube** using Docker as the driver:

   ```bash
   minikube start --driver=docker
   ```

   This will launch a Minikube cluster using Docker.

2. **Check the status** of Minikube to ensure it's running:

   ```bash
   minikube status
   ```

3. **Verify the Kubernetes nodes**:

   ```bash
   kubectl get nodes
   ```

   You should see a node labeled `minikube` in the `Ready` state.

---

### Step 7: Configure Access (Optional)

If you'd like to use Minikube's services from outside the EC2 instance, ensure that your instance’s **security group** allows access to the necessary ports (e.g., port `30000`-`32767` for NodePort services). Update the security group in the AWS Management Console as follows:

1. Open the **EC2 Dashboard**.
2. Go to **Security Groups**.
3. Select your instance's security group and **Edit Inbound Rules**.
4. Add a custom TCP rule to allow traffic from your IP or open it for all (`0.0.0.0/0`) to port `30000-32767`.

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

- **Access the Minikube Dashboard** (in a remote environment, you'll need to use SSH port forwarding):
   ```bash
   minikube dashboard
   ```

   To view it in your browser:
   ```bash
   minikube dashboard --url
   ```

---

## Troubleshooting

1. **Minikube fails to start**:
   - Ensure Docker is installed and running.
   - Check if your EC2 instance has sufficient CPU and memory (`t2.medium` or higher recommended).

2. **Accessing Minikube Dashboard remotely**:
   - You can forward the dashboard port using SSH tunneling:
     ```bash
     ssh -i <path-to-your-pem-file>.pem -L 8080:localhost:30000 ubuntu@<your-ec2-instance-public-ip>
     ```

3. **kubectl not found**:
   - Ensure `kubectl` is in your system's PATH and executable.

---

## Conclusion

You've now successfully installed Minikube on your AWS EC2 Ubuntu instance! You can use this setup to create, test, and manage Kubernetes workloads remotely.
