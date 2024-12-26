### **Scenario 4: Dynamic Volume Provisioning with Storage Classes**  

In Kubernetes, dynamic provisioning allows the automatic creation of PersistentVolumes (PVs) when PersistentVolumeClaims (PVCs) are created. This eliminates the need for manual PV provisioning and simplifies storage management in large-scale clusters.  

---

### **Objective:**  
- Set up a StorageClass for dynamic provisioning.  
- Deploy a PVC that triggers dynamic PV creation.  
- Deploy a pod to consume the dynamically provisioned volume.  

---

## **Step 1: Create StorageClass for Dynamic Provisioning**  

### **Manifest (storage-class.yaml):**  
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: gp2-sc  # Custom StorageClass name
provisioner: kubernetes.io/aws-ebs  # For AWS EBS volumes
parameters:
  type: gp2
reclaimPolicy: Delete
volumeBindingMode: Immediate
```  

---

### **Explanation of Fields:**  
- **provisioner:**  
  - Defines the type of storage provider.  
  - Examples:  
    - AWS: `kubernetes.io/aws-ebs`  
    - GCP: `kubernetes.io/gce-pd`  
    - Azure: `kubernetes.io/azure-disk`  
    - Local: `kubernetes.io/no-provisioner`  
- **parameters:**  
  - Provider-specific parameters. For AWS, `type: gp2` (General Purpose SSD).  
- **reclaimPolicy:**  
  - `Delete`: Deletes the PV when PVC is deleted.  
  - `Retain`: Retains the PV for manual cleanup.  
- **volumeBindingMode:**  
  - `Immediate`: PV is created as soon as PVC is requested.  
  - `WaitForFirstConsumer`: PV is created only when a pod uses the PVC.  

---

### **Apply StorageClass:**  
```bash
kubectl apply -f storage-class.yaml
kubectl get storageclass
```  

---

## **Step 2: Create PVC to Trigger Dynamic PV Provisioning**  

### **Manifest (pvc-dynamic.yaml):**  
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: dynamic-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
  storageClassName: gp2-sc  # Use the custom StorageClass
```  

---

### **Apply PVC:**  
```bash
kubectl apply -f pvc-dynamic.yaml
kubectl get pvc
```  
- **Status:** `Bound`  
- Kubernetes dynamically provisions a new PV of 5Gi using AWS EBS.  

---

## **Step 3: Deploy Pod to Use PVC**  

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

## **Verification:**  

1. **Check PV and PVC:**  
```bash
kubectl get pv
kubectl describe pvc dynamic-pvc
```  
- Verify that the dynamically created PV matches the requested PVC size and storage class.  

2. **Check Pod Logs and PVC Binding:**  
```bash
kubectl logs nginx-dynamic
kubectl describe pod nginx-dynamic
```  
- Confirm the pod is running and the PVC is mounted correctly.  

---

## **Step 4: Simulate PVC Deletion and Reclaim Policy**  

```bash
kubectl delete pod nginx-dynamic
kubectl delete pvc dynamic-pvc
kubectl get pv
```  
- If `reclaimPolicy: Delete` is set, the PV will also be deleted.  
- If `Retain` is set, the PV will remain for manual cleanup.  

```bash
kubectl delete pv <pv-name>
```  

---

## **Key Takeaways from This Hands-on:**  
- **Dynamic Provisioning** simplifies volume creation and management.  
- **StorageClass** abstracts storage provider details from users.  
- **Immediate vs. WaitForFirstConsumer** strategies allow better control over volume provisioning.  

---

## **Next Advanced Scenario:**  
- **Scenario 5: StatefulSets with Dynamic Volume Provisioning**  
- **Scenario 6: Expandable Persistent Volumes (Volume Expansion)**  

Which scenario would you like to explore next?
