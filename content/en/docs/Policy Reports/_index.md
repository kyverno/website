---
title: Policy Reports
description: >
    Manage policy results.
weight: 60
---

Kyverno Policy reports provide information about policy execution and violations. Kyverno creates policy reports for each namespace and a single cluster-level report for cluster resources.

Kyverno uses the common report schema published by the [Kubernetes Policy WG](https://github.com/kubernetes-sigs/wg-policy-prototypes/tree/master/policy-report) which proposes a common report format for Kubernetes tools.


## Viewing policy report summaries

You can view a summary of the namespaced policy report using the following command:

```shell
kubectl get polr -A
```

Note: `polr` is short for `policyreport`.

For example, here are the policy reports for a small test cluster:

```shell
λ kubectl get polr -A
NAMESPACE     NAME                  PASS   FAIL   WARN   ERROR   SKIP   AGE
default       polr-ns-default       338    2      0      0       0      28h
flux-system   polr-ns-flux-system   135    5      0      0       0      28h
```

Similarly, you can view the cluster-wide report using:

```shell
kubectl get cpolr -A
```

Here, `cpolr` is short for `clusterpolicyreport`.

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
kubectl describe polr -A | grep "Status: \+fail" -B10
```
