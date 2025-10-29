---
title: ValidatingPolicy
description: >-
    Validate Kubernetes resources or JSON payloads
weight: 10
---

{{< feature-state state="alpha" version="v1.15" />}}

The Kyverno `ValidatingPolicy` type extends the Kubernetes `ValidatingAdmissionPolicy` type for complex policy evaluations and other features required for Policy-as-Code. A `ValidatingPolicy` is a superset of a `ValidatingAdmissionPolicy` and contains additional fields for Kyverno specific features.

```
apiVersion: policies.kyverno.io/v1alpha1
kind: ValidatingPolicy
metadata:
  name: check-labels
spec:
  validationActions:
    - Deny
  matchConstraints:
    resourceRules:
    - apiGroups:   [""]
      apiVersions: [v1]
      operations:  [CREATE, UPDATE]
      resources:   [pods]
  validations:
    - message: label 'environment' is required
      expression: "'environment' in object.metadata.?labels.orValue([])"
```

## Comparison with ValidatingAdmissionPolicy

The table below compares major features across the Kubernetes `ValidatingAdmissionPolicy` and Kyverno `ValidatingPolicy` types.

| Feature            | ValidatingAdmissionPolicy    |  ValidatingPolicy         |
|--------------------|------------------------------|---------------------------------------------|
| Enforcement        | Admission                    | Admission, Background, Pipelines, ...       |
| Payloads           | Kubernetes                   | Kubernetes, Any JSON or YAML                |
| Distribution       | Kubernetes                   | Helm, CLI, Web Service, API, SDK            |
| CEL Library        | Basic                        | Extended                                    |
| Bindings           | Manual                       | Automatic                                   |
| Auto-generation    | -                            | Pod Controllers, ValidatingAdmissionPolicy  |
| External Data      | _                            | Kubernetes resources or API calls           |
| Caching            | _                            | Global Context, image verification results  |
| Background scans   | -                            | Periodic, On policy creation or change      |
| Exceptions         | -                            | Fine-grained exceptions                     |
| Reporting          | _                            | Policy WG Reports API                       |
| Testing            | _                            | Kyverno CLI (unit), Chainsaw (e2e)          |


## Additional Fields

