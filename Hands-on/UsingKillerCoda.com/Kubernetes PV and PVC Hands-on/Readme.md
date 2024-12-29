## **🚀 Project Overview**  
This project demonstrates **Dynamic Persistent Volume (PV) Expansion** for Stateful applications running on Kubernetes. It simulates a real-world scenario where storage requirements increase over time, and resizing PVCs (Persistent Volume Claims) without downtime becomes essential.  

🛠️ **Key Use Case:** Scaling PostgreSQL StatefulSet by expanding its PVC from 5Gi to 10Gi while the database is running.  

---

## **🎯 Objectives**  
- ✅ Deploy a StatefulSet with dynamically provisioned PVCs.  
- ✅ Expand PVC storage capacity **without downtime**.  
- ✅ Ensure data integrity after volume expansion.  

---

## **⚙️ Prerequisites**  
- Kubernetes Cluster (v1.21 or higher).  
- CSI Driver supporting **Volume Expansion** (e.g., AWS EBS, GCP PD, OpenEBS).  
- Basic understanding of StatefulSets and Persistent Volumes.  
- Access to [Killercoda Kubernetes Lab](https://killercoda.com).  

---

## **📦 Step-by-Step Deployment**  

### **1️⃣ Create a StorageClass with Volume Expansion Enabled**  
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: expandable-sc
provisioner: ebs.csi.aws.com  # Example for AWS EBS
allowVolumeExpansion: true
parameters:
  type: gp2
reclaimPolicy: Retain
volumeBindingMode: Immediate
```  
```bash
kubectl apply -f storageclass.yaml
```  
🔹 `allowVolumeExpansion: true` – Enables dynamic volume resizing.  

---

### **2️⃣ Deploy PostgreSQL StatefulSet with PVC**  
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
🔹 **Initial PVC Size**: 5Gi.  
🔹 **StorageClass**: expandable-sc (created earlier).  

---

### **3️⃣ Verify PVC Creation**  
```bash
kubectl get pvc
```  
Expected output:  
```bash
NAME                STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS     AGE
db-data-postgres-0  Bound    pvc-123abc45-678x-90yz-1bcdefg23456        5Gi        RWO            expandable-sc    1m
```  
---

### **4️⃣ Simulate Data Load in PostgreSQL**  
```bash
kubectl exec -it postgres-db-0 -- psql -U postgres
```  
Create a database and insert sample data:  
```sql
CREATE DATABASE myapp;
\c myapp
CREATE TABLE test (id SERIAL PRIMARY KEY, data TEXT);
INSERT INTO test (data) VALUES ('Initial data');
```  
---

### **5️⃣ Expand PVC to 10Gi**  
```bash
kubectl edit pvc db-data-postgres-0
```  
Modify `resources.requests.storage` to 10Gi:  
```yaml
resources:
  requests:
    storage: 10Gi
```  
Alternatively, use `kubectl patch`:  
```bash
kubectl patch pvc db-data-postgres-0 -p '{"spec":{"resources":{"requests":{"storage":"10Gi"}}}}'
```  
---

### **6️⃣ Verify PVC Expansion**  
```bash
kubectl get pvc db-data-postgres-0
```  
Expected output:  
```bash
NAME                STATUS   CAPACITY   ACCESS MODES   STORAGECLASS     AGE
db-data-postgres-0  Bound    10Gi       RWO            expandable-sc    5m
```  
---

### **7️⃣ Verify Data Integrity**  
Reconnect to PostgreSQL and check existing data:  
```bash
kubectl exec -it postgres-db-0 -- psql -U postgres -d myapp
```  
```sql
SELECT * FROM test;
```  
Expected output:  
```bash
 id |     data      
----+--------------
  1 | Initial data
```  
---

## **🔍 Troubleshooting**  
1. **PVC Stuck in "Resizing":**  
- Ensure `allowVolumeExpansion` is set in StorageClass.  
- Check CSI pod logs:  
```bash
kubectl logs -n kube-system <csi-pod>
```  

2. **PostgreSQL Pod Fails to Mount Resized Volume:**  
- Restart StatefulSet:  
```bash
kubectl rollout restart statefulset postgres-db
```  

---

## **📊 Key Learnings**  
- 📈 **Volume Expansion** is critical for stateful applications like databases.  
- 🔄 Supports **online expansion** or **offline expansion** depending on the CSI driver.  
- 🛡️ Expanding PVCs without downtime ensures uninterrupted service.  

---

## **🌐 Real-World Use Cases**  
- **📊 Databases** (PostgreSQL, MySQL, MongoDB) that require more storage.  
- **📁 File Storage** for shared user data.  
- **📷 Media Applications** with growing media libraries.  

---

## **📌 Next Steps**  
1. **🔁 Multi-Node StatefulSets with PV Replication.**  
2. **📂 Backup and Restore StatefulSet Volumes.**  
3. **☁️ CSI Snapshots for Database Backups.**  

Would you like to dive deeper into **multi-node PostgreSQL clusters** or **distributed storage setups** next?
