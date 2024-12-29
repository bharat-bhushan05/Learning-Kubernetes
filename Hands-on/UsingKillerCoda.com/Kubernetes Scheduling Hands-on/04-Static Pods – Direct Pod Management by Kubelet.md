### **Static Pods – Direct Pod Management by Kubelet (Real-World CKA Hands-On)**  

---

### **Concept Overview**  
**Static Pods** are managed directly by the Kubelet **without the API server**. This makes them useful for:  
- **Bootstrapping critical control-plane components** (like etcd, kube-apiserver).  
- **Ensuring essential services run even if the control plane is down.**  
- **Deployments outside of the Kubernetes scheduler’s control.**  

---

---

### **Real-World Scenario**  
You need to deploy an **Nginx pod** as a static pod on `node01`. This pod should automatically restart if terminated, and it should not be controlled by the API server.  

---

---

## **Hands-On 5: Deploy Static Pod for Critical Service**  

---

### **Step 1: SSH into Node01**  

```bash
ssh node01
```

---

---

### **Step 2: Locate Kubelet Configuration**  

```bash
sudo cat /var/lib/kubelet/config.yaml | grep staticPodPath
```
- **Look for `staticPodPath`**. This is the directory where static pod manifests are stored.  
- If the path is missing, create one manually:  

```bash
sudo mkdir -p /etc/kubernetes/manifests
sudo vi /var/lib/kubelet/config.yaml
```
- **Add this to the file (if needed):**  
   ```yaml
   staticPodPath: /etc/kubernetes/manifests
   ```

---

---

### **Step 3: Create Static Pod Manifest (Nginx)**  

```bash
sudo vi /etc/kubernetes/manifests/nginx-static.yaml
```

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-static
spec:
  containers:
  - name: nginx
    image: nginx
    ports:
    - containerPort: 80
```

---

---

### **Step 4: Kubelet Auto-Starts Static Pod**  

- As soon as the manifest is saved, the Kubelet will start the pod.  

```bash
kubectl get pods -A | grep nginx
```
- The pod will show up under `kube-system` or `default`.  

---

---

### **Step 5: Verify and Manage**  

```bash
kubectl describe pod nginx-static
```
- **Even if deleted,** the pod will **restart immediately**.  

```bash
kubectl delete pod nginx-static
```
- **Kubelet ensures its recreation**.  

---

---

### **Challenge – Modify Static Pod Live**  
1. **Modify the Running Static Pod:**  
   ```bash
   sudo vi /etc/kubernetes/manifests/nginx-static.yaml
   ```  
   - **Add a new label or environment variable:**  
     ```yaml
     metadata:
       labels:
         role: static
     ```  
   - **Save the file.**  
2. **Check if the Pod Restarts with New Config:**  
   ```bash
   kubectl get pods -o wide
   kubectl describe pod nginx-static
   ```  

---

---

## **Advanced Task – Deploy Static Pod for Kube-Proxy**  
- Deploy a static pod version of `kube-proxy` to ensure networking runs even if the API server crashes.  

---  

Next up: **Multiple Schedulers – Run Custom Schedulers Alongside the Default One.**   
Let me know when you're ready to dive deeper!
