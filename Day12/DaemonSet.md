# **DaemonSet in Kubernetes – Deep Dive 🚀**

## **🔹 What is a DaemonSet?**
A **DaemonSet** in Kubernetes ensures that a **specific pod runs on every node** (or a subset of nodes) in the cluster. It is mainly used for **cluster-wide services** like logging, monitoring, networking, or security-related tasks that should be present on each node.

### **📌 Key Characteristics:**
- Ensures **one pod per node** by default (unless tolerations and affinity rules allow more).
- Automatically **adds** a pod when a new node joins the cluster.
- Automatically **removes** the pod when a node is removed.
- If a node fails and is replaced, the DaemonSet **reschedules** the pod on the new node.

---

## **🔹 When to Use a DaemonSet?**
DaemonSets are ideal for running **system-level services** that should run on every node, such as:

✅ **Log Collection** → `fluentd`, `filebeat`, `logstash`  
✅ **Monitoring Agents** → `prometheus-node-exporter`, `datadog-agent`  
✅ **Security Agents** → `falco`, `OSSEC`, `security scanners`  
✅ **Networking Components** → `calico`, `cilium`, `flannel`, `kube-proxy`  
✅ **Storage Plugins** → `ceph`, `glusterFS`, `local volume provisioners`  

---

## **🔹 DaemonSet YAML Example**
Below is an example of a **Fluentd DaemonSet** used for logging.

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: fluentd
  namespace: kube-system
spec:
  selector:
    matchLabels:
      app: fluentd
  template:
    metadata:
      labels:
        app: fluentd
    spec:
      tolerations:
      - key: node-role.kubernetes.io/master
        effect: NoSchedule  # Ensures the pod runs even on master nodes
      containers:
      - name: fluentd
        image: fluent/fluentd:v1.14
        resources:
          limits:
            cpu: "500m"
            memory: "256Mi"
          requests:
            cpu: "100m"
            memory: "128Mi"
        volumeMounts:
        - name: varlog
          mountPath: /var/log
      volumes:
      - name: varlog
        hostPath:
          path: /var/log  # Access logs from the node
```

### **📌 Explanation**
- **`kind: DaemonSet`** → Ensures one pod per node.
- **`tolerations`** → Allows scheduling on master nodes.
- **`volumes`** → Uses `hostPath` to access `/var/log` on nodes.
- **`resources`** → Limits CPU and memory.

---

## **🔹 How DaemonSet Works Internally?**
1. **Scheduler Bypass**: Unlike Deployments, DaemonSets do **not use the default Kubernetes scheduler**. Instead, the Kubernetes controller directly assigns pods to nodes.
2. **Node Additions**: When a new node joins, the DaemonSet automatically schedules a pod on it.
3. **Pod Deletions**: If a node is drained or removed, the DaemonSet automatically removes the pod.
4. **Rolling Updates**: You can update a DaemonSet **without downtime** using `updateStrategy`.

---

## **🔹 Managing DaemonSets**
### **1️⃣ Deploy a DaemonSet**
```bash
kubectl apply -f fluentd-daemonset.yaml
```

### **2️⃣ List DaemonSets**
```bash
kubectl get daemonset -n kube-system
```

### **3️⃣ View DaemonSet Pods**
```bash
kubectl get pods -o wide
```

### **4️⃣ Scale a DaemonSet (Not Allowed!)**
```bash
kubectl scale daemonset fluentd --replicas=2
```
📌 **This will fail!** DaemonSets do not allow manual scaling.

### **5️⃣ Delete a DaemonSet**
```bash
kubectl delete daemonset fluentd -n kube-system
```
📌 **This removes all pods from nodes.**

---

## **🔹 DaemonSet Update Strategies**
DaemonSets support two update strategies:
1. **OnDelete** → Pods update only if explicitly deleted.
2. **RollingUpdate** → Pods update gradually (default behavior).

### **Example: Rolling Update**
```yaml
spec:
  updateStrategy:
    type: RollingUpdate
```

### **Verify Rolling Updates**
```bash
kubectl rollout status daemonset fluentd
```

---

## **🔹 Advanced DaemonSet Features**
### **1️⃣ Run on Specific Nodes Only**
Use **Node Selectors** or **Node Affinity** to target specific nodes.

```yaml
spec:
  template:
    spec:
      nodeSelector:
        disktype: ssd  # Runs only on nodes with SSD storage
```

---

### **2️⃣ Running on Master Nodes**
By default, **DaemonSets do not run on master nodes**.  
To override this, use **tolerations**:

```yaml
spec:
  template:
    spec:
      tolerations:
      - key: node-role.kubernetes.io/master
        effect: NoSchedule
```

---

### **3️⃣ Running Multiple Pods per Node**
By default, DaemonSets run **one pod per node**, but you can allow multiple by using **different labels**.

```yaml
metadata:
  labels:
    app: fluentd-1
```
📌 This allows multiple DaemonSets to run **different versions** of Fluentd.

---

## **🔹 Key Differences: DaemonSet vs Deployment**
| Feature | DaemonSet | Deployment |
|---------|-----------|------------|
| **Purpose** | Runs pods on every node | Runs pods on specific nodes |
| **Scaling** | Automatically 1 per node | Manual scaling allowed |
| **Pod Scheduling** | Directly assigned | Uses Kubernetes scheduler |
| **Example Use Cases** | Logging, monitoring, networking | Applications, microservices |

---

## **🔹 When NOT to Use DaemonSet?**
- **For applications that do not need to run on every node.**  
- **If scaling pods manually is required.**  
- **For stateless workloads where horizontal scaling is needed.**  

---

## **🔹 Conclusion**
✅ **DaemonSets are perfect for system-level services** that must run across all nodes.  
✅ **Automatic scaling with the cluster** ensures smooth operation.  
✅ **Efficiently manage infrastructure components** like logging, monitoring, and networking.  

Would you like a **real-world hands-on lab** for this? Let me know! 🚀🔥
