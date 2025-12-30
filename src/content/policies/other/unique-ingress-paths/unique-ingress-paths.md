---
title: 'Unique Ingress Path'
category: validate
severity: medium
type: ClusterPolicy
subjects:
  - Ingress
tags: []
version: 1.6.0
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/other/unique-ingress-paths/unique-ingress-paths.yaml" target="-blank">/other/unique-ingress-paths/unique-ingress-paths.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: unique-ingress-path
  annotations:
    policies.kyverno.io/title: Unique Ingress Path
    policies.kyverno.io/category: Sample
    policies.kyverno.io/severity: medium
    policies.kyverno.io/subject: Ingress
    policies.kyverno.io/minversion: 1.6.0
    policies.kyverno.io/description: Just like the need to ensure uniqueness among Ingress hosts, there is a need to have the paths be unique as well. This policy checks an incoming Ingress to ensure its root path does not conflict with another root path in a different Namespace. It requires that incoming Ingress resources have a single rule with a single path only and assumes the root path is specified explicitly in an existing Ingress rule (ex., when blocking /foo/bar /foo must exist by itself and not part of /foo/baz).
spec:
  validationFailureAction: Audit
  background: false
  rules:
    - name: check-path
      match:
        any:
          - resources:
              kinds:
                - Ingress
      context:
        - name: allpaths
          apiCall:
            urlPath: /apis/networking.k8s.io/v1/ingresses
            jmesPath: items[].spec.rules[].http.paths[].path
        - name: nspath
          apiCall:
            urlPath: /apis/networking.k8s.io/v1/namespaces/{{request.object.metadata.namespace}}/ingresses
            jmesPath: items[].spec.rules[].http.paths[].path
      preconditions:
        any:
          - key: "{{request.operation || 'BACKGROUND'}}"
            operator: AnyIn
            value:
              - CREATE
              - UPDATE
      validate:
        message: The root path /{{request.object.spec.rules[].http.paths[].path | [0] | to_string(@) | split(@, '/') | [1]}} exists in another Ingress rule elsewhere in the cluster.
        deny:
          conditions:
            all:
              - key: /{{request.object.spec.rules[].http.paths[].path | [0] | to_string(@) | split(@, '/') | [1]}}
                operator: AnyIn
                value: '{{allpaths}}'
              - key: /{{request.object.spec.rules[].http.paths[].path | [0] | to_string(@) | split(@, '/') | [1]}}
                operator: AnyNotIn
                value: '{{nspath}}'
```
