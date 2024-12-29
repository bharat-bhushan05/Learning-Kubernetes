To log in as the `dev-bharat` user and test access to the `dev` namespace without using `kubectl auth can-i`, you can create a Kubernetes client certificate for the user and configure `kubectl` to use it. Here's a step-by-step guide to achieve this:  

---

### **Step 1: Create a Private Key and Certificate Signing Request (CSR)**  
```bash
openssl genrsa -out dev-bharat.key 2048
openssl req -new -key dev-bharat.key -out dev-bharat.csr -subj "/CN=dev-bharat/O=developers"
```
- **`/CN=dev-bharat`** – Common Name (CN) must match the username.  
- **`/O=developers`** – Organization (O) can represent a group for role bindings.  

---

### **Step 2: Create a Kubernetes CSR Resource**  
```yaml
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: dev-bharat-csr
spec:
  groups:
  - system:authenticated
  request: $(cat dev-bharat.csr | base64 | tr -d '\n')
  signerName: kubernetes.io/kube-apiserver-client
  usages:
  - client auth
```
- **Purpose:** This CSR requests the Kubernetes API server to sign the user certificate.  
- **Encode the CSR:**  
```bash
cat dev-bharat.csr | base64 | tr -d '\n'
```
Replace the `request` value in the YAML with the output of the command.  

---

### **Step 3: Submit the CSR to Kubernetes**  
```bash
kubectl apply -f dev-bharat-csr.yaml
kubectl get csr
```
- Ensure the CSR is in a `Pending` state.  

---

### **Step 4: Approve the CSR**  
```bash
kubectl certificate approve dev-bharat-csr
```
- This will approve and sign the CSR, issuing a client certificate for the `dev-bharat` user.  

---

### **Step 5: Retrieve the Signed Certificate**  
```bash
kubectl get csr dev-bharat-csr -o jsonpath='{.status.certificate}' | base64 --decode > dev-bharat.crt
```
- **`dev-bharat.crt`** – This is the signed client certificate.  

---

### **Step 6: Configure `kubectl` for the New User**  

1. **Add Credentials to Kubectl:**  
```bash
kubectl config set-credentials dev-bharat \
  --client-certificate=dev-bharat.crt \
  --client-key=dev-bharat.key
```

2. **Create a Context for `dev-bharat`:**  
```bash
kubectl config set-context dev-bharat-context \
  --cluster=$(kubectl config view --minify -o jsonpath='{.clusters[0].name}') \
  --namespace=dev \
  --user=dev-bharat
```

3. **Switch to the New Context:**  
```bash
kubectl config use-context dev-bharat-context
```

---

### **Step 7: Test Access to the Dev Namespace**  
```bash
kubectl get pods
kubectl get deployments
kubectl create deployment test-deploy --image=nginx
```
- **Explanation:** This tests if the user `dev-bharat` has access to resources in the `dev` namespace.  
- **If access is denied:** You need to modify the `Role` or `RoleBinding` for the user.  

---

### **Step 8: Create Role and RoleBinding for dev-bharat (if needed)**  

**Role (dev-pod-reader):**  
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: dev
  name: pod-reader
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list"]
```

**RoleBinding:**  
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  namespace: dev
  name: pod-reader-binding
subjects:
- kind: User
  name: dev-bharat
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```
- Apply the Role and RoleBinding:  
```bash
kubectl apply -f role.yaml
kubectl apply -f rolebinding.yaml
```

---

### **Step 9: Validate User Access**  
Try accessing resources in the `dev` namespace:  
```bash
kubectl get pods
kubectl create pod test --image=nginx
```
- If the user has permission, the operations will succeed.  
- If denied, adjust the `Role` and `RoleBinding`.  

---

### **Switching Between Contexts**  
```bash
kubectl config use-context dev-bharat-context
kubectl config use-context admin-context
```
- **Switch back to admin access** when needed by returning to the admin context.  

---

### **Verification Without kubectl auth**  
- By switching to the `dev-bharat` context, you directly experience the permissions and limitations of the user. This simulates real-world scenarios without running `kubectl auth can-i` explicitly.  

---

### **Cleanup (Optional)**  
```bash
kubectl delete csr dev-bharat-csr
kubectl config delete-context dev-bharat-context
kubectl config delete-user dev-bharat
rm dev-bharat.key dev-bharat.crt dev-bharat.csr
```  
- **Purpose:** Clean up the created resources if the user is no longer required.  

---

### **Conclusion:**  
This process simulates real-world Kubernetes authentication workflows by creating a client certificate and configuring `kubectl` to operate as the `dev-bharat` user. By testing user access directly through context switching, you ensure RBAC policies are correctly implemented and users have appropriate permissions in their namespaces.
