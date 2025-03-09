A real-world example to **test CPU and memory exhaustion** scenarios in a Kubernetes cluster.

---

## **🔹 Scenario 1: Testing CPU Exhaustion**
We'll deploy a pod that runs a high-CPU workload to see what happens when it exceeds CPU requests and limits.

### **1️⃣ Create a CPU-Stress Pod**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: cpu-stress
  namespace: default
spec:
  containers:
  - name: stress
    image: polinux/stress  # Stress test container
    resources:
      requests:
        cpu: "500m"
      limits:
        cpu: "1"
    command: ["stress"]
    args: ["--cpu", "2", "--timeout", "600"]
```
✅ **This pod:**
- Requests `500m` (0.5 CPU cores).
- Has a limit of `1` CPU core.
- Runs `stress` to fully load the CPU for `600 seconds (10 minutes)`.

### **2️⃣ Deploy the Pod**
```bash
kubectl apply -f cpu-stress.yaml
```

### **3️⃣ Monitor CPU Usage**
```bash
kubectl top pod cpu-stress
```
- If **CPU usage stays within 1 CPU**, Kubernetes **throttles** it.
- If **CPU exceeds the request (500m)** but stays within the limit (1), it runs slower.

### **4️⃣ Verify CPU Throttling**
Run the following to see CPU throttling:
```bash
kubectl describe pod cpu-stress | grep -i throttled
```

📌 **Expected Result:**
- The pod does **not get killed**.
- It is **throttled** if it exceeds the requested CPU (`500m`).

---

## **🔹 Scenario 2: Testing Memory Exhaustion (OOMKill)**
We'll create a pod that tries to consume more memory than allowed.

### **1️⃣ Create a Memory-Stress Pod**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: memory-stress
  namespace: default
spec:
  containers:
  - name: stress
    image: polinux/stress
    resources:
      requests:
        memory: "128Mi"
      limits:
        memory: "256Mi"
    command: ["stress"]
    args: ["--vm", "2", "--vm-bytes", "512M", "--timeout", "600"]
```
✅ **This pod:**
- Requests **128Mi** memory.
- Has a limit of **256Mi** memory.
- Runs **stress** to allocate `512M`, exceeding the limit.

### **2️⃣ Deploy the Pod**
```bash
kubectl apply -f memory-stress.yaml
```

### **3️⃣ Monitor Memory Usage**
```bash
kubectl top pod memory-stress
```
- If the pod tries to exceed **256Mi**, Kubernetes **kills it (OOMKilled)**.

### **4️⃣ Check Pod Status**
```bash
kubectl get pods memory-stress
```
```bash
kubectl describe pod memory-stress | grep -i "oom"
```
📌 **Expected Result:**
- Pod gets **OOMKilled** and restarts.
- If the pod is in a crash loop, you’ll see:  
  ```
  Reason: OOMKilled
  ```

---

## **🔹 Scenario 3: What If Node Runs Out of CPU or Memory?**
If multiple pods consume all CPU/memory:
1. **CPU Exhaustion:**  
   - All pods slow down due to throttling.
   - Kubernetes does **not evict pods**.
   
2. **Memory Exhaustion:**  
   - Kubernetes **kills** non-critical pods.
   - If no memory is left, **the node crashes and restarts**.

### **Test This on a Node**
Run:
```bash
kubectl top node
```
If memory is too high:
```bash
kubectl describe node <node-name> | grep -i "memory pressure"
```
📌 **Expected Output:**
- `MemoryPressure=True` means the node is running out of memory.
- Pods are evicted.

---

## **🔹 Cleanup**
```bash
kubectl delete pod cpu-stress memory-stress
```

---

