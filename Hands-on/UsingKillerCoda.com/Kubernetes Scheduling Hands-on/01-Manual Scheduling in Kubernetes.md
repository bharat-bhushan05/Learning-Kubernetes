### **Manual Scheduling in Kubernetes (Day 1-2)**  
Manual scheduling involves directly specifying the node on which a pod should run by setting the `nodeName` field in the pod manifest. This bypasses the Kubernetes scheduler.

---

### **Why Manual Scheduling?**  
- **Testing and Debugging**: Helps in testing node capacity, affinity, or node readiness.  
- **Controlled Placement**: Useful when specific workloads must run on designated nodes (e.g., GPU nodes).  
- **Scheduler Bypass**: Allows placing pods without waiting for the default scheduler.

---

### **Limitations of Manual Scheduling**  
- **No Rescheduling**: If a node fails, the pod will not be rescheduled automatically.  
- **Error-Prone**: Specifying non-existent or drained nodes leads to scheduling failures.  
- **Static Approach**: Doesn't adapt to node changes dynamically.

---

---

## **Hands-On 1: Basic Manual Pod Scheduling**  

### **Objective**  
Create and schedule a pod manually on a specific node.  

### **Steps**  

1. **Login to Killercoda Kubernetes Environment**  
   - Visit [killercoda.com](https://killercoda.com)  
   - Select the Kubernetes playground and start the environment.  
   - Access the cluster using the terminal.  

2. **List Available Nodes**  
```bash
kubectl get nodes
```
- Identify the node names (e.g., `node01` or `controlplane`).  

3. **Create a Pod Manifest**  
```bash
nano manual-pod.yaml
```
Add the following content:  
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: manual-pod
spec:
  nodeName: node01
  containers:
  - name: nginx
    image: nginx
    ports:
    - containerPort: 80
```

4. **Deploy the Pod**  
```bash
kubectl apply -f manual-pod.yaml
```

5. **Verify Pod Placement**  
```bash
kubectl get pods -o wide
```
- Ensure the pod is running on `node01`.  

6. **Check Pod Logs**  
```bash
kubectl logs manual-pod
```

---

### **Explanation**  
- **`nodeName: node01`**: Directly binds the pod to `node01`.  
- **`containers`**: Defines the pod's container, using the `nginx` image.  

If the pod remains in `Pending` state, use:  
```bash
kubectl describe pod manual-pod
```
- Check for errors such as **NodeNotFound** or **Unschedulable**.

---

---

## **Hands-On 2: Schedule Pod on a Non-Existent Node**  

### **Objective**  
Test pod behavior when scheduled to an invalid node.  

---

1. **Modify Pod Manifest**  
```yaml
nodeName: invalid-node
```

2. **Apply Manifest**  
```bash
kubectl apply -f manual-pod.yaml
```

3. **Check Pod Status**  
```bash
kubectl get pods
```

4. **Troubleshoot**  
```bash
kubectl describe pod manual-pod
```
- Look for errors like:  
```
FailedScheduling: no nodes are available
```

---

### **Explanation**  
- Kubernetes cannot schedule the pod because `invalid-node` doesn’t exist.  
- This simulates failure conditions when a node is incorrectly referenced.  

---

---

## **Hands-On 3: Schedule Two Pods on Different Nodes**  

### **Objective**  
Manually schedule two pods on two different nodes.  

---

1. **Create Two Pod Manifests**  
```bash
nano pod-node01.yaml
```
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod-node01
spec:
  nodeName: node01
  containers:
  - name: nginx
    image: nginx
```

```bash
nano pod-node02.yaml
```
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod-node02
spec:
  nodeName: node02
  containers:
  - name: nginx
    image: nginx
```

2. **Deploy the Pods**  
```bash
kubectl apply -f pod-node01.yaml
kubectl apply -f pod-node02.yaml
```

3. **Verify Placement**  
```bash
kubectl get pods -o wide
```

---

### **Explanation**  
- This demonstrates distributing workloads across multiple nodes by directly targeting them.  
- Useful for high availability and load balancing tests.  

---

---

## **Hands-On 4: Debugging Manual Scheduling Failures**  

### **Objective**  
Learn to debug when pod scheduling fails.  

---

1. **Modify Pod to Target a Drained Node**  
```yaml
nodeName: node01
```

2. **Drain the Node**  
```bash
kubectl drain node01 --ignore-daemonsets
```

3. **Deploy Pod**  
```bash
kubectl apply -f manual-pod.yaml
```

4. **Check Events**  
```bash
kubectl describe pod manual-pod
```
- Look for `PodUnschedulable` or `NodeNotReady` events.  

5. **Uncordon Node**  
```bash
kubectl uncordon node01
```
- Retry scheduling the pod.  

---

### **Explanation**  
- **Drained Node**: Nodes that are drained cannot accept new pods.  
- **Uncordon**: Re-enables the node for scheduling.  

---

---

## **Hands-On 5: Moving Pods Between Nodes**  

### **Objective**  
Move a pod from one node to another by modifying its manifest.  

---

1. **Delete the Existing Pod**  
```bash
kubectl delete pod manual-pod
```

2. **Modify Manifest to Target Another Node**  
```yaml
nodeName: node02
```

3. **Redeploy Pod**  
```bash
kubectl apply -f manual-pod.yaml
```

4. **Verify New Placement**  
```bash
kubectl get pods -o wide
```

---

### **Explanation**  
- Manual rescheduling is done by deleting and redeploying pods.  
- Kubernetes doesn’t automatically move manually scheduled pods, hence the need for redeployment.  

---

---

### **Recap of Manual Scheduling**  
- **Direct Node Assignment**: `nodeName` directly assigns pods to nodes.  
- **Use Cases**: Target specific nodes for testing or workload separation.  
- **Caveats**: No automatic rescheduling on node failure.  

---

**Next Step** – Move to **Taints and Tolerations** to control pod placement dynamically.
