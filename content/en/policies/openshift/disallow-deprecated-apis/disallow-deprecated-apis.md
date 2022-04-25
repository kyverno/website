---
title: "Disallow deprecated APIs"
category: OpenShift
version: 1.6.0
subject: ClusterRole,ClusterRoleBinding,Role,RoleBinding
policyType: "validate"
description: >
    OpenShift APIs are sometimes deprecated and removed after a few releases. As a best practice, older API versions should be replaced with newer versions. This policy validates for APIs that are deprecated or scheduled for removal. Note that checking for some of these resources may require modifying the Kyverno ConfigMap to remove filters.      
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//openshift/disallow-deprecated-apis/disallow-deprecated-apis.yaml" target="-blank">/openshift/disallow-deprecated-apis/disallow-deprecated-apis.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: disallow-deprecated-apis
  annotations:
    policies.kyverno.io/title: Disallow deprecated APIs
    policies.kyverno.io/category: OpenShift
    policies.kyverno.io/severity: medium
    kyverno.io/kyverno-version: 1.6.0
    policies.kyverno.io/minversion: 1.6.0
    kyverno.io/kubernetes-version: "1.20"
    policies.kyverno.io/subject: ClusterRole,ClusterRoleBinding,Role,RoleBinding
    policies.kyverno.io/description: >-
      OpenShift APIs are sometimes deprecated and removed after a few releases.
      As a best practice, older API versions should be replaced with newer versions.
      This policy validates for APIs that are deprecated or scheduled for removal.
      Note that checking for some of these resources may require modifying the Kyverno
      ConfigMap to remove filters.      
spec:
  validationFailureAction: enforce
  background: true
  rules:
  - name: check-deprecated-apis
    match:
      any:
      - resources:
          kinds:
          - authorization.openshift.io/v1/ClusterRole
          - authorization.openshift.io/v1/ClusterRoleBinding
          - authorization.openshift.io/v1/Role
          - authorization.openshift.io/v1/RoleBinding
    validate:
      message: >-
        {{ request.object.apiVersion }}/{{ request.object.kind }} is deprecated.
      deny: {}

```
