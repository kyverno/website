---
title: Reporting
description: >
    View and audit Kyverno policy results with reports.
weight: 60
---

Policy reports are Kubernetes Custom Resources, generated and managed automatically by Kyverno, which contain the results of applying matching Kubernetes resources to Kyverno ClusterPolicy or Policy resources. They are created for `validate` and `verifyImages` rules when the policy in which they are contained is configured with `spec.validationFailureAction: Audit` or `spec.background: true` and a resource applies to one or more rules according to the policy definition. If resources violate multiple rules, there will be multiple entries. When resources are deleted, their entry will be removed from the report. For example, if a validate policy in `Audit` mode exists containing a single rule which requires that all resources set the label `team` and a user creates a Pod which does not set the `team` label, Kyverno will allow the Pod's creation but record it as a `fail` result in a policy report due to the Pod being in violation of the policy and rule. Policies configured with `spec.validationFailureAction: Enforce` immediately block violating resources and therefore do not generate policy reports. Policy reports are an ideal way to observe the impact a Kyverno policy may have in a cluster without causing disruption. The insights gained from these policy reports may be used to provide valuable feedback to both users/developers so they may take appropriate action to bring offending resources into alignment, and to policy authors or cluster operators to help them refine policies prior to changing them to `Enforce` mode. Because reports are decoupled from policies, standard Kubernetes RBAC can then be applied to separate those who can see and manipulate policies from those who can view reports.

Policy reports are created based on two different triggers: an admission event (a `CREATE`, `UPDATE`, or `DELETE` action performed against a resource) or the result of a background scan discovering existing resources. Policy reports, like Kyverno policies, have both Namespaced and cluster-scoped variants; a `PolicyReport` is a Namespaced resource while a `ClusterPolicyReport` is a cluster-scoped resource. However, unlike `Policy` and `ClusterPolicy` resources, the `PolicyReport` and `ClusterPolicyReport` resources contain results from resources which are at the same scope and _not_ what is determined by the Kyverno policy. For example, a `ClusterPolicy` (a cluster-scoped policy) contains a rule which matches on Pods (a Namespaced resource). Results generated from this policy and rule are written to a `PolicyReport` in the Namespace where the Pod exists.

