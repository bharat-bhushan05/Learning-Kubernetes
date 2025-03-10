### **📌 Lifecycle of Scheduling a Pod in Kubernetes**  

When a pod is created in Kubernetes, it goes through multiple stages before becoming "Running" or "Failed." The **Pod Scheduling Lifecycle** involves **various steps**, from creation to scheduling, execution, and termination.

Let's break it down **step by step** with **real-world scenarios** and Kubernetes internals. 🚀

---

## **1️⃣ Pod Creation (User Request)**
- A user (or an automated system like a CI/CD pipeline) creates a **Pod manifest** and submits it to the Kubernetes API server.
- Example:  
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  containers:
  - name: my-container
    image: nginx
```
- **Command to create the pod:**
```bash
kubectl apply -f my-pod.yaml
```
- The **Kubernetes API server** receives the request and stores it in **etcd** (Kubernetes' key-value store).

---

## **2️⃣ Pod Admission (Validation & Binding)**
The API server **validates** the request:
✔️ Checks if the YAML syntax is correct.  
✔️ Ensures the requested **resources (CPU, memory, storage)** are within namespace quotas.  
✔️ Verifies **RBAC permissions** (e.g., is the user allowed to create a pod?).  

- If validation fails, the pod remains in a `Pending` state, and you can check events:
```bash
kubectl describe pod my-pod
```

---

## **3️⃣ Scheduler Selects a Node**
The **Kube-Scheduler** picks a node to run the pod. It follows this **decision process**:

### 🔹 **Step 1: Filtering (Node Candidates)**
Kubernetes removes nodes that **cannot** run the pod. It checks:
✔️ Node is **Ready** (`kubectl get nodes`)  
✔️ Node has enough **CPU & Memory**  
✔️ Pod **tolerations and taints**  
✔️ **Node Selectors / Node Affinity** match  

### 🔹 **Step 2: Scoring (Best Fit Node)**
Kubernetes assigns scores based on:
✔️ **Least CPU/Memory requested** (spreads workloads evenly)  
✔️ **Pod affinity/anti-affinity rules**  
✔️ **Proximity to storage volumes** (e.g., local SSDs)  

### 🔹 **Step 3: Binding (Final Selection)**
- Kube-Scheduler assigns the pod to the best node.
- You can see the assigned node:
```bash
kubectl get pods -o wide
```
- If scheduling fails, the pod **remains in Pending**.

---

## **4️⃣ Kubelet Starts the Pod**
The **Kubelet** (running on the selected node) receives the pod and starts executing:
1. **Pulls the container image** from a registry (if not already cached).
2. **Creates a container runtime (Docker, containerd, CRI-O)**.
3. **Mounts volumes** (e.g., PVCs, Secrets, ConfigMaps).
4. **Executes the container entry point**.

🔹 **Check if the container is running**:
```bash
kubectl get pods
kubectl describe pod my-pod
kubectl logs my-pod -c my-container
```

---

## **5️⃣ Pod Running & Health Checks**
The pod enters the `Running` state if:
✔️ **Container is started successfully.**  
✔️ **Liveness and Readiness Probes pass.**  

💡 **Example of Health Probes in YAML**:
```yaml
livenessProbe:
  httpGet:
    path: /healthz
    port: 80
  initialDelaySeconds: 5
  periodSeconds: 10
```
- If probes fail, Kubernetes restarts the container.

---

## **6️⃣ Pod Termination & Eviction**
A pod stops running due to:
✅ **Manual Deletion**:  
```bash
kubectl delete pod my-pod
```
✅ **Preemption (Higher priority pod needs space)**  
✅ **Node Failure / Drain**  
```bash
kubectl drain <node-name> --ignore-daemonsets
```
✅ **Out of Resources (OOMKill)**  
- The pod is evicted if the node runs out of memory.

🔹 **Check Pod Termination Events**:
```bash
kubectl get events --sort-by=.metadata.creationTimestamp
```

---

## **🎯 Summary of Pod Scheduling Lifecycle**
| Phase         | Description |
|--------------|------------|
| **Pending** | API server validates the pod, waiting for a node |
| **Scheduled** | Kube-Scheduler assigns the pod to a node |
| **ContainerCreating** | Kubelet pulls the image and prepares the pod |
| **Running** | Pod is fully started and responding to probes |
| **Succeeded** | Pod ran and completed (for jobs/batch workloads) |
| **Failed** | Pod encountered an unrecoverable error |
| **Terminating** | Kubernetes is stopping the pod |

---

## **🔥 Hands-on Lab: Debugging Pod Scheduling Issues**
### **🛠️ Scenario 1: Pod Stuck in Pending**
1️⃣ Create a pod that **requires too much memory**:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: memory-hungry
spec:
  containers:
  - name: hungry-container
    image: nginx
    resources:
      requests:
        memory: "10Gi"
      limits:
        memory: "15Gi"
```
```bash
kubectl apply -f memory-hungry.yaml
kubectl get pods
kubectl describe pod memory-hungry
```
🚀 **Fix**: Reduce memory requests.

---

### **🛠️ Scenario 2: Pod Stuck in ContainerCreating**
```bash
kubectl describe pod my-pod
```
❌ If you see:
```
Failed to pull image: image not found
```
🚀 **Fix**: Check the image name, ensure it's available.

---

### **🛠️ Scenario 3: Pod Eviction Due to High Memory Usage**
```bash
kubectl top pod my-pod
kubectl top node
```
❌ If a pod is **killed due to OOM**, increase the memory limit.

---

### **🎯 Final Takeaways**
✔️ Understand **each step** in the pod scheduling lifecycle.  
✔️ Use `kubectl describe` and `kubectl logs` for debugging.  
✔️ **Test real-world failure scenarios** to gain hands-on experience.  

---
