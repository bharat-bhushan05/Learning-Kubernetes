### **Scenario 5: StatefulSets with Dynamic Volume Provisioning**  

StatefulSets manage stateful applications, ensuring each pod retains a unique identity and stable storage. This scenario demonstrates how to provision PersistentVolumes dynamically for each pod in a StatefulSet, ensuring data persistence across pod restarts.  

---

### **Objective:**  
- Create a StatefulSet with dynamic PVC provisioning.  
- Deploy a replicated stateful application (e.g., MySQL or Redis).  
- Ensure each pod gets a unique PersistentVolume.  

---

## **Step 1: Create StorageClass for Dynamic PV Provisioning**  

### **Manifest (storageclass-stateful.yaml):**  
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: stateful-sc
provisioner: kubernetes.io/aws-ebs
parameters:
  type: gp2
reclaimPolicy: Retain
volumeBindingMode: WaitForFirstConsumer
```  

---

### **Explanation of Fields:**  
- **volumeBindingMode: WaitForFirstConsumer** – PVs are created when pods are scheduled, avoiding unnecessary resource allocation.  
- **reclaimPolicy: Retain** – Even if the PVC is deleted, the PV remains for manual cleanup, preventing accidental data loss.  

---

### **Apply StorageClass:**  
```bash
kubectl apply -f storageclass-stateful.yaml
kubectl get storageclass
```  

---

## **Step 2: Deploy StatefulSet with PVC Template**  

### **Manifest (statefulset-mysql.yaml):**  
```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mysql
spec:
  serviceName: mysql
  replicas: 3
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
          ports:
            - containerPort: 3306
          volumeMounts:
            - name: mysql-storage
              mountPath: /var/lib/mysql
  volumeClaimTemplates:
    - metadata:
        name: mysql-storage
      spec:
        accessModes:
          - ReadWriteOnce
        resources:
          requests:
            storage: 10Gi
        storageClassName: stateful-sc
```  

---

### **Explanation of Fields:**  
- **volumeClaimTemplates** – Automatically provisions a PVC for each pod replica.  
- **replicas: 3** – Three MySQL pods, each with its own PVC.  
- **serviceName: mysql** – All pods are part of a headless service, enabling direct pod-to-pod communication.  

---

### **Apply StatefulSet:**  
```bash
kubectl apply -f statefulset-mysql.yaml
kubectl get statefulsets
kubectl get pods -o wide
```  
- Pods will appear as `mysql-0`, `mysql-1`, and `mysql-2`.  
- Each pod will receive a unique PVC (`mysql-storage-mysql-0`, etc.).  

---

## **Step 3: Verify PVC and PV Binding**  

```bash
kubectl get pvc
kubectl get pv
```  
- Three PVCs are dynamically created, each bound to a separate PV.  

```bash
kubectl describe pvc mysql-storage-mysql-0
```  
- Verify that the PVC is bound and references the `stateful-sc` StorageClass.  

---

## **Step 4: Access Pods and Test Persistence**  

```bash
kubectl exec -it mysql-0 -- mysql -u root -p
```  
- Log in to the MySQL instance and create a test database.  
```sql
CREATE DATABASE testdb;
SHOW DATABASES;
```  

- Restart the pod to ensure data persists.  
```bash
kubectl delete pod mysql-0
kubectl get pods
```  
- After the pod restarts, verify the database still exists.  
```bash
kubectl exec -it mysql-0 -- mysql -u root -p
SHOW DATABASES;
```  

---

## **Step 5: Scale StatefulSet**  

```bash
kubectl scale statefulset mysql --replicas=5
kubectl get pods
kubectl get pvc
```  
- Additional pods (`mysql-3`, `mysql-4`) are created, each with a corresponding PVC.  

---

## **Step 6: Clean Up (Optional)**  

```bash
kubectl delete statefulset mysql
kubectl delete pvc --selector=app=mysql
kubectl delete pv --selector=app=mysql
```  
- PVC deletion will retain the PVs if `Retain` was used. Manually delete PVs if necessary.  

---

## **Key Takeaways from This Hands-on:**  
- **StatefulSets** ensure stable pod identities and persistent storage.  
- **volumeClaimTemplates** dynamically provision PVCs per pod.  
- **Scaling** adds new pods with unique PVs, ensuring data isolation per replica.  

---

## **Next Advanced Scenario:**  
- **Scenario 6: Volume Expansion for PersistentVolumes**  
- **Scenario 7: Multi-Zone StatefulSets with Anti-Affinity**  

Would you like to proceed with volume expansion or dive into multi-zone StatefulSets?
