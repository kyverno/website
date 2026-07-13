---
title: Secure-by-Default Kubernetes
excerpt: Use Kyverno policies to enforce security and compliance standards across Kubernetes environments.
sidebar:
  order: 10
---

Kubernetes gives teams a powerful platform for building and running applications, but secure behavior is not always the default. Platform teams need a way to make safe configurations consistent across clusters, namespaces, and workloads.

Kyverno helps teams define security standards as Kubernetes policies. Policies can validate unsafe resources, apply secure defaults, generate baseline resources, verify trusted images, and report compliance results across the cluster.

## Problem Space

Kubernetes security issues often come from small configuration choices repeated across many workloads. Without consistent guardrails, these configurations can create security risks, operational instability, and compliance challenges across clusters.

| Challenge                  | Risk                                                    |
| -------------------------- | ------------------------------------------------------- |
| Privileged containers      | Containers may gain excessive access to the host.       |
| Missing resource limits    | Workloads can consume excessive CPU or memory.          |
| Untrusted container images | Images may come from unknown or unverified sources.     |
| HostPath usage             | Pods may access sensitive host files or directories.    |
| Running as root            | Containers may run with unnecessary privileges.         |
| Missing security contexts  | Runtime security controls are not applied consistently. |
| Configuration drift        | Security standards vary across teams and environments.  |

Kyverno helps platform teams enforce security standards through Kubernetes-native policies, ensuring workloads meet organizational requirements before they are admitted into the cluster.

## Desired Outcome

When Kyverno is used to implement secure-by-default Kubernetes practices, platform teams can achieve the following outcomes:

| Outcome               | What it means                                          |
| --------------------- | ------------------------------------------------------ |
| Secure workloads      | Unsafe configurations are blocked.                     |
| Trusted deployments   | Only approved and verified images are allowed.         |
| Consistent standards  | Security controls are applied automatically.           |
| Reduced drift         | Policies continuously enforce requirements.            |
| Compliance visibility | Policy violations are reported and tracked.            |
| Audit-first rollout   | Policies can start in `Audit` mode before enforcement. |

## Kyverno Capabilities

Kyverno policies describe the desired security outcome for Kubernetes resources. Platform teams can start by observing violations, then move critical controls to enforcement when the impact is understood.

### Validation Policies

Validation policies check incoming resources against security requirements before they are admitted into the cluster. They help platform teams enforce workload security standards, resource requirements, and runtime restrictions.

Relevant documentation:

