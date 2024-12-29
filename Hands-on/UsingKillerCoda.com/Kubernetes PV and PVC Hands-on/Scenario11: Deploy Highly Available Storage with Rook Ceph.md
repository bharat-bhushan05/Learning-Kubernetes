### **Scenario 11: Deploy Highly Available Storage with Rook Ceph**  

In this scenario, you'll deploy a **Ceph cluster using Rook** to provide highly available, distributed block storage for Kubernetes. Ceph is an open-source storage solution that supports block, object, and file storage. Rook automates deployment and management of Ceph in Kubernetes, making it easier to handle dynamic storage needs.  

---

### **Objective:**  
- Deploy Rook Ceph as a storage backend.  
- Configure a CephBlockPool and StorageClass for dynamic PVC provisioning.  
- Deploy a StatefulSet that uses Ceph storage.  
- Simulate node failure and test data resiliency.  

---

## **Prerequisites:**  
- Kubernetes cluster with at least 3 nodes (for redundancy).  
- Access to **killercoda.com** or a similar Kubernetes playground.  

---

### **Step 1: Install Rook-Ceph Operator**  

```bash
# Clone Rook GitHub repo for manifests
git clone https://github.com/rook/rook.git
cd rook/deploy/examples

# Deploy Rook operator
kubectl apply -f crds.yaml
kubectl apply -f common.yaml
kubectl apply -f operator.yaml

# Verify operator deployment
kubectl get pods -n rook-ceph
```  
**Explanation:**  
- `crds.yaml` – Installs Custom Resource Definitions (CRDs) for Ceph.  
- `common.yaml` – Sets up namespaces and service accounts.  
- `operator.yaml` – Deploys the Rook operator to manage Ceph clusters.  

---

### **Step 2: Deploy Ceph Cluster**  

```bash
# Deploy Ceph cluster
kubectl apply -f cluster.yaml

# Check cluster status
kubectl get pods -n rook-ceph
```  
**cluster.yaml:**  
```yaml
apiVersion: ceph.rook.io/v1
kind: CephCluster
metadata:
  name: rook-ceph
  namespace: rook-ceph
spec:
  dataDirHostPath: /var/lib/rook
  mon:
    count: 3
    allowMultiplePerNode: false
  cephVersion:
    image: quay.io/ceph/ceph:v16
  dashboard:
    enabled: true
  storage:
    useAllNodes: true
    useAllDevices: true
```  
**Explanation:**  
- Deploys a **3-monitor Ceph cluster** for high availability.  
- Rook automatically uses all nodes and devices to build the cluster.  
- The Ceph dashboard is enabled for cluster management.  

---

### **Step 3: Create a CephBlockPool**  

```bash
# Deploy Ceph block pool
kubectl apply -f pool.yaml
```  
**pool.yaml:**  
```yaml
apiVersion: ceph.rook.io/v1
kind: CephBlockPool
metadata:
  name: replicapool
  namespace: rook-ceph
spec:
  replicated:
    size: 3  # Data replicated across 3 nodes
  failureDomain: host
```  
**Explanation:**  
- A CephBlockPool defines storage redundancy (3-way replication).  
- `failureDomain: host` ensures no data loss if one node fails.  

---

### **Step 4: Create a StorageClass for PVCs**  

```bash
kubectl apply -f storageclass.yaml
```  
**storageclass.yaml:**  
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: rook-ceph-block
provisioner: rook-ceph.rbd.csi.ceph.com
parameters:
  clusterID: rook-ceph
  pool: replicapool
  imageFormat: "2"
  imageFeatures: layering
  csi.storage.k8s.io/provisioner-secret-name: rook-csi-rbd-provisioner
  csi.storage.k8s.io/provisioner-secret-namespace: rook-ceph
  csi.storage.k8s.io/controller-expand-secret-name: rook-csi-rbd-provisioner
  csi.storage.k8s.io/controller-expand-secret-namespace: rook-ceph
  csi.storage.k8s.io/node-stage-secret-name: rook-csi-rbd-node
  csi.storage.k8s.io/node-stage-secret-namespace: rook-ceph
  csi.storage.k8s.io/fstype: ext4
reclaimPolicy: Retain
allowVolumeExpansion: true
```  
**Explanation:**  
- This StorageClass dynamically provisions PVs from the CephBlockPool.  
- Supports **volume expansion** and uses RBD (RADOS Block Device) as the backend.  

---

### **Step 5: Create PVCs with Ceph Storage**  

```bash
kubectl apply -f pvc.yaml
```  
**pvc.yaml:**  
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: ceph-pvc
  namespace: default
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
  storageClassName: rook-ceph-block
```  

---

### **Step 6: Deploy StatefulSet with Ceph PVCs**  

```bash
kubectl apply -f statefulset.yaml
```  
**statefulset.yaml:**  
```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: web
  namespace: default
spec:
  serviceName: "nginx"
  replicas: 3
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: nginx
        image: nginx
        volumeMounts:
        - name: data
          mountPath: /usr/share/nginx/html
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: ["ReadWriteOnce"]
      storageClassName: rook-ceph-block
      resources:
        requests:
          storage: 3Gi
```  
**Explanation:**  
- Each pod gets a dynamically provisioned Ceph PVC.  
- Volumes persist even if the pod reschedules.  

---

### **Step 7: Simulate Node Failure**  

1. **Identify Ceph monitors and OSDs**:  
```bash
kubectl get pods -n rook-ceph
```  
2. **Drain one node to simulate failure**:  
```bash
kubectl drain <node-name> --ignore-daemonsets
```  
3. **Observe cluster recovery**:  
```bash
kubectl get cephcluster -n rook-ceph
kubectl get pods -n rook-ceph
```  
4. **Uncordon the node after testing**:  
```bash
kubectl uncordon <node-name>
```  

---

### **Verification**  

```bash
# Check if PVCs are bound
kubectl get pvc

# Verify PVs
kubectl get pv

# Check Ceph cluster status
kubectl -n rook-ceph get cephcluster
```  

---

### **Cleanup**  

```bash
kubectl delete -f statefulset.yaml
kubectl delete -f pvc.yaml
kubectl delete -f pool.yaml
kubectl delete -f cluster.yaml
kubectl delete -f operator.yaml
kubectl delete namespace rook-ceph
```  

---

### **Key Takeaways:**  
- **Ceph's self-healing** ensures data durability even if nodes fail.  
- **Dynamic provisioning** simplifies managing large storage environments.  
- **Replication and failure domain** provide enterprise-grade storage resilience.  
- Useful for **production workloads requiring HA storage** (databases, critical applications).  
