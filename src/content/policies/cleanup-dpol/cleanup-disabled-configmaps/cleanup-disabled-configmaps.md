---
title: 'Cleanup ConfigMaps with a Namespace Switch'
category: cleanup
severity: medium
type: DeletingPolicy
subjects:
  - ConfigMap
tags:
  - Cleanup
version: 1.20.0
description: 'Demonstrate a resource lookup during scheduled cleanup. Delete ConfigMaps labeled cleanup.example.com/temporary=true only if a cleanup-settings ConfigMap in the same namespace has data.enabled set to "true". The settings ConfigMap itself is always retained. A missing settings ConfigMap produces an evaluation error and does not authorize deletion. Grant the cleanup controller ConfigMap permissions using the accompanying RBAC.'
createdAt: "2026-11-08T02:12:54.000Z"
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/cleanup-dpol/cleanup-disabled-configmaps/cleanup-disabled-configmaps.yaml" target="_blank" rel="noopener noreferrer">/cleanup-dpol/cleanup-disabled-configmaps/cleanup-disabled-configmaps.yaml</a>

```yaml
apiVersion: policies.kyverno.io/v1
kind: DeletingPolicy
metadata:
  name: cleanup-disabled-configmaps
  annotations:
    policies.kyverno.io/title: Cleanup ConfigMaps with a Namespace Switch
    policies.kyverno.io/category: Cleanup
    policies.kyverno.io/severity: medium
    policies.kyverno.io/subject: ConfigMap
    policies.kyverno.io/minversion: 1.20.0
    policies.kyverno.io/description: Demonstrate a resource lookup during scheduled cleanup. Delete ConfigMaps labeled cleanup.example.com/temporary=true only if a cleanup-settings ConfigMap in the same namespace has data.enabled set to "true". The settings ConfigMap itself is always retained. A missing settings ConfigMap produces an evaluation error and does not authorize deletion. Grant the cleanup controller ConfigMap permissions using the accompanying RBAC.
spec:
  schedule: "* * * * *"
  matchConstraints:
    resourceRules:
      - apiGroups:
          - ""
        apiVersions:
          - v1
        resources:
          - configmaps
    objectSelector:
      matchLabels:
        cleanup.example.com/temporary: "true"
  conditions:
    - name: preserve-settings
      expression: object.metadata.name != 'cleanup-settings'
    - name: namespace-switch-enabled
      expression: resource.Get("v1", "configmaps", object.metadata.namespace, "cleanup-settings").data.enabled == 'true'

```
