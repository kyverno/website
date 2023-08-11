---
title: Working Logic
description: Explanation of the working of ttl controller.
weight: 35
---

The ttl controller is composed of the ttl-manager, a pivotal component responsible for initiating and terminating dedicated controllers tailored to handle various resources, both Kubernetes-specific and custom resources. These actions are guided by the resources' admission into the system and the associated RBAC permissions.

The manager continually monitors the entire cluster, keeping a vigilant eye on newly introduced resource types. It also ensures that these resources possess sufficient permissions before triggering the setup of a dedicated controller dedicated to their management. Importantly, if permissions are altered for existing resources, the manager takes the initiative to gracefully halt the corresponding dedicated controller. This principle also extends to scenarios involving the admission or removal of resource definitions within the cluster.

To maintain operational integrity, the manager inherently conducts reconciliations at default intervals of every 1 minute. These reconciliations serve to validate the smooth functioning of resource-specific controllers. If desired, you have the flexibility to personalize the frequency of these reconciliations using a flag called [`ttlReconciliationInterval`](/docs/Installation/customization.md).

<img src="/images/ttl-manager-working.png" alt="ttl-manager-working" width="65%"/>