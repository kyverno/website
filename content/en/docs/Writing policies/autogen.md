---
title: Auto-Gen Rules for Pod Controllers
description: >
    Automatically generate rules for Pod controllers.
weight: 9
---

Pods are one of the most common object types in Kubernetes and as such are the focus of most types of validation rules. But creation of Pods directly is almost never done as it is considered an anti-pattern. Instead, Kubernetes has many higher-level controllers that directly or indirectly manage Pods, namely the Deployment, DaemonSet, StatefulSet, Job, and CronJob resources. Writing policy that targets Pods but must be written for every one of these controllers would be tedious and inefficient. Kyverno solves this issue by supporting automatic generation of policy rules for higher-level controllers from a rule written for a Pod.

{{% alert title="Note" color="info" %}}
Kyverno 1.9 adds support for including ReplicaSets and ReplicationControllers to auto-gen rules. These two intermediary controllers share the same Pod template schema as DaemonSets, Deployments, StatefulSets, and Jobs.
{{% /alert %}}

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
            - ReplicaSet
            - ReplicationController
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

Similar to the automatic translation of expressions beginning with `request.object.metadata.*`, Kyverno also auto-generates rules for Pod controllers when a pattern specifies the same structure. For example, the [disallow default namespace policy](https://kyverno.io/policies/best-practices/disallow_default_namespace/disallow_default_namespace/) is a validate rule which uses an overlay pattern to ensure that neither a Pod nor any of its controllers can use the `default` Namespace.

```yaml
pattern:
  metadata:
    namespace: "!default"
```

With auto-gen set to its default, this will get translated in the case of Deployments and others to the following below which is not the desire when expressing such a rule as the `namespace` field is not defined under the Pod template when using a Pod controller. This auto-generated pattern will therefore cause all applicable Pod controllers to be in violation of the translated pattern.

```yaml
pattern:
  spec:
    template:
      metadata:
        namespace: "!default"
```

In such cases, auto-gen should be disabled as described above and one or more rules written to explicitly control the matching resources and the patterns/expressions used against them.
