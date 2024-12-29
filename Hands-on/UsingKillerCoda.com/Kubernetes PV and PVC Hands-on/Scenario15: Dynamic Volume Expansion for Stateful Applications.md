### **Scenario 15: Dynamic Volume Expansion for Stateful Applications**  

In this advanced scenario, you'll dynamically expand Persistent Volumes (PVs) backing Stateful applications (like databases) without downtime. This is crucial for real-world scaling and data growth without service interruption.  

---

### **Objective:**  
- Deploy a StatefulSet with dynamically provisioned PVCs.  
- Expand PVC size while the application is running.  
- Verify data integrity after volume expansion.  

---

### **Prerequisites:**  
- Kubernetes cluster (v1.21+).  
- CSI driver that supports volume expansion (e.g., AWS EBS, GCP PD, OpenEBS, etc.).  
- Stateful application deployment (PostgreSQL, MySQL, or MongoDB).  

---

### **Step 1: Enable Volume Expansion in StorageClass**  

Create a `StorageClass` with volume expansion enabled.  
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: expandable-sc
provisioner: ebs.csi.aws.com  # Use your environment's CSI driver
allowVolumeExpansion: true
parameters:
  type: gp2
reclaimPolicy: Retain
volumeBindingMode: Immediate
```  
```bash
kubectl apply -f storageclass.yaml
```  
---

### **Step 2: Deploy StatefulSet with PVCs**  

Deploy PostgreSQL StatefulSet using PVC backed by the expandable StorageClass.  

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: postgres-db
spec:
  serviceName: "postgres"
  replicas: 1
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
      - name: postgres
        image: postgres:14
        ports:
        - containerPort: 5432
        env:
        - name: POSTGRES_PASSWORD
          value: "password"
        volumeMounts:
        - mountPath: /var/lib/postgresql/data
          name: db-data
  volumeClaimTemplates:
  - metadata:
      name: db-data
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 5Gi
      storageClassName: expandable-sc
```  
```bash
kubectl apply -f statefulset.yaml
```  

---

### **Step 3: Verify PVC Creation and Attachments**  

Check the PVC created by the StatefulSet:  
```bash
kubectl get pvc
```  
```bash
NAME                STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS     AGE
db-data-postgres-0  Bound    pvc-123abc45-678x-90yz-1bcdefg23456        5Gi        RWO            expandable-sc    1m
```  

---

### **Step 4: Simulate Data Load**  

Connect to the running pod and add data to simulate real usage.  
```bash
kubectl exec -it postgres-db-0 -- psql -U postgres
```  
Create a sample database and table:  
```sql
CREATE DATABASE myapp;
\c myapp
CREATE TABLE test (id SERIAL PRIMARY KEY, data TEXT);
INSERT INTO test (data) VALUES ('Initial data');
```  

---

### **Step 5: Expand PVC Size**  

Edit the PVC to request additional storage.  
```bash
kubectl edit pvc db-data-postgres-0
```  
Locate the `resources.requests.storage` section and increase the size:  
```yaml
resources:
  requests:
    storage: 10Gi
```  

Alternatively, apply it directly with `kubectl patch`:  
```bash
kubectl patch pvc db-data-postgres-0 -p '{"spec":{"resources":{"requests":{"storage":"10Gi"}}}}'
```  

---

### **Step 6: Verify PVC Expansion**  

```bash
kubectl get pvc db-data-postgres-0
```  
```bash
NAME                STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS     AGE
db-data-postgres-0  Bound    pvc-123abc45-678x-90yz-1bcdefg23456        10Gi       RWO            expandable-sc    5m
```  

Check the volume status:  
```bash
kubectl describe pvc db-data-postgres-0
```  

**Verify with the following output:**  
```bash
Status: Bound
Capacity: 10Gi
```  

---

### **Step 7: Restart StatefulSet (If Required by CSI Driver)**  

Some CSI drivers require pod restart to detect the volume size change.  
```bash
kubectl rollout restart statefulset postgres-db
```  

---

### **Step 8: Verify Data Integrity After Expansion**  

Log in to the pod again and verify the data remains intact:  
```bash
kubectl exec -it postgres-db-0 -- psql -U postgres -d myapp
```  
```sql
SELECT * FROM test;
```  
**Expected Output:**  
```bash
 id |     data      
----+--------------
  1 | Initial data
```  

---

### **Step 9: Perform Dynamic Expansion for Running Pods**  

Kubernetes v1.22+ supports resizing PVCs without restarting StatefulSets for CSI drivers that support it. If the CSI driver allows online expansion, no pod restarts are required.  

To verify:  
```bash
kubectl get volumeattachments
```  
```bash
kubectl describe volumeattachment <attachment-name>
```  

Look for:  
```yaml
message: "Volume expansion succeeded"
```  

---

### **Troubleshooting:**  

1. **PVC Expansion Stuck in "Resizing":**  
- Ensure `allowVolumeExpansion` is set to `true` in the StorageClass.  
- Check pod logs:  
```bash
kubectl logs -n kube-system <csi-pod>
```  

2. **PostgreSQL Pod Stuck in Pending State:**  
- Verify the expanded PVC is correctly bound:  
```bash
kubectl get pvc
```  
- If pod fails to mount the resized volume, restart StatefulSet:  
```bash
kubectl rollout restart statefulset postgres-db
```  

3. **Expansion Not Reflected in PVC:**  
- Ensure that the CSI driver supports dynamic resizing.  
- Check for CSI volume expansion support:  
```bash
kubectl describe csidriver
```  

---

### **Key Takeaways:**  
- **Dynamic volume expansion** is critical for scaling stateful applications without downtime.  
- **allowVolumeExpansion** in `StorageClass` must be enabled.  
- Expansion can be performed **live (online)** or with **pod restarts** based on CSI driver capabilities.  
- Real-world use cases include **databases (Postgres, MySQL, MongoDB)** and **file storage systems**.  
