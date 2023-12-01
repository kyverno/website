---
title: Kyverno CLI
description: >
  Apply and test policies outside a cluster.
weight: 70
---

The Kyverno Command Line Interface (CLI) is designed to validate and test policy behavior to resources prior to adding them to a cluster. The CLI can be used in CI/CD pipelines to assist with the resource authoring process to ensure they conform to standards prior to them being deployed. It can be used as a `kubectl` plugin or as a standalone CLI. The CLI, although composed of the same Kyverno codebase, is a purpose-built binary available via multiple installation methods but is distinct from the Kyverno container image which runs as a Pod in a target Kubernetes cluster.

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

### Manual Binary Installation

The Kyverno CLI may also be installed by manually downloading the compiled binary available on the [releases page](https://github.com/kyverno/kyverno/releases). An example of installing the Kyverno CLI v1.10.0 on a Linux x86_64 system is shown below.

```sh
curl -LO https://github.com/kyverno/kyverno/releases/download/v1.10.0/kyverno-cli_v1.10.0_linux_x86_64.tar.gz
tar -xvf kyverno-cli_v1.10.0_linux_x86_64.tar.gz
sudo cp kyverno /usr/local/bin/
```

### Building the CLI from source

You can also build the CLI binary from the Git repository (requires Go).

```sh
git clone https://github.com/kyverno/kyverno
cd kyverno
make build-cli
sudo mv ./cmd/cli/kubectl-kyverno/kubectl-kyverno /usr/local/bin/
```

## CLI Commands

When using the Kyverno CLI with [kustomize](https://kustomize.io/), it is recommended to use the "[standalone](https://kubectl.docs.kubernetes.io/installation/kustomize/binaries/)" version as opposed to the version embedded inside `kubectl`.

### Apply

The `apply` command is used to perform a dry run on one or more policies with a given set of input resources. This can be useful to determine a policy's effectiveness prior to committing to a cluster. In the case of mutate policies, the `apply` command can show the mutated resource as an output. The input resources can either be resource manifests (one or multiple) or can be taken from a running Kubernetes cluster. The  `apply` command supports files from URLs both as policies and resources.

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

Apply all cluster policies in the current cluster to all matching resources in a cluster based on the current `kubectl` context:

```sh
kubectl get clusterpolicies -o yaml | kyverno apply - --cluster
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

Use `-f` or `--values-file` for applying multiple policies to multiple resources while passing a file containing variables and their values. Variables specified can be of various types include AdmissionReview fields, ConfigMap context data, and API call context data.

Use `-u` or `--userinfo` for applying policies while passing an optional user_info.yaml file which contains necessary admission request data made during the request.

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
      apiVersion: networking.k8s.io/v1
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
  validationFailureAction: Enforce
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
            any:
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

Use `--values-file` or `-f` for passing a file containing Namespace details. Check [here](/docs/writing-policies/match-exclude/#match-deployments-in-namespaces-using-labels) to know more about Namespace selectors.

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
  validationFailureAction: Audit
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
  validationFailureAction: Enforce
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

Policies that have their validationFailureAction set to `Audit` can be set to produce a warning instead of a failure using the `--audit-warn` flag. This will also cause a non-zero exit code if no enforcing policies failed.

```sh
kyverno apply /path/to/policy.yaml --resource /path/to/resource.yaml --audit-warn
```

Additionally, you can use the `--warn-exit-code` flag with the `apply` command to control the exit code when warnings are reported. This is useful in CI/CD systems when used with the `--audit-warn` flag to treat `Audit` policies as warnings. When no failures or errors are found, but warnings are encountered, the CLI will exit with the defined exit code.

```sh
kyverno apply disallow-latest-tag.yaml --resource=echo-test.yaml --audit-warn --warn-exit-code 3
echo $?
3
```

You can also use `--warn-exit-code` in combination with `--warn-no-pass` flag to make the CLI exit with the warning code if no objects were found that satisfy a policy. This may be useful during the initial development of a policy or if you want to make sure that an object exists in the Kubernetes manifest.

```sh
kyverno apply disallow-latest-tag.yaml --resource=empty.yaml --warn-exit-code 3 --warn-no-pass
echo $?
3
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
spec:
  validationFailureAction: Audit
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

The `test` command is used to test a given set of resources against one or more policies to check desired results, declared in advance in a separate test manifest file, against the actual results. `test` is useful when you wish to declare what your expected results should be by defining the intent which then assists with locating discrepancies should those results change.

`test` works by scanning a given location, which can be either a Git repository or local folder, and executing the tests defined within. The rule types `validate`, `mutate`, and `generate` are currently supported. The command recursively looks for YAML files with policy test declarations (described below) with a specified file name and then executes those tests.  All files applicable to the same test must be co-located. Directory recursion is supported. `test` supports the [auto-gen feature](/docs/writing-policies/autogen/) making it possible to test, for example, Deployment resources against a Pod policy.

`test` will search for a file named `kyverno-test.yaml` and, if found, will execute the tests within.

In each test, there are four desired results which can be tested for. If the actual result of the test, once executed, matches the desired result as defined in the test manifest, it will be scored as a `pass` in the command output. For example, if the specified result of a given test of a resource against a policy is declared to be a `pass` and the actual result when tested is also a `pass`, the command output will show as `pass`. If the actual result was instead a `skip`, the command output will show as `fail` because the two results do not agree. The following are the desired results which can be specified in a test manifest.

1. pass: The resource passes the policy definition. For `validate` rules which are written with a `deny` statement, this will not be a possible result. `mutate` and `generate` rules can declare a pass.
2. skip: The resource does not meet either the `match` or `exclude` block, or does not pass the `preconditions` statements. For `validate` rules which are written with a `deny` statement, this is a possible result. If a rule contains certain conditional anchors which are not satisfied, the result may also be scored as a `skip`.
3. fail: The resource does not pass the policy definition. Typically used for `validate` rules with pattern-style policy definitions.
4. warn: Setting the annotation `policies.kyverno.io/scored` to `"false"` on a resource or policy which would otherwise fail will be considered a `warn`.

Use `--detailed-results` for a comprehensive output (default value `false`). For help with the `test` command, pass the `-h` flag for extensive output including usage, flags, and sample manifests.

{{% alert title="Note" color="info" %}}
The Kyverno CLI via the `test` command does not embed the Kubernetes control plane components and therefore is not able to perform the types of initial mutations subjected to a resource as part of an in-cluster creation flow. Take care to ensure the manifests you test account for these modifications.
{{% /alert %}}

#### Test File Structures

The test declaration file format of `kyverno-test.yaml` must be of the following format. In order to quickly generate a sample manifest which you can populate with your specified inputs, use either the `--manifest-mutate` or `--manifest-validate` command and output the result to a `kyverno-test.yaml` file.

```yaml
name: mytests
policies:
  - <path/to/policy.yaml>
  - <path/to/policy.yaml>
resources:
  - <path/to/resource.yaml>
  - <path/to/resource.yaml>
variables: variables.yaml # optional file for declaring variables. see below for example.
userinfo: user_info.yaml # optional file for declaring admission request information (roles, cluster roles and subjects). see below for example.
results:
- policy: <name>
  rule: <name>
  resource: <name>
  resources: # optional, primarily for `validate` rules. One of either `resource` or `resources[]` must be specified. Use `resources[]` when a number of different resources should all share the same test result.
  - <name_1>
  - <name_2>
  namespace: <name> # when testing for a resource in a specific Namespace
  patchedResource: <file_name.yaml> # when testing a mutate rule this field is required.
  generatedResource: <file_name.yaml> # when testing a generate rule this field is required.
  kind: <kind>
  result: pass
```

The test declaration consists of the following parts:

1. The `policies` element which lists one or more policies to be applied.
2. The `resources` element which lists one or more resources to which the policies are applied.
3. The `variables` element which defines a file in which variables and their values are stored for use in the policy test. Optional depending on policy content.
4. The `userinfo` element which declares admission request data for subjects and roles. Optional depending on policy content.
5. The `results` element which declares the expected results. Depending on the type of rule being tested, this section may vary.

If needing to pass variables, such as those from [external data sources](/docs/writing-policies/external-data-sources/) like context variables built from [API calls](https://kyverno.io/docs/writing-policies/external-data-sources/#variables-from-kubernetes-api-server-calls) or others, a `variables.yaml` file can be defined with the same format as accepted with the `apply` command. If a variable needs to contain an array of strings, it must be formatted as JSON encoded. Like with the `apply` command, variables that begin with `request.object` normally do not need to be specified in the variables file as these will be sourced from the resource. Policies which trigger based upon `request.operation` equaling `CREATE` do not need a variables file. The CLI will assume a value of `CREATE` if no variable for `request.operation` is defined.

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

A variables file may also optionally specify global variable values without the need to name specific rules or resources avoiding repetition for the same variable and same value.

```yaml
globalValues:
  request.operation: UPDATE
```

If policies use a namespaceSelector, these can also be specified in the variables file.

```yaml
namespaceSelector:
  - name: test1
    labels:
      foo.com/managed-state: managed
```

The user can also declare a `user_info.yaml` file that can be used to pass admission request information such as roles, cluster roles, and subjects.

```yaml
clusterRoles:
- admin
userInfo:
  username: someone@somecorp.com
```

Testing for subresources in `Kind/Subresource` matching format also requires a `subresources{}` section in the values file.

```yaml
subresources:
  - subresource:
      name: <name of subresource>
      kind: <kind of subresource>
      group: <group of subresource>
      version: <version of subresource>
    parentResource:
      name: <name of parent resource>
      kind: <kind of parent resource>
      group: <group of parent resource>
      version: <version of parent resource>
```

Here is an example when testing for subresources:

```yaml
subresources:
  - subresource:
      name: "deployments/scale"
      kind: "Scale"
      group: "autoscaling"
      version: "v1"
    parentResource:
      name: "deployments"
      kind: "Deployment"
      group: "apps"
      version: "v1"
```

#### Test Against Local Files

Test a set of local files in the working directory.

```sh
kyverno test .
```

Test a set of local files by specifying the directory.

```sh
kyverno test /path/to/folderContainingTestYamls
```

#### Test Against Git Repositories

Test an entire Git repository by specifying the branch name within the repo URL. If branch is not specified, `main` will be used as a default.

```sh
kyverno test https://github.com/kyverno/policies/release-1.6
```

Test a specific directory of the repository by specifying the directory within repo URL and the branch with the `--git-branch` or `-b` flag. Even if testing against `main`, when using a directory in the URL of the repo requires passing the `--git-branch` or `-b` flag.

```sh
kyverno test https://github.com/kyverno/policies/pod-security/restricted -b release-1.6
```

Use the `-f` flag to set a custom file name which includes test cases. By default, `test` will search for a file called `kyverno-test.yaml`.

#### Testing Policies with Image Registry Access

For policies which require image registry access to set context variables, those variables may be sourced from a variables file (defined below) or from a "live" registry by passing the `--registry` flag.

#### Test Subset of Resources

In some cases, you may wish to only test a subset of policy, rules, and/ resource combination rather than all those defined in a test manifest. Use the `--test-case-selector` flag to specify the exact tests you wish to execute.

```sh
kyverno test . --test-case-selector "policy=add-default-resources, rule=add-default-requests, resource=nginx-demo2"
```

#### Examples

The test command executes a test declaration by applying the policies to the resources and comparing the actual results with the desired/expected results. The test passes if the actual results match the expected results.

Below is an example of testing a policy containing two `validate` rules against the same resource where each is supposed to pass the policy.

Policy manifest (`disallow_latest_tag.yaml`):

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: disallow-latest-tag
spec:
  validationFailureAction: Audit
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
  - disallow_latest_tag.yaml
resources:
  - resource.yaml
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
$ kyverno test .

Executing disallow_latest_tag...
applying 1 policy to 1 resource... 

│───│─────────────────────│────────────────────│───────────────────────│────────│
│ # │ POLICY              │ RULE               │ RESOURCE              │ RESULT │
│───│─────────────────────│────────────────────│───────────────────────│────────│
│ 1 │ disallow-latest-tag │ require-image-tag  │ default/Pod/myapp-pod │ Pass   │
│ 2 │ disallow-latest-tag │ validate-image-tag │ default/Pod/myapp-pod │ Pass   │
│───│─────────────────────│────────────────────│───────────────────────│────────│

Test Summary: 2 tests passed and 0 tests failed
```

In the below case, a `mutate` policy which adds default resources to a Pod is being tested against two resources. Notice the addition of the `patchedResource` field in the `results[]` array, which is a requirement when testing `mutate` rules.

Policy manifest (`add-default-resources.yaml`):

```yaml
apiVersion : kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: add-default-resources
spec:
  background: false
  rules:
  - name: add-default-requests
    match:
      any:
      - resources:
          kinds:
          - Pod
    preconditions:
      any:
      - key: "{{request.operation}}"
        operator: AnyIn
        value:
        - CREATE
        - UPDATE
    mutate:
      patchStrategicMerge:
        spec:
          containers:
            - (name): "*"
              resources:
                requests:
                  +(memory): "100Mi"
                  +(cpu): "100m"
```

Resource manifest (`resource.yaml`):

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-demo1
spec:
  containers:
  - name: nginx
    image: nginx:1.14.2
---
apiVersion: v1
kind: Pod
metadata:
  name: nginx-demo2
spec:
  containers:
  - name: nginx
    image: nginx:latest
    resources:
      requests:
        memory: "200Mi" 
        cpu: "200m"
```

Variables manifest (`values.yaml`):

```yaml
policies:
- name: add-default-resources
  resources:
  - name: nginx-demo1
    values:
      request.operation: CREATE
  - name: nginx-demo2
    values:
      request.operation: UPDATE
```

Test manifest (`kyverno-test.yaml`):

```yaml
name: add-default-resources
policies:
  - add-default-resources.yaml
resources:
  - resource.yaml
variables: values.yaml
results:
  - policy: add-default-resources
    rule: add-default-requests
    resource: nginx-demo1
    patchedResource: patchedResource1.yaml
    kind: Pod
    result: pass
  - policy: add-default-resources
    rule: add-default-requests
    resource: nginx-demo2
    patchedResource: patchedResource2.yaml
    kind: Pod
    result: skip
```

```sh
$ kyverno test .

Executing add-default-resources...
applying 1 policy to 2 resources... 

skipped mutate policy add-default-resources -> resource default/Pod/nginx-demo2
│───│───────────────────────│──────────────────────│─────────────────────────│────────│
│ # │ POLICY                │ RULE                 │ RESOURCE                │ RESULT │
│───│───────────────────────│──────────────────────│─────────────────────────│────────│
│ 1 │ add-default-resources │ add-default-requests │ default/Pod/nginx-demo1 │ Pass   │
│ 2 │ add-default-resources │ add-default-requests │ default/Pod/nginx-demo2 │ Pass   │
│───│───────────────────────│──────────────────────│─────────────────────────│────────│

Test Summary: 2 tests passed and 0 tests failed
```

In the following policy test, a `generate` policy rule is applied which generates a new resource from an existing resource present in `resource.yaml`. To test the `generate` policy, the addition of a `generatedResource` field in the `results[]` array is required which is used to test against the resource generated by the policy.

Policy manifest (`add_network_policy.yaml`):

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: add-networkpolicy
spec:
  rules:
  - name: default-deny
    match:
      any:
      - resources:
          kinds:
          - Namespace
    generate:
      apiVersion: networking.k8s.io/v1
      kind: NetworkPolicy
      name: default-deny
      namespace: "{{request.object.metadata.name}}"
      synchronize: true
      data:
        spec:
          podSelector: {}
          policyTypes:
          - Ingress
          - Egress
```

Resource manifest (`resource.yaml`):

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: hello-world-namespace
```

Generated Resource (`generatedResource.yaml`):

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny
  namespace: hello-world-namespace
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
```

Test manifest (`kyverno-test.yaml`):

```yaml
name: deny-all-traffic
policies:
  - add_network_policy.yaml
resources:
  - resource.yaml
results:
  - policy: add-networkpolicy
    rule: default-deny
    resource: hello-world-namespace
    generatedResource: generatedResource.yaml
    kind: Namespace
    result: pass
```

```sh
$ kyverno test .
Executing deny-all-traffic...
applying 1 policy to 1 resource...

│───│───────────────────│──────────────│──────────────────────────────────│────────│
│ # │ POLICY            │ RULE         │ RESOURCE                         │ RESULT │
│───│───────────────────│──────────────│──────────────────────────────────│────────│
│ 1 │ add-networkpolicy │ default-deny │ /Namespace/hello-world-namespace │ Pass   │
│───│───────────────────│──────────────│──────────────────────────────────│────────│
Test Summary: 1 tests passed and 0 tests failed
```

For many more examples of test cases, please see the [kyverno/policies](https://github.com/kyverno/policies) repository which strives to have test cases for all the sample policies which appear on the [website](https://kyverno.io/policies/).

### Create

The Kyverno CLI has a `create` subcommand which makes it possible to create various Kyverno resources for use in both the webhook and the CLI. You can create:

1. metrics-config file
2. test file
3. user-info file
4. values file
5. exception file

Examples:

To create a values file
```sh
kyverno create values -g request.mode=dev -n prod,env=prod --rule policy,rule,env=demo --resource policy,resource,env=demo
```

To create a policy exception file
```sh
kyverno create exception my-exception --namespace my-ns --policy-rules "policy,rule-1,rule-2" --any "kind=Pod,kind=Deployment,name=test-*"
```
To create a test file
```sh
kyverno create test -p policy.yaml -r resource.yaml -f values.yaml --pass policy-name,rule-name,resource-name,resource-namespace,resource-kind
```

### Docs

The Kyverno CLI has a `docs` subcommand which makes it possible to generate Kyverno CLI reference documentation. It can be used to generate simple markdown files or markdown to be used for the website.

Examples:

To generate simple markdown documentation

```sh
kyverno docs -o . --autogenTag=false
```

### Jp

The Kyverno CLI has a `jp` subcommand which makes it possible to test not only the custom filters endemic to Kyverno but also the full array of capabilities of JMESPath included in the `jp` tool itself [here](https://github.com/jmespath/jp). By passing in either through stdin or a file, both for input JSON or YAML documents and expressions, the `jp` subcommand will evaluate any JMESPath expression and supply the output.

Examples:

List available Kyverno custom JMESPath filters. Please refer to the JMESPath documentation page [here](/docs/writing-policies/jmespath/) for extensive details on each custom filter. Note this does not show the built-in JMESPath filters available upstream, only the custom Kyverno filters.

```sh
$ kyverno jp function
Name: add
  Signature: add(any, any) any
  Note:      does arithmetic addition of two specified values of numbers, quantities, and durations

Name: base64_decode
  Signature: base64_decode(string) string
  Note:      decodes a base 64 string

Name: base64_encode
  Signature: base64_encode(string) string
  Note:      encodes a regular, plaintext and unencoded string to base64

Name: compare
  Signature: compare(string, string) number
  Note:      compares two strings lexicographically
<snip>
```

Test a custom JMESPath filter using stdin inputs.

```sh
$ echo '{"foo": "BAR"}' | kyverno jp query 'to_lower(foo)'
Reading from terminal input.
Enter input object and hit Ctrl+D.
# to_lower(foo)
"bar"
```

Test a custom JMESPath filter using an input JSON file. YAML files are also supported.

```sh
$ cat foo.json
{"bar": "this-is-a-dashed-string"}

$ kyverno jp query -i foo.json "split(bar, '-')"
# split(bar, '-')
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
$ kyverno jp query -i foo.json "split(bar, '-') | length(@)"
# split(bar, '-') | length(@)
5
```

Test a custom JMESPath filter using an expression from a file.

```sh
$ cat add
add(`1`,`2`)

$ echo {} | kyverno jp query -q add
Reading from terminal input.
Enter input object and hit Ctrl+D.
# add(`1`,`2`)
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

$ kyverno jp query -i pod.json 'spec.containers[0].name' -u
# spec.containers[0].name
busybox
```

Parse a JMESPath expression and show the corresponding [AST](https://en.wikipedia.org/wiki/Abstract_syntax_tree) to see how it was interpreted.

```sh
$ kyverno jp parse 'request.object.metadata.name | truncate(@, `9`)'
# request.object.metadata.name | truncate(@, `9`)
ASTPipe {
  children: {
    ASTSubexpression {
      children: {
        ASTSubexpression {
          children: {
            ASTSubexpression {
              children: {
                ASTField {
                  value: "request"
                }
                ASTField {
                  value: "object"
                }
            }
            ASTField {
              value: "metadata"
            }
        }
        ASTField {
          value: "name"
        }
    }
    ASTFunctionExpression {
      value: "truncate"
      children: {
        ASTCurrentNode {
        }
        ASTLiteral {
          value: 9
        }
    }
}
```

For more specific information on writing JMESPath for use in Kyverno, see the [JMESPath page](/docs/writing-policies/jmespath/).

### Oci

The Kyverno CLI has experimental ability to now push and pull Kyverno policies as OCI artifacts from an OCI-compliant registry. This ability allows one to store policies in a registry similar to how they are commonly stored in a git repository today. In a future release, the Kyverno admission controller will be able to directly reference this OCI image bundle to fetch policies.

{{% alert title="Warning" color="warning" %}}
The `oci` command is experimental and changes to the command and structure may change at any time.
{{% /alert %}}

To use the `oci` command, set the environment variable `KYVERNO_EXPERIMENTAL` to a value of `1` or `true`.

#### Pushing

Kyverno policies may be pushed to an OCI-compliant registry by using the `push` subcommand. Use the `-i` flag for the image repository reference and `--policy` or `-p` to reference one or more policies which should be bundled and pushed. The `-p` flag also supports a directory containing Kyverno policies. The directory must only contain Kyverno ClusterPolicy or Policy resources. Policies will be serialized and validated by the CLI first to ensure they are correct prior to pushing. This also means YAML comments will be lost.

Push a single Kyverno ClusterPolicy named `require-labels.yaml` to GitHub Container Registry at the `acme` organization in a repository named `mypolicies` with tag `0.0.1`.

```sh
kyverno oci push -i ghcr.io/acme/mypolicies:0.0.1 --policy require-labels.yaml
```

Push a directory named `mydirofpolicies` containing multiple Kyverno ClusterPolicy and Policy resources to GitHub Container Registry at the `acme` organization in a repository named `mypolicybundle` with tag `0.0.1`.

```sh
kyverno oci push -i ghcr.io/acme/mypolicybundle:0.0.1 --policy mydirofpolicies/
```

#### Pulling

Similar to the `push` subcommand, the `kyverno oci` command can pull the policies which were stored from a `push`. The `-i` flag is again used to reference the OCI artifact representing the Kyverno policies. The `--directory` or `-d` flag is used to set the output directory. Policies will be output as separate YAML files in the directory specified.

Pull the `ghcr.io/acme/mypolicybundle:0.0.1` Kyverno policy bundle to the working directory.

```sh
kyverno oci pull -i ghcr.io/acme/mypolicybundle:0.0.1
```

Pull the `ghcr.io/acme/mypolicybundle:0.0.1` Kyverno policy bundle to a directory named `foodir`.

```sh
kyverno oci pull -i ghcr.io/acme/mypolicybundle:0.0.1 -d foodir/
```

### Version

Prints the version of Kyverno CLI.

Example:

```sh
$ kyverno version
Version: 1.6.0
Time: 2022-02-08T07:49:45Z
Git commit ID: 5b4d4c266353981a559fe210b4e85100fa3bf397
```
