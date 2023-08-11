---
title: Configuring Controller
description: Configuration options for a TTL-Controller installation.
weight: 25
---

In order for the ttl-controller to function correctly, it's essential to grant the controller specific permissions: the ability to list, watch, and delete resources. This can be achieved by providing these permissions within the helm chart for the cleanup-controller. The configuration file for the helm chart, which contains these settings, can be accessed [`here`](https://github.com/kyverno/kyverno/blob/main/charts/kyverno/values.yaml#L1170C9-L1170C9).

Within this configuration file, you have the option to define the precise permissions that the cleenup-controller requires. This includes specifying the types of resources for which the controller should have these permissions being the part of the cleanup-controller these permissions will automatically give access to the ttl-controller to work properly. By setting up these permissions appropriately, you enable the ttl-controller to effectively carry out its tasks, ensuring that it can identify, monitor, and delete resources as needed.