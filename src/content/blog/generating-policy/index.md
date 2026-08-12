---
date: 2026-05-25
title: GeneratingPolicy - Let Kyverno Handle the Setup
tags:
  - General
authors:
  - name: Kirti Goyal
excerpt: A practical guide to GeneratingPolicy in Kyverno like automatically creating NetworkPolicies, syncing Secrets, and bootstrapping namespaces without anyone having to remember a checklist
draft: false
---

Every Kubernetes platform team has some version of this checklist.

"When you create a new namespace, remember to also create a NetworkPolicy, a
ResourceQuota, a RoleBinding, and copy the image pull secret from the default
namespace."

It lives in a wiki. Nobody reads the wiki. Someone creates a namespace, forgets three
of the four things, and two weeks later there's an incident because the NetworkPolicy
was never there.

GeneratingPolicy is what replaces that checklist. Instead of telling people what to
create, the cluster just creates it automatically. Developer creates a namespace and
Kyverno handles the rest.

## How GeneratingPolicy is different from the others

ValidatingPolicy checks resources. MutatingPolicy modifies resources. GeneratingPolicy
creates entirely new resources in response to something happening.

The trigger and the output are completely different things.

```text
Namespace created (trigger)
        ↓
Kyverno detects the event
        ↓
NetworkPolicy created inside that namespace (downstream)
RoleBinding created inside that namespace (downstream)
ResourceQuota created inside that namespace (downstream)
```

One event. Multiple resources. Automatically. Every single time.

## Three key terms to understand

- **Trigger:** The resource that kicks off the generation. It's defined in `matchConstraints`.
  When a resource matching these rules appears, the policy runs.

- **Downstream:** The resource(s) Kyverno creates as a result. These are what gets
  generated.

- **Source:** An existing resource used as a template for cloning. Fetched using
  `resource.Get()` or `resource.List()`.

## The anatomy of a GeneratingPolicy

```yaml
apiVersion: policies.kyverno.io/v1
kind: GeneratingPolicy
metadata:
  name: your-policy-name
spec:
  evaluation:
    synchronize:
      enabled: true # it keeps generated resources in sync with the policy
  matchConstraints:
    resourceRules:
      - apiGroups: ['']
        apiVersions: ['v1']
        operations: ['CREATE']
        resources: ['namespaces'] # the trigger
  variables:
    - name: nsName
      expression: 'object.metadata.name' # capture the trigger's name
  generate:
    - expression: generator.Apply(variables.nsName, [downstream resource])
```

The `generator.Apply()` function is what actually creates the downstream resource.
It takes two arguments: the target namespace and a list of resources to create there.

## Use case 1: Generate a NetworkPolicy for every new namespace

In a new namespace, when there is no NetworkPolicy. Pods can talk to anything. That's a security problem.
This policy fixes it automatically.

```yaml
apiVersion: policies.kyverno.io/v1
kind: GeneratingPolicy
metadata:
  name: default-deny-networkpolicy
spec:
  evaluation:
    synchronize:
      enabled: true
  matchConstraints:
    resourceRules:
      - apiGroups: ['']
        apiVersions: ['v1']
        operations: ['CREATE']
        resources: ['namespaces']
  variables:
    - name: nsName
      expression: 'object.metadata.name'
    - name: downstream
      expression: >-
        [
          {
            "kind": dyn("NetworkPolicy"),
            "apiVersion": dyn("networking.k8s.io/v1"),
            "metadata": dyn({
              "name": "default-deny-all",
              "namespace": string(variables.nsName)
            }),
            "spec": dyn({
              "podSelector": dyn({}),
              "policyTypes": dyn(["Ingress", "Egress"])
            })
          }
        ]
  generate:
    - expression: generator.Apply(variables.nsName, variables.downstream)
```

**Try it:**

Apply the policy:

```bash
kubectl apply -f default-deny-networkpolicy.yaml
```

Create a new namespace:

```bash
kubectl create namespace my-team
```

Check what's inside it:

