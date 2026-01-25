---
title: 'Kyverno Issues on EKS'
linkTitle: 'Kyverno Issues EKS'
description: >
  Troubleshoot Kyverno webhook failures and resource validation issues on EKS clusters
weight: 90
---

**Symptom**: I'm an EKS user and I'm finding that resources that should be blocked by a Kyverno policy are not. My cluster does not use the VPC CNI.

**Solution**: When using EKS with a custom CNI plug-in (ex., Calico), the Kyverno webhook cannot be reached by the API server because the control plane nodes, which cannot use a custom CNI, differ from the configuration of the worker nodes, which can. In order to resolve this, when installing Kyverno via Helm, set the `hostNetwork` option to `true`. See also [this note](https://cert-manager.io/docs/installation/compatibility/#aws-eks). AWS lists the alternate compatible CNI plug-ins [here](https://docs.aws.amazon.com/eks/latest/userguide/alternate-cni-plugins.html).

**Symptom**: When creating Pods or other resources, I receive similar errors like `Error from server (InternalError): Internal error occurred: failed calling webhook "validate.kyverno.svc-fail": Post "https://kyverno-svc.kyverno.svc:443/validate?timeout=10s": context deadline exceeded`.

**Solution**: When using EKS with the VPC CNI, problems may arise if the CNI plug-in is outdated. Upgrade the VPC CNI plug-in to a version supported and compatible with the Kubernetes version running in the EKS cluster.

If the EKS cluster uses your own security group, some of the network traffic from the control plane to the worker nodes might be blocked (documented [here](https://docs.aws.amazon.com/eks/latest/userguide/sec-group-reqs.html)). Create an inbound rule in the security group attached to the EKS worker nodes, allowing communication on port 9443 from the EKS cluster security group.
