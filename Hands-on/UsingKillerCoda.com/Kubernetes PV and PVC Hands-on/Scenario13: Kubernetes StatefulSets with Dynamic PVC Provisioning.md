### **Scenario 13: Kubernetes StatefulSets with Dynamic PVC Provisioning (Advanced)**  

In this hands-on, you will deploy **StatefulSets** with dynamically provisioned Persistent Volume Claims (PVCs). StatefulSets ensure that pods are created in a predictable order, maintain persistent storage, and handle scaling and failure scenarios gracefully. This scenario simulates deploying databases like **PostgreSQL, MongoDB, or Cassandra** that require stable network identities and persistent storage.  

---

### **Objective:**  
- Deploy a StatefulSet with dynamically provisioned storage.  
- Explore scaling, rolling updates, and pod recovery with persistent storage.  
- Simulate node failures and ensure pod rescheduling with attached PVCs.  

---

### **Prerequisites:**  
- Kubernetes cluster (min 2 worker nodes).  
- Access to **killercoda.com** or similar playground.  
- Basic knowledge of PVCs, PVs, and StatefulSets.  

---

## **Step 1: Prepare the Environment**  

Ensure your Kubernetes cluster is ready:  
```bash
kubectl get nodes
```  
All nodes should be in a `Ready` state.  

---

## **Step 2: Create a StorageClass for Dynamic Provisioning**  

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: stateful-storage
provisioner: kubernetes.io/aws-ebs  # Change to match your environment (e.g., nfs, gcePersistentDisk)
parameters:
  type: gp2
  fsType: ext4
reclaimPolicy: Retain
allowVolumeExpansion: true
```  
**Apply it:**  
```bash
kubectl apply -f storageclass.yaml
```  

**Explanation:**  
- `provisioner` – Set to AWS EBS, NFS, or GCE depending on your cluster.  
- `allowVolumeExpansion` – PVC can be resized dynamically.  
- `Retain` – PVs are retained even after PVC deletion.  

---

## **Step 3: Deploy a StatefulSet with PVCs**  

### **StatefulSet Manifest (nginx-example.yaml):**  
```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: web
spec:
  serviceName: "nginx"
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
        image: nginx:1.21
        ports:
        - containerPort: 80
          name: web
        volumeMounts:
        - name: web-storage
          mountPath: /usr/share/nginx/html
  volumeClaimTemplates:
  - metadata:
      name: web-storage
    spec:
      accessModes: [ "ReadWriteOnce" ]
      storageClassName: stateful-storage
      resources:
        requests:
          storage: 2Gi
```  
**Apply the StatefulSet:**  
```bash
kubectl apply -f nginx-example.yaml
```  

---

## **Step 4: Expose the StatefulSet with a Headless Service**  

```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx
  labels:
    app: nginx
spec:
  ports:
    - port: 80
      targetPort: 80
  clusterIP: None
  selector:
    app: nginx
```  
```bash
kubectl apply -f headless-service.yaml
```  

**Explanation:**  
- `clusterIP: None` – Creates a headless service, ensuring direct pod-to-pod communication.  
- Each pod gets a **stable DNS name** (`web-0`, `web-1`, `web-2`).  

---

## **Step 5: Verify Deployment**  

Check pods, PVCs, and PVs:  
```bash
kubectl get pods
kubectl get pvc
kubectl get pv
kubectl describe pod web-0
```  

---

## **Step 6: Scaling the StatefulSet**  

Increase replicas from `3` to `5`:  
```bash
kubectl scale statefulset web --replicas=5
```  
Verify new pods and PVCs:  
```bash
kubectl get pods
kubectl get pvc
```  
- New pods (`web-3`, `web-4`) and PVCs will be created automatically.  

---

## **Step 7: Simulate Node Failure and Pod Recovery**  

1. **Drain a Node to Simulate Failure:**  
```bash
kubectl drain <node-name> --ignore-daemonsets --delete-emptydir-data
```  
2. **Observe Pod Migration:**  
```bash
kubectl get pods -o wide
```  
3. **Uncordon the Node (Bring Back to Service):**  
```bash
kubectl uncordon <node-name>
```  

**Explanation:**  
- StatefulSet pods will reschedule on another node, attaching the same PVC, ensuring data persistence.  

---

## **Step 8: Performing a Rolling Update**  

Upgrade the nginx version in the StatefulSet:  
```bash
kubectl set image statefulset/web nginx=nginx:1.23
```  
Monitor rolling updates:  
```bash
kubectl rollout status statefulset web
```  
- Pods are updated sequentially (one by one), ensuring zero downtime.  

---

## **Step 9: Expanding PVC Size (Optional)**  

Edit the PVC template to expand storage:  
```yaml
resources:
  requests:
    storage: 5Gi
```  
```bash
kubectl edit statefulset web
```  
Confirm PVC expansion:  
```bash
kubectl describe pvc web-storage-web-0
```  

---

## **Step 10: Test Persistent Data After Pod Deletion**  

Delete one pod:  
```bash
kubectl delete pod web-0
```  
Verify the pod is recreated and retains data:  
```bash
kubectl get pods
kubectl exec -it web-0 -- ls /usr/share/nginx/html
```  
- Data persists across pod restarts.  

---

## **Troubleshooting:**  

1. **PVC Stuck in Pending:**  
- Ensure the `StorageClass` provisioner is available.  
- Check logs of CSI drivers:  
```bash
kubectl logs -n kube-system <csi-pod-name>
```  

2. **Pod Stuck in Terminating:**  
```bash
kubectl delete pod <pod-name> --force --grace-period=0
```  

3. **PVC Not Bound:**  
- Describe the PVC for details:  
```bash
kubectl describe pvc <pvc-name>
```  

---

## **Cleanup:**  

```bash
kubectl delete statefulset web
kubectl delete pvc --all
kubectl delete pv --all
kubectl delete svc nginx
kubectl delete storageclass stateful-storage
```  

---

## **Key Takeaways:**  
- StatefulSets are crucial for **stateful workloads** that need persistent storage and stable identities.  
- Dynamic provisioning with **volumeClaimTemplates** simplifies storage management.  
- Scaling and rolling updates for stateful applications are handled predictably.  
- Simulated node failures demonstrate Kubernetes' ability to reschedule pods while retaining attached PVCs.  
