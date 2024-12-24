Here are additional advanced RBAC scenarios to further challenge your understanding of Kubernetes security and access management. These scenarios include troubleshooting access issues, fine-grained control with labels, managing user access in multi-cluster environments, and implementing custom authorization policies.

---

## **Scenario 24: Troubleshooting RBAC Access Denied Errors**

In real-world environments, RBAC misconfigurations can cause access issues. This scenario focuses on troubleshooting and resolving a common `access denied` error.

### **Step 1: Simulate Access Denied**

Assume that a service account is attempting to access a resource it shouldn't have permission to.

```bash
kubectl auth can-i get pods --as=system:serviceaccount:default:unknown-sa
```

Expected Output:

```bash
no
```

### **Step 2: Check RBAC Bindings and Roles**

Check if the service account has any associated roles:

```bash
kubectl get rolebindings,clusterrolebindings -A | grep unknown-sa
```

This will show you whether the service account has any roles bound to it.

### **Step 3: Review Role or ClusterRole**

If no role bindings exist, create a role for the service account. For example, a role to read pods in the `default` namespace:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-reader
  namespace: default
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list"]
```

Apply the role:

```bash
kubectl apply -f pod-reader-role.yaml
```

### **Step 4: Create RoleBinding**

If no rolebinding exists, create one to bind the role to the service account:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: pod-reader-binding
  namespace: default
subjects:
- kind: ServiceAccount
  name: unknown-sa
  namespace: default
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```

Apply the `RoleBinding`:

```bash
kubectl apply -f pod-reader-binding.yaml
```

### **Step 5: Re-run the Test**

Test again if the service account has access to the pods:

```bash
kubectl auth can-i get pods --as=system:serviceaccount:default:unknown-sa
```

Expected Output:

```bash
yes
```

By following these troubleshooting steps, you can resolve many common `RBAC access denied` errors in Kubernetes.

---

## **Scenario 25: Fine-grained Access Control Using Label Selectors**

Sometimes you may want to give users access to only a subset of resources that match a specific label. This scenario demonstrates how to use label selectors in RBAC rules.

### **Step 1: Create a Namespace**

```bash
kubectl create namespace production
```

### **Step 2: Label Resources**

Label a pod within the `production` namespace to make it distinguishable:

```bash
kubectl run app-pod --image=nginx --namespace=production --labels="app=webserver"
```

### **Step 3: Define Role with Label Selectors**

Create a `Role` that only allows access to pods with a specific label in the `production` namespace:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: label-specific-pod-reader
  namespace: production
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list"]
  resourceNames: []
  # Allow only pods with the label "app=webserver"
  labelSelector:
    matchLabels:
      app: webserver
```

Apply the `Role`:

```bash
kubectl apply -f label-specific-pod-reader-role.yaml
```

### **Step 4: Bind Role to a Service Account**

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: label-specific-pod-reader-binding
  namespace: production
subjects:
- kind: ServiceAccount
  name: developer-sa
  namespace: production
roleRef:
  kind: Role
  name: label-specific-pod-reader
  apiGroup: rbac.authorization.k8s.io
```

Apply the `RoleBinding`:

```bash
kubectl apply -f label-specific-pod-reader-binding.yaml
```

### **Step 5: Test Access for Service Account**

Test if the service account can access the labeled pods:

```bash
kubectl auth can-i get pods -n production --as=system:serviceaccount:production:developer-sa
```

Expected Output:

```bash
yes
```

If there are no pods matching the label `app=webserver`, access will be denied.

---

## **Scenario 26: Multi-cluster RBAC Access Management**

In multi-cluster environments, managing access across clusters can become complex. This scenario focuses on managing RBAC in multiple Kubernetes clusters.

### **Step 1: Set Up Two Kubernetes Clusters**

For simplicity, assume you have two clusters: `cluster-a` and `cluster-b`. You can manage access to resources in both clusters via `kubectl` contexts.

### **Step 2: Set Up `kubectl` Contexts for Both Clusters**

```bash
kubectl config use-context cluster-a
kubectl config use-context cluster-b
```

### **Step 3: Create ClusterRole and RoleBindings in Each Cluster**

