### **Scenario 8: Stateful Application with Volume Snapshots and Recovery**  

In this scenario, we'll deploy a stateful application with PersistentVolumes (PVs) and learn how to create snapshots for backup and disaster recovery. This is crucial for database applications or any stateful workload where data integrity and recovery are essential.  

---

### **Objective:**  
- Deploy a MySQL StatefulSet with persistent storage.  
- Create and manage volume snapshots for backup.  
- Simulate data loss and perform recovery from snapshots.  

---

## **Step 1: Set Up CSI Driver for Snapshots**  

Before creating volume snapshots, ensure that the CSI (Container Storage Interface) snapshot controller is installed.  

### **Install Snapshot CRDs and Controller:**  
```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/master/client/config/crd/snapshot.storage.k8s.io_volumesnapshots.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/master/deploy/kubernetes/snapshot-controller/rbac-snapshot-controller.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/master/deploy/kubernetes/snapshot-controller/setup-snapshot-controller.yaml
```  
---

### **Verify Snapshot Controller Installation:**  
```bash
kubectl get crd | grep volumesnapshot
kubectl get pods -n kube-system | grep snapshot-controller
```  
Ensure the snapshot controller is running.  

---

## **Step 2: Create a StorageClass Supporting Snapshots**  

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: csi-sc
provisioner: ebs.csi.aws.com
parameters:
  type: gp3
reclaimPolicy: Retain
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: true
```  
```bash
kubectl apply -f storageclass.yaml
```  

---

## **Step 3: Deploy a MySQL StatefulSet with Persistent Storage**  

### **Manifest (mysql-statefulset.yaml):**  
```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mysql
spec:
  serviceName: mysql
  replicas: 1
  selector:
    matchLabels:
      app: mysql
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
        - name: mysql
          image: mysql:5.7
          env:
            - name: MYSQL_ROOT_PASSWORD
              value: rootpassword
          volumeMounts:
            - name: data
              mountPath: /var/lib/mysql
  volumeClaimTemplates:
    - metadata:
        name: data
      spec:
        accessModes: 
          - ReadWriteOnce
        resources:
          requests:
            storage: 10Gi
        storageClassName: csi-sc
```  
```bash
kubectl apply -f mysql-statefulset.yaml
```  
---

### **Verify Deployment:**  
```bash
kubectl get pods
kubectl get pvc
```  
Ensure the pod is running and the PVC is bound.  

---

## **Step 4: Create a VolumeSnapshotClass**  

### **Manifest (volumesnapshotclass.yaml):**  
```yaml
apiVersion: snapshot.storage.k8s.io/v1
kind: VolumeSnapshotClass
metadata:
  name: csi-snapshot-class
driver: ebs.csi.aws.com
deletionPolicy: Retain
```  
```bash
kubectl apply -f volumesnapshotclass.yaml
```  
---

## **Step 5: Take a Volume Snapshot of the PVC**  

### **Manifest (volumesnapshot.yaml):**  
```yaml
apiVersion: snapshot.storage.k8s.io/v1
kind: VolumeSnapshot
metadata:
  name: mysql-snapshot
spec:
  volumeSnapshotClassName: csi-snapshot-class
  source:
    persistentVolumeClaimName: data-mysql-0
```  
```bash
kubectl apply -f volumesnapshot.yaml
```  

---

### **Verify Snapshot Creation:**  
```bash
kubectl get volumesnapshot
kubectl describe volumesnapshot mysql-snapshot
```  
Ensure the snapshot is `ReadyToUse`.  

---

## **Step 6: Simulate Data Loss**  

- Connect to MySQL and create a test database.  
```bash
kubectl exec -it mysql-0 -- mysql -uroot -prootpassword -e "CREATE DATABASE testdb;"
kubectl exec -it mysql-0 -- mysql -uroot -prootpassword -e "SHOW DATABASES;"
```  
- Simulate data loss by deleting the PVC.  
```bash
kubectl delete pvc data-mysql-0
kubectl get pvc
```  

---

## **Step 7: Restore from Snapshot**  

### **Manifest (restore-pvc.yaml):**  
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: data-mysql-0
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
  storageClassName: csi-sc
  dataSource:
    name: mysql-snapshot
    kind: VolumeSnapshot
    apiGroup: snapshot.storage.k8s.io
```  
```bash
kubectl apply -f restore-pvc.yaml
```  

---

### **Restart StatefulSet:**  
```bash
kubectl rollout restart statefulset mysql
kubectl get pods
```  
Verify the pod is running and data is restored.  

---

## **Step 8: Verify Data Recovery**  

```bash
kubectl exec -it mysql-0 -- mysql -uroot -prootpassword -e "SHOW DATABASES;"
```  
Ensure `testdb` exists, confirming successful recovery.  

---

## **Step 9: Cleanup (Optional)**  

```bash
kubectl delete statefulset mysql
kubectl delete volumesnapshot mysql-snapshot
kubectl delete volumesnapshotclass csi-snapshot-class
kubectl delete pvc data-mysql-0
```  

---

## **Key Takeaways from This Hands-on:**  
- **Volume Snapshots** provide easy backup and recovery for stateful applications.  
- **Restoration** from snapshots is seamless, ensuring minimal downtime.  
- **SnapshotClass** manages snapshot policies, enabling greater control over backup lifecycles.  

---
