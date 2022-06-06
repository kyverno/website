---
title: Reporting
description: >
    View and audit Kyverno policy results with reports.
weight: 60
---

Kyverno policy reports are Kubernetes resources that provide information about policy results, including violations. Kyverno creates policy reports for each Namespace and a single cluster-level report for cluster resources.

Result entries are added to reports whenever a resource is created which violates one or more rules where the applicable rule sets `validationFailureAction=audit`. Otherwise, when in `enforce` mode, the resource is blocked immediately upon creation and therefore no entry is created since no offending resource exists. If the created resource violates multiple rules, there will be multiple entries in the reports for the same resource. Likewise, if a resource is deleted, it will be expunged from the report simultaneously.

There are two types of reports that get created and updated by Kyverno: a `ClusterPolicyReport` (for cluster-scoped resources) and a `PolicyReport` (for Namespaced resources). The contents of these reports are determined by the violating resources and not where the rule is stored. For example, if a rule is written which validates Ingress resources, because Ingress is a Namespaced resource, any violations will show up in a `PolicyReport` co-located in the same Namespace as the offending resource itself, regardless if that rule was written in a `Policy` or a `ClusterPolicy`.

Kyverno uses the policy report schema published by the [Kubernetes Policy WG](https://github.com/kubernetes-sigs/wg-policy-prototypes/tree/master/policy-report) which proposes a common policy report format across Kubernetes tools.

{{% alert title="Note" color="info" %}}
Policy reports show policy results for current resources in the cluster. For information on resources that were blocked during admission controls, use the [policy rule execution metric](/docs/monitoring/policy-results-info/).
{{% /alert %}}

## Report result logic

Entries in a policy report contain a `result` field which can be either `pass`, `skip`, `warn`, `error`, or `fail`.

`pass`: The resource was applicable to a rule and the pattern passed evaluation.
`skip`: Preconditions were not satisfied (if applicable) in a rule and so further processing was not performed.
`fail`: The resource failed the pattern evaluation.
`warn`: The annotation `policies.kyverno.io/scored` has been set to `"false"` in the policy converting otherwise `fail` results to `warn`.
`error`: Variable substitution failed outside of preconditions and elsewhere in the rule (ex., in the pattern).

## Viewing policy report summaries

You can view a summary of the namespaced policy report using the following command:

```sh
kubectl get policyreport -A
```

For example, here are the policy reports for a small test cluster (`polr` is the shortname for `policyreports`):

```sh
$ kubectl get polr -A
NAMESPACE     NAME                  PASS   FAIL   WARN   ERROR   SKIP   AGE
default       polr-ns-default       338    2      0      0       0      28h
flux-system   polr-ns-flux-system   135    5      0      0       0      28h
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

Since the report provides information on all rule and resource execution, finding policy violations requires an additional filter.

Here is a command to view policy violations for the `default` Namespace:

```sh
kubectl describe polr polr-ns-default | grep "Result: \+fail" -B10
```

Running this in the test cluster shows two containers without `runAsNotRoot: true`.

```sh
$ kubectl describe polr polr-ns-default | grep "Result: \+fail" -B10
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
  Result:         fail
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
  Result:         fail
```

To view all namespaced violations in a cluster use:

```sh
kubectl describe polr -A | grep -i "Result: \+fail" -B10
```

## Example: Trigger a PolicyReport

By default, a `PolicyReport` object exists in every Namespace regardless if there are any Kyverno `Policy` objects which also exist in that Namespace. The `PolicyReport` itself is also empty (i.e., without any results) until there are Kubernetes resources which trigger the report. A resource will appear in the report if it creates any of pass, fail, warn, skip, or error conditions.

As an example, take the `default` Namespace which currently has no Pods present.

```sh
$ kubectl get pods -n default
No resources found in default namespace.
```

A single Kyverno ClusterPolicy exists with a single rule which ensures Pods cannot mount Secrets as environment variables.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: secrets-not-from-env-vars
spec:
  background: true
  validationFailureAction: audit
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

$ kubectl get polr -o wide
NAME              KIND   NAME   PASS   FAIL   WARN   ERROR   SKIP   AGE
polr-ns-default                 1      0      0      0       0      28h
```

Inspect the PolicyReport in the `default` Namespace to view its contents. Notice that the `busybox` Pod is listed as having passed.

```sh
$ kubectl get polr polr-ns-default -o yaml

<snipped>
results:
- message: validation rule 'secrets-not-from-env-vars' passed.
  policy: secrets-not-from-env-vars
  resources:
  - apiVersion: v1
    kind: Pod
    name: busybox
    namespace: default
    uid: 7b71dc2a-e945-4100-b392-7c137b6f17d5
  rule: secrets-not-from-env-vars
  scored: true
  status: pass
summary:
  error: 0
  fail: 0
  pass: 1
  skip: 0
  warn: 0
```

Create another Pod which violates the rule in the sample policy. Because the rule is written with `validationFailureAction: audit`, resources are allowed to be created which violate the rule. If this occurs, another entry will be created in the PolicyReport which denotes this condition as a FAIL. By contrast, if `validationFailureAction: enforce` and an offending resource was attempted creation, it would be immediately blocked and therefore would not generate another entry in the report.

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
results:
- message: validation rule 'secrets-not-from-env-vars' passed.
  policy: secrets-not-from-env-vars
  resources:
  - apiVersion: v1
    kind: Pod
    name: busybox
    namespace: default
    uid: 7b71dc2a-e945-4100-b392-7c137b6f17d5
  rule: secrets-not-from-env-vars
  scored: true
  status: pass
- message: 'validation error: Secrets must be mounted as volumes, not as environment
    variables. Rule secrets-not-from-env-vars failed at path /spec/containers/0/env/0/valueFrom/secretKeyRef/'
  policy: secrets-not-from-env-vars
  resources:
  - apiVersion: v1
    kind: Pod
    name: secret-pod
    namespace: default
    uid: 6b6262a1-318b-45f8-979b-3e35201b6d64
  rule: secrets-not-from-env-vars
  scored: true
  status: fail
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

$ kubectl get polr polr-ns-default -o wide
NAME              KIND   NAME   PASS   FAIL   WARN   ERROR   SKIP   AGE
polr-ns-default                 1      0      0      0       0      28h
```

Notice how the PolicyReport has removed the previously-failed entry when the violating Pod was deleted.

## Example: Trigger a ClusterPolicyReport

A ClusterPolicyReport is the same concept as a PolicyReport only it contains resources which are cluster scoped rather than namespaced.

As an example, create the following sample ClusterPolicy containing a single rule which validates that all new Namespaces should contain the label called `thisshouldntexist` and have some value. Notice how `validationFailureAction: audit` and `background: true` in this ClusterPolicy.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: require-ns-labels
spec:
  validationFailureAction: audit
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
$ kubectl get cpolr
NAME                  PASS   FAIL   WARN   ERROR   SKIP   AGE
clusterpolicyreport   0      3      0      0       0      27h
```

Notice that a default ClusterPolicyReport named `clusterpolicyreport` exists with three failures.

The ClusterPolicyReport, when inspected, has the same structure as the PolicyReport object and contains entries in the `results` and `summary` objects with the outcomes of a policy audit.

```yaml
results:
- message: 'validation error: The label `thisshouldntexist` is required. Rule check-for-labels-on-namespace
    failed at path /metadata/labels/thisshouldntexist/'
  policy: require-ns-labels
  resources:
  - apiVersion: v1
    kind: Namespace
    name: argocd
    uid: 0b139fa6-ea7f-43ab-9619-03ab430811ec
  rule: check-for-labels-on-namespace
  scored: true
  status: fail
- message: 'validation error: The label `thisshouldntexist` is required. Rule check-for-labels-on-namespace
    failed at path /metadata/labels/'
  policy: require-ns-labels
  resources:
  - apiVersion: v1
    kind: Namespace
    name: tkg-system-public
    uid: 431c10e5-3926-47d8-963f-c76a65f9b84d
  rule: check-for-labels-on-namespace
  scored: true
  status: fail
- message: 'validation error: The label `thisshouldntexist` is required. Rule check-for-labels-on-namespace
    failed at path /metadata/labels/'
  policy: require-ns-labels
  resources:
  - apiVersion: v1
    kind: Namespace
    name: default
    uid: d5f89d01-2d44-4957-bc86-a9aa757bd311
  rule: check-for-labels-on-namespace
  scored: true
  status: fail
summary:
  error: 0
  fail: 3
  pass: 0
  skip: 0
  warn: 0
```

{{% alert title="Note" color="info" %}}
By default, Kyverno's configuration filters out certain key system-level Namespaces from showing in a ClusterPolicyReport in order to eliminate background noise. This can be changed by editing the Kyverno ConfigMap and adjusting the `resourceFilters` entry. For more information, see the [Resource Filters section](/docs/installation/#resource-filters) in the [Installation guide](/docs/installation/).
{{% /alert %}}
