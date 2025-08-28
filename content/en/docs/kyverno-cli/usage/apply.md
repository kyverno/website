---
title: apply
weight: 20
---

The `apply` command is used to perform a dry run on one or more policies with a given set of input resources. This can be useful to determine a policy's effectiveness prior to committing to a cluster. In the case of mutate policies, the `apply` command can show the mutated resource as an output. The input resources can either be resource manifests (one or multiple) or can be taken from a running Kubernetes cluster. The  `apply` command supports files from URLs both as policies and resources.

Apply to a resource:

```sh
kyverno apply /path/to/policy.yaml --resource /path/to/resource.yaml
```

Apply a policy to all matching resources in a cluster based on the current `kubectl` context:

```sh
kyverno apply /path/to/policy.yaml --cluster
```

The resources can also be loaded concurrently in clusters with a large number of resources by configuring the number of parallel workers using the `--concurrent` flag and controlling the number of resources fetched per API call through the `--batch-size` flag. Additionally, the performance of concurrent resource loading can be analyzed by enabling the `--show-performance` flag:

```sh
kyverno apply /path/to/policy.yaml --cluster --concurrent 8 --batch-size 500 --show-performance
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

Apply a policy to a resource with a policy exception: 

```sh
kyverno apply /path/to/policy.yaml --resource /path/to/resource.yaml --exception /path/to/exception.yaml
```
Apply multiple policies to multiple resources with exceptions:

```sh
kyverno apply /path/to/policy1.yaml /path/to/folderFullOfPolicies --resource /path/to/resource1.yaml --resource /path/to/resource2.yaml --exception /path/to/exception1.yaml --exception /path/to/exception2.yaml 
```
Apply multiple policies to multiple resources where exceptions are evaluated from the provided resources:

```sh
kyverno apply /path/to/policy1.yaml /path/to/folderFullOfPolicies --resource /path/to/resource1.yaml --resource /path/to/resource2.yaml --exceptions-with-resources
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

Run a policy with a mutate existing rule on a group of target resources:

```sh
kyverno apply /path/to/policy.yaml --resource /path/to/resource.yaml  --target-resource /path/to/target1.yaml --target-resource /path/to/target2.yaml

Applying 1 policy rule(s) to 1 resource(s)...

mutate policy <policy-name> applied to <trigger-name>:
<trigger-resource>
---
patched targets:

<patched-target1>

---

<patched-target2>

---

pass: 2, fail: 0, warn: 0, error: 0, skip: 0
```

Run a policy with a mutate existing rule on target resources from a directory:

```sh
kyverno apply /path/to/policy.yaml --resource /path/to/resource.yaml  --target-resources /path/to/targets/

Applying 1 policy rule(s) to 1 resource(s)...

mutate policy <policy-name> applied to <trigger-name>:
<trigger-resource>
---
patched targets:

<patched-targets>

pass: 5, fail: 0, warn: 0, error: 0, skip: 0
```


Apply a policy containing variables using the `--set` or `-s` flag to pass in the values. Variables that begin with `{{request.object}}` normally do not need to be specified as these will be read from the resource.

```sh
kyverno apply /path/to/policy.yaml --resource /path/to/resource.yaml --set <variable1>=<value1>,<variable2>=<value2>
```

Use `-f` or `--values-file` for applying multiple policies to multiple resources while passing a file containing variables and their values. Variables specified can be of various types include AdmissionReview fields, ConfigMap context data, API call context data, and Global Context Entries.

Use `-u` or `--userinfo` for applying policies while passing an optional user_info.yaml file which contains necessary admission request data made during the request.

