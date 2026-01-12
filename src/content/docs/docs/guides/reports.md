---
title: Policy Reports
description: View and audit Kyverno policy results with reports.
sidebar:
  order: 1
---

Policy reports are Kubernetes Custom Resources, generated and managed automatically by Kyverno, which contain the results of applying matching Kubernetes resources to Kyverno ClusterPolicy or Policy resources. They are created for `validate`, `mutate`, `generate` and `verifyImages` rules when a resource is matched by one or more rules according to the policy definition. If resources violate multiple rules, there will be multiple entries. When resources are deleted, their entry will be removed from the report. Reports, therefore, always represent the current state of the cluster and do not record historical information.

For example, if a validate policy in `Audit` mode exists containing a single rule which requires that all resources set the label `team` and a user creates a Pod which does not set the `team` label, Kyverno will allow the Pod's creation but record it as a `fail` result in a policy report due to the Pod being in violation of the policy and rule. Policies configured with `spec.rules[*].validate[*].failureAction: Enforce` immediately block violating resources and results will only be reported for `pass` evaluations. Policy reports are an ideal way to observe the impact a Kyverno policy may have in a cluster without causing disruption. The insights gained from these policy reports may be used to provide valuable feedback to both users/developers so they may take appropriate action to bring offending resources into alignment, and to policy authors or cluster operators to help them refine policies prior to changing them to `Enforce` mode. Because reports are decoupled from policies, standard Kubernetes RBAC can then be applied to separate those who can see and manipulate policies from those who can view reports.

Policy reports are created based on two different triggers: an admission event (a `CREATE`, `UPDATE`, or `DELETE` action performed against a resource) or the result of a background scan discovering existing resources. Policy reports, like Kyverno policies, have both Namespaced and cluster-scoped variants; a `PolicyReport` is a Namespaced resource while a `ClusterPolicyReport` is a cluster-scoped resource. Reports are stored in the cluster on a per resource basis. Every namespaced resource will (eventually) have an associated `PolicyReport` and every clustered resource will (eventually) have an associated `ClusterPolicyReport`.

