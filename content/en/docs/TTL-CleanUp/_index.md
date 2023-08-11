---
title: "TTL CleanUp"
linkTitle: "TTL CleanUp"
weight: 50
description: >
    Assign label to the resources which will facilitate the scheduled deletion/cleanup of the resources from the cluster.
---



Kyverno offers a valuable feature that enables the cleanup (deletion) of existing cluster resources based on assigned label (`cleanup.kyverno.io/ttl`), apart from the [`CleanupPolicy`](/docs/writing-policies/cleanup), which makes it easier for the users to schedule the resource cleanup beforehand.

This feature also supports a unique capability known as "negative delay." This means that even if a user sets up a controller after labeling a resource, Kyverno can effectively identify and include that resource in its cleanup schedule. The resource deletion is then scheduled according to the specified timestamp found within the assigned label value.

<img src="/images/ttl-cleanup-structure.png" alt="ttl-cleanup" width="65%"/>