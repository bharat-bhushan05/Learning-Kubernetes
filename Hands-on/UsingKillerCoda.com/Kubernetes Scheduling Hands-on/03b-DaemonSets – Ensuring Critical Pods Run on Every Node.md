### **DaemonSets – Ensuring Critical Pods Run on Every Node (Real-World CKA Hands-On)**  

---

### **Concept Overview**  
**DaemonSets** ensure that a pod runs **once on every node** in the cluster.  
- Ideal for **logging, monitoring, and network agents**.  
- New pods automatically deploy to **new nodes** when they join the cluster.  
- Deleting nodes triggers **pod eviction**.  

---

---

### **Real-World Scenario**  
🔹 **Requirement:**  
- Deploy a **logging agent** that runs on **every node** to collect system logs.  
- Ensure pods scale automatically with node additions/removals.  

---

---

## **Hands-On 13: Deploy DaemonSets for Cluster-Wide Logging**  

---

### **Step 1: Create a DaemonSet Definition**  

**YAML Definition (fluentd-logger DaemonSet):**  
```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: fluentd
spec:
  selector:
    matchLabels:
      name: fluentd
  template:
    metadata:
      labels:
        name: fluentd
    spec:
      containers:
      - name: fluentd
        image: fluent/fluentd:v1.14
        resources:
          limits:
            memory: "500Mi"
            cpu: "200m"
        volumeMounts:
        - name: varlog
          mountPath: /var/log
      volumes:
      - name: varlog
        hostPath:
          path: /var/log
```

---

```bash
kubectl apply -f fluentd-daemonset.yaml
kubectl get pods -o wide
```
- **Explanation:**  
  - A pod runs on **every node** mounting `/var/log`.  
  - **fluentd** collects logs and forwards them.  

---

---

### **Step 2: Add New Nodes and Verify DaemonSet Behavior**  
1. Scale the cluster by adding nodes.  
2. Verify pods are automatically created:  
```bash
kubectl get pods -o wide
```
- New nodes will have **one fluentd pod each**.  

---

---

### **Step 3: Drain a Node to Evict DaemonSet Pods**  
```bash
kubectl drain <node-name> --ignore-daemonsets
kubectl get pods -o wide
```
- DaemonSet pods **remain on drained nodes** unless `--ignore-daemonsets` is used.  

---

---

### **Step 4: Label Nodes for Selective DaemonSet Deployment**  

```bash
kubectl label nodes <node-name> logging=true
```

- Update the DaemonSet to run **only on labeled nodes**:  
```yaml
spec:
  template:
    spec:
      nodeSelector:
        logging: "true"
```

```bash
kubectl apply -f fluentd-daemonset.yaml
```
- Fluentd pods now **only run on nodes with `logging=true`**.  

---

---

### **Explanation (Why It Works):**  
- **DaemonSets** ensure essential services are **always available** on all nodes.  
- Node labeling enables **targeted pod placement**.  
- Useful for **distributed logging, network monitoring, and security agents**.  

---

---

### **Advanced Task – Deploy DaemonSets with Affinity**  
- Deploy a DaemonSet that **avoids master nodes** but runs on all worker nodes.  
- Use **node affinity** to exclude `node-role.kubernetes.io/master`.  

---

**YAML Definition (Anti-affinity Example):**  
```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: node-exporter
spec:
  template:
    spec:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: node-role.kubernetes.io/master
                operator: DoesNotExist
      containers:
      - name: node-exporter
        image: prom/node-exporter
```
```bash
kubectl apply -f node-exporter.yaml
kubectl get pods -o wide
```
- DaemonSet avoids **master nodes** while targeting workers.  

---

---

### **Challenge – Test Your Understanding**  
1. Deploy a DaemonSet that:  
   - Targets nodes with `env=prod`.  
   - Runs `busybox` to monitor system logs.  
2. Simulate node additions and verify **auto-scaling of DaemonSet pods**.  
3. Drain a node and observe DaemonSet pod behavior.  

---

Let me know when you're ready for **Static Pods Hands-On**!
