---
title: Tracing
description: Using distributed tracing to introspect the internal operations of Kyverno.
sidebar:
  order: 80
---

## Introduction

Tracing is a method of tracking application requests as they are processed by the application software. When a software is instrumented it produces traces, traces are made of spans hierarchically organised to form a trace. Spans are defined by a start and end time, eventually a parent span, and a number of properties that define the span characteristics (client spans, server spans, etc...).

Tracing is not limited to a single application, as the tracing context can be transmitted on the wire it is possible to collect spans from multiple applications and reconcile them in a single trace.

In the context of Kyverno, requests are usually sent by the Kubernetes API server to the Kyverno service during the admission phase. Kyverno receives and processes admission requests according to the configured policies. Every step in the admission pipeline and during the engine policy processing will produce spans. All clients (Kubernetes client, registry client and cosign client) have also been instrumented to produce client spans and transmit the tracing context on the wire.

## Trace example

Below is a trace for a validating admission request.

<p align="center"><img src="./assets/trace-example-1.png" height="300px"/></p>

## Installation and Setup

Tracing requires a backend where Kyverno will send traces. Kyverno uses OpenTelemetry for instrumentation and supports various backends like [Jaeger](https://www.jaegertracing.io/), [Grafana Tempo](https://grafana.com/oss/tempo/) or [Datadog](https://docs.datadoghq.com/tracing/) to name a few.

When you install Kyverno via Helm, you need to set a couple of values to enable tracing.

```shell
$ values.yaml

# ...

# Enable tracing in the admission controller
admissionController:
  tracing:
    # -- Enable tracing
    enabled: true
    # -- Traces receiver address
    address: <backend url>
    # -- Traces receiver port
    port: 4317

# ...

# Enable tracing in the background controller
backgroundController:
  tracing:
    # -- Enable tracing
    enabled: true
    # -- Traces receiver address
    address: <backend url>
    # -- Traces receiver port
    port: 4317

# ...

# Enable tracing in the cleanup controller
cleanupController:
  tracing:
    # -- Enable tracing
    enabled: true
    # -- Traces receiver address
    address: <backend url>
    # -- Traces receiver port
    port: 4317

# ...

# Enable tracing in the reports controller
reportsController:
  tracing:
    # -- Enable tracing
    enabled: true
    # -- Traces receiver address
    address: <backend url>
    # -- Traces receiver port
    port: 4317

# ...
```

Tracing is disabled by default and depending on the backend the associated cost can be significant.

Currently, Kyverno tracing is configured to sample all incoming requests, there's no way to configure the tracing sampler directly in Kyverno. [OpenTelemetry Collector](https://opentelemetry.io/docs/collector/) can be used to take better sampling decision at the cost of a more advanced setup.

## Additional docs and tutorials
