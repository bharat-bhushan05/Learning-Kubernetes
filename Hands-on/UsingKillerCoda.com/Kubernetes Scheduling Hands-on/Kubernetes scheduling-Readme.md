Let's dive into Kubernetes scheduling step by step, starting with **manual scheduling**. Each topic will have five hands-on labs to reinforce the concepts.  

### 1. Manual Scheduling (Day 1-2)
Manual scheduling bypasses the Kubernetes scheduler and places pods directly on nodes by specifying the `nodeName` field.

---

**Hands-on 1: Create a Pod with nodeName**  
1. SSH into the Kubernetes cluster on Killercoda.  
2. Create a basic pod manifest:  
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: manual-pod
spec:
  nodeName: node01
  containers:
  - name: nginx
    image: nginx
    ports:
    - containerPort: 80
```
3. Apply the manifest:  
```bash
kubectl apply -f manual-pod.yaml
```
4. Verify:  
```bash
kubectl get pods -o wide
```
5. Check pod logs:  
```bash
kubectl logs manual-pod
```

---

**Hands-on 2: Try Scheduling to a Non-existent Node**  
- Modify `nodeName` to `invalid-node` and observe the error:  
```yaml
nodeName: invalid-node
```
- Apply and check pod status:  
```bash
kubectl apply -f manual-pod.yaml
kubectl describe pod manual-pod
```

---

**Hands-on 3: Create Two Pods Manually on Different Nodes**  
- Create two pod manifests, scheduling one on `node01` and the other on `node02`.  
```yaml
nodeName: node02
```
- Verify with:  
```bash
kubectl get pods -o wide
```

---

**Hands-on 4: Debugging Manual Scheduling Failures**  
- Create a pod with an incorrect node label and troubleshoot using `describe pod`.  
- Check events for insights.

---

**Hands-on 5: Move a Pod from One Node to Another**  
1. Delete the running pod:  
```bash
kubectl delete pod manual-pod
```
2. Update `nodeName` to `node02` and redeploy:  
```bash
kubectl apply -f manual-pod.yaml
```

---

### 2. Taints and Tolerations (Day 3-4)
Taints prevent pods from being scheduled on nodes unless the pod tolerates them.

---

**Hands-on 1: Taint a Node**  
```bash
kubectl taint nodes node01 key=value:NoSchedule
```
- Confirm taint:  
```bash
kubectl describe node node01 | grep Taints
```

---

**Hands-on 2: Create a Pod with Tolerations**  
```yaml
tolerations:
- key: "key"
  operator: "Equal"
  value: "value"
  effect: "NoSchedule"
```

---

**Hands-on 3: Remove a Taint**  
```bash
kubectl taint nodes node01 key=value:NoSchedule-
```

---

**Hands-on 4: Taint Multiple Nodes**  
```bash
kubectl taint nodes node01 env=prod:NoExecute
kubectl taint nodes node02 env=dev:NoSchedule
```

---

**Hands-on 5: Pod Eviction with Taints**  
- Apply `NoExecute` taint and check pod eviction.

---

### 3. Node Selectors (Day 5-6)
Schedule pods based on node labels.

---

**Hands-on 1: Label Nodes**  
```bash
kubectl label nodes node01 env=prod
```

---

**Hands-on 2: Create a Pod with nodeSelector**  
```yaml
nodeSelector:
  env: prod
```

---

**Hands-on 3: Deploy to Unlabeled Node**  
- Deploy a pod to a node without a matching label and troubleshoot.

---

**Hands-on 4: Remove Labels and Observe**  
```bash
kubectl label nodes node01 env-
```

---

**Hands-on 5: Multi-label Node Selectors**  
```yaml
nodeSelector:
  env: prod
  tier: backend
```

---

### 4. Node Affinity (Day 7-8)  
Advanced node selection based on expressions.

---

**Hands-on 1: Set Node Affinity**  
```yaml
affinity:
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
      - matchExpressions:
        - key: env
          operator: In
          values:
          - prod
```

---

**Hands-on 2: Use 'NotIn' Operator**  
- Prevent pods from scheduling on certain nodes.

---

**Hands-on 3: PreferredDuringScheduling**  
- Implement soft node affinity rules.

---

**Hands-on 4: Complex Affinity Rules**  
- Combine `required` and `preferred` affinity.

---

**Hands-on 5: Modify Affinity at Runtime**  
- Patch running pods with new affinity rules.

---

### 5. Resource Requirements and Limits (Day 9-10)
Define CPU/memory for pods.

---

**Hands-on 1: Basic Resource Requests**  
```yaml
resources:
  requests:
    memory: "256Mi"
    cpu: "250m"
```

---

**Hands-on 2: Add Resource Limits**  
```yaml
limits:
  memory: "512Mi"
  cpu: "500m"
```

---

**Hands-on 3: Exceed Requests and Observe**  
- Deploy a pod exceeding the requests.

---

**Hands-on 4: Set Namespace Resource Quotas**  
```bash
kubectl create quota compute-resources --hard=cpu=2,memory=2Gi
```

---

**Hands-on 5: Pod Priority and Preemption**  
- Define pod priority classes.

---

### 6. DaemonSets (Day 11-12)
Ensure pods run on every node.

---

**Hands-on 1: Deploy a DaemonSet**  
```yaml
apiVersion: apps/v1
kind: DaemonSet
spec:
  template:
    spec:
      containers:
      - name: log-collector
        image: fluentd
```

---

### 7. Static Pods (Day 13)
Run pods directly on nodes via manifest files.

---

**Hands-on 1: Deploy a Static Pod**  
- Place the manifest in `/etc/kubernetes/manifests/`.

---

### 8. Multiple Schedulers (Day 14-15)
Run custom schedulers alongside the default.

---

**Hands-on 1: Deploy a Second Scheduler**  
```bash
kubectl apply -f custom-scheduler.yaml
```

---

### End-to-End Project (Day 16-18)  
Combine all concepts to create a resilient, multi-node application deployment.

