---
date: 2022-10-24
title: Kyverno 1.8 Released
linkTitle: Kyverno 1.8
description: Kyverno 1.8 is here.
draft: false
---

![kyverno](kyverno.png)

Following on the heels of the 1.7 release of Kyverno, the Kyverno team is proud to present version 1.8 which is another huge leap forward not just in terms of features and functionality but of optimizations, performance, and other improvements required in strict or high-scale environments. And in addition to those, a tremendous amount of work went into refactoring and other housekeeping items that make Kyverno cleaner and more efficient making future development (and contributions) easier, quicker, and ultimately more maintainable. We'll walk through the largest of these features in this article.

## Key New Features of Kyverno 1.8

### Pod Security Integration

The successor to Kubernetes' Pod Security Policy (PSP) is [Pod Security Admission](https://kubernetes.io/docs/concepts/security/pod-security-admission/), enabled by default in 1.23 and stable now in 1.25. This new technology implements a set of standards dubbed [Pod Security Standards](https://kubernetes.io/docs/concepts/security/pod-security-standards/). Pod Security Admission brings many benefits over PSPs but also some fairly important caveats. Starting in 1.8, Kyverno has a new validate subrule called podSecurity which internally uses the same libraries as Pod Security Admission but allows for much simpler implementation of those standards while offering flexible exemptions not found in Pod Security Admission. Shown below is an example of this new podSecurity rule in action which implements the entire restricted profile of the Pod Security Standards across the entire cluster.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: podsecurity-restricted
spec:
  background: true
  validationFailureAction: audit
  rules:
    - name: restricted
      match:
        any:
          - resources:
              kinds:
                - Pod
      validate:
        podSecurity:
          level: restricted
          version: latest
```

### YAML Manifest Verification

Although Kyverno has integrated with [Sigstore](https://www.sigstore.dev/) tooling for some time now, offering capabilities like [container image signature verification and attestation verification](/docs/policy-types/cluster-policy/verify-images), Kyverno 1.8 steps this up one notch further by bringing support for Sigstore's [manifest project](https://github.com/sigstore/k8s-manifest-sigstore). With this integration, Kyverno is now additionally able to verify signatures on Kubernetes YAML manifests to ensure, like container images, that they haven't been tampered with. Once a manifest has been signed with a private key of a user's choosing, a new Kyverno policy may be written which verifies the signature and comparing the signed (original) manifest contents with the current contents. Shown here is an example of such a policy which verifies the key used to sign Deployments.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: verify-manifest-integrity
spec:
  validationFailureAction: audit
  background: true
  rules:
    - name: verify-deployment-allow-replicas
      match:
        any:
          - resources:
              kinds:
                - Deployment
      validate:
        manifests:
          attestors:
            - count: 1
              entries:
                - keys:
                    publicKeys: |-
                      -----BEGIN PUBLIC KEY-----
                      MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEStoX3dPCFYFD2uPgTjZOf1I5UFTa
                      1tIu7uoGoyTxJqqEq7K2aqU+vy+aK76uQ5mcllc+TymVtcLk10kcKvb3FQ==
                      -----END PUBLIC KEY-----
          ignoreFields:
            - objects:
                - kind: Deployment
              fields:
                - spec.replicas
```

Signing of manifests is a great way to bolster the security of your cluster, but it also requires some flexibility. Teams often need to change values and certain fields (in addition to Kubernetes itself needing to sometimes change them). That's why with this new rule type there is an object where you can specify which fields to ignore when verifying those manifests. In the previous policy, it provides an exception for the replicas field of a Deployment allowing only the value of this field to deviate from what was originally signed.

### Cloning Multiple Resources

One of the defining capabilities of Kyverno is its simple way of [generating new Kubernetes resources](/docs/policy-types/cluster-policy/generate) as opposed to just validating or mutating them. We've seen tremendous adoption of this policy-based ability by software teams and users all over the place. One of the most common use cases for this generate ability is in multi-tenancy or Namespace-as-a-Service provisioning processes. But something we heard loud and clear was that users needed to clone more than just a single resource at a time. Very often, when provisioning a new Namespace, a variety of resources are required before handing that over. For example, Secrets, ConfigMaps, Custom Resources, and others are commonly required. In Kyverno 1.8, we've brought you this ability by now allowing a single generate rule to define, in a selective manner, and clone multiple resources from the same source Namespace. As you can see from the below policy, whenever a new Namespace is created, all the Secrets and ConfigMaps in the `staging` Namespace which have been labeled with `allowedToBeClone=true` will be cloned into the new Namespace.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: provision-namespaces
spec:
  rules:
    - name: sync-secrets-configmaps
      match:
        any:
          - resources:
              kinds:
                - Namespace
      generate:
        namespace: '{{request.object.metadata.name}}'
        synchronize: true
        cloneList:
          namespace: staging
          kinds:
            - v1/Secret
            - v1/ConfigMap
          selector:
            matchLabels:
              allowedToBeCloned: 'true'
```

### GitOps Friendly Rule Auto-Generation Is Here To Stay

In the 1.7 release, we introduced the new concept of moving Pod rule autogeneration out of `spec` and into `status` to be more kind to our GitOps users. Now in 1.8, that feature is on by default and no feature flags are required, allowing users of popular GitOps tools like Flux and ArgoCD to deploy Kyverno policies through their tooling without having to slightly adapt their definitions to account for these changes.

## Other Additions and Enhancements

Kyverno 1.8 is such a substantial release it's hard to cover all of the features, but here are a few others to note.

OpenTelemetry support was added for those who want an alternative to Prometheus.

The CLI now supports testing of generate policies joining long-time support for validate and mutate rule testing.

On the JMESPath side, we have two new filters called `random` and `x509_decode`. The `random` filter gives Kyverno the ability to generate random strings of data but in a fully composable and easy-to-use way. The `x509_decode` filter allows Kyverno to interpret PEM-encoded X509 certificates and make policy decisions based upon their contents, excellent for doing things like checking certificate subjects, expiration dates, and more.

The reporting system received a total overhaul in this release which makes it both lighter on memory, faster to generate policy reports, and more reliable.

Over time with the tremendous development velocity achieved in Kyverno, we've added many new fields and changed others. Kyverno 1.8 introduces a new schema version `v2beta1` which is what we'll begin using in the near future as it brings all the various rule types fully up-to-date with the latest and greatest.

And on the sample policy library, almost forty new policies have been added including implementation of best practices for common service meshes like Istio and Linkerd, CI/CD tools like Tekton, and more. This brings the total up to around 230 making Kyverno, by far, the policy engine with the [largest number of samples](/policies/) designed to help get you running faster and easier.

## Potentially Breaking Changes

A couple things of which to be aware prior to upgrading. First, the Helm chart registry URL has changed to `ghcr.io/kyverno/charts/kyverno` so make sure to update your Helm repositories. And second, because we've revamped Kyverno's reporting and background scanning abilities, the `backgroundScan` container flag you might have passed previously has changed to being a `true` or `false` value, simply either activating or deactivating background scans.

## Closing

Just like in previous releases, Kyverno 1.8 is a huge release [closing over 250 issues](https://github.com/kyverno/kyverno/releases/tag/v1.8.0). The maintainers and contributors have been hard at work for the past few months trying to bring additional value to the community, so we hope you find this release useful. As always, we love the community and hope you engage with us on any one of our outlets.
