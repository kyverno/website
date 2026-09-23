---
date: 2026-05-24
title: MutatingPolicy - Fix Resources Automatically Before They Enter Your Cluster
tags:
  - General
authors:
  - name: Kirti Goyal
excerpt: A practical guide to MutatingPolicy in Kyverno. Automatically adding defaults,fixing missing configs, and enriching resources before Kubernetes stores them.
draft: true
---

There's a frustrating pattern that platform teams run into constantly: a developer
deploys something, it gets blocked by a ValidatingPolicy, they fix it, redeploy, get
blocked again for something else, fix that too. Back and forth. Everyone's annoyed.

MutatingPolicy solves a different part of that problem. Instead of blocking resources
that don't meet the rules, it quietly fixes them before they ever reach Kubernetes.
The developer deploys and Kyverno adds what's missing. Kubernetes stores a compliant
resource and nobody gets blocked.

## How MutatingPolicy fits into the picture

Mutating admission controllers run before validating admission controllers. So a common pattern in real clusters is:

1. MutatingPolicy runs first and adds missing labels, sets default resource limits,
   injects security settings
2. ValidatingPolicy runs after that and checks that everything meets the rules

The developer applies a Pod with no labels. The MutatingPolicy adds them. ValidatingPolicy
sees the labels and passes the resource. In this way, the developer never gets blocked, and the cluster stays compliant.

## The anatomy of a MutatingPolicy

```yaml
apiVersion: policies.kyverno.io/v1
kind: MutatingPolicy
metadata:
  name: your-policy-name
spec:
  matchConstraints:
    resourceRules:
      - apiGroups: ['']
        apiVersions: ['v1']
        operations: ['CREATE', 'UPDATE']
        resources: ['pods']
  matchConditions:
    - name: condition-name
      expression: '!has(object.metadata.labels)' # only run if this is true
  mutations:
    - patchType: ApplyConfiguration # or JSONPatch
      applyConfiguration:
        expression: >
          Object{
            metadata: Object.metadata{
              labels: Object.metadata.labels{
                team: "platform"
              }
            }
          }
```

Three things to understand before looking at examples:

- `matchConditions`: This is optional but important. It's a pre-filter. The mutation only
  runs if this expression is true. Without it, the mutation runs on every matching
  resource unconditionally. You can use it to avoid overwriting things that are already set.

- `patchType: ApplyConfiguration`: This is the merge approach. You describe what the object
  should look like, Kyverno merges it in. It's easier to read and works well for most mutations.

- `patchType: JSONPatch`: This is the surgical approach. You Specify exact operations at exact paths. It gives more precise control and complexity. Use this when the merge approach isn't enough.

## Use case 1: Add a default label

The most common mutation. For example, every Pod should have a `team` label, but developers forget.
So, instead of blocking them, you can just add it automatically. But only if it's missing.

```yaml
apiVersion: policies.kyverno.io/v1
kind: MutatingPolicy
metadata:
  name: add-team-label
spec:
  matchConstraints:
    resourceRules:
      - apiGroups: ['']
        apiVersions: ['v1']
        operations: ['CREATE', 'UPDATE']
        resources: ['pods']
  matchConditions:
    - name: team-label-missing
      expression: '!has(object.metadata.labels) || !has(object.metadata.labels.team)'
  mutations:
    - patchType: ApplyConfiguration
      applyConfiguration:
        expression: >
          Object{
            metadata: Object.metadata{
              labels: Object.metadata.labels{
                team: "platform"
              }
            }
          }
```

**Try it:**

Apply the policy:

```bash
kubectl apply -f add-team-label.yaml
```

Create a Pod without the label:

```bash
kubectl run nginx --image=nginx
```

Check what labels the Pod has:

```bash
kubectl get pod nginx --show-labels
```

Expected output:

```text
NAME    READY   STATUS    RESTARTS   AGE   LABELS
nginx   1/1     Running   0          5s    team=platform
```

Here, Kyverno added the label silently. The Pod was never blocked.

Now try creating a Pod that already has a team label:

```bash
kubectl run redis --image=redis -l team=backend
```

```bash
kubectl get pod redis --show-labels
```

Expected output:

```text
NAME    READY   STATUS    RESTARTS   AGE   LABELS
redis   1/1     Running   0          5s    team=backend
```

