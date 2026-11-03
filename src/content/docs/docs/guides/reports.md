---
title: Policy Reports
excerpt: View and audit Kyverno policy results with reports.
sidebar:
  order: 1
---

Policy reports are Kubernetes custom resources generated and managed by Kyverno. They record the results of applying [policies](/docs/policy-types/overview) to resources. Reports represent the current state of resources in the cluster, not a historical audit log. When a resource is deleted, its report is removed.

A `PolicyReport` describes a namespaced resource and is created in the resource's namespace. A `ClusterPolicyReport` describes a cluster-scoped resource. These report types use the `wgpolicyk8s.io/v1alpha2` API, independently of the policy API.

## Admission and Background Results

A [ValidatingPolicy](/docs/policy-types/validating-policy) with `validationActions: [Audit]` allows a non-compliant resource to be created and records the failure in a report. With `validationActions: [Deny]`, non-compliant admission requests are blocked. Reports describe resources that exist in the cluster; use [metrics](/docs/guides/monitoring) and Kubernetes Events to investigate blocked requests.

Use audit results to assess the impact of a policy before switching to `Deny`. Because reports are separate resources, Kubernetes RBAC can grant users access to reports without granting access to modify policies.

Reports can contain results from admission processing and from background scans. They can also include results from mutation, generation, image verification, and [policy exceptions](/docs/guides/exceptions), depending on the enabled reporting features.

## Report Result Logic

| Result  | Description                                                                                                  |
| ------- | ------------------------------------------------------------------------------------------------------------ |
| `pass`  | The policy evaluated successfully for the resource.                                                          |
| `skip`  | Evaluation was bypassed, for example by a matching PolicyException.                                          |
| `fail`  | The resource did not satisfy the policy.                                                                     |
| `warn`  | A non-compliant result is reported as a warning, for example when `policies.kyverno.io/scored` is `"false"`. |
| `error` | An evaluation error prevented the policy from producing a normal result.                                     |

