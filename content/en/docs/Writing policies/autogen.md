---
title: Auto-Gen Rules for Pod Controllers
description: >
    Automatically generate rules for Pod controllers.
weight: 9
---

Pods are one of the most common object types in Kubernetes and as such are the focus of most types of validation rules. But creation of Pods directly is almost never done as it is considered an anti-pattern. Instead, Kubernetes has many higher-level controllers that directly or indirectly manage Pods, namely the Deployment, DaemonSet, StatefulSet, Job, and CronJob resources. Writing policy that targets Pods but must be written for every one of these controllers would be tedious and inefficient. Kyverno solves this issue by supporting automatic generation of policy rules for higher-level controllers from a rule written for a Pod.

For example, when creating a validation policy like below which checks that all images come from an internal, trusted registry, the policy applies to all resources capable of generating Pods.

```yaml
apiVersion : kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: restrict-image-registries
spec:
  validationFailureAction: enforce
  rules:
  - name: validate-registries
    match:
      any:
      - resources:
          kinds:
          - Pod
    validate:
      message: "Images may only come from our internal enterprise registry."
      pattern:
        spec:
          containers:
          - image: "registry.domain.com/*"
```

Once the policy is created, these other resources can be shown in auto-generated rules which Kyverno adds to the policy.

```yaml
spec:
  background: true
  failurePolicy: Fail
  rules:
  - match:
      any:
      - resources:
          kinds:
          - Pod
    name: validate-registries
    validate:
      message: Images may only come from our internal enterprise registry.
      pattern:
        spec:
          containers:
          - image: registry.domain.com/*
  - match:
      any:
      - resources:
          kinds:
          - DaemonSet
          - Deployment
          - Job
          - StatefulSet
    name: autogen-validate-registries
    validate:
      message: Images may only come from our internal enterprise registry.
      pattern:
        spec:
          template:
            spec:
              containers:
              - image: registry.domain.com/*
  - match:
      any:
      - resources:
          kinds:
          - CronJob
    name: autogen-cronjob-validate-registries
    validate:
      message: Images may only come from our internal enterprise registry.
      pattern:
        spec:
          jobTemplate:
            spec:
              template:
                spec:
                  containers:
                  - image: registry.domain.com/*
  validationFailureAction: enforce
```

This auto-generation behavior is controlled by the `pod-policies.kyverno.io/autogen-controllers` annotation.

By default, Kyverno inserts an annotation `pod-policies.kyverno.io/autogen-controllers=DaemonSet,Deployment,Job,StatefulSet,CronJob`, to generate additional rules that are applied to these controllers.

You can change the annotation `pod-policies.kyverno.io/autogen-controllers` to customize the target Pod controllers for the auto-generated rules. For example, Kyverno generates a rule for a `Deployment` if the annotation of policy is defined as `pod-policies.kyverno.io/autogen-controllers=Deployment`.

When a `name` or `labelSelector` is specified in the `match` or `exclude` block, Kyverno skips generating Pod controller rules as these filters may not be applicable to Pod controllers.

To disable auto-generating rules for Pod controllers set `pod-policies.kyverno.io/autogen-controllers`  to the value `none`.
