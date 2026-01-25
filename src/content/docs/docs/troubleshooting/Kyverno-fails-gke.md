---
title: 'Kyverno Issues on GKE'
linkTitle: 'Kyverno Issues GKE'
weigth: 80
description: >
  Troubleshoot Kyverno webhook failures on GKE private clusters with firewall rule adjustments.
---

**Symptom**: I'm using GKE and after installing Kyverno, my cluster is either broken or I'm seeing timeouts and other issues.

**Solution**: Private GKE clusters do not allow certain communications from the control planes to the workers, which Kyverno requires to receive webhooks from the API server. In order to resolve this issue, create a firewall rule which allows the control plane to speak to workers on the Kyverno TCP port which, by default at this time, is 9443. For more details, see the [GKE documentation](https://cloud.google.com/kubernetes-engine/docs/how-to/private-clusters#add_firewall_rules).
