## Error01: The "docker" driver should not be used with root privileges. If you wish to continue as root, use --force.
```Error01
root@ip-172-31-14-200:/# minikube start
* minikube v1.34.0 on Ubuntu 24.04 (xen/amd64)
* Automatically selected the docker driver. Other choices: none, ssh
* The "docker" driver should not be used with root privileges. If you wish to continue as root, use --force.
* If you are running minikube within a VM, consider using --driver=none:
*   https://minikube.sigs.k8s.io/docs/reference/drivers/none/
```

### Option 1: Use a Non-Root User

Minikube works best when not run as the `root` user, especially with the Docker driver. Follow these steps to run Minikube as a non-root user:

1. **Create a non-root user** (if not already done):
   ```bash
   sudo adduser <your-username>
   sudo usermod -aG sudo <your-username>
   sudo usermod -aG docker <your-username>
   ```

2. **Switch to the non-root user**:
   ```bash
   su - <your-username>
   ```

3. **Start Minikube as the non-root user**:
   ```bash
   minikube start --driver=docker
   ```

If you have already added the non-root user to the `docker` group, the above steps should work without requiring `sudo`.

---

### Option 2: Use the `--driver=none` Option

If you prefer to continue as the `root` user, you can use the **"none" driver**, which runs Minikube directly on the host system without a hypervisor or Docker. This option requires you to install and configure Kubernetes components manually.

1. **Install required packages**:
   ```bash
   sudo apt-get install -y conntrack cri-tools socat ebtables
   ```

2. **Start Minikube using the `--driver=none` option**:
   ```bash
   minikube start --driver=none
   ```

   > **Note**: The `none` driver runs Kubernetes directly on your host, so ensure your EC2 instance has the necessary permissions and system resources.

---

### Option 3: Force the Docker Driver

If you still want to run Minikube as `root` using the Docker driver, you can force it by adding the `--force` flag:

```bash
minikube start --driver=docker --force
```

However, it's not recommended to run Minikube with root privileges for security reasons, so Option 1 (running as a non-root user) is the safer and more ideal approach.

---

## Error02: Unable to pick a default driver. Here is what was considered, in preference order
```Error: 
ubuntu@ip-172-31-14-200:~$ minikube start
* minikube v1.34.0 on Ubuntu 24.04 (xen/amd64)
* Unable to pick a default driver. Here is what was considered, in preference order:
  - docker: Not healthy: "docker version --format {{.Server.Os}}-{{.Server.Version}}:{{.Server.Platform.Name}}" exit status 1: permission denied while trying to connect to the Docker daemon socket at unix:///var/run/docker.sock: Get "http://%2Fvar%2Frun%2Fdocker.sock/v1.24/version": dial unix /var/run/docker.sock: connect: permission denied
  - docker: Suggestion: Add your user to the 'docker' group: 'sudo usermod -aG docker $USER && newgrp docker' <https://docs.docker.com/engine/install/linux-postinstall/>
* Alternatively you could install one of these drivers:
  - kvm2: Not installed: exec: "virsh": executable file not found in $PATH
  - podman: Not installed: exec: "podman": executable file not found in $PATH
  - qemu2: Not installed: exec: "qemu-system-x86_64": executable file not found in $PATH
  - virtualbox: Not installed: unable to find VBoxManage in $PATH

X Exiting due to DRV_NOT_HEALTHY: Found driver(s) but none were healthy. See above for suggestions how to fix installed drivers.

ubuntu@ip-172-31-14-200:~$ whoami
ubuntu
```
It looks like the issue you're encountering is related to Docker permissions. Even though you're logged in as the `ubuntu` user, this user does not have the correct permissions to access the Docker socket (`/var/run/docker.sock`). Docker commands require either `sudo` privileges or that your user is in the `docker` group.

To resolve this, follow these steps:

### Step 1: Add the User to the `docker` Group
This will allow your `ubuntu` user to run Docker commands without `sudo`.

```bash
sudo usermod -aG docker $USER
```

This command adds your current user (`$USER`, in this case `ubuntu`) to the `docker` group, which gives it permission to interact with Docker.

### Step 2: Apply the Group Changes
After adding your user to the `docker` group, you need to log out and log back in for the changes to take effect.

1. Log out of the EC2 instance:
   ```bash
   exit
   ```

2. Log back in to the EC2 instance:
   ```bash
   ssh -i <your-pem-file>.pem ubuntu@<your-ec2-instance-public-ip>
   ```

Alternatively, you can use the `newgrp` command to avoid logging out:
```bash
newgrp docker
```

### Step 3: Verify Docker Access
After logging back in (or using `newgrp`), check that you can run Docker commands without `sudo`:

```bash
docker ps
```

If this works without showing any permission errors, you're ready to proceed.

### Step 4: Start Minikube
Now, try starting Minikube again:

```bash
minikube start --driver=docker
```

This should start Minikube without requiring root privileges.

---





