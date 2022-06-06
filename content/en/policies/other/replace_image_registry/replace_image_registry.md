---
title: "Replace Image Registry"
category: Sample
version: 1.5.4
subject: Pod
policyType: "mutate"
description: >
    Rather than blocking Pods which come from outside registries, it is also possible to mutate them so the pulls are directed to approved registries. In some cases, those registries may function as pull-through proxies and can fetch the image if not cached. This policy policy mutates all images either in the form 'image:tag' or 'registry.corp.com/image:tag' to be  `myregistry.corp.com/`. Any path in the image name will be preserved.
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//other/replace_image_registry/replace_image_registry.yaml" target="-blank">/other/replace_image_registry/replace_image_registry.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: replace-image-registry
  annotations:
    pod-policies.kyverno.io/autogen-controllers: none
    policies.kyverno.io/title: Replace Image Registry
    policies.kyverno.io/category: Sample
    policies.kyverno.io/severity: medium
    policies.kyverno.io/subject: Pod
    policies.kyverno.io/minversion: 1.5.4
    policies.kyverno.io/description: >-
      Rather than blocking Pods which come from outside registries,
      it is also possible to mutate them so the pulls are directed to
      approved registries. In some cases, those registries may function as
      pull-through proxies and can fetch the image if not cached.
      This policy policy mutates all images either
      in the form 'image:tag' or 'registry.corp.com/image:tag' to be 
      `myregistry.corp.com/`. Any path in the image name will be preserved.
spec:
  background: false
  rules:
    - name: replace-image-registry-pod-containers
      match:
        resources:
          kinds:
          - Pod
      mutate:
        foreach:
        - list: "request.object.spec.containers"
          patchStrategicMerge:
            spec:
              containers:
              - name: "{{ element.name }}"
                image: |-    
                        {{ regex_replace_all('^[^/]+', '{{element.image}}', 'myregistry.corp.com' )}}
    - name: replace-image-registry-pod-initcontainers
      match:
        resources:
          kinds:
          - Pod
      preconditions:
        all:
        - key: "{{ request.object.spec.initContainers[] || '' | length(@) }}"
          operator: GreaterThanOrEquals
          value: 1
      mutate:
        foreach:
        - list: "request.object.spec.initContainers"
          patchStrategicMerge:
            spec:
              initContainers:
              - name: "{{ element.name }}"
                image: |-    
                        {{ regex_replace_all('^[^/]+', '{{element.image}}', 'myregistry.corp.com' )}}
    - name: replace-image-registry-depl-containers
      match:
        resources:
          kinds:
          - Deployment
      mutate:
        foreach:
        - list: "request.object.spec.template.spec.containers"
          patchStrategicMerge:
            spec:
              template:
                spec:
                  containers:
                  - name: "{{ element.name }}"
                    image: |-    
                            {{ regex_replace_all('^[^/]+', '{{element.image}}', 'myregistry.corp.com' )}}
    - name: replace-image-registry-depl-initcontainers
      match:
        resources:
          kinds:
          - Deployment
      preconditions:
        all:
        - key: "{{ request.object.spec.template.spec.initContainers[] || '' | length(@) }}"
          operator: GreaterThanOrEquals
          value: 1
      mutate:
        foreach:
        - list: "request.object.spec.template.spec.initContainers"
          patchStrategicMerge:
            spec:
              template:
                spec:
                  initContainers:
                  - name: "{{ element.name }}"
                    image: |-    
                            {{ regex_replace_all('^[^/]+', '{{element.image}}', 'myregistry.corp.com' )}}

```
