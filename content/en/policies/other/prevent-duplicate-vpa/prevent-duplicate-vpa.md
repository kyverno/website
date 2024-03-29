---
title: "Prevent Duplicate VerticalPodAutoscalers"
category: Other
version: 
subject: VerticalPodAutoscaler
policyType: "validate"
description: >
    VerticalPodAutoscaler (VPA) is useful to automatically adjust the resources assigned to Pods. It requires defining a specific target resource by kind and name. There are no built-in validation checks by the VPA controller to prevent the creation of multiple VPAs which target the same resource. This policy has two rules, the first of which ensures that the only targetRef kinds accepted are one of either Deployment, StatefulSet, ReplicaSet, or DaemonSet. The second prevents the creation of duplicate VPAs by validating that any new VPA targets a unique resource.
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//other/prevent-duplicate-vpa/prevent-duplicate-vpa.yaml" target="-blank">/other/prevent-duplicate-vpa/prevent-duplicate-vpa.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: prevent-duplicate-vpa
  annotations:
    policies.kyverno.io/title: Prevent Duplicate VerticalPodAutoscalers
    policies.kyverno.io/category: Other
    policies.kyverno.io/severity: medium
    kyverno.io/kyverno-version: 1.11.4
    kyverno.io/kubernetes-version: "1.27"
    policies.kyverno.io/subject: VerticalPodAutoscaler
    policies.kyverno.io/description: >-
      VerticalPodAutoscaler (VPA) is useful to automatically adjust the resources assigned to Pods.
      It requires defining a specific target resource by kind and name. There are no built-in
      validation checks by the VPA controller to prevent the creation of multiple VPAs which target
      the same resource. This policy has two rules, the first of which ensures that the only targetRef
      kinds accepted are one of either Deployment, StatefulSet, ReplicaSet, or DaemonSet. The second
      prevents the creation of duplicate VPAs by validating that any
      new VPA targets a unique resource.
spec:
  validationFailureAction: Audit
  background: false
  rules:
  - name: verify-kind-name-duplicates
    match:
      any:
      - resources:
          kinds:
          - VerticalPodAutoscaler
          operations:
          - CREATE
    validate:
      message: >-
        The target kind must be specified exactly as Deployment, StatefulSet, ReplicaSet, or DaemonSet.
      pattern:
        spec:
          targetRef:
            kind: Deployment | StatefulSet | ReplicaSet | DaemonSet
  - name: check-targetref-duplicates
    match:
      any:
      - resources:
          kinds:
          - VerticalPodAutoscaler
          operations:
          - CREATE
    preconditions:
      all:
      - key:
        - Deployment
        - StatefulSet
        - ReplicaSet
        - DaemonSet
        operator: AnyIn
        value: "{{ request.object.spec.targetRef.kind }}"
    context:
    - name: targets
      apiCall:
        urlPath: "/apis/autoscaling.k8s.io/v1/namespaces/{{ request.namespace }}/verticalpodautoscalers"
        jmesPath: "items[?spec.targetRef.kind=='{{ request.object.spec.targetRef.kind }}'].spec.targetRef.name"
    validate:
      message: >-
        The target {{ request.object.spec.targetRef.kind }} named
        {{ request.object.spec.targetRef.name }} already has an existing
        VPA configured for it. Duplicate VPAs are not allowed.
      deny:
        conditions:
          all:
          - key: "{{ request.object.spec.targetRef.name }}"
            operator: AnyIn
            value: "{{ targets }}"

```
