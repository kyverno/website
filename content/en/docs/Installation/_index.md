---
title: "Installation"
linkTitle: "Installation"
weight: 20
description: >
  Installation and configuration details for Kyverno using `Helm` or `kubectl`.
---

Kyverno can be installed using Helm or deploying from the YAML manifests directly. When using either of these methods, there are no other steps required to get Kyverno up and running.

Kyverno must always be installed in a dedicated Namespace; it must not be co-located with other applications in existing Namespaces including system-level Namespaces such as `kube-system`.

{{% alert title="Note" color="info" %}}
As of v1.7.0, Kyverno follows the same support policy as the Kubernetes project which is N-2 version compatibility. Although previous versions may work, they are not tested.
{{% /alert %}}

## Compatibility Matrix

| Kyverno Version                | Kubernetes Min | Kubernetes Max |
|--------------------------------|----------------|----------------|
| 1.4.x                          | 1.16           | 1.21           |
| 1.5.x                          | 1.16           | 1.21           |
| 1.6.x                          | 1.16           | 1.23           |
| 1.7.x                          | 1.21           | 1.23           |
| 1.8.x                          | 1.23           | 1.25           |

\* Due to a known issue with Kubernetes 1.23.0-1.23.2, support for 1.23 begins at 1.23.3.

## Install Kyverno using Helm

