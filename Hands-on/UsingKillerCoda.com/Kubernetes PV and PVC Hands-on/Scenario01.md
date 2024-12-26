Rreal-world Kubernetes Persistent Volume (PV) and Persistent Volume Claim (PVC) hands-on lab designed for **killercoda.com**. This will simulate scenarios Kubernetes admins often face, including node-specific storage, pod rescheduling, and dynamic PVC resizing.

---

## **Real-World Scenario:**
You're a Kubernetes admin managing a stateful application that stores uploaded files persistently. You need to:  
1. Bind storage to a specific node.  
2. Ensure data persists even if the pod restarts or moves to another node.  
3. Dynamically resize the storage when more space is required.  

---

## **Objective:**  
- Static and dynamic PV/PVC provisioning.  
- Node affinity to bind PVs to specific nodes.  
- Reschedule pods and verify persistent data.  
- Resize PVC dynamically.  

---

## **Prerequisites on Killercoda:**  
1. Choose the **Kubernetes playground** on Killercoda.  
2. Ensure you have at least 2 worker nodes and 1 master node.  
3. The node has `/mnt/k8s-data` created.  

---

## **Step 1: Create Node-Specific PV**  

### 1. **Get Node Names:**  
```bash
kubectl get nodes
```  
#### Example Output:  
```
NAME          STATUS   ROLES    AGE   VERSION
worker-1      Ready    <none>   5d    v1.28.0
worker-2      Ready    <none>   5d    v1.28.0
```  
Select one (e.g., `worker-1`).  

---

### 2. **Create PV (node-specific):**  
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: node-specific-pv
spec:
  capacity:
    storage: 5Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: manual
  local:
    path: /mnt/k8s-data  # Make sure this path exists on the node
  nodeAffinity:
    required:
      nodeSelectorTerms:
        - matchExpressions:
            - key: kubernetes.io/hostname
              operator: In
              values:
                - worker-1  # Use actual node name
```  
```bash
kubectl apply -f pv.yaml
```  

---

### 3. **Verify PV:**  
```bash
kubectl get pv
```  

---

## **Step 2: Create PVC and Use in a Pod**  

### 1. **Create PVC (to bind to PV):**  
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: app-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
  storageClassName: manual
```  
```bash
kubectl apply -f pvc.yaml
```  

---

### 2. **Deploy a Pod Using PVC:**  
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
spec:
  containers:
    - name: nginx
      image: nginx
      volumeMounts:
        - mountPath: /usr/share/nginx/html
          name: data
  volumes:
    - name: data
      persistentVolumeClaim:
        claimName: app-pvc
```  
```bash
kubectl apply -f pod.yaml
```  

---

### 3. **Verify Pod and PVC Binding:**  
```bash
kubectl get pods
kubectl get pvc
kubectl describe pvc app-pvc
```  
- **PVC Status:** `Bound`  
- **Pod Status:** `Running`  

---

## **Step 3: Write Data and Test Persistence**  

1. **Write to PVC:**  
```bash
kubectl exec -it nginx-pod -- /bin/bash
```  
Inside pod:  
```bash
echo "Persistent Storage Test" > /usr/share/nginx/html/index.html
exit
```  

---

2. **Restart Pod (simulate pod failure):**  
```bash
kubectl delete pod nginx-pod
kubectl apply -f pod.yaml
```  

3. **Check if Data Persists:**  
```bash
kubectl exec -it nginx-pod -- cat /usr/share/nginx/html/index.html
```  
- **Expected Output:**  
```
Persistent Storage Test
```  

---

## **Step 4: Simulate Node Failure (Advanced)**  

1. **Drain Node (simulate node failure):**  
```bash
kubectl drain worker-1 --ignore-daemonsets
```  

2. **Verify Pod is Rescheduled to Another Node:**  
```bash
kubectl get pods -o wide
```  
- **Note:** Since PV is node-specific, pod may remain in `Pending` until node is back.  

3. **Uncordon Node (recover node):**  
```bash
kubectl uncordon worker-1
```  

---

## **Step 5: Resize PVC (Dynamic Expansion)**  

1. **Edit PVC (resize storage):**  
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: app-pvc
spec:
  resources:
    requests:
      storage: 10Gi  # Resize to 10Gi
```  
```bash
kubectl apply -f pvc.yaml
```  

2. **Verify Resize:**  
```bash
kubectl get pvc
kubectl describe pvc app-pvc
```  

---

## **Step 6: Test PVC Expansion in Pod**  

1. Restart pod to pick up expanded PVC:  
```bash
kubectl delete pod nginx-pod
kubectl apply -f pod.yaml
```  

---

## **Step 7: Clean Up Resources**  

```bash
kubectl delete pod nginx-pod
kubectl delete pvc app-pvc
kubectl delete pv node-specific-pv
```  

---

## **Key Learnings from This Hands-on:**  
- **Node Affinity with PVs:** Bind volumes to specific nodes.  
- **Pod Persistence:** Test how pods retain data across restarts.  
- **Dynamic PVC Resizing:** Expand PVC storage dynamically without downtime.  
- **Simulating Node Failures:** Handle real-world pod scheduling issues due to node-specific PVs.  

---  
This exercise simulates multiple admin-level scenarios, enhancing hands-on skills crucial for Kubernetes certifications (CKA) and real-world troubleshooting.
