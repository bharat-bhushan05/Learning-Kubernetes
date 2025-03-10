# Kubernetes Admission Controllers: A Comprehensive Guide

## Table of Contents
1. [Overview](#overview)
2. [Types of Admission Controllers](#types-of-admission-controllers)
3. [How Admission Controllers Work](#how-admission-controllers-work)
4. [Built-in Admission Controllers](#built-in-admission-controllers)
5. [Dynamic Admission Controllers](#dynamic-admission-controllers)
6. [Use Cases](#use-cases)
7. [Creating a Custom Admission Controller](#creating-a-custom-admission-controller)
8. [Best Practices](#best-practices)
9. [Common Pitfalls](#common-pitfalls)
10. [Debugging Admission Controllers](#debugging-admission-controllers)
11. [Conclusion](#conclusion)

---

## Overview
**Admission Controllers** are plugins that govern and enforce how Kubernetes clusters are used. They intercept requests to the Kubernetes API server after authentication/authorization but before persistence, allowing you to:
- **Validate** requests (e.g., reject non-compliant pods).
- **Mutate** requests (e.g., inject sidecar containers).
- Apply security policies, resource quotas, and more.

---

## Types of Admission Controllers
### 1. **Built-in Admission Controllers**
Enabled via flags in the Kubernetes API server (e.g., `--enable-admission-plugins=NamespaceLifecycle,ResourceQuota`). Examples:
- **`NamespaceLifecycle`**: Prevents resource creation in non-existent namespaces.
- **`ResourceQuota`**: Enforces namespace-level resource limits.
- **`PodSecurity`** (replaces deprecated `PodSecurityPolicy`): Enforces Pod security standards.
- **`DefaultStorageClass`**: Adds a default storage class to PVCs.

### 2. **Dynamic Admission Controllers (Webhooks)**
Extend functionality using external HTTP servers:
- **ValidatingWebhookConfiguration**: Validate requests.
- **MutatingWebhookConfiguration**: Modify requests.

---

## How Admission Controllers Work
### Request Flow
1. **Authentication**: Verify user identity.
2. **Authorization**: Check permissions.
3. **Admission Control**:
   - **Mutating** controllers modify requests (e.g., add labels).
   - **Validating** controllers accept/reject requests.

![API Request Flow](https://miro.medium.com/max/1400/1*3AAH_7hG6qJ5v6j8VSHQSw.png)

---

## Built-in Admission Controllers
| Controller               | Description                                                                 |
|--------------------------|-----------------------------------------------------------------------------|
| `AlwaysPullImages`        | Forces image pull to prevent stale images.                                  |
| `NodeRestriction`         | Limits node permissions for enhanced security.                              |
| `ServiceAccount`          | Automates ServiceAccount setup for pods.                                    |

**Enable/Disable**:
```bash
# Check enabled controllers in kube-apiserver
kubectl -n kube-system get pods -l component=kube-apiserver -o jsonpath='{.items[0].spec.containers[0].command}'
```

---

## Dynamic Admission Controllers
### Webhook Configuration
Example: **ValidatingWebhookConfiguration**
```yaml
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingWebhookConfiguration
metadata:
  name: "pod-validation.example.com"
webhooks:
- name: "pod-validation.example.com"
  rules:
  - apiGroups:   [""]
    apiVersions: ["v1"]
    operations:  ["CREATE", "UPDATE"]
    resources:   ["pods"]
  clientConfig:
    service:
      namespace: "default"
      name: "webhook-service"
      path: "/validate"
      port: 443
    caBundle: "<CA_CERT_BUNDLE>"
  failurePolicy: Fail
  sideEffects: None
  admissionReviewVersions: ["v1"]
```

### Key Fields:
- **`rules`**: Define which API operations/resources to intercept.
- **`failurePolicy`**: Action if the webhook fails (`Ignore` or `Fail`).
- **`sideEffects`**: Whether the webhook has side effects (e.g., `None` for idempotent operations).

---

## Use Cases
1. **Security**:
   - Enforce Pod security policies (e.g., disallow privileged containers).
2. **Cost Control**:
   - Block resource-heavy deployments.
3. **Standardization**:
   - Inject sidecars (e.g., Istio) or labels.
4. **Compliance**:
   - Ensure all images are from trusted registries.

---

## Creating a Custom Admission Controller
### Example: Pod Validating Webhook
**Steps**:
1. **Deploy a Webhook Server**:
   - A HTTPS server handling `/validate` and `/mutate` endpoints.
   - Use TLS certificates signed by the cluster's CA.
2. **Apply Configuration**:
   ```yaml
   # validating-webhook.yaml
   apiVersion: admissionregistration.k8s.io/v1
   kind: ValidatingWebhookConfiguration
   metadata:
     name: "pod-validation.example.com"
   webhooks:
   - name: "pod-validation.example.com"
     # ... (as shown earlier)
   ```
3. **Test**:
   ```bash
   kubectl apply -f pod.yaml
   ```

---

## Best Practices
1. **Idempotency**: Mutating webhooks should handle repeated calls safely.
2. **Failure Policy**: Use `failurePolicy: Ignore` to avoid cluster-wide outages.
3. **Namespace Selectors**: Limit webhook scope to specific namespaces.
4. **Monitoring**: Track metrics (e.g., latency, error rates).

---

## Common Pitfalls
1. **Webhook Deadlock**: A misconfigured webhook blocking its own deployment.
2. **TLS Issues**: Expired/invalid certificates breaking communication.
3. **Performance**: Slow webhooks delaying API requests.

---

## Debugging Admission Controllers
1. **Check API Server Logs**:
   ```bash
   kubectl -n kube-system logs kube-apiserver-<node> | grep admission
   ```
2. **Dry-Run Requests**:
   ```bash
   kubectl apply -f pod.yaml --dry-run=server
   ```
3. **Audit Logs**:
   Enable Kubernetes audit logging to trace admission decisions.

---

## Conclusion
Admission Controllers are critical for enforcing security, compliance, and operational policies in Kubernetes. Whether using built-in controllers or custom webhooks, they provide granular control over cluster behavior. Always test configurations in non-production environments and monitor their impact on API performance.

**Further Reading**:
- [Kubernetes Documentation](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/)
- [Dynamic Admission Control](https://kubernetes.io/blog/2019/03/21/a-guide-to-kubernetes-admission-controllers/)


