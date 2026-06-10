---
title: AI & Agent Governance
excerpt: Use Kyverno policies to govern, secure, and control AI workloads and autonomous agents in Kubernetes.
sidebar:
  order: 16
---

# AI & Agent Governance

AI workloads in Kubernetes often include model-serving platforms, GPU workloads, and autonomous agents. As organizations adopt LLM applications and agent-driven workflows, platform teams need policy controls to ensure these workloads are deployed securely, consistently, and according to organizational standards.

Kyverno helps enforce AI governance using Kubernetes-native policy as code. Policies can validate workload security, restrict untrusted images, govern GPU usage, apply namespace isolation, and generate audit reports for visibility and compliance.

## Problem Space

AI systems and autonomous agents can deploy workloads, scale infrastructure, and modify Kubernetes resources automatically. Without governance controls, these workflows can introduce security risks, resource misuse, and configuration drift.

Common risks include:

| Risk                        | Example                                               |
| --------------------------- | ----------------------------------------------------- |
| Unsafe configurations       | Privileged containers with host access                |
| Uncontrolled resource usage | GPU workloads running without resource limits         |
| Registry sprawl             | Model-serving images pulled from public registries    |
| Isolation failures          | Agents running in shared namespaces with broad access |
| Untracked drift             | Pipelines applying changes without ownership metadata |

Kyverno helps enforce Kubernetes-native policies to validate, govern, and secure AI-driven operations while improving visibility and compliance through policy reporting.

## Desired Outcome

When Kyverno is used for AI and agent governance, platform teams can achieve the following outcomes:

| Outcome                 | What it means                                          |
| ----------------------- | ------------------------------------------------------ |
| Trusted AI workloads    | Only approved images and registries are allowed        |
| Safer runtime security  | Privileged containers and unsafe access are restricted |
| Controlled GPU usage    | AI workloads must define GPU resource limits           |
| Namespace isolation     | AI systems run only in approved namespaces             |
| Verified model images   | Signed images and immutable digests can be validated   |
| Audit-first enforcement | Policies can begin in `Audit` mode before enforcement  |

## Kyverno Capabilities

Kyverno provides Kubernetes-native policy controls to validate, mutate, generate, and verify AI workloads during admission.

## Validation Policies

Validation policies enforce workload security, resource limits, namespace restrictions, and governance metadata during admission. They ensure that container specifications and AI-generated manifests conform to security guidelines. Non-compliant resources are blocked or logged as violations depending on the policy configuration.

### Example policy

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: block-privileged-ai-agents
spec:
  rules:
    - name: disallow-privileged-agent-containers
      match:
        any:
          - resources:
              kinds:
                - Pod
      validate:
        failureAction: Enforce
        message: 'AI agent containers must not run as privileged containers.'
        pattern:
          spec:
            containers:
              - =(securityContext):
                  =(privileged): 'false'
```

## Mutation Policies

Mutation policies automatically apply secure defaults and standardize workload configuration. Platforms can use mutation to inject standard labels, apply default security settings, or set resource limits on GPU workloads. This standardizes configuration across teams without requiring manual updates to deployment templates.

### Example policy

```yaml id="k9d2hf"
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: default-ai-security-context
spec:
  rules:
    - name: add-container-security-defaults
      match:
        any:
          - resources:
              kinds:
                - Pod
      mutate:
        foreach:
          - list: 'request.object.spec.containers'
            patchStrategicMerge:
              spec:
                containers:
                  - name: '{{ element.name }}'
                    securityContext:
                      +(allowPrivilegeEscalation): false
                      +(runAsNonRoot): true
```

## Generate Policies

Generate policies automatically create supporting Kubernetes resources when new workloads or namespaces are created. This helps platform teams provide secure baseline configurations for AI environments.The following policy generates a default `NetworkPolicy` for AI namespaces.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: generate-ai-default-networkpolicy
spec:
  rules:
    - name: generate-default-deny-egress
      match:
        any:
          - resources:
              kinds:
                - Namespace
              selector:
                matchLabels:
                  workload-type: ai
      generate:
        synchronize: true
        apiVersion: networking.k8s.io/v1
        kind: NetworkPolicy
        name: default-deny-egress
        namespace: '{{ request.object.metadata.name }}'
        data:
          spec:
            podSelector: {}
            policyTypes:
              - Egress
```

