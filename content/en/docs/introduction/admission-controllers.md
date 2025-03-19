---
title: Admission Controllers 101
description: An introduction to admission controllers in Kubernetes.
weight: 35
---

This page contains an optional overview of admission controllers in Kubernetes and is recommended for new users of Kubernetes in general or those who would like to better understand how admission controllers work. It is not intended to be an exhaustive reference document on the subject. As such, many advanced details and fine points have been omitted to favor readability.

## About Admission Controllers

In Kubernetes, admission controllers are components responsible for either validating or modifying requests as part of the admissions process. These components can be thought of as "extensibility" points for Kubernetes, often used to control the outcome when new resources are being created hence the term. These admission controllers can be both built-in to the Kubernetes API server directly (also referred to as "in-line", "in-process", or "compiled-in" admission controllers) or external. For example, a built-in admission controller called [ResourceQuota](https://kubernetes.io/docs/concepts/policy/resource-quotas/) will examine any new Deployments to ensure that the resources being requested do not exceed a threshold established for its destined Namespace. If this threshold--to be defined by a user with appropriate permissions--is exceeded, the request to create the Deployment will be blocked.

Admission controllers, regardless of whether they are considered built-in or external, can be **validating** or **mutating**. A single admission controller can even do both simultaneously. Regardless of the type, all admission controllers function after authenticating and authorizing requests but before persisting (saving) them to the backend. The flow of these phases is shown in the diagram below.

<br>

<img src="/images/kubernetes-admission-controllers.png" alt="Kubernetes Admission Controllers" />

<center>
<i>Source: https://kubernetes.io/blog/2019/03/21/a-guide-to-kubernetes-admission-controllers/</i>
</center>
<br></br>

While Kubernetes provides us with built-in admission controllers like ResourceQuota and [many more](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/#what-does-each-admission-controller-do), these are highly-specific, purpose-built controllers which only do one task and cannot be modified. In the real world, users--probably yourself included--often have demands that cannot be met by these built-in controllers. For these use cases, which will be covered shortly, something which can implement custom logic is necessary. In addition to these built-in admission controllers, dynamic admission controllers can be developed as extensions and run as webhooks configured at runtime.

There are two specific admission controllers which enable extending the API functionality via webhooks:

- **MutatingAdmissionWebhook**: can modify a request.
- **ValidatingAdmissionWebhook**: can validate whether the request should be allowed to be created or not.

Because these types differ from built-in admission controllers in that they can be used to implement custom decisions, they are known as **dynamic admission controllers**.

## Use Cases

As already mentioned, Kubernetes provides some admission controllers "out of the box" as built-in admission controllers. When you need to implement validations or mutations which are custom in nature and cannot be accomplished with one or more built-in admission controllers, you must turn to dynamic admission controllers. The following is a list of some use cases for dynamic admission controllers.

- **Security:** Admission controllers can increase security by mandating a reasonable security baseline across an entire Namespace or cluster. For example, `PodSecurity` is a built-in admission controller that can be used for disallowing containers from running as root or making sure that containers do not run as privileged. However, many users find that this admission controller, typically referred to as [Pod Security Admission](https://kubernetes.io/docs/concepts/security/pod-security-admission/), is [limited in several ways](../../blog/general/psp-migration/index.md#comparison). When the limitations of a built-in admission controller such as PodSecurity (Pod Security Admission) are reached, dynamic admission control can be used to plug the gaps.

- **Governance:** Using admission controllers you can enforce the adherence to certain practices like having good labels, annotations, resource limits, or other settings. For example, you can enforce label validation (or mutation) on different objects to ensure proper labels are being used, such as every object being assigned to a team or project, or every Deployment specifying an `app` label. Governance aspects like these are highly specific to the organization and such specific opinions must be enforced via dynamic admission controllers.

- **Configuration management:** Admission controllers allow you to validate the configuration of the objects running in the cluster and prevent misconfiguration. Admission controllers can be useful in detecting and fixing images deployed without semantic tags, automatically adding or validating resource requests and/or limits, and ensuring no two Ingress resources share the same hostname. Like governance, these desires often must be customized by the organization so they align with internal standards and practices. Dynamic admission control is the only way to provide this level of control to users.

- **Fine-grained RBAC:** Traditional RBAC (Role-Based Access Control) defines roles and permissions to perform specific actions within a Kubernetes cluster, but it lacks the granularity needed for certain scenarios. Dynamic admission controllers address this gap by allowing administrators to impose detailed conditions on top of standard RBAC policies. For example, the ability to place restrictions on who may delete a Namespace with a certain label is only possible through dynamic admission control.

- **Multi-tenancy:** Multi-tenancy enhances resource utilization, reduces operational costs, and promotes agility and collaboration as multiple teams share the same cluster. Many organizations operate internally as multi-tenanted businesses. Kubernetes doesn’t have a native way to enforce boundaries between these tenants, hence admission controllers (like `ResourceQuota` and `LimitRanger`) can be used to enforce limits on consumption and creation of cluster resources (such as CPU time, memory, and persistent storage) within a specified Namespace. Some dynamic admission controllers, such as Kyverno, can take this a step further by automating the creation process of resources in new Namespaces adding a bootstrapping capability for new tenants or customers.

- **Cost control:** Running Kubernetes costs you money and without certain checks and gates in place, those expenses could quickly get out of hand. For example, Kubernetes clusters running in public clouds such as AWS, GCP, and Azure have the ability to instantiate other cloud services in your account based on a Kubernetes resource. These cloud resources come at an additional cost. Dynamic admission controllers can limit specific resources that may have cost implications on your infrastructure, for example limiting the number of Kubernetes Services of type `LoadBalancer` which may be created in a given cluster as each one brings up a cloud load balancer.

- **Supply chain security:** Admission controllers act as gatekeepers, validating requests based on predefined policies before allowing resources to be admitted into the cluster. Admission controllers can help incorporate supply chain security measures like ensuring images are signed by a trusted corporate key or have one or more qualities attested to by an authorized third party. Because these aspects of supply chain security often involve fetching additional information about images, a dynamic admission controller must be used.

## About Dynamic Admission Controllers

Dynamic admission controllers are those which are implemented as part of the [MutatingAdmissionWebhook](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/#mutatingadmissionwebhook) and [ValidatingAdmissionWebhook](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/#validatingadmissionwebhook) admission controllers and contain two parts, a webhook and a controller.

* **Webhook**: A Kubernetes resource which contains a set of directives intended for the API server. Those directives consist of several parts:

  1. What resources to send
  2. Where they should be sent
  3. What the response behavior should be

* **Controller**: A piece of software, typically delivered as one or more Pods, which listens and responds to requests sent to it by the Kubernetes API server. The requests it receives are a result of the instructions defined in the webhook.

### Webhooks

A webhook is a Kubernetes API resource similar to others like Pod and ConfigMap which is created in the Kubernetes cluster and defines a sort of "bridge" between the API server and a separate piece of software. These webhooks are either `ValidatingWebhookConfiguration` or `MutatingWebhookConfiguration`. A `ValidatingWebhookConfiguration` defines the contract governing validations and a `MutatingWebhookConfiguration` defines the contract governing mutations. Multiple such webhooks may be created and it is not uncommon to see several of both types in a single cluster.

An example of an abbreviated `ValidatingWebhookConfiguration` is shown below. Comments have been added to call out the major components which will be explained further.

```yaml
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingWebhookConfiguration
metadata:
  name: kyverno-resource-validating-webhook-cfg
webhooks:
  - name: validate.kyverno.svc-fail  ## The name of this webhook
    rules:                           ## What resources should be sent
      - apiGroups:
          - apps
        apiVersions:
          - v1
        operations:
          - CREATE
        resources:
          - deployments
    clientConfig:                    ## Where the resources should be sent
      caBundle: LS0t<snip>0tLS0K
      service:
        name: kyverno-svc
        namespace: kyverno
        path: /validate/fail
        port: 443
    timeoutSeconds: 10               ## How long should the API server wait
    failurePolicy: Fail              ## What should happen after the wait is over
```

In this example, the API server has been instructed to send any creation requests for Deployments to a Service in the cluster named `kyverno-svc` existing in the `kyverno` Namespace. Should the API server receive any such creation requests for any other type of resource, these will not be sent. Because this is a ValidatingWebhookConfiguration, the service responding to these requests must deliver either an "allowed" or "denied" response back to the API server. The API server will await this response for 10 seconds and if none is received will block creation of that Deployment.

### Controllers

The controller is the other half of the dynamic admission controller story. Something must be listening for the requests sent by the API server and be prepared to respond. This is typically implemented by a controller running in the same cluster as a Pod. This controller, like the API server with the webhook, must have some instruction for how to respond to requests. This instruction is provided to it in the form of a **policy**. A policy is typically another Kubernetes resource, but this time a [Custom Resource](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/), which the controller uses to determine that response. Once the controller examines the policy it is prepared to make a decision for resources it receives.

For example, as you may have learned in the [validation quick start section](../introduction/quick-start.md#validate-resources), a policy such as `require-labels` can be used to instruct the controller how to respond in the case where it receives a matching request. If the Pod has a label named `team` then its creation will be allowed. If it does not, it will be prevented.

Controllers receiving requests from the Kubernetes API server do so over HTTP/REST. The contents of that request are a "packaging" or "wrapping" of the resource, which has been defined via the webhook, in addition to other pertinent information about who or what made the request. This package is called an `AdmissionReview`. More details on this packaging format along with an example can be seen [here](/docs/policy_types/cluster_policy/jmespath.md#admissionreview).

Webhooks and controllers work together to bring about these types of custom decisions, some of which were defined in the previous use cases section. A webhook is an instruction for the Kubernetes API server while a policy is an instruction for the controller.

## More Details

While the basics have already been covered, it can be helpful to understand a few more details about how admission controllers, specifically dynamic admission controllers, operate as this can be critical when it comes to providing the best experience for you.

### Order

First, refer back to the diagram at the top of the page and notice the sequence of events. When it comes to dynamic admission control, all mutations happen first followed by all validations. However, even before the mutation step, it is important to understand what the API server has already done. Prior to the mutation step, the API server has already performed these tasks:

* Authenticated the request
* Authorized the request
* Performed any and all field defaulting
* Applied any and all in-process mutations

The latter two are especially important when it comes to authoring policy since what you expect the controller to receive and what it actually receives can be very different.

When a dynamic admission controller such as Kyverno receives a request from the API server, irrespective of whether that request is for a mutation or validation, the request already contains all modifications made to it by the API server and its various internal controllers including built-in admission controllers.

For example, if you as a human user were to author and then create the following Pod definition using the command `kubectl create -f pod.yaml`

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: mypod
spec:
  containers:
  - name: busybox
    image: busybox
    args:
    - sleep
    - infinity
    resources:
      limits:
        memory: 64Mi
        cpu: 100m
```

what a dynamic admission controller may see if it requested to be informed about Pod creation events is the following:

```yaml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: "2024-02-11T00:53:09Z"
  managedFields:
    - apiVersion: v1
      fieldsType: FieldsV1
      fieldsV1:
        f:spec:
          f:containers:
            k:{"name":"busybox"}:
              .: {}
              f:args: {}
              f:image: {}
              f:imagePullPolicy: {}
              f:name: {}
              f:resources:
                .: {}
                f:limits:
                  .: {}
                  f:cpu: {}
                  f:memory: {}
                f:requests:
                  .: {}
                  f:cpu: {}
                  f:memory: {}
              f:terminationMessagePath: {}
              f:terminationMessagePolicy: {}
          f:dnsPolicy: {}
          f:enableServiceLinks: {}
          f:restartPolicy: {}
          f:schedulerName: {}
          f:securityContext: {}
          f:terminationGracePeriodSeconds: {}
      manager: kubectl-create
      operation: Update
      time: "2024-02-11T00:53:09Z"
  name: mypod
  namespace: default
  uid: 49fee716-d086-4806-9c87-9796f5d3f7aa
spec:
  containers:
    - args:
        - sleep
        - infinity
      image: busybox
      imagePullPolicy: Always
      name: busybox
      resources:
        limits:
          cpu: 100m
          memory: 64Mi
        requests:
          cpu: 100m
          memory: 64Mi
      terminationMessagePath: /dev/termination-log
      terminationMessagePolicy: File
      volumeMounts:
        - mountPath: /var/run/secrets/kubernetes.io/serviceaccount
          name: kube-api-access-kzw57
          readOnly: true
  dnsPolicy: ClusterFirst
  enableServiceLinks: true
  preemptionPolicy: PreemptLowerPriority
  priority: 0
  restartPolicy: Always
  schedulerName: default-scheduler
  securityContext: {}
  serviceAccount: default
  serviceAccountName: default
  terminationGracePeriodSeconds: 30
  tolerations:
    - effect: NoExecute
      key: node.kubernetes.io/not-ready
      operator: Exists
      tolerationSeconds: 300
    - effect: NoExecute
      key: node.kubernetes.io/unreachable
      operator: Exists
      tolerationSeconds: 300
  volumes:
    - name: kube-api-access-kzw57
      projected:
        defaultMode: 420
        sources:
          - serviceAccountToken:
              expirationSeconds: 3607
              path: token
          - configMap:
              items:
                - key: ca.crt
                  path: ca.crt
              name: kube-root-ca.crt
          - downwardAPI:
              items:
                - fieldRef:
                    apiVersion: v1
                    fieldPath: metadata.namespace
                  path: namespace
status:
  phase: Pending
  qosClass: Guaranteed
```

As you can see, there are quite a few new fields that have been added. These fields are the work of the Pod controller defaulting behavior as well as all built-in admission controllers. For example, notice how in the original request there were neither volumes nor volume mounts and yet suddenly there are both. This is the work of the [ServiceAccount admission controller](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/#serviceaccount) which has automatically mounted a token to the Pod corresponding to the `default` ServiceAccount. Notice also how the original Pod manifest specified only limits but no requests but now it has requests equal to limits. This is the work of the Pod controller applying its [default behavior](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#requests-and-limits) when limits are specified without requests and without another controller having performed any request defaulting.

The number and type of these field defaultings and mutations can vary based on the resource type, the admission controllers enabled in the cluster, and other factors. Since a dynamic admission controller has no way of distinguishing between what you, as a person, submitted to the API server versus what it received it is important to take these factors into consideration when authoring and troubleshooting policy.

Understanding the sequence of events leading up to dynamic admission controllers being invoked is important, but so is how they are invoked when the time arrives.

During the dynamic mutating admission phase, the webhooks are called serially where one is called followed by the next and so on. They are not called at random but in [lexical order](https://en.wikipedia.org/wiki/Lexicographic_order). For example, if there were two `MutatingWebhookConfigurations`, one named `alpha` and the other `bravo`, the `alpha` webhook will be called first and all responses returned before `bravo` is called. The ordering cannot be influenced aside from changing the name of the MutatingWebhookConfiguration resource itself.

> This serialized order of calling mutation webhooks also involves the responses from them. If `alpha` modified the request and it was subsequently sent to `bravo`, then `bravo` would see the modifications made by `alpha` and not the original resource which only `alpha` received.

During the dynamic validating admission phase, webhooks are called in parallel order which is different from mutations. During this step, all `ValidatingWebhookConfigurations` are called simultaneously and all downstream controllers receive responses roughly at the same time. All controllers which have received a validating request must respond that the resource is allowed in order for it to be persisted. Therefore, the latency experienced by a resource subject to validating webhooks is the greatest value of the slowest controller to respond and not a sum of the response times of all controllers.

### Limitations

Second, it is important to understand the abilities and limitations of dynamic admission control. Dynamic admission control is limited in two primary ways. The first limitation is the operations which may be controlled. The second are the types of resources which may be controlled.

Unlike Kubernetes (Cluster)Roles which can define a whole host of verbs like `create`, `get`, `delete`, and `patch`, the Kubernetes API server only permits a subset of these to be sent to dynamic admission controllers. Rather than being called "verbs" these are called "operations" in webhook parlance. There are four operations which the API server recognizes:

* **CREATE**: The CREATE operation occurs when a resource is created.
* **UPDATE**: The UPDATE operation occurs when an existing resource is modified, regardless of whether it results from a verb "patch" or "update". Because an update means a resource has already been created, the `oldObject` structure in the `AdmissionReview` resource will be populated. Refer back to the [admission review page](/docs/policy_types/cluster_policy/jmespath.md#admissionreview) for more details.
* **DELETE**: The DELETE operation occurs when a resource is deleted. Note that this may not always align to a `kubectl delete` command. Depending on the resource being deleted, there may first be an UPDATE followed by the ultimate DELETE operation.
* **CONNECT**: The CONNECT operation occurs when a user/process performs a `kubectl exec` command against a Pod.

As you may have noticed, operations corresponding to verbs such as "get", "list", or "watch" are absent. The Kubernetes API server will not permit sending of any such read-related requests to admission controllers. It is therefore not possible to use dynamic admission controllers to protect against these types of requests and adding an operation such as `GET` to the webhook will be ignored.

With a better understanding of what operations can be controlled, you should also know which resources can and cannot be controlled.

The Kubernetes API server allows basically all API resources to be sent to dynamic admission controllers with the exception of two: `MutatingWebhookConfigurations` and `ValidatingWebhookConfigurations`. These resources are exempted implicitly and this behavior cannot be altered. This decision was made to avoid a "chicken-and-egg" situation from occurring and deadlocking the entire cluster. Since a webhook may not be configured to send other webhooks, you may not validate or mutate these resources during dynamic admission control phases.

### Precautions

Dynamic admission controllers are considered a critical piece of cluster machinery and should be deployed, configured, and operated with care. Like with all software having powerful capabilities, failing to do so could be problematic in a number of ways.

#### Performance

If you refer back to the [webhooks section](#webhooks) where a simplified ValidatingWebhookConfiguration was shown, you may recall the `failurePolicy` field. The value of this field instructs the API server what to do with the request if a response has not been received from the controller within `timeoutSeconds`, however regardless of that value the admissions process waits for a response. Because a dynamic admission controller essentially stands in the path of the admissions process, the performance considerations are very important.

Since the Kubernetes API server allows sending the vast majority of API resources and operations on those resources to dynamic admission controllers, it has the possibility of inundating the downstream controller with requests. And as webhooks allow configuring `'*'` for each field, meaning that all resources and all operations should be sent, this can result in potentially thousands of requests per second reaching the controller. Each of those requests must be responded to no matter the response it provides. On very large and active clusters, this has the capability to drive performance into the ground and quickly bring operations to a standstill. You should be cautious of a number of factors when configuring webhooks either manually or dynamically through policy:

1. Only request the resources you actually need. Configuring a webhook for `'*'` should be a last resort.
2. Limit the types of operations which matter. Including `UPDATE` in those operations can result in an order of magnitude greater of admission requests to process. See [this table](/docs/installation/scaling.md#admissionreview-reference) for more details.
3. Take your cluster's management actions into consideration, for example how often you elastically scale the cluster or perform chaos engineering as these can create high bursts of admission events to process.

On the controller and policy side, there are also some important considerations.

The first is controller scaling. Kyverno supports both horizontal (multiple replicas) and vertical (adding more resource requests to existing replicas) for increased performance. Rightsizing resource requirements is essential to guaranteeing good performance. The default values have proven to be sufficient for many installations but not all. You should always test a dynamic admission controller in a development/test environment first in order to find the right balance between requests and limits. We also recommend not using CPU or memory limits while in this "probationary" period so you can get a full picture of resource usage. Pod restarts are often a good indicator that limits may be set too low for a given workload. See [Scaling Kyverno](/docs/installation/scaling.md) for more details.

The second controller consideration is what you've asked your policy to do. Some dynamic admission controllers have the ability to call external services such as image registries and even arbitrary services like configuration management systems or service platforms. These could be running anywhere in the world and so a great deal of additional latency can be incurred in this process. Even if you have solved for other performance concerns like those noted previously, making such calls is expensive in terms of latency and can easily form a bottleneck. When authoring policy which makes calls to non-Kubernetes APIs, do everything you can to make these responses fast and reliable and avoid them altogether if possible.

#### Availability

As explained in the [Performance](#performance) section just now, you know that your dynamic admission controller stands in the path of the admissions process. But response time is irrelevant if the controller cannot respond at all. The controller must remain available so it can be reached by callbacks from the API server. So long as a webhook configuration resource exists, the API server will consider this its directive for the requests to send even if the service listed has no endpoints or is absent.

Availability of the controller can be disrupted in a number of ways: cluster failures, improper node scaling procedures, user error, etc. Having multiple replicas can mitigate some of these scenarios but not all. See the [High Availability](../high-availability/_index.md) page for more information on how Kyverno handles this.

Webhooks can also be configured with Namespace and object selectors allowing the Kubernetes API to withhold sending some types of requests. This is particularly important for the Namespace where the controller resides and potentially those of other critical cluster components. Webhooks are commonly (sometimes by default) configured to exclude the Namespace of the dynamic admission controller itself in order to allow recovery from events like Pod failure. See the [Security vs Operability](/docs/installation/_index.md#security-vs-operability) section for more information including an example scenario which highlights this need to configure exclusions.

#### Security

A dynamic admission controller is a privileged piece of cluster machinery and should only be installed and configured by those with cluster-admin privileges. Users should take precautions to ensure the controller exists in its own Namespace and not co-located in another Namespace. Nothing else should be deployed into this controller's Namespace. Users should also not be entitled to this Namespace using RBAC remembering how exclusions may be in place as noted in the Availability section previously.

When it comes to RBAC, the dynamic admission controller cannot be a replacement for it. Recall that read-related requests are not sent to such controllers so it is not possible to, for example, somehow give users cluster-admin and rely on a policy engine to do the rest of the work. This approach is faulty and can easily be circumvented in a number of ways, for example by deleting webhooks or the CRDs for policy. Standard Kubernetes RBAC should be used appropriately to form the high levels of security and only after involving a dynamic admission controller for more granular concerns.

Due to the necessity to balance availability with security, an alternative to dynamic validating admission control in the form of [ValidatingAdmissionPolicy](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/#validatingadmissionpolicy) has been proposed. Because this is a built-in admission controller, availability is tied to that of the Kubernetes API server itself and many deadlocking situations can be avoided. ValidatingAdmissionPolicy is still in the development stage and time will tell how this will compare to dynamic admission control via webhooks.

## Links

Admission controllers in Kubernetes is a vast subject and much has been written on them. Here are a few links to follow for further reading:

* [Admission Controllers Reference](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/) (Kubernetes reference docs)
* [Dynamic Admission Control](https://kubernetes.io/docs/reference/access-authn-authz/extensible-admission-controllers/) (Kubernetes reference docs)
* [A Guide to Kubernetes Admission Controllers](https://kubernetes.io/blog/2019/03/21/a-guide-to-kubernetes-admission-controllers/) (Kubernetes blog)
* [Kubernetes admission controllers in 5 minutes](https://sysdig.com/blog/kubernetes-admission-controllers/) (Sysdig blog)
