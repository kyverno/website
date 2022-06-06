---
title: "Check deprecated APIs"
category: Best Practices
version: 
subject: Kubernetes APIs
policyType: "validate"
description: >
    Kubernetes APIs are sometimes deprecated and removed after a few releases. As a best practice, older API versions should be replaced with newer versions. This policy validates for APIs that are deprecated or scheduled for removal. Note that checking for some of these resources may require modifying the Kyverno ConfigMap to remove filters.
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//best-practices/check_deprecated_apis/check_deprecated_apis.yaml" target="-blank">/best-practices/check_deprecated_apis/check_deprecated_apis.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: check-deprecated-apis
  annotations:
    policies.kyverno.io/title: Check deprecated APIs
    policies.kyverno.io/category: Best Practices
    policies.kyverno.io/subject: Kubernetes APIs
    kyverno.io/kyverno-version: 1.6.2
    kyverno.io/kubernetes-version: "1.23"
    policies.kyverno.io/description: >-
      Kubernetes APIs are sometimes deprecated and removed after a few releases.
      As a best practice, older API versions should be replaced with newer versions.
      This policy validates for APIs that are deprecated or scheduled for removal.
      Note that checking for some of these resources may require modifying the Kyverno
      ConfigMap to remove filters.
spec:
  validationFailureAction: audit
  background: true
  rules:
  - name: validate-v1-22-removals
    match:
      resources:
        kinds:
        - admissionregistration.k8s.io/*/ValidatingWebhookConfiguration
        - admissionregistration.k8s.io/*/MutatingWebhookConfiguration
        - apiextensions.k8s.io/*/CustomResourceDefinition
        - apiregistration.k8s.io/*/APIService
        - authentication.k8s.io/*/TokenReview
        - authorization.k8s.io/*/SubjectAccessReview
        - authorization.k8s.io/*/LocalSubjectAccessReview
        - authorization.k8s.io/*/SelfSubjectAccessReview
        - certificates.k8s.io/*/CertificateSigningRequest
        - coordination.k8s.io/*/Lease
        - extensions/*/Ingress
        - networking.k8s.io/*/Ingress
        - networking.k8s.io/*/IngressClass
        - rbac.authorization.k8s.io/*/ClusterRole
        - rbac.authorization.k8s.io/*/ClusterRoleBinding
        - rbac.authorization.k8s.io/*/Role
        - rbac.authorization.k8s.io/*/RoleBinding
        - scheduling.k8s.io/*/PriorityClass
        - storage.k8s.io/*/CSIDriver
        - storage.k8s.io/*/CSINode
        - storage.k8s.io/*/StorageClass
        - storage.k8s.io/*/VolumeAttachment
    preconditions:
      all:
      - key: "{{request.object.apiVersion}}"
        operator: AnyIn
        value:
        - admissionregistration.k8s.io/v1beta1
        - apiextensions.k8s.io/v1beta1
        - apiregistration.k8s.io/v1beta1
        - authentication.k8s.io/v1beta1
        - authorization.k8s.io/v1beta1
        - certificates.k8s.io/v1beta1
        - coordination.k8s.io/v1beta1
        - extensions/v1beta1
        - networking.k8s.io/v1beta1
        - rbac.authorization.k8s.io/v1beta1
        - scheduling.k8s.io/v1beta1
        - storage.k8s.io/v1beta1
    validate:
      message: >-
        {{ request.object.apiVersion }}/{{ request.object.kind }} is deprecated and will be removed in v1.22.
        See: https://kubernetes.io/docs/reference/using-api/deprecation-guide/
      deny: {}
  - name: validate-v1-25-removals
    match:
      resources:
        kinds:
        - batch/*/CronJob
        - discovery.k8s.io/*/EndpointSlice
        - events.k8s.io/*/Event
        - policy/*/PodDisruptionBudget
        - policy/*/PodSecurityPolicy
        - node.k8s.io/*/RuntimeClass
    preconditions:
      all:
      - key: "{{request.object.apiVersion}}"
        operator: AnyIn
        value:
        - batch/v1beta1
        - discovery.k8s.io/v1beta1
        - events.k8s.io/v1beta1
        - policy/v1beta1
        - node.k8s.io/v1beta1
    validate:
      message: >-
        {{ request.object.apiVersion }}/{{ request.object.kind }} is deprecated and will be removed in v1.25.
        See: https://kubernetes.io/docs/reference/using-api/deprecation-guide/
      deny: {}
```
