Hands-on guide for Kubernetes Ingress and NGINX Ingress Controller that you can practice on **Killercoda**. This tutorial will help you understand the core concepts, set up an NGINX Ingress Controller, and deploy services behind the Ingress.

---

### **Prerequisites**  
- Basic understanding of Kubernetes  
- Killercoda Kubernetes cluster (default Killercoda setup)  
- `kubectl` configured to interact with the cluster  

---

## **Part 1: Setting Up the Kubernetes Cluster on Killercoda**  
1. **Start the Cluster**  
   - Open [Killercoda Kubernetes playground](https://killercoda.com/playgrounds/scenario/kubernetes).  
   - Click **Start Scenario** to launch a Kubernetes cluster.  

2. **Verify Cluster Status**  
   ```bash
   kubectl get nodes
   kubectl cluster-info
   ```

---

## **Part 2: Deploying a Sample Application**  
We will deploy two simple applications (`app1` and `app2`) to demonstrate routing using Ingress.  

### 1. **Deploy App1**  
```yaml
# app1-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app1
spec:
  replicas: 2
  selector:
    matchLabels:
      app: app1
  template:
    metadata:
      labels:
        app: app1
    spec:
      containers:
      - name: app1
        image: hashicorp/http-echo
        args:
        - "-text=Hello from App1"
        ports:
        - containerPort: 5678
---
apiVersion: v1
kind: Service
metadata:
  name: app1-service
spec:
  selector:
    app: app1
  ports:
    - protocol: TCP
      port: 80
      targetPort: 5678
```
```bash
kubectl apply -f app1-deployment.yaml
```

---

### 2. **Deploy App2**  
```yaml
# app2-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app2
spec:
  replicas: 2
  selector:
    matchLabels:
      app: app2
  template:
    metadata:
      labels:
        app: app2
    spec:
      containers:
      - name: app2
        image: hashicorp/http-echo
        args:
        - "-text=Hello from App2"
        ports:
        - containerPort: 5678
---
apiVersion: v1
kind: Service
metadata:
  name: app2-service
spec:
  selector:
    app: app2
  ports:
    - protocol: TCP
      port: 80
      targetPort: 5678
```
```bash
kubectl apply -f app2-deployment.yaml
```

---

## **Part 3: Installing NGINX Ingress Controller**  
1. **Add Ingress-NGINX Repository**  
```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
```

2. **Verify Ingress Controller Deployment**  
```bash
kubectl get pods -n ingress-nginx
kubectl get svc -n ingress-nginx
```
   > Look for `ingress-nginx-controller` running and exposed via a service.  

---

## **Part 4: Create Ingress Resources**  
1. **Create Ingress for App1 and App2**  
```yaml
# ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: app-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
  - host: killercoda.local
    http:
      paths:
      - path: /app1
        pathType: Prefix
        backend:
          service:
            name: app1-service
            port:
              number: 80
      - path: /app2
        pathType: Prefix
        backend:
          service:
            name: app2-service
            port:
              number: 80
```
```bash
kubectl apply -f ingress.yaml
```

---

## **Part 5: Testing Ingress**  
1. **Get the Ingress IP**  
```bash
kubectl get ingress
```
   > Note the external IP of the Ingress.  

2. **Add Entry to Hosts File (Local Testing on Killercoda)**  
```bash
echo "127.0.0.1 killercoda.local" | sudo tee -a /etc/hosts
```

3. **Test Routing**  
```bash
curl http://killercoda.local/app1
curl http://killercoda.local/app2
```
   - `app1` should return: **Hello from App1**  
   - `app2` should return: **Hello from App2**  

---

## **Part 6: Advanced Ingress Configuration**  

### 1. **Enabling HTTPS with Self-Signed Certificate**  
```bash
kubectl create secret tls app-tls --cert=/path/to/tls.crt --key=/path/to/tls.key
```
Modify `ingress.yaml` to enable TLS:  
```yaml
spec:
  tls:
  - hosts:
    - killercoda.local
    secretName: app-tls
  rules:
  - host: killercoda.local
    http:
      paths:
      - path: /app1
        pathType: Prefix
        backend:
          service:
            name: app1-service
            port:
              number: 80
```
```bash
kubectl apply -f ingress.yaml
```
Test with HTTPS:  
```bash
curl -k https://killercoda.local/app1
```

---

## **Part 7: Troubleshooting Tips**  
1. **Check Ingress Logs**  
```bash
kubectl logs -n ingress-nginx -l app.kubernetes.io/name=ingress-nginx
```
2. **Describe Ingress**  
```bash
kubectl describe ingress app-ingress
```
3. **Check Service and Pod**  
```bash
kubectl get svc
kubectl get pods
```

---

## **Key Concepts Covered:**  
- Deploying applications in Kubernetes  
- Configuring services to expose applications  
- Installing and configuring NGINX Ingress Controller  
- Creating Ingress rules for path-based routing  
- Testing and troubleshooting Ingress  
