---
title: Troubleshooting
LinkTitle: Troubleshooting
description: >
  Processes for troubleshooting and recovery of Kyverno.
sidebar:
  order: 130
---

Although Kyverno's goal is to make policy simple, sometimes trouble still strikes. The following sections can be used to help troubleshoot and recover when things go wrong.

## Troubleshooting Guides

- **[CEL Expressions](/docs/troubleshooting/cel-expressions/)** - Debug and troubleshoot CEL expressions in policies
- **[General Kyverno Issues](/docs/guides/troubleshooting#api-server-blocked)** - Common Kyverno operational issues

## API Server Blocked

**[API Server Blocked](/docs/troubleshooting/api-server-blocked/)** - To resolve API server blockages.

## Policies Not Applied

**[Policies Not Applied](/docs/troubleshooting/policies-not-applied/)** - Troubleshoot and fix issues where Kyverno policies are not applied.

## Kyverno OOMKills

**[Kyverno OOMKills](/docs/troubleshooting/kyverno-oomkills/)** - Troubleshoot high resource usage or OOMKills caused by Kyverno policies.

## AKS Webhook Configuration

**[AKS Webhook Configuration](/docs/troubleshooting/aks-webhook-config/)** - Kyverno on AKS is consuming excessive CPU or memory.

## Kyverno Slow Response

**[Kyverno Slow Response](/docs/troubleshooting/kyverno-slow-response/)** - Resolve slow Kyverno operations caused by API throttling.

## Partial Policy Application

**[Partial Policy Application](/docs/troubleshooting/partial-policy-application)** - Resolve issues where only some Kyverno policies are applied.

## Client-Side Throttling

**[Client-Side Throttling](/docs/troubleshooting/client-side-throttling/)** - Resolve delays in resource creation caused by Kyverno's client-side throttling.

## Kyverno Crashes

**[Kyverno Crashes](/docs/troubleshooting/kyverno-crashes/)** - Resolve Kyverno crashes caused by insufficient memory in large clusters.

## Kyverno Issues on GKE

**[Kyverno Issues on GKE](/docs/troubleshooting/kyverno-fails-gke/)** - Troubleshoot Kyverno webhook failures on GKE private clusters with firewall rule adjustments.

## Kyverno Issues on EKS

**[Kyverno Fails on EKS](/docs/troubleshooting/kyverno-fails-eks/)** - Troubleshoot Kyverno webhook failures and resource validation issues on EKS clusters.

## Policy Definition Fails

**[Policy Definition Fails](/docs/troubleshooting/policy-definition-fails/)** - Diagnose and fix issues with non-functional Kyverno policies.

## Admission Reports Overloaded

**[Admission Reports Overloaded](/docs/troubleshooting/admission-report-overloaded/)** - Resolve accumulating admission reports affecting etcd and cluster performance.

## Kyverno Lacks Permissions

**[Kyverno Lacks Permissions](/docs/troubleshooting/kyverno-lacks-permissions/)** - Troubleshoot and fix Kyverno's permission issues during policy creation.
