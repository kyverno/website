---
title: Background Scans 
description: >
  Manage aplying policies to existing resources in a cluster
weight: 9
---

Kyverno can validate existing resources in the cluster that may have been created before a policy was created. The application of policies to existing resources is referred to as `background scanning`. 

**Note: Kyverno does not mutate existing resources, to prevent inadvertent changes to workloads. Mutate and generate rules are not processed during background scans.** 

A policy is always enabled for processing during admission control. However, policy rules that rely on variable ``AdmissionReview`` request information (e.g. `{{request.userInfo}}`) cannot be applied to existing resources in the `background scanning` mode as the user information is not available. Hence, these rules must set the boolean flag `{spec.background}` to `false` to disable `background` scanning.

```
spec:
  background: true
  rules:
  - name: default-deny-ingress
```

The default value of `background` is `true`. 

When a policy is created or modified, the policy validation logic will report an error if a rule uses `userInfo` and does not set `background` to `false`.

