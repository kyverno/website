---
title: "Add Image as Environment Variable"
category: Other
version: 1.4.3
subject: Pod
policyType: "mutate"
description: >
    The Kubernetes downward API only has the ability to express so many options as environment variables. The image consumed in a Pod is commonly needed to make the application aware of some logic it must take. This policy takes the value of the `image` field and adds it as an environment variable to bare Pods and Deployments having no more than two containers. The `env` array must already exist for the policy to operate correctly. This policy may be easily extended to support other higher-level Pod controllers as well as more containers by following the established rules.
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//other/add-image-as-env-var/add-image-as-env-var.yaml" target="-blank">/other/add-image-as-env-var/add-image-as-env-var.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: add-image-as-env-var
  # env array needs to exist (least one env var is present)
  annotations:
    pod-policies.kyverno.io/autogen-controllers: None
    policies.kyverno.io/title: Add Image as Environment Variable
    policies.kyverno.io/category: Other
    policies.kyverno.io/severity: medium
    policies.kyverno.io/minversion: 1.4.3
    kyverno.io/kyverno-version: 1.6.2
    kyverno.io/kubernetes-version: "1.23"
    policies.kyverno.io/subject: Pod
    policies.kyverno.io/description: >-
      The Kubernetes downward API only has the ability to express so many
      options as environment variables. The image consumed in a Pod is commonly
      needed to make the application aware of some logic it must take. This policy
      takes the value of the `image` field and adds it as an environment variable
      to bare Pods and Deployments having no more than two containers. The `env` array must already exist for the policy
      to operate correctly. This policy may be easily extended to support other higher-level
      Pod controllers as well as more containers by following the established rules.
spec:
  background: false
  schemaValidation: false
  rules:
  # One Pod
  - name: pod-containers-1-inject-image
    match:
      resources:
        kinds:
        - Pod
    preconditions:
      all:
      - key: "{{request.object.spec.containers[] | length(@)}}"
        operator: GreaterThanOrEquals
        value: 1
    mutate:
      patchesJson6902: |-
        - op: add
          path: "/spec/containers/0/env/-"
          value: {"name":"K8S_IMAGE","value":"{{request.object.spec.containers[0].image}}"}
  # Two or more Pods
  - name: pod-containers-2-inject-image
    match:
      resources:
        kinds:
        - Pod
    preconditions:
      all:
      - key: "{{request.object.spec.containers[] | length(@)}}"
        operator: GreaterThanOrEquals
        value: 2
    mutate:
      patchesJson6902: |-
        - op: add
          path: "/spec/containers/1/env/-"
          value: {"name":"K8S_IMAGE","value":"{{request.object.spec.containers[1].image}}"}
  # Deployment with one Pod
  - name: deploy-containers-1-inject-image
    match:
      resources:
        kinds:
        - Deployment
    preconditions:
      all:
      - key: "{{request.object.spec.template.spec.containers[] | length(@)}}"
        operator: GreaterThanOrEquals
        value: 1
    mutate:
      patchesJson6902: |-
        - op: add
          path: "/spec/template/spec/containers/0/env/-"
          value: {"name":"K8S_IMAGE","value":"{{request.object.spec.template.spec.containers[0].image}}"}
  # Deployment with two or more Pods
  - name: deploy-containers-2-inject-image
    match:
      resources:
        kinds:
        - Deployment
    preconditions:
      all:
      - key: "{{request.object.spec.template.spec.containers[] | length(@)}}"
        operator: GreaterThanOrEquals
        value: 2
    mutate:
      patchesJson6902: |-
        - op: add
          path: "/spec/template/spec/containers/1/env/-"
          value: {"name":"K8S_IMAGE","value":"{{request.object.spec.template.spec.containers[1].image}}"}

```
