### **Kubernetes Manual Scheduling – Deep Dive (Advanced Hands-On)**  
Manual scheduling is a foundational Kubernetes concept that lets you bypass the scheduler by directly assigning pods to nodes. While simple in essence, its implications, edge cases, and troubleshooting strategies offer rich learning opportunities.  

---

### **1. Understanding the Scheduling Flow (Before Hands-On)**  
Kubernetes scheduling typically works as follows:  
1. **Pod Creation**: A pod is defined in a manifest and submitted to the cluster.  
2. **Scheduler Interception**: The default scheduler intercepts the pod and looks for an available node that meets resource requirements, affinity, and constraints.  
3. **Node Binding**: The scheduler binds the pod to the node.  

**Manual Scheduling Bypasses Step 2.**  
By setting the `nodeName` field in the pod spec, you directly tell Kubernetes, "Run this pod here, don't use the scheduler."

---

---

## **Hands-On 1: Deep Dive into Basic Manual Pod Scheduling**  

### **Objective**  
- Schedule a pod directly to a specific node using `nodeName`.  
- Analyze the lifecycle, logs, and troubleshoot potential errors.  

---

### **Detailed Logical Flow**  

1. **Why Direct Scheduling?**  
- Sometimes, the default scheduler might not schedule pods correctly due to node constraints.  
- Direct scheduling ensures pods land exactly where you want.  
- Good for specialized nodes (e.g., GPU, ARM-based, or tainted nodes).  

2. **Real-World Use Case**  
- **Scenario**: A machine-learning app needs to run exclusively on GPU nodes, but the scheduler is overburdened or misconfigured.  
- **Solution**: Directly schedule pods using `nodeName` to ensure placement without waiting for scheduler resolution.  

---

### **Step-by-Step Implementation**  

1. **List Nodes**  
```bash
kubectl get nodes
```
Example Output:  
```
NAME       STATUS   ROLES           AGE    VERSION
node01     Ready    worker          5d     v1.25.0
controlplane  Ready    master         5d     v1.25.0
```

2. **Inspect Node Resources**  
```bash
kubectl describe node node01
```
- Check CPU, memory, and allocated resources.  
- Verify if there’s sufficient room for new pods.  

3. **Define Pod Manifest**  
```bash
nano manual-pod.yaml
```
Add:  
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: manual-pod
spec:
  nodeName: node01  # Directly scheduling to node01
  containers:
  - name: nginx
    image: nginx
    resources:
      requests:
        memory: "64Mi"
        cpu: "250m"
    ports:
    - containerPort: 80
```

---

### **Advanced Breakdown of YAML**  
- **`apiVersion`** – Defines the Kubernetes API.  
- **`kind`** – Specifies that this is a pod object.  
- **`metadata`** – Pod identification (critical for logging/troubleshooting).  
- **`spec.nodeName`** – Direct node assignment (bypasses scheduler).  
- **`containers`** – Defines the app (Nginx in this case).  
- **`resources.requests`** – Ensures pod requests specific resources, influencing node placement if available.  

---

4. **Apply Pod Manifest**  
```bash
kubectl apply -f manual-pod.yaml
```

5. **Check Pod Status**  
```bash
kubectl get pods -o wide
```
Example Output:  
```
NAME          READY   STATUS    RESTARTS   AGE   IP             NODE
manual-pod    1/1     Running   0          5s    192.168.1.15   node01
```

6. **Detailed Pod Inspection**  
```bash
kubectl describe pod manual-pod
```
- Look for node assignment confirmation under **Node: node01**.  

---

---

### **Why This Works**  
- **If Node Exists and is Ready** → Pod starts.  
- **If Node is Unschedulable/Full** → Pod remains in `Pending` state.  
- **If Node Doesn't Exist** → Pod creation fails immediately.  

---

---

## **Hands-On 2: Scheduling Pod on a Non-Existent Node (Failure Analysis)**  

### **Objective**  
Simulate scheduling a pod on a non-existent node to observe Kubernetes behavior and error logging.  

---

### **Step-by-Step**  

1. **Modify Pod Manifest**  
```yaml
spec:
  nodeName: non-existent-node
```

2. **Apply Pod**  
```bash
kubectl apply -f manual-pod.yaml
```

3. **Check Status**  
```bash
kubectl get pods
```
Output:  
```
NAME          READY   STATUS    RESTARTS   AGE
manual-pod    0/1     Pending   0          10s
```

4. **Describe Pod for Error Details**  
```bash
kubectl describe pod manual-pod
```
Look for:  
```
Warning  FailedScheduling  Pod  node(s) non-existent-node not found
```

---

### **Why This Happens**  
- Kubernetes cannot bind pods to non-existent nodes.  
- This helps detect misconfigurations early.  

---

---

## **Hands-On 3: Schedule Pods Across Different Nodes (Load Distribution)**  

### **Objective**  
Manually distribute pods to specific nodes for load balancing across the cluster.  

---

### **Step-by-Step**  

1. **Create Pod for Node01**  
```yaml
metadata:
  name: pod-node01
spec:
  nodeName: node01
  containers:
  - name: nginx
    image: nginx
```

2. **Create Pod for Control Plane**  
```yaml
metadata:
  name: pod-controlplane
spec:
  nodeName: controlplane
  containers:
  - name: nginx
    image: nginx
```

3. **Deploy Both Pods**  
```bash
kubectl apply -f pod-node01.yaml
kubectl apply -f pod-controlplane.yaml
```

4. **Verify Pod Distribution**  
```bash
kubectl get pods -o wide
```

---

---

## **Hands-On 4: Force Scheduling to a Drained Node (Debugging)**  

1. **Drain Node01**  
```bash
kubectl drain node01 --ignore-daemonsets
```

2. **Deploy Pod to Drained Node**  
```yaml
spec:
  nodeName: node01
```
```bash
kubectl apply -f manual-pod.yaml
```

3. **Check Pod Logs**  
```bash
kubectl describe pod manual-pod
```
Look for:  
```
Warning  FailedScheduling  5m  Node node01 is cordoned and cannot accept pods
```

4. **Uncordon the Node**  
```bash
kubectl uncordon node01
```

---

---

## **Hands-On 5: Node Over-Provisioning (Handling Resource Exhaustion)**  

1. **Schedule Pod to Exhaust Node Resources**  
```yaml
spec:
  nodeName: node01
  containers:
  - name: nginx
    image: nginx
    resources:
      requests:
        memory: "1000Mi"
        cpu: "1000m"
```

2. **Deploy and Check**  
```bash
kubectl apply -f manual-pod.yaml
kubectl describe pod manual-pod
```
Look for:  
```
Warning  FailedScheduling  Insufficient memory or CPU on node01
```

---

---

### **Advanced Analysis**  
- **Node Pressure**: Over-provisioning leads to pod failures, allowing testing of cluster limits.  
- **Resource Allocation**: Forces cluster admins to rethink scaling strategies or node resource allocation.  

---

Next: **Taints and Tolerations** to handle pod/node isolation dynamically.