1. **In Cluster A**: Create a `ClusterRole` to allow viewing pods and a `RoleBinding` for users in the `cluster-a-users` namespace.

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: pod-viewer
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list"]
```

2. **In Cluster B**: Create the same `ClusterRole` and a `RoleBinding` for users in the `cluster-b-users` namespace.

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: pod-viewer
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list"]
```

### **Step 4: Bind the ClusterRole to Specific Users**

Create `ClusterRoleBinding` in each cluster:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: pod-viewer-binding
subjects:
- kind: User
  name: external-user
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: pod-viewer
  apiGroup: rbac.authorization.k8s.io
```

Apply the `ClusterRoleBinding` in both clusters.

### **Step 5: Access Resources Across Clusters**

Switch between clusters and test if the `external-user` can access the `pods` in both clusters.

```bash
kubectl auth can-i get pods --as=external-user --context=cluster-a
kubectl auth can-i get pods --as=external-user --context=cluster-b
```

Expected Output:

```bash
yes
yes
```

This demonstrates how to manage multi-cluster access with RBAC.

---

## **Scenario 27: Implementing Custom Authorization with Admission Controllers**

In some cases, you may need to enforce custom authorization rules. Admission Controllers can help enforce policies that extend Kubernetes' default RBAC behavior.

### **Step 1: Create a Custom Admission Controller**

Let's create an `AdmissionController` to enforce that all pods created must have a `team` label.

1. **Create a webhook server** that validates pod creation requests and ensures that the `team` label exists.

2. The webhook server would listen to pod creation events and reject those without the required `team` label.

### **Step 2: Deploy the Admission Controller**

Deploy the webhook server that will validate the pod creation request:

```bash
kubectl apply -f admission-controller-webhook.yaml
```

### **Step 3: Create a ValidatingWebhookConfiguration**

```yaml
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingWebhookConfiguration
metadata:
  name: validate-team-labels
webhooks:
- name: validate-team-labels.k8s.io
  clientConfig:
    url: https://admission-controller-server/validate
    caBundle: <ca-cert>
  rules:
  - operations: ["CREATE"]
    apiGroups: [""]
    apiVersions: ["v1"]
    resources: ["pods"]
  admissionReviewVersions: ["v1"]
  sideEffects: None
```

### **Step 4: Test the Admission Controller**

Try creating a pod without the `team` label:

```bash
kubectl run myapp-pod --image=nginx --labels="app=webserver"
```

The pod creation should be rejected by the admission controller.

### **Step 5: Create a Valid Pod with the Team Label**

```bash
kubectl run myapp-pod --image=nginx --labels="app=webserver,team=devops"
```

This pod creation should be allowed, demonstrating the use of custom admission controllers for enforcing policies.

---

## **Scenario 28: Using External Identity Providers (OIDC)**

In some environments, you may want to use external identity providers (OIDC, LDAP) to authenticate users. Kubernetes supports OIDC as a way to integrate external identity providers for user authentication.

### **Step 1: Set Up OIDC Provider**

Set up an OIDC provider (e.g., Google Identity, AWS Cognito, or any OpenID-compliant provider).

### **Step 2: Configure Kubernetes to Use OIDC**

Configure the Kubernetes API server with the OIDC provider details (this requires admin access to the Kubernetes cluster).

```yaml
apiServer:
  oidc-issuer-url: https://accounts.google.com
  oidc-client-id: <client-id>
  oidc-ca-file: /path/to/ca.pem
  oidc-username-claim: email
  oidc-groups-claim: groups
```

### **Step 3: Create RoleBindings Based on Groups**

Once OIDC is set up, you can bind groups to Kubernetes roles. For example:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-binding
subjects:
- kind: Group
  name: admins
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: cluster-admin
  apiGroup: rbac.authorization.k8s.io
```

### **Step 4: Verify Authentication and Access**

Once the OIDC provider is set up, users will authenticate using the external identity provider, and you can assign them roles based on their group membership.

---

## **Conclusion**

These advanced scenarios offer deeper insights into managing RBAC for complex, multi-cluster, and external-identity-based environments. They cover:

- Troubleshooting RBAC errors.
- Fine-grained access control using labels.
- Managing access across multiple Kubernetes clusters.
- Implementing custom authorization policies using admission controllers.
- Integrating external identity providers for authentication.

These hands-on exercises provide the tools necessary to manage RBAC in production Kubernetes environments with precision and security.
