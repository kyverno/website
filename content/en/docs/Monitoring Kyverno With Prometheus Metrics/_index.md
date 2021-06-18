---
title: Monitoring Kyverno
description: Monitor Kyverno policy metrics with Prometheus
weight: 65
---

## Introduction

As a cluster admistrator, it is beneficial for you to have capabilities to monitor the state and execution of the Kyverno policies applied over your cluster. Things like tracking the applied policies, the changes associated with them, the activity associated with the incoming requests processed, and the results associated with policies can prove to be extremely useful as a part of cluster observability and compliance.

In addition, providing flexible monitoring of targets from the rule level or policy level to entire cluster level gives you options to extract insights from the collected metrics.

## Installation and Setup

When you install Kyverno via Helm, a service called `kyverno-svc-metrics` gets created inside the `kyverno` namespace and this service exposes metrics om port 8000.

```sh
$ values.yaml

...
metricsService:
  create: true
  type: ClusterIP
  ## Kyverno's metrics server will be exposed at this port
  port: 8000
  ## The Node's port which will allow access Kyverno's metrics at the host level. Only used if service.type is NodePort.
  nodePort:
  ## Provide any additional annotations which may be required. This can be used to
  ## set the LoadBalancer service type to internal only.
  ## ref: https://kubernetes.io/docs/concepts/services-networking/service/#internal-load-balancer
  ##
  annotations: {}
...
```

By default, the service type is going to be `ClusterIP` meaning that the metrics would be only capable of being scraped by a Prometheus server sitting inside the cluster. <br>

In many cases, the Prometheus server may be outside the workload cluster as an shared service. In those scenarios, you will want the `kyverno-svc-metrics` service to be publicly exposed so as to expose the metrics (available at port 8000) to your Prometheus server sitting outside the cluster.<br>

Services can be exposed to external clients via an Ingress, or using `LoadBalancer` or `NodePort` service types. 

To expose your `kyverno-svc-metrics` service publicly as `NodePort` at host's/node's port number 8000, you can configure your `values.yaml` before Helm installation as follows:

```sh
...
metricsService:
  create: true
  type: NodePort
  ## Kyverno's metrics server will be exposed at this port
  port: 8000
  ## The Node's port which will allow access Kyverno's metrics at the host level. Only used if service.type is NodePort.
  nodePort: 8000
  ## Provide any additional annotations which may be required. This can be used to
  ## set the LoadBalancer service type to internal only.
  ## ref: https://kubernetes.io/docs/concepts/services-networking/service/#internal-load-balancer
  ##
  annotations: {}
...
```

To expose the `kyverno-svc-metrics` service using a `LoadBalancer` type, you can configure your `values.yaml` before Helm installation as follows:

```sh
...
metricsService:
  create: true
  type: LoadBalancer
  ## Kyverno's metrics server will be exposed at this port
  port: 8000
  ## The Node's port which will allow access Kyverno's metrics at the host level. Only used if service.type is NodePort.
  nodePort: 
  ## Provide any additional annotations which may be required. This can be used to
  ## set the LoadBalancer service type to internal only.
  ## ref: https://kubernetes.io/docs/concepts/services-networking/service/#internal-load-balancer
  ##
  annotations: {}
...
```

## Metrics and Dashbpard