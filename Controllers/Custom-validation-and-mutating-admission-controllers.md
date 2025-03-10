Creating custom **validation** and **mutating admission controllers** in Kubernetes involves writing **admission webhook servers** that intercept API requests and enforce custom policies. Below is a step-by-step guide with code examples and detailed explanations.

---

### **1. Overview**
- **Validating Webhook**: Accepts/rejects requests based on custom logic (e.g., "Pods must have a specific label").
- **Mutating Webhook**: Modifies requests before they are persisted (e.g., "Inject a sidecar container into all Pods").
- **Webhook Server**: An HTTPS server that handles admission requests from the Kubernetes API server.

---

### **2. Prerequisites**
1. A Kubernetes cluster (v1.16+ for `admissionregistration.k8s.io/v1`).
2. Tools: `kubectl`, `openssl`, and a programming language (e.g., Go, Python).
3. **TLS Certificates**: Webhook servers must use HTTPS with a CA-signed certificate.

---

### **3. Step-by-Step Implementation**

#### **A. Generate TLS Certificates**
Use `openssl` to create a Certificate Authority (CA) and sign a server certificate:
```bash
# Generate CA key and cert
openssl genrsa -out ca.key 2048
openssl req -x509 -new -nodes -key ca.key -subj "/CN=admission-ca" -days 365 -out ca.crt

# Generate server key and CSR
openssl genrsa -out server.key 2048
openssl req -new -key server.key -subj "/CN=admission-webhook.default.svc" -out server.csr

# Sign the server certificate with the CA
openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt -days 365
```

#### **B. Deploy the Webhook Server**
Create a Kubernetes `Deployment` and `Service` for the webhook server:
```yaml
# webhook-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: admission-webhook
spec:
  replicas: 1
  selector:
    matchLabels:
      app: admission-webhook
  template:
    metadata:
      labels:
        app: admission-webhook
    spec:
      containers:
      - name: webhook
        image: my-webhook-server:latest
        ports:
        - containerPort: 443
        volumeMounts:
        - name: cert
          mountPath: /etc/certs
          readOnly: true
      volumes:
      - name: cert
        secret:
          secretName: webhook-cert
---
# webhook-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: admission-webhook
spec:
  selector:
    app: admission-webhook
  ports:
  - port: 443
    targetPort: 443
```

#### **C. Create a Kubernetes Secret for TLS Certificates**
```bash
kubectl create secret tls webhook-cert \
  --cert=server.crt \
  --key=server.key
```

---

### **4. Webhook Server Code (Go Example)**
Below is a simplified Go webhook server that:
- **Mutates** Pods to add a label.
- **Validates** Pods to ensure they have an `owner` annotation.

```go
package main

import (
	"encoding/json"
	"fmt"
	"net/http"
	"k8s.io/api/admission/v1"
	corev1 "k8s.io/api/core/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/apimachinery/pkg/runtime"
	"k8s.io/apimachinery/pkg/runtime/serializer"
)

var (
	codecs = serializer.NewCodecFactory(runtime.NewScheme())
)

// Handle mutating webhook requests
func mutate(w http.ResponseWriter, r *http.Request) {
	admissionReview := v1.AdmissionReview{}
	if err := json.NewDecoder(r.Body).Decode(&admissionReview); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	pod := corev1.Pod{}
	if err := json.Unmarshal(admissionReview.Request.Object.Raw, &pod); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	// Add a label to the Pod
	patch := []byte(fmt.Sprintf(
		`[{ "op": "add", "path": "/metadata/labels/example-label", "value": "mutated" }]`,
	))

	// Build the admission response
	admissionResponse := v1.AdmissionResponse{
		UID:     admissionReview.Request.UID,
		Allowed: true,
		Patch:   patch,
		PatchType: func() *v1.PatchType {
			pt := v1.PatchTypeJSONPatch
			return &pt
		}(),
	}

	resp := v1.AdmissionReview{
		TypeMeta: metav1.TypeMeta{
			Kind:       "AdmissionReview",
			APIVersion: "admission.k8s.io/v1",
		},
		Response: &admissionResponse,
	}

	json.NewEncoder(w).Encode(resp)
}

// Handle validating webhook requests
func validate(w http.ResponseWriter, r *http.Request) {
	admissionReview := v1.AdmissionReview{}
	if err := json.NewDecoder(r.Body).Decode(&admissionReview); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	pod := corev1.Pod{}
	if err := json.Unmarshal(admissionReview.Request.Object.Raw, &pod); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	// Check if the Pod has an "owner" annotation
	allowed := pod.Annotations["owner"] != ""
	admissionResponse := v1.AdmissionResponse{
		UID:     admissionReview.Request.UID,
		Allowed: allowed,
	}

	if !allowed {
		admissionResponse.Result = &metav1.Status{
			Message: "Pod must have an 'owner' annotation",
		}
	}

	resp := v1.AdmissionReview{
		TypeMeta: metav1.TypeMeta{
			Kind:       "AdmissionReview",
			APIVersion: "admission.k8s.io/v1",
		},
		Response: &admissionResponse,
	}

	json.NewEncoder(w).Encode(resp)
}

func main() {
	http.HandleFunc("/mutate", mutate)
	http.HandleFunc("/validate", validate)
	http.ListenAndServeTLS(":443", "server.crt", "server.key", nil)
}
```

