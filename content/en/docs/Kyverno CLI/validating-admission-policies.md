---
title: ValidatingAdmissionPolicies
description: >
  Applying ValidatingAdmissionPolicies to resources using Kyverno CLI
weight: 15
---

`ValidatingAdmissionPolicies` were introduced in Kubernetes 1.26. They use the [Common Expression Language (CEL)](https://github.com/google/cel-spec) to provide an in-process and declarative alternative to [validating admission webhooks](https://kubernetes.io/docs/reference/access-authn-authz/extensible-admission-controllers/#what-are-admission-webhooks). Now, the Kyverno CLI can be used to apply `ValidatingAdmissionPolicies` to resources

With the `apply` command, `ValidatingAdmissionPolicies` can be applied to resources as follows:

Policy manifest (check-deployment-replicas.yaml):
```yaml
apiVersion: admissionregistration.k8s.io/v1alpha1
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
Apply the `ValidatingAdmissionPolicy` to the resource:
```sh
kyverno apply /path/to/check-deployment-replicas.yaml --resource /path/to/deployment.yaml
```
The following output will be generated:
```sh
Applying 1 policy rule(s) to 1 resource(s)...

pass: 1, fail: 0, warn: 0, error: 0, skip: 0 
```

The `test` command is used to test a given set of resources against one or more `ValidatingAdmissionPolicies` to check desired results, declared in advance in a separate test manifest file (kyverno-test.yaml), against the actual results. The test passes if the actual results match the expected results.

Below is an example of testing a `ValidatingAdmissionPolicy` against two resources, one of which violates the policy.

Policy manifest (disallow-host-path.yaml):
```yaml
apiVersion: admissionregistration.k8s.io/v1alpha1
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
