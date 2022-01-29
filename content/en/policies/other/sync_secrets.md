---
title: "Sync Secrets"
category: Sample
version: 
subject: Secret
policyType: "generate"
description: >
    Secrets like registry credentials often need to exist in multiple Namespaces so Pods there have access. Manually duplicating those Secrets is time consuming and error prone. This policy will copy a Secret called `regcred` which exists in the `default` Namespace to new Namespaces when they are created. It will also push updates to the copied Secrets should the source Secret be changed.
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//other/sync_secrets.yaml" target="-blank">/other/sync_secrets.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: sync-secrets
  annotations:
    policies.kyverno.io/title: Sync Secrets
    policies.kyverno.io/category: Sample
    policies.kyverno.io/subject: Secret
    policies.kyverno.io/description: >-
      Secrets like registry credentials often need to exist in multiple
      Namespaces so Pods there have access. Manually duplicating those Secrets
      is time consuming and error prone. This policy will copy a
      Secret called `regcred` which exists in the `default` Namespace to
      new Namespaces when they are created. It will also push updates to
      the copied Secrets should the source Secret be changed.
spec:
  rules:
  - name: sync-image-pull-secret
    match:
      resources:
        kinds:
        - Namespace
    generate:
      kind: Secret
      name: regcred
      namespace: "{{request.object.metadata.name}}"
      synchronize: true
      clone:
        namespace: default
        name: regcred
```
