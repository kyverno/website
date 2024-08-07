---
title: "Restrict Edit for Endpoints CVE-2021-25740 in CEL expressions"
category: Security in CEL
version: 
subject: ClusterRole
policyType: "validate"
description: >
    Clusters not initially installed with Kubernetes 1.22 may be vulnerable to an issue defined in CVE-2021-25740 which could enable users to send network traffic to locations they would otherwise not have access to via a confused deputy attack. This was due to the system:aggregate-to-edit ClusterRole having edit permission of Endpoints. This policy, intended to run in background mode, checks if your cluster is vulnerable to CVE-2021-25740 by ensuring the system:aggregate-to-edit ClusterRole does not have the edit permission of Endpoints.
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//other-cel/restrict-edit-for-endpoints/restrict-edit-for-endpoints.yaml" target="-blank">/other-cel/restrict-edit-for-endpoints/restrict-edit-for-endpoints.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: restrict-edit-for-endpoints
  annotations:
    policies.kyverno.io/title: Restrict Edit for Endpoints CVE-2021-25740 in CEL expressions
    policies.kyverno.io/category: Security in CEL 
    policies.kyverno.io/severity: low
    policies.kyverno.io/subject: ClusterRole
    kyverno.io/kyverno-version: 1.11.0
    kyverno.io/kubernetes-version: "1.26-1.27"
    policies.kyverno.io/description: >-
      Clusters not initially installed with Kubernetes 1.22 may be vulnerable to an issue
      defined in CVE-2021-25740 which could enable users to send network traffic to locations
      they would otherwise not have access to via a confused deputy attack. This was due to
      the system:aggregate-to-edit ClusterRole having edit permission of Endpoints.
      This policy, intended to run in background mode, checks if your cluster is vulnerable
      to CVE-2021-25740 by ensuring the system:aggregate-to-edit ClusterRole does not have
      the edit permission of Endpoints.
spec:
  validationFailureAction: Audit
  background: true
  rules:
    - name: system-aggregate-to-edit-check
      match:
        any:
        - resources:
            kinds:
            - ClusterRole
            names:
            - system:aggregate-to-edit
      validate:
        cel:
          expressions:
            - expression: "!object.rules.exists(rule, 'endpoints' in rule.resources && 'edit' in rule.verbs)"
              message: >-
                This cluster may still be vulnerable to CVE-2021-25740. The system:aggregate-to-edit ClusterRole
                should not have edit permission over Endpoints.


```
