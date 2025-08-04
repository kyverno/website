---
title: AKS Webhook Issues
description: >
  Resolve high memory usage or audit log noise in AKS caused by interaction between Kyverno webhooks and the AKS Admissions Enforcer.
weight: 40
---

**Symptom**: I'm using AKS and Kyverno is using too much memory or CPU or produces many audit logs

**Solution**: On AKS the Kyverno webhooks will be mutated by the AKS [Admissions Enforcer](https://learn.microsoft.com/en-us/azure/aks/faq#can-admission-controller-webhooks-impact-kube-system-and-internal-aks-namespaces) plugin, that can lead to an endless update loop. To prevent that behavior, set the annotation `"admissions.enforcer/disabled": true` to all Kyverno webhooks. When installing via Helm, the annotation can be added with `config.webhookAnnotations`. As of Kyverno 1.12, this configuration is enabled by default.