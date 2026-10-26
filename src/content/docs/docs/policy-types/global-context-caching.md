---
title: Global Context Caching
excerpt: Cache Kubernetes resources and external API data globally to speed up policy evaluation at scale.
sidebar:
  order: 105
---

# Global Context Caching

By centralizing and pre-fetching heavy datasets, multiple policies can evaluate
incoming mutation, validation, or generation requests using
`globalContext.Get()` in a CEL expression. Store the result in a policy
variable and reference it through `variables.<name>`.

> **HA Note:** In high-availability deployments, each Kyverno replica maintains
> its own independent in-memory cache. Admission requests may be served by
> different replicas whose cache freshness can differ slightly between refresh
> cycles. This is expected behavior — design your policies to tolerate this
> per-replica eventual consistency.

---

## Prerequisites

Before configuring a `GlobalContextEntry`, ensure the following:

- **Kyverno >= 1.12.0** is installed in your cluster (`GlobalContextEntry`
  was introduced in this release). Verify your version with:

  ```bash
  # Linux/macOS
  kubectl get deployment -n kyverno -o jsonpath='{range .items[*]}{.metadata.name}{": "}{.spec.template.spec.containers[0].image}{"\n"}{end}'

  # Windows PowerShell
  kubectl get deployment -n kyverno -o jsonpath="{range .items[*]}{.metadata.name}{': '}{.spec.template.spec.containers[0].image}{'\n'}{end}"
  ```

- **kubectl** access with sufficient permissions to create cluster-scoped resources.
- **Kyverno ServiceAccount RBAC:** For `kubernetesResource` mode, the Kyverno
  ServiceAccount must have `get`, `list`, and `watch` permissions on the target
  resource. This is especially important for custom resources (CRs).

> **API Version Note:** `GlobalContextEntry` uses `apiVersion: kyverno.io/v2`.
> The older `kyverno.io/v2alpha1` version is deprecated, but the `GlobalContextEntry`
> resource itself is fully supported and is not being deprecated — it continues to
> work with the CEL-based policy types.

### Granting RBAC Permissions for Custom Resources (CRs)

If you are caching a **custom resource (CR)** served by a CRD — for example,
a resource from a custom API group — append a rule to Kyverno's existing
ClusterRole using a JSON patch:

```bash
  # Linux/macOS
  kubectl patch clusterrole kyverno:admission-controller --type=json --patch '[{"op":"add","path":"/rules/-","value":{"apiGroups":["your.crd.group"],"resources":["yourresources"],"verbs":["get","list","watch"]}}]'
```

```powershell
  # Windows PowerShell
  kubectl patch clusterrole kyverno:admission-controller --type=json --patch '[{"op":"add","path":"/rules/-","value":{"apiGroups":["your.crd.group"],"resources":["yourresources"],"verbs":["get","list","watch"]}}]'
```

> **Note:** Replace `your.crd.group` and `yourresources` with your actual
> CRD API group and resource name (lowercased, pluralized). This appends
> to the existing rules without overwriting them. Standard resources like
> `configmaps` and `secrets` already have permissions by default — no
> patch needed.

---

## Concept & Architecture: The "Why"

```mermaid
graph TD
    subgraph "Standard Policy Evaluation"
        A[Incoming Request] --> B{Inline API Call}
        B -->|Wait| C[API Server / External Service]
        C -->|Latency| D[Evaluation Result]
    end

    subgraph "GlobalContextEntry"
        E[Background Worker] -->|Fetch| F[Global Memory Cache]
        G[Incoming Request] -->|Read| F
        F -->|near 0 ms Latency| H[Evaluation Result]
    end
```

Kyverno operates natively as a Kubernetes Admission Controller webhook. When a resource lifecycle event occurs (e.g., `kubectl apply`), Kyverno intercepts the request and must determine whether to allow or deny it with minimal latency.

### The Problem: Reactive Inline Lookup Bottlenecks

