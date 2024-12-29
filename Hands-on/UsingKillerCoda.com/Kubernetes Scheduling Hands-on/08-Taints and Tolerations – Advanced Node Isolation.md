### **Taints and Tolerations – Advanced Node Isolation (Real-World CKA Hands-On)**  



### **Concept Overview**  
In Kubernetes, **taints and tolerations** control **pod placement** by **preventing pods from scheduling on specific nodes** unless explicitly allowed.  
- **Taints** – Applied to nodes to **repel pods**.  
- **Tolerations** – Applied to pods to **override taints** and allow scheduling.  





### **Real-World Scenario**  
You manage a production Kubernetes cluster.  
🔹 **Requirement:** Ensure critical workloads (`frontend pods`) run on high-performance nodes, isolating them from less important tasks (`logging pods`).  





## **Hands-On 9: Implement Node Isolation with Taints and Tolerations**  



### **Step 1: Taint the Node (Isolate It)**  

```bash
kubectl taint nodes <node-name> env=prod:NoSchedule
```
- **Explanation:**  
  - Taint the node with key `env=prod`.  
  - Any pod without a matching toleration **will not be scheduled** on this node.  
  - `NoSchedule` – Pods cannot schedule unless they tolerate the taint.  





### **Step 2: Deploy Pods Without Toleration (Test Repulsion)**  

**Create a Logging Pod:**  

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: logging-pod
spec:
  containers:
  - name: logging
    image: busybox
    command: ["sh", "-c", "while true; do echo logging; sleep 10; done"]
```



```bash
kubectl apply -f logging-pod.yaml
kubectl describe pod logging-pod
```
- **Outcome:** Pod will stay in `Pending` state.  
- **Reason:** Node is tainted, and the pod does not have a toleration.  





### **Step 3: Apply Toleration to Allow Scheduling**  

**Modify the Logging Pod with Toleration:**  

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: logging-pod
spec:
  tolerations:
  - key: "env"
    operator: "Equal"
    value: "prod"
    effect: "NoSchedule"
  containers:
  - name: logging
    image: busybox
    command: ["sh", "-c", "while true; do echo logging; sleep 10; done"]
```



```bash
kubectl apply -f logging-pod.yaml
kubectl get pods -o wide
```
- **Outcome:** Pod successfully schedules on the tainted node.  





### **Explanation (Why It Works):**  
- **Key:** `env=prod` on the node matches the toleration key on the pod.  
- **Effect:** `NoSchedule` is overridden, and pod placement occurs.  





### **Advanced Task – Evict Pods (NoExecute Taint)**  

```bash
kubectl taint nodes <node-name> maintenance=true:NoExecute
```
- **Pods without toleration will be evicted immediately**.  
- Test by deploying a pod without tolerations and observe its eviction.  





### **Challenge – Test Your Understanding**  
1. **Create a Node Pool** (`gpu-nodes`) with taints:  
   - Key: `gpu=true:NoSchedule`  
2. **Deploy an AI pod** that tolerates `gpu=true`.  
3. **Ensure other pods cannot access GPU nodes.**  

Let me know when you're ready for the next step!
