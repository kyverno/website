---
title: 'Partial Policy Application'
linkTitle: 'Partial Policy Application'
description: >
  Resolve issues where only some Kyverno policies are applied.
weight: 60
---

**Symptom**: Kyverno is working for some policies but not others. How can I see what's going on?

**Solution**: The first thing is to check the logs from the Kyverno Pod to see if it describes why a policy or rule isn't working.

1. Check the Pod logs from Kyverno. Assuming Kyverno was installed into the default Namespace called `kyverno` use the command `kubectl -n kyverno logs <kyverno_pod_name>` to show the logs. To watch the logs live, add the `-f` switch for the "follow" option.

2. If no helpful information is being displayed at the default logging level, increase the level of verbosity by editing the Kyverno Deployment. To edit the Deployment, assuming Kyverno was installed into the default Namespace, use the command `kubectl -n kyverno edit deploy kyverno-<controller_type>-controller`. Find the `args` section for the container named `kyverno` and either add the `-v` switch or increase to a higher level. The flag `-v=6` will increase the logging level to its highest. Take care to revert this change once troubleshooting steps are concluded.
