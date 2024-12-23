# Kubernetes: Day 4 - Deployments

## **Overview**
In this session, we will focus on Kubernetes Deployments, including creating, scaling, updating, and rolling back Deployments. Deployments provide a powerful way to manage application workloads and ensure application availability.

---

## **1. Objectives**
- Understand the role of Deployments in Kubernetes.
- Learn how to create and manage Deployments.
- Perform updates and rollbacks to ensure application stability.

---

## **2. What is a Deployment?**
A Deployment in Kubernetes is a higher-level concept that provides declarative updates for Pods and ReplicaSets. It ensures:

1. **High availability**: Deployments maintain the desired number of replicas for Pods, automatically replacing failed instances.
2. **Declarative management**: You can define the desired state of your application, and Kubernetes will work to match it.
3. **Rolling updates**: Deployments enable zero-downtime updates by rolling out changes gradually.
4. **Rollbacks**: If an update introduces an error, you can roll back to a previous stable state.

---

## **3. Commands Overview**

Here are some key `kubectl` commands we will use:
- `kubectl create deployment` - Create a new Deployment.
- `kubectl apply` - Apply changes from a YAML file.
- `kubectl rollout` - Manage Deployment rollouts.
- `kubectl scale` - Scale up or down the number of replicas.

---

## **4. Hands-On Activities**

### **Step 1: Create a Deployment**

#### **YAML Definition**
Create a file named `deployment.yaml` with the following content:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
      - name: my-app-container
        image: nginx:1.21
        ports:
        - containerPort: 80
```

#### **Apply the Deployment**
Execute the following command to create the Deployment:
```bash
kubectl apply -f deployment.yaml
```

#### **Verify Deployment**
Check the status of the Deployment and the Pods:
```bash
kubectl get deployments
kubectl get pods
```

### **Step 2: Scale the Deployment**

Scaling a Deployment adjusts the number of replicas for the application.

#### **Scale to 5 Replicas**
Run the following command:
```bash
kubectl scale deployment my-app-deployment --replicas=5
```

#### **Verify Scaling**
Check the updated number of Pods:
```bash
kubectl get pods
```
You should see 5 running Pods.

### **Step 3: Update the Deployment**

Updating a Deployment allows you to change the application configuration or image.

#### **Update the Image**
Update the container image to a newer version using this command:
```bash
kubectl set image deployment/my-app-deployment my-app-container=nginx:1.22
```

#### **Monitor the Rollout**
Monitor the progress of the update:
```bash
kubectl rollout status deployment my-app-deployment
```

### **Step 4: Perform a Rollback**

If the update introduces an issue, you can roll back to the previous stable state.

#### **Check Revision History**
View the Deployment's revision history:
```bash
kubectl rollout history deployment my-app-deployment
```

#### **Rollback to Previous Version**
Roll back to the previous revision:
```bash
kubectl rollout undo deployment my-app-deployment
```

#### **Verify Rollback**
Ensure the Pods are running the previous version:
```bash
kubectl get pods
```

---

## **5. Summary**

- **Deployments** are a powerful tool for managing application workloads in Kubernetes.
- They support declarative updates, scaling, and rollbacks, ensuring reliability and availability.
- Key operations include creating, updating, scaling, and rolling back Deployments.

By mastering Deployments, you gain significant control over the lifecycle of your Kubernetes applications.

---

## **6. Additional Resources**
- [Kubernetes Official Documentation: Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