```bash
kubectl get networkpolicy -n my-team
```

Expected output:

```text
NAME               POD-SELECTOR   AGE
default-deny-all   <none>         2s
```

Kyverno created the NetworkPolicy inside the namespace automatically. Nobody had to
remember to do it.

## Use case 2: Clone a Secret across namespaces

Image pull secrets are a constant headache. The secret lives in `default`. Every new
namespace needs a copy of it. Without automation, someone has to manually copy it every time
and then keep it in sync when the secret rotates.

```yaml
apiVersion: policies.kyverno.io/v1
kind: GeneratingPolicy
metadata:
  name: clone-pull-secret
spec:
  evaluation:
    synchronize:
      enabled: true
  matchConstraints:
    resourceRules:
      - apiGroups: ['']
        apiVersions: ['v1']
        operations: ['CREATE', 'UPDATE']
        resources: ['namespaces']
  variables:
    - name: nsName
      expression: 'object.metadata.name'
    - name: source
      expression: resource.Get("v1", "secrets", "default", "regcred")
  generate:
    - expression: generator.Apply(variables.nsName, [variables.source])
```

`resource.Get()` fetches the existing `regcred` secret from the `default` namespace.
`generator.Apply()` creates a copy of it in the new namespace.

With `synchronize: true`, if the source secret is updated, all the copies get updated
too. If the source is deleted, the copies get deleted. The downstream resources stay
in sync with the original automatically.

**Try it:**

First create a test secret in the default namespace:

```bash
kubectl -n default create secret docker-registry regcred \
  --docker-server=myregistry.io \
  --docker-username=myuser \
  --docker-password=mypassword
```

Apply the policy:

```bash
kubectl apply -f clone-pull-secret.yaml
```

Create a new namespace:

```bash
kubectl create namespace new-team
```

Check if the secret was cloned:

```bash
kubectl get secret regcred -n new-team
```

Expected output:

```text
NAME      TYPE                             DATA   AGE
regcred   kubernetes.io/dockerconfigjson   1      3s
```

## Use case 3: Full namespace bootstrap

This is the real power of GeneratingPolicy. One trigger, everything a namespace needs,
created automatically.

```yaml
apiVersion: policies.kyverno.io/v1
kind: GeneratingPolicy
metadata:
  name: namespace-bootstrap
spec:
  evaluation:
    synchronize:
      enabled: true
  matchConstraints:
    resourceRules:
      - apiGroups: ['']
        apiVersions: ['v1']
        operations: ['CREATE']
        resources: ['namespaces']
  variables:
    - name: nsName
      expression: 'object.metadata.name'
    - name: downstream
      expression: >-
        [
          {
            "kind": dyn("ResourceQuota"),
            "apiVersion": dyn("v1"),
            "metadata": dyn({
              "name": "default-quota",
              "namespace": string(variables.nsName)
            }),
            "spec": dyn({
              "hard": dyn({
                "pods": "20",
                "requests.cpu": "4",
                "requests.memory": "8Gi",
                "limits.cpu": "8",
                "limits.memory": "16Gi"
              })
            })
          },
          {
            "kind": dyn("NetworkPolicy"),
            "apiVersion": dyn("networking.k8s.io/v1"),
            "metadata": dyn({
              "name": "default-deny-all",
              "namespace": string(variables.nsName)
            }),
            "spec": dyn({
              "podSelector": dyn({}),
              "policyTypes": dyn(["Ingress", "Egress"])
            })
          }
        ]
  generate:
    - expression: generator.Apply(variables.nsName, variables.downstream)
```

In this case, there is one policy. Two resources are created per namespace. You can add more to the list as needed like RoleBindings, ConfigMaps, LimitRanges. The developer creates a namespace and walks away. Everything is already there.

## Use case 4: Apply to existing namespaces too

By default, GeneratingPolicy only runs for resources created after the policy is
applied. Namespaces that already exist won't get the generated resources.
To fix that, enable `generateExisting`:

