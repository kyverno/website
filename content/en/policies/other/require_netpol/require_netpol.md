---
title: "Require NetworkPolicy"
category: Sample
version: 1.3.6
subject: Deployment, NetworkPolicy
policyType: "validate"
description: >
    NetworkPolicy is used to control Pod-to-Pod communication and is a good practice to ensure only authorized Pods can send/receive traffic. This policy checks incoming Deployments to ensure they have a matching, preexisting NetworkPolicy.
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//other/require_netpol/require_netpol.yaml" target="-blank">/other/require_netpol/require_netpol.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: require-network-policy
  annotations:
    policies.kyverno.io/title: Require NetworkPolicy
    policies.kyverno.io/category: Sample
    policies.kyverno.io/minversion: 1.3.6
    kyverno.io/kyverno-version: 1.6.2
    kyverno.io/kubernetes-version: "1.23"
    policies.kyverno.io/subject: Deployment, NetworkPolicy
    policies.kyverno.io/description: >-
      NetworkPolicy is used to control Pod-to-Pod communication
      and is a good practice to ensure only authorized Pods can send/receive
      traffic. This policy checks incoming Deployments to ensure
      they have a matching, preexisting NetworkPolicy.
spec:
  validationFailureAction: audit
  background: false
  rules:
  - name: require-network-policy
    match:
      resources:
        kinds:
        - Deployment
    preconditions:
      any:
      - key: "{{request.operation}}"
        operator: Equals
        value: CREATE
    context:
    - name: policies_count
      apiCall:
        urlPath: "/apis/networking.k8s.io/v1/namespaces/{{request.namespace}}/networkpolicies"
        jmesPath: "items[?label_match(spec.podSelector.matchLabels, `{{request.object.spec.template.metadata.labels}}`)] | length(@)"
    validate:
      message: "Every Deployment requires a matching NetworkPolicy."
      deny:
        conditions:
          any:
          - key: "{{policies_count}}"
            operator: LessThan
            value: 1
```
