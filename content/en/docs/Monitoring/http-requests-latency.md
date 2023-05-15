---
title: HTTP Requests Latency
description: This metric can be used to track the latencies associated with HTTP requests.
weight: 30
---

**Metric Name(s)**

* `kyverno_http_requests_duration_seconds_count`
* `kyverno_http_requests_duration_seconds_sum`
* `kyverno_http_requests_duration_seconds_bucket`

**Metric Value**

Histogram - A float value representing the latency of the HTTP request processing in seconds.

See [Prometheus docs](https://prometheus.io/docs/practices/histograms/) for a detailed explanation of how histograms work.

## Use cases

* TODO

## Filter Labels

| Label | Allowed Values | Description |
| --- | --- | --- |
| http\_method | `GET`, `POST`, etc. | HTTP method |
| http\_url | | URL of the request |

## Useful Queries

* TODO