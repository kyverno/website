---
title: Example Scenarios 
description: Follow along scenarios for creating and viewing your first policy reports.
weight: 25
---

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

{{% alert title="Note" color="info" %}}
Note that a namespaced `Policy` applies only to namespaced resources and only in the Namespace in which they are created. This example would have been exactly the same if we had used a `Policy` instead of `ClusterPolicy`.

For a cluster level resource, a `ClusterPolicyReport` would have been created at cluster level instead of a namespaced `PolicyReport`.
{{% /alert %}}
