### **41. Restricting Access to Custom CRDs (Custom Resource Definitions)**  
- **What it does:**  
  Grants specific roles access to manage custom resources without exposing standard Kubernetes resources.  

**Example (Role for Managing CRDs):**  
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: custom-crd
  name: crd-manager
rules:
- apiGroups: ["example.com"]  # Custom API group for CRD
  resources: ["widgets"]
  verbs: ["get", "list", "create", "update"]
```
- **Use Case:**  
  - Developers can manage custom resources (`widgets`) while maintaining isolation from native Kubernetes resources.  

---

### **42. Enforcing ResourceQuota Policies with RBAC**  
- **What it does:**  
  Restricts developers from modifying `ResourceQuota` or `LimitRange` objects, ensuring only cluster admins can change resource limits.  

**Example (Quota Protection Role):**  
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: dev
  name: quota-protector
rules:
- apiGroups: [""]
  resources: ["resourcequotas", "limitranges"]
  verbs: []
```
- **Use Case:**  
  - Prevents users from bypassing resource quotas by blocking all modification attempts, ensuring compliance with resource policies.  

---

### **43. Enforcing PodSecurityPolicy with RBAC**  
- **What it does:**  
  Enforces pod security by granting permissions to apply `PodSecurityPolicy` (PSP) only to specific users.  

**Example (Restricted Pod Security Policy Role):**  
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: security
  name: psp-user
rules:
- apiGroups: ["policy"]
  resources: ["podsecuritypolicies"]
  verbs: ["use"]
  resourceNames: ["restricted-psp"]
```
- **Use Case:**  
  - Developers can only apply predefined `PodSecurityPolicy` (e.g., `restricted-psp`), ensuring security compliance for deployed workloads.  

---

### **44. Controlling Dynamic Admission Controllers**  
- **What it does:**  
  Grants permissions to manage `MutatingWebhookConfiguration` and `ValidatingWebhookConfiguration` for dynamic admission control.  

**Example (Webhook Manager Role):**  
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: kube-system
  name: webhook-manager
rules:
- apiGroups: ["admissionregistration.k8s.io"]
  resources: ["validatingwebhookconfigurations", "mutatingwebhookconfigurations"]
  verbs: ["get", "create", "update", "delete"]
```
- **Use Case:**  
  - Security teams can create and update webhooks for dynamic policy enforcement without accessing the entire cluster.  

---

### **45. Isolating Logs by Namespace (EKS/AKS/GKE)**  
- **What it does:**  
  Restricts access to application logs based on namespaces by controlling access to `events` and `logs`.  

**Example (Log Reader Role):**  
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: logging
  name: log-reader
rules:
- apiGroups: [""]
  resources: ["events"]
  verbs: ["get", "list"]
- apiGroups: ["logging"]
  resources: ["logs"]
  verbs: ["get"]
```
- **Use Case:**  
  - Developers can access logs for debugging in their namespace without viewing cluster-wide logs.  

---

### **46. Temporary Namespace Access (Self-Service Namespace Creation)**  
- **What it does:**  
  Enables developers to create temporary namespaces for testing, with automated cleanup using `CronJob`.  

**Example (Temporary Namespace Creator Role):**  
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: temp-namespace-creator
rules:
- apiGroups: [""]
  resources: ["namespaces"]
  verbs: ["create"]
```
**Namespace Cleanup (CronJob):**  
```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: namespace-cleaner
spec:
  schedule: "0 6 * * *"  # Daily at 6 AM
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: cleaner
            image: bitnami/kubectl
            command:
            - kubectl
            - delete
            - namespace
            - --selector=temp=true
          restartPolicy: OnFailure
```
- **Use Case:**  
  - Developers can create temporary namespaces for testing, which are automatically deleted after a set time.  

---

### **47. Limiting Ingress Controller Configuration Access**  
- **What it does:**  
  Restricts who can modify `Ingress` resources to prevent unauthorized traffic routing changes.  

**Example (Ingress Manager Role):**  
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: frontend
  name: ingress-manager
rules:
- apiGroups: ["networking.k8s.io"]
  resources: ["ingresses"]
  verbs: ["get", "create", "update", "delete"]
```
- **Use Case:**  
  - Only networking teams can configure ingress rules, ensuring that routing is secured and not accidentally misconfigured.  

---

### **48. Advanced Namespace Quota with Sub-Namespaces**  
- **What it does:**  
  Enforces quota management across parent and child namespaces to manage multi-tenancy environments.  

**Example (Quota Role with Sub-Namespaces):**  
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: team-a
  name: quota-manager
rules:
- apiGroups: [""]
  resources: ["resourcequotas"]
  verbs: ["create", "get", "list"]
```
- **Use Case:**  
  - Team leads can set quotas for sub-namespaces, preventing resource hogging by sub-teams.  

---

### **49. Managing Kubernetes Jobs (Batch API Access)**  
- **What it does:**  
  Grants permissions to manage Kubernetes Jobs and CronJobs for automated task scheduling.  

**Example (Job Manager Role):**  
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: batch
  name: job-manager
rules:
- apiGroups: ["batch"]
  resources: ["jobs", "cronjobs"]
  verbs: ["get", "create", "update", "delete"]
```
- **Use Case:**  
  - Developers can create and manage batch processing jobs while maintaining separation from application deployments.  

---

### **50. Restricting Persistent Volume Expansion**  
- **What it does:**  
  Prevents unauthorized users from expanding Persistent Volumes (PVs) beyond defined limits.  

**Example (PV Expansion Role):**  
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: storage
  name: pv-expander
rules:
- apiGroups: [""]
  resources: ["persistentvolumeclaims"]
  verbs: ["update"]
  resourceNames: ["app-pvc"]
```
- **Use Case:**  
  - Storage admins can expand volumes, but developers cannot resize storage by themselves.  