When a policy requires data outside the immediate admission review payload, such as an allowed registry list stored in a ConfigMap, it can use the CEL [resource library](/docs/policy-types/cel-libraries#resource-library) or [HTTP library](/docs/policy-types/cel-libraries#http-library) for an inline lookup.

Under high cluster density, if a continuous integration or continuous deployment (CI/CD) engine (e.g., Argo CD or Flux) executes a massive batch deployment of 200 microservices simultaneously:

- Kyverno is forced to instantiate **200 separate, concurrent network calls** to the Kubernetes API server or target external webhooks to retrieve identical tracking data.
- This scenario creates severe internal network latency spikes, induces heavy connection-throttling at the API server layer, and heavily balloons cluster CPU utilization, occasionally prompting admission timeouts.

### The Solution: Global Memory Caching

`GlobalContextEntry` decouples the policy execution pathway from external network dependencies entirely.

Instead of executing real-time fetches during admission evaluation, Kyverno delegates resource
tracking to an asynchronous background worker loop:

1. **Background Collection:** Kyverno queries the designated cluster resource or external target once, building a localized memory structure.
2. **Deterministic Refreshing:** For `apiCall` mode, Kyverno polls the target at user-configured `refreshInterval` intervals. For `kubernetesResource` mode, Kyverno uses Kubernetes watch/informer mechanisms to automatically track resource changes without polling.
3. **Instant Lookup Execution:** When the same batch of 200 microservices triggers policy evaluations, Kyverno serves the evaluation data directly out of local RAM cache. Network overhead drops to near 0 ms, ensuring horizontal stability at massive organizational scales.

---

## Getting Started

The fastest way to use `GlobalContextEntry` is a two-step process: define a cache entry, then reference it in a policy.

### Step 1: Create a GlobalContextEntry

```yaml
apiVersion: kyverno.io/v2
kind: GlobalContextEntry
metadata:
  name: my-first-cache
spec:
  kubernetesResource:
    group: ''
    version: v1
    resource: configmaps
    namespace: default
```

### Step 2: Reference it in a Policy

```yaml
spec:
  variables:
    - name: cachedConfigmaps
      expression: globalContext.Get("my-first-cache", "")
```

`variables.cachedConfigmaps` is now available to CEL expressions without an inline API call. See the [complete policy example](#step-2-bind-a-policy-to-the-entry) and [Configuration Modes](#configuration-modes).

---

## Configuration Modes

A `GlobalContextEntry` must set exactly one of the following mutually exclusive
source fields:

- `kubernetesResource`: Monitors and maps native objects living within the cluster.
- `apiCall`: Polls external endpoints or performs structured internal HTTP interactions.

Optionally, either mode can also include a `projections` block to pre-filter
the cached data using JMESPath before policies consume it.

### 1. Kubernetes Resource Caching

Use this mode to capture internal topology data, structural metadata, or shared configuration boundaries (e.g., `ConfigMaps`, `Namespaces`, or custom resource configurations).

| Schema Field | Value Data Type | Required    | Engine Validation Constraints                                                                                                                                                                                                                                                     |
| :----------- | :-------------- | :---------- | :-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `group`      | string          | Conditional | The Kubernetes API group (e.g., `apps`). Required for non-core resources. Use an empty string `""` **only when `version` is also `v1`** — this is the only valid core API combination. Any other pairing (e.g., `group: ""` with `version: v1beta1`) will fail schema validation. |
| `version`    | string          | **Yes**     | The explicit API version state (e.g., `v1`, `v1beta1`).                                                                                                                                                                                                                           |
| `resource`   | string          | **Yes**     | **Must be lowercased and pluralized** (e.g., use `configmaps` or `secrets`, not `ConfigMap`).                                                                                                                                                                                     |
| `namespace`  | string          | No          | The target namespace boundaries. If omitted, Kyverno tracks across **all namespaces** globally.                                                                                                                                                                                   |

> **Important:** Ensure the Kyverno ServiceAccount has the necessary RBAC
> permissions (`get`, `list`, `watch`) for the resources you are caching,
> especially when tracking custom resources (CRs).

#### Syntax Example: Local ConfigMap Tracking

```yaml
apiVersion: kyverno.io/v2
kind: GlobalContextEntry
metadata:
  name: configmap-cache
spec:
  kubernetesResource:
    group: ''
    version: v1
    resource: configmaps
    namespace: default
```

### 2. External API Caching

Use this mode to extract and synchronize authorization lists, identity definitions, or operational constraints managed outside the local Kubernetes ecosystem.

| Schema Field      | Default Value | Engine Validation Constraints                                                                   |
| :---------------- | :------------ | :---------------------------------------------------------------------------------------------- |
| `urlPath`         | —             | Path for querying the **local Kubernetes API server**. Mutually exclusive with `service.url`.   |
| `service.url`     | —             | Full URL for **external endpoints**. Mutually exclusive with `urlPath`.                         |
| `refreshInterval` | `10m`         | Background polling cadence. Accepts duration strings (e.g., `30s`, `5m`, `2h`). Must be > `0s`. |
| `retryLimit`      | `3`           | Max retry attempts before the sync loop errors. Minimum value is `1`.                           |
| `method`          | `GET`         | HTTP method. **Must be explicitly set to `POST`** if a `data` payload array is provided.        |

> **Method Enforcement:** If your `apiCall` profile passes a custom request payload under the `data` array parameter, the underlying HTTP schema engine enforces that the `method` parameter **must be explicitly configured as POST**.

#### Syntax Example: External Metadata Ingestion

```yaml
apiVersion: kyverno.io/v2
kind: GlobalContextEntry
metadata:
  name: corporate-teams-cache
spec:
  apiCall:
    service:
      url: 'https://api.internal.corporate/v1/teams'
    refreshInterval: 5m
    retryLimit: 5
```

## Data Projections (JMESPath Slicing)

Caching large-scale external API payloads or extensive multi-namespace collections inside memory can stress system overhead. Kyverno supports `projections` using **JMESPath** so policies can work with a narrower, more focused view of that cached data.

> **Note on API Sources:**
>
> - Use `urlPath` when querying the **local Kubernetes API server** (e.g., fetching internal cluster resources).
> - Use `service.url` when targeting **external endpoints** (e.g., external inventory or security services).

> These two fields are **mutually exclusive** — only one may be defined per `apiCall` entry.

Projections act as a high-performance filtering layer, transforming raw complex structures into exact key-value primitives or explicit string arrays for policy consumption. This helps simplify policy evaluation and reduce the amount of data rules need to traverse, but it does not necessarily remove the underlying cached payload.

> **Important:** The `name` of each projection must be different from the
> `GlobalContextEntry`'s own `metadata.name`. Using the same name will fail
> schema validation with: `"A projection entry requires a name different from
the global context entry name"`.
>
> Example — if your entry is named `my-k8s-cached-data`, your projection name
> cannot also be `my-k8s-cached-data`. Use a descriptive sub-name like
> `config-names` instead.

Projections work with both `urlPath` (Kubernetes API server) and `service.url`
(external endpoints). Here are both forms:

**For Kubernetes API server responses** — use `urlPath`:

```yaml
apiVersion: kyverno.io/v2
kind: GlobalContextEntry
metadata:
  name: my-k8s-cached-data
spec:
  apiCall:
    urlPath: '/api/v1/namespaces/default/configmaps'
  projections:
    - name: config-names
      jmesPath: 'items[].metadata.name'
```

**For external endpoint responses** — use `service.url`:

```yaml
apiVersion: kyverno.io/v2
kind: GlobalContextEntry
metadata:
  name: my-external-cached-data
spec:
  apiCall:
    service:
      url: 'https://api.internal.corporate/v1/teams'
    refreshInterval: 5m
  projections:
    - name: team-ids
      jmesPath: 'teams[].id'
```

> `urlPath` and `service.url` are **mutually exclusive** — only one may be
> defined per `apiCall` entry. Use `urlPath` for in-cluster Kubernetes API
> resources and `service.url` for all external HTTP endpoints.

### Referencing Cached Data in a Policy

Reference a `GlobalContextEntry` using `globalContext.Get()`. The first argument names the entry, and the second names a projection defined in that entry. Use an empty string to retrieve the full cached payload, then filter it using CEL:

```yaml
spec:
  variables:
    - name: configmapNames
      expression: globalContext.Get("shared-config-cache", "").map(cm, cm.metadata.name)
```

> **JMESPath shape reminder:**
>
> - `kubernetesResource` mode → use `[].metadata.name`
> - `apiCall.urlPath` mode → use `items[].metadata.name`

If you defined `projections` in your `GlobalContextEntry` spec, pass the projection name as the second argument:

```yaml
spec:
  variables:
    - name: configmapNames
      expression: globalContext.Get("my-k8s-cached-data", "config-names")
```

## Eventual Consistency & Operational Notes

**Eventual Consistency:** Caches are updated asynchronously. Policy evaluations may briefly use slightly stale data between refresh cycles. Design your policy logic to tolerate this window, particularly for rapidly changing resources.

**Production Security — External API Calls:**

- Store credentials in Kubernetes `Secrets`, never hardcoded in the resource spec.
- Ensure all external endpoints are protected with valid TLS certificates.

**Inline Lookup vs. `GlobalContextEntry` — When to Use Which:**

| Feature            | CEL resource or HTTP lookup          | `GlobalContextEntry`                     |
| :----------------- | :----------------------------------- | :--------------------------------------- |
| **Performance**    | High overhead (one call per request) | High performance (served from RAM cache) |
| **Use Case**       | Real-time, volatile data             | Static or slowly changing data           |
| **Scalability**    | Can overwhelm API servers under load | Significantly reduces API server load    |
| **Data Freshness** | Always current                       | Eventually consistent                    |

### Behavior on Cache Failure

If a `GlobalContextEntry` cannot be loaded or refreshed (for example, the external endpoint is unreachable and `retryLimit` is exhausted), policies referencing it via `globalContext.Get()` may encounter an evaluation error until a successful sync occurs.

Monitor `status.conditions` and `status.lastRefreshTime` on the resource, and check Kyverno controller logs for `globalcontext` errors in production clusters.

## Practical Use Cases & Blueprints

### 1. Referencing Shared ConfigMap Data Across Multiple Policies

This scenario caches cluster-wide configuration mappings centrally so multiple running rules can cross-reference them without individual cluster query costs.

#### Step 1: Define the Cache entry

```yaml
apiVersion: kyverno.io/v2
kind: GlobalContextEntry
metadata:
  name: shared-config-cache
spec:
  kubernetesResource:
    group: ''
    version: v1
    resource: configmaps
    namespace: default
```

> **Payload Structure:** The shape of cached data differs by mode:
>
> - **`kubernetesResource` mode** returns an array. In CEL, use `.map(cm, cm.metadata.name)`.
> - **`apiCall.urlPath` mode** returns a Kubernetes API envelope. In CEL, use `.items.map(cm, cm.metadata.name)`.
>
> Inspect the source payload using the commands in [Verification](#verification) before writing expressions.

#### Step 2: Bind a Policy to the Entry

```yaml
apiVersion: policies.kyverno.io/v1
kind: ValidatingPolicy
metadata:
  name: require-configmap-via-gctx
spec:
  validationActions: [Deny]
  evaluation:
    background:
      enabled: false
  matchConstraints:
    resourceRules:
      - apiGroups: ['apps']
        apiVersions: ['v1']
        operations: ['CREATE', 'UPDATE']
        resources: ['deployments']
  variables:
    - name: configmaps
      expression: globalContext.Get("shared-config-cache", "")
  validations:
    - expression: variables.configmaps.exists(cm, cm.metadata.name == "app-config")
      message: "Required 'app-config' ConfigMap is missing from the cache."
```

### 2. Caching Approved Container Registries (External API)

This implementation ensures cluster deployments pull strictly from vetted, enterprise-controlled image domains stored on an external inventory catalog manager.

#### Step 1: Define the Cache entry

```yaml
apiVersion: kyverno.io/v2
kind: GlobalContextEntry
metadata:
  name: approved-registries-cache
spec:
  apiCall:
    service:
      url: 'https://api.corporate.internal/v1/registries'
    refreshInterval: 30m
    retryLimit: 3
```

#### Step 2: Bind a Policy to the Entry

Assuming the API returns: `{"allowed": ["internal-registry.io", "gcr.io"]}`

```yaml
apiVersion: policies.kyverno.io/v1
kind: ValidatingPolicy
metadata:
  name: restrict-registries-global
spec:
  validationActions: [Deny]
  evaluation:
    background:
      enabled: false
  matchConstraints:
    resourceRules:
      - apiGroups: ['']
        apiVersions: ['v1']
        operations: ['CREATE', 'UPDATE']
        resources: ['pods']
  variables:
    - name: allowedRegistries
      expression: globalContext.Get("approved-registries-cache", "").allowed
  validations:
    - expression: >-
        object.spec.containers.all(container,
          image(container.image).registry() in variables.allowedRegistries)
      message: 'The container image registry is not approved by enterprise security policy.'
```

> **How the registry is extracted:** The CEL [image library](/docs/policy-types/cel-libraries#image-library) parses the image reference and returns its registry hostname.
>
> Ensure your `allowed_registries` list contains registry hostnames only
> (e.g., `"internal-registry.io"`, `"gcr.io"`), not full image paths.

### 3. Caching RBAC or Organizational Metadata

Useful for performance-heavy validation structures, like tracking dynamic team metadata roles across specific namespace boundaries.

#### Step 1: Define the Cache entry

```yaml
apiVersion: kyverno.io/v2
kind: GlobalContextEntry
metadata:
  name: rbac-team-cache
spec:
  kubernetesResource:
    group: 'rbac.authorization.k8s.io'
    version: v1
    resource: clusterrolebindings
```

#### Step 2: Bind a Policy to the Entry

```yaml
apiVersion: policies.kyverno.io/v1
kind: ValidatingPolicy
metadata:
  name: validate-team-namespace-access
spec:
  validationActions: [Deny]
  evaluation:
    background:
      enabled: false
  matchConstraints:
    resourceRules:
      - apiGroups: ['']
        apiVersions: ['v1']
        operations: ['CREATE']
        resources: ['namespaces']
  variables:
    - name: bindings
      expression: globalContext.Get("rbac-team-cache", "")
  validations:
    - expression: >-
        variables.bindings.exists(binding,
          has(binding.subjects) && binding.subjects.exists(subject,
            subject.kind == "User" && subject.name == request.userInfo.username))
      message: 'User initiating namespace creation is not registered in cluster role metadata.'
```

## Verification

> **Note:** `gctxentry` is always registered as a short name for `GlobalContextEntry`
> (defined in the Kyverno CRD via `shortName=gctxentry`). You can confirm all
> available Kyverno resource short names on your cluster with:
> `kubectl api-resources | grep kyverno`

```bash
# Linux/macOS
kubectl api-resources | grep kyverno

# Windows
kubectl api-resources | findstr kyverno
```

Use the following steps to confirm your `GlobalContextEntry` is actively syncing
and your policies can consume its data correctly.

### 1. Check Resource Status & Conditions

```bash
kubectl get globalcontextentries <entry-name> -o yaml
```

Look for the `status` block in the output. A healthy entry looks like this:

```yaml
status:
  conditions:
    - type: Ready
      status: 'True'
      reason: Succeeded
      message: 'GlobalContextEntry synced successfully'
```

Key fields to inspect:

| Field                             | What to Check                                                                            |
| :-------------------------------- | :--------------------------------------------------------------------------------------- |
| `status.conditions[].type: Ready` | Must be `"True"`. Any other value means the cache is not serving data.                   |
| `status.conditions[].reason`      | `Succeeded` = healthy. `Failed` = check the message field for the error.                 |
| `status.lastRefreshTime`          | Confirms the last successful sync. If this is stale, the background worker may be stuck. |

### 2. Watch Live Sync Events

```bash
kubectl get events -n kyverno --field-selector \
  involvedObject.kind=GlobalContextEntry,involvedObject.name=<entry-name>
```

This surfaces sync failures, retry-limit exhaustion, or RBAC denial events directly
without needing to dig through logs.

### 3. Check Kyverno Controller Logs

First, discover the exact component label your installation uses:

```bash
kubectl get pods -n kyverno --show-labels
```

Look for the `app.kubernetes.io/component` value in the output. Then use it to stream logs:

```bash
kubectl logs -n kyverno \
  -l app.kubernetes.io/component=<your-component-label> \
  --since=10m \
  | grep -i globalcontext
```

> **Note:** Replace `<your-component-label>` with the value found above.
> The most common value is `admission-controller` for standard Kyverno
> installations, but this may differ in custom deployments.

### 4. Inspect the Source Payload Shape (for building JMESPath)

`GlobalContextEntry` status does not expose the cached payload. To validate the data shape and build correct JMESPath expressions, fetch the source directly:

```bash
# kubernetesResource mode (example)
kubectl get <resource> -n <namespace> -o json | jq .

# apiCall.urlPath mode (example)
kubectl get --raw "<urlPath>" | jq .
```

## Cleanup

To remove a `GlobalContextEntry`:

```bash
kubectl delete globalcontextentries <entry-name>
```

> **Note:** Deleting a `GlobalContextEntry` that is actively referenced by running
> policies will cause those policies to return a `variable evaluation error` on
> the next admission request. Always update or remove dependent policies first.

---

## Troubleshooting

When working with `GlobalContextEntry`, misconfigurations typically manifest as empty context variables inside evaluations or synchronization blockages.

### Common Issues Matrix

| Symptom / Error                                                   | Root Cause                                           | Remediation Steps                                                                                                    |
| :---------------------------------------------------------------- | :--------------------------------------------------- | :------------------------------------------------------------------------------------------------------------------- |
| `GlobalContextEntry` creation fails with validation/schema errors | Singular configuration constraint violation.         | Ensure you configured `kubernetesResource` **or** `apiCall`. Defining both simultaneously violates resource schemas. |
| Resource tracking results in completely empty arrays              | Incorrect resource naming specification.             | The `resource` field **must be lowercased and pluralized**. Use `configmaps` instead of `ConfigMap`.                 |
| Policies return `variable evaluation error` on global contexts    | Kyverno controllers lack appropriate RBAC clearance. | Verify Kyverno's ClusterRole has `get`, `list`, and `watch` permissions for that specific API group.                 |
| External API caching loops fail continuously                      | Incorrect configuration of custom data variables.    | If supplying a payload under `apiCall`, explicitly set `method: POST`.                                               |
