---
title: Example Scenarios 
description: >
  Follow along scenarios for creating and viewing your first policy reports.
weight: 25
---

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

Create another Pod which violates the rule in the sample policy. Because the rule is written with `validationFailureAction: Audit`, resources are allowed to be created which violate the rule. If this occurs, another entry will be created in the PolicyReport which denotes this condition as a FAIL. By contrast, if `validationFailureAction: Enforce` and an offending resource was attempted creation, it would be immediately blocked and therefore would not generate another entry in the report. However, if the resource passed then a PASS result would be created in the report.

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

$ kubectl get polr cpol-secrets-not-from-env-vars
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
$ kubectl get cpolr
NAME                     PASS   FAIL   WARN   ERROR   SKIP   AGE
cpol-require-ns-labels   0      5      0      0       0      76m
```

Notice that a ClusterPolicyReport named `cpol-require-ns-labels` exists with five failures. The number of combined results here will depend on the number of Namespaces in your cluster. At the moment the policy was created, Kyverno began inspecting existing Namespaces to evaluate them against the policy.

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
