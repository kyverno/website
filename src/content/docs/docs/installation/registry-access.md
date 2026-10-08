---
title: Registry access and policy credentials
excerpt: Configure private registry destinations and namespace-scoped policy credentials.
sidebar:
  order: 36
---

Registry destination settings and credential references serve different purposes. The destination settings control where image and signature requests can connect. Credential references select the Kubernetes Secrets used to authenticate those requests. Allowing a destination does not give it another registry's credentials.

## Private registry destinations

The default `privateRegistryEgressMode` is `audit`. Ordinary private registries continue to work, and Kyverno logs private destinations that `enforce` mode would reject at verbosity 2. To use `enforce`, list the required private registry hosts, token services, and signature verification services:

```yaml
features:
  registryClient:
    privateRegistryEgressMode: enforce
    privateRegistryAllowlist:
      - registry.corp.example
      - auth.corp.example
      - 10.20.30.0/24
```

The equivalent controller arguments are:

```text
--privateRegistryEgressMode=enforce
--privateRegistryAllowlist=registry.corp.example,auth.corp.example,10.20.30.0/24
```

Entries can be exact hostnames, IP addresses, or CIDRs. URLs, wildcard names, paths, and empty entries are not accepted. Public destinations do not need allowlist entries. A hostname entry covers that hostname's ordinary private addresses across ports. Prefer specific hostnames or narrow subnets.

Both modes reject loopback, link-local, metadata, unspecified, multicast, and broadcast destinations. An allowlist entry does not override these restrictions. Move a registry using one of those addresses to an ordinary private or public address before upgrading.

The settings cover registry requests, authentication token services, redirects, and HTTP services used for signature verification, including public-key URLs and TUF mirrors. Private redirect and token destinations need their own entries in enforce mode. KMS provider SDK connections are outside these settings.

The Helm chart passes these settings to the admission, background, and reports controllers. To override a controller, use its `featuresOverride.registryClient` values. Cleanup receives neither argument.

Before enabling enforce mode:

1. Exercise image lookups, signature verification, and relevant background scans in audit mode.
2. Review the logs and list every required private registry, token, redirect, and signature-service destination.
3. Enable enforce mode and repeat the same operations.

These settings apply to CEL image lookups and image validating policies. The corresponding 1.19 legacy-policy update applies them to `imageRegistry`, `verifyImages`, and manifest signature verification as well.

### Proxies

`HTTP_PROXY`, `HTTPS_PROXY`, and `NO_PROXY` retain their normal roles. An operator-configured proxy may use an ordinary private address without an allowlist entry, but the destination is checked separately. A private proxy does not authorize every private destination.

Kyverno validates direct connection addresses. When a proxy resolves the final hostname, configure the proxy's own destination controls too; Kyverno cannot inspect the proxy's DNS resolution.

## Secret references in namespaced policies

For a policy in `tenant-a`, a bare Secret name such as `registry-pull` resolves in `tenant-a`. The explicit reference `tenant-a/registry-pull` selects the same Secret. A reference to a different namespace is rejected at admission and during evaluation.

This applies to:

- `NamespacedImageValidatingPolicy.spec.credentials.secrets` and signature pull Secrets in its Cosign attestors, including attestors passed to CEL functions.
- In the 1.19 legacy-policy update, `Policy` credentials in `context[].imageRegistry` and `verifyImages`, including nested context entries.

Cluster-scoped policies retain their existing credential defaults. Administrator-configured global credentials and resource `imagePullSecrets` are separate from a policy's explicit Secret references and retain their existing behavior.

Before upgrading, replace namespaced policy references that depend on a Secret in the Kyverno installation namespace or another namespace. Provision credentials appropriate for the tenant in the policy namespace, then update the reference. Missing credentials or permissions can cause private registry authentication to fail. Stored policies with invalid references report an evaluation error until corrected.

### Grant access to a named Secret

The controller can use a bounded API GET for a policy's tenant Secret when its existing cache does not contain it. This does not add tenant Secret informers or grant Kubernetes permissions. Grant only the required access, for example:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: kyverno-registry-credential
  namespace: tenant-a
rules:
  - apiGroups: ['']
    resources: ['secrets']
    resourceNames: ['registry-pull']
    verbs: ['get']
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: kyverno-registry-credential
  namespace: tenant-a
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: kyverno-registry-credential
subjects:
  - kind: ServiceAccount
    name: kyverno-admission-controller
    namespace: kyverno
```

Use the actual namespace and ServiceAccount names from your installation. Add the background or reports controller ServiceAccounts only when they evaluate the policy. An authorization error is returned without trying an installation-namespace Secret instead.

## Parameters in legacy Policy CEL rules

The 1.19 update also confines `Policy.spec.rules[].validate.cel` parameters to the policy namespace. An omitted `paramRef.namespace` defaults there; an explicit namespace must match. This applies to both named references and selectors. The `paramKind` must describe a namespaced resource in the requested served API version, so install its CRD before creating the Policy.

Use an administrator-managed `ClusterPolicy` when cluster-wide parameter access is required. Native Kubernetes `ValidatingAdmissionPolicy` and `MutatingAdmissionPolicy` parameter behavior is unchanged.
