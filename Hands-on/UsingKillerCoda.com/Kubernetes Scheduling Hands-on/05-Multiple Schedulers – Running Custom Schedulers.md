### **Multiple Schedulers – Running Custom Schedulers (Real-World CKA Hands-On)**  

 

### **Concept Overview**  
In Kubernetes, **multiple schedulers** allow for custom scheduling logic. While the default scheduler handles most pods, a custom scheduler can:  
- **Prioritize specific workloads**.  
- **Handle specialized constraints (e.g., GPU scheduling)**.  
- **Optimize for latency, cost, or resource usage**.  

 

 

### **Real-World Scenario**  
You need to deploy a **custom scheduler** alongside the default scheduler to handle specific pods that require custom logic (e.g., pods preferring nodes with large memory).  

 

 

## **Hands-On 6: Deploy and Use a Custom Scheduler**  

 

### **Step 1: Deploy Custom Scheduler (Based on Kube-Scheduler)**  

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: custom-scheduler
  namespace: kube-system
 
apiVersion: apps/v1
kind: Deployment
metadata:
  name: custom-scheduler
  namespace: kube-system
spec:
  replicas: 1
  selector:
    matchLabels:
      component: custom-scheduler
  template:
    metadata:
      labels:
        component: custom-scheduler
    spec:
      serviceAccountName: custom-scheduler
      containers:
      - name: kube-scheduler
        image: k8s.gcr.io/kube-scheduler:v1.28.0
        command:
        - /usr/local/bin/kube-scheduler
        - --scheduler-name=custom-scheduler
        - --leader-elect=false
```

 

 

### **Explanation**  
- **Custom Scheduler** deployed as a pod under `kube-system`.  
- **`--scheduler-name=custom-scheduler`** registers a new scheduler.  
- **`--leader-elect=false`** avoids leader election conflicts with the default scheduler.  

 

 

### **Step 2: Apply and Verify**  

```bash
kubectl apply -f custom-scheduler.yaml
kubectl get pods -n kube-system | grep scheduler
```
- Ensure both the **default** and **custom schedulers** are running.  

```bash
kubectl get endpoints kube-scheduler -n kube-system
```
- Confirm the new scheduler has an endpoint.  

 

 

### **Step 3: Schedule Pods Using the Custom Scheduler**  

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-custom
spec:
  schedulerName: custom-scheduler
  containers:
  - name: nginx
    image: nginx
```

 

 

### **Explanation**  
- **`schedulerName: custom-scheduler`** forces the pod to use the **custom scheduler**.  
- The pod will **only be scheduled if the custom scheduler is active**.  

 

 

### **Step 4: Apply and Verify**  

```bash
kubectl apply -f nginx-custom.yaml
kubectl get pods -o wide
```
- If the custom scheduler is down, the pod will **stay in the pending state**.  

 

 

### **Challenge – Test Scheduler Behavior**  
1. **Stop the Custom Scheduler**:  
   ```bash
   kubectl scale deployment custom-scheduler -n kube-system --replicas=0
   ```  
2. **Observe Pod Behavior:**  
   ```bash
   kubectl get pods -o wide
   ```  
   - The pod will remain pending.  

3. **Restart the Scheduler and Watch the Pod Get Scheduled:**  
   ```bash
   kubectl scale deployment custom-scheduler -n kube-system --replicas=1
   ```  

 

 

### **Advanced Task – Add Priority to the Custom Scheduler**  
- Modify the custom scheduler to **prioritize nodes** with labels like `high-memory=true`.  
- I can guide you through writing custom scheduling logic if you’re ready.  

Next up: **Resource Requests and Limits – Fine-tune Pod Resource Management**.  
Let me know when you're ready to proceed!
