---
title: "Admission Requests Count"
description: >
    This metric can be used to track the number of admission requests which were triggered as a part of Kyverno.
weight: 45
---

#### Metric Name(s)

* `kyverno_admission_requests_total`

#### Metric Value

Counter - An only-increasing integer representing the count of admission requests associated with a sample.

#### Metric Labels

| Label | Allowed Values | Description |
| --- | --- | --- |
| request\_allowed | "true", "false" | If the admission review was accepeted or rejected. |
| request\_webhook | "ValidatingWebhookConfiguration", "MutatingWebhookConfiguration" | Type of webhook processing the admission review. |
| resource\_kind | "Pod", "Deployment", "StatefulSet", "ReplicaSet", etc. | Kind of this resource |
| resource\_namespace | | Namespace in which this resource lives |
| resource\_request\_operation | "create", "update", "delete" | If the requested resource is being created, updated, or deleted. |

#### Use cases

* The cluster admin wants to know how many admission requests were triggered in the last 24h hence, know how active Kyverno has been.
* The cluster admin wants to know what percentage of total incoming admission requests to Kyverno correspond to the incoming resource creations.

#### Useful Queries

* Total admission requests triggered in the last 24h:<br> 
`sum(increase(kyverno_admission_requests_total{}[24h]))`

* Percentage of total incoming admission requests corresponding to resource creations:<br>
`sum(kyverno_admission_requests_total{resource_request_operation="create"})/sum(kyverno_admission_requests_total{})`