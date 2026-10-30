---
title: High Availability
linkTitle: High Availability
sidebar:
  order: 140
excerpt: Understand the various components of Kyverno and how it impacts high availability.
---

Kyverno contains several different capabilities, decoupled into separate controllers, and each controller runs in its own Kubernetes Deployment. Installing Kyverno in a highly-available manner therefore requires additional replicas for each of the chosen controllers.

## Controllers in Kyverno

Kyverno consists of four different Deployments where each Deployment runs a controller of a single type. Each controller is responsible for one of the main capabilities within Kyverno as well as some supporting and related controllers.

### Admission Controller

- Receives AdmissionReview requests from the Kubernetes API server through validating and mutating webhooks.
- Processes validate, mutate, and image validating rules.
- Manages and renews certificates as Kubernetes Secrets for webhook use through the embedded Cert Renewer.
- Manages and configures webhook rules dynamically based on installed policies through the embedded Webhook Controller.
- Performs policy validation for the `ValidatingPolicy`, `ImageValidatingPolicy`, `MutatingPolicy`, `GeneratingPolicy`, `DeletingPolicy`, and `PolicyException` custom resources and their namespaced variants.
- Processes Policy Exceptions.
- Generates `EphemeralReport` and `ClusterEphemeralReport` intermediary resources for further processing by the Reports Controller.
- Generates `UpdateRequest` intermediary resources for further processing by the Background Controller.

### Reports Controller

- Responsible for creation and reconciliation of the final `PolicyReport` and `ClusterPolicyReport` custom resources.
- Performs background scans and generates, processes, and converts `EphemeralReport` and `ClusterEphemeralReport` intermediary resources into the final policy report resources.

### Background Controller

- Processes resource generation for `GeneratingPolicy` and mutation of existing resources for `MutatingPolicy`.
- Processes policy add, update, and delete events.
- Processes and generates `UpdateRequest` intermediary resources to generate or mutate the final resource.
- Generates `EphemeralReport` and `ClusterEphemeralReport` intermediary resources for further processing by the Reports Controller.
- Has no relationship to the Reports Controller for background scans.

### Cleanup Controller

- Processes scheduled resource deletion for [DeletingPolicy](/docs/policy-types/deleting-policy).
- Handles [TTL cleanup](/docs/guides/ttl-cleanup) of labeled resources.
- Deletes matching resources through the Kubernetes API, subject to the controller's permissions.

## How HA works in Kyverno

This section provides details on how Kyverno handles HA scenarios.

### Admission Controller

The Admission Controller is a required component of any Kyverno installation regardless of the type or size. Even if, for example, policy reporting is the only desirable feature, the admission controller must be installed.

The admission controller does not use leader election for inbound webhook requests which means AdmissionReview requests can be distributed and processed by all available replicas. The minimum supported replica count for a highly-available admission controller deployment is three. Leader election is required for certificate and webhook management functions so therefore only one replica will handle these tasks at a given time.

Multiple replicas configured for the admission controller can be used for both availability and scale of AdmissionReview processing. They do not shard the in-memory policy cache: every replica loads the full policy set. Vertical scaling of the individual replicas' resources may also be performed to increase combined throughput and to hold a large policy cache. See [Scaling Kyverno](/docs/installation/scaling#horizontal-scale) for how this interacts with policy count.

### Reports Controller

The Reports Controller is responsible for all report processing logic. Since this is a stateful service, the reports controller requires leader election. Regardless of the number of replicas, only a single replica will handle reports processing at any given time.

Multiple replicas configured for the reports controller can only be used for availability. Vertical scaling of the individual replicas' resources may also be performed to increase throughput but will only impact the processing done by leader.

### Background Controller

The Background Controller is responsible for handling of generate and mutate-existing rules. This is also a stateful service and therefore the background controller also requires leader election. Although the Admission Controller can handle multiple, concurrent UpdateRequest generations, regardless of the number of replicas only a single replica of the background controller will handle the final resource generation or, in the case of existing resources, mutation.

Multiple replicas configured for the background controller can only be used for availability. Vertical scaling of the replicas can be performed as well as increasing the number of internal workers used by these processes (`--genWorkers`). See the [container flags section](/docs/installation/customization#container-flags) for more details.

### Cleanup Controller

The Cleanup Controller processes scheduled deletions and TTL cleanup against the Kubernetes API. Configure replicas for availability and monitor deletion latency and controller resource usage when sizing this component. Additional replicas do not imply that the same scheduled deletion should run more than once.

## Installing Kyverno in HA mode

The Helm chart is the recommended method of installing Kyverno in a production-grade, highly-available fashion as it provides all the necessary Kubernetes resources and configuration options to meet most production needs. For more information on installation of Kyverno in high availability, see the corresponding [installation section](/docs/installation/installation#high-availability-installation).
