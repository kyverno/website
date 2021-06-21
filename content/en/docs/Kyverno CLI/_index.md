---
title: Kyverno CLI
description: >
  Apply and test policies outside a cluster.
weight: 70
---

The Kyverno Command Line Interface (CLI) is designed to validate policies and test the behavior of applying policies to resources before adding the policy to a cluster. It can be used as a `kubectl` plugin or as a standalone CLI.

## Installing the CLI

You can use [Krew](https://github.com/kubernetes-sigs/krew) to install the Kyverno CLI:

```bash
# Install Kyverno CLI using kubectl krew plugin manager
kubectl krew install kyverno

# test the Kyverno CLI
kubectl kyverno version  

```

## Install via AUR (archlinux)

You can install the Kyverno CLI via your favorite AUR helper (e.g. [yay](https://github.com/Jguer/yay))

```
yay -S kyverno-git
```

## Building the CLI

You can also build the CLI binary from the Git repository, and then move the binary into a directory in your PATH.

```bash
git clone https://github.com/kyverno/kyverno.git
cd github.com/kyverno/kyverno
make cli
mv ./cmd/cli/kubectl-kyverno/kyverno /usr/local/bin/kyverno
```

## CLI Commands

When using the Kyverno CLI with [kustomize](https://kustomize.io/), it is recommended to use the "standalone" version (binaries [here](https://kubectl.docs.kubernetes.io/installation/kustomize/binaries/)) as opposed to the version embedded inside `kubectl`.

### Apply

Applies policies on resources, and supports applying multiple policies on multiple resources in a single command. The command also supports applying the given policies to an entire cluster. The current `kubectl` context will be used to access the cluster.

{{% alert title="Note" color="info" %}}
Kyverno CLI in both `apply` and `validate` commands supports files from URLs both as policies and resources.
{{% /alert %}}

Displays mutate results to stdout, by default. Use the `-o <path>` flag to save mutated resources to a file or directory.

Apply to a resource:
```
kyverno apply /path/to/policy.yaml --resource /path/to/resource.yaml
```

Apply to all matching resources in a cluster:
```
kyverno apply /path/to/policy.yaml --cluster > policy-results.txt
```

The resources can also be passed from stdin:
```
kustomize build nginx/overlays/envs/prod/ | kyverno apply /path/to/policy.yaml --resource -
```

Apply multiple policies to multiple resources:
```
kyverno apply /path/to/policy1.yaml /path/to/folderFullOfPolicies --resource /path/to/resource1.yaml --resource /path/to/resource2.yaml --cluster
```

Saving the mutated resource in a file/directory:
```
kyverno apply /path/to/policy.yaml --resource /path/to/resource.yaml -o <file path/directory path>
```

Apply policy with variables:

Use the `--set` flag to pass the values for variables in a policy while applying on a resource.

```
kyverno apply /path/to/policy.yaml --resource /path/to/resource.yaml --set <variable1>=<value1>,<variable2>=<value2>
```

Use `--values_file` for applying multiple policies on multiple resources and pass a file containing variables and its values. Variables specified can be of various types include AdmissionReview fields, ConfigMap context data (Kyverno 1.3.6), and API call context data (Kyverno 1.3.6).

{{% alert title="Note" color="info" %}}
When passing ConfigMap array data into the values file, the data must be formatted as JSON outlined [here](https://kyverno.io/docs/writing-policies/external-data-sources/#handling-configmap-array-values).
{{% /alert %}}

```
kyverno apply /path/to/policy1.yaml /path/to/policy2.yaml --resource /path/to/resource1.yaml --resource /path/to/resource2.yaml -f /path/to/value.yaml
```

Format of `value.yaml`:

```yaml
policies:
  - name: <policy1 name>
    resources:
      - name: <resource1 name>
        values:
          <variable1 in policy1>: <value>
          <variable2 in policy1>: <value>
      - name: <resource2 name>
        values:
          <variable1 in policy1>: <value>
          <variable2 in policy1>: <value>
  - name: <policy2 name>
    resources:
      - name: <resource1 name>
        values:
          <variable1 in policy2>: <value>
          <variable2 in policy2>: <value>
      - name: <resource2 name>
        values:
          <variable1 in policy2>: <value>
          <variable2 in policy2>: <value>
```

Example:

Policy manifest (`add_network_policy.yaml`):

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: add-networkpolicy
  annotations:
    policies.kyverno.io/category: Workload Management
    policies.kyverno.io/description: By default, Kubernetes allows communications across
      all pods within a cluster. Network policies and, a CNI that supports network policies,
      must be used to restrict communications. A default NetworkPolicy should be configured
      for each namespace to default deny all ingress traffic to the pods in the namespace.
      Application teams can then configure additional NetworkPolicy resources to allow
      desired traffic to application pods from select sources.
spec:
  rules:
  - name: default-deny-ingress
    match:
      resources:
        kinds:
        - Namespace
    generate:
      kind: NetworkPolicy
      name: default-deny-ingress
      namespace: "{{request.object.metadata.name}}"
      synchronize: true
      data:
        spec:
          # select all pods in the namespace
          podSelector: {}
          policyTypes:
          - Ingress
```

Resource manifest (`required_default_network_policy.yaml`):

```yaml
kind: Namespace
apiVersion: v1
metadata:
  name: "devtest"
```

Applying policy on resource using `--set` or `-s` flag:

```
kyverno apply /path/to/add_network_policy.yaml --resource /path/to/required_default_network_policy.yaml -s request.object.metadata.name=devtest
```

Applying policy on resource using `--values_file` or `-f` flag:

YAML file containing variables (`value.yaml`):

```yaml
policies:
  - name: default-deny-ingress
    resources:
      - name: devtest
        values:
          request.namespace: devtest
```

```
kyverno apply /path/to/add_network_policy.yaml --resource /path/to/required_default_network_policy.yaml -f /path/to/value.yaml
```

Apply policy with namespace selector:

Use `--values_file` for passing a file containing namespace details.
Check [here](https://kyverno.io/docs/writing-policies/match-exclude/#match-deployments-in-namespaces-using-labels) to know more about namespace selector.

```
kyverno apply /path/to/policy1.yaml /path/to/policy2.yaml --resource /path/to/resource1.yaml --resource /path/to/resource2.yaml -f /path/to/value.yaml
```

Format of `value.yaml`:

```yaml
namespaceSelector:
  - name: <namespace1 name>
    labels:
      <namespace label key>: <namespace label value>
  - name: <namespace2 name>
    labels:
      <namespace label key>: <namespace label value>
```

Example:

Policy manifest (`enforce-pod-name.yaml`):

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: enforce-pod-name
spec:
  validationFailureAction: audit
  background: true
  rules:
    - name: validate-name
      match:
        resources:
          kinds:
            - Pod
          namespaceSelector:
            matchExpressions:
            - key: foo.com/managed-state
              operator: In
              values:
              - managed
      validate:
        message: "The Pod must end with -nginx"
        pattern:
          metadata:
            name: "*-nginx"
```

Resource manifest (`nginx.yaml`):

```yaml
kind: "Pod"
apiVersion: "v1"
metadata:
  name: test-nginx
  namespace: test1
spec:
  containers:
  - name: "nginx"
    image: "nginx:latest"
```

Namespace manifest (`namespace.yaml`):

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: test1
  labels:
    foo.com/managed-state: managed
```

YAML file containing variables (`value.yaml`):

```yaml
namespaceSelector:
  - name: test1
    labels:
      foo.com/managed-state: managed
```

To test the above policy use the following command:
```
kyverno apply /path/to/enforce-pod-name.yaml --resource /path/to/nginx.yaml -f /path/to/value.yaml
```


#### Policy Report

Policy report provide information about policy execution and violation. Use `--policy_report` with the `apply` command to generate policy report.

Policy report can also be generated for a live cluster. While generating a policy report for a live cluster the `-r` flag is assuming a resource by specific name which is assumed to be globally unique. And it doesn't support naming the resource type (ex., Pod/foo when the cluster contains resources of different types with the same name). To generate a policy report for a live cluster use `--cluster` with `--policy_report`.

```sh
kyverno apply policy.yaml --cluster --policy_report
```
Above example applies a `policy.yaml` to all resources in the cluster.

Below are the combination of inputs that can be used for generating the policy report from Kyverno CLI.

| Policy        | Resource         | Cluster   | Namespace      | Interpretation                                                                           |
| ---- |:-------------:| :---------------:| :--------:| :-------------:| :----------------------------------------------------------------------------------------| 
| policy.yaml   | -r resource.yaml | false     |                | Apply policy from `policy.yaml` to the resources specified in `resource.yaml`                                         |
| policy.yaml   | -r resourceName  | true      |                | Apply policy from `policy.yaml` to the resource with a given name in the cluster                                        |
| policy.yaml   |                  | true      |                | Apply policy from policy.yaml to all the resources in the cluster                                   |
| policy.yaml   | -r resourceName  | true      | -n=namespaceName   | Apply policy from `policy.yaml` to the resource with a given name in a specific Namespace                |
| policy.yaml   |                  | true      | -n=namespaceName   | Apply policy from `policy.yaml` to all the resources in a specific Namespace           |


Example:

Consider the following policy and resources:

policy.yaml
```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: require-pod-requests-limits
  annotations:
    policies.kyverno.io/category: Workload Management
    policies.kyverno.io/description: >-
      As application workloads share cluster resources, it is important to limit resources
      requested and consumed by each pod. It is recommended to require 'resources.requests'
      and 'resources.limits' per pod. If a namespace level request or limit is specified,
      defaults are automatically applied to each pod based on the 'LimitRange' configuration.
spec:
  validationFailureAction: audit
  rules:
  - name: validate-resources
    match:
      resources:
        kinds:
        - Pod
    validate:
      message: "CPU and memory resource requests and limits are required"
      pattern:
        spec:
          containers:
          - resources:
              requests:
                memory: "?*"
                cpu: "?*"
              limits:
                memory: "?*"
```

resource1.yaml
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx1
  labels:
    env: test
spec:
  containers:
  - name: nginx
    image: nginx
    imagePullPolicy: IfNotPresent
    resources:
      requests:
        memory: "64Mi"
        cpu: "250m"
      limits:
        memory: "128Mi"
        cpu: "500m"
```

resource2.yaml
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx2
  labels:
    env: test
spec:
  containers:
  - name: nginx
    image: nginx
    imagePullPolicy: IfNotPresent
```

Case 1: Apply a policy manifest to multiple resource manifests
```sh
kyverno apply policy.yaml -r resource1.yaml -r resource2.yaml --policy_report
```

Case 2: Apply a policy manifest to multiple resources in the cluster 

Create the resources by first applying manifests `resource1.yaml` and `resource2.yaml`.
```sh
kyverno apply policy.yaml -r nginx1 -r nginx2 --cluster --policy_report
```

Case 3: Apply a policy manifest to all resources in the cluster
```sh
kyverno apply policy.yaml --cluster --policy_report
```
Given the contents of policy.yaml shown earlier, this will produce a report validating against all Pods in the cluster.

Case 4: Apply a policy manifest to multiple resources by name within a specific Namespace
```sh
kyverno apply policy.yaml -r nginx1 -r nginx2 --cluster --policy_report -n default
```

Case 5: Apply a policy manifest to all resources within the default Namespace
```sh
kyverno apply policy.yaml --cluster --policy_report -n default
```
Given the contents of `policy.yaml` shown earlier, this will produce a report validating all Pods within the default Namespace.

On applying `policy.yaml` to the mentioned resources, the following report will be generated: 

```yaml
apiVersion: wgpolicyk8s.io/v1alpha1
kind: ClusterPolicyReport
metadata:
  name: clusterpolicyreport
results:
- message: Validation rule 'validate-resources' succeeded.
  policy: require-pod-requests-limits
  resources:
  - apiVersion: v1
    kind: Pod
    name: nginx1
    namespace: default
  rule: validate-resources
  scored: true
  status: pass
- message: 'Validation error: CPU and memory resource requests and limits are required; Validation rule validate-resources failed at path /spec/containers/0/resources/limits/'
  policy: require-pod-requests-limits
  resources:
  - apiVersion: v1
    kind: Pod
    name: nginx2
    namespace: default
  rule: validate-resources
  scored: true
  status: fail
summary:
  error: 0
  fail: 1
  pass: 1
  skip: 0
  warn: 0
```

### Test

The `test` command can test multiple policy resources from a Git repository or local folders. The command recursively looks for YAML files with policy test declarations (described below) and then executes those tests.

Example:

```sh
kyverno test  /path/to/folderContaningTestYamls
```
or

```sh
kyverno test  /path/to/githubRepository
``` 

Use the `--f <fileName.yaml>` flag to set a file name which includes test cases.

Test declaration file format (`test.yaml`)

```yaml
- name: test-1
  policies:
     - <path>
     - <path>
  resources:
     - <path>
     - <path>
   results:
   - policy: <name>
     rule: <name>
     resource: <name>
     status: pass
   - policy: <name>
     rule: <name>
     resource: <name>
     status: fail
    
```

The test declaration consists of three parts:

1. The `policies` element which lists one or more policies to be applied.
2. The `resources` element which lists one or more resources to which the policies are applied.
3. The `results` element which declares the expected results.

The test command executes a test declaration by applying the policies to the resources and comparing the results with the expected results. The test passes if the actual results match the expected results.

Multiple tests can be defined in the same file using the YAML delimiter `---`.

Example:

Policy manifest (`disallow_latest_tag.yaml`):

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: disallow-latest-tag
  annotations:
    policies.kyverno.io/category: Best Practices
    policies.kyverno.io/description: >-
      The ':latest' tag is mutable and can lead to unexpected errors if the 
      image changes. A best practice is to use an immutable tag that maps to 
      a specific version of an application pod.
spec:
  validationFailureAction: audit
  rules:
  - name: require-image-tag
    match:
      resources:
        kinds:
        - Pod
    validate:
      message: "An image tag is required."  
      pattern:
        spec:
          containers:
          - image: "*:*"
  - name: validate-image-tag
    match:
      resources:
        kinds:
        - Pod
    validate:
      message: "Using a mutable image tag e.g. 'latest' is not allowed."
      pattern:
        spec:
          containers:
          - image: "!*:latest"
```

Resource manifest (`resource.yaml`):

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: myapp-podName
  labels:
    app: myapp
spec: 
  containers:
  - name: nginx
    image: nginx:1.12
```

Test manifest (`test.yaml`):

```yaml
name: disallow_latest_tag
policies:
  -  disallow_latest_tag.yaml
resources:
  -  resource.yaml
results:
  - policy: disallow-latest-tag
    rule: require-image-tag
    resource: myapp-pod
    status: pass
  - policy: disallow-latest-tag
    rule: validate-image-tag
    resource: myapp-pod
    status: pass
```

```sh
kyverno test <PathToDirs>
```
The example above applies a test on the policy and the resource defined in the test YAML.


| #        | TEST                                                                    | RESULT           |
| ---------|:-----------------------------------------------------------------------:|:-----------------| 
| 1        |  myapp-pod  with  disallow-latest-tag/require-image-tag               | pass             |
| 2        |  myapp-pod  with  disallow-latest-tag/validate-image-tag              | pass             | 



### Validate

Validates a policy, can validate multiple policy resource description files or even an entire folder containing policy resource description files. Currently supports files with resource description in YAML. The policies can also be passed from stdin.

Example:

```
kyverno validate /path/to/policy1.yaml /path/to/policy2.yaml /path/to/folderFullOfPolicies
```

Passing policy from stdin:

```
kustomize build nginx/overlays/envs/prod/ | kyverno validate -
```

Use the `-o <yaml/json>` flag to display the mutated policy.

Example:

```
kyverno validate /path/to/policy1.yaml /path/to/policy2.yaml /path/to/folderFullOfPolicies -o yaml
```

Policy can also be validated with CRDs. Use `-c` flag to pass the CRD, can pass multiple CRD files or even an entire folder containing CRDs.

Example:

```
kyverno validate /path/to/policy1.yaml -c /path/to/crd.yaml -c /path/to/folderFullOfCRDs
```

### Version

Prints the version of Kyverno used by the CLI.

Example:

```
kyverno version
```
