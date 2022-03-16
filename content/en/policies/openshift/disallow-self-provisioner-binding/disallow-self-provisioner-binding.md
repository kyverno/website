---
title: "Disallow binding to self-provisioner cluster role in OpenShift"
category: OpenShift
version: 1.6.0
subject: ClusterRoleBinding
policyType: "validate"
description: >
    This policy prevents binding to the self-provisioners role for strict control of OpenShift project creation.
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/release-1.6//openshift/disallow-self-provisioner-binding/disallow-self-provisioner-binding.yaml" target="-blank">/openshift/disallow-self-provisioner-binding/disallow-self-provisioner-binding.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: disallow-self-provisioner-binding
  annotations:
    policies.kyverno.io/title: Disallow binding to self-provisioner cluster role in OpenShift
    policies.kyverno.io/category: OpenShift
    policies.kyverno.io/severity: high
    kyverno.io/kyverno-version: 1.6.0
    policies.kyverno.io/minversion: 1.6.0
    kyverno.io/kubernetes-version: "1.20"
    policies.kyverno.io/subject: ClusterRoleBinding
    policies.kyverno.io/description: >-
      This policy prevents binding to the self-provisioners role for strict control of OpenShift project creation.
spec:
  validationFailureAction: enforce
  background: true
  rules:
  - name: check-self-provisioner-binding-no-subject
    match:
      any:
      - resources:
          kinds:
          - ClusterRoleBinding
    preconditions:
      all:
      - key: "{{request.object.metadata.name}}"
        operator: Equals
        value: self-provisioners
      - key: "{{request.operation}}"
        operator: Equals
        value: UPDATE
    validate:
      message: >-
        Binding to the self-provisioners cluster role is not allowed.
      pattern:
        =(subjects): {}
  - name: check-self-provisioner-binding-with-subject
    match:
      any:
      - resources:
          kinds:
          - ClusterRoleBinding
    preconditions:
      all:
      - key: "{{request.object.metadata.name || ''}}"
        operator: NotEquals
        value: self-provisioners
    validate:
      message: >-
        Binding to the self-provisioners cluster role is not allowed.
      deny:
        conditions:
          all:
          - key: self-provisioner
            operator: In
            value: "{{request.object.roleRef.name}}"

```
