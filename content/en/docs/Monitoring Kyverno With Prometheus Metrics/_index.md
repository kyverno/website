---
title: Monitoring Kyverno
description: Monitor the activities associated with the Kyverno policies applied over your cluster with a good set of Prometheus-compliant metrics
weight: 45
---

## Introduction

As a cluster admistrator or just a normal dev associated with a Kubernetes cluster, it can certainly prove to be beneficial for you to have capabilities around monitoring the state of the Kyverno policies applied over your cluster. Things like tracking the policies, the changes associated with them, the activity associated with the incoming requests hitting them and the results associated with them can prove to be extremely useful as a part of cluster-observability compliance.

Alongside this, providing a non-rigid granularity of monitoring the above targets from rule's level to policy's level to entire admission request's level would give you enough flexibility to extract a diversified set of insights from these metrics depending on your need or/and SLA requirements.

## Installation and Setup

Whenever you install Kyverno via helm, a service called `kyverno-svc` gets created as well inside the `kyverno` namespace and this service ends up exposing the metrics at its port no. 8000.

```sh
$ values.yaml

...
service:
  port: 443
  type: ClusterIP
  # Only used if service.type is NodePort
  nodePort:
  ## Kyverno's metrics server will be exposed at this port
  metricsPort: 8000
  ## The Node's port which will allow access Kyverno's metrics at the host level. Only used if service.type is NodePort.
  metricsNodePort: 8000
  ## Provide any additional annotations which may be required. This can be used to
  ## set the LoadBalancer service type to internal only.
  ## ref: https://kubernetes.io/docs/concepts/services-networking/service/#internal-load-balancer
  ##
  annotations: {}
...
```

By default, the service type is going to be `ClusterIP` meaning that the metrics would be only capable of being scraped by a Prometheus server sitting inside the cluster. <br>
But speculatively, in majority of the cases, the Prometheus server would be kept outside the cluster as an isolated component. In those kinds of scenarios, you would want the `kyverno-svc` service to be publicly exposed so as to expose the metrics (available at port 8000) to your Prometheus server sitting outside the cluster.<br>

To do so, either you can expose the `kyverno-svc` service as NodePort or LoadBalancer.
That can be done via the `values.yaml` file itself which is provided at the time of helm installation.

```sh
...
service:
  type: NodePort
  metricsPort: 8000
  metricsNodePort: 8000
...
```

The above configuration will allow Kyverno's metrics to be exposed at port 8000 of any host/node of the cluster.

## Metrics and a ready-to-use Grafana Dashboard