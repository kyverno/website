---
title: Reporting
description: >
    View and audit Kyverno policy results with reports.
weight: 60
---

Policy reports are Kubernetes Custom Resources, generated and managed automatically by Kyverno, which contain the results of applying matching Kubernetes resources to Kyverno ClusterPolicy or Policy resources.
They are created for `validate` and `verifyImages` rules when a resource is matched by one or more rules according to the policy definition.
If resources violate multiple rules, there will be multiple entries.
When resources are deleted, their entry will be removed from the report.
Reports, therefore, always represent the current state of the cluster and do not record historical information.

For example, if a validate policy in `Audit` mode exists containing a single rule which requires that all resources set the label `team` and a user creates a Pod which does not set the `team` label, Kyverno will allow the Pod's creation but record it as a `fail` result in a policy report due to the Pod being in violation of the policy and rule.
Policies configured with `spec.validationFailureAction: Enforce` immediately block violating resources and results will only be reported for `pass` evaluations.
Policy reports are an ideal way to observe the impact a Kyverno policy may have in a cluster without causing disruption.
The insights gained from these policy reports may be used to provide valuable feedback to both users/developers so they may take appropriate action to bring offending resources into alignment, and to policy authors or cluster operators to help them refine policies prior to changing them to `Enforce` mode.
Because reports are decoupled from policies, standard Kubernetes RBAC can then be applied to separate those who can see and manipulate policies from those who can view reports.

Policy reports are created based on two different triggers: an admission event (a `CREATE`, `UPDATE`, or `DELETE` action performed against a resource) or the result of a background scan discovering existing resources.
Policy reports, like Kyverno policies, have both Namespaced and cluster-scoped variants; a `PolicyReport` is a Namespaced resource while a `ClusterPolicyReport` is a cluster-scoped resource.

Reports are stored in the cluster on a per resource basis.
Every namespaced resource will have an associated `PolicyReport` and every clustered resource will have an associated `ClusterPolicyReport`.

Kyverno uses a standard and open format published by the [Kubernetes Policy working group](https://github.com/kubernetes-sigs/wg-policy-prototypes/tree/master/policy-report) which proposes a common policy report format across Kubernetes tools.
Below is an example of a `PolicyReport` generated for a `Pod` which shows passing and failed rules.

```yaml
apiVersion: wgpolicyk8s.io/v1alpha2
kind: PolicyReport
metadata:
  creationTimestamp: "2023-12-06T13:19:03Z"
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
  resourceVersion: "720507"
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
  message: 'validation error: Sharing the host namespaces is disallowed. The fields
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

{{% alert title="Note" color="info" %}}
Policy reports show policy results for current resources in the cluster only. For information on resources that were blocked during admission controls, use the [policy rule execution metric](/docs/monitoring/policy-results-info/) or inspect Kubernetes Events on the corresponding Kyverno policy. A `Pod/exec` subresource is not capable of producing an entry in a policy report due to API limitations.
{{% /alert %}}

Policy reports have a few configuration options available. For details, see the [container flags](/docs/installation/customization/#container-flags) section.

{{% alert title="Note" color="warning" %}}
Policy reports created from background scans are not subject to the configuration of a [Namespace selector](/docs/installation/customization/#namespace-selectors) defined in the [Kyverno ConfigMap](/docs/installation/customization/#configmap-keys).
{{% /alert %}}

## Report result logic

Entries in a policy report contain a `result` field which can be either `pass`, `skip`, `warn`, `error`, or `fail`.

| Result | Description                                                                                                                        |
|--------|------------------------------------------------------------------------------------------------------------------------------------|
| pass   | The resource was applicable to a rule and the pattern passed evaluation.                                                           |
| skip   | Preconditions were not satisfied (if applicable) in a rule, or an applicable PolicyException exists and so further processing was not performed.                            |
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

For more details on the internal reporting processes, see the developer docs [here](https://github.com/kyverno/kyverno/tree/main/docs/dev/reports).