Kyverno uses a standard and open format published by the [Kubernetes Policy working group](https://github.com/kubernetes-sigs/wg-policy-prototypes/tree/master/policy-report) which proposes a common policy report format across Kubernetes tools. Below is an example of a `PolicyReport` generated for a `Pod` which shows passing and failed rules.

```yaml
apiVersion: wgpolicyk8s.io/v1alpha2
kind: PolicyReport
metadata:
  creationTimestamp: '2023-12-06T13:19:03Z'
  generation: 2
  labels:
    app.kubernetes.io/managed-by: kyverno
  name: 487df031-11d8-4ab4-b089-dfc0db1e533e
  namespace: kube-system
  ownerReferences:
    - apiVersion: v1
      kind: Pod
      name: kube-apiserver-kind-control-plane
      uid: 487df031-11d8-4ab4-b089-dfc0db1e533e
  resourceVersion: '720507'
  uid: 0ec04a57-4c3d-492d-9278-951cd1929fe3
results:
  - category: Pod Security Standards (Baseline)
    message: validation rule 'adding-capabilities' passed.
    policy: disallow-capabilities
    result: pass
    rule: adding-capabilities
    scored: true
    severity: medium
    source: kyverno
    timestamp:
      nanos: 0
      seconds: 1701868762
  - category: Pod Security Standards (Baseline)
    message:
      'validation error: Sharing the host namespaces is disallowed. The fields
      spec.hostNetwork, spec.hostIPC, and spec.hostPID must be unset or set to `false`.
      rule host-namespaces failed at path /spec/hostNetwork/'
    policy: disallow-host-namespaces
    result: fail
    rule: host-namespaces
    scored: true
    severity: medium
    source: kyverno
    timestamp:
      nanos: 0
      seconds: 1701868762
# ...
scope:
  apiVersion: v1
  kind: Pod
  name: kube-apiserver-kind-control-plane
  namespace: kube-system
  uid: 487df031-11d8-4ab4-b089-dfc0db1e533e
summary:
  error: 0
  fail: 2
  pass: 10
  skip: 0
  warn: 0
```

The report's contents can be found under the `results[]` object in which it displays a number of fields including the resource that was matched against the rule in the parent policy.

:::note[Note]
Policy reports show policy results for current resources in the cluster only. For information on resources that were blocked during admission controls, use the [policy rule execution metric](/docs/monitoring/policy-results-info) or inspect Kubernetes Events on the corresponding Kyverno policy. A `Pod/exec` subresource is not capable of producing an entry in a policy report due to API limitations.
:::

Policy reports have a few configuration options available. For details, see the [container flags](/docs/installation/customization#container-flags) section.

:::caution[Note]
Policy reports created from background scans are not subject to the configuration of a [Namespace selector](/docs/installation/customization#namespace-selectors) defined in the [Kyverno ConfigMap](/docs/installation/customization#configmap-keys).
:::

:::note[Note]
To configure Kyverno to generate reports for Kubernetes ValidatingAdmissionPolicies enable the `--validatingAdmissionPolicyReports` flag in the reports controller.
:::

:::note[Note]
Reporting can be enabled or disabled for rule types by modifying the value of the flag `--enableReporting=validate,mutate,mutateExisting,generate,imageVerify`.
:::

:::note[Note]
Creating reports for a resource require permissions to `get`, `list` and `watch` the resource in Kyverno reports controller.
:::

## Report result logic

Entries in a policy report contain a `result` field which can be either `pass`, `skip`, `warn`, `error`, or `fail`.

| Result | Description                                                                                                                                      |
| ------ | ------------------------------------------------------------------------------------------------------------------------------------------------ |
| pass   | The resource was applicable to a rule and the pattern passed evaluation.                                                                         |
| skip   | Preconditions were not satisfied (if applicable) in a rule, or an applicable PolicyException exists and so further processing was not performed. |
| fail   | The resource failed the pattern evaluation.                                                                                                      |
| warn   | The annotation `policies.kyverno.io/scored` has been set to `"false"` in the policy converting otherwise `fail` results to `warn`.               |
| error  | Variable substitution failed outside of preconditions and elsewhere in the rule (ex., in the pattern).                                           |

### Scenarios for Skip results

A `skip` result signifies that Kyverno decided not to evaluate the resource against a specific rule. This is different from a pass where the resource was evaluated and deemed compliant. A `skip` means the rule was essentially bypassed.

Here's a breakdown of common scenarios resulting in a `skip`:

1. **Preconditions Not Met:**

This is the most frequent reason for a skip. If a rule has preconditions defined and any of the conditions within the any or all blocks evaluate to FALSE, the entire rule is skipped. Kyverno won't even attempt to apply the pattern, effectively bypassing the rule.

2. **Policy Exceptions:**

Kyverno allows you to define exceptions to policies using PolicyException resources. If an exception exists that matches a specific resource and rule, Kyverno will skip the rule for that resource.

3. **Conditional Anchors `()` with Unmet Conditions:**

When using a conditional anchor, the corresponding section is skipped if the condition within the anchor evaluates to FALSE.

4. **Global Anchors `<()` with Unmet Conditions:**

Similar to conditional anchors, if the condition inside a global anchor is FALSE, the entire rule is skipped. The difference is that global anchors apply to the whole rule, not just a specific section.

5. **Anchor Logic Resulting in Skip:**

As explained in the [validate documentation](/docs/policy-types/cluster-policy/validate), a combination of anchors and their evaluation results can lead to a skip. Specifically, a conditional anchor might be skipped, but if it's a sibling to another condition that results in a pass or fail, the overall result will reflect that of the sibling, potentially masking the skip.

_Example:_ If we have the following policy:

```yaml
spec:
  =(initContainers):
    - (name): '!istio-init'
      =(securityContext):
        =(runAsUser): '>0'
  =(containers):
    - =(securityContext):
        =(runAsUser): '>0'
```

The following resource would result in pass:

```yaml
spec:
  initContainers:
    - name: istio-init
      securityContext:
        runAsUser: 0
  containers:
    - name: nginx
      image: nginx
```

That's because for the `initContainers` block the condition isn't met so it's a skip. But the `containers` block is a pass. So the overall result is a pass.

**Key Points to Remember:**

- A skip result is not a failure; it's a deliberate bypass based on predefined conditions or exceptions.
- Understanding the distinction between pass and skip is crucial for accurately interpreting policy report data.
- When troubleshooting a skip, carefully examine preconditions, exceptions, and the logic within your anchors to pinpoint the reason for the bypass.

## Viewing report summaries

You can view a summary of the Namespaced policy reports using the following command:

```sh
kubectl get policyreport -A
```

For example, below are the policy reports found in the `kube-system` namespace of a small test cluster created with kind.

```sh
$ kubectl get polr -n kube-system -o wide
NAME                                   KIND         NAME                                         PASS   FAIL   WARN   ERROR   SKIP   AGE
049a4ec1-32a5-4417-9184-1a59cfaa1ca6   DaemonSet    kindnet                                      9      3      0      0       0      16m
049d2cca-c30f-4f26-a70a-dfcc2cc5f433   DaemonSet    kube-proxy                                   9      3      0      0       0      16m
1d491ec4-ca84-4b3a-960a-a2aefa3219ba   Pod          kube-controller-manager-kind-control-plane   10     2      0      0       0      16m
34fa05b8-40cc-4bd3-836e-077abf4c126e   Pod          kindnet-qtq54                                9      3      0      0       0      16m
3997d5d0-363a-4820-8768-4be3788b3968   Pod          kube-proxy-tcgcz                             9      3      0      0       0      16m
4434c0ac-e27f-41eb-b4c2-b1a7aca8056a   ReplicaSet   coredns-5dd5756b68                           12     0      0      0       0      16m
487df031-11d8-4ab4-b089-dfc0db1e533e   Pod          kube-apiserver-kind-control-plane            10     2      0      0       0      16m
553c0601-b995-4ed8-a36b-11e7cb38893b   Pod          kube-proxy-jdsck                             9      3      0      0       0      16m
89044d72-8a1e-4af0-877b-9be727dc3ec4   Pod          kindnet-7rrns                                9      3      0      0       0      16m
9eb8c5c0-fe5c-4c7d-96c3-3ff65c361f4f   Pod          etcd-kind-control-plane                      10     2      0      0       0      16m
b7968d37-4337-4756-bfe8-3c111f7a7356   Pod          kube-proxy-ncvxk                             9      3      0      0       0      16m
cc894ef1-6a45-44e0-99f6-3765a59088e7   Pod          kube-scheduler-kind-control-plane            10     2      0      0       0      16m
cf538bcc-4752-45d4-9712-480c425dc8d3   Pod          kindnet-c8fv6                                9      3      0      0       0      16m
d9ea5169-17a7-458d-a971-09028a73cddd   Pod          coredns-5dd5756b68-z5whj                     12     0      0      0       0      16m
e23946aa-17c3-4b96-b72b-eb7fd72eba62   Deployment   coredns                                      12     0      0      0       0      16m
e666a741-c9cf-499c-a9c7-b8e0c600239a   Pod          kindnet-2rkgr                                9      3      0      0       0      16m
e6f5aa6a-74e0-4c30-bb2b-1a6ee046e5ad   Pod          coredns-5dd5756b68-tnv25                     12     0      0      0       0      16m
fd2aa944-3fc7-42b0-a6c0-1304e0aa473f   Pod          kube-proxy-p4x82                             9      3      0      0       0      16m
```

Similarly, you can view the cluster-wide report using:

```sh
kubectl get clusterpolicyreport
```

:::note[Tip]
Note that the name of the report is mostly random. Add `-o wide` to show additional information that will help identify the resource associated with the report.
:::

:::note[Tip]
For a graphical view of Policy Reports, check out [Policy Reporter](https://github.com/kyverno/policy-reporter#readme).
:::

## Viewing policy violations

Since the report provides information on all rule and resource execution, returning only select entries requires a filter expression.

Policy reports can be inspected using either `kubectl describe` or `kubectl get`. For example, here is a command, requiring `yq`, to view only failures for the (Namespaced) report `1d491ec4-ca84-4b3a-960a-a2aefa3219ba`:

```sh
kubectl get polr 1d491ec4-ca84-4b3a-960a-a2aefa3219ba -o jsonpath='{.results[?(@.result=="fail")]}' | yq -p json -
```

```yaml
category: Pod Security Standards (Baseline)
message: 'validation error: Privileged mode is disallowed. The fields spec.containers[*].securityContext.privileged and spec.initContainers[*].securityContext.privileged must be unset or set to `false`.          . rule privileged-containers failed at path /spec/containers/0/securityContext/privileged/'
policy: disallow-privileged-containers
result: fail
rule: privileged-containers
scored: true
severity: medium
source: kyverno
timestamp:
  nanos: 0
  seconds: 1.666094801e+09
---
category: Pod Security Standards (Baseline)
message: 'validation error: Privileged mode is disallowed. The fields spec.containers[*].securityContext.privileged and spec.initContainers[*].securityContext.privileged must be unset or set to `false`.          . rule privileged-containers failed at path /spec/containers/0/securityContext/privileged/'
policy: disallow-privileged-containers
result: fail
rule: privileged-containers
scored: true
severity: medium
source: kyverno
timestamp:
  nanos: 0
  seconds: 1.666095335e+09
```

## Report internals

The `PolicyReport` and `ClusterPolicyReport` are the final resources composed of matching resources as determined by Kyverno `Policy` and `ClusterPolicy` objects, however these reports are built of four intermediary resources. For matching resources which were caught during admission mode, `AdmissionReport` and `ClusterAdmissionReport` resources are created. For results of background processing, `BackgroundScanReport` and `ClusterBackgroundScanReport` resources are created. An example of a `ClusterAdmissionReport` is shown below.

:::note[Note]
As of kyverno 1.16, you can add the label `reports.kyverno.io/disabled` with any value to a policy of any type (YAML, CEL or VAP/MAP), which will result in no reports of any kind (ephemeral or permanent) be generated for this policy
:::

```yaml
apiVersion: kyverno.io/v1alpha2
kind: ClusterAdmissionReport
metadata:
  creationTimestamp: '2022-10-18T13:15:09Z'
  generation: 1
  labels:
    app.kubernetes.io/managed-by: kyverno
    audit.kyverno.io/resource.hash: a7ec5160f220c5b83c26b5c8f7dc35b6
    audit.kyverno.io/resource.uid: 61946422-14ba-4aa2-94b4-229d38446381
    cpol.kyverno.io/require-ns-labels: '4773'
  name: c0cc7337-9bcd-4d53-abb2-93f7f5555216
  resourceVersion: '4986'
  uid: 10babc6c-9e6e-4386-abed-c13f50091523
spec:
  owner:
    apiVersion: v1
    kind: Namespace
    name: testing
    uid: 61946422-14ba-4aa2-94b4-229d38446381
  results:
    - message:
        'validation error: The label `thisshouldntexist` is required. rule check-for-labels-on-namespace
        failed at path /metadata/labels/thisshouldntexist/'
      policy: require-ns-labels
      result: fail
      rule: check-for-labels-on-namespace
      scored: true
      source: kyverno
      timestamp:
        nanos: 0
        seconds: 1666098909
  summary:
    error: 0
    fail: 1
    pass: 0
    skip: 0
    warn: 0
```

These intermediary resources have the same basic contents as a policy report and are used internally by Kyverno to build the final policy report. Kyverno will merge these results automatically into the appropriate policy report and there is no manual interaction typically required.

For more details on the internal reporting processes, see the developer docs [here](https://github.com/kyverno/kyverno/tree/main/docs/dev/reports).

## Background Scans

Kyverno can validate existing resources in the cluster that may have been created before a policy was created. This can be useful when evaluating the potential effects some new policies will have on a cluster prior to changing them to `Enforce` mode. The application of policies to existing resources is referred to as **background scanning** and is enabled by default unless `spec.background` is set to `false` in a policy like shown below in the snippet.

```yaml
spec:
  background: false
  rules:
    - name: default-deny-ingress
```

:::note[Note]
Background scans are handled by the reports controller and not the background controller.
:::

Background scanning, enabled by default in a `Policy` or `ClusterPolicy` object with the `spec.background` field, allows Kyverno to periodically scan existing resources and find if they match any `validate` or `verifyImages` rules. If existing resources are found which would violate an existing policy, the background scan notes them in a `ClusterPolicyReport` or a `PolicyReport` object, depending on if the resource is namespaced or not. It does not block any existing resources that match a rule, even in `Enforce` mode. It has no effect on either `generate` or `mutate` rules for the purposes of reporting.

Background scanning occurs on a periodic basis (one hour by default) and offers some configuration options via [container flags](/docs/installation/customization#container-flags).

When background scanning is enabled, regardless of whether the policy's `failureAction` is set to `Enforce` or `Audit`, the results will be recorded in a report. To see the specifics of how reporting works with background scans, refer to the tables below.

**Reporting behavior when `background: true`**

|                          | New Resource | Existing Resource |
| ------------------------ | ------------ | ----------------- |
| `failureAction: Enforce` | Pass only    | Report            |
| `failureAction: Audit`   | Report       | Report            |

**Reporting behavior when `background: false`**

|                          | New Resource | Existing Resource |
| ------------------------ | ------------ | ----------------- |
| `failureAction: Enforce` | Pass only    | None              |
| `failureAction: Audit`   | Report       | None              |

Also, policy rules that are written using either certain variables from [AdmissionReview](/docs/policy-types/cluster-policy/variables#variables-from-admission-review-requests) request information (e.g. `request.userInfo`), or fields like Roles, ClusterRoles, and Subjects in `match` and `exclude` statements, cannot be applied to existing resources in the background scanning mode since that information must come from an AdmissionReview request and is not available if the resource exists. Hence, these rules must set `background` to `false` to disable background scanning. The exceptions to this are `request.object` and `request.namespace` variables as these will be translated from the current state of the resource.

## Example: Trigger a PolicyReport

A `PolicyReport` object (Namespaced) is created in the same Namespace where resources apply to one or more Kyverno policies. Cluster wide resources will generate `ClusterPolicyReport` resources at the cluster level.

A single Kyverno ClusterPolicy exists with a single rule which ensures Pods cannot mount Secrets as environment variables.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: secrets-not-from-env-vars
spec:
  background: true
  rules:
    - name: secrets-not-from-env-vars
      match:
        any:
          - resources:
              kinds:
                - Pod
      validate:
        failureAction: Audit
        message: 'Secrets must be mounted as volumes, not as environment variables.'
        pattern:
          spec:
            containers:
              - name: '*'
                =(env):
                  - =(valueFrom):
                      X(secretKeyRef): 'null'
```

Creating a Pod in this Namespace which does not use any Secrets (and thereby does not violate the `secrets-not-from-env-vars` rule in the ClusterPolicy) will generate the first entry in the PolicyReport, but listed as a `PASS`.

```sh
$ kubectl run busybox --image busybox:1.28 -- sleep 9999
pod/busybox created

$ kubectl get po
NAME      READY   STATUS    RESTARTS   AGE
busybox   1/1     Running   0          66s

$ kubectl get polr -o wide
NAME                                   KIND         NAME                                         PASS   FAIL   WARN   ERROR   SKIP   AGE
89044d72-8a1e-4af0-877b-9be727dc3ec4   Pod          busybox                                      1      0      0      0       0      15s
```

Inspect the PolicyReport in the `default` Namespace to view its contents. Notice that the rule `secrets-not-from-env-vars` is listed as having passed.

```sh
$ kubectl get polr 89044d72-8a1e-4af0-877b-9be727dc3ec4 -o yaml

<snipped>
results:
- message: validation rule 'secrets-not-from-env-vars' passed.
  policy: secrets-not-from-env-vars
  result: pass
  rule: secrets-not-from-env-vars
  scored: true
  source: kyverno
  timestamp:
    nanos: 0
    seconds: 1666097147
summary:
  error: 0
  fail: 0
  pass: 1
  skip: 0
  warn: 0
```

Create another Pod which violates the rule in the sample policy. Because the rule is written with `failureAction: Audit`, resources are allowed to be created which violate the rule. If this occurs, another entry will be created in the PolicyReport which denotes this condition as a FAIL. By contrast, if `failureAction: Enforce` and an offending resource was attempted creation, it would be immediately blocked and therefore would not generate another entry in the report. However, if the resource passed then a PASS result would be created in the report.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secret-pod
spec:
  containers:
    - name: busybox
      image: busybox:1.28
      env:
        - name: SECRET_STUFF
          valueFrom:
            secretKeyRef:
              name: mysecret
              key: mysecretname
```

Since the above Pod spec was allowed and it violated the rule, there should now be a failure entry in the PolicyReport in the `default` Namespace.

```sh
$ kubectl get polr -o wide
NAME                                   KIND         NAME                                         PASS   FAIL   WARN   ERROR   SKIP   AGE
9eb8c5c0-fe5c-4c7d-96c3-3ff65c361f4f   Pod          secret-pod                                   0      1      0      0       0      15s

$ kubectl get polr 9eb8c5c0-fe5c-4c7d-96c3-3ff65c361f4f -o yaml

<snipped>
- message: 'validation error: Secrets must be mounted as volumes, not as environment
    variables. rule secrets-not-from-env-vars failed at path /spec/containers/0/env/0/valueFrom/secretKeyRef/'
  policy: secrets-not-from-env-vars
  result: fail
  rule: secrets-not-from-env-vars
  scored: true
  source: kyverno
  timestamp:
    nanos: 0
    seconds: 1666098438
summary:
  error: 0
  fail: 1
  pass: 1
  skip: 0
  warn: 0
```

Lastly, delete the Pod called `secret-pod` and check that the PolicyReport object was also deleted.

```sh
$ kubectl delete po secret-pod
pod "secret-pod" deleted

$ kubectl get polr -o wide
NAME                                   KIND         NAME                                         PASS   FAIL   WARN   ERROR   SKIP   AGE
```

:::note[Note]
Note that a namespaced `Policy` applies only to namespaced resources and only in the Namespace in which they are created. This example would have been exactly the same if we had used a `Policy` instead of `ClusterPolicy`.

For a cluster level resource, a `ClusterPolicyReport` would have been created at cluster level instead of a namespaced `PolicyReport`.
:::

## OpenReports

> **Note:** OpenReports integration is available as of Kyverno 1.15. The feature is in ALPHA status

Kyverno supports reporting policy results using the `openreports.io/v1alpha1` API as an alternative to the default wgpolicyk8s reporting. This can be enabled using the `--openreportsEnabled` flag in the Kyverno controller.

This is an initial step to eventually deprecate `wgpolicyk8s` and fully depend on `openreports.io` as the API group for permanent reports

### Enabling OpenReports

To enable OpenReports integration, add the `--openreportsEnabled` flag to the Kyverno reports controller.

If you are deploying Kyverno using Helm, setting the chart value `openreports.enabled=true` will automatically add the `--openreportsEnabled` flag to the reports controller deployment.

### Example: Enforcing an 'app' Label

Below is an example Kyverno policy that enforces the presence of an `app` label on all Pods. When this policy is applied and OpenReports integration is enabled, Kyverno will generate reports in the `openreports.io/v1alpha1` API group.

#### Policy Example

```yaml
apiVersion: kyverno.io/v1
kind: Policy
metadata:
  name: require-app-label
  namespace: default
spec:
  admission: true
  background: true
  rules:
    - match:
        resources:
          kinds:
            - Pod
      name: check-app-label
      skipBackgroundRequests: true
      validate:
        message: Pods must have an 'app' label.
        pattern:
          metadata:
            labels:
              app: ?*
  validationFailureAction: enforce
```

#### Example OpenReports Output

You can view the reports as follows:

```sh
$ kubectl get reports -A -o yaml
```

```yaml
apiVersion: v1
items:
  - apiVersion: openreports.io/v1alpha1
    kind: Report
    metadata:
      labels:
        app.kubernetes.io/managed-by: kyverno
      name: 7d23ea02-1526-4a4f-ba14-49665adf55e
    results:
      - message: "validation error: Pods must have an 'app' label. rule check-app-label failed at path /metadata/labels/app/"
        policy: default/require-app-label
        properties:
          process: background scan
        result: fail
        rule: check-app-label
        scored: true
        source: kyverno
        timestamp:
          nanos: 0
          seconds: 1849050397
    scope:
      apiVersion: v1
      kind: Pod
      name: example-deployment-c94dc9f47-dfq6l
      namespace: default
      uid: dcd32da4-8539-4636-bba5-fd2cc3a6aaff
    summary:
      error: 0
      fail: 1
      pass: 0
      skip: 0
      warn: 0
kind: List
metadata: {}
```

## ValidatingAdmissionPolicy Reports

Kyverno can generate reports for ValidatingAdmissionPolicies and their bindings. These reports provide information about the resources that are validated by the policies and the results of the validation. They can be used to monitor the health of the cluster and to ensure that the policies are being enforced as expected.

To configure Kyverno to generate reports for ValidatingAdmissionPolicies, set the `--validatingAdmissionPolicyReports` flag to `true` in the reports controller. This flag is set to `false` by default.

### Example: Trigger a PolicyReport

Create a ValidatingAdmissionPolicy that checks the Deployment replicas and a ValidatingAdmissionPolicyBinding that binds the policy to a namespace whose labels set to `environment: staging`.

```yaml
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingAdmissionPolicy
metadata:
  name: 'check-deployment-replicas'
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
  name: 'check-deployment-replicas-binding'
spec:
  policyName: 'check-deployment-replicas'
  validationActions: [Deny]
  matchResources:
    namespaceSelector:
      matchLabels:
        environment: staging
```

Create a Namespace with the label `environment: staging`:

```sh
kubectl create ns staging
kubectl label ns staging environment=staging
```

Create the following Deployments:

1. A Deployment with 7 replicas in the `default` namespace.

```sh
kubectl create deployment deployment-1 --image=nginx --replicas=7
```

2. A Deployment with 3 replicas in the `default` namespace.

```sh
kubectl create deployment deployment-2 --image=nginx --replicas=3
```

3. A Deployment with 7 replicas in the `staging` namespace.

```sh
kubectl create deployment deployment-3 --image=nginx --replicas=7 -n staging
```

4. A Deployment with 3 replicas in the `staging` namespace.

```sh
kubectl create deployment deployment-4 --image=nginx --replicas=3 -n staging
```

PolicyReports are generated in the same namespace as the resources that are validated. The PolicyReports for the above example are generated in the `default` and `staging` namespaces.

```sh
kubectl get polr -n default

No resources found in default namespace.
```

```sh
kubectl get polr -n staging -o yaml

apiVersion: v1
items:
- apiVersion: wgpolicyk8s.io/v1alpha2
  kind: PolicyReport
  metadata:
    creationTimestamp: "2024-01-25T11:55:33Z"
    generation: 1
    labels:
      app.kubernetes.io/managed-by: kyverno
    name: 0b2d730e-cbc3-4eab-8f3b-ad106ea5d559
    namespace: staging-ns
    ownerReferences:
    - apiVersion: apps/v1
      kind: Deployment
      name: deployment-3
      uid: 0b2d730e-cbc3-4eab-8f3b-ad106ea5d559
    resourceVersion: "83693"
    uid: 90ab79b4-fc0b-41bc-b8d0-da021c02ee9d
  results:
  - message: 'failed expression: object.spec.replicas <= 5'
    policy: check-deployment-replicas
    properties:
      binding: check-deployment-replicas-binding
    result: fail
    source: ValidatingAdmissionPolicy
    timestamp:
      nanos: 0
      seconds: 1706183723
  scope:
    apiVersion: apps/v1
    kind: Deployment
    name: deployment-3
    namespace: staging-ns
    uid: 0b2d730e-cbc3-4eab-8f3b-ad106ea5d559
  summary:
    error: 0
    fail: 1
    pass: 0
    skip: 0
    warn: 0
- apiVersion: wgpolicyk8s.io/v1alpha2
  kind: PolicyReport
  metadata:
    creationTimestamp: "2024-01-25T11:55:33Z"
    generation: 1
    labels:
      app.kubernetes.io/managed-by: kyverno
    name: c1e28ad7-b5c9-4f5c-9b77-8d4278df9fc4
    namespace: staging-ns
    ownerReferences:
    - apiVersion: apps/v1
      kind: Deployment
      name: deployment-4
      uid: c1e28ad7-b5c9-4f5c-9b77-8d4278df9fc4
    resourceVersion: "83694"
    uid: 8e19960d-969d-4e4c-a7d7-480fff15df6d
  results:
  - policy: check-deployment-replicas
    properties:
      binding: check-deployment-replicas-binding
    result: pass
    source: ValidatingAdmissionPolicy
    timestamp:
      nanos: 0
      seconds: 1706183723
  scope:
    apiVersion: apps/v1
    kind: Deployment
    name: deployment-4
    namespace: staging-ns
    uid: c1e28ad7-b5c9-4f5c-9b77-8d4278df9fc4
  summary:
    error: 0
    fail: 0
    pass: 1
    skip: 0
    warn: 0
kind: List
metadata:
  resourceVersion: ""
```
