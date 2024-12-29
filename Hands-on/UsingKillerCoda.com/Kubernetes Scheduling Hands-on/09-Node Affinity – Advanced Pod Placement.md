### **Node Affinity – Advanced Pod Placement (Real-World CKA Hands-On)**  



### **Concept Overview**  
**Node Affinity** extends **nodeSelector** by offering **greater flexibility and advanced rules** for pod scheduling.  
- It allows **soft (preferred)** and **hard (required)** constraints for node selection.  
- Key advantage: **Pods can "prefer" certain nodes without failing if they aren’t available**.  





### **Real-World Scenario**  
🔹 **Requirement:**  
- Deploy **frontend pods** on nodes labeled `frontend=true`.  
- If no such nodes exist, schedule on **any node** as a fallback.  





## **Hands-On 11: Use Node Affinity for Pod Placement**  



### **Step 1: Label Nodes Based on Role**  

```bash
kubectl label nodes <node-name> frontend=true
```
- Label nodes that will **preferentially host frontend pods**.  





### **Step 2: Define Pod with Node Affinity**  

**Create a Pod Definition (with Required and Preferred Affinity):**  

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: frontend-pod
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: frontend
            operator: In
            values:
            - "true"
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 1
        preference:
          matchExpressions:
          - key: region
            operator: In
            values:
            - "us-east-1"
  containers:
  - name: frontend
    image: nginx
```



```bash
kubectl apply -f frontend-pod.yaml
kubectl get pods -o wide
```
- **Explanation:**  
  - Pod **must schedule** on nodes labeled `frontend=true`.  
  - **Prefer nodes** in region `us-east-1` if multiple nodes match.  





### **Step 3: Test Pod Placement (Without Labels)**  

- Deploy the pod **without labeling** any node with `frontend=true`.  

```bash
kubectl describe pod frontend-pod
```
- Pod will stay in **Pending** because no node satisfies the **hard affinity**.  





### **Step 4: Label Node to Resolve Scheduling**  

```bash
kubectl label nodes <node-name> frontend=true region=us-east-1
```
- Pod will now **immediately schedule** on the labeled node.  





### **Explanation (Why It Works):**  
- **Hard Affinity:** Requires the pod to run on specific nodes (`frontend=true`).  
- **Soft Affinity:** Prefers nodes in the `us-east-1` region but will still run if unavailable.  
- **Benefit:**  
  - Ensures **mission-critical pods** land on **designated nodes**.  
  - Provides **flexibility** when nodes aren't available.  





### **Advanced Task – Multi-Affinity Pod**  
1. Label a node as:  

```bash
kubectl label nodes <node-name> tier=backend env=prod
```

2. Deploy a pod that requires:  
   - **tier=backend** (hard requirement).  
   - Prefers **prod nodes**.  



**YAML:**  
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: backend-pod
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: tier
            operator: In
            values:
            - "backend"
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 10
        preference:
          matchExpressions:
          - key: env
            operator: In
            values:
            - "prod"
  containers:
  - name: backend
    image: nginx
```





### **Challenge – Test Your Understanding**  
1. Label nodes for different zones (`zone-a`, `zone-b`).  
2. Deploy pods that:  
   - **Require `zone-a`**.  
   - Prefer `zone-b` but can tolerate scheduling elsewhere.  
3. **Evict pods** by removing labels and observe pod behavior.  



Let me know when you're ready for **Resource Requests and Limits Hands-On**!
