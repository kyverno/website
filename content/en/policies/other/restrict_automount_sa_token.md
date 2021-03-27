---
type: "docs"
title: Restrict Automount Sa Token
linkTitle: Restrict Automount Sa Token
weight: 16
description: >
    Kubernetes automatically mounts service account credentials in each pod.  The service account may be assigned roles allowing pods to access API resources.  To restrict access, opt out of auto-mounting tokens by setting  automountServiceAccountToken to false.
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//other/restrict_automount_sa_token.yaml" target="-blank">/other/restrict_automount_sa_token.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: restrict-automount-sa-token
  annotations:
    policies.kyverno.io/title: Restrict Auto-Mount of Service Account Tokens
    policies.kyverno.io/category: Sample
    policies.kyverno.io/description: >-
      Kubernetes automatically mounts service account credentials in each pod. 
      The service account may be assigned roles allowing pods to access API resources. 
      To restrict access, opt out of auto-mounting tokens by setting 
      automountServiceAccountToken to false.
spec:
  rules:
  - name: validate-automountServiceAccountToken
    match:
      resources:
        kinds:
        - Pod
    validate:
      message: "Auto-mounting of Service Account tokens is not allowed."
      pattern:
        spec:
          automountServiceAccountToken: false
```
