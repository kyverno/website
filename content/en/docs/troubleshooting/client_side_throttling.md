---
title: Client-Side Throttling
description: >
  Resolve delays in resource creation caused by Kyverno's client-side throttling.
weight: 100
---

**Symptom**: Kyverno pods emit logs stating `Waited for <n>s due to client-side throttling`; the creation of mutated resources may be delayed.

**Solution**: Try increasing `clientRateLimitBurst` and `clientRateLimitQPS` (documented [here](/docs/installation/customization.md#container-flags)). If that doesn't resolve the problem, you can experiment with slowly increasing these values. Just bear in mind that higher values place more pressure on the Kubernetes API (the client-side throttling was implemented for a reason), which could result in cluster-wide latency, so proceed with caution.