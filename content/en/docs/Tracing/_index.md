---
title: Tracing
description: Trace Kyverno engine admission requests processing
weight: 65
---

## Introduction

Tracing is a method of tracking application requests as they are processed by the application software. When a software is instrumented it produces traces, traces are made of spans hierarchically organised to form a trace. Spans are defined by a start and end time, eventually a parent span, and a number of properties that define the span characteristics (client spans, server spans, etc...).

Tracing is not limited to a single application, as the tracing context can be transmitted on the wire it is possible to collect spans from multiple applications and reconcile them in a single trace.

In the context of Kyverno, requests are usually sent by the Kubernetes API server to the Kyverno service during the admission phase. Kyverno receives and processes admission requests according to the configured policies. Every step in the admission pipeline and during the engine policy processing will produce spans. All clients (Kubernetes client, registry client and cosign client) have also been instrument to produce client spans and transmit the tracing context on the wire.

## Installation and Setup

Tracing requires a backend where Kyverno will send traces. Kyverno uses OpenTelemetry for instrumentation and supports various backends like Jaeger, Grafana Tempo or Datadog to name a few.

When you install Kyverno via Helm, you need to set a couple of values to enable tracing.

```sh
$ values.yaml

...
extraArgs:
  # enable tracing
  - --enableTracing
  # configure tracing endpoint
  - --tracingAddress=tempo.monitoring
  # configure tracing port
  - --tracingPort=4317
...
```

Tracing is disabled by default and depending on the backend the associated cost can be significant.

## Configuring the metrics

While installing Kyverno via Helm, you also have the ability to configure which metrics you'll want to expose.

* You can configure which namespaces you want to `include` and/or `exclude` for metric exportation when configuring your Helm chart. This configuration is useful in situations where you might want to exclude the exposure of Kyverno metrics for certain futile namespaces like test namespaces, which you might be dealing with on a regular basis. Likewise, you can include certain namespaces if you want to monitor Kyverno-related activity for only a set of certain critical namespaces.
Exporting the right set of namespaces (as opposed to exposing all namespaces) can end up substantially reducing the memory footprint of Kyverno's metrics exporter.

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

> `exclude` takes precedence over "include", in cases when a namespace is provided under both `include` and `exclude`.

> The below content is deprecated

* The metric refresh interval is also configurable, and allows the metrics registry to purge itself of all associated metrics within that time frame. This clean-up resets the memory footprint associated with Kyverno's metric exporter. This is particularly useful in scenarios when concerned with the overall memory footprint of Kyverno's metric exporter.

```sh
...
config:
  # rate at which metrics should reset so as to clean up the memory footprint of kyverno metrics, if you might be expecting high memory footprint of Kyverno's metrics.
  metricsRefreshInterval: 24h 
  #Default: 0, no refresh of metrics
...
```

> You still would not lose your previous metrics as your metrics get persisted in the Prometheus backend.

## Metrics and Dashboard
