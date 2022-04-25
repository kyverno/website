---
title: "Limit ConfigMap to ServiceAccounts for a User"
category: Other
version: 
subject: ConfigMap, ServiceAccount
policyType: "validate"
description: >
    This policy shows how to restrict certain operations on specific ConfigMaps by ServiceAccounts.
---

## Policy Definition
<a href="https://github.com/JimBugwadia/kyverno-policies/raw/fix_annotations//other/limit-configmap-for-sa/limit_configmap_for_sa.yaml" target="-blank">/other/limit-configmap-for-sa/limit_configmap_for_sa.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: limit-configmap-for-sa
  annotations:
    policies.kyverno.io/title: Limit ConfigMap to ServiceAccounts for a User
    policies.kyverno.io/category: Other
    policies.kyverno.io/severity: medium
    kyverno.io/kyverno-version: 1.6.0
    kyverno.io/kubernetes-version: "1.20-1.23"
    policies.kyverno.io/subject: ConfigMap, ServiceAccount
    policies.kyverno.io/description: This policy shows how to restrict certain operations on specific ConfigMaps by ServiceAccounts.
spec:
  background: false
  validationFailureAction: audit
  rules:
  - name: limit-configmap-for-sa-developer
    match:
      any:
      - resources:
          kinds:
          - "ConfigMap"
        subjects:
        - kind: ServiceAccount
          name: developer
          namespace: kube-system
      - resources:
          kinds:
          - "ConfigMap"
        subjects:
        - kind: ServiceAccount
          name: another-developer
          namespace: another-namespace
    preconditions:
      all:
      - key: "{{request.object.metadata.namespace}}"
        operator: In
        value:
        - "any-namespace"
        - "another-namespace"
      - key: "{{request.object.metadata.name}}"
        operator: In
        value:
        - "any-configmap-name-good"
        - "another-configmap-name"
    validate:
      message: "{{request.object.metadata.namespace}}/{{request.object.kind}}/{{request.object.metadata.name}} resource is protected. Admin or allowed users can change the resource"
      deny:
        conditions:
          all:
          - key: "{{request.operation}}"
            operator: "In"
            value:
            - "UPDATE"
            - "CREATE"

```
