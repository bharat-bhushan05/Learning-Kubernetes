### **Node Selectors – Control Pod Placement (Real-World CKA Hands-On)**  



### **Concept Overview**  
Node selectors allow **fine-grained control** over pod scheduling by targeting specific nodes using **key-value labels**.  
- **Pods are only scheduled** on nodes that match the specified labels.  
- Simple yet effective for separating environments (e.g., `dev`, `prod`).  





### **Real-World Scenario**  
🔹 **Requirement:** Deploy application pods on **high-memory nodes** to ensure optimal performance.  
🔹 Other services (like logging) should remain on **standard nodes**.  





## **Hands-On 10: Use Node Selectors for Pod Placement**  



### **Step 1: Label Nodes Based on Capability**  

```bash
kubectl label nodes <node-name> hardware=high-memory
```
- Label a node with `hardware=high-memory`.  
- This node will now **host high-memory pods**.  





### **Step 2: Create Pod with Node Selector**  

**Create a Pod Definition:**  

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-pod
spec:
  nodeSelector:
    hardware: high-memory
  containers:
  - name: app
    image: nginx
    resources:
      requests:
        memory: "1Gi"
      limits:
        memory: "2Gi"
```



```bash
kubectl apply -f app-pod.yaml
kubectl get pods -o wide
```
- Pod is placed on the **high-memory node** due to the `nodeSelector`.  
- If no node has this label, the pod will stay **in Pending**.  





### **Step 3: Test Node Selector (Deploy Without Label)**  

- Deploy the pod **without labeling** any node as `high-memory`.  

```bash
kubectl describe pod app-pod
```
- The pod will remain in **Pending** because no matching node exists.  
- This ensures only labeled nodes can host the pod.  





### **Step 4: Add Label to Fix Scheduling**  

```bash
kubectl label nodes <node-name> hardware=high-memory
kubectl get nodes --show-labels
```
- Pod schedules immediately after node is labeled.  





### **Explanation (Why It Works):**  
- **Node Selectors** enable **manual control** over node selection based on workloads.  
- Nodes without the required label are **ignored**.  





### **Advanced Task – Multi-Selector Pod**  
1. Label another node:  

```bash
kubectl label nodes <node-name> env=prod
```

2. Deploy a pod that **requires both labels** (`hardware=high-memory` and `env=prod`).  



**YAML:**  
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-prod-pod
spec:
  nodeSelector:
    hardware: high-memory
    env: prod
  containers:
  - name: app
    image: nginx
```

- Only nodes matching **both labels** will schedule this pod.  





### **Challenge – Test Your Understanding**  
1. Label 3 nodes with different environments (`dev`, `qa`, `prod`).  
2. Deploy pods that:  
   - Run on **prod nodes** only.  
   - Are restricted to **dev nodes**.  
3. Verify that pods only schedule on their intended environments.  



Let me know when you're ready to proceed with **Node Affinity (More Advanced Selectors)**!
