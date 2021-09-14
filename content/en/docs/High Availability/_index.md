---
title: "High Availability"
linkTitle: "High Availability"
weight: 10
description: >
  Learn how to configure High Availability in Kyverno
---

## Configure Kyverno in HA mode

## How HA works in Kyverno

- ### Module - Webhook Server
  Webhook server is where Kyverno receives and processes admission requests. This controller does not require a leader-election. When Kyverno runs multiple instances, the Service will distribute the admission requests across different instances. 

  For “mutate” and “validate” enforce policies, Kyverno returns the decision along with the admission response; it is a synchronous request-response process. However, for “generate” and “validate” audit policies, Kyverno pushes these requests to a queue, and returns the response immediately, and then starts processing the data asynchronously. 

  If the process is terminated, we need to complete pending requests / drain the queue and then shutdown Kyverno gracefully.

  **Updated:** the queue in the validate audit handler is used to generate policy reports. Since the report will be reconciled when Kyverno restarts, there’s no need to drain this queue on shutdown.

  The remaining components (listed below) will need to enable leader election to support HA, we will use this library [client-go/tools/leaderelection](https://pkg.go.dev/k8s.io/client-go/tools/leaderelection) to enable it. The library is used by kube-controller-manager, kube-scheduler, etc. Notice that this library “does not guarantee that only one client is acting as a leader (a.k.a. fencing)”, so we have to design in a way that even if the same process gets executed twice, the results are consistent.
- ### Module - Webhook Register / Webhook Monitor / Certificate Renewer
  In latest v1.3.6-rc1, the webhook register, webhook monitor and certificate renewer are managed in the same package. The minimum requirement is to enable leader election for the webhook register to register the webhook configurations. 

  Updated (v1.4.0-beta1): both webook register and certificate renewer have enabled leader election.  The webhook monitor runs across all instances as it maintains an internal webhook timestamp to monitor the webhook status. Note the monitor also re-creates the webhook configurations if any is missing, currently it is checked every 30s.

  
- ### Module - Generate Controller
  A generate policy is processed in two phases: 

  1. the webhook server receives the source (trigger) resource, build and create (to etcd) a GenerateRequest object base on the admission request; 

  2. The generate controller receives the event for GenerateRequest, then starts processing it (generating target resource).

  The leader election needs to be added in the generate controller

  
- ### Module - Policy Controller
  The policy controller does two things:

  1. Updates GenerateRequests on generate policy updates
  2. Builds and creates ReportChangeRequests on validate policy updates, the policy report controller watches the events of ReportChangeRequest to generate policy reports.

  Both policy controller and policy report controller have enabled leader election.
