**Types of Kubernetes Admission Controllers**, including their purpose, behavior, and use cases:

---

### **1. Admission Controller Categories**
Admission controllers are divided into **three categories** based on their functionality:
1. **Validating Admission Controllers**  
   - **Check** requests against policies and **reject** non-compliant requests.
   - Example: Enforcing resource limits or security policies.
2. **Mutating Admission Controllers**  
   - **Modify** requests before persistence (e.g., inject fields, set defaults).
   - Example: Adding labels or default storage classes.
3. **Hybrid Controllers**  
   - Perform both validation and mutation.
   - Example: `NamespaceLifecycle` (mutates namespace deletion requests and validates new resources).

---

### **2. Built-in Admission Controllers**
These are compiled into the Kubernetes API server and enabled via the `--enable-admission-plugins` flag. Below are key controllers grouped by type:

---

#### **A. Validating Controllers**
| Controller                          | Description                                                                                     | Enabled by Default? |
|-------------------------------------|-------------------------------------------------------------------------------------------------|---------------------|
| **`AlwaysAdmit`**                   | Allows all requests (used for testing).                                                        | No                  |
| **`AlwaysDeny`**                    | Denies all requests (used for testing).                                                        | No                  |
| **`EventRateLimit`**                | Limits the number of events created per second to prevent API overload.                         | No                  |
| **`PodSecurity`**                   | Enforces Pod security standards (replaces deprecated `PodSecurityPolicy`).                      | Yes (v1.25+)       |
| **`ResourceQuota`**                 | Enforces namespace-level quotas for CPU, memory, and object counts.                            | Yes                 |
| **`LimitRanger`**                   | Enforces default resource requests/limits for Pods.                                             | Yes                 |

---

#### **B. Mutating Controllers**
| Controller                          | Description                                                                                     | Enabled by Default? |
|-------------------------------------|-------------------------------------------------------------------------------------------------|---------------------|
| **`DefaultStorageClass`**           | Adds a default storage class to PersistentVolumeClaims (PVCs) if none is specified.             | Yes                 |
| **`DefaultTolerationSeconds`**      | Adds default tolerations for `notready:NoExecute` and `unreachable:NoExecute` taints.           | Yes                 |
| **`MutatingAdmissionWebhook`**      | Triggers external webhooks to modify requests (part of dynamic admission control).              | Yes                 |
| **`NamespaceAutoProvision`**        | Automatically creates namespaces if they don’t exist (deprecated in favor of `NamespaceLifecycle`). | No           |

---

#### **C. Hybrid Controllers (Validation + Mutation)**
| Controller                          | Description                                                                                     | Enabled by Default? |
|-------------------------------------|-------------------------------------------------------------------------------------------------|---------------------|
| **`NamespaceLifecycle`**            | - **Validates**: Rejects Pods in terminating namespaces. <br> - **Mutates**: Automatically creates `default`, `kube-public`, and `kube-system` namespaces. | Yes |
| **`ServiceAccount`**                | - **Mutates**: Adds a default service account to Pods. <br> - **Validates**: Ensures service accounts exist. | Yes |
| **`NodeRestriction`**               | - **Validates**: Restricts node modifications to the node’s own object. <br> - **Mutates**: Adds labels/taints to nodes. | Yes |

---

#### **D. Security-Focused Controllers**
| Controller                          | Description                                                                                     | Enabled by Default? |
|-------------------------------------|-------------------------------------------------------------------------------------------------|---------------------|
| **`AlwaysPullImages`**              | Forces image pull policy to `Always` to prevent stale image versions.                           | No                  |
| **`DenyServiceExternalIPs`**        | Blocks Services from using `externalIPs` (security risk).                                       | Yes                 |
| **`PodNodeSelector`**               | Restricts Pod node selectors based on namespace annotations.                                    | No                  |
| **`CertificateApproval`**           | Validates CertificateSigningRequest (CSR) approvals.                                            | Yes                 |

---

### **3. Dynamic Admission Controllers**
These use **webhooks** to extend Kubernetes with custom logic. They are not compiled into the API server but configured via CRDs:

| Controller                          | Type       | Description                                                                 |
|-------------------------------------|------------|-----------------------------------------------------------------------------|
| **`ValidatingAdmissionWebhook`**    | Validating | Triggers external HTTP servers to validate requests (e.g., custom policies).|
| **`MutatingAdmissionWebhook`**      | Mutating   | Triggers external HTTP servers to modify requests (e.g., inject sidecars).  |

---

### **4. Deprecated Controllers**
| Controller                          | Replacement                     | Deprecation Reason                                              |
|-------------------------------------|---------------------------------|-----------------------------------------------------------------|
| **`PodSecurityPolicy`**             | `PodSecurity` Admission Controller | Complexity and usability issues.                              |
| **`Initializers`**                  | Admission Webhooks              | Superseded by webhooks for dynamic admission control.           |

---

### **5. Example Use Cases**
1. **Enforcing Security**  
   - Use `PodSecurity` to block privileged containers.
   - Use `AlwaysPullImages` to prevent image tampering.
2. **Resource Management**  
   - Use `ResourceQuota` to limit namespace-level resources.
   - Use `LimitRanger` to set default CPU/memory requests.
3. **Cost Control**  
   - Use `EventRateLimit` to prevent API server overload.
4. **Custom Logic**  
   - Use `MutatingAdmissionWebhook` to inject Istio sidecars.
   - Use `ValidatingAdmissionWebhook` to enforce custom tagging policies.

---

### **6. Enabling Admission Controllers**
To enable controllers, modify the Kubernetes API server manifest:
```yaml
# /etc/kubernetes/manifests/kube-apiserver.yaml
spec:
  containers:
  - command:
    - kube-apiserver
    - --enable-admission-plugins=NamespaceLifecycle,ResourceQuota,LimitRanger,PodSecurity
    - --disable-admission-plugins=DenyEscalatingExec
```

---

### **7. Key Considerations**
- **Order of Execution**: Mutating controllers run before validating controllers.
- **Performance**: Each controller adds latency to API requests.
- **Compatibility**: Some controllers are enabled by default; others require manual configuration.

---

### **Conclusion**
Admission controllers are critical for securing and customizing Kubernetes clusters. Use built-in controllers for common policies (e.g., `PodSecurity`, `ResourceQuota`) and dynamic webhooks for bespoke requirements. Always test configurations in non-production environments to avoid breaking API interactions.
