---
title: "Installation"
linkTitle: "Installation"
weight: 20
description: >
  Understand how to install and configure Kyverno.
---

Kyverno provides multiple methods for installation: Helm and YAML manifest. When installing in a production environment, Helm is the recommended and most flexible method as it offers convenient configuration options to satisfy a wide range of customizations. Regardless of the method, Kyverno must always be installed in a dedicated Namespace; it must not be co-located with other applications in existing Namespaces including system Namespaces such as `kube-system`. The Kyverno Namespace should also not be used for deployment of other, unrelated applications and services.

The diagram below shows a typical Kyverno installation featuring all available controllers.

<img src="/images/kyverno-installation.png" alt="Kyverno Installation" width="80%"/>
<br/><br/>

A standard Kyverno installation consists of a number of different components, some of which are optional.

* **Deployments**
  * Admission controller (required): The main component of Kyverno which handles webhook callbacks from the API server for verification, mutation, [Policy Exceptions](/docs/writing-policies/exceptions/), and the processing engine.
  * Background controller (optional): The component responsible for processing of generate and mutate-existing rules.
  * Reports controller (optional): The component responsible for handling of [Policy Reports](/docs/policy-reports/).
  * Cleanup controller (optional): The component responsible for processing of [Cleanup Policies](/docs/writing-policies/cleanup/).
* **Services**
  * Services needed to receive webhook requests.
  * Services needed for monitoring of metrics.
* **ServiceAccounts**
  * One ServiceAccount per controller to segregate and confine the permissions needed for each controller to operate on the resources for which it is responsible.
* **ConfigMaps**
  * ConfigMap for holding the main Kyverno configuration.
  * ConfigMap for holding the metrics configuration.
* **Secrets**
  * Secrets for webhook registration and authentication with the API server.
* **Roles and Bindings**
  * Roles and ClusterRoles, Bindings and ClusterRoleBindings authorizing the various ServiceAccounts to act on the resources in their scope.
* **Webhooks**
  * ValidatingWebhookConfigurations for receiving both policy and resource validation requests.
  * MutatingWebhookConfigurations for receiving both policy and resource mutating requests.
      * Note: Webhook operations per resource is dynamically set if there are match/exclude operations mentioned in the policies applied. If for a resource no operations are set in match or exclude blocks, all default operations are applied in the webhooks rules.
* **CustomResourceDefinitions**
  * CRDs which define the custom resources corresponding to policies, reports, and their intermediary resources.

## Compatibility Matrix

Kyverno follows the same support policy as the Kubernetes project which is an N-2 policy in with the three latest minor releases are maintained. Although previous versions may work, they are not tested and therefore no guarantees are made as to their full compatibility. Kyverno also follows a similar strategy for support of Kubernetes itself. The below table shows the compatibility matrix.

| Kyverno Version                | Kubernetes Min | Kubernetes Max |
|--------------------------------|----------------|----------------|
| 1.6.x                          | 1.16           | 1.23           |
| 1.7.x                          | 1.21           | 1.23           |
| 1.8.x                          | 1.23           | 1.25           |
| 1.9.x                          | 1.24           | 1.26           |
| 1.10.x                         | 1.24           | 1.26           |
| 1.11.x                         | 1.25           | 1.28           |

\* Due to a known issue with Kubernetes 1.23.0-1.23.2, support for 1.23 begins at 1.23.3.