## Verify Images

Image verification ensures that workloads only run container images and AI models from trusted sources. Kyverno integrates with Cosign and Notary to verify cryptographic signatures and build attestations at admission time. This prevents unsigned, untrusted, or modified artifacts from running in production environments.
The following policy verifies signed AI workload images from an approved registry.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: verify-ai-model-images
  annotations:
    policies.kyverno.io/title: Verify AI Model Images
    policies.kyverno.io/category: AI Governance
    policies.kyverno.io/severity: high
spec:
  webhookTimeoutSeconds: 30
  rules:
    - name: verify-signed-ai-images
      match:
        any:
          - resources:
              kinds:
                - Pod
              selector:
                matchLabels:
                  workload.platform.example.com/type: ai
      verifyImages:
        - imageReferences:
            - 'registry.corp.example.com/ai/*'
          mutateDigest: true
          verifyDigest: true
          required: true
          attestors:
            - count: 1
              entries:
                - keys:
                    secret:
                      name: cosign-ai-public-key
                      namespace: kyverno
```

## Policy Reports / Audit Mode

Policy reports provide visibility into governance and compliance results across the cluster. Platform teams can use `Audit` mode to review policy impact before enforcing controls.

The following policy audits AI workloads that do not define GPU resource requests and limits.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: audit-gpu-resource-standards
spec:
  background: true
  rules:
    - name: require-gpu-request-and-limit
      match:
        any:
          - resources:
              kinds:
                - Pod
              selector:
                matchLabels:
                  workload.platform.example.com/type: ai
      validate:
        failureAction: Audit
        message: 'GPU AI workloads should set both requests and limits for nvidia.com/gpu.'
        pattern:
          spec:
            containers:
              - resources:
                  requests:
                    nvidia.com/gpu: '?*'
                  limits:
                    nvidia.com/gpu: '?*'
```

View report results using:

```sh id="pdm03c"
kubectl get policyreports -A
kubectl get clusterpolicyreports
kubectl describe policyreport -n ai-platform
```

For more information, see [Policy Reports](https://kyverno.io/docs/guides/reports/).

## Real-World AI Governance Use Cases

| Use case              | Kyverno outcome                                  |
| --------------------- | ------------------------------------------------ |
| Trusted AI images     | Allow only approved registries and signed images |
| Safer AI runtimes     | Block privileged containers and unsafe access    |
| Controlled GPU usage  | Enforce GPU resource limits                      |
| Namespace isolation   | Restrict AI workloads to dedicated namespaces    |
| Governance visibility | Require ownership and environment labels         |
| Secure defaults       | Generate baseline `NetworkPolicy` resources      |

## Outcome Mapping

| User goal                       | Kyverno capability               | Example outcome             |
| ------------------------------- | -------------------------------- | --------------------------- |
| Restrict unsafe AI workloads    | Validation policies              | Block privileged containers |
| Enforce trusted AI images       | Verify Images                    | Allow only signed images    |
| Control GPU usage               | Validation policies              | Require GPU resource limits |
| Isolate AI systems              | Validation and Generate policies | Dedicated AI namespaces     |
| Standardize governance metadata | Mutation policies                | Default ownership labels    |
| Roll out policies safely        | Policy Reports and Audit mode    | Audit before enforcement    |

## Implementation Path

1. Discover AI workloads and governance requirements
2. Start with policies in `Audit` mode
3. Enforce namespace and security standards
4. Add image verification and registry controls
5. Expand governance across teams and clusters

## Related Documentation

- [Validation](https://kyverno.io/docs/policy-types/validating-policy)
- [Mutation](https://kyverno.io/docs/policy-types/mutating-policy)
- [Generate](https://kyverno.io/docs/policy-types/generating-policy)
- [Verify Images](https://kyverno.io/docs/policy-types/image-validating-policy)
- [Policy Reports](https://kyverno.io/docs/guides/reports)
- [Admission Controllers](https://kyverno.io/docs/guides/admission-controllers)
