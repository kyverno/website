---
title: Admission Reports Overloaded
description: >
  Resolve accumulating admission reports affecting etcd and cluster performance.
weight: 120
---

**Symptom**: Admission reports keep accumulating in the cluster, taking more and more etcd space and slowing down requests.

**Diagnose**: Please follow the [troubleshooting docs](https://github.com/kyverno/kyverno/blob/main/docs/dev/troubleshooting/reports.md) to determine if you are affected by this issue.

**Solution**: Admission reports can accumulate if the reports controller is not working properly so the first thing to check is if the reports controller is running and does not continuously restarts. If the controller works as expected, another potential cause is that it fails to aggregate admission reports fast enough. This usually happens when the controller is throttled. You can fix this by increasing QPS and burst rates for the controller by setting `--clientRateLimitQPS=500` and `--clientRateLimitBurst=500`.
Note that starting with Kyverno 1.10, two cron jobs are responsible for deleting admission reports automatically if they accumulate over a certain threshold.
