### **Scenario 10: Multi-Tenant Storage Isolation with PVs and Quotas**  

In this scenario, we'll configure Kubernetes to provide **storage isolation** for multiple tenants by using **PersistentVolume (PV) quotas, StorageClasses, and ResourceQuotas** at the namespace level. This is critical for environments where multiple teams or applications share the same cluster but require isolated and limited storage to prevent resource exhaustion.  

---  
### **Objective:**  
- Set up multiple namespaces, each representing a tenant.  
- Configure **ResourceQuotas** to limit storage per namespace.  
- Deploy PersistentVolumes (PVs) with different capacities and access modes.  
- Enforce dynamic provisioning using StorageClasses.  
- Simulate exceeding quotas and observe system behavior.  

---  
## **Step 1: Create Tenant Namespaces**  
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: tenant-a
---
apiVersion: v1
kind: Namespace
metadata:
  name: tenant-b
```  
```bash
kubectl apply -f tenant-a.yaml
kubectl apply -f tenant-b.yaml
kubectl get namespaces
```  

---

## **Step 2: Configure ResourceQuotas for Storage Isolation**  
Define storage quotas to restrict total storage per namespace.  

### **ResourceQuota for Tenant-A (quota-tenant-a.yaml):**  
```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: storage-quota
  namespace: tenant-a
spec:
  hard:
    requests.storage: 5Gi
    persistentvolumeclaims: "2"  # Limit to 2 PVCs
```  

### **ResourceQuota for Tenant-B (quota-tenant-b.yaml):**  
```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: storage-quota
  namespace: tenant-b
spec:
  hard:
    requests.storage: 10Gi
    persistentvolumeclaims: "4"  # Limit to 4 PVCs
```  
```bash
kubectl apply -f quota-tenant-a.yaml
kubectl apply -f quota-tenant-b.yaml
kubectl describe resourcequota storage-quota -n tenant-a
kubectl describe resourcequota storage-quota -n tenant-b
```  

---

## **Step 3: Create a StorageClass for Dynamic Provisioning**  
Use dynamic provisioning to allocate PVs when PVCs are created.  

### **StorageClass (storageclass.yaml):**  
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: tenant-sc
provisioner: kubernetes.io/no-provisioner  # Manual provisioning
parameters:
  type: gp2
reclaimPolicy: Retain
volumeBindingMode: Immediate
```  
```bash
kubectl apply -f storageclass.yaml
```  

---

## **Step 4: Provision PersistentVolumes for Each Tenant**  
Manually provision PVs that will be bound to PVCs dynamically.  

### **PersistentVolumes for Tenant-A (pv-tenant-a.yaml):**  
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-tenant-a
spec:
  capacity:
    storage: 3Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: tenant-sc
  hostPath:
    path: /mnt/data-a
```  

### **PersistentVolumes for Tenant-B (pv-tenant-b.yaml):**  
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-tenant-b
spec:
  capacity:
    storage: 8Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: tenant-sc
  hostPath:
    path: /mnt/data-b
```  
```bash
kubectl apply -f pv-tenant-a.yaml
kubectl apply -f pv-tenant-b.yaml
kubectl get pv
```  

---

## **Step 5: Create PVCs in Tenant Namespaces**  

### **PVC for Tenant-A (pvc-tenant-a.yaml):**  
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-tenant-a
  namespace: tenant-a
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 3Gi
  storageClassName: tenant-sc
```  

### **PVC for Tenant-B (pvc-tenant-b.yaml):**  
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-tenant-b
  namespace: tenant-b
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 8Gi
  storageClassName: tenant-sc
```  
```bash
kubectl apply -f pvc-tenant-a.yaml
kubectl apply -f pvc-tenant-b.yaml
kubectl get pvc -n tenant-a
kubectl get pvc -n tenant-b
```  

---

## **Step 6: Deploy Applications in Each Tenant Namespace**  
Deploy simple Nginx pods to use the PVCs.  

### **Nginx Deployment for Tenant-A (nginx-tenant-a.yaml):**  
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-tenant-a
  namespace: tenant-a
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - name: nginx
          image: nginx
          volumeMounts:
            - name: storage
              mountPath: /usr/share/nginx/html
      volumes:
        - name: storage
          persistentVolumeClaim:
            claimName: pvc-tenant-a
```  
```bash
kubectl apply -f nginx-tenant-a.yaml
```  

---

## **Step 7: Test Quota Enforcement**  
Try to provision a PVC exceeding the quota.  

### **Exceeding Quota PVC (exceed-pvc.yaml):**  
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: exceed-pvc
  namespace: tenant-a
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
  storageClassName: tenant-sc
```  
```bash
kubectl apply -f exceed-pvc.yaml
```  
**Expected Output:**  
```
Error from server (Forbidden): persistentvolumeclaims "exceed-pvc" is forbidden: exceeded quota: storage-quota, requested: requests.storage=5Gi, used: requests.storage=3Gi, limited: requests.storage=5Gi
```  

---

## **Step 8: Verify and Cleanup**  
```bash
kubectl describe pvc pvc-tenant-a -n tenant-a
kubectl describe quota storage-quota -n tenant-a
kubectl delete namespace tenant-a tenant-b
kubectl delete pv pv-tenant-a pv-tenant-b
kubectl delete storageclass tenant-sc
```  

---

## **Key Learnings from This Scenario:**  
- **ResourceQuotas** ensure fair usage of storage across namespaces.  
- **StorageClasses** allow dynamic and isolated provisioning per tenant.  
- **HostPath and Manual Provisioning** simulate local storage in real clusters.  
- Exceeding quotas triggers errors, demonstrating storage governance.  

---

