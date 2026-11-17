---
title: 'Cleanup Expired ConfigMaps'
category: cleanup
severity: medium
type: DeletingPolicy
subjects:
  - ConfigMap
tags:
  - Cleanup
version: 1.20.0
description: 'Every minute, delete ConfigMaps explicitly labeled cleanup.example.com/enabled=true whose cleanup.example.com/expires-at annotation is an RFC3339 timestamp in the past. Unlabeled ConfigMaps and ConfigMaps without an expiration are retained. Invalid timestamps cause evaluation errors, not deletion. Grant the cleanup controller ConfigMap list, watch, get, and delete permissions using the accompanying RBAC.'
createdAt: "2026-11-08T02:12:54.000Z"
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/cleanup-dpol/cleanup-expired-configmaps/cleanup-expired-configmaps.yaml" target="_blank" rel="noopener noreferrer">/cleanup-dpol/cleanup-expired-configmaps/cleanup-expired-configmaps.yaml</a>

```yaml
apiVersion: policies.kyverno.io/v1
kind: DeletingPolicy
metadata:
  name: cleanup-expired-configmaps
  annotations:
    policies.kyverno.io/title: Cleanup Expired ConfigMaps
    policies.kyverno.io/category: Cleanup
    policies.kyverno.io/severity: medium
    policies.kyverno.io/subject: ConfigMap
    policies.kyverno.io/minversion: 1.20.0
    policies.kyverno.io/description: Every minute, delete ConfigMaps explicitly labeled cleanup.example.com/enabled=true whose cleanup.example.com/expires-at annotation is an RFC3339 timestamp in the past. Unlabeled ConfigMaps and ConfigMaps without an expiration are retained. Invalid timestamps cause evaluation errors, not deletion. Grant the cleanup controller ConfigMap list, watch, get, and delete permissions using the accompanying RBAC.
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
        cleanup.example.com/enabled: "true"
  conditions:
    - name: has-expiration
      expression: has(object.metadata.annotations) && 'cleanup.example.com/expires-at' in object.metadata.annotations
    - name: expired
      expression: timestamp(object.metadata.annotations['cleanup.example.com/expires-at']) < time.now()

```