Here, the existing label was left alone. The `matchCondition` made sure the mutation only
ran when the label was actually missing.

## Use case 2: Set default resource limits

Pods without resource limits can consume unlimited CPU and memory. This mutation adds default limits to any container that doesn't define them.

```yaml
apiVersion: policies.kyverno.io/v1
kind: MutatingPolicy
metadata:
  name: set-default-resource-limits
spec:
  matchConstraints:
    resourceRules:
      - apiGroups: ['']
        apiVersions: ['v1']
        operations: ['CREATE']
        resources: ['pods']
  matchConditions:
    - name: missing-limits
      expression: >
        object.spec.containers.exists(c,
          !has(c.resources) || !has(c.resources.limits)
        )
  mutations:
    - patchType: ApplyConfiguration
      applyConfiguration:
        expression: >
          Object{
            spec: Object.spec{
              containers: object.spec.containers.map(c,
                !has(c.resources) || !has(c.resources.limits) ?
                Object.spec.containers{
                  name: c.name,
                  resources: Object.spec.containers.resources{
                    limits: Object.spec.containers.resources.limits{
                      cpu: "500m",
                      memory: "128Mi"
                    }
                  }
                } : c
              )
            }
          }
```

The `map()` function iterates through every container in the Pod. For each one, if
limits are missing, it adds the defaults. If limits are already set, it leaves them
exactly as they are.

## Use case 3: Inject security settings into every container

Security contexts are easy to forget and tedious to add manually to every container.
This mutation adds `allowPrivilegeEscalation: false` to every container automatically.

```yaml
apiVersion: policies.kyverno.io/v1
kind: MutatingPolicy
metadata:
  name: set-security-context
spec:
  matchConstraints:
    resourceRules:
      - apiGroups: ['']
        apiVersions: ['v1']
        operations: ['CREATE', 'UPDATE']
        resources: ['pods']
  mutations:
    - patchType: ApplyConfiguration
      applyConfiguration:
        expression: >
          Object{
            spec: Object.spec{
              containers: object.spec.containers.map(container,
                Object.spec.containers{
                  name: container.name,
                  securityContext: Object.spec.containers.securityContext{
                    allowPrivilegeEscalation: false
                  }
                }
              )
            }
          }
```

Every container in every Pod automatically gets `allowPrivilegeEscalation: false`,
without any developer having to remember to add it. The platform team defines the policy once, and every new Pod gets the same security defaults automatically.

## Use case 4: Conditional mutation

Sometimes the mutation should behave differently depending on the state of the resource.
In this example, if a Pod already has an `environment` label, just add `managed: true`. If it doesn't have one, add both `environment: dev` and `managed: true`.

```yaml
apiVersion: policies.kyverno.io/v1
kind: MutatingPolicy
metadata:
  name: conditional-labels
spec:
  matchConstraints:
    resourceRules:
      - apiGroups: ['']
        apiVersions: ['v1']
        resources: ['pods']
        operations: ['CREATE', 'UPDATE']
  mutations:
    - patchType: ApplyConfiguration
      applyConfiguration:
        expression: |
          has(object.metadata.labels) && has(object.metadata.labels.environment) ?
          Object{
            metadata: Object.metadata{
              labels: {"managed": "true"}
            }
          } :
          Object{
            metadata: Object.metadata{
              labels: {"environment": "dev", "managed": "true"}
            }
          }
```

Read the `?` as "if" and the `:` as "else." This is a standard CEL ternary. If the environment label exists then add only managed: true. If it doesn't exist, then add both.
Basically, the mutation changes behaviour based on what already exists on the resource.

## ApplyConfiguration vs JSONPatch: when to use which

- **`ApplyConfiguration`** is the right choice for most mutations. You describe the shape
  wanted and Kyverno merges it in. It's readable, straightforward and handles nested fields cleanly.

- **`JSONPatch`** is the right choice when precision is needed. It's like modifying a specific item in an array by index, handling special characters in key names, or performing replace and remove operations.

Here's the same label mutation written as JSONPatch:

