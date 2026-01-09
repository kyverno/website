---
title: 'Restrict External IPs'
category: validate
severity: medium
type: ClusterPolicy
subjects:
  - Service
tags:
  - Best Practices
version: 1.6.0
description: 'Service externalIPs can be used for a MITM attack (CVE-2020-8554). Restrict externalIPs or limit to a known set of addresses. See: https://github.com/kyverno/kyverno/issues/1367. This policy validates that the `externalIPs` field is not set on a Service.'
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/best-practices/restrict-service-external-ips/restrict-service-external-ips.yaml" target="-blank">/best-practices/restrict-service-external-ips/restrict-service-external-ips.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: restrict-external-ips
  annotations:
    policies.kyverno.io/title: Restrict External IPs
    policies.kyverno.io/category: Best Practices
    policies.kyverno.io/minversion: 1.6.0
    policies.kyverno.io/severity: medium
    policies.kyverno.io/subject: Service
    policies.kyverno.io/description: "Service externalIPs can be used for a MITM attack (CVE-2020-8554). Restrict externalIPs or limit to a known set of addresses. See: https://github.com/kyverno/kyverno/issues/1367. This policy validates that the `externalIPs` field is not set on a Service."
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
      validate:
        message: externalIPs are not allowed.
        pattern:
          spec:
            X(externalIPs): "null"

```
