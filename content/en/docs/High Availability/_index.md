---
title: "High Availability"
linkTitle: "High Availability"
weight: 120
description: >
  Learn how to configure High Availability in Kyverno
---

## Configure Kyverno in HA mode

 To install Kyverno in HA using Helm Chart.
  
  **NOTE:** Due to some complexities accompanied with running 2 replicas, the recommended replica counts for HA is at least 3.

 ```sh
 helm install kyverno kyverno/kyverno --create-namespace --set=replicaCount=3 
 ```
### How HA works in Kyverno

 This section provides details on how Kyverno handles HA scenarios.

 **Module - Webhook Server**

   Webhook server is where Kyverno receives and processes admission requests. This controller does not require a leader-election. When Kyverno runs multiple instances, the Service will distribute the admission requests across different instances. 

   For `mutate` and `validate` enforce policies, Kyverno returns the decision along with the admission response; it is a synchronous request-response process. However, for `generate` and “validate” audit policies, Kyverno pushes these requests to a queue, and returns the response immediately, and then starts processing the data asynchronously. The queue in the validate audit handler is used to generate policy reports. 
   
   Since the report will be reconciled when Kyverno restarts, there’s no need to drain this queue on shutdown. If the process is terminated, we need to complete pending requests / drain the queue and then shutdown Kyverno gracefully.

  
   The remaining components (listed below) will need to enable leader election to support HA, we will use this library [client-go/tools/leaderelection](https://pkg.go.dev/k8s.io/client-go/tools/leaderelection) to enable it.
   The library is used by kube-controller-manager, kube-scheduler, etc. Notice that this library does not guarantee that only one client is acting as a leader (a.k.a. fencing), so we have to design in a way that even if the same process gets executed twice, the results are consistent.

**Module - Webhook Register / Webhook Monitor / Certificate Renewer**

   In v1.3.6, the webhook register, webhook monitor and certificate renewer are managed in the same package. The minimum requirement is to enable leader election for the webhook register to register the webhook configurations. 

   V1.4.0: Both webhook register and certificate renewer have enabled leader election.  The webhook monitor runs across all instances as it maintains an internal webhook timestamp to monitor the webhook status. The monitor also recreates the webhook configurations if any are missing. The check is currently performed every 30 seconds.

  
 **Module - Generate Controller**

  A generate policy is processed in two phases: 

  1. The webhook server receives the source (triggering) resource and creates a GenerateRequest object based on the admission request; 

  2. The generate controller receives the event for GenerateRequest, then starts processing it (generating target resource).

  The leader election is enabled for the Generate Controller.
  That is to say, there will only be one instance processing the GR if Kyverno is configured with multiple replicas.
  
**Module - Policy Controller**

  The policy controller does two things:

  1. Updates GenerateRequests on generate policy updates.
  2. Builds and creates ReportChangeRequests on validate policy updates. 
  3. The policy report controller watches the events of ReportChangeRequest to generate policy reports.

  Both policy controller and policy report controller have enabled leader election.