### **🔹 Summary of Expected Behavior**
| Scenario | What Happens? | Solution |
|----------|--------------|----------|
| **Pod consumes all CPU** | Pod is **throttled**, but not killed. | Set **CPU limits**, use **HPA**. |
| **Pod consumes all memory** | Pod is **OOMKilled** and restarted. | Set **Memory limits**, use **VPA**. |
| **Node runs out of CPU** | All pods slow down (throttling). | Scale cluster or use **HPA**. |
| **Node runs out of memory** | Some pods are evicted, node may crash. | Use **VPA**, limit memory. |
---
Great! Let's test **CPU and memory exhaustion scenarios** on a real Kubernetes cluster and analyze logs. 🚀  

---

## **🔹 Step 1: Deploy a High CPU Consumption Pod**
We’ll create a pod that consumes **more CPU** than its request to trigger throttling.

### **1️⃣ Create a `cpu-stress.yaml` file**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: cpu-stress
  namespace: default
spec:
  containers:
  - name: stress
    image: polinux/stress
    resources:
      requests:
        cpu: "500m"
      limits:
        cpu: "1"  # Maximum 1 CPU core
    command: ["stress"]
    args: ["--cpu", "2", "--timeout", "600"]  # Uses 2 CPU cores for 10 minutes
```

### **2️⃣ Apply the Pod**
```bash
kubectl apply -f cpu-stress.yaml
```

### **3️⃣ Monitor CPU Usage**
```bash
kubectl top pod cpu-stress
```
📌 **Expected Output:**  
The pod **consumes up to 1 CPU core** (throttled if it exceeds `500m`).

### **4️⃣ Check CPU Throttling**
```bash
kubectl describe pod cpu-stress | grep -i throttled
```
📌 **Expected Output:**  
If throttled, you'll see logs about CPU limits being enforced.

---

## **🔹 Step 2: Deploy a High Memory Consumption Pod**
We’ll create a pod that tries to **consume more memory** than its limit, triggering an OOMKill.

### **1️⃣ Create a `memory-stress.yaml` file**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: memory-stress
  namespace: default
spec:
  containers:
  - name: stress
    image: polinux/stress
    resources:
      requests:
        memory: "128Mi"
      limits:
        memory: "256Mi"  # Max limit
    command: ["stress"]
    args: ["--vm", "1", "--vm-bytes", "512M", "--timeout", "600"]  # Requests 512Mi (above limit)
```

### **2️⃣ Apply the Pod**
```bash
kubectl apply -f memory-stress.yaml
```

### **3️⃣ Monitor Memory Usage**
```bash
kubectl top pod memory-stress
```
📌 **Expected Output:**  
- If memory usage goes above `256Mi`, the pod is **OOMKilled**.

### **4️⃣ Check if Pod is Killed**
```bash
kubectl get pods memory-stress
kubectl describe pod memory-stress | grep -i "oom"
```
📌 **Expected Output:**  
```
Reason: OOMKilled
```
This means Kubernetes **terminated the pod** due to excessive memory usage.

---

## **🔹 Step 3: Simulate a Node Running Out of CPU or Memory**
If multiple high-resource pods run, they can **consume all resources of a node**.

### **1️⃣ Check Node Resource Usage**
```bash
kubectl top node
```

### **2️⃣ Check if the Node is Under Pressure**
```bash
kubectl describe node <node-name> | grep -i "pressure"
```
📌 **Expected Outputs:**
- `MemoryPressure=True`: Node **does not have enough memory**, pods may be evicted.  
- `CPUPressure=True`: Node **is running out of CPU**, but pods are only throttled.

---

## **🔹 Step 4: Cleanup**
```bash
kubectl delete pod cpu-stress memory-stress
```
This removes the test pods.

---

## **🔹 Summary of Expected Behavior**
| Scenario | What Happens? | Solution |
|----------|--------------|----------|
| **Pod consumes all CPU** | Throttling occurs, but pod runs. | Set **CPU limits**, use **HPA**. |
| **Pod consumes all memory** | Kubernetes **OOMKills** the pod. | Set **memory limits**, use **VPA**. |
| **Node runs out of CPU** | Throttling for all pods. | Scale cluster, use **HPA**. |
| **Node runs out of memory** | Pods are evicted, node may crash. | Use **VPA**, limit memory. |

---



---
