---
title: Scaling Kyverno
description: Scaling considerations for a Kyverno installation.
weight: 45
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

Horizontal scaling refers to increasing the number of replicas of a given controller. Kyverno supports multiple replicas for each of its controllers, but the effect of multiple replicas is handled differently according to the controller. See the [high availability section](/docs/high-availability/#how-ha-works-in-kyverno) for more details.

### Scale Testing

The following tables show Kyverno performance test results for the admission and reports controllers. The admission controller table shows the resource consumption (memory and CPU) and latency as a result of increased AdmissionReviews per Second (ARPS) and how this is influenced by the queries per second (QPS) and burst settings.

The reports controller table shows the policy report count and size impacts including the various intermediary resources. Also shown are the resource consumption figures at a scale of up to 100,000 Pods.

In both tables, the testing was performed using K3d on an Ubuntu 20.04 system with an AMD EPYC 7502P 32-core processor @ 2.5GHz (max 3.35GHz) and 256GB of RAM.

For additional specifics on these tests along with a set of instructions which can be used to reproduce the environment, see the developer documentation [here](https://github.com/kyverno/kyverno/blob/main/docs/perf-testing/README.md).

#### Admission Controller

| replicas | # policies | Rule Type |   Mode  | Subject | memory request / limit | cpu request |  ARPS | Latency (avg, unit: ms) | Memory (max) | CPU (max) | admission reports | bgscan reports | policy reports | reports controller memory (max) | reports controller CPU (max) | # nodes |   # pods  | QPS/Bust |
|:--------:|:----------:|:---------:|:-------:|:-------:|:----------------------:|:-----------:|:-----:|:-----------------------:|:------------:|:---------:|:-----------------:|:--------------:|:--------------:|:-------------------------------:|:----------------------------:|:-------:|:---------:|:--------:|
|     3    |     17     |  Validate | Enforce |   Pods  |     128 Mi / 384Mi     |     100m    | 14.92 |            44           |   150.60Mi   |    2.16   |        1000       |      1368      |       88       |             604.49Mi            |             8.51             |   300   |     1k    |   15/15  |
|     3    |     17     |  Validate | Enforce |   Pods  |     128 Mi / 384Mi     |     100m    | 43.47 |            32           |     169Mi    |    5.55   |        5000       |      5369      |       164      |             781.25Mi            |             8.22             |   300   |     5k    |   50/50  |
|     3    |     17     |  Validate | Enforce |   Pods  |     128 Mi / 384Mi     |     100m    | 81.97 |            78           |   215.64Mi   |   10.37   |        5000       |      5369      |       164      |             702.15Mi            |               4              |   300   |     5k    |  100/100 |
|     3    |     17     |  Validate | Enforce |   Pods  |     128 Mi / 512Mi     |     100m    | 83.88 |           129           |   267.29Mi   |    8.75   |        4552       |      4907      |       146      |             598.70Mi            |             7.88             |   300   | 4552/5000 |  150/150 |
|     3    |     17     |  Validate | Enforce |   Pods  |     128 Mi / 512Mi     |     100m    | 108.7 |           151           |   243.10Mi   |   15.34   |        2139       |      2630      |       124      |             375.98Mi            |             7.51             |   300   | 2262/5000 |  200/200 |

#### Reports Controller

| # validate policies |     # pods    | memory request / limit |    memory (max)    | cpu request | CPU (max) | periodic scan interval / workers | total etcd size | policyreports count  | admission reports count | background reports count | QPS/burst | # nodes | admission controller (memory request/limit) |
|:-------------------:|:-------------:|:----------------------:|:------------------:|:-----------:|:---------:|:--------------------------------:|:---------------:|:--------------------:|:-----------------------:|:------------------------:|:---------:|:-------:|:-------------------------------------------:|
|   17 PSS policies   |      1000     |       64Mi / 4Gi       | 240504832=229.36Mi |     100m    |    6.28   |            30 mins / 2           |     43.54Mi     |          88          |           1000          |           1369           |    5/10   |   300   |                 128Mi/384Mi                 |
|   17 PSS policies   |      5000     |       64Mi / 4Gi       | 823582720=785.43Mi |     100m    |     8     |            30 mins / 2           |     145.33Mi    |          164         |           5000          |           5369           |   50/50   |   300   |                 128Mi/384Mi                 |
|   17 PSS policies   |     10000     |       64Mi / 4Gi       |  1381728256=1.32Gi |     100m    |    8.51   |            30 mins / 2           |     251.48Mi    |          258         |          10000          |           10369          |   50/50   |   300   |                 128Mi/384Mi                 |
|   17 PSS policies   |     10000     |       64Mi / 4Gi       |  1700921344=1.62Gi |     100m    |    8.44   |              1h / 2              |     251.48Mi    |          258         |          10000          |           10369          |   50/50   |   300   |                 128Mi/384Mi                 |
|   17 PSS policies   | 19924 / 20000 |       64Mi / 4Gi       |  2693844992=2.51Gi |     100m    |    9.62   |              1h / 2              |     470.42Mi    |          448         |          19885          |           20289          |   50/50   |   300   |                 128Mi/384Mi                 |
|   17 PSS policies   |     100940    |       64Mi / 20Gi      |  6866862080=6.40Gi |     100m    |    5.55   |              1h / 2              |                 |         1356         |          100587         |           11441          |   50/50   |   1000  |              128Mi/384Mi (OOM)              |
|                     |               |                        |                    |             |           |                                  |                 |                      |                         |                          |           |         |                                             |
|   17 PSS policies   |     53456     |       64Mi / 10Gi      |       1.89Gi       |     100m    |    8.12   |              1h / 2              |                 |         1077         |          52893          |           22742          |   50/50   |   500   |                  128Mi/1Gi                  |
|   17 PSS policies   |     53457     |       64Mi / 10Gi      |       2.84Gi       |     100m    |    7.39   |              2h / 2              |                 |         1077         |          52893          |           33303          |   50/50   |   500   |                  128Mi/1Gi                  |
|   17 PSS policies   |     53457     |       64Mi / 10Gi      |       2.55Gi       |     100m    |    7.66   |              3h / 2              |      1.10Gi     |         1077         |          52893          |           35520          |   50/50   |   500   |                  128Mi/1Gi                  |
|                     |               |                        |                    |             |           |                                  |                 |                      |                         |                          |           |         |                                             |
|   17 PSS policies   |     83716     |       64Mi / 10Gi      |                    |     100m    |           |              3h / 2              |                 |       1510/1305      |          82868          |           33768          |   50/50   |   800   |                  128Mi/1Gi                  |
|   17 PSS policies   |     100392    |       64Mi / 10Gi      |       4.83Gi       |     100m    |   23.14   |              2h / 10             |      2.38Gi     |         1873         |          100033         |           73728          |   50/50   |   960   |                 128Mi/512Mi                 |
|   17 PSS policies   |     80856     |       64Mi / 10Gi      |       2.20Gi       |     100m    |   19.13   |              2h / 10             |      2.24Gi     |         1573         |           n/a           |           80891          |   50/50   |   818   |                 128Mi/384Mi                 |

#### AdmissionReview Reference

API requests, operations, and activities which match corresponding Kyverno rules result in an AdmissionReview request getting sent to admission controllers like Kyverno. The number and frequency of these requests may vary greatly depending on the amount and type of activity in the cluster. The following table below is provided to give a sense of how many minimum AdmissionReview requests may result from common operations. These figures only refer to the _minimum_ number and, in actuality, the final count will almost certainly be greater but varies depending on things like finalizers and other controllers in the cluster.

| Operation |  Resource  |                Config               |          ARs         |
|:---------:|:----------:|:-----------------------------------:|:--------------------:|
| CREATE    | Pod        |                                     |                    1 |
| DELETE    | Pod        |                                     |                    3 |
| CREATE    | Deployment | replicas=1                          |                    3 |
| UPDATE    | Deployment | Change image                        |                    8 |
| DELETE    | Deployment | replicas=1                          |                    7 |
| CREATE    | Deployment | replicas=2                          |                    4 |
| UPDATE    | Deployment | Change image                        |                   13 |
| DELETE    | Deployment | replicas=2                          |                   10 |
| CREATE    | Job        | restartPolicy=Never, backoffLimit=4 |                    3 |
| DELETE    | Job        |                                     |                    4 |
| CREATE    | CronJob    | schedule="*/1 * * * *"              | 4 (3 per invocation) |
| DELETE    | CronJob    | schedule="*/1 * * * *", 2 completed |                    9 |
| CREATE    | ConfigMap  |                                     |                    1 |
| EDIT      | ConfigMap  |                                     |                    1 |
| DELETE    | ConfigMap  |                                     |                    1 |

These figures were captured using K3d v5.4.9 on Kubernetes v1.26.2 and Kyverno 1.10.0-alpha.2 with a 3-replica admission controller. When testing against KinD, there may be one less DELETE AdmissionReview for Pod-related operations.
