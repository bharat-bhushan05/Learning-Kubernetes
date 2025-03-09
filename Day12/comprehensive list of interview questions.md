A **comprehensive list of interview questions** on **DaemonSets in Kubernetes**, including **conceptual, practical, and scenario-based** questions, along with **detailed explanations**.

---

# **🔹 Basic Questions on DaemonSet**
### **1️⃣ What is a DaemonSet in Kubernetes?**
💡 **Answer:**  
A **DaemonSet** is a Kubernetes resource that ensures that a **copy of a specific pod runs on every node** (or a subset of nodes) in a cluster. It is typically used for **node-level services** like log collection, monitoring, or networking components.

### **2️⃣ How does a DaemonSet differ from a Deployment?**
| Feature        | **DaemonSet** | **Deployment** |
|---------------|--------------|--------------|
| Pod Scheduling | Runs one pod per node | Can run multiple pods on any node |
| Use Cases | Monitoring, logging, networking | Application workloads |
| Scaling | Automatically schedules on new nodes | Requires manual or autoscaling |

---

# **🔹 Intermediate Questions**
### **3️⃣ How does Kubernetes schedule DaemonSet pods?**
💡 **Answer:**  
DaemonSet pods are **not managed by the default Kubernetes scheduler**. Instead, the **DaemonSet controller** schedules them directly on nodes.

### **4️⃣ How can you limit DaemonSet pods to specific nodes?**
💡 **Answer:**  
Use **nodeSelector, affinity, or taints & tolerations**.

- **Using `nodeSelector`**  
  ```yaml
  spec:
    template:
      spec:
        nodeSelector:
          custom-label: log-collector
  ```

- **Using `affinity` for advanced scheduling:**  
  ```yaml
  spec:
    template:
      spec:
        affinity:
          nodeAffinity:
            requiredDuringSchedulingIgnoredDuringExecution:
              nodeSelectorTerms:
              - matchExpressions:
                - key: node-type
                  operator: In
                  values:
                  - logging-node
  ```

---

# **🔹 Advanced Questions**
### **5️⃣ What update strategies are available for a DaemonSet?**
💡 **Answer:**  
DaemonSet supports two update strategies:

| Strategy | Description |
|----------|------------|
| **RollingUpdate** | Updates pods gradually, without downtime |
| **OnDelete** | Updates only when old pods are manually deleted |

📌 **Example (RollingUpdate):**  
```yaml
spec:
  updateStrategy:
    type: RollingUpdate
```

📌 **Example (OnDelete):**  
```yaml
spec:
  updateStrategy:
    type: OnDelete
```

### **6️⃣ What happens if a DaemonSet is deleted?**
💡 **Answer:**  
When a DaemonSet is deleted, all **DaemonSet-managed pods** are also deleted. However, if the pods were manually created or are managed by another controller, they might not be deleted.

📌 **Delete a DaemonSet:**  
```bash
kubectl delete daemonset fluentd -n kube-system
```

---

# **🔹 Scenario-Based Questions**
### **7️⃣ Scenario: Your DaemonSet is not running on some nodes. What could be the reasons?**
💡 **Possible Causes & Solutions:**  
✅ **Taints & Tolerations Issue:**  
If the nodes are tainted and your DaemonSet does not have the corresponding **toleration**, the pods will not schedule.

✅ **NodeSelector or Affinity Issues:**  
If your DaemonSet **uses nodeSelector or nodeAffinity**, ensure that the nodes have matching labels.

✅ **Resource Limits Issue:**  
Check if your nodes have enough CPU & memory available.

✅ **Check Events:**  
```bash
kubectl describe daemonset <daemonset-name>
kubectl get events --sort-by=.metadata.creationTimestamp
```

---

### **8️⃣ Scenario: A new node was added, but the DaemonSet pod is not running on it. How would you troubleshoot?**
💡 **Troubleshooting Steps:**
1. **Check if the node is Ready:**  
   ```bash
   kubectl get nodes
   ```
   If the node is `NotReady`, check logs:  
   ```bash
   kubectl describe node <node-name>
   ```

2. **Check if the DaemonSet has the correct scheduling rules:**  
   ```bash
   kubectl get daemonset <daemonset-name> -o yaml
   ```

3. **Check if the node has necessary labels:**  
   ```bash
   kubectl get nodes --show-labels
   ```

4. **Check if the pod is stuck in scheduling:**  
   ```bash
   kubectl get pods -o wide
   ```

5. **Manually schedule a pod for testing:**  
   ```bash
   kubectl run test-pod --image=nginx --restart=Never --overrides='{"spec":{"nodeSelector":{"kubernetes.io/hostname":"<node-name>"}}}'
   ```

---

### **9️⃣ Scenario: Your DaemonSet pod keeps restarting. How do you debug it?**
💡 **Possible Causes & Fixes:**
✅ **Check logs for errors:**  
   ```bash
   kubectl logs -f daemonset/<daemonset-name> -n <namespace>
   ```

✅ **Check pod description for events:**  
   ```bash
   kubectl describe pod <pod-name>
   ```

✅ **Check if there’s an image pull error:**  
   ```bash
   kubectl get pods -o wide
   ```

✅ **If OOMKilled (out of memory), increase limits:**  
   ```yaml
   resources:
     limits:
       memory: "512Mi"
   ```

---

### **🔟 Scenario: How would you update a DaemonSet without causing downtime?**
💡 **Best Practice:** Use **RollingUpdate strategy**  
📌 **Update `fluentd-daemonset.yaml`:**  
```yaml
spec:
  updateStrategy:
    type: RollingUpdate
```

📌 **Apply the update:**  
```bash
kubectl apply -f fluentd-daemonset.yaml
```

📌 **Check rollout status:**  
```bash
kubectl rollout status daemonset fluentd -n kube-system
```

📌 **If something goes wrong, rollback:**  
```bash
kubectl rollout undo daemonset fluentd -n kube-system
```

---

# **🔹 Expert-Level Questions**
### **1️⃣1️⃣ Can a DaemonSet be used for stateful applications?**
💡 **Answer:**  
DaemonSets **can** be used for stateful applications, but they lack **persistent storage guarantees** like StatefulSets.

📌 **If persistent storage is required:**  
```yaml
volumeMounts:
- name: data
  mountPath: /var/lib/app
volumes:
- name: data
  hostPath:
    path: /mnt/data
```

---

### **1️⃣2️⃣ How does a DaemonSet handle rolling updates if a pod crashes during the update?**
💡 **Answer:**  
If a pod **fails to start during a RollingUpdate**, Kubernetes will:

1. **Retry a few times** before marking it as `CrashLoopBackOff`
2. **Stop rolling out new updates** if the failure threshold is reached
3. **Allow rollback** with:
   ```bash
   kubectl rollout undo daemonset <daemonset-name>
   ```

---

### **1️⃣3️⃣ What happens if a node running a DaemonSet pod is deleted?**
💡 **Answer:**  
1. **The pod is removed** because its node no longer exists.  
2. **If a new node is added**, the DaemonSet **automatically schedules a new pod** on it.  

---

# **🔹 Final Thoughts**
These **interview questions** cover **theory, real-world troubleshooting, and advanced Kubernetes scheduling concepts**. Mastering these topics will help you **ace any Kubernetes interview**! 🚀🔥

