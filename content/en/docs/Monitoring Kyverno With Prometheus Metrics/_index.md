---
title: Monitoring
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

## Configuring the metrics

While installing Kyverno via Helm, you have also have the opportunity to tweak and configure the metrics which you need to be exposed.

* You can configure only certain amount of namespaces for which you want the metrics to be exported by configuring which namespaces you want to be "included" or/and "excluded" while exposing the metrics. This configuration is useful in situations where you might want to exclude the exposure of Kyverno metrics for certain futile namespaces like test namespaces which you might be dealing with on a regular basis. At the same time, you can include certain namespaces if you want to monitor Kyverno-related activity for only a certain critical namespaces.
Exporting only the right amount of namespaces as opposed to exposing all namespaces can end up substantially reducing the memory footprint of Kyverno's metrics exporter.
```sh
...
config:
  metricsConfig:
    namespaces: {
      "include": [],
      "exclude": []
    }
  # 'namespaces.include': list of namespaces to capture metrics for. Default: all namespaces included.
  # 'namespaces.exclude': list of namespaces to NOT capture metrics for. Default: [], none of the namespaces excluded.
...
```
> "exclude" takes precedence over "include", in case a namespace is provided both under "include" and "exclude".

* You can also configure a metrics refresh interval which cleans up the metrics registry and all the associated metrics of Kyverno's metric exporter at a certain moment, hence, cleaning up and resetting the memory footprint associated with Kyverno's metric exporter. This configuration is useful in situations where you might end up facing a periodic need of resetting and cleaning up the metric exporter of Kyverno to tone down the memory footprint associated with it.<br>
Although Kyverno tries to minimize the cardinality associated with the metrics it exposes, it still exposes certain labels with a slightly higher cardinality than other labels such as `policy_name` and `resource_namespace`. This configuration would be useful in scenarios involving large numbers of namespaces/policies, since these resources have a large memory footprint.
```sh
...
config:
  # rate at which metrics should reset so as to clean up the memory footprint of kyverno metrics, if you might be expecting high memory footprint of Kyverno's metrics.
  metricsRefreshInterval: 24h 
  #Default: 0, no refresh of metrics
...
```
> You still would not lose your previous metrics as your metrics get persisted in your Prometheus backend.

## Metrics and Dashboard