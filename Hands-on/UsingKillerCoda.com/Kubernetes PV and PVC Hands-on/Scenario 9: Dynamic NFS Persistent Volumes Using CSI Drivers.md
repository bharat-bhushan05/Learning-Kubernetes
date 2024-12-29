### **Scenario 9: Dynamic NFS Persistent Volumes Using CSI Drivers**  

In this advanced hands-on lab, we'll configure **dynamic NFS persistent volumes** using a CSI driver. This scenario is useful for multi-pod applications that need shared storage (e.g., WordPress, distributed systems). NFS volumes allow multiple pods across nodes to share the same data.  

---

### **Objective:**  
- Deploy an NFS server inside the cluster.  
- Install and configure the NFS CSI driver.  
- Dynamically provision persistent volumes (PVs) using StorageClasses.  
- Deploy a multi-pod application that shares the same NFS volume.  

---

## **Step 1: Deploy an NFS Server in Kubernetes**  

### **Manifest (nfs-server-deployment.yaml):**  
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: nfs-lab

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nfs-server
  namespace: nfs-lab
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nfs-server
  template:
    metadata:
      labels:
        app: nfs-server
    spec:
      containers:
        - name: nfs-server
          image: itsthenetwork/nfs-server-alpine:latest
          ports:
            - name: nfs
              containerPort: 2049
          env:
            - name: SHARED_DIRECTORY
              value: /exports
          volumeMounts:
            - name: nfs-data
              mountPath: /exports
      volumes:
        - name: nfs-data
          persistentVolumeClaim:
            claimName: nfs-pvc
---
apiVersion: v1
kind: Service
metadata:
  name: nfs-service
  namespace: nfs-lab
spec:
  ports:
    - port: 2049
      name: nfs
  clusterIP: None  # Headless service
  selector:
    app: nfs-server
```  
---

### **Create a PVC for the NFS Server (nfs-pvc.yaml):**  
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: nfs-pvc
  namespace: nfs-lab
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 10Gi
```  
```bash
kubectl apply -f nfs-server-deployment.yaml
kubectl apply -f nfs-pvc.yaml
```  
---

### **Verify NFS Server Deployment:**  
```bash
kubectl get pods -n nfs-lab
kubectl get svc -n nfs-lab
```  
Ensure the pod is running and the service is created.  

---

## **Step 2: Install NFS CSI Driver**  

1. **Install NFS CSI Driver using Helm:**  
```bash
helm repo add nfs-subdir-external-provisioner https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner
helm repo update
helm install nfs-provisioner nfs-subdir-external-provisioner/nfs-subdir-external-provisioner \
  --set nfs.server=<NFS_SERVER_IP> \
  --set nfs.path=/exports \
  --set storageClass.name=nfs-sc \
  --set storageClass.defaultClass=true
```  
*Replace `<NFS_SERVER_IP>` with the ClusterIP or pod IP of the NFS server.*  

---

## **Step 3: Create NFS StorageClass for Dynamic Provisioning**  

### **Manifest (nfs-storageclass.yaml):**  
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: nfs-sc
provisioner: nfs-subdir-external-provisioner
parameters:
  pathPattern: "${.PVC.namespace}/${.PVC.name}"
  archiveOnDelete: "false"
reclaimPolicy: Retain
volumeBindingMode: Immediate
```  
```bash
kubectl apply -f nfs-storageclass.yaml
```  
---

## **Step 4: Deploy an Application Using NFS Dynamic PVC**  

### **Manifest (shared-data-pvc.yaml):**  
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: shared-pvc
  namespace: default
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 5Gi
  storageClassName: nfs-sc
```  
---

### **Deploy an Application (nginx.yaml):**  
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
spec:
  replicas: 3
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
          image: nginx:latest
          volumeMounts:
            - name: shared-storage
              mountPath: /usr/share/nginx/html
      volumes:
        - name: shared-storage
          persistentVolumeClaim:
            claimName: shared-pvc
```  
```bash
kubectl apply -f shared-data-pvc.yaml
kubectl apply -f nginx.yaml
```  

---

### **Verify Application and Storage**  
```bash
kubectl get pods
kubectl get pvc
kubectl describe pvc shared-pvc
```  
Ensure all Nginx pods are using the same NFS volume.  

---

## **Step 5: Test Shared Data Across Pods**  

1. **Write to NFS volume from one pod:**  
```bash
kubectl exec -it <nginx-pod-name> -- bash
echo "Hello from NFS" > /usr/share/nginx/html/index.html
```  

2. **Verify the file from another pod:**  
```bash
kubectl exec -it <another-nginx-pod-name> -- cat /usr/share/nginx/html/index.html
```  
All pods should see the same data, proving shared access.  

---

## **Step 6: Cleanup (Optional)**  
```bash
kubectl delete deployment nginx
kubectl delete pvc shared-pvc
kubectl delete pvc nfs-pvc -n nfs-lab
kubectl delete deployment nfs-server -n nfs-lab
kubectl delete svc nfs-service -n nfs-lab
kubectl delete storageclass nfs-sc
helm uninstall nfs-provisioner
```  

---

## **Key Takeaways from This Hands-on:**  
- **NFS Volumes** allow pods to share persistent data, useful for distributed workloads.  
- **Dynamic Provisioning** automates PV creation based on PVC requests.  
- **Scalable and Flexible** – NFS is suitable for both small clusters and large multi-tenant environments.  

---

