# Day 6: Namespaces in Kubernetes

## **Overview**
Namespaces in Kubernetes are a way to divide cluster resources between multiple users or teams. They provide a mechanism for:

- **Resource Isolation:** Allowing separate environments for development, testing, and production.
- **Access Control:** Assigning permissions and policies to specific namespaces.
- **Resource Quotas:** Limiting resource usage per namespace.

This guide will take you from understanding the basics of namespaces to advanced concepts and practical applications.

---

## **1. What Are Namespaces?**

### **Definition:**
A namespace is a Kubernetes object that provides a virtual cluster within a physical cluster. Each namespace has its own:

- Pods
- Services
- Deployments
- ConfigMaps and Secrets

### **Predefined Namespaces:**
1. **default:** The default namespace for objects with no specified namespace.
2. **kube-system:** Used for Kubernetes system components like the API server and scheduler.
3. **kube-public:** Publicly accessible data, such as the cluster's `public-info` ConfigMap.
4. **kube-node-lease:** For node heartbeat data.

### **Use Cases:**
- Creating isolated environments for different projects or teams.
- Managing different stages of development (e.g., dev, staging, prod).
- Implementing resource constraints.

---

## **2. Beginner-Level Hands-On: Working with Namespaces**

### **Exercise 1: Create and Use a Namespace**

#### **Objective:**
Learn how to create and use namespaces.

#### **Steps:**

1. **List Existing Namespaces:**
   ```bash
   kubectl get namespaces
   ```

2. **Create a Namespace:**
   ```bash
   kubectl create namespace dev-environment
   ```

3. **Deploy an Application in the Namespace:**
   ```bash
   kubectl create deployment nginx-app --image=nginx --namespace=dev-environment
   ```

4. **Access Resources in the Namespace:**
   ```bash
   kubectl get pods --namespace=dev-environment
   ```

5. **Set a Default Namespace for kubectl Commands:**
   Edit the kubeconfig context to set a default namespace:
   ```bash
   kubectl config set-context --current --namespace=dev-environment
   ```
   Test the configuration:
   ```bash
   kubectl get pods
   ```

---

## **3. Intermediate-Level Hands-On: Namespace-Specific Resources**

### **Exercise 2: Create Namespace-Specific ConfigMaps and Secrets**

#### **Objective:**
Store configuration data and sensitive information in a namespace.

#### **Steps:**

1. **Create a ConfigMap in the Namespace:**
   ```yaml
   apiVersion: v1
   kind: ConfigMap
   metadata:
     name: app-config
     namespace: dev-environment
   data:
     key1: value1
     key2: value2
   ```
   Apply the file:
   ```bash
   kubectl apply -f configmap.yaml
   ```

2. **Create a Secret in the Namespace:**
   ```yaml
   apiVersion: v1
   kind: Secret
   metadata:
     name: app-secret
     namespace: dev-environment
   type: Opaque
   data:
     username: YWRtaW4=
     password: cGFzc3dvcmQ=
   ```
   Apply the file:
   ```bash
   kubectl apply -f secret.yaml
   ```

3. **Use ConfigMap and Secret in a Pod:**
   ```yaml
   apiVersion: v1
   kind: Pod
   metadata:
     name: app-pod
     namespace: dev-environment
   spec:
     containers:
       - name: app-container
         image: nginx
         env:
           - name: CONFIG_KEY1
             valueFrom:
               configMapKeyRef:
                 name: app-config
                 key: key1
           - name: SECRET_USERNAME
             valueFrom:
               secretKeyRef:
                 name: app-secret
                 key: username
   ```
   Apply the file:
   ```bash
   kubectl apply -f pod.yaml
   ```

---

## **4. Advanced-Level Concepts: Resource Quotas and Limits**

### **Resource Quotas**
#### **Definition:**
Resource quotas restrict the resource consumption within a namespace.

#### **Steps to Apply a Resource Quota:**

1. **Create a Resource Quota:**
   ```yaml
   apiVersion: v1
   kind: ResourceQuota
   metadata:
     name: dev-quota
     namespace: dev-environment
   spec:
     hard:
       pods: "10"
       requests.cpu: "4"
       requests.memory: "8Gi"
       limits.cpu: "8"
       limits.memory: "16Gi"
   ```
   Apply the file:
   ```bash
   kubectl apply -f resource-quota.yaml
   ```

2. **Test Resource Quota:**
   Try creating resources beyond the quota and observe the errors.

### **LimitRanges**
#### **Definition:**
LimitRanges enforce default and maximum resource limits on containers.

#### **Steps to Apply LimitRanges:**

1. **Create a LimitRange:**
   ```yaml
   apiVersion: v1
   kind: LimitRange
   metadata:
     name: resource-limits
     namespace: dev-environment
   spec:
     limits:
       - type: Container
         default:
           cpu: "500m"
           memory: "512Mi"
         defaultRequest:
           cpu: "250m"
           memory: "256Mi"
         max:
           cpu: "2"
           memory: "1Gi"
         min:
           cpu: "100m"
           memory: "128Mi"
   ```
   Apply the file:
   ```bash
   kubectl apply -f limitrange.yaml
   ```

2. **Test LimitRanges:**
   Deploy Pods with varying resource requests and observe the applied limits.

---

## **5. Troubleshooting Namespaces**

### **Common Issues:**

1. **Issue:** Resources are not visible.
   - **Diagnosis:**
     - Check if you are querying the correct namespace:
       ```bash
       kubectl get pods --namespace=<namespace>
       ```
     - Ensure the namespace exists:
       ```bash
       kubectl get namespaces
       ```

2. **Issue:** Namespace deletion is stuck.
   - **Diagnosis:** Check if finalizers are blocking deletion:
     ```bash
     kubectl get namespace <namespace> -o yaml
     ```
   - **Resolution:** Remove finalizers manually if safe:
     ```bash
     kubectl patch namespace <namespace> -p '{"metadata":{"finalizers":null}}'
     ```

---

This guide equips you with foundational and advanced knowledge of Kubernetes namespaces, enabling effective resource management and isolation. Follow the hands-on exercises and troubleshooting steps to master the concept of namespaces.
