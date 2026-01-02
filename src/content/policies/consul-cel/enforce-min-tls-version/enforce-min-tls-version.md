---
title: 'Enforce Consul min TLS version  in CEL expressions'
category: validate
severity: medium
type: ClusterPolicy
subjects:
  - Mesh
tags:
  - Consul in CEL
version: 1.11.0
description: 'This policy will check the TLS Min version to ensure that whenever the mesh is set, there is a minimum version of TLS set for all the service mesh proxies and this enforces that service mesh mTLS traffic uses TLS v1.2 or newer.'
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/consul-cel/enforce-min-tls-version/enforce-min-tls-version.yaml" target="-blank">/consul-cel/enforce-min-tls-version/enforce-min-tls-version.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: enforce-min-tls-version
  annotations:
    policies.kyverno.io/title: Enforce Consul min TLS version  in CEL expressions
    policies.kyverno.io/category: Consul in CEL
    policies.kyverno.io/severity: medium
    policies.kyverno.io/subject: Mesh
    kyverno.io/kyverno-version: 1.11.0
    policies.kyverno.io/minversion: 1.11.0
    kyverno.io/kubernetes-version: 1.26-1.27
    policies.kyverno.io/description: This policy will check the TLS Min version to ensure that whenever the mesh is set, there is a minimum version of TLS set for all the service mesh proxies and this enforces that service mesh mTLS traffic uses TLS v1.2 or newer.
spec:
  validationFailureAction: Enforce
  background: true
  rules:
    - name: check-for-tls-version
      match:
        any:
          - resources:
              kinds:
                - Mesh
              operations:
                - CREATE
                - UPDATE
      validate:
        cel:
          expressions:
            - expression: object.?spec.?tls.?incoming.?tlsMinVersion.orValue('') == 'TLSv1_2'
              message: The minimum version of TLS is TLS v1_2
```
