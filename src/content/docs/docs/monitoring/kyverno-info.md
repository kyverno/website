---
title: Kyverno Info
description: This metric can be used to information related to Kyverno such as its version.
sidebar:
  order: 50
---

#### Metric Name(s)

- `kyverno_info`

#### Metric Value

Gauge - A constant value of 1 with labels to include relevant information

#### Metric Labels

| Label   | Allowed Values | Description                           |
| ------- | -------------- | ------------------------------------- |
| version |                | Current version of Kyverno being used |

#### Use cases

- The cluster admin wants to see information related to Kyverno such as its version

#### Useful Queries

- `kyverno_info`
