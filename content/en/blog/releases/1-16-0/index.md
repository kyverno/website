---
date: 2025-11-10
title: Announcing Kyverno Release 1.16!
linkTitle: Kyverno 1.16
description: Kyverno 1.16 marks a pivotal step toward a unified, CEL‑powered policy platform.
draft: false
---

# Announcing Kyverno Release 1.16!

Kyverno 1.16 delivers major advancements in policy as code for Kubernetes, centered on a new generation of CEL-based policies now available in beta with a clear path to GA. This release introduces partial support for namespaced CEL policies to confine enforcement and minimize RBAC, aligning with least-privilege best practices. Observability is significantly enhanced with full metrics for CEL policies and native event generation, enabling precise visibility and faster troubleshooting. Security and governance get sharper controls through fine-grained policy exceptions tailored for CEL policies, and validation use cases broaden with the integration of an HTTP authorizer into ValidatingPolicy. Finally, we’re debuting the Kyverno SDK, laying the foundation for ecosystem integrations and custom tooling.

## CEL Policy Types

### CEL Policies in beta

CEL policy types are introduced as v1beta. The promotion plan provides a clear, non‑breaking path: v1 will be made available in 1.17 with GA targeted for 1.18. This release includes the cluster‑scoped family (Validating, Mutating, Generating, Deleting, ImageValidating) at v1beta1 and adds namespaced variants for validation, deleting, and image validation; namespaced Generating and Mutating will follow in 1.17. PolicyException and GlobalContextEntry will advance in step to keep versions aligned; see the promotion roadmap in the tracking issue.

## Namespaced Policies

Kyverno 1.16 introduces namespaced CEL policy types - `NamespacedValidatingPolicy`, `NamespacedDeletingPolicy`, and `NamespacedImageValidatingPolicy` - which mirror their cluster-scoped counterparts but apply only within the policy’s namespace. This lets teams enforce guardrails with least-privilege RBAC and without central changes, improving multi-tenancy and safety during rollout. Choose namespaced types for team-owned namespaces and cluster-scoped types for global controls.

## Observability Upgrades

CEL policies now have comprehensive, native observability for faster diagnosis.

- Validating policy execution latency
  - Metrics:  `kyverno_validating_policy_execution_duration_seconds_count, ..._sum, ..._bucket`
  - What it measures: Time spent evaluating validating policies per admission/background execution as a Prometheus histogram.
  - Key labels: policy_name, policy_background_mode, policy_validation_mode (enforce/audit), resource_kind, resource_namespace, resource_request_operation (create/update/delete), execution_cause (admission_request/background_scan), result (PASS/FAIL).

- Mutating policy execution latency
  - Metrics: `kyverno_mutating_policy_execution_duration_seconds_count, ..._sum, ..._bucket`
  - What it measures: Time spent executing mutating policies (admission/background) as a Prometheus histogram.
  - Key labels: policy_name, policy_background_mode, resource_kind, resource_namespace, resource_request_operation, execution_cause, result.

- Generating policy execution latency
  - Metrics: `kyverno_generating_policy_execution_duration_seconds_count, ..._sum, ..._bucket`
  - What it measures: Time spent executing generating policies when evaluating requests or during background scans.
  - Key labels: policy_name, policy_background_mode, resource_kind, resource_namespace, resource_request_operation, execution_cause, result.

- Image-validating policy execution latency
  - Metrics: `kyverno_image_validating_policy_execution_duration_seconds_count, ..._sum, ..._bucket`
  - What it measures: Time spent evaluating image-related validating policies (e.g., image verification) as a Prometheus histogram.
  - Key labels: policy_name, policy_background_mode, resource_kind, resource_namespace, resource_request_operation, execution_cause, result.

CEL policies now emit Kubernetes Events for passes, violations, errors, and compile/load issues with rich context (policy/rule, resource, user, mode). This provides instant, kubectl-visible feedback and easier correlation with admission decisions and metrics during rollout and troubleshooting.

## Fine-Grained Policy Exceptions

### Image-based exceptions

This exception allows `Pods` in `ci` using images, via `images` attribute, that match the provided patterns while keeping the no-latest rule enforced for all other images. It narrows the bypass to specific namespaces and teams for auditability.

```yaml
apiVersion: policies.kyverno.io/v1beta1
kind: PolicyException
metadata:
  name: allow-ci-latest-images
  namespace: ci
spec:
  policies:
    - name: restrict-image-tags
      rules: ["no-latest"]
  images:
    - "ghcr.io/kyverno/*:latest"
  matchConditions:
    - expression: "has(object.metadata.labels.team) && object.metadata.labels.team == 'platform'"
```

The following `ValidatingPolicy` references `exceptions.allowedImages` which skips validation checks for white-listed image(s):

```yaml
apiVersion: policies.kyverno.io/v1beta1
kind: ValidatingPolicy
metadata:
  name: check-labels
spec:
  rules:
    - name: broker-config
      match:
        any:
          - resources:
              kinds: ["pods"]
              namespaces: ["exceptions-allowed-images"]
      matchConditions:
        - expression: "has(object.spec.containers) && object.spec.containers.exists(c, exceptions.allowedImages.exists(img, c.image == img))"
      validations:
        # ...
```

### Value-based exceptions

This exception whitelists a list of values via `allowedValues` used by a CEL validation for a constrained set of targets so teams can proceed without weakening the entire policy.

