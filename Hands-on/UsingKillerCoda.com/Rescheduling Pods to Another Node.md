## **🔥 Hands-on Lab: Rescheduling Pods to Another Node in KillerCoda**
**KillerCoda Playground URL:**  
[🔗 Kubernetes Playground - KillerCoda](https://killercoda.com/playgrounds/scenario/kubernetes)

---

### **📌 Step 1: Launch the Kubernetes Playground**
1️⃣ Open [KillerCoda’s Kubernetes Playground](https://killercoda.com/playgrounds/scenario/kubernetes).  
2️⃣ Wait for the cluster to initialize. You'll have **two worker nodes** available (`node01` and `node02`).  
3️⃣ Verify the available nodes:
   ```bash
   kubectl get nodes
   ```
   Example output:
   ```
   NAME      STATUS   ROLES    AGE   VERSION
   node01    Ready    <none>   10m   v1.26
   node02    Ready    <none>   10m   v1.26
   ```

---

### **📌 Step 2: Deploy a Pod on `node01`**
1️⃣ Create a **YAML file** for the pod:
   ```bash
   nano my-pod.yaml
   ```
2️⃣ Add the following content to schedule it on `node01`:
   ```yaml
   apiVersion: v1
   kind: Pod
   metadata:
     name: my-pod
   spec:
     nodeSelector:
       kubernetes.io/hostname: node01
     containers:
       - name: nginx-container
         image: nginx
   ```
3️⃣ Save & exit (`CTRL+X`, then `Y`, then `Enter`).  
4️⃣ Apply the pod manifest:
   ```bash
   kubectl apply -f my-pod.yaml
   ```
5️⃣ Check where the pod is running:
   ```bash
   kubectl get pods -o wide
   ```
   Example output:
   ```
   NAME     READY   STATUS    NODE
   my-pod   1/1     Running   node01
   ```

---

### **📌 Step 3: Reschedule the Pod to `node02`**
#### **Approach 1: Manually Delete the Pod**
1️⃣ Delete the pod:
   ```bash
   kubectl delete pod my-pod
   ```
2️⃣ Edit the YAML file to change `nodeSelector` to `node02`:
   ```bash
   nano my-pod.yaml
   ```
3️⃣ Modify the `nodeSelector`:
   ```yaml
     nodeSelector:
       kubernetes.io/hostname: node02
   ```
4️⃣ Save & exit (`CTRL+X`, then `Y`, then `Enter`).  
5️⃣ Reapply the pod:
   ```bash
   kubectl apply -f my-pod.yaml
   ```
6️⃣ Verify that it moved to `node02`:
   ```bash
   kubectl get pods -o wide
   ```
   Output should now show `my-pod` running on `node02`.

---

### **📌 Step 4: Reschedule Pods Using `kubectl drain`**
Instead of manually deleting pods, use `kubectl drain` to **evict all pods** from `node01`.

1️⃣ Cordon `node01` (prevents new pods from scheduling):
   ```bash
   kubectl cordon node01
   ```
2️⃣ Drain `node01` (move existing pods to `node02`):
   ```bash
   kubectl drain node01 --ignore-daemonsets --force
   ```
3️⃣ Check that the pod has been moved:
   ```bash
   kubectl get pods -o wide
   ```
4️⃣ Uncordon `node01` to allow scheduling again:
   ```bash
   kubectl uncordon node01
   ```

---

### **📌 Step 5: Reschedule Pods Using Taints & Tolerations**
If you want to **prevent pods from running on `node01`**, add a **taint**:

1️⃣ Apply a taint to `node01`:
   ```bash
   kubectl taint nodes node01 key=value:NoSchedule
   ```
2️⃣ Check the taint:
   ```bash
   kubectl describe node node01 | grep Taints
   ```
3️⃣ Try scheduling a pod on `node01` (**it won’t work**).  
4️⃣ Remove the taint:
   ```bash
   kubectl taint nodes node01 key=value:NoSchedule-
   ```

---

### **🎯 Lab Complete!**
✅ You successfully rescheduled a pod using **manual deletion, `kubectl drain`, and taints/tolerations**.  
🚀 Now, try deploying a **Deployment** and rescheduling its replicas!  

Would you like more **advanced exercises** on this? 😊
