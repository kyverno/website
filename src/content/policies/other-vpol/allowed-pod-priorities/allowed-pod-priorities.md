---
title: 'Allowed Pod Priorities in cel expressions'
category: validate
severity: medium
type: ValidatingPolicy
subjects:
  - Pod
tags:
  - Sample in vpol
version: 1.14.0
description: 'A Pod PriorityClass is used to provide a guarantee on the scheduling of a Pod relative to others. In certain cases where not all users in a cluster are trusted, a malicious user could create Pods at the highest possible priorities, causing other Pods to be evicted/not get scheduled. This policy checks the defined `priorityClassName` in a Pod spec to a dictionary of allowable PriorityClasses for the given Namespace stored in a ConfigMap. If the `priorityClassName` is not among them, the Pod is blocked.'
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/other-vpol/allowed-pod-priorities/allowed-pod-priorities.yaml" target="-blank">/other-vpol/allowed-pod-priorities/allowed-pod-priorities.yaml</a>

```yaml
apiVersion: policies.kyverno.io/v1
kind: ValidatingPolicy
metadata:
  name: allowed-podpriorities
  annotations:
    policies.kyverno.io/title: Allowed Pod Priorities in cel expressions
    policies.kyverno.io/category: Sample in vpol
    policies.kyverno.io/minversion: 1.14.0
    kyverno.io/kubernetes-version: "1.30"
    policies.kyverno.io/subject: Pod
    policies.kyverno.io/description: A Pod PriorityClass is used to provide a guarantee on the scheduling of a Pod relative to others. In certain cases where not all users in a cluster are trusted, a malicious user could create Pods at the highest possible priorities, causing other Pods to be evicted/not get scheduled. This policy checks the defined `priorityClassName` in a Pod spec to a dictionary of allowable PriorityClasses for the given Namespace stored in a ConfigMap. If the `priorityClassName` is not among them, the Pod is blocked.
spec:
  validationActions:
    - Audit
  evaluation:
    background:
      enabled: true
  matchConstraints:
    resourceRules:
      - apiGroups:
          - ""
        apiVersions:
          - v1
        operations:
          - CREATE
          - UPDATE
        resources:
          - pods
  variables:
    - name: prior
      expression: resource.Get("v1", "configmaps", "default", "allowed-pod-priorities")
    - name: namespaceName
      expression: namespaceObject.metadata.name
    - name: priorities
      expression: "variables.namespaceName in variables.prior.data ? variables.prior.data[variables.namespaceName].split(', ') : []"
  validations:
    - expression: variables.priorities == [] || object.spec.priorityClassName in variables.priorities
      message: "'The Pod PriorityClass ' + object.spec.priorityClassName + ' is not in the list of the following PriorityClasses allowed in this Namespace: ' + variables.prior.data[variables.namespaceName]"

```
