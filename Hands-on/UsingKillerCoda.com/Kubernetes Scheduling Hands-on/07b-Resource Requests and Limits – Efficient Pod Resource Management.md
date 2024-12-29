### **Resource Requests and Limits – Efficient Pod Resource Management (Real-World CKA Hands-On)**  



### **Concept Overview**  
Resource requests and limits ensure that **pods don’t overconsume CPU/memory**, protecting cluster stability.  
- **Requests:** Minimum resources a pod needs to start.  
- **Limits:** Maximum resources a pod can use.  
- Pods that exceed limits may be **throttled (CPU)** or **killed (memory)**.  





### **Real-World Scenario**  
🔹 **Requirement:**  
- Deploy a pod that **requires 200m (0.2 CPU cores)** and **500Mi of memory**.  
- Limit the pod to **500m (0.5 CPU cores)** and **1Gi memory**.  
- Prevent pods from consuming excessive resources.  





## **Hands-On 12: Set Resource Requests and Limits for Pods**  



### **Step 1: Create Pod with Resource Specifications**  

**YAML Definition:**  
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: resource-pod
spec:
  containers:
  - name: web
    image: nginx
    resources:
      requests:
        memory: "500Mi"
        cpu: "200m"
      limits:
        memory: "1Gi"
        cpu: "500m"
```



```bash
kubectl apply -f resource-pod.yaml
kubectl describe pod resource-pod
kubectl top pod resource-pod
```
- **Explanation:**  
  - Pod **requests 200m CPU and 500Mi memory** at startup.  
  - If the pod exceeds **500m CPU or 1Gi memory**, Kubernetes **throttles CPU or kills the pod (OOM)**.  





### **Step 2: Test Pod Behavior**  

1. Simulate **high CPU usage** inside the pod:  
```bash
kubectl exec -it resource-pod -- stress --cpu 2
```
- The pod will **hit the 500m CPU limit** and be **throttled**.  



2. Simulate **memory overload**:  
```bash
kubectl exec -it resource-pod -- stress --vm 1 --vm-bytes 2G
```
- Pod will be **terminated** due to exceeding the 1Gi memory limit.  
```bash
kubectl describe pod resource-pod
```
- Look for **OOMKilled** in the pod status.  





### **Step 3: Adjust Limits to Prevent OOMKill**  

- Increase the pod's memory limit to **2Gi**:  
```yaml
resources:
  limits:
    memory: "2Gi"
    cpu: "500m"
```
```bash
kubectl apply -f resource-pod.yaml
```
- Pod now **accommodates higher memory loads** without crashing.  





### **Explanation (Why It Works):**  
- **Requests guarantee** minimum pod resources to prevent starvation.  
- **Limits** prevent resource hogging by rogue pods, ensuring **fair resource sharing** across the cluster.  





### **Advanced Task – Burstable vs. Guaranteed Pods**  
1. Deploy two pods:  
   - Pod A: **Request 500m CPU, limit 1 CPU** (Burstable).  
   - Pod B: **Request 1 CPU, limit 1 CPU** (Guaranteed).  
2. Observe **scheduling priority**. Guaranteed pods have **higher QoS** during node pressure.  
```bash
kubectl describe pod <pod-name>
```
- Check the **QoS class** in the description (`Burstable` or `Guaranteed`).  





### **Challenge – Test Your Understanding**  
1. Deploy a pod that:  
   - Requests **1 CPU and 2Gi memory**.  
   - Limits **2 CPUs and 4Gi memory**.  
2. Stress the pod to **trigger throttling and memory eviction**.  
3. **Monitor pod restarts** using:  
```bash
kubectl get pods -w
```  
4. Experiment by **removing resource limits** and observe pod behavior.  



Let me know when you're ready for **DaemonSets Hands-On**!
