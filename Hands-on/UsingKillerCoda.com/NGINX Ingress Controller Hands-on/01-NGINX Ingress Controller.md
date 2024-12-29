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


---

## **Part 8: Advanced Ingress Configuration**

### **1. Rate Limiting with NGINX Ingress Controller**

You can use annotations to configure rate limiting on your services. This can help protect your services from being overwhelmed by too many requests in a short period.

#### **Steps to enable Rate Limiting**:

1. **Modify your Ingress YAML** to include rate limiting annotations:
```yaml
# ingress-rate-limiting.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: app-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    nginx.ingress.kubernetes.io/limit-concurrency: "1" # Limit the concurrency
    nginx.ingress.kubernetes.io/limit-rps: "5" # Max 5 requests per second
    nginx.ingress.kubernetes.io/limit-burst: "10" # Allow burst of up to 10 requests
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

2. **Apply the changes**:
```bash
kubectl apply -f ingress-rate-limiting.yaml
```

3. **Test the rate limiting**:  
You can use `curl` or any HTTP client to test the rate limiting. Make rapid requests and observe the behavior.

```bash
# Test with rapid requests
for i in {1..20}; do curl -s http://killercoda.local/app1; done
```

You should see some requests being rate-limited.

---

### **2. Custom Error Pages with NGINX Ingress**

Custom error pages allow you to display a user-friendly page instead of default error messages for common HTTP status codes (like 404 or 500).

#### **Steps to configure Custom Error Pages**:

1. **Create a custom error page** (e.g., an HTML page with a message).  
Upload this error page to your Kubernetes cluster or host it on an external server.

2. **Update the Ingress YAML** to include error page annotations:
```yaml
# ingress-with-error-pages.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: app-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    nginx.ingress.kubernetes.io/custom-http-errors: "404,500"
    nginx.ingress.kubernetes.io/custom-error-page-404: "http://my-external-error-page.com/404.html"
    nginx.ingress.kubernetes.io/custom-error-page-500: "http://my-external-error-page.com/500.html"
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
```

3. **Apply the changes**:
```bash
kubectl apply -f ingress-with-error-pages.yaml
```

4. **Test the custom error page**:  
To trigger an error, you can request an invalid path or test the application with downtime.
```bash
curl http://killercoda.local/invalid-path
```
You should see your custom 404 error page.

---

### **3. JWT Authentication with NGINX Ingress Controller**

JWT (JSON Web Tokens) can be used to secure access to your services. With NGINX Ingress Controller, you can set up JWT authentication for your Ingress resources to only allow authorized users to access the application.

#### **Steps to configure JWT authentication**:

1. **Create a Secret for JWT Configuration** (e.g., public key or shared secret).

   For this demo, assume we are using a shared secret for JWT verification:
```bash
kubectl create secret generic jwt-secret --from-literal=jwt-secret="my-jwt-secret-key"
```

2. **Update your Ingress YAML to include JWT Authentication annotations**:
```yaml
# ingress-jwt-auth.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: app-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    nginx.ingress.kubernetes.io/auth-url: "http://nginx-ingress-controller.com/authenticate"
    nginx.ingress.kubernetes.io/auth-signin: "https://your-auth-server.com/oauth2/authorize?redirect_uri=https://killercoda.local/app1"
    nginx.ingress.kubernetes.io/auth-response-headers: "Authorization"
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
```

3. **Apply the changes**:
```bash
kubectl apply -f ingress-jwt-auth.yaml
```

4. **Test JWT Authentication**:  
To test JWT authentication, ensure you have a valid token and then try accessing the service:
```bash
curl -H "Authorization: Bearer <your-jwt-token>" http://killercoda.local/app1
```
You should be able to access the service if the JWT is valid; otherwise, the request will be denied.

---

## **Summary of Annotations**:

- **Rate Limiting**:
  - `nginx.ingress.kubernetes.io/limit-concurrency`: Limits the number of simultaneous connections.
  - `nginx.ingress.kubernetes.io/limit-rps`: Limits the number of requests per second.
  - `nginx.ingress.kubernetes.io/limit-burst`: Allows a burst of requests beyond the rate limit.

- **Custom Error Pages**:
  - `nginx.ingress.kubernetes.io/custom-http-errors`: Defines which error codes should trigger custom pages.
  - `nginx.ingress.kubernetes.io/custom-error-page-<code>`: URL for the custom error page.

- **JWT Authentication**:
  - `nginx.ingress.kubernetes.io/auth-url`: The URL where the JWT can be validated.
  - `nginx.ingress.kubernetes.io/auth-signin`: URL for redirecting unauthenticated users.
  - `nginx.ingress.kubernetes.io/auth-response-headers`: Specifies which headers to return from the authentication service.

---

### **Conclusion**

These advanced NGINX Ingress Controller features allow you to:
- Apply rate limiting to prevent abuse of your services.
- Serve custom error pages to enhance user experience.
- Secure your services with JWT authentication.

