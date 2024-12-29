### **Resource Requests and Limits – Fine-Tuning Pod Resource Management (Real-World CKA Hands-On)**  

---

### **Concept Overview**  
In Kubernetes, **resource requests and limits** ensure:  
- **Efficient resource allocation** (CPU/memory).  
- **Fair sharing of cluster resources**.  
- **Avoidance of over-provisioning or under-provisioning**.  

**Key Concepts:**  
- **Requests** – Minimum guaranteed resources for a container.  
- **Limits** – Maximum resources a container can consume.  
- If a pod exceeds its limit, it may be **throttled (CPU)** or **killed (memory)**.  

---

---

### **Real-World Scenario**  
A critical service (`payment-service`) experiences memory spikes during peak traffic. You need to:  
1. Guarantee **500m (0.5 CPU) and 256Mi memory** at all times.  
2. Cap usage at **1 CPU and 512Mi memory** to prevent cluster instability.  

---

---

## **Hands-On 7: Implement Resource Requests and Limits**  

---

### **Step 1: Create Resource-Limited Pod**  

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: payment-service
  labels:
    app: payment
spec:
  containers:
  - name: payment
    image: nginx
    resources:
      requests:
        cpu: "500m"
        memory: "256Mi"
      limits:
        cpu: "1"
        memory: "512Mi"
```

---

---

### **Explanation**  
- **Request:** Guarantees **0.5 CPU** and **256Mi memory**.  
- **Limit:** Caps at **1 CPU** and **512Mi memory**.  

If the pod tries to exceed 512Mi of memory, it will **terminate with an OOMKilled status**.  

---

---

### **Step 2: Apply and Verify**  

```bash
kubectl apply -f payment-pod.yaml
kubectl describe pod payment-service
```
- Check the **resource section** in the pod description.  

---

---

### **Step 3: Simulate Memory Spike (Stress Test)**  

```bash
kubectl exec -it payment-service -- sh
```
Inside the pod:  
```bash
stress --vm 1 --vm-bytes 600M --timeout 30s
```
- **Outcome:** The pod will terminate due to exceeding its memory limit.  

```bash
kubectl get pods
```
- Observe the **OOMKilled** status.  

---

---

### **Challenge – Fix OOMKilled Issue**  
1. **Edit the Pod to Increase Memory Limit**:  
   ```bash
   kubectl edit pod payment-service
   ```  
   - Update:  
     ```yaml
     limits:
       memory: "1Gi"
     ```  
2. **Reapply and Re-Test Memory Spike.**  

---

---

### **Advanced Task – Enforce Default Resource Quotas**  
- Apply a **ResourceQuota** to the `default` namespace to limit total resource consumption by all pods.  

Let me know when you're ready to proceed!
