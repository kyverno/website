---
title: High Availability
linkTitle: High Availability
weight: 120
description: >
  Understand how to deploy high availability and how it works across Kyverno.
---

## Configure Kyverno in HA mode

To install Kyverno in HA using the Helm Chart.

**NOTE:** For high availability, the only supported replica count is 3.

```sh
helm install kyverno kyverno/kyverno -n kyverno --create-namespace --set=replicaCount=3 
```

### How HA works in Kyverno

This section provides details on how Kyverno handles HA scenarios.

#### Webhook Server

The webhook server is where Kyverno receives and processes admission requests. This controller does not require leader election. When Kyverno runs multiple instances, the Kubernetes Service will distribute the admission requests across different Kyverno instances.

For `mutate` and `validate` rules in `Enforce` mode, Kyverno returns the decision along with the admission response; it is a synchronous request-response process. However, for `generate` and `validate` rules in `Audit` mode, Kyverno pushes these requests to a queue and returns the response immediately, then starts processing the data asynchronously. The queue in the `validate` audit handler is used to generate policy reports.

Since the report will be reconciled when Kyverno restarts, there's no need to drain this queue on shutdown. If the process is terminated, we need to complete pending requests / drain the queue and then shutdown Kyverno gracefully.

The library is used by kube-controller-manager, kube-scheduler, etc. Notice that this library does not guarantee that only one client is acting as a leader (a.k.a. fencing), so we have to design in a way that even if the same process gets executed twice, the results are consistent.

#### Cert Renewer

The certificate renewer controller is responsible for monitoring the Secrets Kyverno uses for its webhooks. This controller also uses leader election.

#### Webhook Controller

The webhook controller is responsible for configuring the various webhooks. These webhooks, by default managed dynamically, instruct the Kubernetes API server which resources to send to Kyverno. The webhook controller uses leader election as it maintains an internal webhook timestamp to monitor the webhook status. The controller also recreates the webhook configurations if any are missing.

#### Background Controller

The background controller is responsible for handling UpdateRequest resources (an intermediary resource used by generate and mutate-existing rules) and processing rules in background scanning mode. The background controller does not require leader election.

#### Report Controller

The report controller is responsible for creation of policy reports from both admission requests and background scans and requires leader election.

#### Cleanup - Webhook Server

In the cleanup controller, the webhook server reconciles cleanup policies and existing CronJobs. It does not require leader election.

#### Cleanup - Cleanup controller

The cleanup controller applies cleanup policies to generate CronJobs and reconciles existing CronJobs when they change. This component does require leader election.

#### Cleanup - Cert Manager

The cert manager manages the certificates stored as Secrets and does require leader election.

#### Cleanup - Webhook Monitor

The webhook config monitor updates the webhook used by the cleanup controller when the Secret changes. This component also uses leader election.
