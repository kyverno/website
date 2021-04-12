---
type: "docs"
title: Inject Sidecar
linkTitle: Inject Sidecar
weight: 22
description: >
    Sample policy that injects a sidecar container into Pods that match an annotation.  
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//other/inject_sidecar_deployment.yaml" target="-blank">/other/inject_sidecar_deployment.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: inject-sidecar
  annotations:
    policies.kyverno.io/title: Inject Sidecar Container
    policies.kyverno.io/category: Sample
    policies.kyverno.io/description: >-
      Sample policy that injects a sidecar container into Pods that match an annotation.  
spec:
  background: false
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
