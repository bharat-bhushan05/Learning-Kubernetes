## **Scenario 2: Dynamic Provisioning Using StorageClasses**  
Imagine you need to deploy applications with storage that automatically provisions based on demand, without manually creating PersistentVolumes. This is useful for cloud environments (AWS, GCP, Azure) or local clusters with dynamic storage backends like NFS or HostPath provisioners.

---

### **Objective:**  
- Create and use a `StorageClass` for dynamic PV provisioning.  
- Deploy pods that automatically trigger PV creation.  
- Explore reclaim policies, volume expansion, and access modes.

---

## **Step 1: Create a Dynamic StorageClass**  

### **Manifest (storageclass.yaml):**  
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: dynamic-storage
provisioner: kubernetes.io/no-provisioner  # Use 'no-provisioner' for local storage (manual)
reclaimPolicy: Retain  # Options: Delete, Retain, Recycle (Recycle is deprecated)
volumeBindingMode: WaitForFirstConsumer  # Options: Immediate, WaitForFirstConsumer
allowVolumeExpansion: true  # Allows PVC resizing
parameters:
  type: gp2  # Optional - Depends on provisioner (AWS, Azure, etc.)
```  

---

### **Explanation of Fields:**  
- **provisioner:**  
  - Determines how PVs are provisioned.  
  - `kubernetes.io/no-provisioner` – For local storage.  
  - `ebs.csi.aws.com` – AWS EBS Provisioner.  
  - `pd.csi.storage.gke.io` – GCP Persistent Disk.  
  - `azure-disk` – Azure Disk Provisioner.  

- **reclaimPolicy:**  
  - `Retain` – Keeps PV after PVC deletion. Manual cleanup required.  
  - `Delete` – Automatically deletes PV when PVC is deleted.  
  - `Recycle` – Wipes data and makes PV available (deprecated).  

- **volumeBindingMode:**  
  - `Immediate` – Binds PVC immediately.  
  - `WaitForFirstConsumer` – Waits until pod scheduling. Useful for multi-zone clusters.  

- **allowVolumeExpansion:**  
  - Enables PVC resizing dynamically.  

---

### **Apply the StorageClass:**  
```bash
kubectl apply -f storageclass.yaml
kubectl get storageclass
```  

---

## **Step 2: Create PVC Using StorageClass**  

### **Manifest (pvc-dynamic.yaml):**  
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: dynamic-pvc
spec:
  accessModes:
    - ReadWriteOnce  # Options: ReadWriteMany, ReadOnlyMany
  resources:
    requests:
      storage: 10Gi
  storageClassName: dynamic-storage  # Links to the StorageClass
```  

---

### **Explanation of PVC Fields:**  
- **accessModes:**  
  - `ReadWriteOnce` – Single-node access for reading/writing.  
  - `ReadWriteMany` – Multi-node access (NFS or CephFS).  
  - `ReadOnlyMany` – Multi-node read-only.  

- **resources.requests.storage:**  
  - Requested storage size.  

- **storageClassName:**  
  - Matches the created StorageClass for dynamic provisioning.  

---

### **Apply PVC:**  
```bash
kubectl apply -f pvc-dynamic.yaml
kubectl get pvc
```  

---

## **Step 3: Deploy Pod with Dynamic PVC**  

### **Manifest (nginx-dynamic-pod.yaml):**  
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-dynamic
spec:
  containers:
    - name: nginx
      image: nginx
      volumeMounts:
        - mountPath: /usr/share/nginx/html
          name: dynamic-storage
  volumes:
    - name: dynamic-storage
      persistentVolumeClaim:
        claimName: dynamic-pvc
```  

---

### **Apply Pod:**  
```bash
kubectl apply -f nginx-dynamic-pod.yaml
kubectl get pods
```  

---

## **Step 4: Verify and Test**  

1. **Check PVC Binding:**  
```bash
kubectl get pvc
kubectl describe pvc dynamic-pvc
```  
- **Status:** `Bound`  

2. **Check PV Creation (Dynamic):**  
```bash
kubectl get pv
kubectl describe pv
```  

---

### **Testing Pod Persistence:**  
```bash
kubectl exec -it nginx-dynamic -- /bin/bash
```  
```bash
echo "Dynamic Provisioning Test" > /usr/share/nginx/html/index.html
exit
```  

**Restart Pod and Verify Data:**  
```bash
kubectl delete pod nginx-dynamic
kubectl apply -f nginx-dynamic-pod.yaml
kubectl exec -it nginx-dynamic -- cat /usr/share/nginx/html/index.html
```  
- **Expected Output:**  
```
Dynamic Provisioning Test
```  

---

## **Step 5: PVC Expansion (Optional)**  

### **Edit PVC (Resize Storage):**  
```bash
kubectl edit pvc dynamic-pvc
```  
Increase `storage` size:  
```yaml
resources:
  requests:
    storage: 15Gi
```  

---

### **Verify Expansion:**  
```bash
kubectl get pvc
kubectl describe pvc dynamic-pvc
```  
- **Status:** `Resizing` → `Bound`  

---

## **Step 6: Clean Up**  
```bash
kubectl delete pod nginx-dynamic
kubectl delete pvc dynamic-pvc
kubectl delete storageclass dynamic-storage
```  

---

## **Key Takeaways from This Hands-on:**  
- **Dynamic Provisioning** eliminates manual PV creation.  
- **StorageClass** abstracts storage types (AWS, GCP, Azure, local).  
- **Volume Expansion** ensures storage can grow with application needs.  
- **Volume Binding Modes** allow delayed binding, optimizing scheduling in multi-zone clusters.  

---

### **Next Advanced Scenario:**  
- **Advanced Node Affinity with StatefulSets**  
- **Multi-AZ Persistent Volumes**  
- **Binding PVC to Specific Zonal Disks**  
- **Using NFS for ReadWriteMany Across Nodes**  

Let me know which scenario you'd like to explore next!