The `ValidatingPolicy` extends the [Kubernetes ValidatingAdmissionPolicy](https://kubernetes.io/docs/reference/access-authn-authz/validating-admission-policy/) with the following additional fields for Kyverno features. A complete reference is provided in the [API specification](https://htmlpreview.github.io/?https://github.com/kyverno/kyverno/blob/release-1.14/docs/user/crd/index.html#policies.kyverno.io/v1alpha1.ValidatingPolicy).

### evaluation

The `spec.evaluation` field defines how the policy is applied and how the payload is processed. It can be used to enable, or disable, admission request processing and background processing for a policy. It is also used to manage whether the payload is processed as JSON or a Kubernetes resource.

```yaml
apiVersion: policies.kyverno.io/v1alpha1
kind: ValidatingPolicy
metadata:
  name: sample
spec:
  evaluation:
    admission:
      enabled: false
    background:
      enabled: true
    mode : Kubernetes
  ...
```

The `mode` can be set to `JSON` for non-Kubernetes payloads.

Refer to the [API Reference](https://htmlpreview.github.io/?https://github.com/kyverno/kyverno/blob/release-1.14/docs/user/crd/index.html#policies.kyverno.io/v1alpha1.EvaluationConfiguration) for details.

### webhookConfiguration

The `spec.webhookConfiguration` field defines properties used to manage the Kyverno admission controller webhook settings.


```yaml
apiVersion: policies.kyverno.io/v1alpha1
kind: ValidatingPolicy
metadata:
  name: check-deployment-labels
spec:
  webhookConfiguration:
   timeoutSeconds: 15
  ...
```

In the policy above, `webhookConfiguration.timeoutSeconds` is set to `15`, which defines how long the admission request waits for policy evaluation. The default is `10` seconds, and the allowed range is `1` to `30` seconds. After this timeout, the request may fail or ignore the result based on the failure policy. Kyverno reflects this setting in the generated `ValidatingWebhookConfiguration`.

Refer to the [API Reference](https://htmlpreview.github.io/?https://github.com/kyverno/kyverno/blob/release-1.14/docs/user/crd/index.html#policies.kyverno.io/v1alpha1.WebhookConfiguration) for details.


### autogen

The `spec.autogen` field defines policy auto-generation behaviors, to automatically generate policies for pod controllers and generate `ValidatingAdmissionPolicy` types for Kubernetes API server execution.

Here is an example of generating policies for deployments, jobs, cronjobs, and statefulsets and also generating a `ValidatingAdmissionPolicy` from the `ValidatingPolicy` declaration:

```yaml
 apiVersion: policies.kyverno.io/v1alpha1
 kind: ValidatingPolicy
 metadata:
   name: disallow-capabilities
 spec:
   autogen:
    validatingAdmissionPolicy:
     enabled: true
    podControllers:
      controllers:
       - deployments
       - jobs
       - cronjobs
       - statefulsets
```

Generating a `ValidatingAdmissionPolicy` from a `ValidatingPolicy` provides the benefits of faster and more resilient execution during admission controls while leveraging all features of Kyverno.

Refer to the [API Reference](https://htmlpreview.github.io/?https://github.com/kyverno/kyverno/blob/release-1.14/docs/user/crd/index.html#policies.kyverno.io/v1alpha1.AutogenConfiguration) for details.

## Policy Scope

ValidatingPolicy comes in both cluster-scoped and namespaced versions:

- **`ValidatingPolicy`**: Cluster-scoped, applies to resources across all namespaces
- **`NamespacedValidatingPolicy`**: Namespace-scoped, applies only to resources within the same namespace

Both policy types have identical functionality and field structure. The only difference is the scope of resource selection.

### Example NamespacedValidatingPolicy

```yaml
apiVersion: policies.kyverno.io/v1alpha1
kind: NamespacedValidatingPolicy
metadata:
  name: check-deployment-replicas
  namespace: production
spec:
  validationActions:
    - Deny
  matchConstraints:
    resourceRules:
    - apiGroups: ["apps"]
      apiVersions: ["v1"]
      operations: [CREATE, UPDATE]
      resources: ["deployments"]
  validations:
    - message: "deployments must have at least 2 replicas for high availability"
      expression: "object.spec.replicas >= 2"
```

As the name suggests, the `NamespacedValidatingPolicy` allows namespace owners to manage validation policies without requiring cluster-admin permissions, improving multi-tenancy and security isolation.

## Kyverno CEL Libraries

Kyverno enhances Kubernetes' CEL environment with libraries enabling complex policy logic and advanced features. For comprehensive documentation of all available CEL libraries, see the [CEL Libraries documentation](/docs/policy-types/cel-libraries/).

## Exceptions

Policies are applied cluster-wide by default. However, there may be times when an exception is required. In such cases, the [PolicyException](/docs/exceptions/_index.md#policyexceptions-with-cel-expressions) can be used to allow select resources to bypass the policy, without modifying the policies themselves. This ensures that your policies remain secure while providing the flexibility to grant exceptions as needed.

## JSON Payloads

The Kyverno ValidatingPolicy can be applied to any JSON payload. Here is an example of a policy that can be applied to a Terraform plan, and ensures that EKS clusters do not expose a public endpoint: 

```yaml
apiVersion: policies.kyverno.io/v1alpha1
kind: ValidatingPolicy
metadata:
  name: check-public-endpoint
spec:
  evaluation:
    mode: JSON
  matchConditions:
    - name: is-terraform-plan
      expression: "has(object.planned_values) && has(object.terraform_version)"
    - name: has-eks-cluster
      expression: |
        has(object.planned_values) && 
          (has(object.planned_values.root_module) && has(object.planned_values.root_module.child_modules) &&
           object.planned_values.root_module.child_modules.exists(m, 
             has(m.resources) && m.resources.exists(r, r.type == 'aws_eks_cluster')))
  validations:
    - message: "Public access to EKS cluster endpoint must be set to false"
      expression: |
        (
          (!has(object.planned_values.root_module.child_modules) ||
           object.planned_values.root_module.child_modules.all(module,
             !has(module.resources) ||
             module.resources.filter(r, r.type == 'aws_eks_cluster').all(cluster,
               !has(cluster.values.vpc_config) ||
               cluster.values.vpc_config.all(vpc,
                 !has(vpc.endpoint_public_access) || vpc.endpoint_public_access == false
               )
             )
           ))
        )
```

***To write a policy for JSON payloads:***
1. Set `spec.evaluation.mode` to `JSON`.
2. Next, define a `spec.matchConditions` with CEL expressions to tell the engine which payloads should be matched. 
3. Finally, define your validation rules in `spec.validations`.

To evaluate JSON policies, use the [Kyverno CLI](../../kyverno-cli/). 

A Kyverno Engine SDK is planned for a subsequent release.

## Reporting Details in ValidatingPolicy

When a ValidatingPolicy is evaluated, the results are recorded in PolicyReports. PolicyReports are standard Kubernetes custom resources that summarize the outcomes of policy evaluations, including whether resources passed or failed validation.

Kyverno provides additional fields in ValidatingPolicy rules to make PolicyReports more informative and contextual. Two important features are:

### Using auditAnnotations to add custom data

The auditAnnotations field allows attaching custom key-value data to the results stored in PolicyReports. These values can be static strings or dynamic expressions using [CEL (Common Expression Language)](/docs/policy-types/cel-libraries/)
.

This is useful for adding metadata such as severity, team ownership, or any resource-specific values that help consumers of the PolicyReport better understand and act on violations.

***Example Policy:***

```yaml
apiVersion: policies.kyverno.io/v1alpha1
kind: ValidatingPolicy
metadata:
  name: check-deployment-labels
spec:
  auditAnnotations:
    - key: team
      valueExpression: "platform" 
  matchConstraints:
    resourceRules:
    - apiGroups:   [apps]
      apiVersions: [v1]
      operations:  [CREATE, UPDATE]
      resources:   [deployments]
  variables:
    - name: environment
      expression: >-
        has(object.metadata.labels) && 'env' in object.metadata.labels && object.metadata.labels['env'] == 'prod'
  validations:
    - expression: >-
        variables.environment == true
      message: >-
        Deployment labels must be env=prod
```

***Example Deployment:***
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
    env: prod
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:latest
```

***Resulting PolicyReport entry:***

```bash
# Example: Add PolicyReport output here
```

### Using messageExpression to generate dynamic messages

While the message field provides a static failure message, messageExpression allows you to dynamically build messages using CEL expressions. This produces more contextual and precise failure descriptions.

If both message and messageExpression are defined, the messageExpression takes precedence.

The expression must evaluate to a string.

If the expression fails or produces an invalid string (empty, whitespace-only, or multi-line), Kyverno falls back to the static message.

***Example Policy:***

```yaml
apiVersion: policies.kyverno.io/v1alpha1
kind: ValidatingPolicy
metadata:
  name: check-deployment-labels
  annotations:
    policies.kyverno.io/title: Check Deployment Labels
    policies.kyverno.io/category: Other
    policies.kyverno.io/severity: medium
spec:
  validationActions: 
   - Audit
  matchConstraints:
    resourceRules:
    - apiGroups:   [apps]
      apiVersions: [v1]
      operations:  [CREATE, UPDATE]
      resources:   [deployments]
  variables:
    - name: environment
      expression: >-
        has(object.metadata.labels) && 'env' in object.metadata.labels && object.metadata.labels['env'] == 'prod'
  validations:
    - expression: >-
        variables.environment == true
      messageExpression: >-
        'Deployment labels must be env=prod' + (has(object.metadata.labels) && 'env' in object.metadata.labels ? ' but found env=' + string(object.metadata.labels['env']) : ' but no env label is present')
```
***Example Resource Deployment:***

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: bad-deployment
  labels:
    app: nginx
    env: testing
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:latest
```

***Resulting PolicyReport entry:***

```yaml
apiVersion: v1
items:
- apiVersion: wgpolicyk8s.io/v1alpha2
  kind: PolicyReport
  metadata:
    generation: 1
    labels:
      app.kubernetes.io/managed-by: kyverno
    ownerReferences:
    - apiVersion: apps/v1
      kind: Deployment
      name: no-env
  results:
  - category: Other
    message: Deployment labels must be env=prod but no env label is present
    policy: check-deployment-labels
    result: fail
    scored: true
    severity: medium
    source: KyvernoValidatingPolicy
  scope:
    apiVersion: apps/v1
    kind: Deployment
    name: no-env
  summary:
    error: 0
    fail: 1
    pass: 0
    skip: 0
    warn: 0
```