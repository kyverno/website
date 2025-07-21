---
title: OpenReports Integration 
description: Use openreports.io/v1alpha1 for policy reporting in Kyverno.
weight: 15
---

> **Note:** OpenReports integration is available as of Kyverno 1.15.

Kyverno supports reporting policy results using the `openreports.io/v1alpha1` API as an alternative to the default wgpolicyk8s reporting. This can be enabled using the `--openreportsEnabled` flag in the Kyverno controller.


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
