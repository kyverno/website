---
type: "docs"
title: Restrict External Ips
linkTitle: Restrict External Ips
weight: 13
description: >
    Service externalIPs can be used for a MITM attack (CVE-2020-8554). Restrict externalIPs or limit to a known set of addresses. See: https://github.com/kyverno/kyverno/issues/1367.
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//best-practices/restrict-service-external-ips/restrict-service-external-ips.yaml" target="-blank">/best-practices/restrict-service-external-ips/restrict-service-external-ips.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: restrict-external-ips
  annotations:
    policies.kyverno.io/title: Restrict External IPs
    policies.kyverno.io/category: Best Practices
    policies.kyverno.io/description: >-
      Service externalIPs can be used for a MITM attack (CVE-2020-8554).
      Restrict externalIPs or limit to a known set of addresses.
      See: https://github.com/kyverno/kyverno/issues/1367.
spec:
  validationFailureAction: audit
  rules:
  - name: check-ips
    match:
      resources:
        kinds:
        - Service
    validate:
      message: "externalIPs are not allowed."
      pattern:
        spec:
          # restrict external IP addresses
          # you can alternatively restrict to a known set of addresses using:
          #     =(externalIPs): ["37.10.11.53", "153.10.20.1"]
          X(externalIPs): nil
```
