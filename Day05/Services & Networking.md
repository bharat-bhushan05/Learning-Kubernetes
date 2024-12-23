# Day 5: Services & Networking

## **Overview**
This document serves as a comprehensive guide to understanding and implementing Kubernetes Services and Networking. From beginner-level concepts to advanced troubleshooting, this README is designed to equip you with a thorough understanding of:

1. **Kubernetes Services** (ClusterIP, NodePort, LoadBalancer)
2. **DNS in Kubernetes**
3. **Exposing Services**
4. **Troubleshooting Networking Issues**

---

## **1. What Are Kubernetes Services?**

### **Definition:**
A Kubernetes Service is an abstraction that provides a stable endpoint to access a group of Pods. As Pods are ephemeral, their IP addresses can change, and Services ensure consistent communication between components.

### **Types of Services:**

1. **ClusterIP (Default):**
   - Exposes the service on an internal IP within the cluster.
   - Only accessible from within the cluster.

2. **NodePort:**
   - Exposes the service on a static port on each node's IP.
   - Accessible externally using `<NodeIP>:<NodePort>`.

3. **LoadBalancer:**
   - Creates an external load balancer in cloud environments.
   - Routes external traffic to the service.

4. **ExternalName:**
   - Maps a Kubernetes Service to an external DNS name.
   - Used for accessing external services.

---

## **2. Beginner-Level Hands-On: Setting Up Services**

### **Exercise 1: Create a ClusterIP Service**
#### **Objective:**
Expose a deployment internally using a ClusterIP service.

#### **Steps:**

1. **Deploy an Application:**
   ```bash
   kubectl create deployment internal-app --image=nginx --replicas=3
   ```

2. **Create a ClusterIP Service:**
   ```yaml
   apiVersion: v1
   kind: Service
   metadata:
     name: internal-service
   spec:
     selector:
       app: internal-app
     ports:
       - protocol: TCP
         port: 80
         targetPort: 80
   ```
   Save this file as `clusterip-service.yaml` and apply it:
   ```bash
   kubectl apply -f clusterip-service.yaml
   ```

3. **Test the Service:**
   - Verify the service:
     ```bash
     kubectl get svc internal-service
     ```
   - Access the service from within the cluster:
     ```bash
     kubectl exec -it <pod-name> -- curl internal-service
     ```

---

### **Exercise 2: Create a NodePort Service**
#### **Objective:**
Expose a deployment externally using a NodePort service.

#### **Steps:**

1. **Deploy an Application:**
   ```bash
   kubectl create deployment external-app --image=nginx --replicas=2
   ```

2. **Create a NodePort Service:**
   ```yaml
   apiVersion: v1
   kind: Service
   metadata:
     name: external-service
   spec:
     type: NodePort
     selector:
       app: external-app
     ports:
       - protocol: TCP
         port: 80
         targetPort: 80
         nodePort: 30007
   ```
   Save this file as `nodeport-service.yaml` and apply it:
   ```bash
   kubectl apply -f nodeport-service.yaml
   ```

3. **Access the Service:**
   - Get the Node IP:
     ```bash
     kubectl get nodes -o wide
     ```
   - Access the service using `<NodeIP>:30007` in a browser or via curl.

---

### **Exercise 3: Create a LoadBalancer Service**
#### **Objective:**
Expose an application to the internet using a LoadBalancer service.

#### **Steps:**

1. **Deploy an Application:**
   ```bash
   kubectl create deployment web-app --image=nginx --replicas=3
   ```

2. **Create a LoadBalancer Service:**
   ```yaml
   apiVersion: v1
   kind: Service
   metadata:
     name: web-service
   spec:
     type: LoadBalancer
     selector:
       app: web-app
     ports:
       - protocol: TCP
         port: 80
         targetPort: 80
   ```
   Save this file as `loadbalancer-service.yaml` and apply it:
   ```bash
   kubectl apply -f loadbalancer-service.yaml
   ```

3. **Test the Service:**
   - Get the External IP:
     ```bash
     kubectl get svc web-service
     ```
   - Access the service using the External IP in a browser or via curl.

---

## **3. Intermediate-Level Concepts: Kubernetes DNS**

### **What Is Kubernetes DNS?**
Kubernetes DNS automatically assigns DNS names to Services, making them accessible by name rather than IP.

### **Example:**
- Service Name: `internal-service`
- Namespace: `default`
- Fully Qualified DNS Name: `internal-service.default.svc.cluster.local`

### **Testing DNS Resolution:**

1. Deploy a busybox pod for testing:
   ```bash
   kubectl run busybox --image=busybox --restart=Never -- sleep 3600
   ```

2. Access the busybox pod:
   ```bash
   kubectl exec -it busybox -- sh
   ```

3. Test DNS Resolution:
   ```bash
   nslookup internal-service
   ```

---

## **4. Advanced Hands-On: Network Policies**

### **Objective:**
Control communication between Pods using Network Policies.

### **Steps:**

1. **Create a Namespace:**
   ```bash
   kubectl create namespace network-policy-test
   ```

2. **Deploy Two Applications:**
   ```bash
   kubectl run app1 --image=nginx --namespace=network-policy-test
   kubectl run app2 --image=nginx --namespace=network-policy-test
   ```

3. **Apply a Network Policy:**
   ```yaml
   apiVersion: networking.k8s.io/v1
   kind: NetworkPolicy
   metadata:
     name: allow-app1
     namespace: network-policy-test
   spec:
     podSelector:
       matchLabels:
         run: app1
     ingress:
       - from:
           - podSelector:
               matchLabels:
                 run: app2
   ```
   Save this as `network-policy.yaml` and apply it:
   ```bash
   kubectl apply -f network-policy.yaml
   ```

4. **Test Connectivity:**
   - Exec into `app2` pod and curl `app1`:
     ```bash
     kubectl exec -it <app2-pod> -- curl app1
     ```

---

## **5. Troubleshooting Networking Issues**

### **Issue 1: Service Not Accessible**
#### **Diagnosis:**
1. Check if the Pods are running:
   ```bash
   kubectl get pods -l app=<app-name>
   ```

2. Verify the service details:
   ```bash
   kubectl describe svc <service-name>
   ```

3. Inspect Pod logs:
   ```bash
   kubectl logs <pod-name>
   ```

#### **Resolution:**
- Ensure the Service selector matches Pod labels.
- Verify the port and targetPort configuration.

---

### **Issue 2: DNS Resolution Fails**
#### **Diagnosis:**
1. Check CoreDNS logs:
   ```bash
   kubectl logs -n kube-system -l k8s-app=kube-dns
   ```

#### **Resolution:**
1. Ensure CoreDNS Pods are running:
   ```bash
   kubectl get pods -n kube-system
   ```
2. Restart CoreDNS Pods if needed:
   ```bash
   kubectl rollout restart deployment -n kube-system coredns
   ```

---

This README serves as a comprehensive guide to mastering Kubernetes Services and Networking. Follow the exercises and troubleshooting steps to build expertise from beginner to advanced levels.
