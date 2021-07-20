---
title: "Installation"
linkTitle: "Installation"
weight: 20
description: >
  Installation and configuration details for Kyverno using `Helm` or `kubectl`.
---

Kyverno can be installed using Helm or deploying from the YAML manifests directly. When using either of these methods, there are no other steps required to get Kyverno up and running.

{{% alert title="Note" color="info" %}}
As of v1.4.0, Kyverno supports multiple replicas for increased scale and availability.
{{% /alert %}}

## Compatibility Matrix

| Kyverno Version                | Kubernetes Min | Kubernetes Max |
|--------------------------------|----------------|----------------|
| 1.2.1                          | 1.14           | 1.17           |
| 1.3.0                          | 1.16           | 1.20*          |
| 1.4.0                          | 1.16           | 1.21           |

\* Kyverno CLI 1.3.0 supports up to Kubernetes 1.18.

## Install Kyverno using Helm

Kyverno can be deployed through a Helm chart which is accessible either through the Kyverno repo or on [ArtifactHub](https://artifacthub.io/packages/helm/kyverno/kyverno). As of Kyverno 1.3.2, the Helm chart also by default installs the `default` profile of the Pod Security Standards policies available [here](https://kyverno.io/policies/pod-security/).

In order to install Kyverno with Helm, first add the Kyverno Helm repository.

```sh
helm repo add kyverno https://kyverno.github.io/kyverno/
```

Scan the new repository for charts.

```sh
helm repo update
```

Use Helm 3.2+ to create a Namespace and install Kyverno.

```sh
helm install kyverno kyverno/kyverno --namespace kyverno --create-namespace
```

To install non-stable releases, add the `--devel` switch to Helm.

```sh
helm install kyverno --namespace kyverno kyverno/kyverno --create-namespace --devel
```

For Helm versions prior to 3.2, create a Namespace and then install the Kyverno Helm chart.

```sh
kubectl create ns kyverno
helm install kyverno --namespace kyverno kyverno/kyverno
```

{{% alert title="Note" color="info" %}}
For all of the flags available during a Helm installation of Kyverno, see [here](https://github.com/kyverno/kyverno/tree/main/charts/kyverno). To disable the automatic installation of the default Pod Security Standard policies, set `podSecurityStandard` to `disabled`.
{{% /alert %}}

## Install Kyverno using YAMLs

If you'd rather deploy the manifest directly, simply apply the latest release file. This manifest path will always point to the latest release, including release candidates and other non-stable releases.

```sh
kubectl create -f https://raw.githubusercontent.com/kyverno/kyverno/main/definitions/release/install.yaml
```

## Customize the installation of Kyverno

The picture below shows shows a typical Kyverno installation:

<img src="/images/kyverno-installation.png" alt="Kyverno Installation" width="80%"/>
<br/><br/>

If you wish to customize the installation of Kyverno to have certificates signed by an internal or trusted CA, or to otherwise learn how the components work together, follow the below guide.

The Kyverno policy engine runs as an admission webhook and requires a CA-signed certificate and key to setup secure TLS communication with the kube-apiserver (the CA can be self-signed). There are two ways to configure secure communications between Kyverno and the kube-apiserver.

### Option 1: Auto-generate a self-signed CA and certificate

Kyverno can automatically generate a new self-signed Certificate Authority (CA) and a CA signed certificate to use for webhook registration. This is the default behavior when installing Kyverno, and when done the certificate validity period is 10 years.

```sh
## Install Kyverno
kubectl create -f https://raw.githubusercontent.com/kyverno/kyverno/main/definitions/release/install.yaml
```

{{% alert title="Note" color="info" %}}
The above command installs the last released version of Kyverno, which may not be stable. If you want to install a different version, you can edit the `install.yaml` file and update the image tag.
{{% /alert %}}

Also, by default Kyverno is installed in the "kyverno" namespace. To install it in a different namespace, you can edit `install.yaml` and update the namespace.

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
kubectl logs <kyverno-pod-name> -n <namespace>
```

### Option 2: Use your own CA-signed certificate

{{% alert title="Note" color="warning" %}}
There is a known issue with this process. It is being worked on and should be available again in a future release.
{{% /alert %}}

You can install your own CA-signed certificate, or generate a self-signed CA and use it to sign a certificate. Once you have a CA and X.509 certificate-key pair, you can install these as Kubernetes secrets in your cluster. If Kyverno finds these secrets, it uses them. Otherwise it will request the kube-controller-manager to generate a certificate (see Option 1 above).

#### 2.1. Generate a self-signed CA and signed certificate-key pair

{{% alert title="Note" color="warning" %}}
Using a separate self-signed root CA is difficult to manage and not recommended for production use.
{{% /alert %}}

If you already have a CA and a signed certificate, you can directly proceed to Step 2.

Here are the commands to create a self-signed root CA, and generate a signed certificate and key using OpenSSL (you can customize the certificate attributes for your deployment):

1. Create a self-signed CA

```bash
openssl genrsa -out rootCA.key 4096
openssl req -x509 -new -nodes -key rootCA.key -sha256 -days 1024 -out rootCA.crt  -subj "/C=US/ST=test/L=test /O=test /OU=PIB/CN=*.kyverno.svc/emailAddress=test@test.com"
```

2. Create a keypair

```bash
openssl genrsa -out webhook.key 4096
openssl req -new -key webhook.key -out webhook.csr  -subj "/C=US/ST=test /L=test /O=test /OU=PIB/CN=kyverno-svc.kyverno.svc/emailAddress=test@test.com"
```

3. Create a `webhook.ext` file with the Subject Alternate Names (SAN) to use. This is required with Kubernetes 1.19+ and Go 1.15+.

```
subjectAltName = DNS:kyverno-svc,DNS:kyverno-svc.kyverno,DNS:kyverno-svc.kyverno.svc
```

4. Sign the keypair with the CA passing in the extension

```bash
openssl x509 -req -in webhook.csr -CA rootCA.crt -CAkey rootCA.key -CAcreateserial -out webhook.crt -days 1024 -sha256 -extfile webhook.ext
```

5. Verify the contents of the certificate

```bash
 openssl x509 -in webhook.crt -text -noout
```

The certificate must contain the SAN information in the `X509v3 extensions` section:

```
X509v3 extensions:
    X509v3 Subject Alternative Name:
        DNS:kyverno-svc, DNS:kyverno-svc.kyverno, DNS:kyverno-svc.kyverno.svc
```

#### 2.2. Configure secrets for the CA and TLS certificate-key pair

You can now use the following files to create secrets:

- `rootCA.crt`
- `webhooks.crt`
- `webhooks.key`

To create the required secrets, use the following commands (do not change the secret names):

```sh
kubectl create ns <namespace>
kubectl create secret tls kyverno-svc.kyverno.svc.kyverno-tls-pair --cert=webhook.crt --key=webhook.key -n <namespace>
kubectl annotate secret kyverno-svc.kyverno.svc.kyverno-tls-pair self-signed-cert=true -n <namespace>
kubectl create secret generic kyverno-svc.kyverno.svc.kyverno-tls-ca --from-file=rootCA.crt -n <namespace>
```

{{% alert title="Note" color="info" %}}
The annotation on the TLS pair secret is used by Kyverno to identify the use of self-signed certificates and checks for the required root CA secret.
{{% /alert %}}

Secret | Data | Content
------------ | ------------- | -------------
`kyverno-svc.kyverno.svc.kyverno-tls-pair` | rootCA.crt | root CA used to sign the certificate
`kyverno-svc.kyverno.svc.kyverno-tls-ca` | tls.key & tls.crt  | key and signed certificate

Kyverno uses secrets created above to setup TLS communication with the kube-apiserver and specify the CA bundle to be used to validate the webhook server's certificate in the admission webhook configurations.

This process has been automated for you with a simple script that generates a self-signed CA, a TLS certificate-key pair, and the corresponding Kubernetes secrets: [helper script](https://github.com/kyverno/kyverno/blob/main/scripts/generate-self-signed-cert-and-k8secrets.sh)

#### 2.3. Install Kyverno

You can now install Kyverno by downloading and updating `install.yaml`, or using the command below (assumes that the namespace is "kyverno"):

```sh
kubectl create -f https://raw.githubusercontent.com/kyverno/kyverno/main/definitions/release/install.yaml
```

## Configuring Kyverno

### Permissions

Kyverno, in `foreground` mode, leverages admission webhooks to manage incoming API requests, and `background` mode applies the policies on existing resources. It uses ServiceAccount `kyverno-service-account`, which is bound to multiple ClusterRoles, which defines the default resources and operations that are permitted.

ClusterRoles used by Kyverno:

- `kyverno:webhook`
- `kyverno:userinfo`
- `kyverno:customresources`
- `kyverno:policycontroller`
- `kyverno:generatecontroller`

The `generate` rule creates a new resource, and to allow Kyverno to create resources the Kyverno ClusterRole needs permissions to create/update/delete. This can be done by adding the resource to the ClusterRole `kyverno:generatecontroller` used by Kyverno or by creating a new ClusterRole and a ClusterRoleBinding to Kyverno's default ServiceAccount.

To get cluster wide permissions, users must add the permissions for cluster wide resource such as `roles`,  `clusterroles`,  `rolebindings` and `clusterrolebindings` they need.

```yaml
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRole
metadata:
  name: kyverno:generatecontroller
rules:
- apiGroups:
  - "*"
  resources:
  - namespaces
  - networkpolicies
  - secrets
  - configmaps
  - resourcequotas
  - limitranges
  - ResourceA # new Resource to be generated
  - ResourceB
  verbs:
  - create # generate new resources
  - get # check the contents of exiting resources
  - update # update existing resource, if required configuration defined in policy is not present
  - delete # clean-up, if the generate trigger resource is deleted
```

```yaml
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: kyverno-admin-generate
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: kyverno:generatecontroller # clusterRole defined above, to manage generated resources
subjects:
- kind: ServiceAccount
  name: kyverno-service-account # default kyverno serviceAccount
  namespace: kyverno
```

### Version

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
kubectl logs -l app=kyverno -n <namespace>
```

### Flags

The following flags are used to control the behavior of Kyverno and must be set in the Kyverno ConfigMap.

1. `excludeGroupRole`: excludeGroupRole role expected string with comma-separated group role. It will exclude all the group role from the user request. Default we are using `system:serviceaccounts:kube-system,system:nodes,system:kube-scheduler`.
2. `excludeUsername`: excludeUsername expected string with comma-separated kubernetes username. In generate request if user enable `Synchronize` in generate policy then only kyverno can update/delete generated resource but admin can exclude specific username who have access of delete/update generated resource.
3. `filterK8sResources`(deprecated): Kubernetes resources in the format "[kind,namespace,name]" where the policy is not evaluated by the admission webhook. For example --filterKind "[Deployment, kyverno, kyverno]" --filterKind "[Deployment, kyverno, kyverno],[Events, *, *]".
4. `gen-workers`: the number of workers for processing generate policies concurrently. Default is set to 10.
5. `background-scan`: the interval (like 30s, 15m, 12h) for background processing. Default is set to 1h.
6. `generateSuccessEvents`: specifies whether (true/false) to generate success events. Default is set to "false".

### PolicyViolation access

During the Kyverno installation, it creates a ClusterRole `kyverno:policyviolations` which has the `list,get,watch` operations on resource `policyviolations`. To grant access to a Namespace admin, configure the following YAML file then apply to the cluster.

- Replace `metadata.namespace` with Namespace of the admin
- Configure `subjects` field to bind admin's role to the ClusterRole `policyviolation`

```yaml
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: RoleBinding
metadata:
  name: policyviolation
  # change namespace below to create rolebinding for the namespace admin
  namespace: default
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: policyviolation
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

### Resource Filters

The admission webhook checks if a policy is applicable on all admission requests. The Kubernetes kinds that are not processed can be filtered by adding a ConfigMap in namespace `kyverno` and specifying the resources to be filtered under `data.resourceFilters`. The default name of this ConfigMap is `init-config` but can be changed by modifying the value of the environment variable `INIT_CONFIG` in the Kyverno deployment spec. `data.resourceFilters` must be a sequence of one or more `[<Kind>,<Namespace>,<Name>]` entries with `*` as a wildcard. Thus, an item `[Node,*,*]` means that admissions of kind `Node` in any namespace and with any name will be ignored. Wildcards are also supported in each of these sequences. For example, this sequence filters out kind `Pod` in namespace `foo-system` having names beginning with `redis`.

```
[Pod,foo-system,redis*]
```

By default a number of kinds are skipped in the default configuration including Nodes, Events, APIService, SubjectAccessReview, and more.

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: init-config
  namespace: kyverno
data:
  # resource types to be skipped by kyverno policy engine
  resourceFilters: "[Event,*,*][*,kube-system,*][*,kube-public,*][*,kube-node-lease,*][Node,*,*][APIService,*,*][TokenReview,*,*][SubjectAccessReview,*,*][*,kyverno,*]"
```

To modify the ConfigMap, either directly edit the ConfigMap `init-config` in the default configuration inside `install.yaml` and redeploy it or modify the ConfigMap using `kubectl`.  Changes to the ConfigMap through `kubectl` will automatically be picked up at runtime.

## Upgrading Kyverno

Upgrading Kyverno is as simple as applying the new YAML manifest, or using Helm depending on how it was installed.

### Upgrade Kyverno with YAML manifest

Apply the new manifest over the existing installation.

```sh
kubectl apply -f https://raw.githubusercontent.com/kyverno/kyverno/main/definitions/release/install.yaml
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
helm upgrade kyverno --namespace kyverno kyverno/kyverno --version <version_number>
```

## Uninstalling Kyverno

To uninstall Kyverno, use either the raw YAML manifest or Helm. The Kyverno deployment, RBAC resources, and all CRDs will be removed, including any reports.

### Option 1 - Uninstall Kyverno with YAML manifest

```sh
kubectl delete -f https://raw.githubusercontent.com/kyverno/kyverno/main/definitions/release/install.yaml
```

### Option 2 - Uninstall Kyverno with Helm

```sh
helm uninstall kyverno --namespace kyverno kyverno/kyverno
```

### Clean up Webhook Configurations

Kyverno by default will try to clean up all its webhook configurations when terminated. But in cases where its RBAC resources are removed first, it will lose the permission to do so properly.

Regardless which uninstallation method is chosen, webhooks will need to be manually removed as the final step. Use the below commands to delete those webhook configurations.

```sh
kubectl delete mutatingwebhookconfigurations kyverno-policy-mutating-webhook-cfg kyverno-resource-mutating-webhook-cfg kyverno-verify-mutating-webhook-cfg

kubectl delete validatingwebhookconfigurations kyverno-policy-validating-webhook-cfg kyverno-resource-validating-webhook-cfg
```
