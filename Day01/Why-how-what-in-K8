# Why-How-What-in-K8

#### **Why Kubernetes?**
Kubernetes has become a standard for container orchestration due to several critical challenges in managing modern applications:

1. **Scaling & Automation**: As applications grow, manually managing hundreds or thousands of containers becomes highly complex. Kubernetes automates the deployment, scaling, and management of containerized applications.
   
2. **High Availability & Resilience**: Kubernetes ensures that applications are highly available and resilient to failures. If a container crashes, Kubernetes automatically restarts it, reschedules it on a healthy node, or scales out when needed.

3. **Portability Across Environments**: Kubernetes abstracts away the underlying infrastructure, allowing applications to run consistently across cloud environments, on-premises data centers, or hybrid environments. This portability helps organizations avoid vendor lock-in.

4. **Efficient Resource Utilization**: Kubernetes schedules containers onto the best-suited nodes, ensuring that computing resources are efficiently utilized and workloads are balanced across the infrastructure.

5. **Simplification of Microservices Architecture**: With the rise of microservices, there’s a need to manage a vast number of smaller services. Kubernetes provides powerful tools for service discovery, load balancing, and network communication, simplifying the orchestration of complex microservices architectures.

#### **Benefits of Kubernetes:**
- **Automation**: Handles container lifecycle management (deployment, updates, restarts).
- **Self-Healing**: Automatically replaces failed containers or nodes.
- **Scalability**: Seamlessly scales applications horizontally by adding/removing containers.
- **Portability**: Runs applications consistently across any cloud or on-prem infrastructure.
- **Security**: Provides mechanisms to control access, configure secrets, and manage TLS certificates.
- **Cost-Effective**: Optimizes resource usage, reducing waste and operational overhead.

---

### What is Kubernetes?

#### **What is Kubernetes?**
Kubernetes (often abbreviated as K8s) is an open-source platform designed to automate the deployment, scaling, and management of containerized applications. Originally developed by Google, it is now maintained by the Cloud Native Computing Foundation (CNCF). Kubernetes enables the orchestration of containers across a cluster of physical or virtual machines.

#### **Core Concepts of Kubernetes:**
1. **Cluster**: A Kubernetes cluster consists of at least one control plane (master) and one or more worker nodes. The control plane manages the overall state and scheduling, while worker nodes run the containerized applications.

2. **Pod**: A pod is the smallest deployable unit in Kubernetes. It is an abstraction that represents one or more containers, usually tightly coupled, that share the same network and storage resources.

3. **Node**: A node is a machine (physical or virtual) where Kubernetes runs pods. Nodes are managed by the control plane and can have multiple pods scheduled on them.

4. **Service**: A Kubernetes service is an abstraction that defines a logical set of pods and a policy for accessing them. Services provide stable endpoints for network communication, regardless of where the pods are scheduled.

5. **Deployment**: A deployment defines how many replicas of a pod should run and manages the lifecycle of those pods. It handles rolling updates, scaling, and rollback of the application.

6. **Namespace**: Namespaces are used to organize resources within a Kubernetes cluster. They provide isolation for different environments or teams.

7. **Ingress**: Ingress manages external access to services, typically via HTTP/HTTPS. It can offer load balancing, SSL termination, and routing to different services.

8. **ConfigMap and Secret**: These are used to manage configuration data and sensitive information like passwords or API tokens separately from the application code, making it more secure and easier to update.

9. **Volumes**: Kubernetes volumes provide storage that containers within pods can access. Volumes outlast the lifecycle of individual containers, ensuring data persistence.

#### **What Kubernetes Does:**
- **Orchestration**: Manages and schedules containers across a distributed cluster.
- **Service Discovery**: Provides internal mechanisms for locating services via DNS names and IP addresses.
- **Load Balancing**: Distributes traffic across containers for improved performance and reliability.
- **Rolling Updates and Rollbacks**: Ensures smooth updates with zero downtime, and if an update fails, it automatically rolls back to a previous stable version.
- **Self-Healing**: Automatically restarts failed containers or re-schedules them on a healthy node.
- **Horizontal Scaling**: Automatically increases or decreases the number of containers based on CPU, memory usage, or custom metrics.

---

### How Kubernetes Works?

#### **How Kubernetes Works:**
Kubernetes works by abstracting the underlying infrastructure and providing an API to manage the entire lifecycle of containerized applications. Here's an overview of its working mechanism:

1. **Control Plane**: The control plane is responsible for maintaining the desired state of the cluster. It includes the following components:
   - **API Server**: Exposes the Kubernetes API, which is the entry point for all administrative tasks.
   - **etcd**: A distributed key-value store that stores the cluster state.
   - **Controller Manager**: Manages different controllers that ensure the cluster state matches the desired state (e.g., replication controllers, node controllers).
   - **Scheduler**: Determines which node a pod will run on based on resource requirements, policies, and constraints.

2. **Worker Nodes**: Each worker node runs:
   - **kubelet**: An agent that ensures containers are running in pods.
   - **Container Runtime**: Responsible for running containers (e.g., Docker, containerd).
   - **kube-proxy**: Manages network rules and service discovery for containers.

3. **Pod Scheduling**:
   - When a deployment request is made, the scheduler evaluates the resource needs of the pod and identifies the most suitable node based on available resources and policies.
   - Once a node is selected, the kubelet on that node pulls the required container image from a container registry and starts the container within a pod.

4. **Service Discovery**:
   - Kubernetes assigns each pod an internal IP address. Services provide stable access to pods by abstracting their underlying IPs. Pods behind a service can be reached using a service name, which is managed through Kubernetes' internal DNS.

5. **Scaling**:
   - Kubernetes can automatically scale the number of pods running in a deployment based on CPU/memory usage or custom metrics (using the Horizontal Pod Autoscaler). The deployment controller continuously monitors the status and adjusts the pod count accordingly.

6. **Self-Healing**:
   - If a pod fails (e.g., due to application crash), Kubernetes detects the failure and automatically restarts the pod on the same node or schedules it on another node if necessary.
   - Kubernetes ensures that the number of running pods always matches the desired count specified in the deployment configuration.

7. **Rolling Updates and Rollbacks**:
   - When deploying a new version of an application, Kubernetes can perform a rolling update, where new pods are created gradually, and old ones are terminated only after the new pods are up and running.
   - If something goes wrong, Kubernetes can roll back the deployment to the previous version to ensure the system remains stable.

8. **Persistent Storage**:
   - Kubernetes provides a variety of storage solutions, from simple volumes mounted from the host node to external cloud-based storage like AWS EBS, GCP Persistent Disks, or Azure Disks.
   - Storage classes allow dynamic provisioning of storage based on specific performance requirements.

#### **Example Workflow**:
1. **Create a Deployment**: You define a deployment that describes the application, including the container image, number of replicas, and resources.
2. **Kubernetes Schedules Pods**: The scheduler assigns the pods to nodes based on available resources.
3. **Load Balancer/Service Exposes Pods**: A service is created that exposes the pods to internal or external traffic, providing load balancing across them.
4. **Scaling/Healing**: If traffic increases, Kubernetes can scale up the pods. If a pod fails, Kubernetes automatically replaces it.
5. **Update & Rollback**: New versions of the app can be deployed with rolling updates, and if an issue occurs, Kubernetes rolls back to the previous version.

---

### Conclusion:
Kubernetes simplifies the management of containerized applications by automating deployment, scaling, and operations across clusters of machines. It allows organizations to build resilient and scalable microservices architectures while optimizing resource utilization and ensuring high availability across environments.
