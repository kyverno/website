---
title: test
weight: 25
---

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

### Test File Structures

The test declaration file format of `kyverno-test.yaml` must be of the following format.

```yaml
apiVersion: cli.kyverno.io/v1alpha1
kind: Test
metadata:
  name: kyverno-test
policies:
  - <path/to/policy.yaml>
  - <path/to/policy.yaml>
resources:
  - <path/to/resource.yaml>
  - <path/to/resource.yaml>
exceptions: # optional files for specifying exceptions. See below for an example.
  - <path/to/exception.yaml>
  - <path/to/exception.yaml>
variables: variables.yaml # optional file for declaring variables. see below for example.
userinfo: user_info.yaml # optional file for declaring admission request information (roles, cluster roles and subjects). see below for example.
results:
- policy: <name> # Namespaced Policy is specified as <namespace>/<name>
  isValidatingAdmissionPolicy: false # when the policy is ValidatingAdmissionPolicy, this field is required.
  rule: <name> # when the policy is a Kyverno policy, this field is required.
  resources: # optional, primarily for `validate` rules.
  - <namespace_1/name_1>
  - <namespace_2/name_2>
  patchedResource: <file_name.yaml> # when testing a mutate rule this field is required.
  generatedResource: <file_name.yaml> # when testing a generate rule this field is required.
  cloneSourceResource: <file_name.yaml> # when testing a generate rule that uses `clone` object this field is required.
  kind: <kind>
  result: pass
```

The test declaration consists of the following parts:

1. The `policies` element which lists one or more policies to be applied.
2. The `resources` element which lists one or more resources to which the policies are applied.
3. The `exceptions` element which lists one or more policy exceptions. Cannot be used with ValidatingAdmissionPolicy. Optional.
4. The `variables` element which defines a file in which variables and their values are stored for use in the policy test. Optional depending on policy content.
5. The `userinfo` element which declares admission request data for subjects and roles. Optional depending on policy content.
6. The `results` element which declares the expected results. Depending on the type of rule being tested, this section may vary.

