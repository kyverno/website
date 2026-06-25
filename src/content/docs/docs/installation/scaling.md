---
title: Scaling Kyverno
excerpt: Scaling considerations for a Kyverno installation.
sidebar:
  order: 45
---

## Scaling Kyverno

Kyverno supports scaling in multiple dimensions, both vertical as well as horizontal. It is important to understand when to scale, how to scale, and what the effects of that scaling will have on its operation. See the sections below to understand these topics better.

Because Kyverno is an admission controller with many capabilities and due to the variability with respect to environment type, size, and composition of Kubernetes clusters, the amount of processing performed by Kyverno can vary greatly. Sizing a Kyverno installation based solely upon Node or Pod count is often not appropriate to accurately predict the amount of resources it will require.

For example, a large production cluster hosting 60,000 Pods yet with no Kyverno policies installed which match on `Pod` has no bearing on the resources required by Kyverno. Because webhooks are dynamically managed by Kyverno according to the policies installed in the cluster, no policies which match on `Pod` results in no information about Pods being sent by the API server to Kyverno and, therefore, reduced processing load.

However, any policies which match on a wildcard (`"*"`) will result in Kyverno being forced to process _every_ operation (CREATE, UPDATE, DELETE, and CONNECT) on _every_ resource in the cluster. Even if the policy logic itself is simple, only a single, simple policy written in such a manner and installed in a large cluster can and will have significant impact on the resources required by Kyverno.

### Vertical Scale

Vertical scaling refers to increasing the resources allocated to existing Pods, which amounts to resource requests and limits.

We recommend conducting tests in your own environment to determine real-world utilization in order to best set resource requests and limits, but as a best practice we also recommend not setting CPU limits.

### Horizontal Scale

