---
title: 'Kyverno Crashes'
linkTitle: 'Resolve Kyverno Crashes'
weight: 70
description: >
  Resolve Kyverno crashes caused by insufficient memory in large clusters.
---

**Symptom**: I have a large cluster with many objects and many Kyverno policies. Kyverno is seen to sometimes crash.

**Solution**: In cases of very large scale, it may be required to increase the memory limit of the Kyverno Pod so it can keep track of these objects.

1. First, see the [above troubleshooting section](#kyverno-consumes-a-lot-of-resources-or-i-see-oomkills). If changes are required, edit the necessary Kyverno Deployment and increase the memory limit on the container. Change the `resources.limits.memory` field to a larger value. Continue to monitor the memory usage by using something like the [Kubernetes metrics-server](https://github.com/kubernetes-sigs/metrics-server#installation).
