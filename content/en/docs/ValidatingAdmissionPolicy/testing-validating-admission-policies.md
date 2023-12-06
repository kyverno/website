---
title: Testing ValidatingAdmissionPolicies
description: >
  Testing Kubernetes ValidatingAdmissionPolicies using Kyverno CLI.
weight: 50
---
Kubernetes [ValidatingAdmissionPolicy (VAP)](https://kubernetes.io/docs/reference/access-authn-authz/validating-admission-policy/) was first introduced in 1.26, and it's not fully enabled by default as of Kubernetes versions up to and including 1.28. It provides a declarative, in-process option for validating admission webhooks and uses the [Common Expression Language](https://github.com/google/cel-spec) (CEL) to perform resource validation checks directly in the API server. The Kyverno Command Line Interface (CLI) enables the validation and testing of ValidatingAdmissionPolicies on resources before adding them to a cluster. It can be integrated into CI/CD pipelines to help with the resource authoring process, ensuring that they adhere to the required standards before deployment. 

Check the below sections for more information:
1. [Apply ValidatingAdmissionPolicies to resources using `kyverno apply`](/docs/kyverno-cli/#validatingadmissionpolicy).
2. [Test ValidatingAdmissionPolicies aganist resources using `kyverno test`](/docs/kyverno-cli/#validatingadmissionpolicy-1)