**NOTE:** The [Enterprise Kyverno](https://nirmata.com/kyverno-enterprise/) by Nirmata supports a wide range of Kubernetes versions for any Kyverno version. Refer to the Release Compatibility Matrix for the Enterprise Kyverno [here](https://docs.nirmata.io/n4k/release-compatibility-matrix/) or contact [Nirmata support](mailto:support@nirmata.com) for assistance.

## Security vs Operability

For a production installation, Kyverno should be installed in [high availability mode](/docs/installation/methods/#high-availability). Regardless of the installation method used for Kyverno, it is important to understand the risks associated with any webhook and how it may impact cluster operations and security especially in production environments. Kyverno configures its resource webhooks by default (but [configurable](/docs/writing-policies/policy-settings/)) in [fail closed mode](https://kubernetes.io/docs/reference/access-authn-authz/extensible-admission-controllers/#failure-policy). This means if the API server cannot reach Kyverno in its attempt to send an AdmissionReview request for a resource that matches a policy, the request will fail. For example, a validation policy exists which checks that all Pods must run as non-root. A new Pod creation request is submitted to the API server and the API server cannot reach Kyverno. Because the policy cannot be evaluated, the request to create the Pod will fail. Care must therefore be taken to ensure that Kyverno is always available or else configured appropriately to exclude certain key Namespaces, specifically that of Kyverno's, to ensure it can receive those API requests. There is a tradeoff between security by default and operability regardless of which option is chosen.

The following combination may result in cluster inoperability if the Kyverno Namespace is not excluded:

1. At least one Kyverno rule matching on `Pods` is configured in fail closed mode (the default setting).
2. No Namespace exclusions have been configured for at least the Kyverno Namespace, possibly other key system Namespaces (ex., `kube-system`). This is not the default as of Helm chart version 2.5.0.
3. All Kyverno Pods become unavailable due to a full cluster outage or improper scaling in of Nodes (for example, a cloud PaaS destroying too many Nodes in a node group as part of an auto-scaling operation without first cordoning and draining Pods).

If this combination of events occurs, the only way to recover is to manually delete the ValidatingWebhookConfigurations thereby allowing new Kyverno Pods to start up. Recovery steps are provided in the [troubleshooting section](/docs/troubleshooting/#api-server-is-blocked).

{{% alert title="Note" color="info" %}}
Kubernetes will not send ValidatingWebhookConfiguration or MutatingWebhookConfiguration objects to admission controllers, so therefore it is not possible to use a Kyverno policy to validate or mutate these objects.
{{% /alert %}}

By contrast, these operability concerns can be mitigated by making some security concessions. Specifically, by excluding the Kyverno and other system Namespaces during installation, should the aforementioned failure scenarios occur Kyverno should be able to recover by itself with no manual intervention. This is the default behavior as of the Helm chart version 2.5.0. However, configuring these exclusions means that subsequent policies will not be able to act on resources destined for those Namespaces as the API server has been told not to send AdmissionReview requests for them. Providing controls for those Namespaces, therefore, lies in the hands of the cluster administrator to implement, for example, Kubernetes RBAC to restrict who and what can take place in those excluded Namespaces.

{{% alert title="Note" color="info" %}}
Namespaces and/or objects within Namespaces may be excluded in a variety of ways including namespaceSelectors and objectSelectors. The Helm chart provides options for both, but by default the Kyverno Namespace will be excluded.
{{% /alert %}}

{{% alert title="Note" color="warning" %}}
When using objectSelector, it may be possible for users to spoof the same label key/value used to configure the webhooks should they discover how it is configured, thereby allowing resources to circumvent policy detection. For this reason, a namespaceSelector using the `kubernetes.io/metadata.name` immutable label is recommended.
{{% /alert %}}

The choices and their implications are therefore:

1. Do not exclude system Namespaces, including Kyverno's, (not default) during installation resulting in a more secure-by-default posture but potentially requiring manual recovery steps in some outage scenarios.
2. Exclude system Namespaces during installation (default) resulting in easier cluster recovery but potentially requiring other methods to secure those Namespaces, for example with Kubernetes RBAC.

You should choose the best option based upon your risk aversion, needs, and operational practices.

{{% alert title="Note" color="info" %}}
If you choose to *not* exclude Kyverno or system Namespaces/objects and intend to cover them with policies, you may need to modify the Kyverno [resourceFilters](/docs/installation/customization/#resource-filters) entry in the [ConfigMap](/docs/installation/customization/#configmap-keys) to remove those items.
{{% /alert %}}
