---
title: "Check ServiceAccount"
category: Sample
version: 
subject: Pod,ServiceAccount
policyType: "validate"
description: >
    ServiceAccounts with privileges to create Pods may be able to do so and name a ServiceAccount other than the one used to create it. This policy checks the Pod, if created by a ServiceAccount, and ensures the `serviceAccountName` field matches the actual ServiceAccount.
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/release-1.6//other/check_serviceaccount/check_serviceaccount.yaml" target="-blank">/other/check_serviceaccount/check_serviceaccount.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: check-sa
  annotations:
    policies.kyverno.io/title: Check ServiceAccount
    policies.kyverno.io/category: Sample
    policies.kyverno.io/subject: Pod,ServiceAccount
    kyverno.io/kyverno-version: 1.5.2
    kyverno.io/kubernetes-version: "1.21"
    policies.kyverno.io/description: >-
      ServiceAccounts with privileges to create Pods may be able to do so and name
      a ServiceAccount other than the one used to create it. This policy checks the
      Pod, if created by a ServiceAccount, and ensures the `serviceAccountName` field
      matches the actual ServiceAccount.
spec:
  validationFailureAction: audit
  background: false
  rules:
    - name: check-sa
      match:
        resources:
          kinds:
          - Pod
      preconditions:
        all:
        - key: "{{serviceAccountName}}"
          operator: Equals
          value: "*?"
      validate:
        message: "The ServiceAccount used to create this Pod is confined to using the same account when running the Pod."
        pattern:
          spec:
            serviceAccountName: "{{serviceAccountName}}"

```