Kyverno uses a standard and open format published by the [Kubernetes Policy working group](https://github.com/kubernetes-sigs/wg-policy-prototypes/tree/master/policy-report) which proposes a common policy report format across Kubernetes tools. Below is an example of a `ClusterPolicyReport` which shows Namespaces in violation of a validate rule which requires the `team` label be present.

```yaml
apiVersion: wgpolicyk8s.io/v1alpha2
kind: ClusterPolicyReport
metadata:
  creationTimestamp: "2022-10-18T11:55:20Z"
  generation: 1
  labels:
    app.kubernetes.io/managed-by: kyverno
  name: cpol-require-ns-labels
  resourceVersion: "950"
  uid: 6dde3d0d-d2e8-48d9-8b56-47b3c5e7a3b3
results:
- category: Best Practices
  message: 'validation error: The label `team` is required. rule check-for-ns-labels
    failed at path /metadata/labels/team/'
  policy: require-ns-labels
  resources:
  - apiVersion: v1
    kind: Namespace
    name: kube-node-lease
    uid: 06e5056f-76a3-461a-8d45-2793b8bd5bbc
  result: fail
  rule: check-for-ns-labels
  scored: true
  severity: medium
  source: kyverno
  timestamp:
    nanos: 0
    seconds: 1666094105
```

The report's contents can be found under the `results[]` object in which it displays a number of fields including the resource that was matched against the rule in the parent policy.

Policy reports are created in a 1:1 relationship with a Kyverno policy. The naming follows the convention `<policy_type>-<policy_name>` where `<report_type>` uses the alias `pol` (for `Policy`) or `cpol` (for `ClusterPolicy`).

{{% alert title="Note" color="info" %}}
Policy reports show policy results for current resources in the cluster only. For information on resources that were blocked during admission controls, use the [policy rule execution metric](/docs/monitoring/policy-results-info/) or look at events on the corresponding Kyverno policy. A `PodExecOptions` subresource is not capable of producing an entry in a policy report due to API limitations.
{{% /alert %}}

Policy reports have a few configuration options available. For details, see the [container flags](/docs/installation/#container-flags) section.

{{% alert title="Note" color="warning" %}}
Policy reports created from background scans are not subject to the configuration of either a [resource filter](/docs/installation/#resource-filters) or a [Namespace selector](/docs/installation/#namespace-selectors) defined in the [Kyverno ConfigMap](/docs/installation/#configmap-flags). This is due to the fact that the overhead required to generate these reports is minimal and should have no performance impact.
{{% /alert %}}

## Report result logic

Entries in a policy report contain a `result` field which can be either `pass`, `skip`, `warn`, `error`, or `fail`.

| Result | Description                                                                                                                        |
|--------|------------------------------------------------------------------------------------------------------------------------------------|
| pass   | The resource was applicable to a rule and the pattern passed evaluation.                                                           |
| skip   | Preconditions were not satisfied (if applicable) in a rule and so further processing was not performed.                            |
| fail   | The resource failed the pattern evaluation.                                                                                        |
| warn   | The annotation `policies.kyverno.io/scored` has been set to `"false"` in the policy converting otherwise `fail` results to `warn`. |
| error  | Variable substitution failed outside of preconditions and elsewhere in the rule (ex., in the pattern).                             |

## Viewing policy report summaries

You can view a summary of the Namespaced policy reports using the following command:

```sh
kubectl get policyreport -A
```

For example, below are the policy reports for a small test cluster (`polr` is the alias for `PolicyReports`) in which the only policy installed is named `disallow-privileged-containers`. 

```sh
$ kubectl get polr -A
NAMESPACE     NAME                                  PASS   FAIL   WARN   ERROR   SKIP   AGE
kube-system   cpol-disallow-privileged-containers   14     0      0      0       0      6s
kyverno       cpol-disallow-privileged-containers   2      0      0      0       0      5s
default       cpol-disallow-privileged-containers   0      1      0      0       0      5s
```

Similarly, you can view the cluster-wide report using:

```sh
kubectl get clusterpolicyreport
```

{{% alert title="Tip" color="info" %}}
For a graphical view of Policy Reports, check out [Policy Reporter](https://github.com/kyverno/policy-reporter#readme).
{{% /alert %}}

{{% alert title="Note" color="info" %}}
If you've set the `policies.kyverno.io/scored` annotation to `"false"` in your policy, then the policy violations will be reported as warnings rather than failures. By default, it is set to `"true"` and policy violations are reported as failures.
{{% /alert %}}

## Viewing policy violations

Since the report provides information on all rule and resource execution, returning only select entries requires a filter expression.

Policy reports can be inspected using either `kubectl describe` or `kubectl get`. For example, here is a command, requiring `yq`, to view only failures for the (Namespaced) report called `cpol-disallow-privileged-containers`:

```sh
kubectl get polr cpol-disallow-privileged-containers -o jsonpath='{.results[?(@.result=="fail")]}' | yq -p json -
```

```yaml
category: Pod Security Standards (Baseline)
message: 'validation error: Privileged mode is disallowed. The fields spec.containers[*].securityContext.privileged and spec.initContainers[*].securityContext.privileged must be unset or set to `false`.          . rule privileged-containers failed at path /spec/containers/0/securityContext/privileged/'
policy: disallow-privileged-containers
resources:
  - apiVersion: v1
    kind: Pod
    name: h0nk
    namespace: default
    uid: 71a4a8c8-8e02-46ed-af3d-db38f590a5b6
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
resources:
  - apiVersion: v1
    kind: Pod
    name: badpod
    namespace: default
    uid: 8ef79afd-f2b4-44f8-8c50-dabdda45b8c0
result: fail
rule: privileged-containers
scored: true
severity: medium
source: kyverno
timestamp:
  nanos: 0
  seconds: 1.666095335e+09
```

## Example: Trigger a PolicyReport

By default, a `PolicyReport` object (Namespaced) is created in the same Namespace where resources apply to one or more Kyverno policies, be they `Policy` or `ClusterPolicy` policies.

A single Kyverno ClusterPolicy exists with a single rule which ensures Pods cannot mount Secrets as environment variables.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: secrets-not-from-env-vars
spec:
  background: true
  validationFailureAction: Audit
  rules:
  - name: secrets-not-from-env-vars
    match:
      any:
      - resources:
          kinds:
          - Pod
    validate:
      message: "Secrets must be mounted as volumes, not as environment variables."
      pattern:
        spec:
          containers:
          - name: "*"
            =(env):
            - =(valueFrom):
                X(secretKeyRef): "null"
```

Creating a Pod in this Namespace which does not use any Secrets (and thereby does not violate the `secrets-not-from-env-vars` rule in the ClusterPolicy) will generate the first entry in the PolicyReport, but listed as a `PASS`.

```sh
$ kubectl run busybox --image busybox:1.28 -- sleep 9999
pod/busybox created

$ kubectl get po
NAME      READY   STATUS    RESTARTS   AGE
busybox   1/1     Running   0          66s

$ kubectl get polr
NAME                             PASS   FAIL   WARN   ERROR   SKIP   AGE
cpol-secrets-not-from-env-vars   1      0      0      0       0      6s
```

Inspect the PolicyReport in the `default` Namespace to view its contents. Notice that the `busybox` Pod is listed as having passed.

```sh
$ kubectl get polr cpol-secrets-not-from-env-vars -o yaml

<snipped>
results:
- message: validation rule 'secrets-not-from-env-vars' passed.
  policy: secrets-not-from-env-vars
  resources:
  - apiVersion: v1
    kind: Pod
    name: busybox
    namespace: default
    uid: 0dd94825-cc6e-435b-982b-fb76ac2fdc2a
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

Create another Pod which violates the rule in the sample policy. Because the rule is written with `validationFailureAction: Audit`, resources are allowed to be created which violate the rule. If this occurs, another entry will be created in the PolicyReport which denotes this condition as a FAIL. By contrast, if `validationFailureAction: Enforce` and an offending resource was attempted creation, it would be immediately blocked and therefore would not generate another entry in the report.

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
$ kubectl get polr polr-ns-default -o yaml

<snipped>
- message: 'validation error: Secrets must be mounted as volumes, not as environment
    variables. rule secrets-not-from-env-vars failed at path /spec/containers/0/env/0/valueFrom/secretKeyRef/'
  policy: secrets-not-from-env-vars
  resources:
  - apiVersion: v1
    kind: Pod
    name: secret-pod
    namespace: default
    uid: 72a7422c-fb6f-486f-b274-1ca0de55d49d
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

Lastly, delete the Pod called `secret-pod` and once again check the PolicyReport object.

```sh
$ kubectl delete po secret-pod
pod "secret-pod" deleted

$ k get polr cpol-secrets-not-from-env-vars
NAME                             PASS   FAIL   WARN   ERROR   SKIP   AGE
cpol-secrets-not-from-env-vars   1      0      0      0       0      2m21s
```

Notice how the PolicyReport has removed the previously-failed entry when the violating Pod was deleted.

## Example: Trigger a ClusterPolicyReport

A ClusterPolicyReport is the same concept as a PolicyReport only it contains resources which are cluster scoped rather than Namespaced.

As an example, create the following sample ClusterPolicy containing a single rule which validates that all new Namespaces should contain the label called `thisshouldntexist` and have some value. Notice how `validationFailureAction: Audit` and `background: true` in this ClusterPolicy.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: require-ns-labels
spec:
  validationFailureAction: Audit
  background: true
  rules:
  - name: check-for-labels-on-namespace
    match:
      any:
      - resources:
          kinds:
          - Namespace
    validate:
      message: "The label `thisshouldntexist` is required."
      pattern:
        metadata:
          labels:
            thisshouldntexist: "?*"
```

After creating this sample ClusterPolicy, check for the existence of a ClusterPolicyReport object.

```sh
$ k get cpolr
NAME                     PASS   FAIL   WARN   ERROR   SKIP   AGE
cpol-require-ns-labels   0      5      0      0       0      76m```
```

Notice that a ClusterPolicyReport named `cpol-require-ns-labels` exists with five failures.

The ClusterPolicyReport, when inspected, has the same structure as the PolicyReport object and contains entries in the `results` and `summary` objects with the outcomes of a policy audit.

```yaml
results:
- message: 'validation error: The label `thisshouldntexist` is required. rule check-for-labels-on-namespace
    failed at path /metadata/labels/thisshouldntexist/'
  policy: require-ns-labels
  resources:
  - apiVersion: v1
    kind: Namespace
    name: kube-node-lease
    uid: 06e5056f-76a3-461a-8d45-2793b8bd5bbc
  result: fail
  rule: check-for-labels-on-namespace
  scored: true
  source: kyverno
  timestamp:
    nanos: 0
    seconds: 1666098654
- message: 'validation error: The label `thisshouldntexist` is required. rule check-for-labels-on-namespace
    failed at path /metadata/labels/thisshouldntexist/'
  policy: require-ns-labels
  resources:
  - apiVersion: v1
    kind: Namespace
    name: default
    uid: 4ffe22fd-0927-4ed1-8b04-50ca7ed58626
  result: fail
  rule: check-for-labels-on-namespace
  scored: true
  source: kyverno
  timestamp:
    nanos: 0
    seconds: 1666098654
- message: 'validation error: The label `thisshouldntexist` is required. rule check-for-labels-on-namespace
    failed at path /metadata/labels/thisshouldntexist/'
  policy: require-ns-labels
  resources:
  - apiVersion: v1
    kind: Namespace
    name: kyverno
    uid: 5d87cd66-ce30-4abc-b863-f3b97715a5f1
  result: fail
  rule: check-for-labels-on-namespace
  scored: true
  source: kyverno
  timestamp:
    nanos: 0
    seconds: 1666098654
- message: 'validation error: The label `thisshouldntexist` is required. rule check-for-labels-on-namespace
    failed at path /metadata/labels/thisshouldntexist/'
  policy: require-ns-labels
  resources:
  - apiVersion: v1
    kind: Namespace
    name: kube-public
    uid: c077ee71-435b-4921-9e05-8751fee71b64
  result: fail
  rule: check-for-labels-on-namespace
  scored: true
  source: kyverno
  timestamp:
    nanos: 0
    seconds: 1666098654
- message: 'validation error: The label `thisshouldntexist` is required. rule check-for-labels-on-namespace
    failed at path /metadata/labels/thisshouldntexist/'
  policy: require-ns-labels
  resources:
  - apiVersion: v1
    kind: Namespace
    name: kube-system
    uid: e63fabde-b572-4b07-b899-b2230f4eac69
  result: fail
  rule: check-for-labels-on-namespace
  scored: true
  source: kyverno
  timestamp:
    nanos: 0
    seconds: 1666098654
summary:
  error: 0
  fail: 5
  pass: 0
  skip: 0
  warn: 0
```

## Report internals

The `PolicyReport` and `ClusterPolicyReport` are the final resources composed of matching resources as determined by Kyverno `Policy` and `ClusterPolicy` objects, however these reports are built of four intermediary resources. For matching resources which were caught during admission mode, `AdmissionReport` and `ClusterAdmissionReport` resources are created. For results of background processing, `BackgroundScanReport` and `ClusterBackgroundScanReport` resources are created. An example of a `ClusterAdmissionReport` is shown below.

```yaml
apiVersion: kyverno.io/v1alpha2
kind: ClusterAdmissionReport
metadata:
  creationTimestamp: "2022-10-18T13:15:09Z"
  generation: 1
  labels:
    app.kubernetes.io/managed-by: kyverno
    audit.kyverno.io/resource.hash: a7ec5160f220c5b83c26b5c8f7dc35b6
    audit.kyverno.io/resource.uid: 61946422-14ba-4aa2-94b4-229d38446381
    cpol.kyverno.io/require-ns-labels: "4773"
  name: c0cc7337-9bcd-4d53-abb2-93f7f5555216
  resourceVersion: "4986"
  uid: 10babc6c-9e6e-4386-abed-c13f50091523
spec:
  owner:
    apiVersion: v1
    kind: Namespace
    name: testing
    uid: 61946422-14ba-4aa2-94b4-229d38446381
  results:
  - message: 'validation error: The label `thisshouldntexist` is required. rule check-for-labels-on-namespace
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
