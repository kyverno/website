---
title: 'Restrict External IPs in CEL expressions'
category: validate
severity: medium
type: ClusterPolicy
subjects:
  - Service
tags: []
version: 1.11.0
description: 'Service externalIPs can be used for a MITM attack (CVE-2020-8554). Restrict externalIPs or limit to a known set of addresses. See: https://github.com/kyverno/kyverno/issues/1367. This policy validates that the `externalIPs` field is not set on a Service.'
isNew: true
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/best-practices-cel/restrict-service-external-ips/restrict-service-external-ips.yaml" target="-blank">/best-practices-cel/restrict-service-external-ips/restrict-service-external-ips.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: restrict-external-ips
  annotations:
    policies.kyverno.io/title: Restrict External IPs in CEL expressions
    policies.kyverno.io/category: Best Practices in CEL
    policies.kyverno.io/minversion: 1.11.0
    kyverno.io/kubernetes-version: 1.26-1.27
    policies.kyverno.io/severity: medium
    policies.kyverno.io/subject: Service
    policies.kyverno.io/description: 'Service externalIPs can be used for a MITM attack (CVE-2020-8554). Restrict externalIPs or limit to a known set of addresses. See: https://github.com/kyverno/kyverno/issues/1367. This policy validates that the `externalIPs` field is not set on a Service.'
spec:
  validationFailureAction: Audit
  background: true
  rules:
    - name: check-ips
      match:
        any:
          - resources:
              kinds:
                - Service
              operations:
                - CREATE
                - UPDATE
      validate:
        cel:
          expressions:
            - expression: '!has(object.spec.externalIPs)'
              message: externalIPs are not allowed.
```
