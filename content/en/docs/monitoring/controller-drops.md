---
title: Controller Drops Count
description: This metric can be used to track the number of times a controller drops elements. Dropping usually indicates an unrecoverable error, the controller retried to process an item a couple of times and after failing every try drop the item.
weight: 45
---

#### Metric Name(s)

* `kyverno_controller_drop_total`

#### Metric Value

Counter - An only-increasing integer representing the number of items dropped.

#### Metric Labels

| Label | Allowed Values | Description |
| --- | --- | --- |
| controller\_name | | Controller name. |

#### Use cases

* Check if an item was dropped in the last 1 hour.

#### Useful Queries

* Number of drops per second per controller:<br> 
`sum by (controller_name) (rate(kyverno_controller_drop_total{}[1h]))`
