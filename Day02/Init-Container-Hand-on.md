Let's walk through a hands-on example of creating a pod with an **init container** in Kubernetes. This example will involve using an init container to check if an external service (like a database) is ready before starting the main application container.

---

### **Step-by-Step Example: Creating a Pod with an Init Container**

We will create a pod with two containers:
- An **init container** that waits for a mock database service to be available.
- A **main container** that runs an Nginx server, which starts only after the init container completes its task.

---

### **1. Create the YAML file for the Pod**

Create a YAML file named `pod-with-init.yaml`.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod-with-init
spec:
  # Define the init container
  initContainers:
  - name: init-check-db
    image: busybox
    command: ['sh', '-c', 'until nslookup db-service; do echo waiting for db-service; sleep 2; done;']
  
  # Define the main container
  containers:
  - name: main-app
    image: nginx
    ports:
    - containerPort: 80
```

### **Explanation:**
- **Init container** (`init-check-db`):
  - It uses the `busybox` image.
  - It runs a command that continuously checks (`nslookup`) for the DNS of the `db-service` to become available. If the service is not found, it waits for 2 seconds before checking again. The main container won’t start until this init container completes.
  
- **Main container** (`main-app`):
  - Runs the `nginx` web server.
  - Exposes port 80 for HTTP traffic.

---

### **2. Apply the Pod configuration**

Now, create the pod by applying the YAML configuration:

```bash
kubectl apply -f pod-with-init.yaml
```

### **3. Verify the Pod creation**

Check the status of the pod to see if it is running:

```bash
kubectl get pods
```

Initially, you should see the pod in the `Pending` state because the init container is waiting for the `db-service` to be available. The pod will not proceed to start the main container until the init container successfully completes.

You can also describe the pod to get more detailed information:

```bash
kubectl describe pod pod-with-init
```

In the output, you'll see the status of both the init container and the main container. The init container will repeatedly attempt to check for the `db-service`.

---

### **4. Simulate the `db-service`**

To simulate the external `db-service` the init container is waiting for, you can create a simple Kubernetes service named `db-service`:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: db-service
spec:
  selector:
    app: mock-db
  ports:
  - protocol: TCP
    port: 5432
    targetPort: 5432
---
apiVersion: v1
kind: Pod
metadata:
  name: mock-db
  labels:
    app: mock-db
spec:
  containers:
  - name: mock-db-container
    image: busybox
    command: ['sh', '-c', 'sleep 3600']
```

- **Service**: Exposes the mock database (`db-service`) on port 5432.
- **Mock database pod**: A simple BusyBox container that simulates a running database service by sleeping for an extended period.

Apply this configuration to create the mock service and pod:

```bash
kubectl apply -f db-service.yaml
```

Once the `db-service` is available, the init container in your original pod will detect it and complete its task.

---

### **5. Verify that the Main Container Starts**

After the `db-service` is available, the init container should finish successfully, and the main Nginx container should start.

Check the pod’s status again:

```bash
kubectl get pods
```

The pod should now be in the `Running` state, and you can access the Nginx service running in the main container.

---

### **6. Check the Logs**

To confirm that the init container ran successfully, you can check its logs:

```bash
kubectl logs pod-with-init -c init-check-db
```

This will show the output from the init container as it checked for the `db-service`.

To check the logs for the main container (Nginx):

```bash
kubectl logs pod-with-init -c main-app
```

---

### **7. Cleanup**

After you're done with this exercise, you can clean up the resources by deleting the pod and service:

```bash
kubectl delete pod pod-with-init
kubectl delete pod mock-db
kubectl delete service db-service
```

---

### **Summary**

In this hands-on example, you:
1. Created a pod with an **init container** that waits for an external service (`db-service`) to become available before starting the main Nginx container.
2. Simulated the external `db-service` using a Kubernetes service and pod.
3. Verified that the main container started after the init container completed.
