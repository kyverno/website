---
title: "Require CPU Limits"
category: Other
version: 
subject: Pod
policyType: "validate"
description: >
    Setting CPU limits on containers ensures fair distribution of resources, preventing any single container from monopolizing CPU and impacting the performance of other containers. This practice enhances stability, predictability, and cost control, while also mitigating the noisy neighbor problem and facilitating efficient scaling in Kubernetes clusters. This policy ensures that cpu limits are set on every container.
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//other/require-cpu-limits/require-cpu-limits.yaml" target="-blank">/other/require-cpu-limits/require-cpu-limits.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: require-cpu-limits
  annotations:
    policies.kyverno.io/title: Require CPU Limits
    policies.kyverno.io/category: Other
    policies.kyverno.io/severity: medium
    policies.kyverno.io/subject: Pod
    kyverno.io/kubernetes-version: "1.26"
    policies.kyverno.io/description: >-
      Setting CPU limits on containers ensures fair distribution of resources, preventing any single container from monopolizing CPU and impacting the performance of other containers. This practice enhances stability, predictability, and cost control, while also mitigating the noisy neighbor problem and facilitating efficient scaling in Kubernetes clusters. This policy ensures that cpu limits are set on every container.
spec:
  validationFailureAction: Audit
  background: true
  rules:
  - name: check-cpu-limits
    match:
      any:
      - resources:
          kinds:
          - Pod
    validate:
      message: "CPU limits are required for all containers."
      pattern:
        spec:
          containers:
          - (name): "*"
            resources:
              limits:
                cpu: "?*"
          =(ephemeralContainers):
          - =(name): "*"
            resources:
              limits:
                cpu: "?*"
          =(initContainers):
          - =(name): "*"
            resources:
              limits:
                cpu: "?*"

```