```yaml
mutations:
  - patchType: JSONPatch
    jsonPatch:
      expression: |
        has(object.metadata.labels) ?
        [
          JSONPatch{
            op: "add",
            path: "/metadata/labels/team",
            value: "platform"
          }
        ] :
        [
          JSONPatch{
            op: "add",
            path: "/metadata/labels",
            value: {"team": "platform"}
          }
        ]
```

> Notice the condition is required here, if the labels field doesn't exist yet, the path
> `/metadata/labels/team` would error. JSONPatch needs explicit handling for cases where
> the parent field might not exist. ApplyConfiguration handles this automatically.

## Mutating existing resources

By default, `MutatingPolicy` only runs at admission. When a resource is being created or
updated. But what about resources that were deployed before the policy existed? For that you can enable background mutation with `mutateExisting`:

```yaml
spec:
  evaluation:
    mutateExisting:
      enabled: true
  matchConstraints:
    resourceRules:
      - apiGroups: ['']
        apiVersions: ['v1']
        operations: ['CREATE', 'UPDATE']
        resources: ['pods']
```

Two important things about `mutateExisting`:

- **It's asynchronous**. There's a delay between when the policy is applied and when
  existing resources get mutated. It doesn't happen instantly.

- **It needs extra RBAC permissions**. Because Kyverno is modifying resources outside of
  the normal admission flow, it needs explicit permission to do so. If mutations aren't
  happening on existing resources, check the Kyverno background controller's permissions.

## Sequential mutations order matters

Multiple mutations can be defined in one policy. They run in order, top to bottom.
This matters when a later mutation depends on what an earlier one added.

```yaml
mutations:
  # First mutation to check if it's a database pod
  - patchType: ApplyConfiguration
    applyConfiguration:
      expression: |
        object.spec.containers.exists(c,
          c.image.contains("postgres") || c.image.contains("mysql")
        ) ?
        Object{
          metadata: Object.metadata{
            labels: {"type": "database"}
          }
        } : Object{}

  # Second mutation: if it's a database pod, add backup label
  - patchType: ApplyConfiguration
    applyConfiguration:
      expression: |
        has(object.metadata.labels) &&
        object.metadata.labels.type == "database" ?
        Object{
          metadata: Object.metadata{
            labels: {"backup": "required"}
          }
        } : Object{}
```

Here, the first mutation checks the image and adds `type: database` if it matches. The second reads that label and adds `backup: required`. The second only works because the first mutation ran first. Keep dependent mutations in the same policy and in the right order.

> Note: Kyverno processes mutations sequentially **within** the same policy.
> Across multiple MutatingPolicies which are targeting the same resource, the order is not deterministic.
> If mutations have dependencies, keep them in the same policy.

## Scoping your policy

Here the pattern is same as ValidatingPolicy:

- `MutatingPolicy`: This is cluster-wide and applies across all namespaces

- `NamespacedMutatingPolicy`: This one is scoped to one namespace and is manageable by namespace owners without cluster-admin permissions

```yaml
apiVersion: policies.kyverno.io/v1
kind: NamespacedMutatingPolicy
metadata:
  name: add-labels
  namespace: production
spec:
  matchConstraints:
    resourceRules:
      - apiGroups: ['']
        apiVersions: ['v1']
        operations: ['CREATE', 'UPDATE']
        resources: ['pods']
  mutations:
    - patchType: ApplyConfiguration
      applyConfiguration:
        expression: >
          Object{
            metadata: Object.metadata{
              labels: Object.metadata.labels{
                environment: "production",
                managed: "true"
              }
            }
          }
```

## How MutatingPolicy and ValidatingPolicy work together

This is the pattern used on real platform teams:

```text
Developer runs kubectl apply
        ↓
MutatingPolicy runs first
  - adds missing team label
  - sets default resource limits
  - injects security context
        ↓
ValidatingPolicy runs second
  - checks team label exists
  - checks resource limits defined
  - checks security context set
        ↓
Resource admitted to cluster
```

So, the developer writes their app YAML. Mutation adds the defaults. Validation confirms
everything meets the rules. Then the resource is admitted. Nobody gets blocked for forgetting something that could just be added automatically.

## Do you want to experiment without a cluster?

Test any of these policies in the browser:
https://playground.kyverno.io/

Paste the policy on one side, paste a Pod spec on the other, and see exactly what
Kyverno would mutate. This is great for working out CEL expressions before applying them to
a real cluster.
