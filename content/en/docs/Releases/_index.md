---
title:  "Release"
weight: 55
description:  Kyverno Version Release Notes.
---

## Kyverno v1.4.2
**Note:** With Helm installed Kyverno, upgrading to Kyverno 1.4.2+ (Helm chart v2.0.2) from a version prior to 1.4.2 (Helm chart v2.0.2) will require extra steps. Please refer to the official doc for the upgrade.

## Kyverno v1.4.1
**Note:** To upgrade from 1.4.0, you will need to manually remove the selector app: kyverno from the Deployment or delete the Deployment and then upgrade to 1.4.1.

## Kyverno v1.4.0
**Note:** there was a selector app: kyverno added to the Deployment of the Kyverno Helm chart, it could impact the upgrade process as the selector field cannot be modified during an upgrade. This selector will be removed in 1.4.1, you can comment it out during the upgrade. Thanks to @andriktr for reporting the issue.
For HA, currently recommended minimum replicas is 3.



