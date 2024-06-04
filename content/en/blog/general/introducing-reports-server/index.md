---
date: 2024-05-29
title: Kyverno Reports Server - The ultimate solution to scale reporting
linkTitle: Kyverno Reports Server - The ultimate solution to scale reporting
author: Vishal Choudhary
description: Security or Scalability? Why not both!
---

## Introduction

Policy Reports are used by Kyverno to store the result of policies and cluster policies that match a resource. Kyverno generates reports during admission request as well as periodically as background scans. They are very helpful in auditing the current state of policy compliance in a cluster.

Kyverno also creates its own custom ephemeral reports which are later aggregated to create the final policy reports or cluster policy reports. Policy reports and ephemeral reports are stored in etcd as Custom Resources. 

This setup works fine in most cases, but in larger-scale environments the limits of the Kubernetes API server could be reached. During periods of especially heavy reporting, the volume of data being written to and read from etcd can put the API server under severe load which can lead to degraded performance. Additionally, etcd has a maximum capacity limit and therefore has a limited number of resources it may store. This limit can be reached in large clusters with many report producers.

Today, we are excited to announce [reports-server](https://github.com/kyverno/reports-server), a new Kyverno project which aims to improve scalability of reporting in large clusters giving you all the benefits of visibility without compromising on performance.

In this blog post we will introduce reports server, discuss its architecture, and provide steps on how to get started.

## Architecture

Reports server solves the problem of scalability of policy reports by storing policy reports outside of etcd in a relational database. This has the following advantages:

1. Alleviation of the etcd + API server load and capacity limitations.
2. Common report consumer workflows can be more efficient.
3. With reports stored in a relational database, report consumers could instead query the underlying database directly, using more robust query syntax.

Reports server achieves this by using [Kubernetes API aggregation layer](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/apiserver-aggregation/), where it creates an API service that takes all the requests from the local API server and processes them. Reports server has access to a relational database which it uses to store and query for policy reports and ephemeral reports.

A high-level overview of the architecture is shown below.
![Architecture](./architecture.svg)

## Performance

Reports server stores policy reports and ephemeral reports outside etcd thus reducing the database size of etcd. In the following tables, we show the database size of etcd of increased workloads with and without reports server. In this test, we installed Kyverno policies to audit the Kubernetes [Pod Security Standards](https://kubernetes.io/docs/concepts/security/pod-security-standards/) using 17 policies. Subsequently, we created workloads (Pods, Deployments, ReplicaSets) that match the installed Kyverno policies and scheduled them on false kwok nodes to measure total size of policy reports in etcd. [kwok](https://kwok.sigs.k8s.io/) is a toolkit that enables setting up a cluster of thousands of Nodes in seconds. `DB_SIZE` in the output of `etcdctl endpoint status -w table` was used to calculate etcd DB size. For more details on these tests, refer to the testing documentation for [the report controller](https://github.com/kyverno/kyverno/tree/main/docs/perf-testing). The version of Kyverno used in this testing was 1.12.3.

### Without Reports Server

Below is the count of reports in etcd without the reports server. When the reports server is not installed, `apiserver_storage_objects` reports that there are 10000+ policy reports in etcd:

```bash
$ kubectl get --raw=/metrics | grep apiserver_storage_objects | awk '$2>100' |sort -g -k 2
# HELP apiserver_storage_objects [STABLE] Number of stored objects at the time of last check split by kind.
# TYPE apiserver_storage_objects gauge
apiserver_storage_objects{resource="nodes"} 108
apiserver_storage_objects{resource="leases.coordination.k8s.io"} 123
apiserver_storage_objects{resource="deployments.apps"} 857
apiserver_storage_objects{resource="replicasets.apps"} 859
apiserver_storage_objects{resource="pods"} 8540
apiserver_storage_objects{resource="policyreports.wgpolicyk8s.io"} 10268

$ kubectl get polr -A | wc -l
10269
```
`apiserver_storage_objects` metrics show that there are 10000+ policy reports stored in etcd along with other resources.

Total size of etcd, including all resources in the cluster with respect to amount of policy reports:
| Number of Policy Reports | Number of Pods | Total etcd Size |
| --------------- | --------------- | --------------- |
| 179             | 139             | 46 MB           |
| 1199            | 1139            | 71 MB           |
| 2219            | 2139            | 100 MB          |
| 4259            | 4139            | 149 MB          |
| 6299            | 6139            | 167 MB          |
| 8339            | 8139            | 220 MB          |
| 10379           | 10139           | 255 MB          |

### With Reports Server

Here is the count of objects in etcd with the reports server, when 10000+ policy reports are present in the cluster. When the reports server is installed, `apiserver_storage_objects` does not find any policy reports in etcd and is therefore not reported. When we query for policy reports using kubectl, we see that there are 10000+ policy reports in the cluster:

```bash
$ kubectl get --raw=/metrics | grep apiserver_storage_objects | awk '$2>100' |sort -g -k 2
# HELP apiserver_storage_objects [STABLE] Number of stored objects at the time of last check split by kind.
# TYPE apiserver_storage_objects gauge
apiserver_storage_objects{resource="nodes"} 108
apiserver_storage_objects{resource="leases.coordination.k8s.io"} 123
apiserver_storage_objects{resource="deployments.apps"} 855
apiserver_storage_objects{resource="replicasets.apps"} 857
apiserver_storage_objects{resource="pods"} 8540

$ kubectl get polr -A | wc -l
10249
```
`apiserver_storage_objects` metric does not find policy reports stored in etcd.

Total size of etcd, including all resources in the cluster with respect to amount of policy reports:

| Number of Policy Reports | Number of Pods | Total etcd Size |
| --------------- | --------------- | --------------- |
| 185             | 141             | 38 MB           |
| 1205            | 1141            | 38 MB           |
| 2225            | 2141            | 41 MB           |
| 4265            | 4141            | 55 MB           |
| 6305            | 6141            | 58 MB           |
| 8345            | 8141            | 67 MB           |
| 10385           | 10141           | 76 MB           |

As shown in the benchmark, the size of etcd grows as the number of resources in the cluster grows, but the growth is slower when reports server is installed. As reports server stores policy reports in a separate database, they don't take up any space in etcd. At 10,000 reports, the database size of etcd is 70.1% smaller compared to when reports server is installed.

## Getting Started

To get started using reports server, install the service in your cluster. After a period of time, all the reports-related requests will be redirected from etcd to the reports server database. Reports server has multiple methods for installation including a basic YAML manifest and Helm chart. Detailed instructions for all installation methods can be found in the [installation guide](https://github.com/kyverno/reports-server/blob/main/docs/INSTALL.md).

To install reports server using the YAML manifest, run the following commands:
Create a namespace for reports server:
```bash
kubectl create ns reports-server
```
Apply the reports server manifest:
```bash
kubectl apply -f https://raw.githubusercontent.com/kyverno/reports-server/main/config/install.yaml
```

The manifest will install the following components:
1. A deployment and service for the reports server
2. A Postgres instance
3. An API service to redirect requests to reports server

Reports server comes with a PostgreSQL database, but you may opt for finer control of the database configuration by bringing your own database. See the [database configuration guide](https://github.com/kyverno/reports-server/blob/main/docs/DBCONFIG.md) for more details.

### Migration

If you already have the PolicyReport CRD installed in your cluster, you will have an existing API service managed by kube-aggregator that sends requests to the Kubernetes API server. You will have to update the existing API service to send request to reports server. See the [migration guide](https://github.com/kyverno/reports-server/blob/main/docs/MIGRATION.md) for more details.

## Conclusion

In this short blog post, we demonstrated how reports server can be used to store policy reports.

Reports server is a new project from Kyverno that can be helpful for users with large scale reporting needs. This project is maintained by Kyverno and will have future updates and features based on feedback.

🔗 Check out the project on GitHub: https://github.com/kyverno/reports-server

