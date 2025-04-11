---
title: ValidatingAdmissionPolicy Reports
description: Generate Policy Reports for ValidatingAdmissionPolicies and their bindings.
weight: 15
---

Kyverno can generate reports for ValidatingAdmissionPolicies and their bindings. These reports provide information about the resources that are validated by the policies and the results of the validation. They can be used to monitor the health of the cluster and to ensure that the policies are being enforced as expected.

To configure Kyverno to generate reports for ValidatingAdmissionPolicies, set the `--validatingAdmissionPolicyReports` flag to `true` in the reports controller. This flag is set to `false` by default.

## Example: Trigger a PolicyReport

Create a ValidatingAdmissionPolicy that checks the Deployment replicas and a ValidatingAdmissionPolicyBinding that binds the policy to a namespace whose labels set to `environment: staging`.

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
