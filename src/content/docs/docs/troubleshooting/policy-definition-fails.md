---
title: 'Policy Definition Fails'
weight: 120
description: >
  Diagnose and fix issues with non-functional Kyverno policies.
---

**Symptom**: My policy _seems_ like it should work based on how I have authored it but it doesn't.

**Solution**: There can be many reasons why a policy may fail to work as intended, assuming other policies work. One of the most common reasons is that the API server is sending different contents than what you have accounted for in your policy. To see the full contents of the AdmissionReview request the Kubernetes API server sends to Kyverno, add the `dumpPayload` [container flag](/docs/installation/customization#container-flags) set to `true` and check the logs. This has performance impact so it should be removed or set back to `false` when complete.

The second most common reason policies may fail to operate per design is due to variables. To see the values Kyverno is substituting for variables, increase logging to level `4` by setting the container flag `-v=4`. You can `grep` for the string `variable` (or use tools such as [stern](https://github.com/stern/stern)) and only see the values being substituted for those variables.