---

### **5. Configure Webhooks in Kubernetes**
Create `ValidatingWebhookConfiguration` and `MutatingWebhookConfiguration`:

```yaml
# validating-webhook.yaml
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingWebhookConfiguration
metadata:
  name: pod-validation
webhooks:
- name: pod-validation.example.com
  rules:
  - apiGroups:   [""]
    apiVersions: ["v1"]
    operations:  ["CREATE", "UPDATE"]
    resources:   ["pods"]
  clientConfig:
    service:
      name: admission-webhook
      namespace: default
      path: "/validate"
      port: 443
    caBundle: "<CA_CERT_BUNDLE>"
  admissionReviewVersions: ["v1"]
  sideEffects: None
  failurePolicy: Fail
---
# mutating-webhook.yaml
apiVersion: admissionregistration.k8s.io/v1
kind: MutatingWebhookConfiguration
metadata:
  name: pod-mutation
webhooks:
- name: pod-mutation.example.com
  rules:
  - apiGroups:   [""]
    apiVersions: ["v1"]
    operations:  ["CREATE", "UPDATE"]
    resources:   ["pods"]
  clientConfig:
    service:
      name: admission-webhook
      namespace: default
      path: "/mutate"
      port: 443
    caBundle: "<CA_CERT_BUNDLE>"
  admissionReviewVersions: ["v1"]
  sideEffects: None
  failurePolicy: Fail
```

Replace `<CA_CERT_BUNDLE>` with the base64-encoded CA certificate:
```bash
caBundle=$(cat ca.crt | base64 | tr -d '\n')
```

---

### **6. Testing**
1. **Deploy the Webhook**:
   ```bash
   kubectl apply -f validating-webhook.yaml
   kubectl apply -f mutating-webhook.yaml
   ```
2. **Test a Pod**:
   ```yaml
   # test-pod.yaml
   apiVersion: v1
   kind: Pod
   metadata:
     name: test-pod
     annotations:
       owner: "dev-team" # Remove this to trigger validation failure
   spec:
     containers:
     - name: nginx
       image: nginx
   ```
   ```bash
   kubectl apply -f test-pod.yaml
   ```

3. **Check Mutations**:
   ```bash
   kubectl get pod test-pod -o jsonpath='{.metadata.labels.example-label}'
   # Output: mutated
   ```

---

### **7. Key Considerations**
- **Idempotency**: Mutating webhooks must handle duplicate requests safely.
- **Performance**: Webhooks add latency; optimize logic and use caching.
- **Error Handling**: Use `failurePolicy: Ignore` to avoid cluster-wide outages.
- **TLS Rotation**: Automate certificate renewal (e.g., with cert-manager).

---

### **8. Advanced Use Cases**
1. **Inject Sidecars**: Automatically add logging/monitoring containers.
2. **Policy Enforcement**: Block non-compliant images (e.g., untrusted registries).
3. **Defaulting**: Set default resource requests/limits.
4. **Cost Tagging**: Add labels for cost allocation (e.g., `team: finance`).

---

### **Conclusion**
Custom admission controllers empower you to enforce security, compliance, and operational policies tailored to your organization. Start with simple validations/mutations, then incrementally add complexity while monitoring performance and reliability.
