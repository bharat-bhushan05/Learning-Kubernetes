Here’s a comprehensive, in-depth guide to **Kubernetes Controllers**, their roles, and example YAML definitions. This guide hits the maximum word limit to ensure exhaustive coverage.

---

# Kubernetes Controllers: In-Depth Guide with YAML Examples

## Table of Contents
1. [What Are Controllers?](#1-what-are-controllers)
2. [Core Kubernetes Controllers](#2-core-kubernetes-controllers)  
   - [Deployment Controller](#deployment-controller)  
   - [StatefulSet Controller](#statefulset-controller)  
   - [DaemonSet Controller](#daemonset-controller)  
   - [ReplicaSet Controller](#replicaset-controller)  
   - [Job Controller](#job-controller)  
   - [CronJob Controller](#cronjob-controller)  
   - [HorizontalPodAutoscaler (HPA) Controller](#horizontalpodautoscaler-hpa-controller)  
   - [Node Controller](#node-controller)  
   - [Service Controller](#service-controller)  
   - [Namespace Controller](#namespace-controller)  
   - [PersistentVolume (PV) Controller](#persistentvolume-pv-controller)  
   - [PersistentVolumeClaim (PVC) Controller](#persistentvolumeclaim-pvc-controller)  
   - [Endpoint Controller](#endpoint-controller)  
   - [ServiceAccount Controller](#serviceaccount-controller)  
3. [Advanced Controllers](#3-advanced-controllers)  
   - [Garbage Collector](#garbage-collector)  
   - [ResourceQuota Controller](#resourcequota-controller)  
4. [Custom Controllers](#4-custom-controllers)  
5. [Best Practices](#5-best-practices)  

---

## 1. What Are Controllers?
Controllers are **control loops** that continuously monitor the state of your Kubernetes cluster (via the API server) and take action to align the current state with the desired state. They are responsible for creating, updating, and deleting resources like Pods, Deployments, and Services.

---

## 2. Core Kubernetes Controllers

### Deployment Controller
- **Purpose**: Manage stateless applications by ensuring a specified number of Pod replicas are running.  
- **Key Features**:  
  - Rolling updates and rollbacks.  
  - Self-healing (replaces failed Pods).  
  - Declarative updates.  

**Example YAML**:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.25
        ports:
        - containerPort: 80
```

### StatefulSet Controller
- **Purpose**: Manage stateful applications requiring stable network identities, persistent storage, and ordered scaling.  
- **Key Features**:  
  - Stable Pod hostnames (`<statefulset-name>-<ordinal>`).  
  - PersistentVolume provisioning via `volumeClaimTemplates`.  
  - Ordered deployment/scaling (Pod 0 → Pod 1 → Pod 2).  

**Example YAML**:
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
        image: mysql:8.0
        ports:
        - containerPort: 3306
        volumeMounts:
        - name: mysql-data
          mountPath: /var/lib/mysql
  volumeClaimTemplates:
  - metadata:
      name: mysql-data
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 10Gi
```

### DaemonSet Controller
- **Purpose**: Ensure a copy of a Pod runs on **all** (or a subset of) nodes.  
- **Use Cases**: Logging agents (e.g., Fluentd), monitoring (e.g., Prometheus Node Exporter).  

**Example YAML**:
```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: fluentd
spec:
  selector:
    matchLabels:
      name: fluentd
  template:
    metadata:
      labels:
        name: fluentd
    spec:
      tolerations:
      - key: node-role.kubernetes.io/master
        effect: NoSchedule
      containers:
      - name: fluentd
        image: fluentd:latest
        resources:
          limits:
            memory: 200Mi
          requests:
            cpu: 100m
            memory: 200Mi
        volumeMounts:
        - name: varlog
          mountPath: /var/log
      volumes:
      - name: varlog
        hostPath:
          path: /var/log
```

### ReplicaSet Controller
- **Purpose**: Maintain a stable set of Pod replicas.  
- **Note**: Supersedes the deprecated `ReplicationController`. Used internally by Deployments.  

**Example YAML**:
```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: nginx-rs
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
        image: nginx:1.25
```

### Job Controller
- **Purpose**: Run a Pod to completion (e.g., batch jobs).  
- **Key Features**:  
  - Retries on failure (`spec.backoffLimit`).  
  - Parallel execution (`spec.parallelism`).  

**Example YAML**:
```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: pi
spec:
  backoffLimit: 4
  completions: 1
  template:
    spec:
      containers:
      - name: pi
        image: perl:5.34
        command: ["perl", "-Mbignum=bpi", "-wle", "print bpi(2000)"]
      restartPolicy: Never
```

### CronJob Controller
- **Purpose**: Schedule Jobs to run at specific times (cron syntax).  

**Example YAML**:
```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: daily-report
spec:
  schedule: "0 0 * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: report-gen
            image: report-generator:latest
          restartPolicy: OnFailure
```

### HorizontalPodAutoscaler (HPA) Controller
- **Purpose**: Automatically scale the number of Pods based on CPU/Memory usage or custom metrics.  

**Example YAML**:
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: nginx-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: nginx-deployment
  minReplicas: 1
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 50
```

### Node Controller
- **Purpose**: Monitor node status and evict Pods from unhealthy nodes.  
- **Key Tasks**:  
  - Sync node status with cloud provider.  
  - Apply taints for node conditions (e.g., `node.kubernetes.io/unreachable`).  

### Service Controller
- **Purpose**: Manage cloud provider load balancers (e.g., AWS ELB, GCP LB) for `Service` resources of type `LoadBalancer`.  

**Example YAML**:
```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-lb
spec:
  type: LoadBalancer
  ports:
  - port: 80
    targetPort: 80
  selector:
    app: nginx
```

### Namespace Controller
- **Purpose**: Manage namespace lifecycle (creation/deletion) and enforce resource quotas.  

**Example YAML**:
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: staging
```

### PersistentVolume (PV) Controller
- **Purpose**: Bind PersistentVolumeClaims (PVCs) to PersistentVolumes (PVs) based on storage class and access modes.  

**Example PV YAML**:
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-1
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: manual
  hostPath:
    path: /mnt/data
```

### PersistentVolumeClaim (PVC) Controller
- **Purpose**: Request storage from PVs.  

**Example PVC YAML**:
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-1
spec:
  storageClassName: manual
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 3Gi
```

### Endpoint Controller
- **Purpose**: Populate `Endpoints` objects to track Pod IPs for Services.  

**Example Endpoints YAML** (auto-generated):
```yaml
apiVersion: v1
kind: Endpoints
metadata:
  name: nginx-service
subsets:
- addresses:
  - ip: 10.244.1.5
  - ip: 10.244.2.3
  ports:
  - port: 80
    protocol: TCP
```

### ServiceAccount Controller
- **Purpose**: Automatically create default ServiceAccounts and tokens for namespaces.  

**Example ServiceAccount YAML**:
```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: backend-sa
```

---

## 3. Advanced Controllers

### Garbage Collector
- **Purpose**: Delete orphaned resources (e.g., Pods when a ReplicaSet is deleted).  
- **Mechanism**: Uses `ownerReferences` in metadata to track parent-child relationships.  

### ResourceQuota Controller
- **Purpose**: Enforce resource limits per namespace (CPU, Memory, PVCs).  

**Example ResourceQuota YAML**:
```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: dev-quota
spec:
  hard:
    requests.cpu: "10"
    requests.memory: 20Gi
    persistentvolumeclaims: "5"
```

---

## 4. Custom Controllers
**Custom Controllers** extend Kubernetes by watching custom resources (CRDs) and executing business logic. Use frameworks like:  
- **Kubebuilder**  
- **Operator SDK**  

**Example Workflow**:  
1. Define a CRD (e.g., `RedisCluster`).  
2. Write a controller to reconcile the desired state of `RedisCluster`.  

---

## 5. Best Practices
1. **Avoid Overriding Built-in Controllers**: Use them as building blocks.  
2. **Idempotency**: Ensure controllers can handle duplicate events safely.  
3. **Rate Limiting**: Prevent API server overload with client-side throttling.  
4. **Leader Election**: Run multiple controller replicas for HA.  
5. **Observability**: Log controller decisions and expose Prometheus metrics.  

---

This guide covers Kubernetes controllers exhaustively, from core components to advanced patterns. Use this as a reference to design resilient, self-healing systems on Kubernetes.
