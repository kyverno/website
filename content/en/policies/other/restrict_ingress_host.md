---
title: "Unique Ingress Host"
linkTitle: "Unique Ingress Host"
weight: 25
repo: "https://github.com/kyverno/policies/blob/main/other/restrict_ingress_host.yaml"
description: >
    
category: 
rules:
    - name: check-host
      match:
        resources:
          kinds:
            - Ingress
      context:
        - name: hosts
          apiCall:
            urlPath: "/apis/networking.k8s.io/v1beta1/ingresses"
            jmesPath: "items[].spec.rules[].host"
      preconditions:
        - key: "{{ request.operation }}"
          operator: Equals
          value: "CREATE"
      validate:
        message: "the Ingress host name must be unique"
        deny:
          conditions:
            - key: "{{ request.object.spec.rules[].host }}"
              operator: In
              value: "{{ hosts }}"

---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//other/restrict_ingress_host.yaml" target="-blank">/other/restrict_ingress_host.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: unique-ingress-host
  annotations:
    policies.kyverno.io/title: Unique Ingress Host
    policies.kyverno.io/category: Sample
    policies.kyverno.io/description: >-
      Checks an incoming Ingress resource to ensure its hosts are unique to the cluster.
spec:
  validationFailureAction: enforce
  background: false
  rules:
    - name: check-host
      match:
        resources:
          kinds:
            - Ingress
      context:
        - name: hosts
          apiCall:
            urlPath: "/apis/networking.k8s.io/v1beta1/ingresses"
            jmesPath: "items[].spec.rules[].host"
      preconditions:
        - key: "{{ request.operation }}"
          operator: Equals
          value: "CREATE"
      validate:
        message: "The Ingress host name must be unique."
        deny:
          conditions:
            - key: "{{ request.object.spec.rules[].host }}"
              operator: In
              value: "{{ hosts }}"

```