Horizontal scaling refers to increasing the number of replicas of a given controller. Kyverno supports multiple replicas for each of its controllers, but the effect of multiple replicas is handled differently according to the controller. See the [high availability section](/docs/guides/high-availability#how-ha-works-in-kyverno) for more details.

### HPA Autoscaling for the Admission Controller

Kyverno 1.18 adds support for automatic horizontal scaling of the admission controller using a [HorizontalPodAutoscaler (HPA)](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/). This allows Kubernetes to automatically increase or decrease the number of admission controller replicas based on observed CPU or memory utilization.

#### Helm Chart Values

The following Helm values control HPA behavior for the admission controller:

| Value                                                               | Default | Description                                                                                                                                       |
| ------------------------------------------------------------------- | ------- | ------------------------------------------------------------------------------------------------------------------------------------------------- |
| `admissionController.autoscaling.enabled`                           | `false` | Enable or disable the HPA                                                                                                                         |
| `admissionController.autoscaling.minReplicas`                       | `1`     | Minimum number of replicas                                                                                                                        |
| `admissionController.autoscaling.maxReplicas`                       | `10`    | Maximum number of replicas                                                                                                                        |
| `admissionController.autoscaling.targetCPUUtilizationPercentage`    | `80`    | Target average CPU utilization (%) across all replicas                                                                                            |
| `admissionController.autoscaling.targetMemoryUtilizationPercentage` | (unset) | Target average memory utilization (%) across all replicas                                                                                         |
| `admissionController.autoscaling.behavior`                          | `{}`    | Custom [scaling behavior](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/#configurable-scaling-behavior) configuration |

#### Enabling CPU-Based Autoscaling

To enable HPA with CPU-based scaling only, set the following values:

```yaml
admissionController:
  autoscaling:
    enabled: true
    minReplicas: 3
    maxReplicas: 10
    targetCPUUtilizationPercentage: 80
```

#### Enabling Memory-Based Autoscaling

To enable HPA with memory-based scaling only, unset the CPU target and set a memory target:

```yaml
admissionController:
  autoscaling:
    enabled: true
    minReplicas: 3
    maxReplicas: 10
    targetCPUUtilizationPercentage: ~
    targetMemoryUtilizationPercentage: 80
```

#### Combining CPU and Memory Autoscaling

Both metrics can be used simultaneously. The HPA will scale up when either threshold is exceeded:

```yaml
admissionController:
  autoscaling:
    enabled: true
    minReplicas: 3
    maxReplicas: 10
    targetCPUUtilizationPercentage: 80
    targetMemoryUtilizationPercentage: 80
```

#### Recommended Settings for Production

For a production environment, consider the following starting points based on the [scale testing results](#scale-testing) above:

- Set `minReplicas` to at least `3`, which is the [minimum for a highly-available admission controller deployment](/docs/guides/high-availability#admission-controller).
- Set `maxReplicas` based on your cluster size and the maximum acceptable latency under peak load. Values between `5` and `10` are common for large clusters.
- Use a CPU target of `80` and/or a memory target of `80` as a starting point, then adjust based on observed utilization.
- Ensure the admission controller Pods have appropriate [resource requests and limits](/docs/installation/customization#container-flags) set so that the HPA utilization percentages are calculated correctly. Without requests defined, the HPA cannot compute utilization.

```yaml
admissionController:
  resources:
    requests:
      cpu: 100m
      memory: 256Mi
    limits:
      memory: 512Mi
  autoscaling:
    enabled: true
    minReplicas: 3
    maxReplicas: 10
    targetCPUUtilizationPercentage: 80
    targetMemoryUtilizationPercentage: 80
```

#### Interaction with PodDisruptionBudget

When running multiple replicas, it is recommended to also configure a [PodDisruptionBudget (PDB)](https://kubernetes.io/docs/tasks/run-application/configure-pdb/) to prevent all replicas from being evicted simultaneously during voluntary disruptions (for example, node drains). The Helm chart creates a PDB automatically when `replicas` is greater than `1`, but when autoscaling is enabled the replica count is managed dynamically and a PDB should be configured explicitly:

```yaml
admissionController:
  autoscaling:
    enabled: true
    minReplicas: 3
    maxReplicas: 10
    targetCPUUtilizationPercentage: 80
    targetMemoryUtilizationPercentage: 80
  podDisruptionBudget:
    enabled: true
    minAvailable: 2
```

Setting `minAvailable` to one less than `minReplicas` ensures at least a quorum of replicas remain available during maintenance operations while still allowing rolling upgrades.

### Scale Testing

#### Admission Controller

Kyverno admission controller benchmarks are measured using [k6](https://k6.io/open-source/) with the [xk6-kubernetes](https://github.com/grafana/xk6-kubernetes) extension. k6's shared-iterations executor distributes a fixed number of pod CREATE requests across a pool of concurrent virtual users (VUs). All latency values are end-to-end iteration duration measured from the k6 client (API server + webhook round-trip). [KWOK](https://kwok.sigs.k8s.io/) fake nodes are used so pod scheduling overhead does not inflate admission latency numbers.

##### ClusterPolicy (pre-v1.14, `kyverno.io/v1`)

Tested on an AMD EPYC 7502P 32-core @ 2.5 GHz (max 3.35 GHz), 256 GB RAM, Ubuntu 20.04, KinD. Latency reported as avg / max. For more details refer to the load testing documentation [here](https://github.com/kyverno/load-testing/blob/main/README.md).

| replicas | # policies | Rule Type | Mode    | Subject | Virtual Users/Iterations | Latency (avg/max)  | Memory (max) | CPU (max) | Memory Limit    |
| -------- | ---------- | --------- | ------- | ------- | ------------------------ | ------------------ | ------------ | --------- | --------------- |
| 1        | 17         | Validate  | Enforce | Pods    | 100/1,000                | 37.71ms / 110.53ms | 152Mi        | 548m      | default (384Mi) |
| 1        | 17         | Validate  | Enforce | Pods    | 200/5,000                | 80.74ms / 409.35ms | 182Mi        | 2885m     | default (384Mi) |
| 1        | 17         | Validate  | Enforce | Pods    | 500/10,000               | 92.73ms / 3.15s    | 143Mi        | 3033m     | 512Mi           |
| 3        | 17         | Validate  | Enforce | Pods    | 100/1,000                | 32.89ms / 121.19ms | 104Mi        | 262m      | default (384Mi) |
| 3        | 17         | Validate  | Enforce | Pods    | 200/5,000                | 60.06ms / 1.01s    | 117Mi        | 1067m     | default (384Mi) |
| 3        | 17         | Validate  | Enforce | Pods    | 500/10,000               | 151.97ms / 3.17s   | 107Mi        | 1182m     | 512Mi           |

##### CEL-Based Policies (v1.18.1, `policies.kyverno.io/v1`)

Tested on Akamai Dedicated `g6-dedicated-32` (32 vCPU / 64 GB RAM), KinD 3-worker cluster, KWOK fake nodes, Kyverno v1.18.1 (Helm chart 3.8.1). Load generated from a separate `g6-dedicated-16` instance. Latency reported as avg / p95 / p99. Memory and CPU metrics were not captured in this run; use the `kyverno_admission_review_duration_seconds` Prometheus metric for runtime monitoring.

The `vpol-pss` scenario installs 16 `ValidatingPolicy` resources mirroring the Pod Security Standards restricted profile (equivalent to the ClusterPolicy rows above). The `combined` scenario activates one `ValidatingPolicy` and one `MutatingPolicy` simultaneously, exercising both webhook paths per admission request.

| replicas | # policies | Policy Type      | Scenario     | Subject | VUs / Iterations | avg   | p95   | p99       | fail% |
| -------- | ---------- | ---------------- | ------------ | ------- | ---------------- | ----- | ----- | --------- | ----- |
| 1        | 16         | ValidatingPolicy | vpol-pss     | Pods    | 50 / 5,000       | 57ms  | 103ms | 182ms     | 0%    |
| 1        | 16         | ValidatingPolicy | vpol-pss     | Pods    | 200 / 10,000     | 156ms | 316ms | 487ms     | 0%    |
| 1        | 16         | ValidatingPolicy | vpol-pss     | Pods    | 500 / 10,000     | 366ms | 866ms | 1,247ms ⚠ | 0%    |
| 3        | 16         | ValidatingPolicy | vpol-pss     | Pods    | 50 / 5,000       | 57ms  | 95ms  | 106ms     | 0%    |
| 3        | 16         | ValidatingPolicy | vpol-pss     | Pods    | 200 / 10,000     | 145ms | 237ms | 284ms     | 0%    |
| 3        | 16         | ValidatingPolicy | vpol-pss     | Pods    | 500 / 10,000     | 321ms | 536ms | 649ms     | 0%    |
| 1        | 1          | MutatingPolicy   | mpol-complex | Pods    | 200 / 10,000     | 152ms | 221ms | 240ms     | 0%    |
| 1        | 1          | MutatingPolicy   | mpol-complex | Pods    | 500 / 10,000     | 252ms | 378ms | 427ms     | 0%    |
| 3        | 1          | MutatingPolicy   | mpol-complex | Pods    | 200 / 10,000     | 152ms | 220ms | 244ms     | 0%    |
| 3        | 1          | MutatingPolicy   | mpol-complex | Pods    | 500 / 10,000     | 256ms | 386ms | 460ms     | 0%    |
| 1        | 2          | combined         | vpol + mpol  | Pods    | 200 / 10,000     | 155ms | 295ms | 454ms     | 0%    |
| 1        | 2          | combined         | vpol + mpol  | Pods    | 500 / 10,000     | 384ms | 777ms | 1,113ms ⚠ | 0%    |
| 3        | 2          | combined         | vpol + mpol  | Pods    | 200 / 10,000     | 149ms | 241ms | 289ms     | 0%    |
| 3        | 2          | combined         | vpol + mpol  | Pods    | 500 / 10,000     | 310ms | 491ms | 567ms     | 0%    |

⚠ p99 > 1 s at single-replica under extreme load (500 concurrent creates). The `KyvernoAdmissionHighLatency` PrometheusRule alert fires at p99 > 1 s sustained for 5 minutes. With 3 replicas all scenarios remain below 650 ms p99 at 500 VU. Full results including simple/moderate complexity variants and per-VU-level breakdowns are available in [docs/perf-testing/v1.18.1/results/summary.md](https://github.com/kyverno/kyverno/blob/main/docs/perf-testing/v1.18.1/results/summary.md).

#### Reports Controller

The following table shows the resource consumption (memory and CPU) and objects sizes in etcd of increased workloads. The test was conducted where we installed Kyverno policies to audit the Kubernetes pod security standards using 16 policies. Subsequently, we created workloads and scheduled them on the fake KWOK nodes to measure total size of policy reports in etcd. [KWOK](https://kwok.sigs.k8s.io/) is a toolkit that enables setting up a cluster of thousands of Nodes in seconds. For more details on these tests, refer to the testing documentation for [the report controller](https://github.com/kyverno/kyverno/tree/main/docs/perf-testing).

| # policyreports | total etcd size | CPU (max) | memory (max) |
| --------------- | --------------- | --------- | ------------ |
| 1284            | 373 MB          | 3709m     | 99Mi         |
| 2524            | 381 MB          | 3729m     | 102Mi        |
| 3572            | 390 MB          | 3721m     | 110Mi        |
| 4879            | 398 MB          | 3981m     | 118Mi        |
| 6099            | 418 MB          | 4014m     | 124Mi        |
| 7319            | 431 MB          | 4034m     | 136Mi        |
| 10254           | 483 MB          | 4273m     | 152Mi        |

#### AdmissionReview Reference

API requests, operations, and activities which match corresponding Kyverno rules result in an AdmissionReview request getting sent to admission controllers like Kyverno. The number and frequency of these requests may vary greatly depending on the amount and type of activity in the cluster. The following table below is provided to give a sense of how many minimum AdmissionReview requests may result from common operations. These figures only refer to the _minimum_ number and, in actuality, the final count will almost certainly be greater but varies depending on things like finalizers and other controllers in the cluster.

| Operation |  Resource  |                 Config                 |         ARs          |
| :-------: | :--------: | :------------------------------------: | :------------------: |
|  CREATE   |    Pod     |                                        |          1           |
|  DELETE   |    Pod     |                                        |          3           |
|  CREATE   | Deployment |               replicas=1               |          3           |
|  UPDATE   | Deployment |              Change image              |          8           |
|  DELETE   | Deployment |               replicas=1               |          7           |
|  CREATE   | Deployment |               replicas=2               |          4           |
|  UPDATE   | Deployment |              Change image              |          13          |
|  DELETE   | Deployment |               replicas=2               |          10          |
|  CREATE   |    Job     |  restartPolicy=Never, backoffLimit=4   |          3           |
|  DELETE   |    Job     |                                        |          4           |
|  CREATE   |  CronJob   |       schedule="_/1 _ \* \* \*"        | 4 (3 per invocation) |
|  DELETE   |  CronJob   | schedule="_/1 _ \* \* \*", 2 completed |          9           |
|  CREATE   | ConfigMap  |                                        |          1           |
|   EDIT    | ConfigMap  |                                        |          1           |
|  DELETE   | ConfigMap  |                                        |          1           |

These figures were captured using K3d v5.4.9 on Kubernetes v1.26.2 and Kyverno 1.10.0-alpha.2 with a 3-replica admission controller. When testing against KinD, there may be one less DELETE AdmissionReview for Pod-related operations.

### Kubernetes api-server and etcd resource footprint

In clusters with many Kyverno policy resources, the resource footprint of some core Kubernetes components may be affected, in particular the kube-apiserver and etcd.

For example, if you create several thousand Kyverno policy resources, double check that the kube-apiserver pods have head room to increase its memory allocations, otherwise
the cluster may crash entirely.
