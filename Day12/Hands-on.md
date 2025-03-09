A **hands-on lab** to simulate and troubleshoot common **DaemonSet issues** in a Kubernetes cluster. This will help you understand real-world scenarios and how to fix them effectively.  

---

# **🔥 DaemonSet Troubleshooting Hands-on Lab**
### **🛠️ Lab Setup**
We will:
✅ Create a **DaemonSet**  
✅ Simulate **various issues**  
✅ Debug and troubleshoot  

---

## **📝 Step 1: Create a Kubernetes Cluster**
If you don't already have a cluster, start **Minikube** or use any existing cluster.  
```bash
minikube start
```
Or use **kind (Kubernetes in Docker)**:  
```bash
kind create cluster --name daemonset-lab
```

---

## **📝 Step 2: Create a DaemonSet**
Save this YAML as `fluentd-daemonset.yaml`:  
```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: fluentd
  namespace: kube-system
  labels:
    app: fluentd
spec:
  selector:
    matchLabels:
      name: fluentd
  template:
    metadata:
      labels:
        name: fluentd
    spec:
      tolerations:
      - key: "node-role.kubernetes.io/master"
        operator: "Exists"
        effect: "NoSchedule"
      containers:
      - name: fluentd
        image: fluentd:latest
        resources:
          limits:
            memory: "256Mi"
            cpu: "100m"
          requests:
            memory: "128Mi"
            cpu: "50m"
        volumeMounts:
        - name: varlog
          mountPath: /var/log
      volumes:
      - name: varlog
        hostPath:
          path: /var/log
```
Apply the DaemonSet:
```bash
kubectl apply -f fluentd-daemonset.yaml
```

Check if the DaemonSet is running:  
```bash
kubectl get daemonsets -n kube-system
kubectl get pods -o wide -n kube-system
```

---

# **🛠️ Step 3: Simulate & Troubleshoot Common Issues**
Now, we’ll simulate **real-world errors** and debug them.

---

## **🔥 Scenario 1: DaemonSet Pods Not Scheduled on Nodes**
### **❌ Problem: DaemonSet pods are pending**
Check if any pod is stuck in `Pending`:
```bash
kubectl get pods -n kube-system -o wide
```
If the output shows `STATUS: Pending`, find out why:
```bash
kubectl describe pod <pod-name> -n kube-system
```
### **🔎 Fix:**
1️⃣ Check if nodes are labeled correctly:
```bash
kubectl get nodes --show-labels
```
If missing, add the required label:
```bash
kubectl label node <node-name> app=fluentd
```
2️⃣ Check **taints**:
```bash
kubectl describe node <node-name> | grep -i taint
```
If the node is **tainted**, add a toleration in the DaemonSet YAML.

---

## **🔥 Scenario 2: Pods in CrashLoopBackOff**
### **❌ Problem: Fluentd pods keep restarting**
```bash
kubectl get pods -n kube-system
```
If pods are in `CrashLoopBackOff`, check logs:
```bash
kubectl logs -n kube-system <pod-name>
```
### **🔎 Fix:**
1️⃣ If memory is insufficient:
```yaml
resources:
  limits:
    memory: "512Mi"
    cpu: "200m"
  requests:
    memory: "256Mi"
    cpu: "100m"
```
Apply changes:
```bash
kubectl apply -f fluentd-daemonset.yaml
```

2️⃣ If the container crashes due to missing config:
```bash
kubectl describe pod <pod-name> -n kube-system
```
Fix any incorrect environment variables or mounts.

---

## **🔥 Scenario 3: ImagePullBackOff**
### **❌ Problem: Incorrect container image**
Check the pod status:
```bash
kubectl get pods -n kube-system
```
If the `STATUS` is `ImagePullBackOff`:
```bash
kubectl describe pod <pod-name> -n kube-system
```
### **🔎 Fix:**
1️⃣ Update the **correct image version**:
```yaml
containers:
- name: fluentd
  image: fluentd:v1.14
```
Apply the fix:
```bash
kubectl apply -f fluentd-daemonset.yaml
```
2️⃣ If using a **private registry**, add a secret:
```yaml
imagePullSecrets:
- name: my-registry-secret
```

---

## **🔥 Scenario 4: Some Nodes Do Not Have DaemonSet Pods**
### **❌ Problem: Pods missing on specific nodes**
Check on which nodes DaemonSet pods are running:
```bash
kubectl get pods -o wide -n kube-system
```
If a node is missing a pod:
```bash
kubectl describe node <node-name>
```
### **🔎 Fix:**
1️⃣ If nodes are missing required labels, add them:
```bash
kubectl label node <node-name> role=worker
```
2️⃣ If a node is **tainted**, add toleration:
```yaml
tolerations:
- key: "node-role.kubernetes.io/master"
  operator: "Exists"
  effect: "NoSchedule"
```

---

## **🔥 Scenario 5: DaemonSet Not Updating**
### **❌ Problem: Pods do not update after applying changes**
If you updated the DaemonSet but pods still run the old version:
```bash
kubectl rollout status daemonset fluentd -n kube-system
```
### **🔎 Fix:**
1️⃣ **Use RollingUpdate strategy instead of OnDelete**:
```yaml
updateStrategy:
  type: RollingUpdate
```
Apply changes:
```bash
kubectl apply -f fluentd-daemonset.yaml
```
2️⃣ **Manually delete old pods**:
```bash
kubectl delete pod --selector=name=fluentd -n kube-system
```

---

## **🔥 Scenario 6: Debugging Logs & Events**
Check DaemonSet **events**:
```bash
kubectl get events -n kube-system | grep fluentd
```
Check **detailed pod logs**:
```bash
kubectl logs -f daemonset/fluentd -n kube-system
```

---

# **🎯 Conclusion**
🚀 You have successfully simulated and **troubleshooted** various **DaemonSet issues** in Kubernetes!  
This hands-on lab prepares you for **real-world debugging** and **Kubernetes interviews**. 🔥  
