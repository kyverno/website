---
title: "Exclude Namespaces Dynamically in CEL expressions"
category: Sample in CEL
version: 1.11.0
subject: Namespace, Pod
policyType: "validate"
description: >
    It's common where policy lookups need to consider a mapping to many possible values rather than a static mapping. This is a sample which demonstrates how to dynamically look up an allow list of Namespaces from a ConfigMap where the ConfigMap stores an array of strings. This policy validates that any Pods created outside of the list of Namespaces have the label `foo` applied.
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//other-cel/exclude-namespaces-dynamically/exclude-namespaces-dynamically.yaml" target="-blank">/other-cel/exclude-namespaces-dynamically/exclude-namespaces-dynamically.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: exclude-namespaces-example
  annotations:
    policies.kyverno.io/title: Exclude Namespaces Dynamically in CEL expressions
    policies.kyverno.io/category: Sample in CEL 
    policies.kyverno.io/severity: medium
    policies.kyverno.io/subject: Namespace, Pod
    policies.kyverno.io/minversion: 1.11.0
    pod-policies.kyverno.io/autogen-controllers: none
    kyverno.io/kyverno-version: 1.11.0
    kyverno.io/kubernetes-version: "1.26-1.27"
    policies.kyverno.io/description: >-
      It's common where policy lookups need to consider a mapping to many possible values rather than a
      static mapping. This is a sample which demonstrates how to dynamically look up an allow list of Namespaces from a ConfigMap
      where the ConfigMap stores an array of strings. This policy validates that any Pods created
      outside of the list of Namespaces have the label `foo` applied.
spec:
  validationFailureAction: Audit
  background: true
  rules:
  - name: exclude-namespaces-dynamically
    match:
      any:
      - resources:
          kinds:
          - Deployment
          - DaemonSet
          - StatefulSet
          - Job
          operations:
          - CREATE
          - UPDATE
    celPreconditions:
      - name: "filter-namespaces"
        expression: "!(request.namespace in params.data['exclude'].split(', '))"
    validate:
      cel:
        paramKind:
          apiVersion: v1
          kind: ConfigMap
        paramRef:
          name: namespace-filters
          namespace: default
          parameterNotFoundAction: Deny
        expressions:
          - expression: "has(object.spec.template.metadata) && has(object.spec.template.metadata.labels) && 'foo' in object.spec.template.metadata.labels"
            messageExpression: >
              'Creating Pods in the ' + request.namespace + ' namespace,' +
              ' which is not in the excluded list of namespaces' + params.data.exclude + ',' +
              ' is forbidden unless it carries the label `foo`.'
  - name: exclude-namespaces-dynamically-pods
    match:
      any:
      - resources:
          kinds:
          - Pod
          operations:
          - CREATE
          - UPDATE
    celPreconditions:
      - name: "filter-namespaces"
        expression: "!(request.namespace in params.data['exclude'].split(', '))"
    validate:
      cel:
        paramKind:
          apiVersion: v1
          kind: ConfigMap
        paramRef:
          name: namespace-filters
          namespace: default
          parameterNotFoundAction: Deny
        expressions:
          - expression: "has(object.metadata.labels) && 'foo' in object.metadata.labels"
            messageExpression: >
              'Creating Pods in the ' + request.namespace + ' namespace,' +
              ' which is not in the excluded list of namespaces ' + params.data.exclude + ',' +
              ' is forbidden unless it carries the label `foo`.'
  - name: exclude-namespaces-dynamically-cronjobs
    match:
      any:
      - resources:
          kinds:
          - CronJob
          operations:
          - CREATE
          - UPDATE
    celPreconditions:
      - name: "filter-namespaces"
        expression: "!(request.namespace in params.data['exclude'].split(', '))"
    validate:
      cel:
        paramKind:
          apiVersion: v1
          kind: ConfigMap
        paramRef:
          name: namespace-filters
          namespace: default
          parameterNotFoundAction: Deny
        expressions:
          - expression: >-
              has(object.spec.jobTemplate.spec.template.metadata) &&
              has(object.spec.jobTemplate.spec.template.metadata.labels) && 'foo' in object.spec.jobTemplate.spec.template.metadata.labels
            messageExpression: >
              'Creating Pods in the ' + request.namespace + ' namespace,' +
              ' which is not in the excluded list of namespaces ' + params.data.exclude + ',' +
              ' is forbidden unless it carries the label `foo`.'


```
