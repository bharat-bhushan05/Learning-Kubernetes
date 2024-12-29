### **Scenario 12: Kubernetes Dynamic NFS Provisioning with NFS-Subdir-External-Provisioner**  

In this scenario, you will set up **dynamic NFS (Network File System) provisioning** in Kubernetes using the **nfs-subdir-external-provisioner**. This allows automatic provisioning of persistent volumes (PVs) from an NFS server, enabling shared storage across multiple pods.  

---

### **Objective:**  
- Set up an NFS server (can be external or within Kubernetes).  
- Deploy the **nfs-subdir-external-provisioner** to manage dynamic provisioning.  
- Create StorageClass and PVCs dynamically.  
- Deploy an application that uses NFS-backed persistent storage.  

---

### **Prerequisites:**  
- Kubernetes cluster (at least 2 nodes).  
- Access to **killercoda.com** or a Kubernetes playground.  
- NFS server (can be created in the cluster).  

---

## **Step 1: Set Up the NFS Server**  

### **Option 1: External NFS Server (Recommended for Production)**  
- Use an existing external NFS server.  
- Ensure the NFS server exports a directory, e.g., `/export/k8s-data`.  

### **Option 2: Deploy NFS Server in Kubernetes (For Testing)**  

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/nfs-subdir-external-provisioner/master/deploy/kubernetes/nfs-server.yaml
```  
**Explanation:**  
- This deploys an **NFS server pod** within Kubernetes.  
- A PersistentVolume (PV) is created for NFS data storage.  

---

## **Step 2: Install NFS Subdir External Provisioner**  

### **Install Helm (if not already installed)**  
```bash
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
```  

### **Deploy NFS Provisioner with Helm**  

```bash
helm repo add nfs-subdir-external-provisioner https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner/
helm repo update

# Deploy provisioner
helm install nfs-provisioner nfs-subdir-external-provisioner/nfs-subdir-external-provisioner \
  --set nfs.server=<nfs-server-ip> \
  --set nfs.path=/export/k8s-data
```  
**Explanation:**  
- `nfs.server` – IP of the NFS server.  
- `nfs.path` – Path exported from the NFS server.  

---

## **Step 3: Create StorageClass for NFS Provisioning**  

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: nfs-storage
provisioner: nfs-subdir-external-provisioner
parameters:
  pathPattern: "${.PVC.namespace}-${.PVC.name}"
  archiveOnDelete: "false"
reclaimPolicy: Retain
mountOptions:
  - hard
  - nfsvers=4.1
```  
**Apply it:**  
```bash
kubectl apply -f storageclass.yaml
```  
**Explanation:**  
- **`archiveOnDelete: false`** – Deletes PVC data when the PVC is deleted.  
- **`pathPattern`** – Defines directory naming patterns for PVCs.  
- **`nfsvers=4.1`** – Ensures the use of NFS version 4.1 for better performance.  

---

## **Step 4: Create PVC Using NFS StorageClass**  

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: nfs-pvc
  namespace: default
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 5Gi
  storageClassName: nfs-storage
```  
**Apply PVC:**  
```bash
kubectl apply -f pvc.yaml
kubectl get pvc
```  
**Explanation:**  
- `ReadWriteMany` – Multiple pods can mount the PVC simultaneously.  
- Dynamically provisions PVs through the NFS provisioner.  

---

## **Step 5: Deploy a Stateful Application with NFS PVC**  

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
        image: nginx
        volumeMounts:
        - name: nfs-storage
          mountPath: /usr/share/nginx/html
      volumes:
      - name: nfs-storage
        persistentVolumeClaim:
          claimName: nfs-pvc
```  
**Deploy the App:**  
```bash
kubectl apply -f nginx-deployment.yaml
kubectl get pods
```  

---

## **Step 6: Verify NFS Dynamic Provisioning**  

```bash
kubectl get pvc
kubectl describe pvc nfs-pvc
kubectl get pv
```  
**Verification Checklist:**  
- PVC should be **Bound** to a dynamically created PV.  
- NFS mount should be accessible from pods.  

---

## **Step 7: Simulate and Test Node Failures**  

1. **Drain One Node:**  
```bash
kubectl drain <node-name> --ignore-daemonsets --delete-emptydir-data
```  
2. **Check Pod Re-Scheduling:**  
```bash
kubectl get pods -o wide
```  
3. **Ensure Pods Reconnect to NFS Storage**:  
```bash
kubectl exec -it <pod-name> -- df -h
```  
- Confirm NFS volume is still mounted and accessible.  

---

## **Step 8: Testing PVC Expansion (Optional)**  

**Expand PVC by Editing Manifest:**  
```yaml
spec:
  resources:
    requests:
      storage: 10Gi
```  
```bash
kubectl edit pvc nfs-pvc
```  
- Verify the new size:  
```bash
kubectl describe pvc nfs-pvc
```  

---

## **Troubleshooting:**  

1. **PVC Stuck in Pending:**  
- Ensure NFS server is reachable (`ping <nfs-server-ip>` from node).  
- Verify the NFS path is correctly exported (`showmount -e <nfs-server-ip>`).  

2. **NFS Pod Not Starting:**  
```bash
kubectl logs <nfs-pod-name> -n kube-system
```  
- Check for NFS mount issues or misconfiguration in the Helm chart.  

---

## **Cleanup:**  

```bash
kubectl delete -f nginx-deployment.yaml
kubectl delete -f pvc.yaml
kubectl delete -f storageclass.yaml
helm uninstall nfs-provisioner
kubectl delete -f nfs-server.yaml
```  

---

## **Key Takeaways:**  
- **NFS dynamic provisioning** allows shared persistent volumes across pods.  
- Useful for **stateful applications** like databases, CMS systems, and file servers.  
- Simulates **real-world production environments** using NFS-backed storage.  
- Expanding PVCs and testing failovers helps understand storage resilience.  