- [Validate Rules](https://kyverno.io/docs/policy-types/cluster-policy/validate/)
- [ValidatingPolicy](https://kyverno.io/docs/policy-types/validating-policy/)

This `ClusterPolicy` blocks Pods that request privileged containers.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: disallow-privileged-containers
spec:
  rules:
    - name: privileged-containers
      match:
        any:
          - resources:
              kinds:
                - Pod
      validate:
        failureAction: Enforce
        message: Privileged containers are not allowed.
        pattern:
          spec:
            =(ephemeralContainers):
              - =(securityContext):
                  =(privileged): 'false'
            =(initContainers):
              - =(securityContext):
                  =(privileged): 'false'
            containers:
              - =(securityContext):
                  =(privileged): 'false'
```

### Mutation Policies

Mutation policies apply secure defaults when recommended settings are missing. This helps platform teams standardize workload configurations and improve security without requiring developers to update every deployment manifest manually.

Relevant documentation:

- [Mutate Rules](https://kyverno.io/docs/policy-types/cluster-policy/mutate/)
- [MutatingPolicy](https://kyverno.io/docs/policy-types/mutating-policy/)

This `ClusterPolicy` adds common security defaults to Pods.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: add-secure-pod-defaults
spec:
  rules:
    - name: add-run-as-non-root
      match:
        any:
          - resources:
              kinds:
                - Pod
      mutate:
        patchStrategicMerge:
          spec:
            securityContext:
              +(runAsNonRoot): true
    - name: disallow-privilege-escalation
      match:
        any:
          - resources:
              kinds:
                - Pod
      mutate:
        foreach:
          - list: request.object.spec.containers[]
            patchStrategicMerge:
              spec:
                containers:
                  - name: '{{ element.name }}'
                    securityContext:
                      +(allowPrivilegeEscalation): false
```

### Generate Policies

Generate policies automatically create supporting resources required for secure Kubernetes environments. This helps platform teams establish consistent security controls, such as `NetworkPolicy` and `ResourceQuota` resources, without relying on manual configuration.

Relevant documentation:

- [Generate Rules](https://kyverno.io/docs/policy-types/cluster-policy/generate/)
- [GeneratingPolicy](https://kyverno.io/docs/policy-types/generating-policy/)

This `ClusterPolicy` generates a default `NetworkPolicy` for newly created namespaces.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: add-default-networkpolicy
spec:
  rules:
    - name: default-deny
      match:
        any:
          - resources:
              kinds:
                - Namespace
      exclude:
        any:
          - resources:
              namespaces:
                - kube-system
                - kube-public
                - kyverno
      generate:
        synchronize: true
        apiVersion: networking.k8s.io/v1
        kind: NetworkPolicy
        name: default-deny
        namespace: '{{ request.object.metadata.name }}'
        data:
          spec:
            podSelector: {}
            policyTypes:
              - Ingress
              - Egress
```

### Verify Images

Image verification helps ensure workloads use trusted and signed container images. This helps platform teams enforce software supply chain security and reduce the risk of deploying untrusted artifacts.

Relevant documentation:

- [Verify Images](https://kyverno.io/docs/policy-types/cluster-policy/verify-images/)
- [ImageValidatingPolicy](https://kyverno.io/docs/policy-types/image-validating-policy/)

This `ClusterPolicy` verifies signed images from an approved registry.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: verify-approved-images
spec:
  rules:
    - name: verify-signed-images
      match:
        any:
          - resources:
              kinds:
                - Pod
      verifyImages:
        - imageReferences:
            - registry.example.com/production/*
          required: true
          mutateDigest: true
          verifyDigest: true
          attestors:
            - entries:
                - keys:
                    publicKeys: |-
                      -----BEGIN PUBLIC KEY-----
                      <public-key>
                      -----END PUBLIC KEY-----
```

### Policy Reports / Audit Mode

Policy reports provide visibility into security and compliance violations across the cluster. Platform teams can use `Audit` mode to understand the impact of new security controls before moving them to enforcement, helping reduce the risk of disrupting existing workloads.

Relevant documentation:

- [Policy Reports](https://kyverno.io/docs/guides/reports/)
- [Validate Rules](https://kyverno.io/docs/policy-types/cluster-policy/validate/)

This `ClusterPolicy` audits Pods that do not define CPU and memory limits.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: audit-resource-requirements
spec:
  background: true
  rules:
    - name: require-requests-and-limits
      match:
        any:
          - resources:
              kinds:
                - Pod
      validate:
        failureAction: Audit
        message: CPU and memory requests and limits should be set.
        pattern:
          spec:
            containers:
              - resources:
                  requests:
                    cpu: '?*'
                    memory: '?*'
                  limits:
                    cpu: '?*'
                    memory: '?*'
```

View policy results with `kubectl`.

```sh
kubectl get policyreports -A
kubectl get clusterpolicyreports
```

## Real-World Security Use Cases

| Use case                    | Kyverno outcome            |
| --------------------------- | -------------------------- |
| Block privileged containers | Safer workloads            |
| Enforce non-root containers | Reduced attack surface     |
| Restrict image registries   | Trusted deployments        |
| Require resource limits     | Better cluster stability   |
| Generate network isolation  | Secure defaults            |
| Prevent running as root     | Improved workload security |
| Audit compliance            | Improved visibility        |

## Outcome Mapping

| User goal                     | Kyverno capability            | Example outcome                                              |
| ----------------------------- | ----------------------------- | ------------------------------------------------------------ |
| Restrict unsafe workloads     | Validation Policies           | Privileged containers and unsafe configurations are blocked. |
| Enforce trusted images        | Verify Images                 | Only signed images from approved registries are admitted.    |
| Standardize security controls | Mutation Policies             | Security defaults are applied automatically.                 |
| Reduce configuration drift    | Generate Policies             | Required security resources are created and synchronized.    |
| Roll out controls safely      | Policy Reports and Audit Mode | Teams can measure violations before enforcement.             |

## Implementation Path

1. Identify workload security requirements.
2. Start with policies in `Audit` mode and review violations before enforcement.
3. Enforce critical security controls.
4. Add image verification and registry restrictions.
5. Review policy reports and address violations.
6. Expand controls across namespaces and clusters.

## Community Resources

Explore these resources to learn more about Kubernetes security practices and policy-driven governance.

- [Kyverno Policy Library](https://kyverno.io/policies/)
- [Kubernetes Pod Security Standards](https://kubernetes.io/docs/concepts/security/pod-security-standards/)
- [CNCF TAG Security](https://tag-security.cncf.io/)
- [Kubernetes Security Documentation](https://kubernetes.io/docs/concepts/security/)

## Related Documentation

- [Validation](https://kyverno.io/docs/policy-types/validating-policy)
- [Mutation](https://kyverno.io/docs/policy-types/mutating-policy)
- [Generate](https://kyverno.io/docs/policy-types/generating-policy)
- [Verify Images](https://kyverno.io/docs/policy-types/image-validating-policy)
- [Policy Reports](https://kyverno.io/docs/guides/reports)
- [Admission Controllers](https://kyverno.io/docs/guides/admission-controllers)
