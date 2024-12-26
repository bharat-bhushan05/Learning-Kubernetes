Hands-on exercise for practicing **Kubernetes Persistent Volumes (PV) and Persistent Volume Claims (PVC)**. This version introduces more variety, including dynamic provisioning, expanding PVC size, and simulating pod failure recovery.  

---

## Objective:  
- Create **Persistent Volumes (PV)** and **Persistent Volume Claims (PVC)**.  
- Use PVC in Pods to persist data.  
- Simulate pod failure to test data persistence.  
- Scale up PVC size dynamically.  

---

## Scenario:  
You are deploying a web application that requires persistent storage to keep uploaded files even if the pod restarts. You'll use PVC to mount storage to the pod and ensure data persists across restarts.  

---

## Hands-on Steps:  

---

### 1. Setup Namespace  

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: storage-lab
```  
```bash
kubectl apply -f namespace.yaml
```  

---

### 2. Create a Persistent Volume (PV)  
This PV uses local storage, simulating a real-world storage scenario.  

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: local-pv
  namespace: storage-lab
spec:
  capacity:
    storage: 2Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: manual
  local:
    path: /mnt/k8s-data  # Ensure this path exists on the node
  nodeAffinity:
    required:
      nodeSelectorTerms:
        - matchExpressions:
            - key: kubernetes.io/hostname
              operator: In
              values:
                - <node-name>  # Replace with your actual node name use #kubectl get nodes
```  
```bash
kubectl apply -f pv.yaml
```  

---

### 3. Create Persistent Volume Claim (PVC)  

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: local-pvc
  namespace: storage-lab
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 2Gi
  storageClassName: manual
```  
```bash
kubectl apply -f pvc.yaml
```  

---

### 4. Deploy a Pod Using PVC  

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
  namespace: storage-lab
spec:
  containers:
    - name: nginx
      image: nginx
      volumeMounts:
        - mountPath: /usr/share/nginx/html
          name: storage-volume
  volumes:
    - name: storage-volume
      persistentVolumeClaim:
        claimName: local-pvc
```  
```bash
kubectl apply -f pod.yaml
```  

---

### 5. Verify Pod and PVC  

```bash
kubectl get pod -n storage-lab
kubectl get pvc -n storage-lab
kubectl get pv
```  

Check if the PVC is **Bound** and the pod is in a **Running** state.  

---

### 6. Write Data to PVC (Test Persistence)  

Access the pod and write a file to the persistent storage:  

```bash
kubectl exec -it nginx-pod -n storage-lab -- /bin/bash
```  

Inside the pod:  
```bash
echo "Welcome to Persistent Storage Test" > /usr/share/nginx/html/index.html
exit
```  

---

### 7. Simulate Pod Failure (Test Persistence)  

Delete the pod:  
```bash
kubectl delete pod nginx-pod -n storage-lab
kubectl apply -f pod.yaml
```  

Check if the file still exists:  
```bash
kubectl exec -it nginx-pod -n storage-lab -- cat /usr/share/nginx/html/index.html
```  
If the file is intact, the storage is persisting correctly.  

---

### 8. Expand PVC Size Dynamically  

1. Edit PVC to increase size (simulate storage growth):  

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: local-pvc
  namespace: storage-lab
spec:
  resources:
    requests:
      storage: 5Gi  # Increase storage size
```  

```bash
kubectl apply -f pvc.yaml
```  

2. Check if PVC size increased:  
```bash
kubectl get pvc -n storage-lab
```  

---

### 9. Simulate Pod Reboot with Stateful Data  

Scale down and up to ensure the PVC remains intact:  

```bash
kubectl delete pod nginx-pod -n storage-lab
kubectl apply -f pod.yaml
```  

Verify the content again:  
```bash
kubectl exec -it nginx-pod -n storage-lab -- cat /usr/share/nginx/html/index.html
```  

---

### 10. Clean Up Resources  

```bash
kubectl delete namespace storage-lab
```  

---

## Key Concepts Demonstrated:  
- **PV and PVC Binding**: Static provisioning using local storage.  
- **Pod Persistence**: Files remain even after pod failure.  
- **Storage Expansion**: Simulated dynamic PVC resizing.  
- **Testing Reboot Scenarios**: Re-deploy pods to verify persistent storage.  

---

### What You Learn:  
- How Kubernetes manages storage with PV/PVC.  
- Real-world scenarios for persistent data handling.  
- Simulating pod failures and testing data persistence.
