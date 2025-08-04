---
title: Kyverno Slow Response
description: >
  Resolve slow Kyverno operations caused by API throttling.
weight: 50
---


**Symptom**: Kyverno's operation seems slow in either mutating resources or validating them, causing additional time to create resources in the Kubernetes cluster.

**Solution**: Check the Kyverno logs for messages about throttling. If many are found, this indicates Kyverno is making too many API calls in too rapid a succession which the Kubernetes API server will throttle. Increase the values, or set the [flags](/docs/installation/customization.md#container-flags), `--clientRateLimitQPS` and `--clientRateLimitBurst`. While these flags have very sensible values after much field trials, in some cases they may need to be increased.