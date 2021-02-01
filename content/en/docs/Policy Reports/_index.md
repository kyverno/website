---
title: Policy Reports
description: >
    Manage policy results.
weight: 60
---

Kyverno policy reports provide information about policy execution and violations. Kyverno creates policy reports for each namespace and a single cluster-level report for cluster resources.

Entries are added to reports whenever a resource is created which violates one or more rules where the applicable rule sets `validationFailureAction=audit`. Otherwise, when in `enforce` mode, the resource is blocked immediately upon creation and therefore no entry is created since no offending resource exists. If the created resource violates multiple rules, there will be multiple entries in the reports for the same resource. Likewise, if a resource is deleted, it will be expunged from the report simultaneously.

There are two types of reports that get created and updated by Kyverno: a `ClusterPolicyReport` (for cluster-scoped resources) and a `PolicyReport` (for Namespaced resources). The contents of these reports are determined by the violating resources and not where the rule is stored. For example, if a rule is written which validates Ingress resources, because Ingress is a Namespaced resource, any violations will show up in a `PolicyReport` co-located in the same Namespace as the offending resource itself, regardless if that rule was written in a `Policy` or a `ClusterPolicy`.

Kyverno uses the policy report schema published by the [Kubernetes Policy WG](https://github.com/kubernetes-sigs/wg-policy-prototypes/tree/master/policy-report) which proposes a common policy report format across Kubernetes tools.

{{% alert title="Note" color="info" %}}
Policy reports are available in Kyverno 1.3.0+. If you are using an older version you can view policy violations using:
    `kubectl get polv -A`

{{% /alert %}}

## Viewing policy report summaries

You can view a summary of the namespaced policy report using the following command:

```shell
kubectl get policyreport -A
```

{{% alert title="Tip" color="info" %}}
`polr` is the short name for `policyreport`.
{{% /alert %}}

For example, here are the policy reports for a small test cluster:

```shell
λ kubectl get polr -A
NAMESPACE     NAME                  PASS   FAIL   WARN   ERROR   SKIP   AGE
default       polr-ns-default       338    2      0      0       0      28h
flux-system   polr-ns-flux-system   135    5      0      0       0      28h
```

Similarly, you can view the cluster-wide report using:

```shell
kubectl get clusterpolicyreport -A
```

{{% alert title="Tip" color="info" %}}
`cpolr` is the short name for `clusterpolicyreport`.
{{% /alert %}}


## Viewing policy violations

Since the report provides information on all rule and resource execution, finding policy violations requires an additional filter. 

Here is a command to view policy violations for the `default` namespace:

```shell
kubectl describe polr polr-ns-default | grep "Status: \+fail" -B10
```

Running this in the test cluster shows two containers without `runAsNotRoot: true`.

```shell
λ kubectl describe polr polr-ns-default | grep "Status: \+fail" -B10
  Message:        validation error: Running as root is not allowed. The fields spec.securityContext.runAsNonRoot, spec.containers[*].securityContext.runAsNonRoot, and spec.initContainers[*].securityContext.runAsNonRoot must be `true`. Rule check-containers[0] failed at path /spec/securityContext/runAsNonRoot/. Rule check-containers[1] failed at path /spec/containers/0/securityContext/.
  Policy:         require-run-as-non-root
  Resources:
    API Version:  v1
    Kind:         Pod
    Name:         add-capabilities-init-containers
    Namespace:    default
    UID:          1caec743-faed-4d5a-90f7-5f4630febd58
  Rule:           check-containers
  Scored:         true
  Status:         fail
--
  Message:        validation error: Running as root is not allowed. The fields spec.securityContext.runAsNonRoot, spec.containers[*].securityContext.runAsNonRoot, and spec.initContainers[*].securityContext.runAsNonRoot must be `true`. Rule check-containers[0] failed at path /spec/securityContext/runAsNonRoot/. Rule check-containers[1] failed at path /spec/containers/0/securityContext/.
  Policy:         require-run-as-non-root
  Resources:
    API Version:  v1
    Kind:         Pod
    Name:         sysctls
    Namespace:    default
    UID:          b98bdfb7-10e0-467f-a51c-ac8b75dc2e95
  Rule:           check-containers
  Scored:         true
  Status:         fail
```

To view all namespaced violations in a cluster use:

```shell
kubectl describe polr -A | grep -i "status: \+fail" -B10
```
