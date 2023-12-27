---
title: "Controller Requeues Count"
description: 
>   This metric can be used to track the number of times a controller requeues elements to be processed. Requeueing usually indicates that an error occured and that the controller enqueued the same item to retry processing it a bit later.
weight: 45
---

#### Metric Name(s)

* `kyverno_controller_requeue_total`

#### Metric Value

Counter - An only-increasing integer representing the number of items requeued.

#### Metric Labels

| Label | Allowed Values | Description |
| --- | --- | --- |
| controller\_name | | Controller name. |
| num\_requeues | | Number of consecutive requeues for the same item. |

#### Use cases

* Troubleshoot abnormal conflicts in reconciliation.

#### Useful Queries

* Number of requeues per controller in the last hour:<br>
`changes (kyverno_controller_requeue_total[1h])`
