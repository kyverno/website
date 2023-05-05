---
title: High Availability
linkTitle: High Availability
weight: 120
description: >
  Understand the various components of Kyverno and how it impacts high availability.
---

Kyverno contains several different capabilities, decoupled into separate controllers, and each controller runs in its own Kubernetes Deployment. Installing Kyverno in a highly-available manner therefore requires additional replicas for each of the chosen controllers.

## Controllers in Kyverno

Kyverno consists of four different Deployments where each Deployment runs a controller of a single type. Each controller is responsible for one of the main capabilities within Kyverno as well as some supporting and related controllers.

### Admission Controller

* Responsible for receiving AdmissionReview requests from the Kubernetes API server to its resource validating and mutating webhooks.
* Processes validate, mutate, and verifyImages rules.
* Manages and renews certificates as Kubernetes Secrets for use in the webhook.
* Manages and configures the webhook rules dynamically based on installed policies.
* Performs policy validation for the `Policy`, `ClusterPolicy`, and `PolicyException` custom resources.
* Processes Policy Exceptions.
* Generates `AdmissionReport` and `ClusterAdmissionReport` intermediary resources for further processing by the Reports Controller.
* Generates `UpdateRequest` intermediary resources for further processing by the Background Controller.

### Reports Controller

* Responsible for creation and reconciliation of the final `PolicyReport` and `ClusterPolicyReport` custom resources.
* Performs background scans and generates and processes `BackgroundScanReport` and `ClusterBackgroundScanReport` intermediary resources.
* Processes `AdmissionReport` and `ClusterAdmissionReport` intermediary resources into the final policy report resources.

### Background Controller

* Responsible for processing generate and mutate-existing rules.
* Processes policy add, update, and delete events.
* Processes `UpdateRequest` intermediary resources to generate the final resource.
* Has no relationship to the Reports Controller for background scans.

### Cleanup Controller

* Responsible for processing cleanup policies.
* Performs policy validation for the `CleanupPolicy` and `ClusterCleanupPolicy` custom resources through a webhook server.
* Responsible for reconciling its webhook through a webhook controller.
* Manages and renews certificates as Kubernetes Secrets for use in the webhook.
* Creates and reconciles CronJobs used as the mechanism to trigger cleanup.
* Handles the cleanup by deleting resources from the Kubernetes API.

## How HA works in Kyverno

This section provides details on how Kyverno handles HA scenarios.

### Admission Controller

The Admission Controller is a required component of any Kyverno installation regardless of the type or size. Even if, for example, policy reporting is the only desirable feature, the admission controller must be installed.

The admission controller does not use leader election for inbound webhook requests which means AdmissionReview requests can be distributed and processed by all available replicas. The minimum supported replica count for a highly-available admission controller deployment is three. Leader election is required for certificate and webhook management functions so therefore only one replica will handle these tasks at a given time.

Multiple replicas configured for the admission controller can be used for both availability and scale. Vertical scaling of the individual replicas' resources may also be performed to increase combined throughput.

### Reports Controller

The Reports Controller is responsible for all report processing logic. Since this is a stateful service, the reports controller requires leader election. Regardless of the number of replicas, only a single replica will handle reports processing at any given time.

Multiple replicas configured for the reports controller can only be used for availability. Vertical scaling of the individual replicas' resources may also be performed to increase throughput but will only impact the processing done by leader.

### Background Controller

The Background Controller is responsible for handling of generate and mutate-existing rules. This is also a stateful service and therefore the background controller also requires leader election. Although the Admission Controller can handle multiple, concurrent UpdateRequest generations, regardless of the number of replicas only a single replica of the background controller will handle the final resource generation or, in the case of existing resources, mutation.

