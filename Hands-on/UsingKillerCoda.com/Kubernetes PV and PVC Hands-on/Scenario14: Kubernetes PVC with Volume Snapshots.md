### **Scenario 14: Kubernetes PVC with Volume Snapshots (Advanced Data Backup and Restore)**  

In this scenario, you will implement **Volume Snapshots** to back up and restore Persistent Volumes (PV) dynamically. This approach simulates real-world disaster recovery (DR) and data protection strategies for stateful applications like databases.  

---

### **Objective:**  
- Create a Persistent Volume (PV) and Persistent Volume Claim (PVC).  
- Take snapshots of the PVC.  
- Restore the snapshot to a new PVC.  
- Simulate data recovery by deploying pods using restored PVCs.  

---

### **Prerequisites:**  
- Kubernetes cluster (v1.20+).  
- CSI driver installed (such as AWS EBS, GCE Persistent Disk, or generic CSI driver).  
- Access to **killercoda.com** or similar playground.  
- Familiarity with PVCs, PVs, and StatefulSets.  

---

### **Step 1: Install Volume Snapshot CRDs**  

First, ensure that the **VolumeSnapshot CRDs** are installed.  
```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/release-6.0/client/config/crd/snapshot.storage.k8s.io_volumesnapshotclasses.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/release-6.0/client/config/crd/snapshot.storage.k8s.io_volumesnapshots.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/release-6.0/client/config/crd/snapshot.storage.k8s.io_volumesnapshotcontents.yaml
```  

Verify the CRDs:  
```bash
kubectl get crd | grep snapshot
```  

---

### **Step 2: Create a VolumeSnapshotClass**  

The `VolumeSnapshotClass` defines snapshot behavior, like `StorageClass` for PVCs.  

```yaml
apiVersion: snapshot.storage.k8s.io/v1
kind: VolumeSnapshotClass
metadata:
  name: csi-snapshot-class
driver: ebs.csi.aws.com  # Adjust based on your CSI driver (gce, nfs, etc.)
deletionPolicy: Retain
```  

**Apply the snapshot class:**  
```bash
kubectl apply -f snapshot-class.yaml
```  

---

### **Step 3: Deploy a PVC for Testing**  

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: test-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
  storageClassName: gp2  # Adjust to your environment
```  

```bash
kubectl apply -f pvc.yaml
```  

---

### **Step 4: Deploy a Test Pod to Write Data**  

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: data-pod
spec:
  containers:
  - name: busybox
    image: busybox
    command: ["sh", "-c", "echo 'Test Data' > /data/testfile && sleep 3600"]
    volumeMounts:
    - mountPath: "/data"
      name: storage
  volumes:
  - name: storage
    persistentVolumeClaim:
      claimName: test-pvc
```  

```bash
kubectl apply -f data-pod.yaml
```  

Verify data is written:  
```bash
kubectl exec data-pod -- cat /data/testfile
```  

---

### **Step 5: Create a Snapshot of the PVC**  

```yaml
apiVersion: snapshot.storage.k8s.io/v1
kind: VolumeSnapshot
metadata:
  name: test-snapshot
spec:
  volumeSnapshotClassName: csi-snapshot-class
  source:
    persistentVolumeClaimName: test-pvc
```  

```bash
kubectl apply -f snapshot.yaml
```  

Verify the snapshot:  
```bash
kubectl get volumesnapshot
```  

---

### **Step 6: Restore a PVC from the Snapshot**  

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: restored-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
  dataSource:
    name: test-snapshot
    kind: VolumeSnapshot
    apiGroup: snapshot.storage.k8s.io
```  

```bash
kubectl apply -f restored-pvc.yaml
```  

---

### **Step 7: Deploy a Pod Using the Restored PVC**  

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: restore-pod
spec:
  containers:
  - name: busybox
    image: busybox
    command: ["sh", "-c", "cat /data/testfile && sleep 3600"]
    volumeMounts:
    - mountPath: "/data"
      name: restored-storage
  volumes:
  - name: restored-storage
    persistentVolumeClaim:
      claimName: restored-pvc
```  

```bash
kubectl apply -f restore-pod.yaml
```  

Check if the restored pod has the original data:  
```bash
kubectl exec restore-pod -- cat /data/testfile
```  
**Expected Output:**  
```
Test Data
```  

---

### **Step 8: Simulate Disaster Recovery**  

1. **Delete the Original Pod and PVC:**  
```bash
kubectl delete pod data-pod
kubectl delete pvc test-pvc
```  

2. **Recreate Pod with Restored PVC:**  
```bash
kubectl apply -f restore-pod.yaml
```  

3. **Verify Data Persistence:**  
```bash
kubectl exec restore-pod -- cat /data/testfile
```  

---

### **Step 9: Expand PVC from Snapshot**  

Edit the PVC to request more storage:  
```yaml
resources:
  requests:
    storage: 10Gi
```  
```bash
kubectl edit pvc restored-pvc
```  

Verify expansion:  
```bash
kubectl describe pvc restored-pvc
```  

---

### **Troubleshooting:**  

1. **Snapshot Creation Fails:**  
- Ensure the `VolumeSnapshotClass` and `CSI driver` are compatible.  
- Check snapshot logs:  
```bash
kubectl describe volumesnapshot test-snapshot
```  

2. **PVC Stuck in Pending State:**  
- Check if `StorageClass` is available.  
- Verify CSI pod logs:  
```bash
kubectl logs -n kube-system <csi-pod-name>
```  

3. **Restore Pod Fails to Start:**  
- Ensure the restored PVC is bound:  
```bash
kubectl get pvc restored-pvc
```  

---

### **Cleanup:**  

```bash
kubectl delete pod restore-pod
kubectl delete pvc restored-pvc
kubectl delete volumesnapshot test-snapshot
kubectl delete volumesnapshotclass csi-snapshot-class
```  

---

### **Key Takeaways:**  
- Volume snapshots are essential for **disaster recovery** and **backup strategies**.  
- They allow **point-in-time recovery** without data loss.  
- Snapshots work seamlessly with CSI drivers, supporting dynamic provisioning and scaling.  
- Volume expansion allows increasing PVC size without downtime.  
