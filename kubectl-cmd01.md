### **Output Formatting Options**

1. **Wide Output (`-o wide`)**:
   Displays additional details about resources.
   ```bash
   kubectl get namespace -o wide
   ```

2. **Custom Columns (`-o custom-columns`)**:
   Specify which fields to display using custom columns.
   ```bash
   kubectl get namespace -o custom-columns=NAME:.metadata.name,STATUS:.status.phase,AGE:.metadata.creationTimestamp
   ```

3. **JSON Output (`-o json`)**:
   Outputs the resource details in JSON format.
   ```bash
   kubectl get namespace -o json
   ```

4. **YAML Output (`-o yaml`)**:
   Outputs the resource details in YAML format.
   ```bash
   kubectl get namespace -o yaml
   ```

5. **Name Output (`-o name`)**:
   Displays only the resource names.
   ```bash
   kubectl get namespace -o name
   ```

6. **Go Template (`-o go-template`)**:
   Use a Go template for highly customized outputs.
   ```bash
   kubectl get namespace -o go-template='{{range .items}}{{.metadata.name}}:{{.metadata.creationTimestamp}}{{"\n"}}{{end}}'
   ```

7. **Custom Sorting (`--sort-by`)**:
   Sort resources based on a field (e.g., `.metadata.name`, `.metadata.creationTimestamp`).
   ```bash
   kubectl get namespace --sort-by=.metadata.name
   ```
8. **Custom Sorting (`--sort-by`)**:
   Sort resources in reverse order
   ```bash
   kubectl get namespace --sort-by=.metadata.creationTimestamp | tac
   ```

---

### **Filtering Options**

1. **Field Selectors (`--field-selector`)**:
   Filter resources by specific field values.
   ```bash
   kubectl get namespace --field-selector=metadata.name=default
   ```

2. **Label Selectors (`-l`)**:
   Filter resources by labels.
   ```bash
   kubectl get namespace -l env=prod
   ```

---

### **General Utility Options**

1. **Limit the Number of Results (`--limit`)**:
   Display a specific number of results.
   ```bash
   kubectl get namespace --limit=5
   ```

2. **Chunking Results (`--chunk-size`)**:
   Control the number of resources fetched per API call (useful for large clusters).
   ```bash
   kubectl get namespace --chunk-size=10
   ```

3. **Watch for Changes (`-w` or `--watch`)**:
   Continuously watch for changes to resources.
   ```bash
   kubectl get namespace -w
   ```

4. **Show Labels (`--show-labels`)**:
   Display labels associated with resources.
   ```bash
   kubectl get namespace --show-labels
   ```

5. **Output Headers (`--no-headers`)**:
   Exclude headers from the output.
   ```bash
   kubectl get namespace --no-headers
   ```

---

### **Examples**

1. Get namespaces sorted by name, without headers:
   ```bash
   kubectl get namespace --sort-by=.metadata.name --no-headers
   ```

2. Get namespaces with custom columns:
   ```bash
   kubectl get namespace -o custom-columns=NAME:.metadata.name,AGE:.metadata.creationTimestamp
   ```

3. Watch for namespace changes in real-time:
   ```bash
   kubectl get namespace -w
   ```

4. Filter namespaces by a specific label:
   ```bash
   kubectl get namespace -l team=backend
   ```

By combining these options, you can extract, format, and sort resource data according to your specific needs.
