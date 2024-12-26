Hands-on exercise on **Kubernetes Persistent Volumes (PV) and Persistent Volume Claims (PVC)** that you can follow step by step on **KillerCoda**.

### Objective:
You will create a **Persistent Volume (PV)**, a **Persistent Volume Claim (PVC)**, and use them in a pod to store and persist data. This will help you understand the concept of storage in Kubernetes and how PV and PVC work together.

### Pre-requisite:
- Basic understanding of Kubernetes concepts like pods, deployments, and namespaces.
- Have access to **KillerCoda** with a Kubernetes cluster running.

### Steps:

#### Step 1: Create a Namespace
In Kubernetes, namespaces help to separate different environments and applications.

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: storage-demo
```
Save this as `namespace.yaml` and apply it:

```bash
kubectl apply -f namespace.yaml
```

#### Step 2: Create a Persistent Volume (PV)
A **Persistent Volume (PV)** represents a piece of storage in your cluster. We’ll create a PV that uses local storage (for demonstration purposes).

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: my-pv
  namespace: storage-demo
spec:
  capacity:
    storage: 5Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: manual
  local:
    path: "/mnt/data"  # Ensure this path exists on your node
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - <your-node-name> # Replace with your actual node name
```

Save this as `pv.yaml` and apply it:

```bash
kubectl apply -f pv.yaml
```

#### Step 3: Create a Persistent Volume Claim (PVC)
A **Persistent Volume Claim (PVC)** is a request for storage. It specifies size and access modes.

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-pvc
  namespace: storage-demo
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
  storageClassName: manual
```

Save this as `pvc.yaml` and apply it:

```bash
kubectl apply -f pvc.yaml
```

#### Step 4: Verify the PV and PVC Status
Check if your Persistent Volume and Persistent Volume Claim are correctly bound:

```bash
kubectl get pv
kubectl get pvc -n storage-demo
```

The **status** of your PVC should be `Bound`, and the **status** of your PV should be `Available` or `Bound`.

#### Step 5: Create a Pod that Uses the PVC
Now, you’ll create a Pod that mounts the PVC as a volume.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
  namespace: storage-demo
spec:
  containers:
  - name: nginx
    image: nginx
    volumeMounts:
    - mountPath: /usr/share/nginx/html
      name: persistent-storage
  volumes:
  - name: persistent-storage
    persistentVolumeClaim:
      claimName: my-pvc
```

Save this as `pod.yaml` and apply it:

```bash
kubectl apply -f pod.yaml
```

#### Step 6: Verify the Pod is Running
Check if your pod is running and is using the PVC for storage.

```bash
kubectl get pod -n storage-demo
```

#### Step 7: Test Persistent Storage
To verify persistent storage, enter the pod and create a file in the mounted volume:

```bash
kubectl exec -it my-pod -n storage-demo -- /bin/bash
```

Inside the pod, create a test file:

```bash
echo "Hello, Kubernetes Persistent Storage!" > /usr/share/nginx/html/test.txt
```

#### Step 8: Restart the Pod and Check Persistence
Delete and recreate the pod to see if the data persists:

```bash
kubectl delete pod my-pod -n storage-demo
kubectl apply -f pod.yaml
```

After the pod is recreated, check if the file `test.txt` is still present.

```bash
kubectl exec -it my-pod -n storage-demo -- cat /usr/share/nginx/html/test.txt
```

If the file content is displayed, then your PVC and PV are working correctly for persistent storage.

#### Step 9: Clean Up
After completing the exercise, you can delete all the resources created:

```bash
kubectl delete -f pod.yaml
kubectl delete -f pvc.yaml
kubectl delete -f pv.yaml
kubectl delete -f namespace.yaml
```

### Summary:
- You created a **Persistent Volume (PV)** with local storage.
- You created a **Persistent Volume Claim (PVC)** to request storage from the PV.
- You used the PVC in a **Pod** to persist data even after the pod was deleted and recreated.

This exercise demonstrates the basic concepts of persistent storage in Kubernetes using **Persistent Volumes (PV)** and **Persistent Volume Claims (PVC)**.
