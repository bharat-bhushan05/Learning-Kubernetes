### **DaemonSets – Ensuring Pods Run on All Nodes (Real-World CKA Hands-On)**  

---

### **Concept Overview**  
**DaemonSets** ensure that a copy of a pod runs on every node (or a subset based on selectors). This is critical for:  
- **Node Monitoring** (Prometheus, Fluentd)  
- **Logging Agents**  
- **Networking Components** (Calico, Cilium)  
- **Security Daemons**  

---

---

### **Real-World Scenario**  
You are tasked with deploying a **node monitoring agent** (using Nginx as a placeholder) to ensure it runs on **all nodes** in the cluster, even if new nodes are added.  

---

---

## **Hands-On 4: Deploy DaemonSet for Monitoring**  

---

### **Step 1: Create DaemonSet for Node Monitoring**  

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: node-monitor
spec:
  selector:
    matchLabels:
      app: monitor
  template:
    metadata:
      labels:
        app: monitor
    spec:
      containers:
      - name: nginx-monitor
        image: nginx
        ports:
        - containerPort: 80
```

---

---

### **Explanation**  
- **`DaemonSet`** ensures one pod is created on **each node**.  
- New nodes will automatically receive a pod.  
- If a node is drained or deleted, the pod is rescheduled.  

---

---

### **Step 2: Apply and Verify**  

```bash
kubectl apply -f node-monitor.yaml
kubectl get pods -o wide
```
- Verify if pods are created on each node.  

```bash
kubectl get daemonsets
kubectl describe daemonset node-monitor
```
- Ensure each node has a pod by checking the `DESIRED` and `CURRENT` pod counts.  

---

---

### **Step 3: Add a New Node to the Cluster (Simulated)**  

1. **Label a New Node (Simulate Auto-Scaling):**  
   ```bash
   kubectl label nodes node03 monitoring=true
   ```  
2. **Observe Pod Creation on the New Node:**  
   ```bash
   kubectl get pods -o wide
   ```  
   - A new pod should automatically be scheduled on `node03`.  

---

---

## **Challenge: Limit DaemonSet to Specific Nodes**  
Modify the DaemonSet to **only run on nodes labeled `monitoring=true`**.  

---

### **Step 4: Update DaemonSet to Target Specific Nodes**  

```yaml
spec:
  template:
    spec:
      nodeSelector:
        monitoring: "true"
```

```bash
kubectl apply -f node-monitor.yaml
```

---

---

### **Verification Task**  
1. **Remove the Label from a Node:**  
   ```bash
   kubectl label nodes node01 monitoring-
   ```  
2. **Observe Pod Deletion:**  
   ```bash
   kubectl get pods -o wide
   ```  
   - Pods on `node01` should terminate.  

---

---

## **Advanced Challenge – DaemonSet for GPU Nodes Only**  
- Label nodes with GPUs and deploy DaemonSets **exclusively on GPU nodes**.  
- I can guide you through this if you’re ready.  

Next up: **Static Pods – Direct Pod Management without Kubelet Control**. Let me know when you're ready!
