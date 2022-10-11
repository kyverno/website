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

Once the policy is created, these other resources can be shown in auto-generated rules which Kyverno adds to the policy under the `status` object.

```yaml
status:
  autogen:
    rules:
    - exclude:
        resources: {}
      generate:
        clone: {}
        cloneList: {}
      match:
        any:
        - resources:
            kinds:
            - DaemonSet
            - Deployment
            - Job
            - StatefulSet
        resources: {}
      mutate: {}
      name: autogen-validate-registries
      validate:
        message: Images may only come from our internal enterprise registry.
        pattern:
          spec:
            template:
              spec:
                containers:
                - image: registry.domain.com/*
    - exclude:
        resources: {}
      generate:
        clone: {}
        cloneList: {}
      match:
        any:
        - resources:
            kinds:
            - CronJob
        resources: {}
      mutate: {}
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
```

This auto-generation behavior is controlled by the `pod-policies.kyverno.io/autogen-controllers` annotation.

You can change the annotation `pod-policies.kyverno.io/autogen-controllers` to customize the target Pod controllers for the auto-generated rules. For example, Kyverno generates a rule for a `Deployment` if the annotation of policy is defined as `pod-policies.kyverno.io/autogen-controllers=Deployment`.

Kyverno skips generating Pod controller rules whenever the following `resources` fields/objects are specified in a `match` or `exclude` block as these filters may not be applicable to Pod controllers:

* `name` (deprecated)
* `selector`
* `annotations`

Additionally, Kyverno only auto-generates rules when the resource kind specified in a combination of `match` and `exclude` is no more than `Pod`. Mutate rules which match on `Pod` and use a JSON patch are also excluded from rule auto-generation as noted [here](/docs/writing-policies/mutate/#rfc-6902-jsonpatch).

To disable auto-generating rules for Pod controllers set `pod-policies.kyverno.io/autogen-controllers`  to the value `none`.

When disabling auto-generation rules for select Pod controllers, Kyverno still applies policy matching on Pods to those spawned by those controllers. To exempt these Pods, use [preconditions](/docs/writing-policies/preconditions/) with an expression similar to the below which may allow Pods created by a Job controller to pass.

```yaml
- key: Job
  operator: AnyNotIn
  value: "{{ request.object.metadata.ownerReferences[].kind }}"
```

## Exclusion by Metadata

In some cases it may be desirable to use an `exclude` block applied to Pods that uses either labels or annotations. For example, the following `match` and `exclude` statement may be written, the purpose of which would be to match any Pods except those that have the annotation `policy.test/require-requests-limits=skip`.

```yaml
rules:
  - name: validate-resources
    match:
      any:
      - resources:
          kinds:
            - Pod
    exclude:
      any:
      - resources:
          annotations:
            policy.test/require-requests-limits: skip
```

When Kyverno sees these types of fields as mentioned above it skips auto-generation for the rule. The next choice may be to use preconditions to achieve the same effect but by writing an expression that looks at `request.object.metadata.*`. As part of auto-generation, Kyverno will see any variables from AdmissionReview such as that beginning with `request.object` and translate it for each of the applicable Pod controllers. The result may be that the auto-generated rule for, as an example, Deployments will get translated to `request.object.spec.template.metadata.*` which references the `metadata` object inside the Pod template and not the `metadata` object of the Deployment itself. To work around this and have preconditions which are not translated for these metadata use cases, double quote the `object` portion of the variable as shown below.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: require-requests-limits
spec:
  validationFailureAction: enforce
  background: true
  rules:
    - name: validate-resources
      match:
        any:
        - resources:
            kinds:
              - Pod
      preconditions:
        all:
        - key: "{{ request.\"object\".metadata.annotations.\"policy.test.io/require-requests-limits\" || '' }}"
          operator: NotEquals
          value: skip
      validate:
        message: "CPU and memory resource requests and limits are required."
        pattern:
          spec:
            containers:
              - resources:
                  requests:
                    memory: "?*"
                    cpu: "?*"
                  limits:
                    memory: "?*"
```

The result will have the same effect as the first snippet which uses an `exclude` block and have the benefit of auto-generation coverage.
