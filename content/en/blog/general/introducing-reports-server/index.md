---
date: 2024-04-24
title: Kyverno Reports Server - The ultimate solution to scale reporting
linkTitle: Kyverno Reports Server - The ultimate solution to scale reporting
author: Vishal Choudhary
description: Security or Scalability? Why not both!
---

## Introduction

Policy Reports are used by Kyverno to store the result of policies and cluster policies that match a resource. Kyverno generates reports during admission request as well as periodically as background scans. They are very helpful in auditing the current state of policy compliance in a cluster.

Kyverno also creates its own custom ephemeral reports which are later aggregated to create the final policy reports or cluster policy reports. Policy reports and ephemeral reports are stored in etcd as Custom Kubernetes Resources. 

This setup works fine in most cases but we start hitting the limits Kubernetes API server in a large cluster. During heavy reporting, the volume of data being written and retrieved by etcd puts the API server under severe load that can lead to poor performance. Moreover, etcd has a maximium capacity limit therefore, it can have a limited number of resources in it. This limit can be reached in large cluster with a lot of report producers.

Today, we are excited to announce [reports-server](https://github.com/kyverno/reports-server), Kyverno's new project that aims to improve scalability of reporting in large cluster, so that you can have all the benefits of governance without compromising on performance.

In this blog post we will introduce reports-server, discuss its architecture and how to get started.

## Architecture

The reports-server solves the problem of scalability of policy reports by storing policy reports outside of etcd in a relational database. This has the following advantages:

1. Alleviation of the etcd + API server load and capacity limitations.
2. Common report consumer workflows can be more efficient.
3. With reports stored in a relational database, report consumers could instead query the underlying database directly, using more robust query syntax.

The reports-server achieves this by using [Kubernetes API aggregation layer](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/apiserver-aggregation/), where it creates an API service that takes all the request from the local api server and processes them in the reports-server. The reports-server has access to a relational database which it uses to store and query for policy reports and ephemeral reports.

Here is a high level overview of the architecture:
![Architecture](./architecture.svg)

## Getting Started

To start using the reports-server, you have to install it in your cluster, and after some moments, all the reports related requests will be redirected for etcd to the reports server database.. Reports-server has multiple methods for installation: YAML manifest and Helm Chart. Detailed instructions for all installation methods can be found in the [installation guide](https://github.com/kyverno/reports-server/blob/main/docs/INSTALL.md).

To install reports server using YAML manifest, run the following command:

```bash
kubectl apply -f https://raw.githubusercontent.com/kyverno/reports-server/main/config/install.yaml
```

This install manifest will install the following things
1. A deployment and service for the reports server
2. A postgres instance
3. An API service to redirect requests to the reports-server

Reports-server comes with a postgreSQL database but you can have finer control of the database configation by bringing your own database. See the [database configuration guide](https://github.com/kyverno/reports-server/blob/main/docs/DBCONFIG.md).

### Migration

If you already have policy reports CRD installed in your cluster, you will have an existing API service managed by kube-aggregator that sends requests to the kubernetes API server. You will have to update the existing API service to send request to reports-server. See the [migration guide](https://github.com/kyverno/reports-server/blob/main/docs/MIGRATION.md).

## Conclusion

In this short blog post we demonstrated how reports server can be used to store policy reports.

The reports-server is a new project from Kyverno that can be helpful for users with a large cluster with a huge reporting activity. This project is maintained by Kyverno and will have future updates and features based on feedback.

🔗 Check out the project on GitHub: https://github.com/kyverno/reports-server