```yaml
apiVersion: policies.kyverno.io/v1beta1
kind: PolicyException
metadata:
  name: allow-debug-annotation
  namespace: dev
spec:
  policies:
    - name: require-approved-annotations
      rules: ["no-debug-mode"]
  allowedValues:
    - "debug-mode-temporary"
  matchConditions:
    - expression: "object.metadata.name.startsWith('experiments-')"
```

Here’s the policy leveraging the above allowed values. It denies resources unless the annotation value is present in `exceptions.allowedValues`.

```yaml
apiVersion: policies.kyverno.io/v1beta1
kind: ValidatingPolicy
metadata:
  name: with-exception-skip-result
spec:
  matchConstraints:
    resourceRules:
      - apiGroups:   [apps]
        apiVersions: [v1]
        operations:  [CREATE, UPDATE]
        resources:   [deployments]
  variables:
    - name: allowedCapabilities
      expression: "['AUDIT_WRITE','CHOWN','DAC_OVERRIDE','FOWNER','FSETID','KILL','MKNOD','NET_BIND_SERVICE','SETFCAP','SETGID','SETPCAP','SETUID','SYS_CHROOT']"
  validations:
    - expression: >-
        object.spec.containers.all(container,
        container.?securityContext.?capabilities.?add.orValue([]).all(capability,
        capability in exceptions.allowedValues ||
        capability in variables.allowedCapabilities))
      message: >-
        Any capabilities added beyond the allowed list (AUDIT_WRITE, CHOWN, DAC_OVERRIDE, FOWNER,
        FSETID, KILL, MKNOD, NET_BIND_SERVICE, SETFCAP, SETGID, SETPCAP, SETUID, SYS_CHROOT)
        are disallowed.
```

### Configurable reporting status

This exception sets `reportResult: pass`, so when it matches, Policy Reports show “pass” rather than the default “skip”, improving dashboards and SLO signals during planned waivers.

```yaml
apiVersion: policies.kyverno.io/v1beta1
kind: PolicyException
metadata:
  name: green-exception-in-report
  namespace: supply-chain
spec:
  policies:
    - name: verify-sbom
      rules: ["require-slsa-level"]
  reportResult: pass
```

## Kyverno Authorizer

Beyond enriching admission-time validation, Kyverno now extends policy decisions to your service edge. The Kyverno Authz Server applies Kyverno policies to authorize requests for Envoy (via the External Authorization filter) and for plain HTTP services as a standalone HTTP authorization server, returning allow/deny decisions based on the same policy engine you use in Kubernetes. This unifies policy enforcement across admission, gateways, and services, enabling consistent guardrails and faster adoption without duplicating logic.

## Introducing the Kyverno SDK

Alongside embedding CEL policy evaluation in controllers, CLIs, and CI, there’s now a companion SDK for service-edge authorization. The SDK lets you load Kyverno policies, compile them, and evaluate incoming requests to produce allow/deny decisions with structured results—powering Envoy External Authorization and plain HTTP services without duplicating policy logic. It’s designed for gateways, sidecars, and app middleware with simple Go APIs, optional metrics/hooks, and a path to unify admission-time and runtime enforcement.

## Other Features and Enhancements

### Label-based reporting configuration

Kyverno now supports label-based report suppression. Add the label reports.kyverno.io/disabled (any value, e.g., "true") to any policy - ClusterPolicy, CEL policy types, ValidatingAdmissionPolicy, or MutatingAdmissionPolicy - to prevent all reporting (both ephemeral and PolicyReports) for that policy. This lets teams silence noisy or staging policies without changing enforcement; remove the label to resume reporting.

### Use Kyverno CEL Libraries in Policy matchConditions

Kyverno 1.16 enables Kyverno CEL libraries in policy `matchConditions`, not just in rule bodies, so you can target when rules run using richer, context-aware checks. These expressions are evaluated by Kyverno but are not used to build admission webhook `matchConditions` - webhook routing remains unchanged.

## Getting Started & Backward Compatibility

### Upgrading to Kyverno 1.16

To upgrade to Kyverno 1.16, you can use Helm:

```bash
helm repo update
helm upgrade --install kyverno kyverno/kyverno -n kyverno --version 3.6.0
```

### Backward Compatibility

Kyverno 1.16 remains fully backward compatible with existing ClusterPolicy resources. You can continue running current policies and adopt the new policy types incrementally; once CEL policy types reach GA, the legacy ClusterPolicy API will enter a formal deprecation process following our standard, non‑breaking schedule.

## Roadmap

We’re building on 1.16 with a clear, low‑friction path forward. In 1.17, CEL policy types will be available as v1, and migration tooling and docs will focus on making upgrades routine. We will continue to expand CEL libraries, samples, and performance optimizations, with SDK and kyverno‑authz maturation to unify admission‑time and runtime enforcement paths. See the release board for the in‑flight work and timelines.

## Conclusion

Kyverno 1.16 marks a pivotal step toward a unified, CEL‑powered policy platform: you can adopt the new policy types in beta today, move enforcement closer to teams with namespaced policies, and gain sharper visibility with native Events and detailed latency metrics. Fine‑grained exceptions make rollouts safer without weakening guardrails, while label‑based report suppression and CEL in matchConditions reduce noise and let you target policy execution precisely.

Looking ahead, the path to v1 and GA is clear, and the ecosystem is expanding with the Kyverno Authz Server and SDK to bring the same policy engine to gateways and services. Upgrade when ready, start with audit where useful, and share feedback—it will shape the final polish and the journey to GA.