If needing to pass variables, such as those from [external data sources](/docs/writing-policies/external-data-sources/) like context variables built from [API calls](https://kyverno.io/docs/writing-policies/external-data-sources/#variables-from-kubernetes-api-server-calls) or others, a `variables.yaml` file can be defined with the same format as accepted with the `apply` command. If a variable needs to contain an array of strings, it must be formatted as JSON encoded. Like with the `apply` command, variables that begin with `request.object` normally do not need to be specified in the variables file as these will be sourced from the resource. Policies which trigger based upon `request.operation` equaling `CREATE` do not need a variables file. The CLI will assume a value of `CREATE` if no variable for `request.operation` is defined.

```yaml
apiVersion: cli.kyverno.io/v1alpha1
kind: Values
metadata:
  name: values
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
apiVersion: cli.kyverno.io/v1alpha1
kind: Values
metadata:
  name: values
globalValues:
  request.operation: UPDATE
```

If policies use a namespaceSelector, these can also be specified in the variables file.

```yaml
apiVersion: cli.kyverno.io/v1alpha1
kind: Values
metadata:
  name: values
namespaceSelector:
  - name: test1
    labels:
      foo.com/managed-state: managed
```

The user can also declare a `user_info.yaml` file that can be used to pass admission request information such as roles, cluster roles, and subjects.

```yaml
apiVersion: cli.kyverno.io/v1alpha1
kind: UserInfo
metadata:
  name: user-info
clusterRoles:
- admin
userInfo:
  username: someone@somecorp.com
```

Testing for subresources in `Kind/Subresource` matching format also requires a `subresources{}` section in the values file.

```yaml
apiVersion: cli.kyverno.io/v1alpha1
kind: Values
metadata:
  name: values
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
apiVersion: cli.kyverno.io/v1alpha1
kind: Values
metadata:
  name: values
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

### Test Against Local Files

Test a set of local files in the working directory.

```sh
kyverno test .
```

Test a set of local files by specifying the directory.

```sh
kyverno test /path/to/folderContainingTestYamls
```

### Test Against Git Repositories

Test an entire Git repository by specifying the branch name within the repo URL. If branch is not specified, `main` will be used as a default.

```sh
kyverno test https://github.com/kyverno/policies/release-1.6
```

Test a specific directory of the repository by specifying the directory within repo URL and the branch with the `--git-branch` or `-b` flag. Even if testing against `main`, when using a directory in the URL of the repo requires passing the `--git-branch` or `-b` flag.

```sh
kyverno test https://github.com/kyverno/policies/pod-security/restricted -b release-1.6
```

Use the `-f` flag to set a custom file name which includes test cases. By default, `test` will search for a file called `kyverno-test.yaml`.

### Testing Policies with Image Registry Access

For policies which require image registry access to set context variables, those variables may be sourced from a variables file (defined below) or from a "live" registry by passing the `--registry` flag.

### Test Subset of Resources

In some cases, you may wish to only test a subset of policy, rules, and/ resource combination rather than all those defined in a test manifest. Use the `--test-case-selector` flag to specify the exact tests you wish to execute.

```sh
kyverno test . --test-case-selector "policy=add-default-resources, rule=add-default-requests, resource=nginx-demo2"
```

### Examples

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
apiVersion: cli.kyverno.io/v1alpha1
kind: Test
metadata:
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
apiVersion: cli.kyverno.io/v1alpha1
kind: Values
metadata:
  name: values
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
apiVersion: cli.kyverno.io/v1alpha1
kind: Test
metadata:
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
apiVersion: cli.kyverno.io/v1alpha1
kind: Test
metadata:
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

In the following policy test, a `validate` rule ensures that Pods aren't allowed to access host namespaces. A Policy Exception is used to exempt Pods and Deployments beginning with the name `important-tool` in the `delta` namespace from this rule. The `exceptions` field is used in the Test manifest to declare a Policy Exception manifest. It is expected that resources that violate the rule but match policy exceptions will be skipped. Otherwise, they will fail.

Policy manifest (`disallow-host-namespaces.yaml`):

```yaml
apiVersion: kyverno.io/v2beta1
kind: ClusterPolicy
metadata:
  name: disallow-host-namespaces
spec:
  validationFailureAction: Enforce
  background: false
  rules:
    - name: host-namespaces
      match:
        any:
        - resources:
            kinds:
              - Pod
      validate:
        message: >-
          Sharing the host namespaces is disallowed. The fields spec.hostNetwork,
          spec.hostIPC, and spec.hostPID must be unset or set to `false`.          
        pattern:
          spec:
            =(hostPID): "false"
            =(hostIPC): "false"
            =(hostNetwork): "false"
```

Policy Exception manifest (`delta-exception.yaml`):

```yaml
apiVersion: kyverno.io/v2beta1
kind: PolicyException
metadata:
  name: delta-exception
  namespace: delta
spec:
  exceptions:
  - policyName: disallow-host-namespaces
    ruleNames:
    - host-namespaces
    - autogen-host-namespaces
  match:
    any:
    - resources:
        kinds:
        - Pod
        - Deployment
        namespaces:
        - delta
        names:
        - important-tool*
```

Resource manifest (`resource.yaml`):

Both Deployments violate the policy but only one matches an exception. The Deployment without an exception will fail while the one with an exception will be skipped.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: important-tool
  namespace: delta
  labels:
    app: busybox
spec:
  replicas: 1
  selector:
    matchLabels:
      app: busybox
  template:
    metadata:
      labels:
        app: busybox
    spec:
      hostIPC: true
      containers:
      - image: busybox:1.35
        name: busybox
        command: ["sleep", "1d"]
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: not-important
  namespace: gamma
  labels:
    app: busybox
spec:
  replicas: 1
  selector:
    matchLabels:
      app: busybox
  template:
    metadata:
      labels:
        app: busybox
    spec:
      hostIPC: true
      containers:
      - image: busybox:1.35
        name: busybox
        command: ["sleep", "1d"]        
```

Test manifest (`kyverno-test.yaml`):

```yaml
apiVersion: cli.kyverno.io/v1alpha1
kind: Test
metadata:
  name: disallow-host-namespaces-test-exception
policies:
- disallow-host-namespace.yaml
resources:
- resource.yaml
exceptions: 
- delta-exception.yaml
results:
  - kind: Deployment
    policy: disallow-host-namespaces
    resources: 
    - important-tool
    rule: host-namespaces
    result: skip
  - kind: Deployment
    policy: disallow-host-namespaces
    resources:
    - not-important
    rule: host-namespaces
    result: fail
```

```sh
kyverno test .

Loading test  ( .kyverno-test/kyverno-test.yaml ) ...
  Loading values/variables ...
  Loading policies ...
  Loading resources ...
  Loading exceptions ...
  Applying 1 policy to 2 resources with 1 exception ...
  Checking results ...

│────│──────────────────────────│─────────────────│───────────────────────────│────────│────────│
│ ID │ POLICY                   │ RULE            │ RESOURCE                  │ RESULT │ REASON │
│────│──────────────────────────│─────────────────│───────────────────────────│────────│────────│
│ 1  │ disallow-host-namespaces │ host-namespaces │ Deployment/important-tool │ Pass   │ Ok     │
│ 2  │ disallow-host-namespaces │ host-namespaces │ Deployment/not-important  │ Pass   │ Ok     │
│────│──────────────────────────│─────────────────│───────────────────────────│────────│────────│


Test Summary: 2 tests passed and 0 tests failed
```

For many more examples of test cases, please see the [kyverno/policies](https://github.com/kyverno/policies) repository which strives to have test cases for all the sample policies which appear on the [website](https://kyverno.io/policies/).

### Testing ValidatingAdmissionPolicies

Below is an example of testing a ValidatingAdmissionPolicy against two resources, one of which violates the policy.

Policy manifest (disallow-host-path.yaml):

```yaml
apiVersion: admissionregistration.k8s.io/v1beta1
kind: ValidatingAdmissionPolicy
metadata:
  name: disallow-host-path
spec:
  failurePolicy: Fail
  matchConstraints:
    resourceRules:
    - apiGroups:   ["apps"]
      apiVersions: ["v1"]
      operations:  ["CREATE", "UPDATE"]
      resources:   ["deployments"]
  validations:
    - expression: "!has(object.spec.template.spec.volumes) || object.spec.template.spec.volumes.all(volume, !has(volume.hostPath))"
      message: "HostPath volumes are forbidden. The field spec.template.spec.volumes[*].hostPath must be unset."
```

Resource manifest (deployments.yaml):

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: deployment-pass
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx-server
        image: nginx
        volumeMounts:
          - name: temp
            mountPath: /scratch
      volumes:
      - name: temp
        emptyDir: {}
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: deployment-fail
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx-server
        image: nginx
        volumeMounts:
          - name: udev
            mountPath: /data
      volumes:
      - name: udev
        hostPath:
          path: /etc/udev
```

Test manifest (kyverno-test.yaml):

```yaml
apiVersion: cli.kyverno.io/v1alpha1
kind: Test
metadata:
  name: disallow-host-path-test
policies:
  - disallow-host-path.yaml
resources:
  - deployments.yaml
results:
  - policy: disallow-host-path
    resource: deployment-pass
    isValidatingAdmissionPolicy: true
    kind: Deployment
    result: pass
  - policy: disallow-host-path
    resource: deployment-fail
    isValidatingAdmissionPolicy: true
    kind: Deployment
    result: fail
```

```sh
$ kyverno test .

Loading test  ( kyverno-test.yaml ) ...
  Loading values/variables ...
  Loading policies ...
  Loading resources ...
  Applying 1 policy to 2 resources ...
  Checking results ...

│────│────────────────────│──────│────────────────────────────│────────│────────│
│ ID │ POLICY             │ RULE │ RESOURCE                   │ RESULT │ REASON │
│────│────────────────────│──────│────────────────────────────│────────│────────│
│  1 │ disallow-host-path │      │ Deployment/deployment-pass │ Pass   │ Ok     │
│  2 │ disallow-host-path │      │ Deployment/deployment-fail │ Pass   │ Ok     │
│────│────────────────────│──────│────────────────────────────│────────│────────│


Test Summary: 2 tests passed and 0 tests failed
```

In the below example, a `ValidatingAdmissionPolicy` and its corresponding `ValidatingAdmissionPolicyBinding` are tested against six resources. Two of these resources do not match the binding, two match the binding but violate the policy, and the remaining two match the binding and do not violate the policy.

Policy manifest (`check-deployment-replicas.yaml`):

```yaml
apiVersion: admissionregistration.k8s.io/v1beta1
kind: ValidatingAdmissionPolicy
metadata:
  name: "check-deployment-replicas"
spec:
  matchConstraints:
    resourceRules:
    - apiGroups:
      - apps
      apiVersions:
      - v1
      operations:
      - CREATE
      - UPDATE
      resources:
      - deployments
  validations:
  - expression: object.spec.replicas <= 2
---
apiVersion: admissionregistration.k8s.io/v1beta1
kind: ValidatingAdmissionPolicyBinding
metadata:
  name: "check-deployment-replicas-binding"
spec:
  policyName: "check-deployment-replicas"
  validationActions: [Deny]
  matchResources:
    namespaceSelector:
      matchExpressions:
      - key: environment
        operator: In
        values:
        - staging
        - production
```

Resource manifest (`resource.yaml`):

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: testing-deployment-1
  namespace: testing
  labels:
    app: busybox
spec:
  replicas: 4
  selector:
    matchLabels:
      app: busybox
  template:
    metadata:
      labels:
        app: busybox
    spec:
      containers:
      - name: busybox
        image: busybox:latest
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: testing-deployment-2
  namespace: testing
  labels:
    app: busybox
spec:
  replicas: 2
  selector:
    matchLabels:
      app: busybox
  template:
    metadata:
      labels:
        app: busybox
    spec:
      containers:
      - name: busybox
        image: busybox:latest
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: staging-deployment-1
  namespace: staging
  labels:
    app: nginx
spec:
  replicas: 4
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:latest
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: staging-deployment-2
  namespace: staging
  labels:
    app: nginx
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:latest
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: production-deployment-1
  namespace: production
  labels:
    app: nginx
spec:
  replicas: 4
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:latest
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: production-deployment-2
  namespace: production
  labels:
    app: nginx
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:latest
```

The above resource manifest contains the following:

1. Two Deployments named `testing-deployment-1` and `testing-deployment-2` in the `testing` namespace. The first Deployment has four replicas, while the second Deployment has two.

2. Two Deployments named `staging-deployment-1` and `staging-deployment-2` in the `staging` namespace. The first Deployment has four replicas, while the second Deployment has two.

3. Two Deployments named `production-deployment-1` and `production-deployment-2` in the `production` namespace. The first Deployment has four replicas, while the second Deployment has two.

Variables manifest (`values.yaml`):

```yaml
apiVersion: cli.kyverno.io/v1alpha1
kind: Value
metadata:
  name: values
namespaceSelector:
  - name: staging
    labels:
      environment: staging
  - name: production
    labels:
      environment: production
  - name: testing
    labels:
      environment: testing
```

Test manifest (kyverno-test.yaml):

```yaml
apiVersion: cli.kyverno.io/v1alpha1
kind: Test
metadata:
  name: kyverno-test.yaml
policies:
- policy.yaml
resources:
- resource.yaml
variables: values.yaml
results:
- kind: Deployment
  policy: check-deployment-replicas
  isValidatingAdmissionPolicy: true
  resources:
  - testing-deployment-1
  - testing-deployment-2
  result: skip
- kind: Deployment
  policy: check-deployment-replicas
  isValidatingAdmissionPolicy: true
  resources:
  - staging-deployment-1
  - production-deployment-1
  result: fail
- kind: Deployment
  policy: check-deployment-replicas
  isValidatingAdmissionPolicy: true
  resources:
  - staging-deployment-2
  - production-deployment-2
  result: pass
```

```sh
$ kyverno test .

Loading test  ( kyverno-test.yaml ) ...
  Loading values/variables ...
  Loading policies ...
  Loading resources ...
  Loading exceptions ...
  Applying 1 policy to 6 resources ...
  Checking results ...

│────│───────────────────────────│──────│────────────────────────────────────│────────│──────────│
│ ID │ POLICY                    │ RULE │ RESOURCE                           │ RESULT │ REASON   │
│────│───────────────────────────│──────│────────────────────────────────────│────────│──────────│
│ 1  │ check-deployment-replicas │      │ Deployment/testing-deployment-1    │ Pass   │ Excluded │
│ 2  │ check-deployment-replicas │      │ Deployment/testing-deployment-2    │ Pass   │ Excluded │
│ 3  │ check-deployment-replicas │      │ Deployment/staging-deployment-1    │ Pass   │ Ok       │
│ 4  │ check-deployment-replicas │      │ Deployment/production-deployment-1 │ Pass   │ Ok       │
│ 5  │ check-deployment-replicas │      │ Deployment/staging-deployment-2    │ Pass   │ Ok       │
│ 6  │ check-deployment-replicas │      │ Deployment/production-deployment-2 │ Pass   │ Ok       │
│────│───────────────────────────│──────│────────────────────────────────────│────────│──────────│


Test Summary: 6 tests passed and 0 tests failed
```