{{% alert title="Note" color="info" %}}
When passing ConfigMap array data into the values file, the data must be formatted as JSON outlined [here](/docs/policy-types/cluster-policy/external-data-sources.md#handling-configmap-array-values).
{{% /alert %}}

```sh
kyverno apply /path/to/policy1.yaml /path/to/policy2.yaml --resource /path/to/resource1.yaml --resource /path/to/resource2.yaml -f /path/to/value.yaml --userinfo /path/to/user_info.yaml
```

Format of `value.yaml` with all possible fields:

```yaml
apiVersion: cli.kyverno.io/v1alpha1
kind: Values
metadata:
  name: values
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
apiVersion: cli.kyverno.io/v1alpha1
kind: UserInfo
metadata:
  name: user-info
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
  background: false
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
apiVersion: cli.kyverno.io/v1alpha1
kind: Values
metadata:
  name: values
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
apiVersion: cli.kyverno.io/v1alpha1
kind: Values
metadata:
  name: values
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
  background: false
  rules:
    - name: validate-mode
      match:
        any:
        - resources:
            kinds:
              - Pod
      validate:
        failureAction: Enforce
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
apiVersion: cli.kyverno.io/v1alpha1
kind: Values
metadata:
  name: values
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

Use `--values-file` or `-f` for passing a file containing Namespace details. Check [here](/docs/policy-types/cluster-policy/match-exclude.md#match-deployments-in-namespaces-using-labels) to know more about Namespace selectors.

```sh
kyverno apply /path/to/policy1.yaml /path/to/policy2.yaml --resource /path/to/resource1.yaml --resource /path/to/resource2.yaml -f /path/to/value.yaml
```

Format of `value.yaml`:

```yaml
apiVersion: cli.kyverno.io/v1alpha1
kind: Values
metadata:
  name: values
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
        failureAction: Audit
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
apiVersion: cli.kyverno.io/v1alpha1
kind: Values
metadata:
  name: values
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
apiVersion: cli.kyverno.io/v1alpha1
kind: Values
metadata:
  name: values
policies:
  - name: cm-variable-example
    rules:
      - name: example-configmap-lookup
        values:
          dictionary.data.env: dev1
```

You can also inject global context entries using variables. Here's an example of a Values file that injects a global context entry:

```yaml
apiVersion: cli.kyverno.io/v1alpha1
kind: Value
metadata:
  name: values
globalValues:
  request.operation: CREATE
policies:
  - name: gctx
    rules:
      - name: main-deployment-exists
        values:
          deploymentCount: 1
```

In this example, `request.operation` is set as a global value, and `deploymentCount` is set for a specific rule in the `gctx` policy.

Policies that have their failureAction set to `Audit` can be set to produce a warning instead of a failure using the `--audit-warn` flag. This will also cause a non-zero exit code if no enforcing policies failed.

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

### Policy Report

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
  rules:
  - name: validate-resources
    match:
      any:
      - resources:
          kinds:
          - Pod
    validate:
      failureAction: Audit
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

### Applying Policy Exceptions

[Policy Exceptions](/docs/policy-types/cluster-policy/exceptions.md) can be applied alongside policies by using the `-e` or `--exceptions` flag to pass the Policy Exception manifest.

```sh
kyverno apply /path/to/policy.yaml --resource /path/to/resource.yaml --exception /path/to/exception.yaml
```

Example:

Applying a policy to a resource with a policy exception.

Policy manifest (`policy.yaml`):

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: max-containers
spec:
  background: false
  rules:
  - name: max-two-containers
    match:
      any:
      - resources:
          kinds:
          - Pod
    validate:
      failureAction: Enforce
      message: "A maximum of 2 containers are allowed inside a Pod."
      deny:
        conditions:
          any:
          - key: "{{request.object.spec.containers[] | length(@)}}"
            operator: GreaterThan
            value: 2
```

Policy Exception manifest (`exception.yaml`):

```yaml
apiVersion: kyverno.io/v2
kind: PolicyException
metadata:
  name: container-exception
spec:
  exceptions:
  - policyName: max-containers
    ruleNames:
    - max-two-containers
    - autogen-max-two-containers
  match:
    any:
    - resources:
        kinds:
        - Pod
        - Deployment
  conditions:
    any:
    - key: "{{ request.object.metadata.labels.color || '' }}"
      operator: Equals
      value: blue
```

Resource manifest (`resource.yaml`):

A Deployment matching the characteristics defined in the PolicyException, shown below, will be allowed creation even though it technically violates the rule’s definition.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: three-containers-deployment
  labels:
    app: my-app
    color: blue
spec:
  replicas: 3
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
        color: blue
    spec:
      containers:
        - name: nginx-container
          image: nginx:latest
          ports:
            - containerPort: 80
        - name: redis-container
          image: redis:latest
          ports:
            - containerPort: 6379
        - name: busybox-container
          image: busybox:latest
          command: ["/bin/sh", "-c", "while true; do echo 'Hello from BusyBox'; sleep 10; done"]    
```

Apply the above policy to the resource with the exception

```sh
kyverno apply /path/to/policy.yaml --resource /path/to/resource.yaml --exception /path/to/exception.yaml
```

The following output will be generated:

```yaml
Applying 3 policy rule(s) to 1 resource(s) with 1 exception(s)...

pass: 0, fail: 0, warn: 0, error: 0, skip: 1 
```

### Kubernetes Native Policies

The `kyverno apply` command can be used to apply native Kubernetes policies and their corresponding bindings to resources, allowing you to test them locally without a cluster.

#### ValidatingAdmissionPolicy

With the `apply` command, Kubernetes ValidatingAdmissionPolicies can be applied to resources as follows:

Policy manifest (check-deployment-replicas.yaml):

```yaml
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingAdmissionPolicy
metadata:
  name: check-deployments-replicas
spec:
  failurePolicy: Fail
  matchConstraints:
    resourceRules:
    - apiGroups:   ["apps"]
      apiVersions: ["v1"]
      operations:  ["CREATE", "UPDATE"]
      resources:   ["deployments"]
  validations:
    - expression: "object.spec.replicas <= 3"
      message: "Replicas must be less than or equal 3"
```

Resource manifest (deployment.yaml):

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-pass
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx-pass
  template:
    metadata:
      labels:
        app: nginx-pass
    spec:
      containers:
      - name: nginx-server
        image: nginx
```

Apply the ValidatingAdmissionPolicy to the resource:

```sh
kyverno apply /path/to/check-deployment-replicas.yaml --resource /path/to/deployment.yaml
```

The following output will be generated:

```sh
Applying 1 policy rule(s) to 1 resource(s)...

pass: 1, fail: 0, warn: 0, error: 0, skip: 0 
```

The below example applies a `ValidatingAdmissionPolicyBinding` along with the policy to all resources in the cluster.

Policy manifest (check-deployment-replicas.yaml):
```yaml
apiVersion: admissionregistration.k8s.io/v1
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
  - expression: object.spec.replicas <= 5
---
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingAdmissionPolicyBinding
metadata:
  name: "check-deployment-replicas-binding"
spec:
  policyName: "check-deployment-replicas"
  validationActions: [Deny]
  matchResources:
    namespaceSelector:
      matchLabels:
        environment: staging
```

The above policy verifies that the number of deployment replicas is not greater than 5 and is limited to a namespace labeled `environment: staging`.

Create a Namespace with the label `environment: staging`:

```bash
kubectl create ns staging
kubectl label ns staging environment=staging
```

Create two Deployments, one of them in the `staging` namespace, which violates the policy.

```bash
kubectl create deployment nginx-1 --image=nginx --replicas=6 -n staging
kubectl create deployment nginx-2 --image=nginx --replicas=6
```

Get all Deployments from the cluster:

```bash
kubectl get deployments -A

NAMESPACE            NAME                     READY   UP-TO-DATE   AVAILABLE   AGE
default              nginx-2                  6/6     6            6           7m26s
kube-system          coredns                  2/2     2            2           13m
local-path-storage   local-path-provisioner   1/1     1            1           13m
staging              nginx-1                  6/6     6            6           7m44s
```

Apply the ValidatingAdmissionPolicy with its binding to all resources in the cluster:

```bash
kyverno apply /path/to/check-deployment-replicas.yaml --cluster --policy-report
```

The following output will be generated:

```bash
Applying 1 policy rule(s) to 4 resource(s)...
----------------------------------------------------------------------
POLICY REPORT:
----------------------------------------------------------------------
apiVersion: wgpolicyk8s.io/v1alpha2
kind: ClusterPolicyReport
metadata:
  creationTimestamp: null
  name: merged
results:
- message: 'failed expression: object.spec.replicas <= 5'
  policy: check-deployment-replicas
  resources:
  - apiVersion: apps/v1
    kind: Deployment
    name: nginx-1
    namespace: staging
    uid: a95d1594-44a7-4c8a-9225-04ac34cb9494
  result: fail
  scored: true
  source: kyverno
  timestamp:
    nanos: 0
    seconds: 1707394871
summary:
  error: 0
  fail: 1
  pass: 0
  skip: 0
  warn: 0
```

As expected, the policy is only applied to `nginx-1` as it matches both the policy definition and its binding.

#### MutatingAdmissionPolicy

Similarly, you can test a MutatingAdmissionPolicy to preview the changes it would make to a resource. The CLI will output the final, mutated resource.

##### Example 1: Basic Mutation

For instance, you can test a MutatingAdmissionPolicy that adds a label to a ConfigMap.

Policy manifest (add-label-to-configmap.yaml):

```yaml
apiVersion: admissionregistration.k8s.io/v1alpha1
kind: MutatingAdmissionPolicy
metadata:
  name: "add-label-to-configmap"
spec:
  matchConstraints:
    resourceRules:
    - apiGroups:   [""]
      apiVersions: ["v1"]
      operations:  ["CREATE"]
      resources:   ["configmaps"]
  failurePolicy: Fail
  reinvocationPolicy: Never
  mutations:
    - patchType: "ApplyConfiguration"
      applyConfiguration:
        expression: >
          object.metadata.?labels["lfx-mentorship"].hasValue() ? 
              Object{} :
              Object{ metadata: Object.metadata{ labels: {"lfx-mentorship": "kyverno"}}}
```

Resource manifest (configmap.yaml):

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: game-demo
  labels:
    app: game
data:
  player_initial_lives: "3"
```

Now, apply the MutatingAdmissionPolicy to the ConfigMap resource:

```bash
kyverno apply /path/to/add-label-to-configmap.yaml --resource /path/to/configmap.yaml
```

The output will show the mutated ConfigMap with the added label:

```bash
Applying 1 policy rule(s) to 1 resource(s)...

policy add-label-to-configmap applied to default/ConfigMap/game-demo:
apiVersion: v1
data:
  player_initial_lives: "3"
kind: ConfigMap
metadata:
  labels:
    app: game
    lfx-mentorship: kyverno
  name: game-demo
  namespace: default
---

Mutation has been applied successfully.
pass: 1, fail: 0, warn: 0, error: 0, skip: 0 
```

The output displays the ConfigMap with the new `lfx-mentorship: kyverno` label, confirming the mutation was applied correctly.

##### Example 2: Mutation with a Binding and Namespace Selector

You can also test policies that include a MutatingAdmissionPolicyBinding to control where the policy is applied. This example makes use of a namespace selector to apply the policy only to ConfigMaps in a specific namespace.

To do this, you must provide a `values.yaml` file to simulate the labels of the Namespaces your resources belong to.

Policy manifest (add-label-to-configmap.yaml):

This file defines a policy to add a label and a binding that restricts it to Namespaces labeled `environment: staging` or `environment: production`.

```yaml
apiVersion: admissionregistration.k8s.io/v1alpha1
kind: MutatingAdmissionPolicy
metadata:
  name: "add-label-to-configmap"
spec:
  matchConstraints:
    resourceRules:
    - apiGroups:   [""]
      apiVersions: ["v1"]
      operations:  ["CREATE"]
      resources:   ["configmaps"]
  failurePolicy: Fail
  reinvocationPolicy: Never
  mutations:
    - patchType: "ApplyConfiguration"
      applyConfiguration:
        expression: >
          object.metadata.?labels["lfx-mentorship"].hasValue() ? 
              Object{} :
              Object{ metadata: Object.metadata{ labels: {"lfx-mentorship": "kyverno"}}}
---
apiVersion: admissionregistration.k8s.io/v1alpha1
kind: MutatingAdmissionPolicyBinding
metadata:
  name: "add-label-to-configmap-binding"
spec:
  policyName: "add-label-to-configmap"
  matchResources:
    namespaceSelector:
      matchExpressions:
      - key: environment
        operator: In
        values:
        - staging
        - production
```

Resource manifest (configmaps.yaml):

This file contains three ConfigMap resources in different Namespaces. Only the ones in staging and production should be mutated.

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: matched-cm-1
  namespace: staging
  labels:
    color: red
data:
  player_initial_lives: "3"
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: matched-cm-2
  namespace: production
  labels:
    color: red
data:
  player_initial_lives: "3"
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: unmatched-cm
  namespace: testing
  labels:
    color: blue
data:
  player_initial_lives: "3"
```

Values file (values.yaml):

This file provides the necessary context. It tells the Kyverno CLI what labels are associated with the staging, production, and testing Namespaces so it can correctly evaluate the namespaceSelector in the binding.

```yaml
apiVersion: cli.kyverno.io/v1alpha1
kind: Value
metadata:
  name: values
namespaceSelector:
- labels:
    environment: staging
  name: staging
- labels:
    environment: production
  name: production
- labels:
    environment: testing
  name: testing
```

Now, apply the MutatingAdmissionPolicy and its binding to the ConfigMaps:

```bash
kyverno apply /path/to/add-label-to-configmap.yaml --resource /path/to/configmaps.yaml -f /path/to/values.yaml
```

The output will show the mutated ConfigMaps in the staging and production Namespaces, while the one in the testing Namespace remains unchanged:

```bash
Applying 1 policy rule(s) to 3 resource(s)...

policy add-label-to-configmap applied to staging/ConfigMap/matched-cm-1:
apiVersion: v1
data:
  player_initial_lives: "3"
kind: ConfigMap
metadata:
  labels:
    color: red
    lfx-mentorship: kyverno
  name: matched-cm-1
  namespace: staging
---

Mutation has been applied successfully.
policy add-label-to-configmap applied to production/ConfigMap/matched-cm-2:
apiVersion: v1
data:
  player_initial_lives: "3"
kind: ConfigMap
metadata:
  labels:
    color: red
    lfx-mentorship: kyverno
  name: matched-cm-2
  namespace: production
---

Mutation has been applied successfully.
pass: 2, fail: 0, warn: 0, error: 0, skip: 0
```

### Applying ValidatingPolicies

In this example, we will apply a `ValidatingPolicy` against two `Deployment` manifests: one that complies with the policy and one that violates it.

First, we define a `ValidatingPolicy` that ensures any `Deployment` has no more than two replicas.

Policy manifest (check-deployment-replicas.yaml):

```yaml
apiVersion: policies.kyverno.io/v1alpha1
kind: ValidatingPolicy
metadata:
  name: check-deployment-replicas
spec:
  matchConstraints:
    resourceRules:
    - apiGroups:   ["apps"]
      apiVersions: ["v1"]
      operations:  ["CREATE", "UPDATE"]
      resources:   ["deployments"]
  validations:
    - expression: "object.spec.replicas <= 2"
      message: "Deployment replicas must be less than or equal to 2"
```

Next, we have two `Deployment` manifests. The `good-deployment` is compliant with 2 replicas, while the `bad-deployment` is non-compliant with 3 replicas.

Resource manifest (deployments.yaml):

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: good-deployment
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
  name: bad-deployment
  labels:
    app: nginx
spec:
  replicas: 3
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

Now, we use the `kyverno apply` command to test the policy against both resources.

```bash
kyverno apply /path/to/check-deployment-replicas.yaml --resource /path/to/deployments.yaml --policy-report
```

The following output will be generated:

```bash
apiVersion: openreports.io/v1alpha1
kind: ClusterReport
metadata:
  creationTimestamp: null
  name: merged
results:
- message: Deployment replicas must be less than or equal 2
  policy: check-deployment-replicas
  properties:
    process: background scan
  resources:
  - apiVersion: apps/v1
    kind: Deployment
    name: bad-deployment
    namespace: default
  result: fail
  scored: true
  source: KyvernoValidatingPolicy
  timestamp:
    nanos: 0
    seconds: 1752755472
- message: success
  policy: check-deployment-replicas
  properties:
    process: background scan
  resources:
  - apiVersion: apps/v1
    kind: Deployment
    name: good-deployment
    namespace: default
  result: pass
  scored: true
  source: KyvernoValidatingPolicy
  timestamp:
    nanos: 0
    seconds: 1752755472
source: ""
summary:
  error: 0
  fail: 1
  pass: 1
  skip: 0
  warn: 0
```

In addition to testing local YAML files, you can use the `kyverno apply` command to validate policies against resources that are already running in a Kubernetes cluster. Instead of specifying resource files with the `--resource` flag, you can use the `--cluster` flag.

For example, to test the `check-deployment-replicas` policy against all Deployment resources in your currently active cluster, you would run:

```bash
kyverno apply /path/to/check-deployment-replicas.yaml --cluster --policy-report
```

Many advanced policies need to look up the state of other resources in the cluster using [Kyverno's custom CEL functions](/docs/policy-types/validating-policy/#kyverno-cel-libraries) like `resource.Get()`. When testing such policies locally with the `kyverno apply` command, the CLI cannot connect to the cluster to retrieve the required resources so you have to provide these resources as input via the `--context-path` flag. 

This flag allows you to specify the resources that the policy will reference. The CLI will then use these resources to evaluate the policy.

This example demonstrates how to test a policy that validates an incoming Pod by checking its name against a value stored in a ConfigMap.

First, we define a `ValidatingPolicy` that uses `resource.Get()` to fetch a ConfigMap named `policy-cm`. The policy then validates that the incoming Pod's name matches the `name` key in the ConfigMap's data.

Policy manifest (check-pod-name-from-configmap.yaml):

```yaml
apiVersion: policies.kyverno.io/v1alpha1
kind: ValidatingPolicy
metadata:
  name: check-pod-name-from-configmap
spec:
  matchConstraints:
    resourceRules:
    - apiGroups:   [""]
      apiVersions: ["v1"]
      operations:  ["CREATE", "UPDATE"]
      resources:   ["pods"]
  variables:
    # This variable uses a Kyverno CEL function to get a ConfigMap from the cluster.
    - name: cm
      expression: >-
        resource.Get("v1", "configmaps", object.metadata.namespace, "policy-cm")
  validations:
    # This rule validates that the Pod's name matches the 'name' key in the ConfigMap's data.
    - expression: >-
        object.metadata.name == variables.cm.data.name
```

Next, we define two Pod manifests: `good-pod`, which should pass the validation, and `bad-pod`, which should fail.

Resource manifest (pods.yaml):

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: good-pod
spec:
  containers:
  - name: nginx
    image: nginx
---
apiVersion: v1
kind: Pod
metadata:
  name: bad-pod
spec:
  containers:
  - name: nginx
    image: nginx
```

Because the CLI cannot connect to a cluster to fetch the `policy-cm` ConfigMap, we must provide it in a context file. This file contains a mock ConfigMap that `resource.Get()` will use during local evaluation.

Context file (context.yaml):

```yaml
apiVersion: cli.kyverno.io/v1alpha1
kind: Context
metadata:
  name: context
spec:
  # The resources defined here will be available to functions like resource.Get()
  resources:
  - apiVersion: v1
    kind: ConfigMap
    metadata:
      namespace: default
      name: policy-cm
    data:
      # According to this, the valid pod name is 'good-pod'.
      name: good-pod
```

Now, we can run the `kyverno apply` command, providing the policy, the resources, and the context file. We also use the `-p` (or `--policy-report`) flag to generate a ClusterReport detailing the results.

```bash
kyverno apply /path/to/policy.yaml --resource /path/to/pods.yaml --context-file /path/to/context.yaml -p
```

The following output will be generated:

```yaml
apiVersion: openreports.io/v1alpha1
kind: ClusterReport
metadata:
  creationTimestamp: null
  name: merged
results:
- message: success
  policy: check-pod-name-from-configmap
  properties:
    process: background scan
  resources:
  - apiVersion: v1
    kind: Pod
    name: good-pod
    namespace: default
  result: pass
  scored: true
  source: KyvernoValidatingPolicy
  timestamp:
    nanos: 0
    seconds: 1752756617
- policy: check-pod-name-from-configmap
  properties:
    process: background scan
  resources:
  - apiVersion: v1
    kind: Pod
    name: bad-pod
    namespace: default
  result: fail
  scored: true
  source: KyvernoValidatingPolicy
  timestamp:
    nanos: 0
    seconds: 1752756617
source: ""
summary:
  error: 0
  fail: 1
  pass: 1
  skip: 0
  warn: 0
```

- The `good-pod` resource resulted in a `pass` because its name matches the value in the ConfigMap provided by the context file.

- The `bad-pod` resource resulted in a `fail` because its name does not match, and the report includes the validation error message from the policy.

When using the `--cluster` flag, the CLI connects to your active Kubernetes cluster, so a local context file is not needed. The `resource.Get()` function will fetch the live ConfigMap directly from the cluster so you have to ensure the ConfigMap and the Pod resources exist in your cluster before running the command.

```bash
kyverno apply /path/to/check-pod-name-from-configmap.yaml --cluster --policy-report
```

In case of applying a `ValidatingPolicy` with a `PolicyException`, you can use the `--exception` flag to specify the exception manifest. The CLI will then apply the policy and the exception together.

In this example, we will test a policy that disallows `hostPath` volumes, but we will use a PolicyException to create an exemption for a specific Pod.

Policy manifest (disallow-host-path.yaml):

```yaml
apiVersion: policies.kyverno.io/v1alpha1
kind: ValidatingPolicy
metadata:
  name: disallow-host-path
spec:
  matchConstraints:
    resourceRules:
    - apiGroups:   [""]
      apiVersions: ["v1"]
      operations:  ["CREATE", "UPDATE"]
      resources:   ["pods"]
  validations:
    - expression: "!has(object.spec.volumes) || object.spec.volumes.all(volume, !has(volume.hostPath))"
      message: "HostPath volumes are forbidden. The field spec.volumes[*].hostPath must be unset."
```

Next, we define a Pod that clearly violates this policy by mounting a `hostPath` volume. Without an exception, this Pod would be blocked.

Resource manifest (pod-with-hostpath.yaml):

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod-with-hostpath
spec:
  containers:
  - name: nginx
    image: nginx
  volumes:
  - name: udev
    hostPath:
      path: /etc/udev
```

Now, we create a PolicyException to exempt our specific Pod from this policy. The exception matches the Pod by name and references the `disallow-host-path` policy.

Policy Exception manifest (exception.yaml):

```yaml
apiVersion: policies.kyverno.io/v1alpha1
kind: PolicyException
metadata:
  name: exempt-hostpath-pod
spec:
  policyRefs:
  - name: disallow-host-path
    kind: ValidatingPolicy
  matchConditions:
    - name: "skip-pod-by-name"
      expression: "object.metadata.name == 'pod-with-hostpath'"
```

Now, we use the `kyverno apply` command, providing the policy, the resource, and the exception using the `--exception` flag. We will also use `-p` to generate a detailed report.

```bash
kyverno apply policy.yaml --resource resource.yaml --exception exception.yaml -p
```

The following output will be generated:

```yaml
apiVersion: openreports.io/v1alpha1
kind: ClusterReport
metadata:
  creationTimestamp: null
  name: merged
results:
- message: 'rule is skipped due to policy exception: exempt-hostpath-pod'
  policy: disallow-host-path
  properties:
    exceptions: exempt-hostpath-pod
    process: background scan
  resources:
  - apiVersion: v1
    kind: Pod
    name: pod-with-hostpath
    namespace: default
  result: skip
  rule: exception
  scored: true
  source: KyvernoValidatingPolicy
  timestamp:
    nanos: 0
    seconds: 1752759828
source: ""
summary:
  error: 0
  fail: 0
  pass: 0
  skip: 1
  warn: 0
```

The output confirms that the PolicyException worked as intended:
- `result: skip`: The policy rule was not enforced on the resource.

- `properties.exceptions: exempt-hostpath-pod`: The report explicitly names the PolicyException responsible for the skip.

- `summary.skip: 1`: The final count reflects that one rule was skipped.
