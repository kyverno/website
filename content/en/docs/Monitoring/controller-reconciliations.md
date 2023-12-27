---
title: "Controller Reconciliations Count"
description: >
    This metric can be used to track the number of reconciliations performed by various Kyverno controllers.
weight: 45
---

#### Metric Name(s)

* `kyverno_controller_reconcile_total`

#### Metric Value

Counter - An only-increasing integer representing the count of reconciliations performed.

#### Metric Labels

| Label | Allowed Values | Description |
| --- | --- | --- |
| controller\_name | | Controller name. |

#### Use cases

* Troubleshoot abnormal activity.

#### Useful Queries

* Number of reconciliations per controller in the last hour:<br>
`changes (kyverno_controller_reconcile_total[1h])`
