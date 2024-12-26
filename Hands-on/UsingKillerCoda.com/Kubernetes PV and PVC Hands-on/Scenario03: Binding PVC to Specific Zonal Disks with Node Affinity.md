### **Scenario 3: Binding PVC to Specific Zonal Disks with Node Affinity**  

In multi-node or multi-zone Kubernetes clusters, you may need to ensure that PersistentVolumes (PVs) are bound to specific nodes or zones. This scenario uses **node affinity** to tie PVs to particular nodes, ensuring the pod consuming the PVC is scheduled on the same node.

---

### **Objective:**  
- Create a PV with node affinity to a specific node (zonal disk).  
- Bind a PVC to this PV.  
- Deploy a pod that uses this PVC and observe scheduling based on node affinity.

---

## **Step 1: Identify Node for Affinity**  

```bash
kubectl get nodes -o wide
```  
- **Pick a node** (e.g., `node-1`) for local disk binding.  
- Copy the node name for the next step.  

---

## **Step 2: Create PV with Node Affinity**  

### **Manifest (pv-node-affinity.yaml):**  
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: zonal-pv
spec:
  capacity:
    storage: 5Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: manual
  local:
    path: /mnt/zonal-data  # Ensure this path exists on the chosen node
  nodeAffinity:
    required:
      nodeSelectorTerms:
        - matchExpressions:
            - key: kubernetes.io/hostname
              operator: In
              values:
                - node-1  # Replace with the node name from Step 1
```  

---

### **Explanation of Fields:**  
- **local.path:**  
  - Path on the node where storage is provisioned.  
  - Create this manually:  
    ```bash
    ssh <node-ip>
    sudo mkdir -p /mnt/zonal-data
    sudo chmod 777 /mnt/zonal-data
    ```  

- **nodeAffinity:**  
  - Ensures PV binds to a specific node.  
  - `kubernetes.io/hostname` – Labels nodes by their hostnames.  

---

### **Apply PV:**  
```bash
kubectl apply -f pv-node-affinity.yaml
kubectl get pv
```  

---

## **Step 3: Create PVC to Bind PV**  

### **Manifest (pvc-node-affinity.yaml):**  
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: zonal-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
  storageClassName: manual
```  

---

### **Apply PVC:**  
```bash
kubectl apply -f pvc-node-affinity.yaml
kubectl get pvc
```  
- **Status:** `Bound`  
- The PVC will automatically bind to `zonal-pv` due to matching size and StorageClass.  

---

## **Step 4: Deploy Pod Using Node-Affinity PVC**  

### **Manifest (nginx-zonal-pod.yaml):**  
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-zonal
spec:
  containers:
    - name: nginx
      image: nginx
      volumeMounts:
        - mountPath: /usr/share/nginx/html
          name: zonal-storage
  volumes:
    - name: zonal-storage
      persistentVolumeClaim:
        claimName: zonal-pvc
```  

---

### **Apply Pod:**  
```bash
kubectl apply -f nginx-zonal-pod.yaml
kubectl get pods -o wide
```  

---

## **Verify Node Affinity:**  
1. **Check Pod Node Assignment:**  
```bash
kubectl describe pod nginx-zonal | grep Node:
```  
- **Expected Node:** `node-1`  

2. **Check PV Binding:**  
```bash
kubectl describe pv zonal-pv
```  
- **Node Affinity Section:** Should reflect node-1 as the only acceptable node.  

---

### **Test Persistence:**  
```bash
kubectl exec -it nginx-zonal -- /bin/bash
echo "Affinity Test" > /usr/share/nginx/html/index.html
exit
```  

**Delete and Redeploy Pod:**  
```bash
kubectl delete pod nginx-zonal
kubectl apply -f nginx-zonal-pod.yaml
kubectl exec -it nginx-zonal -- cat /usr/share/nginx/html/index.html
```  
- **Output:** `Affinity Test`  

---

## **Step 5: Simulate Node Failure**  

- **Cordon the Node:**  
```bash
kubectl cordon node-1
kubectl delete pod nginx-zonal
```  
- The pod will stay in `Pending` state as the bound PV is only accessible on `node-1`.  

- **Uncordon Node:**  
```bash
kubectl uncordon node-1
kubectl get pods
```  
- Pod reschedules to `node-1`.  

---

## **Key Takeaways from This Hands-on:**  
- **Node Affinity** allows tying PVs to specific nodes, crucial for local storage or zonal disks.  
- **Manual PV Binding** enables strict control over where data resides.  
- **Pod Scheduling** respects node affinity by ensuring the pod runs where the PV is available.  

---

## **Next Advanced Scenario:**  
- **Multi-AZ Persistent Volumes with Replication**  
- **StatefulSets with PodDisruptionBudgets**  
- **Dynamic PV Expansion with StatefulSets**  

Which scenario would you like to explore next?
