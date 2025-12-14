# 🔐 Kubernetes RBAC Hands-On Lab (kubeadm + KodeKloud)

This lab demonstrates **real-world Kubernetes RBAC** implementation on a **self-managed kubeadm cluster** running on **AWS Ubuntu machines**, using **KodeKloud labs**.

The lab is fully **CKA-aligned** and avoids cloud IAM, relying on **certificate-based authentication (X.509)**.

---

## 🎯 Objectives

By completing this lab, you will:

* Understand Kubernetes **Authentication vs Authorization**
* Create **dev, qa, prod users** using client certificates
* Implement **namespace-scoped RBAC** using Roles & RoleBindings
* Generate **separate kubeconfig files** per user
* Validate permissions using `kubectl auth can-i`
* Work within **KodeKloud lab limitations**

---

## 🧱 Lab Architecture

```
Kubernetes Cluster (kubeadm)
│
├── Namespace: dev   → User: dev-user  (Full access)
├── Namespace: qa    → User: qa-user   (Read-only)
└── Namespace: prod  → User: prod-user (Strict read-only)
```

---

## ⚠️ KodeKloud Lab Constraints

| Limitation           | Handling Strategy            |
| -------------------- | ---------------------------- |
| No AWS IAM / SSO     | Use certificate-based users  |
| Short lab lifespan   | Minimal, clean configuration |
| Single control-plane | Namespace-based isolation    |
| No external CA       | Reuse Kubernetes CA          |
| No node restarts     | API-level changes only       |

---

## 🛠️ Prerequisites

* Working kubeadm cluster
* Access to control-plane node
* `kubectl` configured for admin access
* OpenSSL installed

---

## 📁 Directory Structure

```
rbac-lab/
├── dev/
│   ├── dev.key
│   ├── dev.crt
│   └── dev.conf
├── qa/
│   ├── qa.key
│   ├── qa.crt
│   └── qa.conf
├── prod/
│   ├── prod.key
│   ├── prod.crt
│   └── prod.conf
└── roles-bindings/
```

---

## 🔑 Authentication (Certificate-Based Users)

Kubernetes does **not store users internally**. Instead:

* User identity is extracted from client certificates
* `CN` → username
* `O`  → group (optional)

Each user is created using:

* Private key (`*.key`)
* CSR (`*.csr`)
* Signed certificate (`*.crt`) using Kubernetes CA

---

## 🧩 Authorization (RBAC)

### Namespaces

* `dev`
* `qa`
* `prod`

### Roles

| Role          | Namespace | Permissions                                |
| ------------- | --------- | ------------------------------------------ |
| dev-role      | dev       | Full access to pods, deployments, services |
| qa-role       | qa        | Read-only                                  |
| prod-readonly | prod      | Strict read-only                           |

### RoleBindings

Each Role is bound to its respective user using a **RoleBinding**.

---

## 🔐 kubeconfig Strategy

Each user gets an **isolated kubeconfig**:

| kubeconfig | User      | Context      | Namespace |
| ---------- | --------- | ------------ | --------- |
| dev.conf   | dev-user  | dev-context  | dev       |
| qa.conf    | qa-user   | qa-context   | qa        |
| prod.conf  | prod-user | prod-context | prod      |

This prevents:

* Accidental privilege escalation
* Context confusion

---

## ✅ Validation Commands

### Check permissions

```bash
kubectl auth can-i get pods -n dev   --kubeconfig=dev/dev.conf
kubectl auth can-i create pods -n qa --kubeconfig=qa/qa.conf
kubectl auth can-i delete pods -n prod --kubeconfig=prod/prod.conf
```

Expected results:

* dev → allowed
* qa → denied (write)
* prod → denied (write)

---

## 🧠 Key Learnings

* Kubernetes RBAC is **deny-by-default**
* Users are external to Kubernetes
* Certificates define identity, RBAC defines permissions
* Namespaces are the foundation of multi-tenancy
* Separate kubeconfigs prevent human error

---

## 🎓 Exam & Interview Tips (CKA)

* Always verify with `kubectl auth can-i`
* Distinguish **Role vs ClusterRole**
* Remember: **RoleBinding is namespace-scoped**
* Context mismatch = misleading results

---

## 🚀 Next Enhancements

* RBAC with **ServiceAccounts** (CI/CD use case)
* ClusterRole vs Role migration
* Break-glass admin access for prod
* RBAC troubleshooting scenarios

---

## 📌 Conclusion

This lab simulates **real production RBAC** in a constrained environment like KodeKloud, preparing you for:

## Outputs:

### Verify Cluster Access and create  Namespaces dev, qa & prod
<img width="1181" height="385" alt="image" src="https://github.com/user-attachments/assets/9d325579-e055-41f5-b4aa-83c209410946" />

### Create Users (Certificate Based) for dev, qa and prod user
<img width="984" height="1180" alt="image" src="https://github.com/user-attachments/assets/2610cfae-8145-4cd9-bf5e-4c0683e9c69a" />

### Created role and role-binding for each user
<img width="762" height="374" alt="image" src="https://github.com/user-attachments/assets/a58342f5-5ac0-405d-aaa1-9fdb722942e3" />

### Deployed role and role-binding
<img width="1181" height="208" alt="image" src="https://github.com/user-attachments/assets/d76e67e1-2299-40cd-9c04-2edb0521b703" />

### Create User-Specific kubeconfig Files ( dev-user kubeconfig)
<img width="1181" height="876" alt="image" src="https://github.com/user-attachments/assets/7c8645f5-9668-476a-8f8c-c6f068ff8261" />

### Create User-Specific kubeconfig Files ( qa-user kubeconfig)
<img width="1181" height="509" alt="image" src="https://github.com/user-attachments/assets/76a64e74-0d4d-4138-ac10-5afce4ce1d9f" />

### Create User-Specific kubeconfig Files ( prod-user kubeconfig)
<img width="1181" height="438" alt="image" src="https://github.com/user-attachments/assets/6ac7abbc-04a5-4f8e-9935-4f8ffec2d788" />

### Validation (dev user)
<img width="1181" height="149" alt="image" src="https://github.com/user-attachments/assets/9401d696-65fd-4e15-8aaa-00ad0955333f" />

### Validation (qa user)
<img width="1181" height="107" alt="image" src="https://github.com/user-attachments/assets/707b9471-66ca-44ce-a14a-1c00fb710df2" />

### Validation (prod user)
<img width="1181" height="115" alt="image" src="https://github.com/user-attachments/assets/72c9b8ae-8641-46e5-9c1a-22e75aa77b07" />

### Extra check
<img width="1181" height="88" alt="image" src="https://github.com/user-attachments/assets/85f3545e-3841-4121-94e2-8bfa40837552" />