CEL `matchConditions` determine whether a policy applies. A resource that does not match a policy is not a policy violation. An exception can also change reporting behavior; see [Policy Exceptions](/docs/guides/exceptions#interpreting-policyreport-results).

## Viewing Report Summaries

View reports across namespaces:

```sh
kubectl get policyreport -A
kubectl get clusterpolicyreport
```

Use `-o wide` to identify the resource associated with a report:

```sh
kubectl get policyreport -n default -o wide
```

Inspect a report in detail:

```sh
kubectl describe policyreport <report-name> -n default
kubectl get policyreport <report-name> -n default -o yaml
```

Each report contains a `scope` identifying the resource, a `results` array identifying evaluated policies, and a `summary` of result counts. For a graphical view, see [Policy Reporter](/docs/subprojects/policy-reporter).

## Viewing Policy Violations

For example, use `jq` to list failed results for resources in a namespace:

```sh
kubectl get policyreport -n default -o json \
  | jq '.items[] | {scope, failures: [.results[]? | select(.result == "fail")]}'
```

## Background Scans

The reports controller can evaluate existing resources, including resources created before a policy was installed. Background scans do not block or delete existing resources, even when a policy uses `validationActions: [Deny]`.

For policies that support background evaluation, control it using `spec.evaluation.background.enabled`:

```yaml
spec:
  evaluation:
    admission:
      enabled: true
    background:
      enabled: true
```

Background scans run periodically; configure their interval using the [reports controller flags](/docs/installation/customization#container-flags). They are handled by the reports controller, not the background controller responsible for resource generation and mutation.

Policies relying on admission-only information, such as the requesting user's identity, must disable background evaluation:

```yaml
spec:
  evaluation:
    background:
      enabled: false
```

Background scans do not have the original AdmissionReview request's user information. Write policies using resource data when they need to apply in both admission and background evaluation.

## Example: Trigger a PolicyReport

Apply a policy requiring a `team` label on Pods. This example uses `Audit` so a non-compliant Pod can be created and reported:

```yaml
apiVersion: policies.kyverno.io/v1
kind: ValidatingPolicy
metadata:
  name: require-team-label
spec:
  validationActions: [Audit]
  evaluation:
    background:
      enabled: true
  matchConstraints:
    resourceRules:
      - apiGroups: ['']
        apiVersions: ['v1']
        operations: ['CREATE', 'UPDATE']
        resources: ['pods']
  validations:
    - expression: has(object.metadata.labels) && has(object.metadata.labels.team)
      message: 'Pods must have a team label.'
```

Create a Pod without the required label in a namespace included in policy evaluation:

```sh
kubectl run report-example --image=nginx -n default
kubectl get policyreport -n default -o wide
```

After reporting completes, inspect the report for `report-example`. Its results identify `require-team-label` with `result: fail` and the validation message. Add the label and inspect the report again:

```sh
kubectl label pod report-example team=platform -n default
```

After reevaluation, the policy result changes to `pass`. Remove the example resources when finished:

```sh
kubectl delete pod report-example -n default
kubectl delete validatingpolicy require-team-label
```

## Report Internals

Kyverno uses `EphemeralReport` and `ClusterEphemeralReport` resources in the `reports.kyverno.io/v1` API group as intermediate results. The reports controller aggregates them into the final `PolicyReport` or `ClusterPolicyReport`. These intermediate resources are managed automatically and normally require no manual interaction.

See the [developer reporting documentation](https://github.com/kyverno/kyverno/tree/main/docs/dev/reports) for implementation details.

## Configuring Reporting

Reporting options are described in [Container Flags](/docs/installation/customization#container-flags):

- `--enableReporting` selects reporting features, such as `validate`, `mutate`, `mutateExisting`, `generate`, and `imageVerify`.
- `--allowedResults` selects persisted results. The default is `pass,fail,error,warn,skip`; restricting results can reduce etcd usage.
- The reports controller needs `get`, `list`, and `watch` permissions for the resources it evaluates.

To disable reports for an individual policy, add the `reports.kyverno.io/disabled` label with any value:

```yaml
metadata:
  labels:
    reports.kyverno.io/disabled: 'true'
```

:::caution
Background reporting does not use the admission webhook's [namespace selector](/docs/installation/customization#namespace-selectors). Configure policy matching and reporting exclusions separately.
:::

## OpenReports

Kyverno also supports the `openreports.io/v1alpha1` API as an alternative to `wgpolicyk8s` reporting. Enable the `--openreportsEnabled` flag on the reports controller, or set the Helm value `openreports.enabled=true`.

The same CEL policy example above can be used with OpenReports enabled. Inspect the resulting reports with:

```sh
kubectl get reports.openreports.io -A
```

OpenReports integration was introduced as an alpha feature in Kyverno 1.15.

## ValidatingAdmissionPolicy Reports

Kyverno can report results for Kubernetes `ValidatingAdmissionPolicy` resources and their bindings. Enable `--validatingAdmissionPolicyReports=true` on the reports controller; this flag is disabled by default.

For example, apply a policy and binding that check Deployment replica counts:

```yaml
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingAdmissionPolicy
metadata:
  name: check-deployment-replicas
spec:
  matchConstraints:
    resourceRules:
      - apiGroups: ['apps']
        apiVersions: ['v1']
        operations: ['CREATE', 'UPDATE']
        resources: ['deployments']
  validations:
    - expression: object.spec.replicas <= 5
---
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingAdmissionPolicyBinding
metadata:
  name: check-deployment-replicas
spec:
  policyName: check-deployment-replicas
  validationActions: [Audit]
  matchResources:
    namespaceSelector:
      matchLabels:
        environment: staging
```

Create matching resources and inspect their reports:

```sh
kubectl create namespace staging
kubectl label namespace staging environment=staging
kubectl create deployment deployment-example --image=nginx --replicas=7 -n staging
kubectl get policyreport -n staging -o yaml
```

After the background scan, the report records a failed `check-deployment-replicas` result for the Deployment because it exceeds five replicas.
