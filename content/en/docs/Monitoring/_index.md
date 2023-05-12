---
title: Monitoring
description: >
  Monitor and observe the operation of Kyverno using metrics.
weight: 65
---

## Introduction

As a cluster administrator, it may benefit you to have monitoring capabilities over both the state and execution of cluster-applied Kyverno policies. This includes monitoring over any applied changes to policies, any activity associated with incoming requests, and any results produced as an outcome. If enabled, monitoring will allow you to visualize and alert on applied policies, and is critical to overall cluster observability and compliance.

In addition, you can specify the scope of your monitoring targets to either the rule, policy, or cluster level, which enables you to extract more granular insights from collected metrics.

## Installation and Setup

When you install Kyverno via Helm, additional services are created inside the `kyverno` Namespace which expose metrics on port 8000.

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

By default, the service type is going to be `ClusterIP` meaning that metrics can only be scraped by a Prometheus server sitting inside the cluster.

In some cases, the Prometheus server may sit outside your workload cluster as a shared service. In these scenarios, you will want the `kyverno-svc-metrics` Service to be publicly exposed so as to expose the metrics (available at port 8000) to your external Prometheus server.

Services can be exposed to external clients via an Ingress, or using `LoadBalancer` or `NodePort` Service types.

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

While installing Kyverno via Helm, you also have the ability to configure which metrics to expose.

You can configure which Namespaces you want to `include` and/or `exclude` for metric exportation when configuring your Helm chart. This configuration is useful in situations where you might want to exclude the exposure of Kyverno metrics for certain Namespaces like test or experimental Namespaces. Likewise, you can include certain Namespaces if you want to monitor Kyverno-related activity for only a set of certain critical Namespaces. Exporting the right set of Namespaces (as opposed to exposing all Namespaces) can end up substantially reducing the memory footprint of Kyverno's metrics exporter.

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

`exclude` takes precedence over `include` in cases when a Namespace is provided under both.

## Disabling metrics

Some metrics may generate an excess amount of data which may be undesirable in situations where this incurs additional cost. Some monitoring products and solutions have the ability to selectively disable which metrics are sent to collectors while leaving others enabled.

Disabling select metrics with [DataDog OpenMetrics](https://docs.datadoghq.com/integrations/openmetrics/) can be done by annotating the Kyverno Pod(s) as shown below.

```yaml
apiVersion: v1                                                                                                                                               
kind: Pod                                                                                                                                                    
metadata:                                                                                                                                                    
  annotations:                                                                                                                                               
    ad.datadoghq.com/kyverno.checks: |                                                                                                                       
      {                                                                                                                                                      
        "openmetrics": {                                                                                                                                     
          "init_config": {},                                                                                                                                 
          "instances": [                                                                                                                                     
            {                                                                                                                                                
              "openmetrics_endpoint": "http://%%host%%:8000/metrics",                                                                                        
              "namespace": "kyverno",                                                                                                                        
              "metrics": [                                                                                                                                   
                {"kyverno_policy_rule_info_total": "policy_rule_info"},                                                                                      
                {"kyverno_admission_requests": "admission_requests"},                                                                                        
                {"kyverno_policy_changes": "policy_changes"}                                                                                                 
              ],                                                                                                                                             
              "exclude_labels": [                                                                                                                            
                "resource_namespace"                                                                                                                         
              ]                                                                                                                                              
            },                                                                                                                                               
            {                                                                                                                                                
              "openmetrics_endpoint": "http://%%host%%:8000/metrics",                                                                                        
              "namespace": "kyverno",                                                                                                                        
              "metrics": [                                                                                                                                   
                {"kyverno_policy_results": "policy_results"}                                                                                                 
              ]                                                                                                                                              
            }                                                                                                                                                
          ]                                                                                                                                                  
        }                                                                                                                                                    
      } 
```

The Kyverno Helm chart supports including additional Pod annotations in the values file as shown in the below example.

```yaml
podAnnotations:
  # https://github.com/DataDog/integrations-core/blob/master/openmetrics/datadog_checks/openmetrics/data/conf.yaml.example
  # Note: To collect counter metrics with names ending in `_total`, specify the metric name without the `_total`
  ad.datadoghq.com/kyverno.checks: |
    {
      "openmetrics": {
        "init_config": {},
        "instances": [
          {
            "openmetrics_endpoint": "http://%%host%%:8000/metrics",
            "namespace": "kyverno",
            "metrics": [
              {"kyverno_policy_rule_info_total": "policy_rule_info"},
              {"kyverno_admission_requests": "admission_requests"},
              {"kyverno_policy_changes": "policy_changes"}
            ],
            "exclude_labels": [
              "resource_namespace"
            ]
          },
          {
            "openmetrics_endpoint": "http://%%host%%:8000/metrics",
            "namespace": "kyverno",
            "metrics": [
              {"kyverno_policy_results": "policy_results"}
            ]
          }
        ]
      }
    }
```

## Metrics and Dashboard