Kyverno can be deployed via a Helm chart--the only supported method for a production install--which is accessible either through the Kyverno repo or on [ArtifactHub](https://artifacthub.io/packages/helm/kyverno/kyverno).

In order to install Kyverno with Helm, first add the Kyverno Helm repository.

```sh
helm repo add kyverno https://kyverno.github.io/kyverno/
```

Scan the new repository for charts.

```sh
helm repo update
```

Optionally, show all available chart versions for Kyverno.

```sh
helm search repo kyverno -l
```

Based on the manner in which you would like to install Kyverno, see either the [High Availability](#high-availability) or [Standalone](#standalone) options below.

To install the Kyverno [Pod Security Standard policies](/policies/pod-security/) run the below Helm command after Kyverno has been installed.

```sh
helm install kyverno-policies kyverno/kyverno-policies -n kyverno
```

### High Availability

The official Helm chart is the recommended method of installing Kyverno in a production-grade, highly-available fashion as it provides all the necessary Kubernetes resources and configurations to meet production needs. By setting `replicaCount=3`, the following will be automatically created and configured as part of the defaults. This is not an exhaustive list and may change. For all of the default values, please see the Helm chart [README](https://github.com/kyverno/kyverno/tree/main/charts/kyverno) keeping in mind the release branch. You should carefully inspect all available chart values and their defaults to determine what overrides, if any, are necessary to meet the particular needs of your production environment.

* Kyverno running with three replicas
* PodDisruptionBudget
* Pod anti-affinity configured
* Kyverno Namespace excluded

{{% alert title="Note" color="warning" %}}
Kyverno does not support two replicas. For a highly-available installation, the only supported count is three.
{{% /alert %}}

By default, starting with the Helm chart version 2.5.0, the Kyverno Namespace will be excluded using a namespaceSelector configured with the [immutable label](https://kubernetes.io/docs/concepts/overview/working-with-objects/_print/#automatic-labelling) `kubernetes.io/metadata.name`. Additional Namespaces may be excluded by configuring chart values. Both namespaceSelector and objectSelector may be used for exclusions.

See also the [Namespace selectors](#namespace-selectors) section below and especially the [Security vs Operability](#security-vs-operability) section.

Use Helm 3.2+ to create a Namespace and install Kyverno.

```sh
helm install kyverno kyverno/kyverno -n kyverno --create-namespace --set replicaCount=3
```

For Helm versions prior to 3.2, create a Namespace and then install the Kyverno Helm chart.

```sh
kubectl create namespace kyverno
helm install kyverno kyverno/kyverno -n kyverno --create-namespace --set replicaCount=3
```

Beginning with Kyverno 1.5.0 (Helm chart v2.1.0), the Kyverno [Pod Security Standard policies](/policies/pod-security/) must be added separately and after Kyverno is installed.

```sh
helm install kyverno-policies kyverno/kyverno-policies -n kyverno
```

### Standalone

A "standalone" installation of Kyverno is suitable for lab, test/dev, or small environments where node count is less than three. It configures a single replica for the Kyverno Deployment and omits many of the production-grade components.

Use Helm 3.2+ to create a Namespace and install Kyverno.

```sh
helm install kyverno kyverno/kyverno -n kyverno --create-namespace --set replicaCount=1
```

For Helm versions prior to 3.2, create a Namespace and then install the Kyverno Helm chart.

```sh
kubectl create namespace kyverno
helm install kyverno kyverno/kyverno -n kyverno --create-namespace --set replicaCount=1
```

To install pre-releases, add the `--devel` switch to Helm.

```sh
helm install kyverno kyverno/kyverno -n kyverno --create-namespace --devel
```

## Install Kyverno using YAMLs

Kyverno can also be installed using a single installation manifest, however for production installation the Helm chart is the only supported method.

This manifest path will always point to the latest `main` branch and is not guaranteed to be stable.

```sh
kubectl create -f https://raw.githubusercontent.com/kyverno/kyverno/main/config/install.yaml
```

You can also pull from a release branch to install the stable releases including release candidates.

```sh
kubectl create -f https://raw.githubusercontent.com/kyverno/kyverno/release-1.7/config/release/install.yaml
```

## Security vs Operability

For a production installation, Kyverno should be installed in [HA mode](#high-availability). Regardless of the installation method used for Kyverno, it is important to understand the risks associated with any webhook and how it may impact cluster operations and security especially in production environments. Kyverno configures its resource webhooks by default (but [configurable](/docs/writing-policies/policy-settings/)) in [fail closed mode](https://kubernetes.io/docs/reference/access-authn-authz/extensible-admission-controllers/#failure-policy). This means if the API server cannot reach Kyverno in its attempt to send an AdmissionReview request for a resource that matches a policy, the request will fail. For example, a validation policy exists which checks that all Pods must run as non-root. A new Pod creation request is submitted to the API server and the API server cannot reach Kyverno. Because the policy cannot be evaluated, the request to create the Pod will fail. Care must therefore be taken to ensure that Kyverno is always available or else configured appropriately to exclude certain key Namespaces, specifically that of Kyverno's, to ensure it can receive those API requests. There is a tradeoff between security by default and operability regardless of which option is chosen.

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
If you choose to *not* exclude Kyverno or system Namespaces/objects and intend to cover them with policies, you may need to modify the Kyverno [resourceFilters](/docs/installation/#resource-filters) entry in the [ConfigMap](/docs/installation/#configmap-flags) to remove those items.
{{% /alert %}}

## Customize the installation of Kyverno

The picture below shows a typical Kyverno installation:

<img src="/images/kyverno-installation.png" alt="Kyverno Installation" width="80%"/>
<br/><br/>

If you wish to customize the installation of Kyverno to have certificates signed by an internal or trusted CA, or to otherwise learn how the components work together, follow the below guide.

### Installing a specific version

To install a specific version, download `install.yaml` and then change the image tag.

e.g., change image tag from `latest` to the specific tag `v1.3.0`.

```yaml
spec:
  containers:
    - name: kyverno
      # image: ghcr.io/kyverno/kyverno:latest
      image: ghcr.io/kyverno/kyverno:v1.3.0
```

To install in a specific namespace replace the namespace "kyverno" with your namespace.

Example:

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: <namespace>
```

```yaml
apiVersion: v1
kind: Service
metadata:
  labels:
    app: kyverno
  name: kyverno-svc
  namespace: <namespace>
```

and in other places (ServiceAccount, ClusterRoles, ClusterRoleBindings, ConfigMaps, Service, Deployment) where Namespace is mentioned.

Alternatively, use [Kustomize](https://kustomize.io/) to replace the Namespace.

To run Kyverno:

```sh
kubectl create -f ./install.yaml
```

To check the Kyverno controller status, run the command:

```sh
kubectl get pods -n <namespace>
```

If the Kyverno controller is not running, you can check its status and logs for errors:

```sh
kubectl describe pod <kyverno-pod-name> -n <namespace>
```

```sh
kubectl logs -l app.kubernetes.io/name=kyverno -n <namespace>
```

### Certificate Management

The Kyverno policy engine runs as an admission webhook and requires a CA-signed certificate and key to setup secure TLS communication with the kube-apiserver (the CA can be self-signed). There are two ways to configure secure communications between Kyverno and the kube-apiserver.

#### Option 1: Auto-generate a self-signed CA and certificate

Kyverno can automatically generate a new self-signed Certificate Authority (CA) and a CA signed certificate to use for webhook registration. This is the default behavior when installing Kyverno and expiration is set at one year. When Kyverno manage its own certificates, it will gracefully handle regeneration upon expiry.

```sh
## Install Kyverno
kubectl create -f https://raw.githubusercontent.com/kyverno/kyverno/main/config/release/install.yaml
```

{{% alert title="Note" color="info" %}}
The above command installs the last released version of Kyverno, which may not be stable. If you want to install a different version, you can edit the `install.yaml` file and update the image tag.
{{% /alert %}}

Also, by default Kyverno is installed in the `kyverno` Namespace. To install it in a different Namespace, you can edit `install.yaml` and update the Namespace.

To check the Kyverno controller status, run the command:

```sh
## Check pod status
kubectl get pods -n <namespace>
```

If the Kyverno controller is not running, you can check its status and logs for errors:

```sh
kubectl describe pod <kyverno-pod-name> -n <namespace>
```

```sh
kubectl logs -l app.kubernetes.io/name=kyverno -n <namespace>
```

#### Option 2: Use your own CA-signed certificate

You can install your own CA-signed certificate, or generate a self-signed CA and use it to sign a certificate. Once you have a CA and X.509 certificate-key pair, you can install these as Kubernetes Secrets in your cluster. If Kyverno finds these Secrets, it uses them. Otherwise it will create its own CA and sign a certificate from it (see Option 1 above). When you bring your own certificates, it is your responsibility to manage the regeneration/rotation process.

##### 2.1. Generate a self-signed CA and signed certificate-key pair

{{% alert title="Note" color="warning" %}}
Using a separate self-signed root CA is difficult to manage and not recommended for production use.
{{% /alert %}}

If you already have a CA and a signed certificate, you can directly proceed to Step 2.

Below is a process which shows how to create a self-signed root CA, and generate a signed certificate and key using [step CLI](https://smallstep.com/cli/):

1. Create a self-signed CA

```sh
step certificate create kyverno-ca rootCA.crt rootCA.key --profile root-ca --insecure --no-password
```

2. Generate a leaf certificate with a five-year expiration

```sh
step certificate create kyverno-svc tls.crt tls.key --profile leaf \
            --ca rootCA.crt --ca-key rootCA.key \
            --san kyverno-svc --san kyverno-svc.kyverno --san kyverno-svc.kyverno.svc --not-after 43200h --insecure --no-password
```

3. Verify the contents of the certificate

```sh
step certificate inspect tls.crt --short
```

The certificate must contain the SAN information in the `X509v3 extensions` section:

```sh
X509v3 extensions:
    X509v3 Subject Alternative Name:
        DNS:kyverno-svc, DNS:kyverno-svc.kyverno, DNS:kyverno-svc.kyverno.svc
```

##### 2.2. Configure Secrets for the CA and TLS certificate-key pair

You can now use the following files to create Secrets:

* `rootCA.crt`
* `tls.crt`
* `tls.key`

To create the required Secrets, use the following commands (do not change the Secret names):

```sh
kubectl create ns <namespace>
kubectl create secret tls kyverno-svc.kyverno.svc.kyverno-tls-pair --cert=tls.crt --key=tls.key -n <namespace>
kubectl create secret generic kyverno-svc.kyverno.svc.kyverno-tls-ca --from-file=rootCA.crt -n <namespace>
```

Secret | Data | Content
------------ | ------------- | -------------
`kyverno-svc.kyverno.svc.kyverno-tls-pair` | tls.key & tls.crt  | key and signed certificate
`kyverno-svc.kyverno.svc.kyverno-tls-ca` | rootCA.crt | root CA used to sign the certificate

Kyverno uses Secrets created above to setup TLS communication with the kube-apiserver and specify the CA bundle to be used to validate the webhook server's certificate in the admission webhook configurations.

This process has been automated for you with a simple script that generates a self-signed CA, a TLS certificate-key pair, and the corresponding Kubernetes secrets: [helper script](https://github.com/kyverno/kyverno/blob/main/scripts/generate-self-signed-cert-and-k8secrets.sh)

##### 2.3. Install Kyverno

You can now install Kyverno by selecting one of the available methods from the [installation section above](/docs/installation/#compatibility-matrix).

### Roles and Permissions

Kyverno creates several Roles and RoleBindings, some of which need to be customized to allow access to sensitive cluster-wide resources.

#### Roles

Kyverno requires the following permissions:

* create and update select resources in its namespace (e.g. `Lease` used for leader elections) and some cluster-wide resources (e.g. `ValidatingWebhookConfiguration` used for registering and managing webhooks).
* create, update, delete, get, list, and watch Kyverno custom resources such as `ClusterPolicy`.
* view, list, and watch resources to apply validation policy rules during background scans.
* create, update, delete, get, list, and watch resources managed via [generate policy](/docs/writing-policies/generate/) rules.

Kyverno creates the following roles that are bound to the `kyverno-service-account` ServiceAccount.

{{% alert title="Tip" color="info" %}}
Use `kubectl get clusterroles,roles -A | grep kyverno` to view all Kyverno roles.
{{% /alert %}}

**Cluster Roles**

Beginning in 1.8.0, Kyverno uses [aggregated ClusterRoles](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#aggregated-clusterroles) to search for and combine ClusterRoles which apply to Kyverno. The following `ClusterRoles` provide Kyverno with permissions to policies and other Kubernetes resources across all Namespaces:

* `kyverno`: top-level ClusterRole which aggregates all other Kyverno ClusterRoles
* `kyverno:policies`: manages policies, reports, generate requests, report change requests, and status
* `kyverno:view`: views all resources
* `kyverno:generate`: creates, updates, and deletes resources via generate policy rules
* `kyverno:events`: creates, updates, and deletes events for policy results
* `kyverno:userinfo`: query Roles and RoleBinding configurations to build [variables](/docs/writing-policies/variables/#pre-defined-variables) with Role information.
* `kyverno:webhook`: allows Kyverno to manage dynamic webhook configurations

Because aggregated ClusterRoles are used, there is only one ClusterRoleBinding named `kyverno` which binds the `kyverno` ClusterRole to the `kyverno-service-account` ServiceAccount.

**Namespaced Roles**

The following `Roles` provide Kyverno with permissions to manage select resources in the Kyverno Namespace:

* `kyverno:leaderelection`: manage leases for leader election across replicas

For each `Role` a `RoleBinding` with the same name as the `Role` is used to bind the permissions to the `kyverno-service-account`.

**Role aggregators**

The following `ClusterRoles` are used to extend the default `admin` role with permissions to view and manage policy resources via [role aggregation](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#aggregated-clusterroles):

* `kyverno:admin-policies`: allow `admin` role to manage Policies and ClusterPolicies
* `kyverno:admin-policyreport`: allow `admin` role to manage PolicyReports and ClusterPolicyReports
* `kyverno:admin-reportchangerequest`: allow `admin` role to manage ClusterReportChangeRequests and ClusterReportChangeRequests
* `kyverno:admin-generaterequest`: allow `admin` role to manage GenerateRequests

#### Customizing Permissions

Because the ClusterRoles used by Kyverno use the [aggregation feature](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#aggregated-clusterroles), extending the permission for Kyverno's use in cases like mutate existing or generate rules is a simple matter of creating one or more new ClusterRoles which use the `app=kyverno` label. It is no longer necessary to modify any existing ClusterRoles created as part of the Kyverno installation.

For example, if a new Kyverno policy introduced into the cluster requires that Kyverno be able to create or modify Deployments, this is not a permission Kyverno carries by default. It will be necessary to create a new ClusterRole and assign it the aggregation label `app=kyverno` in order for those permissions to take effect.

{{% alert title="Tip" color="info" %}}
To inspect the complete permissions granted to the Kyverno ServiceAccount via all the aggregated ClusterRoles, run `kubectl get clusterrole kyverno -o yaml`.
{{% /alert %}}

This sample ClusterRole provides Kyverno additional permissions to create Deployments:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    app: kyverno
  name: kyverno:create-deployments
rules:
- apiGroups:
  - apps
  resources:
  - deployments
  verbs:
  - create
```

### ConfigMap Flags

The following flags are used to control the behavior of Kyverno and must be set in the Kyverno ConfigMap.

1. `excludeGroupRole`: excludeGroupRole role expected string with comma-separated group role. It will exclude all the group role from the user request. Default we are using `system:serviceaccounts:kube-system,system:nodes,system:kube-scheduler`.
2. `excludeUsername`: excludeUsername expected string with comma-separated kubernetes username. In generate request if user enable `Synchronize` in generate policy then only kyverno can update/delete generated resource but admin can exclude specific username who have access of delete/update generated resource.
3. `generateSuccessEvents`: specifies whether (true/false) to generate success events. Default is set to "false".
4. `resourceFilters`: Kubernetes resources in the format "[kind,namespace,name]" where the policy is not evaluated by the admission webhook. For example --filterKind "[Deployment, kyverno, kyverno]" --filterKind "[Deployment, kyverno, kyverno],[Events, *, *]".
5. `webhooks`: specifies the Namespace or object exclusion to configure in the webhooks managed by Kyverno.

### Container Flags

The following flags can also be used to control the advanced behavior of Kyverno and must be set on the main `kyverno` container in the form of arguments. Unless otherwise stated, all container flags should be prefaced with two dashes (ex., `--autogenInternals`).

1. `admissionReports`: enables the AdmissionReport resource which is created from validate rules in `audit` mode. Used to factor into a final PolicyReport. Default is `true`.
2. `allowInsecureRegistry`: allows Kyverno to work with insecure registries (i.e., bypassing certificate checks) either with [verifyImages](/docs/writing-policies/verify-images/) rules or [variables from image registries](/docs/writing-policies/external-data-sources/#variables-from-image-registries). Only for testing purposes. Not to be used in production situations.
3. `autoUpdateWebhooks`: set this flag to `false` to disable auto-configuration of the webhook. With this feature disabled, Kyverno creates a default webhook configuration (which match all kinds of resources), therefore, webhooks configuration via the ConfigMap will be ignored. However, the user still can modify it by patching the webhook resource manually. Default is `true`.
4. `autogenInternals`: activates the [auto-generate](/docs/writing-policies/autogen/) rule calculation to write to `status` rather than the `.spec` field of Kyverno policies. Set to `true` by default. Set to `false` to disable this ability.
5. `backgroundScan`: enables/disables background scans. `true` by default. This replaces the former flag of the same name which controlled the background scan interval.
6. `clientRateLimitBurst`: configure the maximum burst for throttling. Uses the client default if zero. Default is `100`.
7. `clientRateLimitQPS`: configure the maximum QPS to the control plane from Kyverno. Uses the client default if zero. Default is `100`.
8. `disableMetrics`: specifies whether to enable exposing the metrics. Default is `false`.
9. `enableTracing`: set to enable exposing traces. Default is `false`.
10. `genWorkers`: the number of workers for processing generate policies concurrently. Default is `10`.
11. `imagePullSecrets`: specifies secret resource names for image registry access credentials. Accepts multiple values (comma separated).
12. `imageSignatureRepository`: specifies alternate repository for image signatures. Can be overridden per rule via `verifyImages.Repository`.
14. `kubeconfig`: specifies the Kubeconfig file to be used when overriding the API server to which Kyverno should communicate.
15. `maxQueuedEvents`: defines the upper limit of events that are queued internally. Default is `1000`.
16. `metricsPort`: specifies the port to expose prometheus metrics. Default is `8000`.
17. `otelCollector`: sets the OpenTelemetry collector service address. Kyverno will try to connect to this on the metrics port. Default is `opentelemetrycollector.kyverno.svc.cluster.local`.
18. `otelConfig`: sets the preference for Prometheus or OpenTelemetry. Set to `grpc` to enable OpenTelemetry. Default is `prometheus`.
19. `profile`: setting this flag to `true` will enable profiling. Default is `false`.
20. `profilePort`: specifies port to enable profiling. Default is `6060`.
21. `protectManagedResources`: protects the Kyverno resources from being altered by anyone other than the Kyverno Service Account. Defaults to `false`. Set to `true` to enable.
22. `reportsChunkSize`: maximum number of results in generated reports before splitting occurs if there are more results to be stored. Default is `1000`.
23. `serverIP`: Like the `kubeconfig` flag, used when running Kyverno outside of the cluster which it serves.
24. `splitPolicyReport`: splits ClusterPolicyReports and PolicyReports into individual reports per policy rather than a single entity per cluster and per Namespace. Useful when having Namespaces with many resources which apply to policies. Value is boolean. Deprecated in 1.8 and will be removed in 1.9.
25. `transportCreds`: set to the certificate authority secret containing the certificate used by the OpenTelemetry metrics client. Empty string means an insecure connection will be used. Default is `""`.
26. `-v`: sets the verbosity level of Kyverno log output. Takes an integer from 1 to 6 with 6 being the most verbose. Level 4 shows variable substitution messages. Default is `2`.
27. `webhookRegistrationTimeout`: specifies the length of time Kyverno will try to register webhooks with the API server. Defaults to `120s`.
28. `webhookTimeout`: specifies the timeout for webhooks. After the timeout passes, the webhook call will be ignored or the API call will fail based on the failure policy. The timeout value must be between 1 and 30 seconds. Defaults is `10s`.

### Policy Report access

During the Kyverno installation, it creates a ClusterRole `kyverno:admin-policyreport` which has permission to perform all operations on resources `policyreport` and `clusterpolicyreport`. To grant access to a Namespace admin, configure the following YAML file then apply to the cluster.

* Replace `metadata.namespace` with Namespace of the admin
* Configure `subjects` field to bind admin's role to the ClusterRole `policyviolation`

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: policyviolation
  # change namespace below to create rolebinding for the namespace admin
  namespace: default
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: kyverno:admin-policyreport
subjects:
# configure below to access policy violation for the namespace admin
- kind: ServiceAccount
  name: default
  namespace: default
# - apiGroup: rbac.authorization.k8s.io
#   kind: User
#   name:
# - apiGroup: rbac.authorization.k8s.io
#   kind: Group
#   name:
```

### Webhooks

Starting with Kyverno 1.5.0, the `mutatingWebhookConfiguration` and the `validatingWebhookConfiguration` resources are registered and managed dynamically based on the configured policies. Prior to 1.5.0, Kyverno uses a wildcard webhook that allowed it to receive admission requests for all resources. With the webhook auto-configuration feature, Kyverno now only receives admission requests for select resources, hence preventing unnecessary admission requests being forwarded to Kyverno.

Additionally, the `failurePolicy` and `webhookTimeoutSeconds` [policy configuration options](/docs/writing-policies/policy-settings/) allow granular control of webhook settings. By default, policies will be configured to "fail-closed" (i.e. the admission request will fail if the webhook invocation has an unexpected error or a timeout) unless the `failurePolicy` is set to `Ignore`.

This feature is enabled by default in 1.5.0+ but can be turned off by the flag `--autoUpdateWebhooks=false`. If disabled, Kyverno creates the default webhook configurations that forwards admission requests for all resources and with `FailurePolicy` set to `Ignore`.

The `spec.failurePolicy` and `spec.webhookTimeoutSeconds` and [policy configuration fields](/docs/writing-policies/policy-settings/) allow per-policy settings which are automatically aggregated and used to register the required set of webhook configurations.

Prior to 1.5.0, by default, the Kyverno webhook will process all API server requests for all Namespaces and the policy application was filtered using Resource Filters and Namespace Selectors discussed below.

### Resource Filters

Resource filters are a way to instruct Kyverno which AdmissionReview requests sent by the API server to disregard. This is not the same ability as configuration of the webhook. The Kubernetes kinds that should be ignored by policies can be filtered by adding a ConfigMap in Namespace `kyverno` and specifying the resources to be filtered under `data.resourceFilters`. The default name of this ConfigMap is `kyverno` but can be changed by modifying the value of the environment variable `INIT_CONFIG` in the Kyverno deployment spec. `data.resourceFilters` must be a sequence of one or more `[<Kind>,<Namespace>,<Name>]` entries with `*` as a wildcard. Thus, an item `[Node,*,*]` means that admissions of kind `Node` in any namespace and with any name will be ignored. Wildcards are also supported in each of these sequences. For example, this sequence filters out kind `Pod` in namespace `foo-system` having names beginning with `redis`.

```
[Pod,foo-system,redis*]
```

By default a number of kinds are skipped in the default configuration including Nodes, Events, APIService, SubjectAccessReview, and more.

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: kyverno
  namespace: kyverno
data:
  # resource types to be skipped by Kyverno
  resourceFilters: '[Event,*,*][*,kube-system,*][*,kube-public,*][*,kube-node-lease,*][Node,*,*][APIService,*,*][TokenReview,*,*][SubjectAccessReview,*,*][SelfSubjectAccessReview,*,*][*,kyverno,*][Binding,*,*][ReplicaSet,*,*][ReportChangeRequest,*,*][ClusterReportChangeRequest,*,*]'
```

To modify the ConfigMap, either directly edit the ConfigMap `kyverno` in the default configuration inside `install.yaml` and redeploy it or modify the ConfigMap using `kubectl`.  Changes to the ConfigMap through `kubectl` will automatically be picked up at runtime. Resource filters may also be configured at installation time via a Helm value.

### Namespace Selectors

In some cases, it is desired to limit those to certain Namespaces based upon labels. Kyverno can filter on these Namespaces using a `namespaceSelector` object by adding a new `webhooks` object to the ConfigMap. For example, in the below snippet, the `webhooks` object has been added with a `namespaceSelector` object which will filter on Namespaces with the label `environment=prod`. The `webhooks` key only accepts as its value a JSON-formatted `namespaceSelector` object. Note that when installing Kyverno via the Helm chart and setting Namespace exclusions, it will cause this `webhooks` object to be automatically created in the Kyverno ConfigMap. As of the Helm chart v2.5.0, the Kyverno Namespace is excluded by default.

```yaml
apiVersion: v1
data:
  resourceFilters: '[Event,*,*][*,kube-system,*][*,kube-public,*][*,kube-node-lease,*][Node,*,*][APIService,*,*][TokenReview,*,*][SubjectAccessReview,*,*][SelfSubjectAccessReview,*,*][*,kyverno,*][Binding,*,*][ReplicaSet,*,*][ReportChangeRequest,*,*][ClusterReportChangeRequest,*,*]'
  webhooks: '[{"namespaceSelector":{"matchExpressions":[{"key":"kubernetes.io/metadata.name","operator":"NotIn","values":["kyverno"]}]}}]'
kind: ConfigMap
metadata:
  name: kyverno
  namespace: kyverno
```

## Upgrading Kyverno

Upgrading Kyverno is as simple as applying the new YAML manifest, or using Helm depending on how it was installed. You cannot upgrade Kyverno by bumping the image tag on the Deployment as this will not affect the CRDs and other resources necessary for Kyverno's operation.

### Upgrade Kyverno with YAML manifest

Apply the new manifest over the existing installation.

```sh
kubectl apply -f https://raw.githubusercontent.com/kyverno/kyverno/main/config/install.yaml
```

### Upgrade Kyverno with Helm

Kyverno can be upgraded like any other Helm chart.

Scan your Helm repositories for updated charts.

```sh
helm repo update
```

Show the versions of the Kyverno chart which are available. To see pre-release charts, add the `--devel` flag to the `helm` command.

```sh
helm search repo kyverno
```

Run the upgrade command picking the target version.

```sh
helm upgrade kyverno kyverno/kyverno --namespace kyverno --version <version_number>
```

{{% alert title="Note" color="warning" %}}
Upgrading to Kyverno 1.5.0+ (Helm chart v2.1.0) from a version between 1.4.2 to 1.4.3 (Helm chart `>=v2.0.2 <v2.1.0`) will require extra steps.
The step to remove CRDs will cause all Kyverno policies to get removed, so a backup must be taken of policies not added by Helm.
{{% /alert %}}

Below are the steps to upgrade Kyverno to 1.5.0 from 1.4.3. The upgrade to 1.5.0+ requires first removing the old CRDs chart.

First take a backup of all cluster policies not added by Helm:

```sh
kubectl get clusterpolicy -l app.kubernetes.io/managed-by!=Helm -A -o yaml > kyverno-policies.yaml
```

Perform the upgrade

```sh
helm uninstall kyverno --namespace kyverno
helm uninstall kyverno-crds --namespace kyverno
helm install kyverno kyverno/kyverno --namespace kyverno --version <version_number>
```

Restore Kyverno cluster policies

```sh
kubectl apply -f kyverno-policies.yaml
```

## Uninstalling Kyverno

To uninstall Kyverno, use either the raw YAML manifest or Helm. The Kyverno deployment, RBAC resources, and all CRDs will be removed, including any reports.

### Option 1 - Uninstall Kyverno with YAML manifest

```sh
kubectl delete -f https://raw.githubusercontent.com/kyverno/kyverno/main/config/install.yaml
```

### Option 2 - Uninstall Kyverno with Helm

```sh
helm uninstall kyverno kyverno/kyverno --namespace kyverno
```

### Clean up Webhook Configurations

Kyverno by default will try to clean up all its webhook configurations when terminated. But in cases where its RBAC resources are removed first, it will lose the permission to do so properly.

Regardless which uninstallation method is chosen, webhooks will need to be manually removed as the final step. Use the below commands to delete those webhook configurations.

```sh
kubectl delete mutatingwebhookconfigurations kyverno-policy-mutating-webhook-cfg kyverno-resource-mutating-webhook-cfg kyverno-verify-mutating-webhook-cfg

kubectl delete validatingwebhookconfigurations kyverno-policy-validating-webhook-cfg kyverno-resource-validating-webhook-cfg
```
