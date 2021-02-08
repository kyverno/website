---
title: Kyverno CLI
description: >
  Test policies and validate resources outside a cluster.
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

### Version

Prints the version of Kyverno used by the CLI.

Example:

```
kyverno version
```

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

### Apply

Applies policies on resources, and supports applying multiple policies on multiple resources in a single command. The command also supports applying the given policies to an entire cluster. The current `kubectl` context will be used to access the cluster.

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

Use `--values_file` for applying multiple policies on multiple resources and pass a file containing variables and its values.

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

#### Policy Report

Use '--policy_report' with apply command to generate policy report.

Input combination:

| S.No | policy        | resource         | cluster   | namespace      | interpretation                                                                           |
| ---- |:-------------:| :---------------:| :--------:| :-------------:| :----------------------------------------------------------------------------------------| 
| 1.   | policy.yaml   | -r resource.yaml | false     |                | apply policy from file to the resource from file                                         |
| 2.   | policy.yaml   | -r resourceName  | true      |                | apply policy from file to the resource in cluster                                        |
| 3.   | policy.yaml   |                  | true      |                | apply policy from file to all the resources in cluster                                   |
| 4.   | policy.yaml   | -r resourceName  | true      | -n=namespace   | apply policy from file to the resource in cluster in mentioned namespace                 |
| 5.   | policy.yaml   |                  | true      | -n=namespace   | apply policy from file to all the resources in cluster in mentioned namespace            |


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

Case 1: Apply policy manifest on resource manifest

```
kyverno apply policy.yaml -r resource1.yaml -r resource2.yaml --policy_report
```

Case 2: Apply policy manifest on cluster resource 

create above resource manifest in cluster.
```
kyverno apply policy.yaml -r nginx1 -r nginx2 --cluster --policy_report
```

Case 3: Apply policy manifest on all resource avaliable in cluster
```
kyverno apply policy.yaml --cluster --policy_report
```
This will validate all the pods avaliable in cluster.

Case 4: Apply policy manifest on resource avaliable in cluster under a specific namspace
```
kyverno apply policy.yaml -r nginx1 -r nginx2 --cluster --policy_report -n default
```

Case 5: Apply policy manifest on all resource avaliable in cluster under a specific namespace
```
kyverno apply policy.yaml --cluster --policy_report -n default
```
This will validate all the pods avaliable in cluster avaliable under default namespace.

On applying policy.yaml on the mentioned resources, the following report will be generated: 

```
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
