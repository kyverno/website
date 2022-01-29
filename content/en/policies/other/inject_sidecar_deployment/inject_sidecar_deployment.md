---
title: "Inject Sidecar Container"
category: Sample
version: 
subject: Pod,Volume
policyType: "mutate"
description: >
    The sidecar pattern is very common in Kubernetes whereby other applications can insert components via tacit modification of a submitted resource. This is, for example, often how service meshes and secrets applications are able to function transparently. This policy injects a sidecar container, initContainer, and volume into Pods that match an annotation called `vault.hashicorp.com/agent-inject: true`.
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//other/inject_sidecar_deployment/inject_sidecar_deployment.yaml" target="-blank">/other/inject_sidecar_deployment/inject_sidecar_deployment.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: inject-sidecar
  annotations:
    policies.kyverno.io/title: Inject Sidecar Container
    policies.kyverno.io/category: Sample
    policies.kyverno.io/subject: Pod,Volume
    policies.kyverno.io/description: >-
      The sidecar pattern is very common in Kubernetes whereby other applications can
      insert components via tacit modification of a submitted resource. This is, for example,
      often how service meshes and secrets applications are able to function transparently.
      This policy injects a sidecar container, initContainer, and volume into Pods that match
      an annotation called `vault.hashicorp.com/agent-inject: true`.
spec:
  rules:
  - name: inject-sidecar
    match:
      resources:
        kinds:
        - Deployment
    mutate:
      patchStrategicMerge:
        spec:
          template:
            metadata:
              annotations:
                (vault.hashicorp.com/agent-inject): "true"
            spec:
              containers:
              - name: vault-agent
                image: vault:1.5.4
                imagePullPolicy: IfNotPresent
                volumeMounts:
                - mountPath: /vault/secrets
                  name: vault-secret
              initContainers:
              - name: vault-agent-init
                image: vault:1.5.4
                imagePullPolicy: IfNotPresent
                volumeMounts:
                - mountPath: /vault/secrets
                  name: vault-secret
              volumes:
              - name: vault-secret
                emptyDir:
                  medium: Memory

```
