---
title: Kyverno OOMKills
description: >
  Troubleshoot high resource usage or OOMKills caused by Kyverno policies.
weight: 30
---

**Symptom**: Kyverno is using too much memory or CPU. How can I understand what is causing this?

**Solution**: It is important to understand how Kyverno experiences and processes work to determine if what you deem as "too much" is, in fact, too much. Kyverno dynamically configures its webhooks (by default but configurable) according the policies which are loaded and on what resources they match. There is no straightforward formula where resource requirements are directly proportional to, for example, number of Pods or Nodes in a cluster. The following questions need to be asked and answered to build a full picture of the resources consumed by Kyverno.

1. What policies are in the cluster and on what types of resources do they match? Policies which match on wildcards (`"*"`) cause a tremendous load on Kyverno and should be avoided if possible as they instruct the Kubernetes API server to send to Kyverno _every action on every resource_ in the cluster. Even if Kyverno does not have matching policies for most of these resources, it is _required_ to respond to every single one. If even one policy matches on a wildcard, expect the resources needed by Kyverno to easily double, triple, or more.
2. Which controller is experiencing the load? Each Kyverno controller has different responsibilities. See the [controller guide](../high-availability/_index.md#controllers-in-kyverno) for more details. Each controller can be independently scaled, but before immediately scaling in any direction take the time to study the load.
3. Are the default requests and limits still in effect? It is possible the amount of load Kyverno (any of its controllers) is experiencing is beyond the capabilities of the default requests and limits. These defaults have been selected based on a good mix of real-world usage and feedback but **may not suit everyone**. In extremely large and active clusters, from Kyverno's perspective, you may need to increase these.
4. What do your monitoring metrics say? Kyverno is a critical piece of cluster infrastructure and must be monitored effectively just like other pieces. There are several metrics which give a sense of how active Kyverno is, the most important being [admission request count](../monitoring/admission-requests.md). Others include consumed memory and CPU utilization. Sizing should always be done based on peak consumption and not averages.
5. Have you checked the number of pending update requests when using generate or mutate existing rules? In addition to the admission request count metric, you can use `kubectl -n kyverno get updaterequests` to get a sense of the request count. If there are many requests in a `Pending` status this could be a sign of a permissions issue or, for clone-type generate rules with synchronization enabled, excessive updates to the source resource. Ensure you grant the background controller the required permissions to the resources and operations it needs, and ensure Kyverno is able to label clone sources.

You can also follow the steps on the [Kyverno wiki](https://github.com/kyverno/kyverno/wiki/Profiling-Kyverno-on-Kubernetes) for enabling memory and CPU profiling.