---
title: Scaling Kyverno
description: Scaling considerations for a Kyverno installation.
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

Horizontal scaling refers to increasing the number of replicas of a given controller. Kyverno supports multiple replicas for each of its controllers, but the effect of multiple replicas is handled differently according to the controller. See the [high availability section](/docs/guides/high-availability/#how-ha-works-in-kyverno for more details.

### Scale Testing

Testing was performed using KinD on an Ubuntu 20.04 system with an AMD EPYC 7502P 32-core processor @ 2.5GHz (max 3.35GHz) and 256GB of RAM.

#### Admission Controller

The following table shows the resource consumption (memory and CPU) and latency as a result of increased virtual users and iterations defined in [k6](https://k6.io/open-source/). k6 is an open-source load testing tool for performance testing. k6 has multiple executors, the most popular of which is the shared-iterations executor. This executor creates a number of concurrent connections called virtual users. The total number of iterations is then distributed among these virtual users.

The test was conducted where we installed Kyverno policies to enforce the Kubernetes pod security standards using 17 policies. Subsequently, we developed a compatible Pod test to measure how long Kyverno takes to admit the admission request. For more details on these tests, refer to the load testing documentation [here](https://github.com/kyverno/load-testing/blob/main/README.md).

| replicas | # policies | Rule Type        | Mode    | Subject | Virtual Users/Iterations | Latency (avg/max)  | Memory (max) | CPU (max) | Memory Limit    |
| -------- | ---------- | ---------------- | ------- | ------- | ------------------------ | ------------------ | ------------ | --------- | --------------- |
| 1        | 17         | Validate         | Enforce | Pods    | 100/1,000                | 37.71ms / 110.53ms | 152Mi        | 548m      | default (384Mi) |
| 1        | 17         | Validate         | Enforce | Pods    | 200/5,000                | 80.74ms / 409.35ms | 182Mi        | 2885m     | default (384Mi) |
| 1        | 17         | Validate         | Enforce | Pods    | 500/10,000               | 92.73ms / 3.15s    | 143Mi        | 3033m     | 512Mi           |
| 3        | 17         | Validate         | Enforce | Pods    | 100/1,000                | 32.89ms / 121.19ms | 104Mi        | 262m      | default (384Mi) |
| 3        | 17         | Validate         | Enforce | Pods    | 200/5,000                | 60.06ms / 1.01s    | 117Mi        | 1067m     | default (384Mi) |
| 3        | 17         | Validate         | Enforce | Pods    | 500/10,000               | 151.97ms / 3.17s   | 107Mi        | 1182m     | 512Mi           |
| 1        | 16         | ValidatingPolicy | Deny    | Pods    | 100/1,000                | 28.3ms / 108.36ms  | 142Mi        | 108m      | default (384Mi) |
| 1        | 16         | ValidatingPolicy | Deny    | Pods    | 200/5,000                | 54.87ms / 346.74ms | 211Mi        | 2339m     | default (384Mi) |
| 1        | 16         | ValidatingPolicy | Deny    | Pods    | 500/10,000               | 133.67ms / 1.63s   | 163Mi        | 4123m     | 512Mi           |
| 3        | 16         | ValidatingPolicy | Deny    | Pods    | 100/1,000                | 24.87ms / 59.37ms  | 129Mi        | 135m      | default (384Mi) |
| 3        | 16         | ValidatingPolicy | Deny    | Pods    | 200/5,000                | 45.97ms / 1.12s    | 159Mi        | 554m      | default (384Mi) |
| 3        | 16         | ValidatingPolicy | Deny    | Pods    | 500/10,000               | 114.01ms / 3.28s   | 170Mi        | 810m      | 512Mi           |

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
