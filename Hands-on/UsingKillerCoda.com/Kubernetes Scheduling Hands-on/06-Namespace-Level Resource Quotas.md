### **Namespace-Level Resource Quotas – Prevent Resource Exhaustion (Real-World CKA Hands-On)**  



### **Concept Overview**  
**ResourceQuota** in Kubernetes:  
- Sets a **hard limit** on total CPU/memory consumption within a namespace.  
- Ensures **fair distribution** of resources across teams or services.  
- Prevents one team from monopolizing cluster resources.  





### **Real-World Scenario**  
Your Kubernetes cluster hosts multiple teams. The **default namespace** risks resource exhaustion as teams deploy services without constraints.  
🔹 Solution: Apply a **ResourceQuota** to restrict CPU and memory usage.  





## **Hands-On 8: Apply Resource Quota for a Namespace**  



### **Step 1: Create ResourceQuota for Default Namespace**  

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: default-namespace-quota
  namespace: default
spec:
  hard:
    requests.cpu: "2"        # Max total requested CPU: 2 cores
    requests.memory: 4Gi     # Max requested memory: 4Gi
    limits.cpu: "4"          # Max limit across all pods: 4 cores
    limits.memory: 8Gi       # Max memory: 8Gi
    pods: "10"               # Max pods allowed: 10
```





### **Explanation**  
- **Total Pod Limit:** Maximum of 10 pods in the `default` namespace.  
- **CPU Cap:**  
   - Pods can request up to **2 cores** collectively.  
   - Maximum limit: **4 cores**.  
- **Memory Cap:**  
   - Total requested memory can't exceed **4Gi**.  
   - Limit: **8Gi**.  





### **Step 2: Apply the ResourceQuota**  

```bash
kubectl apply -f quota.yaml
kubectl get resourcequota -n default
```
- Verify quota is active.  

```bash
kubectl describe resourcequota default-namespace-quota -n default
```
- View detailed breakdown.  





### **Step 3: Test – Deploy Multiple Pods**  

**Create a Pod Exceeding the Quota:**  

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: quota-test-pod
spec:
  containers:
  - name: nginx
    image: nginx
    resources:
      requests:
        cpu: "1.5"
        memory: "2Gi"
      limits:
        cpu: "2"
        memory: "4Gi"
```



```bash
kubectl apply -f quota-test-pod.yaml
```

- **Deploying 2 such pods will pass.**  
- The 3rd pod will fail due to exceeding the **CPU or memory request quota**.  





### **Challenge – Test Your Understanding**  
1. **Create a Quota** for a new namespace called `dev-team` with:  
   - Max 5 pods.  
   - Total CPU limit: 2 cores.  
   - Memory limit: 6Gi.  

2. **Deploy pods** to `dev-team` to trigger the quota.  





### **Advanced Task – Dynamic Scaling Based on Quota**  
- Implement a Horizontal Pod Autoscaler (HPA) that respects the quota but scales within limits.  

Let me know when you’re ready for the next challenge!
