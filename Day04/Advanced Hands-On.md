# Advanced Hands-On: Scenario-Based Questions and Troubleshooting for Kubernetes Deployments

In this post, we will delve deeper into Deployments by addressing scenario-based questions often asked in interviews and providing detailed troubleshooting steps.

---

## **1. Scenario-Based Hands-On Exercises**

### **Scenario 1: Updating an Application with Minimal Downtime**
#### **Problem:**
You need to update an application to a new version without downtime. Ensure that at least one Pod is always running during the update.

#### **Solution:**
1. **Check the Current Deployment Configuration:**
   ```bash
   kubectl get deployment my-app-deployment -o yaml
   ```
   Ensure the `strategy` field is set to `RollingUpdate`.

2. **Update the Image:**
   ```bash
   kubectl set image deployment/my-app-deployment my-app-container=nginx:1.23
   ```

3. **Monitor the Update Progress:**
   ```bash
   kubectl rollout status deployment my-app-deployment
   ```

4. **Verify the Pods:**
   ```bash
   kubectl get pods -l app=my-app
   ```
   Ensure the new Pods are running the updated version.

---

### **Scenario 2: Roll Back to a Specific Revision**
#### **Problem:**
An update broke the application, and you need to roll back to a specific stable revision.

#### **Solution:**
1. **List the Revision History:**
   ```bash
   kubectl rollout history deployment my-app-deployment
   ```

2. **Roll Back to a Specific Revision:**
   ```bash
   kubectl rollout undo deployment my-app-deployment --to-revision=2
   ```

3. **Verify the Rollback:**
   ```bash
   kubectl get pods
   ```
   Ensure the Pods are running the stable version.

---

### **Scenario 3: Scale Based on Traffic**
#### **Problem:**
Your application experiences a traffic surge, and you need to scale it quickly.

#### **Solution:**
1. **Manually Scale the Deployment:**
   ```bash
   kubectl scale deployment my-app-deployment --replicas=10
   ```

2. **Set Up Autoscaling (Optional):**
   ```bash
   kubectl autoscale deployment my-app-deployment --min=3 --max=15 --cpu-percent=80
   ```

3. **Monitor Scaling Activity:**
   ```bash
   kubectl get hpa
   ```

---

## **2. Troubleshooting Steps**

### **Issue 1: Pods Stuck in `Pending` State**
#### **Diagnosis:**
- Check if there are insufficient resources:
  ```bash
  kubectl describe pod <pod-name>
  ```

#### **Resolution:**
1. Scale down the Deployment or add more nodes to the cluster.
2. Check for node taints preventing scheduling:
   ```bash
   kubectl describe node <node-name>
   ```

---

### **Issue 2: Deployment Update Fails**
#### **Diagnosis:**
- Check the rollout status:
  ```bash
  kubectl rollout status deployment my-app-deployment
  ```

- Inspect events for errors:
  ```bash
  kubectl describe deployment my-app-deployment
  ```

#### **Resolution:**
1. Fix the faulty image or configuration causing the issue.
2. Roll back to the previous version:
   ```bash
   kubectl rollout undo deployment my-app-deployment
   ```

---

### **Issue 3: Pods CrashLoopBackOff**
#### **Diagnosis:**
- View Pod logs:
  ```bash
  kubectl logs <pod-name>
  ```

- Check the Pod's events:
  ```bash
  kubectl describe pod <pod-name>
  ```

#### **Resolution:**
1. Identify the root cause from the logs (e.g., missing config, incorrect image).
2. Apply a fix to the Deployment and roll out the changes.
   ```bash
   kubectl apply -f deployment.yaml
   ```

---

### **Issue 4: High Latency Due to Insufficient Replicas**
#### **Diagnosis:**
- Monitor CPU and memory usage:
  ```bash
  kubectl top pod
  ```

#### **Resolution:**
1. Increase the replica count:
   ```bash
   kubectl scale deployment my-app-deployment --replicas=10
   ```
2. Configure Horizontal Pod Autoscaler for dynamic scaling.

---

These exercises and troubleshooting steps provide practical experience and solutions to common challenges faced with Kubernetes Deployments.
