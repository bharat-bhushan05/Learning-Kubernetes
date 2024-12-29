### **Node Selectors – Kubernetes Advanced Scheduling (Real-World Hands-On for CKA)**  

---

### **Concept Overview**  
**Node Selectors** allow pods to be scheduled on specific nodes based on labels. This is one of the simplest methods for pod placement.  

- **Why Use Node Selectors?**  
  - Ensure workloads run on nodes with specific hardware (GPU, SSD).  
  - Isolate environments (dev, prod).  
  - Optimize performance by distributing pods based on node characteristics.  
  - Compliance with regulatory requirements.  

**Real-World Example:**  
- AI/ML pods require GPU nodes.  
- Compliance apps must run on isolated nodes.  
- Logging pods should run only on storage-optimized nodes.  

---

---

## **Hands-On 1: Schedule Pods on Specific Nodes Using Node Selectors**  

---

### **Scenario**  
You are deploying a pod that requires GPU processing. You need to ensure that this pod lands only on GPU-enabled nodes.  

---

### **Step 1: Label a Node for GPU Workloads**  

```bash
kubectl label nodes node01 gpu=true
```
- Adds a label `gpu=true` to `node01`.  
- This tells Kubernetes the node can handle GPU workloads.  

---

### **Step 2: Verify Node Label**  

```bash
kubectl get nodes --show-labels
```
Look for:  
```
node01   <other-labels>,gpu=true
```

---

### **Step 3: Deploy a Pod with Node Selector**  

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: gpu-pod
spec:
  containers:
  - name: gpu-container
    image: nvidia/cuda:11.0-base
  nodeSelector:
    gpu: "true"
```

```bash
kubectl apply -f gpu-pod.yaml
```

---

### **Step 4: Verify Pod Scheduling**  

```bash
kubectl get pods -o wide
```
- Pod should be scheduled on `node01`.  
```bash
kubectl describe pod gpu-pod
```
- Look for:  
```
Node: node01
```

---

---

## **Deep Analysis – Why This Works**  
- **Matching Labels** – The `nodeSelector` instructs Kubernetes to place the pod on nodes with `gpu=true`.  
- **Simplest Method** – Node Selectors are simple but **lack flexibility**.  
- If no node has the label, pods **remain in Pending** state.  

---

---

## **Real-World Use Case 1: Storage-Optimized Node for Logging**  
You need to ensure all logging pods run on high-storage nodes.  

---

### **Label Node for Storage**  

```bash
kubectl label nodes node02 storage=high
```

---

### **Deploy Logging Pod**  

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: logging-pod
spec:
  containers:
  - name: fluentd
    image: fluentd
  nodeSelector:
    storage: "high"
```

```bash
kubectl apply -f logging-pod.yaml
```
- Pod will only land on `node02`.  

---

---

### **Challenge: What If the Node Fails?**  
- **Node Selector Limitation** – If the labeled node fails, pods **won’t reschedule** to another node.  
- **Solution** – Use **Node Affinity (next topic)** for advanced scheduling strategies.  

---

---

## **Your Task (Before Next Hands-On)**  
- **Try removing the node label** while the pod is running:  
  ```bash
  kubectl label nodes node01 gpu-
  ```  
- Observe what happens to the pod (`kubectl get pods`).  

---

Let me know once you complete this. We will proceed to **Node Affinity** to solve this challenge in the next hands-on.
