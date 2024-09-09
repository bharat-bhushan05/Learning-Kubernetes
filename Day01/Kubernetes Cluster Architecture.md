# Kubernetes Architecture Overview

Welcome to the **Kubernetes Architecture** repository! This repository aims to provide a comprehensive overview of the Kubernetes architecture by referencing the official [Kubernetes documentation](https://kubernetes.io/docs/concepts/architecture/). Kubernetes (K8s) is an open-source system for automating the deployment, scaling, and management of containerized applications.

## Introduction

Kubernetes clusters consist of a set of worker machines, called **nodes**, that run containerized applications. Every cluster has at least one **master node** and multiple **worker nodes**. The master node is responsible for managing the state of the cluster, while the worker nodes host the actual application workloads.

This repository highlights the major components of the Kubernetes architecture, including their respective roles and interactions.

## Kubernetes Architecture

### 1. Master Node

The **Master Node** manages the cluster and coordinates all activities like scheduling applications, maintaining desired states, scaling, and rolling out new updates. It contains the following core components:

- **API Server**: The API server is the front end of the Kubernetes control plane. All the administrative commands are received by the API server, which processes the requests and updates the corresponding objects in the `etcd` store.

  - **Key Responsibilities**:
    - Exposes Kubernetes API.
    - Processes REST requests and provides data to client tools (e.g., `kubectl`).
    - Serves as the primary interface for all interactions with the control plane.

- **Scheduler**: The scheduler is responsible for assigning workloads to nodes. It monitors resource usage and schedules newly created pods that do not have a node assigned to them, ensuring they fit within the cluster's resource constraints.

  - **Key Responsibilities**:
    - Tracks resources available in the cluster.
    - Assigns pods to worker nodes based on resource availability and other constraints.

- **Controller Manager**: The controller manager ensures the desired state of the cluster matches the actual state. It includes various controllers for handling different parts of the system, such as the node controller, replication controller, and endpoints controller.

  - **Key Responsibilities**:
    - Runs control loops to manage the state of Kubernetes resources.
    - Watches for state changes (e.g., replicas, jobs) and makes necessary adjustments.

- **etcd**: A consistent and highly available key-value store that holds all the data regarding the cluster's state. It stores information such as the configuration data, cluster state, and node status.

  - **Key Responsibilities**:
    - Stores configuration and status data.
    - Acts as the source of truth for cluster information.

### 2. Worker Nodes

Worker nodes host and run application workloads in the form of containers, which are encapsulated within **pods**. Each worker node runs the following critical components:

- **Kubelet**: Kubelet is the agent running on every worker node that ensures that the containers described in `PodSpecs` are running as expected. It communicates with the API server to receive commands and maintains the desired state of the pods.

  - **Key Responsibilities**:
    - Monitors the state of containers in pods.
    - Ensures that the containers are running and healthy.

- **Kube-proxy**: Kube-proxy is a network proxy that runs on each worker node and maintains the network rules for pod communication. It facilitates the network traffic to pods within or across nodes in the cluster.

  - **Key Responsibilities**:
    - Manages networking rules and service discovery.
    - Enables communication between services inside and outside the cluster.

- **Container Runtime**: The container runtime is responsible for running containers. Kubernetes supports various container runtimes, such as Docker, containerd, and CRI-O.

  - **Key Responsibilities**:
    - Pulls and runs containers.
    - Isolates containers from the underlying operating system and manages container lifecycles.

### 3. Pods

**Pods** are the smallest and most basic deployable objects in Kubernetes. A pod represents a single instance of an application or a set of related containers that share storage and network resources. Pods are ephemeral, meaning they can be replaced or recreated by the control plane as needed.

- **Key Characteristics**:
  - Contains one or more containers.
  - Shares storage volumes and a unique IP address.
  - Represents a running instance of a containerized application.

### 4. Cluster

The **Cluster** is the overarching structure that contains all the master and worker nodes. It is the physical or virtual machine environment where the Kubernetes control plane and containerized applications run. A Kubernetes cluster can be highly dynamic, with nodes being added or removed based on workload demands.

- **Key Characteristics**:
  - Can be composed of physical servers, virtual machines, or cloud instances.
  - Orchestrates the distribution of containers across multiple worker nodes.
  - Ensures fault tolerance and high availability.

### 5. Services, Networking, and Storage

- **Services**: A Kubernetes Service is an abstraction that defines a logical set of Pods and a policy for accessing them (e.g., through a stable IP address). Services allow decoupling of workloads and external traffic, enabling seamless communication across different components.

- **Networking**: Kubernetes networking model allows Pods running on different nodes to communicate with each other. Each Pod has a unique IP, and communication between Pods is managed by the network policies defined within the cluster.

- **Storage**: Kubernetes provides different storage abstractions to allow persistent data storage. Persistent Volumes (PVs) and Persistent Volume Claims (PVCs) enable Pods to retain data even after a container is terminated.

## Kubernetes Architecture Diagram

Below is a more detailed diagram of the Kubernetes architecture:

```plaintext
+------------------------------------+
|           Master Node              |
|                                    |
| +----------------------------+    |
| |       API Server            |    |
| +----------------------------+    |
| |       Scheduler             |    |
| +----------------------------+    |
| |   Controller Manager        |    |
| +----------------------------+    |
| |       etcd                  |    |
| +----------------------------+    |
+------------------------------------+

       |                                 |
       v                                 v

+---------------------------+   +---------------------------+
|     Worker Node 1          |   |     Worker Node 2          |
|                            |   |                            |
| +-----------------------+  |   | +-----------------------+  |
| |       Kubelet          |  |   | |       Kubelet          |  |
| +-----------------------+  |   | +-----------------------+  |
| |     Kube-proxy         |  |   | |     Kube-proxy         |  |
| +-----------------------+  |   | +-----------------------+  |
| |       Pod(s)           |  |   | |       Pod(s)           |  |
| +-----------------------+  |   | +-----------------------+  |
+---------------------------+   +---------------------------+
```

## Reference

To dive deeper into Kubernetes architecture, please visit the official [Kubernetes documentation](https://kubernetes.io/docs/concepts/architecture/).

## License

This repository is licensed under the Kubernetes documentation [license](https://kubernetes.io/docs/home/).
