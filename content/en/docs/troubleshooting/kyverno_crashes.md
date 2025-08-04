---
title: Kyverno Crashes 
description: >
  Learn how to address Kyverno crashes in large clusters by adjusting memory limits and monitoring resource usage.
weight: 70
---

**Symptom**: I have a large cluster with many objects and many Kyverno policies. Kyverno is seen to sometimes crash.

**Solution**: In cases of very large scale, it may be required to increase the memory limit of the Kyverno Pod so it can keep track of these objects.

1. First, see the [troubleshooting section](/docs/troubleshooting/kyverno_oomkills/). If changes are required, edit the necessary Kyverno Deployment and increase the memory limit on the container. Change the `resources.limits.memory` field to a larger value. Continue to monitor the memory usage by using something like the [Kubernetes metrics-server](https://github.com/kubernetes-sigs/metrics-server#installation).
