---
title: "Add PSA Labels"
category: Pod Security Admission, EKS Best Practices
version: 1.6.0
subject: Namespace
policyType: "mutate"
description: >
    Pod Security Admission (PSA) can be controlled via the assignment of labels at the Namespace level which define the Pod Security Standard (PSS) profile in use and the action to take. If not using a cluster-wide configuration via an AdmissionConfiguration file, Namespaces must be explicitly labeled. This policy assigns the labels `pod-security.kubernetes.io/enforce=baseline` and `pod-security.kubernetes.io/warn=restricted` to all new Namespaces if those labels are not included.
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//psa/add-psa-labels/add-psa-labels.yaml" target="-blank">/psa/add-psa-labels/add-psa-labels.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: add-psa-labels
  annotations:
    policies.kyverno.io/title: Add PSA Labels
    policies.kyverno.io/category: Pod Security Admission, EKS Best Practices
    policies.kyverno.io/severity: medium
    kyverno.io/kyverno-version: 1.7.1
    policies.kyverno.io/minversion: 1.6.0
    kyverno.io/kubernetes-version: "1.24"
    policies.kyverno.io/subject: Namespace
    policies.kyverno.io/description: >-
      Pod Security Admission (PSA) can be controlled via the assignment of labels
      at the Namespace level which define the Pod Security Standard (PSS) profile
      in use and the action to take. If not using a cluster-wide configuration
      via an AdmissionConfiguration file, Namespaces must be explicitly labeled.
      This policy assigns the labels `pod-security.kubernetes.io/enforce=baseline`
      and `pod-security.kubernetes.io/warn=restricted` to all new Namespaces if
      those labels are not included.
spec:
  rules:
  - name: add-baseline-enforce-restricted-warn
    match:
      any:
      - resources:
          kinds:
          - Namespace
    mutate:
      patchStrategicMerge:
        metadata:
          labels:
            +(pod-security.kubernetes.io/enforce): baseline
            +(pod-security.kubernetes.io/warn): restricted

```
