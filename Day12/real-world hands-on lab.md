A **real-world hands-on lab** for DaemonSets in Kubernetes. This lab will cover:  

✅ **Deploying a DaemonSet for Log Collection** (Fluentd)  
✅ **Running a DaemonSet for Node Monitoring** (Prometheus Node Exporter)  
✅ **Exploring All Possible DaemonSet Parameters**  
✅ **Configuring Node Affinity, Tolerations, and Custom Scheduling**  
✅ **Handling Updates and Deletions**  

---

# **🔹 Lab Prerequisites**
Before starting, make sure you have:

1️⃣ **A Kubernetes cluster** (Minikube, k3s, EKS, GKE, AKS, etc.)  
2️⃣ **kubectl CLI installed**  
3️⃣ **YAML editing tool** (VS Code, nano, vim)  

📌 **Verify cluster is running:**  
```bash
kubectl get nodes
```

📌 **Verify kubectl is installed:**  
```bash
kubectl version --short
```

---

# **🔹 Step 1: Deploy a DaemonSet for Log Collection**
Let's deploy **Fluentd**, a popular log collector, as a **DaemonSet**.

📌 **Create `fluentd-daemonset.yaml`**  
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
        effect: NoSchedule
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
          path: /var/log
```

📌 **Deploy the DaemonSet:**  
```bash
kubectl apply -f fluentd-daemonset.yaml
```

📌 **Verify the DaemonSet is running:**  
```bash
kubectl get daemonsets -n kube-system
```

📌 **Check running pods:**  
```bash
kubectl get pods -o wide -n kube-system
```

📌 **Describe the DaemonSet:**  
```bash
kubectl describe daemonset fluentd -n kube-system
```

---

# **🔹 Step 2: Deploy a DaemonSet for Node Monitoring**
Now, let's deploy **Prometheus Node Exporter** to monitor Kubernetes nodes.

📌 **Create `node-exporter-daemonset.yaml`**  
```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: node-exporter
  namespace: monitoring
spec:
  selector:
    matchLabels:
      app: node-exporter
  template:
    metadata:
      labels:
        app: node-exporter
    spec:
      containers:
      - name: node-exporter
        image: prom/node-exporter:v1.5.0
        ports:
        - containerPort: 9100
        resources:
          limits:
            cpu: "300m"
            memory: "256Mi"
          requests:
            cpu: "100m"
            memory: "128Mi"
      hostNetwork: true  # Uses node's network
      tolerations:
      - key: node-role.kubernetes.io/master
        effect: NoSchedule
```

📌 **Deploy the DaemonSet:**  
```bash
kubectl apply -f node-exporter-daemonset.yaml
```

📌 **Verify the deployment:**  
```bash
kubectl get daemonset -n monitoring
```

📌 **Check running pods:**  
```bash
kubectl get pods -n monitoring -o wide
```

📌 **Access Node Exporter Metrics:**  
```bash
kubectl port-forward daemonset/node-exporter 9100:9100 -n monitoring
```
Now, open **http://localhost:9100/metrics** in your browser.

---

# **🔹 Step 3: Run DaemonSet on Specific Nodes Only**
By default, a DaemonSet runs on **all nodes**, but we can **target specific nodes**.

📌 **Label a node:**  
```bash
kubectl label nodes <node-name> custom-label=log-collector
```

📌 **Modify Fluentd DaemonSet to target this node (`fluentd-daemonset.yaml`):**  
```yaml
spec:
  template:
    spec:
      nodeSelector:
        custom-label: log-collector
```

📌 **Apply the changes:**  
```bash
kubectl apply -f fluentd-daemonset.yaml
```

📌 **Check where the pods are running:**  
```bash
kubectl get pods -o wide
```

---

# **🔹 Step 4: Update DaemonSet**
DaemonSets support **rolling updates** and **on-delete** strategies.

📌 **Modify Fluentd to use a new image:**  
```yaml
spec:
  updateStrategy:
    type: RollingUpdate
  template:
    spec:
      containers:
      - name: fluentd
        image: fluent/fluentd:v1.15  # Updated version
```

📌 **Apply the update:**  
```bash
kubectl apply -f fluentd-daemonset.yaml
```

📌 **Check rollout status:**  
```bash
kubectl rollout status daemonset fluentd -n kube-system
```

---

# **🔹 Step 5: Remove DaemonSet**
📌 **Delete Fluentd DaemonSet:**  
```bash
kubectl delete daemonset fluentd -n kube-system
```

📌 **Delete Node Exporter DaemonSet:**  
```bash
kubectl delete daemonset node-exporter -n monitoring
```

---

# **🔹 All Possible Parameters in a DaemonSet**
| Parameter | Description |
|-----------|------------|
| `apiVersion: apps/v1` | API version for DaemonSet |
| `kind: DaemonSet` | Specifies it's a DaemonSet |
| `metadata` | Name, namespace, labels |
| `spec.selector` | Defines how to match pods |
| `spec.template` | Describes pod structure |
| `spec.updateStrategy.type` | `RollingUpdate` or `OnDelete` |
| `spec.template.spec.nodeSelector` | Assign pods to specific nodes |
| `spec.template.spec.tolerations` | Allows running on tainted nodes |
| `spec.template.spec.affinity` | Advanced node scheduling |
| `spec.template.spec.hostNetwork` | Uses the node’s network |

---

# **🔹 Conclusion**
✅ **You deployed DaemonSets for logging and monitoring.**  
✅ **You targeted specific nodes for DaemonSet scheduling.**  
✅ **You learned how to update and delete DaemonSets.**  
