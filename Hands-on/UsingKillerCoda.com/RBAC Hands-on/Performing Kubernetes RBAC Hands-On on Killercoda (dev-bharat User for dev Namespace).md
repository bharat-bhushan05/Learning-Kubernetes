Case1: Suppose as kubernetes admin I have created dev-bharat user for dev namespace. Now how I will login as dev-bharat and test all the access without using kubectl auth command?

### **Performing Kubernetes RBAC Hands-On on Killercoda (dev-bharat User for dev Namespace)**  

Killercoda provides a sandbox environment for Kubernetes, allowing you to perform hands-on exercises without needing a local cluster. Below are the step-by-step instructions to implement the **`dev-bharat`** user and test RBAC in a `dev` namespace.  

---

### **Prerequisites:**  
- A Kubernetes cluster running on Killercoda.  
- Basic knowledge of `kubectl` commands.  

---

## **Step 1: Start a Kubernetes Cluster on Killercoda**  
1. Visit **[killercoda.com](https://killercoda.com)**.  
2. Select the **Kubernetes** environment (e.g., Kubernetes Playground or CKAD/CKA sandbox).  
3. Launch the Kubernetes interactive lab.  

---

## **Step 2: Create the dev Namespace**  
```bash
kubectl create namespace dev
```
- This creates a dedicated namespace for development activities.  

---

## **Step 3: Generate dev-bharat User Certificate and Key**  
1. **Generate Private Key:**  
   ```bash
   openssl genrsa -out dev-bharat.key 2048
   ```  
2. **Create CSR (Certificate Signing Request):**  
   ```bash
   openssl req -new -key dev-bharat.key -out dev-bharat.csr -subj "/CN=dev-bharat/O=developers"
   ```  

---

## **Step 4: Create Kubernetes CSR Resource**  
1. Encode the CSR:  
   ```bash
   cat dev-bharat.csr | base64 | tr -d '\n'
   ```  
2. **Create `dev-bharat-csr.yaml`:**  
   ```yaml
   apiVersion: certificates.k8s.io/v1
   kind: CertificateSigningRequest
   metadata:
     name: dev-bharat-csr
   spec:
     groups:
     - system:authenticated
     request: <BASE64_ENCODED_CSR>
     signerName: kubernetes.io/kube-apiserver-client
     usages:
     - client auth
   ```  
   - Replace `<BASE64_ENCODED_CSR>` with the output from the previous command.  
3. **Apply the CSR:**  
   ```bash
   kubectl apply -f dev-bharat-csr.yaml
   ```  

---

## **Step 5: Approve the CSR**  
```bash
kubectl certificate approve dev-bharat-csr
```  
- After approval, Kubernetes issues the certificate.  

---

## **Step 6: Retrieve the Signed Certificate**  
```bash
kubectl get csr dev-bharat-csr -o jsonpath='{.status.certificate}' | base64 --decode > dev-bharat.crt
```  
- This downloads the signed certificate for the `dev-bharat` user.  

---

## **Step 7: Configure Kubectl for dev-bharat User**  

1. **Add dev-bharat Credentials to Kubectl:**  
   ```bash
   kubectl config set-credentials dev-bharat \
     --client-certificate=dev-bharat.crt \
     --client-key=dev-bharat.key
   ```  

2. **Create a Context for dev-bharat:**  
   ```bash
   kubectl config set-context dev-bharat-context \
     --cluster=$(kubectl config view --minify -o jsonpath='{.clusters[0].name}') \
     --namespace=dev \
     --user=dev-bharat
   ```  

3. **Switch to dev-bharat Context:**  
   ```bash
   kubectl config use-context dev-bharat-context
   ```  

---

## **Step 8: Test Access (Without kubectl auth can-i)**  

1. **Try Listing Pods in the dev Namespace:**  
   ```bash
   kubectl get pods
   ```  
   - You should receive a `forbidden` error since `dev-bharat` does not have permissions yet.  

---

## **Step 9: Create Role and RoleBinding for dev-bharat**  

1. **Create Role (pod-reader) in dev Namespace:**  
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
   ```bash
   kubectl apply -f pod-reader-role.yaml
   ```  

2. **Bind the Role to dev-bharat (RoleBinding):**  
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
   ```bash
   kubectl apply -f pod-reader-binding.yaml
   ```  

---

## **Step 10: Test dev-bharat User Access Again**  

1. **Ensure You Are in the Correct Context:**  
   ```bash
   kubectl config use-context dev-bharat-context
   ```  
2. **Try Listing Pods Again:**  
   ```bash
   kubectl get pods
   ```  
   - This time, the command should succeed because `dev-bharat` now has `get` and `list` permissions for pods.  

---

## **Bonus: Additional Testing**  
1. **Try to Create a Deployment (Should Fail):**  
   ```bash
   kubectl create deployment test-nginx --image=nginx
   ```  
2. **Create Deployment Role and Bind to dev-bharat:**  
   ```yaml
   apiVersion: rbac.authorization.k8s.io/v1
   kind: Role
   metadata:
     namespace: dev
     name: deploy-manager
   rules:
   - apiGroups: ["apps"]
     resources: ["deployments"]
     verbs: ["create", "update"]
   ```  
   ```bash
   kubectl apply -f deploy-manager-role.yaml
   ```  
3. **RoleBinding:**  
   ```yaml
   apiVersion: rbac.authorization.k8s.io/v1
   kind: RoleBinding
   metadata:
     namespace: dev
     name: deploy-binding
   subjects:
   - kind: User
     name: dev-bharat
     apiGroup: rbac.authorization.k8s.io
   roleRef:
     kind: Role
     name: deploy-manager
     apiGroup: rbac.authorization.k8s.io
   ```  
   ```bash
   kubectl apply -f deploy-binding.yaml
   ```  
4. **Test Again:**  
   ```bash
   kubectl create deployment test-nginx --image=nginx
   ```  

---

## **Switch Back to Admin Context:**  
```bash
kubectl config use-context kubernetes-admin@kubernetes
```  

---

### **Cleanup (Optional):**  
```bash
kubectl delete csr dev-bharat-csr
kubectl delete role pod-reader -n dev
kubectl delete rolebinding pod-reader-binding -n dev
kubectl config delete-context dev-bharat-context
kubectl config delete-user dev-bharat
rm dev-bharat.key dev-bharat.crt dev-bharat.csr
```  

---

### **Conclusion:**  
This hands-on exercise provides a complete flow for creating, configuring, and testing Kubernetes RBAC without relying on `kubectl auth can-i`. By directly switching contexts to the `dev-bharat` user, you can simulate real-world access control scenarios efficiently using Killercoda’s environment.
