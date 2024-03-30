---
title: Policy Exceptions
description: >
  Create an exception to an existing policy using a PolicyException. 
weight: 80
---

{{% alert title="Warning" color="warning" %}}
Policy exceptions are a **beta** feature. Normal semantic versioning and compatibility rules will not apply.
{{% /alert %}}

Although Kyverno policies contain multiple methods to provide fine-grained control as to which resources they act upon in the form of [`match`/`exclude` blocks](match-exclude.md#match-statements), [preconditions](preconditions.md) at multiple hierarchies, [anchors](validate.md#anchors), and more, all these mechanisms have in common that the resources which they are intended to exclude must occur in the same rule definition. This may be limiting in situations where policies may not be directly editable, or doing so imposes an operational burden.

For example, in organizations where multiple teams must interact with the same cluster, a team responsible for policy authoring and administration may not be the same team responsible for submission of resources. In these cases, it can be advantageous to decouple the policy definition from certain exclusions. Additionally, there are often times where an organization or team must allow certain exceptions which would violate otherwise valid rules but on a one-time basis if the risks are known and acceptable.

Imagine a validate policy exists in `Enforce` mode which mandates all Pods must not mount host namespaces. A separate team has a legitimate need to run a specific tool in this cluster for a limited time which violates this policy. Normally, the policy would block such a "bad" Pod if the policy was not previously altered in such a way to allow said Pod to run. Rather than making adjustments to the policy, an exception may be granted. Both of these examples are use cases for a **PolicyException** resource described below.

A `PolicyException` is a Namespaced Custom Resource which allows a resource(s) to be allowed past a given policy and rule combination. It can be used to exempt any resource from any Kyverno rule type although it is primarily intended for use with validate rules. A PolicyException encapsulates the familiar `match`/`exclude` statements used in `Policy` and `ClusterPolicy` resources but adds an `exceptions{}` object to select the policy and rule name(s) used to form the exception. A `conditions{}` block (optional) uses common expressions similar to those found in [preconditions](preconditions.md) and [deny rules](validate.md#deny-rules) to query the contents of the selected resources in order to refine the selection process. The logical flow of how a PolicyException works in tandem with a validate policy is depicted below.

```mermaid
graph TD
  Start --> id1["Validate policy in enforce mode exists"]
  id1 --> id2["User/process sends violating resource"]
  id2 --> Need{"Matching PolicyException exists?"}
  Need -- No --> id3["Resource blocked"]
  Need -- Yes --> id4["Resource allowed"]
```

An example set of resources is shown below.

A ClusterPolicy exists containing a single validate rule in `Enforce` mode which requires all Pods must not use any host namespaces via the fields `hostPID`, `hostIPC`, or `hostNetwork`. If any of these fields are defined, they must be set to a value of `false`.

```yaml
apiVersion: kyverno.io/v2beta1
kind: ClusterPolicy
metadata:
  name: disallow-host-namespaces
spec:
  validationFailureAction: Enforce
  background: false
  rules:
    - name: host-namespaces
      match:
        any:
        - resources:
            kinds:
              - Pod
      validate:
        message: >-
          Sharing the host namespaces is disallowed. The fields spec.hostNetwork,
          spec.hostIPC, and spec.hostPID must be unset or set to `false`.
        pattern:
          spec:
            =(hostPID): "false"
            =(hostIPC): "false"
            =(hostNetwork): "false"
```

A cluster administrator wishes to grant an exception to a Pod or Deployment named `important-tool` which will be created in the `delta` Namespace. A PolicyException resource is created which specifies the policy name and rule name which should be bypassed as well as the resource kind, Namespace, and name which may bypass it.

{{% alert title="Note" color="info" %}}
Auto-generated rules for Pod controllers must be specified along with the Pod controller requesting exception, if applicable. Since Kyverno's auto-generated rules are additive in nature, when specifying specific resource names of Pod controllers, it may be necessary to use a wildcard (`*`) to allow the Pods emitted from those controllers to be exempted as components of the Pod name include ReplicaSet hash and Pod hash.
{{% /alert %}}

```yaml
apiVersion: kyverno.io/v2beta1
kind: PolicyException
metadata:
  name: delta-exception
  namespace: delta
spec:
  exceptions:
  - policyName: disallow-host-namespaces
    ruleNames:
    - host-namespaces
    - autogen-host-namespaces
  match:
    any:
    - resources:
        kinds:
        - Pod
        - Deployment
        namespaces:
        - delta
        names:
        - important-tool*
  conditions:
    any:
    - key: "{{ request.object.metadata.labels.app || '' }}"
      operator: Equals
      value: busybox
```

A Deployment matching the characteristics defined in the PolicyException, shown below, will be allowed creation even though it technically violates the rule's definition.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: important-tool
  namespace: delta
  labels:
    app: busybox
spec:
  replicas: 1
  selector:
    matchLabels:
      app: busybox
  template:
    metadata:
      labels:
        app: busybox
    spec:
      hostIPC: true
      containers:
      - image: busybox:1.35
        name: busybox
        command: ["sleep", "1d"]
```

PolicyExceptions are always Namespaced yet may provide an exception for a cluster-scoped resource as well. There is no correlation between the Namespace in which the PolicyException exists and the Namespace where resources may be excepted.

Exceptions against a ClusterPolicy and those against a (Namespaced) Policy can be disambiguated by specifying the value of the `exceptions[].policyName` field in the format `<namespace>/<policy-name>`.

```yaml
exceptions:
- policyName: team-a/disallow-host-namespaces
  ruleNames:
  - host-namespaces
```

PolicyExceptions also support background scanning, enabled by default. An exception which either explicitly defines `spec.background=true` or does not define the field at all, will influence [Policy Reports](../policy-reports) when the exception is processed, allowing report results to change from a `Fail` to a `Skip` result. When background scans are enabled, PolicyExceptions forbid matching on the same types of fields as those forbidden by validate rules including Roles, ClusterRoles, and user information.

Wildcards (`"*"`) are supported in the value of the `ruleNames[]` field allowing exception from any/all rules in the policy without having to name them explicitly.

Since PolicyExceptions are just another Custom Resource, their use can and should be controlled by a number of different mechanisms to ensure their creation in a cluster is authorized including:

* Kubernetes RBAC
* Specific Namespace for PolicyExceptions (see [Container Flags](../installation/customization.md#container-flags))
* Existing GitOps governance processes
* [Kyverno validate rules](validate.md)
* [YAML manifest validation](validate.md#manifest-validation)

PolicyExceptions may be subjected to Kyverno validate policies which can be used to provide additional guardrails around how they may be crafted. For example, it is considered a best practice to only allow very narrow exceptions to a much broader rule. Given the case shown earlier, only a Pod or Deployment with the name `important-tool` would be allowed by the exception, not any Pod or Deployment. Kyverno policy can help ensure, both in the cluster and in a CI/CD process via the [CLI](../kyverno-cli), that PolicyExceptions conform to your design standards. Below is an example of a sample policy to illustrate how a Kyverno validate rule ensure that a specific name must be used when creating an exception. For other samples, see the [policy library](../../policies).

```yaml
apiVersion: kyverno.io/v2beta1
kind: ClusterPolicy
metadata:
  name: policy-for-exceptions
spec:
  validationFailureAction: Enforce
  background: false
  rules:
  - name: require-match-name
    match:
      any:
      - resources:
          kinds:
          - PolicyException
    validate:
      message: >-
        An exception must explicitly specify a name for a resource match.
      pattern:
        spec:
          match:
            =(any):
            - resources:
                names: "?*"
            =(all):
            - resources:
                names: "?*"
```

## Pod Security Exemptions

Kyverno policies can be used to apply Pod Security Standards profiles and controls via the [validate.podSecurity](validate.md#pod-security) subrule. However, there are cases where certain Pods need to be exempted from these policies. For example, a Pod may need to run as `root` or require privileged access. In such cases, a PolicyException can be used to define an exemption for the Pod through the `podSecurity{}` block. It can be used to define controls that are exempted from the policy.

Given the following policy that enforces the latest version of the Pod Security Standards restricted profile in a single rule across the entire cluster.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: psa
spec:
  background: true
  validationFailureAction: Enforce
  rules:
  - name: restricted
    match:
      any:
      - resources:
          kinds:
          - Pod
    validate:
      podSecurity:
        level: restricted
        version: latest
```

In this use case, all Pods in the `delta` Namespace need to run as a root. A PolicyException can be used to exempt all Pods whose Namespace is `delta` from the policy by excluding the `runAsNonRoot` control.

```yaml
apiVersion: kyverno.io/v2beta1
kind: PolicyException
metadata:
  name: pod-security-exception
  namespace: policy-exception-ns
spec:
  exceptions:
  - policyName: psa
    ruleNames:
    - restricted
  match:
    any:
    - resources:
        namespaces:
        - delta
  podSecurity:
    - controlName: "Running as Non-root"
```

The following Pod satisfies all controls in the restricted profile except the `Running as Non-root` control but it matches the exception. Hence, it will be successfully created.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
  namespace: delta
spec:
  containers:
  - name: nginx
    image: nginx
    args:
    - sleep
    - 1d
    securityContext:
      seccompProfile:
        type: RuntimeDefault
      runAsNonRoot: false
      allowPrivilegeEscalation: false
      capabilities:
        drop:
        - ALL
```

PolicyExceptions `podSecurity{}` block has the same functionality as the [validate.podSecurity.exclude](validate.md#exemptions) block in the policy itself. They can be used to exempt controls that can only be defined in the container level fields.

For example, the following PolicyException exempts the containers running either the `nginx` or `redis` image from following the Capabilities control.

```yaml
apiVersion: kyverno.io/v2beta1
kind: PolicyException
metadata:
  name: pod-security-exception
  namespace: policy-exception-ns
spec:
  exceptions:
  - policyName: psa
    ruleNames:
    - restricted
  match:
    any:
    - resources:
        namespaces:
        - delta
  podSecurity:
    - controlName: Capabilities
      images:
          - nginx*
          - redis*
```

There might be a case where it is required to have specific values for the controls in the PodSecurity profile. In such cases, the `podSecurity.restrictedField` field can be used to define these values for the controls that are exempted from the policy.

For example, service meshes like Istio and Linkerd employ an `initContainer` that requires some privileges which are very often problematic in security-conscious clusters. Minimally, these initContainers must add two [Linux capabilities](https://man7.org/linux/man-pages/man7/capabilities.7.html) which allow them to make modifications to the networking stack: `NET_ADMIN` and `NET_RAW`. These initContainers may go even further by running as a root user, something which is a big no-no in the world of containers.

In this case, the `podSecurity.restrictedField` can be used to enforce the entire baseline profile of the Pod Security Standards but only exclude Istio's and Linkerd's images from specifically the initContainers list.

The following PolicyException grants an exemption to the `initContainers` that use Istio or Linkerd images, allowing them to bypass the `Capabilities` control. This is achieved by permitting the values of `NET_ADMIN` and `NET_RAW` in the `securityContext.capabilities.add` field.

```yaml
apiVersion: kyverno.io/v2beta1
kind: PolicyException
metadata:
  name: pod-security-exception
  namespace: policy-exception-ns
spec:
  exceptions:
  - policyName: psa
    ruleNames:
    - baseline
  match:
    any:
    - resources:
        kinds:
          - Pod
  podSecurity:
    - controlName: Capabilities
      images:
        - "*/istio/proxyv2*"
        - "*/linkerd/proxy-init*"
      restrictedField: spec.initContainers[*].securityContext.capabilities.add
      values:
        - NET_ADMIN
        - NET_RAW
```

The following Pod meets all requirements outlined in the baseline profile, except the `Capabilities` control in the `initContainer`. However, it matches the exception that permits the configuration of `spec.initContainers[*].securityContext.capabilities.add` to include `NET_ADMIN` and `NET_RAW`. Hence, it will be successfully created.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: istio-pod
spec:
  initContainers:
  - name: istio-init
    image: docker.io/istio/proxyv2:1.20.2
    args:
        - istio-iptables
        - -p
        - "15001"
        - -z
        - "15006"
        - -u
        - "1337"
        - -m
        - REDIRECT
        - -i
        - '*'
        - -x
        - ""
        - -b
        - '*'
        - -d
        - 15090,15021,15020
        - --log_output_level=default:info
    securityContext:
      allowPrivilegeEscalation: false
      capabilities:
        add:
          - NET_ADMIN
          - NET_RAW
        drop:
          - ALL
      privileged: false
      readOnlyRootFilesystem: false
      runAsGroup: 0
      runAsNonRoot: false
      runAsUser: 0
  containers:
  - name: busybox
    image: busybox:1.35
    args:
    - sleep
    - infinity
```

The following Pod meets all requirements outlined in the baseline profile, except the `Capabilities` control in the `initContainer` and it matches the exception but it sets the `spec.initContainers[*].securityContext.capabilities.add` to `SYS_ADMIN` which isn't an allowed value. Hence, it will be rejected.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: istio-pod
spec:
  initContainers:
  - name: istio-init
    image: docker.io/istio/proxyv2:1.20.2
    args:
        - istio-iptables
        - -p
        - "15001"
        - -z
        - "15006"
        - -u
        - "1337"
        - -m
        - REDIRECT
        - -i
        - '*'
        - -x
        - ""
        - -b
        - '*'
        - -d
        - 15090,15021,15020
        - --log_output_level=default:info
    securityContext:
      allowPrivilegeEscalation: false
      capabilities:
        add:
          - NET_ADMIN
          - NET_RAW
          - SYS_ADMIN
        drop:
          - ALL
      privileged: false
      readOnlyRootFilesystem: false
      runAsGroup: 0
      runAsNonRoot: false
      runAsUser: 0
  containers:
  - name: busybox
    image: busybox:1.35
    args:
    - sleep
    - infinity
```
