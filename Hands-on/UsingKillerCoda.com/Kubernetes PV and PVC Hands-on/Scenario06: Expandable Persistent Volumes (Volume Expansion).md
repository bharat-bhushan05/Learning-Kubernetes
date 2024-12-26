### **Scenario 6: Expandable Persistent Volumes (Volume Expansion)**  

Volume expansion is crucial for scaling storage as application data grows. Kubernetes allows resizing PersistentVolumes without data loss by modifying the PVC. This scenario demonstrates how to enable volume expansion, resize a running PV, and verify the changes.  

---

### **Objective:**  
- Enable dynamic volume expansion for a StorageClass.  
- Expand a PersistentVolumeClaim without recreating the pod.  
- Verify data persistence and pod continuity during expansion.  

---

## **Step 1: Create Expandable StorageClass**  

### **Manifest (expandable-storageclass.yaml):**  
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: expandable-sc
provisioner: kubernetes.io/aws-ebs
allowVolumeExpansion: true
parameters:
  type: gp3  # Supports expansion and high IOPS
reclaimPolicy: Retain
volumeBindingMode: WaitForFirstConsumer
```  

---

### **Explanation of Fields:**  
- **allowVolumeExpansion: true** – Enables PV resizing through PVC updates.  
- **type: gp3** – AWS gp3 provides high performance and scalability.  
- **volumeBindingMode: WaitForFirstConsumer** – Delays PV creation until pod scheduling.  

---

### **Apply StorageClass:**  
```bash
kubectl apply -f expandable-storageclass.yaml
kubectl get storageclass
```  

---

## **Step 2: Create PVC with Expandable StorageClass**  

### **Manifest (expandable-pvc.yaml):**  
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: expandable-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
  storageClassName: expandable-sc
```  

---

### **Apply PVC:**  
```bash
kubectl apply -f expandable-pvc.yaml
kubectl get pvc
```  

---

## **Step 3: Deploy a Pod to Use PVC**  

### **Manifest (expand-pod.yaml):**  
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-expand
spec:
  containers:
    - name: nginx
      image: nginx
      volumeMounts:
        - mountPath: /usr/share/nginx/html
          name: web-storage
  volumes:
    - name: web-storage
      persistentVolumeClaim:
        claimName: expandable-pvc
```  

---

### **Apply Pod:**  
```bash
kubectl apply -f expand-pod.yaml
kubectl get pods
```  

---

## **Step 4: Verify PVC and PV**  

```bash
kubectl get pvc expandable-pvc
kubectl get pv
kubectl describe pvc expandable-pvc
```  
- Note the initial size (5Gi).  

---

## **Step 5: Expand the PVC**  

1. **Edit PVC to Increase Storage Size:**  
```bash
kubectl edit pvc expandable-pvc
```  
- Update the `resources.requests.storage` to `10Gi`.  
```yaml
resources:
  requests:
    storage: 10Gi
```  

2. **Verify Expansion Progress:**  
```bash
kubectl get pvc expandable-pvc
```  
- The PVC status will show `Resizing` or `Bound`.  
```bash
kubectl describe pvc expandable-pvc
```  

---

## **Step 6: Verify Pod and Data Persistence**  

```bash
kubectl exec -it nginx-expand -- df -h
```  
- Check if the storage reflects the new size.  

---

## **Troubleshooting and Checks:**  
- **If Pod Restarts:**  
```bash
kubectl delete pod nginx-expand
kubectl apply -f expand-pod.yaml
```  
- Expansion works seamlessly if the pod uses the volume after resizing.  

- **Check Events if Expansion Fails:**  
```bash
kubectl describe pvc expandable-pvc
kubectl describe pv <pv-name>
```  

---

## **Step 7: Clean Up (Optional)**  
```bash
kubectl delete pod nginx-expand
kubectl delete pvc expandable-pvc
kubectl delete storageclass expandable-sc
```  

---

## **Key Takeaways from This Hands-on:**  
- **allowVolumeExpansion** makes PV scaling straightforward.  
- **gp3** storage (AWS) supports on-the-fly expansion without downtime.  
- **Immediate vs. WaitForFirstConsumer** ensures efficient resource allocation.  

---
