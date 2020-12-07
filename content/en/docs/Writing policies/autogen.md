---
title: Auto-Gen Rules for Pod Controllers
description: >
    Automatically generate rules for Pod controllers.
weight: 8
---

{{% alert title="Note" color="info" %}}
The auto-gen feature is only supported for validation rules with patterns and mutation rules with overlay or patch strategic merge. Deny rules and generate rules are not supported.
{{% /alert %}}

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
      resources:
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
    Match:
      Resources:
        Kinds:
          DaemonSet
          Deployment
          Job
          StatefulSet
    Name:  autogen-validate-registries
    Validate:
      Message:  Images may only come from our internal enterprise registry.
      Pattern:
        Spec:
          Template:
            Spec:
              Containers:
                Image:  registry.domain.com/*
    Match:
      Resources:
        Kinds:
          CronJob
    Name:  autogen-cronjob-validate-registries
    Validate:
      Message:  Images may only come from our internal enterprise registry.
      Pattern:
        Spec:
          Job Template:
            Spec:
              Template:
                Spec:
                  Containers:
                    Image:    registry.domain.com/*
  Validation Failure Action:  enforce
```

This auto-generation behavior is controlled by the `pod-policies.kyverno.io/autogen-controllers` annotation.

By default, Kyverno inserts an annotation `pod-policies.kyverno.io/autogen-controllers=DaemonSet,Deployment,Job,StatefulSet,CronJob`, to generate additional rules that are applied to these controllers.

You can change the annotation `pod-policies.kyverno.io/autogen-controllers` to customize the target Pod controllers for the auto-generated rules. For example, Kyverno generates a rule for a `Deployment` if the annotation of policy is defined as `pod-policies.kyverno.io/autogen-controllers=Deployment`.

When a `name` or `labelSelector` is specified in the `match` or `exclude` block, Kyverno skips generating Pod controller rules as these filters may not be applicable to Pod controllers.

To disable auto-generating rules for Pod controllers set `pod-policies.kyverno.io/autogen-controllers`  to the value `none`.