Multiple replicas configured for the background controller can only be used for availability. Vertical scaling of the replicas can be performed as well as increasing the number of internal workers used by these processes (`--genWorkers`). See the [container flags section](/docs/installation/#container-flags) for more details.

### Cleanup Controller

The Cleanup Controller is responsible for handling of the cleanup policies via creation of the intermediate CronJobs and performing the actual deletions against the API server. It has components which require leader election (certificate and webhook management) and those which do not (cleanup handler).

Multiple replicas configured for the cleanup controller can be used for both availability and scale. Clusters with many concurrent cleanup invocations will see increased throughput when multiple replicas are configured, however only a single replica will handle a given deletion according to a cleanup rule as CronJobs are created and managed on a 1:1 basis. Vertical scaling of the individual replicas' resources may also be performed to increase combined job throughput.

## Controller Internals

The internal processes/functions of each controller are explained below.

### Admission Controller

The Admission Controller is where the "heart" of Kyverno's processing logic for most policy types is found. It is a required component of any Kyverno installation.

#### Webhook Server

The webhook server is where Kyverno receives and processes AdmissionReview requests which are sent in response to policies and their matching resources. For mutate and validate rules in `Enforce` mode, Kyverno returns the decision along with the admission response; it is a synchronous request-response process. However, for generate and validate rules in `Audit` mode, Kyverno pushes these requests to a queue and returns the response immediately, then starts processing the data asynchronously. The queue in the validate audit handler is used to generate policy reports.

The webhook server also performs validation for all policies except cleanup policies.

#### Webhook Controller

The webhook controller is responsible for configuring the various webhooks. These webhooks, by default managed dynamically, instruct the Kubernetes API server which resources to send to Kyverno. The webhook controller uses leader election as it maintains an internal webhook timestamp to monitor the webhook status. The controller also recreates the webhook configurations if any are missing.

#### Cert Renewer

The certificate renewer controller is responsible for monitoring the Secrets Kyverno uses for its webhooks. This controller uses leader election.

#### Exceptions Controller

Policy Exceptions are processed in this component so that matching resources of installed policies which also match a Policy Exception are handled properly.

#### UpdateRequest Generator

The UpdateRequest is an intermediary resource used by the Background Controller in handling of generate and mutate-existing rules. UpdateRequests are synchronously generated inside this component and then asynchronously processed by the Background Controller.

#### AdmissionReport Generator

An AdmissionReport is an intermediary resource used by the Reports Controller to create and reconcile the final policy reports. They are created in this component in response to an incoming AdmissionReview request which matches an installed policy.

### Background Controller

The Background Controller handles generate and mutate rules only for existing resources. It has no relationship to the background report scanning which occurs in the Reports Controller.

#### UpdateRequest Controller

This controller reconciles the UpdateRequests created by the Admission Controller into their final form, whether that is a generated resource or a mutated existing resource.

#### Policy Controller

The policy controller processes all adds, deletes, and updates to all installed policies.

### Reports Controller

The report controller is responsible for creation of policy reports from both admission requests and background scans and requires leader election. It track resources that need to be processed in the background and generates background scan reports (when policy/resource change). It also aggregates these and the intermediary admission reports into the final policy report resources `PolicyReport` and `ClusterPolicyReport`.

#### Background Scan Controller

This component performs all the background scans in a cluster when the designated interval elapses and creates the intermediary resources `BackgroundScanReport` and `ClusterBackgroundScanReport`.

#### AdmissionReport Aggregator

This component takes the synchronously-generated AdmissionReport resources from the Admission Controller and aggregates them into a second intermediary AdmissionReport resource on a per-resource basis.

#### Policy Report Aggregator

This component aggregates both the background and admission intermediary reports into the final resources `PolicyReport` and `ClusterPolicyReport`.

### Cleanup Controller

The Cleanup Controller performs all the cleanup (deletion) tasks as a result of a `CleanupPolicy` or `ClusterCleanupPolicy`. It is the only other controller aside from the Admission Controller which uses and manages webhooks.

#### Webhook Server

This component validates `CleanupPolicy` and `ClusterCleanupPolicy` resources and serves as the endpoint for CronJobs to invoke the cleanup handler.

#### Webhook Controller

The webhook controller updates the webhook used by the cleanup controller when the Secret changes. This component also uses leader election.

#### Cleanup Handler

The cleanup handler deletes resources which match cleanup policies in response to being invoked by a CronJob.

#### CronJob Controller

In the cleanup process, the CronJob controller reconciles cleanup policies and existing CronJobs from installed cleanup policies. It requires leader election.

#### Cert Renewer

The certificate renewer controller is responsible for monitoring the Secrets used in the cleanup controller's webhooks. This controller uses leader election.

## Installing Kyverno in HA mode

The Helm chart is the recommended method of installing Kyverno in a production-grade, highly-available fashion as it provides all the necessary Kubernetes resources and configuration options to meet most production needs. For more information on installation of Kyverno in high availability, see the corresponding [installation section](/docs/installation/#high-availability).