```yaml
spec:
  evaluation:
    generateExisting:
      enabled: true # run against existing resources when the policy is created
    synchronize:
      enabled: true
```

When this policy is applied to a cluster with 10 existing namespaces, Kyverno
immediately generates the downstream resources in all 10. Without this, only new
namespaces created after the policy would get them.

## Use case 5: Looping: generate resources across multiple namespaces

Sometimes the trigger isn't a namespace rather it's a ConfigMap that contains a list of
namespaces. This is a pattern platform teams use to manage which namespaces should
receive certain resources.

```yaml
apiVersion: policies.kyverno.io/v1
kind: GeneratingPolicy
metadata:
  name: generate-network-policy
spec:
  matchConstraints:
    resourceRules:
      - apiGroups: ['']
        apiVersions: ['v1']
        operations: ['CREATE']
        resources: ['configmaps']
  variables:
    - name: nsList
      expression: "object.data.namespaces.split(',')"
    - name: downstream
      expression: >-
        [
          {
            "kind": dyn("NetworkPolicy"),
            "apiVersion": dyn("networking.k8s.io/v1"),
            "metadata": dyn({
              "name": "default-deny-all"
            }),
            "spec": dyn({
              "podSelector": dyn({}),
              "policyTypes": dyn(["Ingress", "Egress"])
            })
          }
        ]
  generate:
    - expression: >
        variables.nsList.all(ns, generator.Apply(ns, variables.downstream))
```

The ConfigMap's `data.namespaces` field contains a comma-separated list like
`"ns1,ns2,ns3"`. Kyverno reads the namespace list from the ConfigMap, iterates through each entry, and creates the NetworkPolicy in every matching namespace.

Create the trigger **ConfigMap** to test it:

```bash
kubectl create configmap team-namespaces \
  --from-literal=namespaces="team-a,team-b,team-c"
```

Check if the NetworkPolicy was created in each namespace:

```bash
kubectl get networkpolicy -n team-a
kubectl get networkpolicy -n team-b
kubectl get networkpolicy -n team-c
```

## Synchronization (what actually happens when things change)

This is what makes GeneratingPolicy genuinely useful on real clusters rather than just
a one-time setup tool.

With `synchronize: true`:

| What happens                                    | Effect                               |
| ----------------------------------------------- | ------------------------------------ |
| Someone manually deletes the generated resource | Kyverno recreates it                 |
| The policy is updated                           | All downstream resources are updated |
| The trigger namespace is deleted                | The downstream resources are deleted |
| The source secret is updated (clone mode)       | All copies are updated               |

Without `synchronize: true`, generated resources are only created once. Changes or deletions after that are not automatically reconciled.

For most real use cases, `synchronize: true` is what you want.

One useful escape hatch: `orphanDownstreamOnPolicyDelete`. If this is set to `true`,
deleting the policy leaves the downstream resources alive instead of cleaning them up.
This is useful when migrating policies without losing the resources they created.

```yaml
spec:
  evaluation:
    synchronize:
      enabled: true
    orphanDownstreamOnPolicyDelete:
      enabled: true # generated resources survive policy deletion
```

## Scoping your policy

Same pattern as the other policy types:

- `GeneratingPolicy`: cluster-wide, runs across all namespaces
- `NamespacedGeneratingPolicy`: scoped to one namespace and manageable without
  cluster-admin permissions

```yaml
apiVersion: policies.kyverno.io/v1
kind: NamespacedGeneratingPolicy
metadata:
  name: clone-secret
  namespace: production
spec:
  matchConstraints:
    resourceRules:
      - apiGroups: ['']
        apiVersions: ['v1']
        operations: ['CREATE']
        resources: ['pods']
  variables:
    - name: nsName
      expression: 'object.metadata.namespace'
    - name: source
      expression: resource.Get("v1", "secrets", "production", "regcred")
  generate:
    - expression: generator.Apply(variables.nsName, [variables.source])
```

## Want to experiment without a cluster?

Test any GeneratingPolicy in the browser:
https://playground.kyverno.io
