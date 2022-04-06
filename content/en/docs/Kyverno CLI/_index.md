---
title: Kyverno CLI
description: >
  Apply and test policies outside a cluster.
weight: 70
---

The Kyverno Command Line Interface (CLI) is designed to validate and test policy behavior to resources prior to adding them to a cluster. The CLI can be used in CI/CD pipelines to assist with the resource authoring process to ensure they conform to standards prior to them being deployed. It can be used as a `kubectl` plugin or as a standalone CLI.

## Building and Installing the CLI

### Install via Krew

You can use [Krew](https://github.com/kubernetes-sigs/krew) to install the Kyverno CLI:

```sh
# Install Kyverno CLI using kubectl krew plugin manager
kubectl krew install kyverno

# test the Kyverno CLI
kubectl kyverno version  
```

### Install via AUR (archlinux)

You can install the Kyverno CLI via your favorite AUR helper (e.g. [yay](https://github.com/Jguer/yay))

```sh
yay -S kyverno-git
```

### Install via Homebrew

The Kyverno CLI can also be installed with [Homebrew](https://brew.sh/) as a [formula](https://formulae.brew.sh/formula/kyverno#default).

```sh
brew install kyverno
```

### Building the CLI from source

You can also build the CLI binary from the Git repository (requires Go).

```sh
git clone https://github.com/kyverno/kyverno
cd kyverno
make cli
mv ./cmd/cli/kubectl-kyverno/kyverno /usr/local/bin/kyverno
```

## CLI Commands

When using the Kyverno CLI with [kustomize](https://kustomize.io/), it is recommended to use the "[standalone](https://kubectl.docs.kubernetes.io/installation/kustomize/binaries/)" version as opposed to the version embedded inside `kubectl`.

### Apply

The `apply` command is used to perform a dry run on one or more policies with a given set of input resources. This can be useful to determine a policy's effectiveness prior to committing to a cluster. In the case of mutate policies, the `apply` command can show the mutated resource as an output. The input resources can either be resource manifests (one or multiple) or can be taken from a running Kubernetes cluster.

{{% alert title="Note" color="info" %}}
Kyverno CLI in both `apply` and `validate` commands supports files from URLs both as policies and resources.
{{% /alert %}}

Apply to a resource:

```sh
kyverno apply /path/to/policy.yaml --resource /path/to/resource.yaml
```

Apply a policy to all matching resources in a cluster based on the current `kubectl` context:

```sh
kyverno apply /path/to/policy.yaml --cluster
```

The resources can also be passed from stdin:

```sh
kustomize build nginx/overlays/envs/prod/ | kyverno apply /path/to/policy.yaml --resource -
```

Apply multiple policies to multiple resources:

```sh
kyverno apply /path/to/policy1.yaml /path/to/folderFullOfPolicies --resource /path/to/resource1.yaml --resource /path/to/resource2.yaml --cluster
```

Apply a mutation policy to a specific resource:

```sh
kyverno apply /path/to/policy.yaml --resource /path/to/resource.yaml

applying 1 policy to 1 resource... 

mutate policy <policy_name> applied to <resource_name>:
<final mutated resource output>
```

Save the mutated resource to a file:

```sh
kyverno apply /path/to/policy.yaml --resource /path/to/resource.yaml -o newresource.yaml
```

Save the mutated resource to a directory:

```sh
kyverno apply /path/to/policy.yaml --resource /path/to/resource.yaml -o foo/
```

Apply a policy containing variables using the `--set` or `-s` flag to pass in the values. Variables that begin with `{{request.object}}` normally do not need to be specified as these will be read from the resource.

```sh
kyverno apply /path/to/policy.yaml --resource /path/to/resource.yaml --set <variable1>=<value1>,<variable2>=<value2>
```

Use `-f` or `--values-file` for applying multiple policies to multiple resources while passing a file containing variables and their values. Variables specified can be of various types include AdmissionReview fields, ConfigMap context data (Kyverno 1.3.6), and API call context data (Kyverno 1.3.6).

Use `-u` or `--userinfo` for applying policies while passing a optional user_info.yaml file which contains necessary admission request data made during the request.

{{% alert title="Note" color="info" %}}
When passing ConfigMap array data into the values file, the data must be formatted as JSON outlined [here](/docs/writing-policies/external-data-sources/#handling-configmap-array-values).
{{% /alert %}}

```sh
kyverno apply /path/to/policy1.yaml /path/to/policy2.yaml --resource /path/to/resource1.yaml --resource /path/to/resource2.yaml -f /path/to/value.yaml --userinfo /path/to/user_info.yaml
```

Format of `value.yaml` with all possible fields:

```yaml
policies:
  - name: <policy1 name>
    rules:
    - name: <rule1 name>
      values:
        <context variable1 in policy1 rule1>: <value>
        <context variable2 in policy1 rule1>: <value>
    - name: <rule2 name>
      values:
        <context variable1 in policy1 rule2>: <value>
        <context variable2 in policy1 rule2>: <value>
    resources:
    - name: <resource1 name>
      values:
        <variable1 in policy1>: <value>
        <variable2 in policy1>: <value>
    - name: <resource2 name>
      values:
        <variable1 in policy1>: <value>
        <variable2 in policy1>: <value>
namespaceSelector:
- name: <namespace1 name>
labels:
  <label key>: <label value>
- name: <namespace2 name>
labels:
  <label key>: <label value>
```

Format of `user_info.yaml`:

```yaml
clusterRoles:
- admin
userInfo:
  username: molybdenum@somecorp.com
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
      any:
      - resources:
          kinds:
          - Namespace
      clusterRoles:
      - cluster-admin
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
  name: devtest
```

Apply a policy to a resource using the `--set` or `-s` flag to pass a variable directly:

```sh
kyverno apply /path/to/add_network_policy.yaml --resource /path/to/required_default_network_policy.yaml -s request.object.metadata.name=devtest
```

Apply a policy to a resource using the `--values-file` or `-f` flag:

YAML file containing variables (`value.yaml`):

```yaml
policies:
  - name: add-networkpolicy
    resources:
      - name: devtest
        values:
          request.namespace: devtest
```

```sh
kyverno apply /path/to/add_network_policy.yaml --resource /path/to/required_default_network_policy.yaml -f /path/to/value.yaml
```

On applying the above policy to the mentioned resources, the following output will be generated:

```sh
Applying 1 policy to 1 resource... 
(Total number of result count may vary as the policy is mutated by Kyverno. To check the mutated policy please try with log level 5)

pass: 1, fail: 0, warn: 0, error: 0, skip: 0 
```

The summary count is based on the number of rules applied on the number of resources.

Value files also support global values, which can be passed to all resources the policy is being applied to.

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
globalValues:
  <global variable1>: <value>
  <global variable2>: <value>
```

If a resource-specific value and a global value have the same variable name, the resource value takes precedence over the global value. See the Pod `test-global-prod` in the following example.

Example:

Policy manifest (`add_dev_pod.yaml`):

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: cm-globalval-example
spec:
  validationFailureAction: enforce
  background: false
  rules:
    - name: validate-mode
      match:
        any:
        - resources:
            kinds:
              - Pod
      validate:
        message: "The value {{ request.mode }} for val1 is not equal to 'dev'."
        deny:
          conditions:
            - key: "{{ request.mode }}"
              operator: NotEquals
              value: dev
```

Resource manifest (`dev_prod_pod.yaml`):

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: test-global-prod
spec:
  containers:
    - name: nginx
      image: nginx:latest
---
apiVersion: v1
kind: Pod
metadata:
  name: test-global-dev
spec:
  containers:
    - name: nginx
      image: nginx:1.12
```

YAML file containing variables (`value.yaml`):

```yaml
policies:
  - name: cm-globalval-example
    resources:
      - name: test-global-prod
        values:
          request.mode: prod
globalValues:
  request.mode: dev
```

```sh
kyverno apply /path/to/add_dev_pod.yaml --resource /path/to/dev_prod_pod.yaml -f /path/to/value.yaml
```

The Pod `test-global-dev` passes the validation, and `test-global-prod` fails.

Apply a policy with the Namespace selector:

Use `--values-file` or `-f` for passing a file containing Namespace details.
Check [here](/docs/writing-policies/match-exclude/#match-deployments-in-namespaces-using-labels) to know more about Namespace selectors.

```sh
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
        any:
        - resources:
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
kind: Pod
apiVersion: v1
metadata:
  name: test-nginx
  namespace: test1
spec:
  containers:
  - name: nginx
    image: nginx:latest
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

To test the above policy, use the following command:

```sh
kyverno apply /path/to/enforce-pod-name.yaml --resource /path/to/nginx.yaml -f /path/to/value.yaml
```

Apply a resource to a policy which uses a context variable:

Use `--values-file` or `-f` for passing a file containing the context variable.

```sh
kyverno apply /path/to/policy1.yaml --resource /path/to/resource1.yaml -f /path/to/value.yaml
```

`policy1.yaml`

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: cm-variable-example
  annotations:
    pod-policies.kyverno.io/autogen-controllers: DaemonSet,Deployment,StatefulSet
spec:
  validationFailureAction: enforce
  background: false
  rules:
    - name: example-configmap-lookup
      context:
      - name: dictionary
        configMap:
          name: mycmap
          namespace: default
      match:
        any:
        - resources:
            kinds:
            - Pod
      mutate:
        patchStrategicMerge:
          metadata:
            labels:
              my-environment-name: "{{dictionary.data.env}}"
```

`resource1.yaml`

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-config-test
spec:
  containers:
  - image: nginx:latest
    name: test-nginx
```

`value.yaml`

```yaml
policies:
  - name: cm-variable-example
    rules:
      - name: example-configmap-lookup
        values:
          dictionary.data.env: dev1
```

#### Policy Report

Policy reports provide information about policy execution and violations. Use `--policy-report` with the `apply` command to generate a policy report for `validate` policies. `mutate` and `generate` policies do not trigger policy reports.

Policy reports can also be generated for a live cluster. While generating a policy report for a live cluster the `-r` flag, which declares a resource, is assumed to be globally unique. And it doesn't support naming the resource type (ex., Pod/foo when the cluster contains resources of different types with the same name). To generate a policy report for a live cluster use `--cluster` with `--policy-report`.

```sh
kyverno apply policy.yaml --cluster --policy-report
```

Above example applies a `policy.yaml` to all resources in the cluster.

Below are the combination of inputs that can be used for generating the policy report from the Kyverno CLI.

| Policy        | Resource         | Cluster   | Namespace      | Interpretation |
| ------------- |:----------------:| :--------:| :-------------:| :-------------:|
| policy.yaml   | -r resource.yaml | false     |                | Apply policy from `policy.yaml` to the resources specified in `resource.yaml` |
| policy.yaml   | -r resourceName  | true      |                | Apply policy from `policy.yaml` to the resource with a given name in the cluster |
| policy.yaml   |                  | true      |                | Apply policy from policy.yaml to all the resources in the cluster |
| policy.yaml   | -r resourceName  | true      | -n=namespaceName   | Apply policy from `policy.yaml` to the resource with a given name in a specific Namespace |
| policy.yaml   |                  | true      | -n=namespaceName   | Apply policy from `policy.yaml` to all the resources in a specific Namespace |

Example:

Consider the following policy and resources:

`policy.yaml`

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
      any:
      - resources:
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

`resource1.yaml`

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

`resource2.yaml`

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
kyverno apply policy.yaml -r resource1.yaml -r resource2.yaml --policy-report
```

Case 2: Apply a policy manifest to multiple resources in the cluster

Create the resources by first applying manifests `resource1.yaml` and `resource2.yaml`.

```sh
kyverno apply policy.yaml -r nginx1 -r nginx2 --cluster --policy-report
```

Case 3: Apply a policy manifest to all resources in the cluster

```sh
kyverno apply policy.yaml --cluster --policy-report
```

Given the contents of policy.yaml shown earlier, this will produce a report validating against all Pods in the cluster.

Case 4: Apply a policy manifest to multiple resources by name within a specific Namespace

```sh
kyverno apply policy.yaml -r nginx1 -r nginx2 --cluster --policy-report -n default
```

Case 5: Apply a policy manifest to all resources within the default Namespace

```sh
kyverno apply policy.yaml --cluster --policy-report -n default
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

The `test` command can test multiple policy resources from a Git repository or local folders. The command recursively looks for YAML files with policy test declarations (described below) and then executes those tests. `test` is useful when you wish to declare, in advance, what your expected results should be by defining the intent in a manifest. All files applicable to the same test must be co-located. Directory recursion is supported. `test` supports the [auto-gen feature](/docs/writing-policies/autogen/) making it possible to test, for example, Deployment resources against a Pod policy.

Run tests on a set of local files:

```sh
kyverno test /path/to/folderContainingTestYamls
```

#### Run tests on a Git repo:

Testing on an entire repo by specifying branch name within repo URL:

```sh
kyverno test https://github.com/<ORG>/<REPO>/<BRANCH>
```

Example:

```sh
kyverno test https://github.com/kyverno/policies/release-1.5
```

{{% alert title="Note" color="info" %}}
If `<BRANCH>` is not provided in this case, the default branch is assumed to be `main`.
{{% /alert %}}

Testing on a specific directory of the repo by specifying the directory within repo URL, and the branch with `--git-branch` flag _(shorthand `-b`)_:

```sh
kyverno test https://github.com/<ORG>/<REPO>/<DIR> --git-branch <BRANCH>
```

Example:

```sh
kyverno test https://github.com/kyverno/policies/pod-security/restricted --git-branch release-1.5
```

{{% alert title="Note" color="info" %}}
While providing `<DIR>` within the repo URL, it is necessary to provide the branch using the `--git-branch` or `-b` flag, even if it is `main`.
{{% /alert %}}

Use the `-f <fileName.yaml>` flag to set a custom file name which includes test cases. By default, `test` will search for a file called `kyverno-test.yaml`. The previous file name of `test.yaml` is deprecated.

The test declaration file format must be of the following format.

```yaml
name: mytests
policies:
  - <path/to/policy.yaml>
  - <path/to/policy.yaml>
resources:
  - <path/to/resource.yaml>
  - <path/to/resource.yaml>
# optional file for declaring variables. see below for example.
variables: variables.yaml
# optional file for declaring admission request information (roles, cluster roles and subjects). see below for example.
userinfo: user_info.yaml
results:
- policy: <name>
  rule: <name>
  resource: <name>
  kind: <kind>
  result: pass
- policy: <name>
  rule: <name>
  resource: <name>
  kind: <kind>
  result: fail
```

If needing to pass variables, such as those from [external data sources](/docs/writing-policies/external-data-sources/) like context variables built from [API calls](https://kyverno.io/docs/writing-policies/external-data-sources/#variables-from-kubernetes-api-server-calls) or others, a `variables.yaml` file can be defined with the same format as accepted with the `apply` command. If a variable needs to contain an array of strings, it must be formatted as JSON encoded. Like with the `apply` command, variables that begin with `request.object` normally do not need to be specified in the variables file as these will be sourced from the resource.

```yaml
policies:
  - name: exclude-namespaces-example
    rules:
      - name: exclude-namespaces-dynamically
        values:
          namespacefilters.data.exclude: asdf
    resources:
      - name: nonroot-pod
        values:
          namespacefilters.data.exclude: foo
      - name: root-pod
        values:
          namespacefilters.data.exclude: "[\"cluster-admin\", \"cluster-operator\", \"tenant-admin\"]"
```

The user can also declare a user_info.yaml file that can be used to pass admission request information such as roles, cluster roles and subjects.

```yaml
clusterRoles:
- admin
userInfo:
  username: someone@somecorp.com
```

The test declaration consists of three (optionally four) parts:

1. The `policies` element which lists one or more policies to be applied.
2. The `resources` element which lists one or more resources to which the policies are applied.
3. The `results` element which declares the expected results.
4. The `userinfo` element which declares admission request data.
5. The `variables` element which defines a file in which variables and their values are stored for use in the policy test.

A variables file may also optionally specify global variable values without the need to name specific rules or resources avoiding repetition for the same variable and same value.

```yaml
globalValues:
  request.operation: UPDATE
```

The test command executes a test declaration by applying the policies to the resources and comparing the results with the expected results. The test passes if the actual results match the expected results.

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
      any:
      - resources:
          kinds:
          - Pod
      clusterRoles:
      - cluster-admin
    validate:
      message: "An image tag is required."  
      pattern:
        spec:
          containers:
          - image: "*:*"
  - name: validate-image-tag
    match:
      any:
      - resources:
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
  name: myapp-pod
  labels:
    app: myapp
spec: 
  containers:
  - name: nginx
    image: nginx:1.12
```

Test manifest (`kyverno-test.yaml`):

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
    kind: Pod
    result: pass
  - policy: disallow-latest-tag
    rule: validate-image-tag
    resource: myapp-pod
    kind: Pod
    result: pass
```

```sh
kyverno test <PathToDirs>
```

The example above applies a test on the policy and the resource defined in the test YAML.

| #        | TEST                                                                  | RESULT           |
| ---------|:---------------------------------------------------------------------:|:-----------------|
| 1        |  myapp-pod  with  disallow-latest-tag/require-image-tag               | pass             |
| 2        |  myapp-pod  with  disallow-latest-tag/validate-image-tag              | pass             |

### Validate

The `validate` command validates that a policy is syntactically valid. It can validate multiple policy resource description files or even an entire folder containing policy resource description files. Currently supports files with resource description in YAML. The policies can also be passed from stdin.

Example:

```sh
kyverno validate /path/to/policy1.yaml /path/to/policy2.yaml /path/to/folderFullOfPolicies
```

Passing policy from stdin:

```sh
kustomize build nginx/overlays/envs/prod/ | kyverno validate -
```

Use the `-o <yaml/json>` flag to display the mutated policy.

Example:

```sh
kyverno validate /path/to/policy1.yaml /path/to/policy2.yaml /path/to/folderFullOfPolicies -o yaml
```

Policy can also be validated with CRDs. Use the `-c` flag to pass the CRD. You can pass multiple CRD files or even an entire folder containing CRDs.

### Jp

The Kyverno CLI has a `jp` subcommand which makes it possible to test not only the custom filters endemic to Kyverno but also the full array of capabilities of JMESPath included in the `jp` tool itself [here](https://github.com/jmespath/jp). By passing in either through stdin or a file, both for input JSON documents and expressions, the `jp` subcommand will evaluate any JMESPath expression and supply the output.

Example:

List available Kyverno custom JMESPath filters.

```sh
$ kyverno jp -l
add(any, any) any
base64_decode(string) string
base64_encode(string) string
compare(string, string) bool
<output abbreviated>
```

Test a custom JMESPath filter using stdin inputs.

```sh
$ echo '{"foo": "BAR"}' | kyverno jp 'to_lower(foo)'
"bar"
```

Test a custom JMESPath filter using an input JSON file.

```sh
$ cat foo
{"bar": "this-is-a-dashed-string"}

$ kyverno jp -f foo "split(bar, '-')"
[
  "this",
  "is",
  "a",
  "dashed",
  "string"
]
```

Test a custom JMESPath filter as well as an upstream JMESPath filter.

```sh
$ kyverno jp -f foo "split(bar, '-') | length(@)"
5
```

Test a custom JMESPath filter using an expression from a file.

```sh
$ cat add
add(`1`,`2`)

$ echo {} | kyverno jp -e add
3
```

Test upstream JMESPath functionality using an input JSON file and show cleaned output.

```sh
$ cat pod.json
{
  "apiVersion": "v1",
  "kind": "Pod",
  "metadata": {
    "name": "mypod",
    "namespace": "foo"
  },
  "spec": {
    "containers": [
      {
        "name": "busybox",
        "image": "busybox"
      }
    ]
  }
}

$ kyverno jp -f pod.json 'spec.containers[0].name' -u
busybox
```

For more specific information on writing JMESPath for use in Kyverno, see the [JMESPath page](/docs/writing-policies/jmespath/).

### Version

Prints the version of Kyverno CLI.

Example:

```sh
$ kyverno version
Version: 1.6.0
Time: 2022-02-08T07:49:45Z
Git commit ID: 5b4d4c266353981a559fe210b4e85100fa3bf397
```
