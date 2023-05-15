---
title: Http Requests Counts
description: This metric can be used to track the number of http requests which were triggered as a part of Kyverno.
weight: 45
---

**Metric Name**

kyverno_http_requests_total

**Metric Value**

Counter - An only-increasing integer representing the count of http requests associated with a sample.

## Use cases

* The cluster admin wants to know how many http requests were triggered in the last 24h hence, know how active Kyverno has been.
* The cluster admin wants to know what percentage of total incoming http requests to Kyverno correspond to a specific HTTP method or URL.

## Filter Labels

| Label | Allowed Values | Description |
| --- | --- | --- |
| http\_method | "GET", "POST, etc. | HTTP method |
| http\_url | | URL of the request |

## Useful Queries

* Total admission requests triggered in the last 24h:<br> 
`sum(increase(kyverno_http_requests_total{}[24h]))`

* Percentage of total incoming admission requests corresponding to resource creations:<br>
`sum(kyverno_http_requests_total{http_method="POST"})/sum(kyverno_http_requests_total{})`