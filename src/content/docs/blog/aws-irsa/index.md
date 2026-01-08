---
date: 2023-08-18
title: Verifying images in a private Amazon ECR with Kyverno and IAM Roles for Service Accounts (IRSA)
slug: blog/verifying-images-in-a-private-amazon-ecr-with-kyverno-and-iam-roles-for-service-accounts-irsa
tags:
  - General
authors:
  - name: Shuting Zhao
excerpt: Using Kyverno to verify images with IRSA
---

When running workloads in Amazon Elastic Kubernetes Service (EKS), it is essential to ensure supply chain security by verifying container image signatures and other metadata. To achieve this, you can configure Kyverno, a CNCF policy engine designed for Kubernetes, to pull from ECR private registries for image verification. It's possible to [pass in the credentials via secrets](/docs/policy-types/cluster-policy/verify-images/sigstore/#using-private-registries), but that can get difficult to manage and automate across multiple clusters. In this blog post, we will explore an alternative method that simplifies the authentication process by leveraging Kyverno and IRSA (IAM Roles for Service Accounts) in EKS for image verification.

Applications, such as Kyverno, running within a Pod's containers can utilize the AWS SDK to make API requests to AWS services by leveraging AWS Identity and Access Management (IAM) permissions. IAM roles for service accounts enable the management of credentials for these applications. Instead of manually creating and distributing AWS credentials to the containers, you can associate an IAM role with a Kubernetes service account and configure your Pods to utilize this service account. The detailed steps for this process can be found in the [documentation](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html). In this blog, we will guide you through the complete process of enabling IAM roles for the Kyverno service account and demonstrate how to verify this using the Kyverno `verifyImages` rule.

## Setting up the EKS Cluster

First, you need to [create an EKS cluster](https://docs.aws.amazon.com/eks/latest/userguide/create-cluster.html). You can then use the AWS CLI to update the kubeconfig file with the cluster details:

```sh
$ aws eks update-kubeconfig --region us-west-2 --name kyverno-irsa
Added new context arn:aws:eks:us-west-2:xxxxxxxxxxxx:cluster/kyverno-irsa to /Users/kyverno/.kube/config
```

Once the kubeconfig is updated, you can verify the cluster by running the following command:

```sh
$ kubectl get node
NAME                                          STATUS   ROLES    AGE   VERSION
ip-172-31-56-181.us-west-2.compute.internal   Ready    <none>   1h   v1.27.3-eks-a5565ad
```

Note: when you use IRSA, it updates the credential chain of the pod to use the IRSA token, however, the pod can still inherit the rights of the instance profile assigned to the worker node. You need to block access to instance metadata to prevent pods that do not use IRSA from inheriting the role assigned to the worker node.

You can follow this [guidance](https://aws.github.io/aws-eks-best-practices/security/docs/iam/#restrict-access-to-the-instance-profile-assigned-to-the-worker-node) to restrict access via the following command, for example:

```sh
aws ec2 modify-instance-metadata-options --instance-id <instance-id> --http-tokens required --http-put-response-hop-limit 1
```

## Installing Kyverno

Once you have the cluster set up, you can use Helm to [install Kyverno into the cluster](/docs/installation/methods):

```sh
helm upgrade --install kyverno kyverno/kyverno --namespace kyverno --create-namespace
```

## Enabling IAM roles for service accounts

### Creating an IAM OIDC Provider for the Cluster

To enable IRSA, you need to create an IAM OIDC provider for the EKS cluster. You can retrieve the OIDC issuer URL using the AWS CLI. The following command retrieves the provider for the cluster `kyverno-irsa`, replace it with your own cluster name:

```sh
export cluster_name=kyverno-irsa
oidc_id=$(aws eks describe-cluster --name $cluster_name --query "cluster.identity.oidc.issuer" --output text | cut -d '/' -f 5)
```

Determine whether an IAM OIDC provider with your cluster's ID is already in your account.

```sh
aws iam list-open-id-connect-providers | grep $oidc_id | cut -d "/" -f4
```

If output is returned, then you already have an IAM OIDC provider for your cluster. If no output is returned, then there's no OIDC provider is associated with the cluster. You can create one using the `eksctl` command:

```sh
$ eksctl utils associate-iam-oidc-provider --cluster $cluster_name --approve
2023-08-14 21:16:31 [ℹ]  will create IAM Open ID Connect provider for cluster "kyverno-irsa" in "us-west-2"
2023-08-14 21:16:33 [✔]  created IAM Open ID Connect provider for cluster "kyverno-irsa" in "us-west-2"
```

### Configuring a Kubernetes Service Account to Assume an IAM Role

To associate an IAM role with a Kubernetes service account, you need to create an IAM policy for your IAM role. If you want to associate an existing IAM policy, you can skip this step.

Setup a custom policy with the following permissions, note that in production its best to not use a wildcard and specify resources:

```sh
cat >notation-signer-policy.json <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "signer:GetSigningProfile",
                "signer:ListSigningProfiles",
                "signer:SignPayload",
                "signer:GetRevocationStatus",
                "signer:DescribeSigningJob",
                "signer:ListSigningJobs"
            ],
            "Resource": "*"
        }
    ]
}
EOF
```

Create the IAM policy:

```sh
aws iam create-policy --policy-name notation-signer-policy --policy-document file://notation-signer-policy.json
```

To configure a Kubernetes service account to assume an IAM role, you can use the `eksctl` command to create an IAM service account.

If your Kyverno is installed with default configurations, you can run the following command directly to create the IAM service account. Otherwise, replace the service account name and namespace with your custom values.

```sh
$ eksctl create iamserviceaccount --override-existing-serviceaccounts kyverno-admission-controller --namespace kyverno --cluster kyverno-irsa --role-name kyverno-irsa --attach-policy-arn arn:aws:iam::xxxxxxxxxxxx:policy/notation-signer-policy --approve
2023-08-14 21:18:17 [ℹ]  1 iamserviceaccount (kyverno/kyverno-admission-controller) was included (based on the include/exclude rules)
2023-08-14 21:18:17 [!]  metadata of serviceaccounts that exist in Kubernetes will be updated, as --override-existing-serviceaccounts was set
2023-08-14 21:18:17 [ℹ]  1 task: {
    2 sequential sub-tasks: {
        create IAM role for serviceaccount "kyverno/kyverno-admission-controller",
        create serviceaccount "kyverno/kyverno-admission-controller",
    } }2023-08-14 21:18:17 [ℹ]  building iamserviceaccount stack "eksctl-kyverno-irsa-addon-iamserviceaccount-kyverno-kyverno-admission-controller"
2023-08-14 21:18:17 [ℹ]  deploying stack "eksctl-kyverno-irsa-addon-iamserviceaccount-kyverno-kyverno-admission-controller"
2023-08-14 21:18:18 [ℹ]  waiting for CloudFormation stack "eksctl-kyverno-irsa-addon-iamserviceaccount-kyverno-kyverno-admission-controller"
2023-08-14 21:18:54 [ℹ]  waiting for CloudFormation stack "eksctl-kyverno-irsa-addon-iamserviceaccount-kyverno-kyverno-admission-controller"
2023-08-14 21:18:55 [ℹ]  serviceaccount "kyverno/kyverno-admission-controller" already exists
2023-08-14 21:18:55 [ℹ]  updated serviceaccount "kyverno/kyverno-admission-controller"
```

After creating the IAM service account, you can verify that the role and service account are configured correctly.

Confirm that the IAM role's trust policy is configured correctly:

```sh
$ aws iam get-role --role-name kyverno-irsa --query Role.AssumeRolePolicyDocument
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:aws:iam::xxxxxxxxxxxx:oidc-provider/oidc.eks.us-west-2.amazonaws.com/id/2EA2DE9A6C72778FA517C24D7BBE2916"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "oidc.eks.us-west-2.amazonaws.com/id/2EA2DE9A6C72778FA517C24D7BBE2916:aud": "sts.amazonaws.com",
                    "oidc.eks.us-west-2.amazonaws.com/id/2EA2DE9A6C72778FA517C24D7BBE2916:sub": "system:serviceaccount:kyverno:kyverno-admission-controller"
                }
            }
        }
    ]
}
```

Confirm that the policy that you attached to your role in a previous step is attached to the role:

```sh
$ aws iam list-attached-role-policies --role-name kyverno-irsa --query AttachedPolicies --output text
arn:aws:iam::xxxxxxxxxxxx:policy/notation-signer-policy notation-signer-policy
```

Confirm that the Kyverno service account is annotated with the role:

```sh
$ kubectl describe serviceaccount kyverno-admission-controller -n kyverno

Name:                kyverno-admission-controller
Namespace:           kyverno
Annotations:         eks.amazonaws.com/role-arn: arn:aws:iam::xxxxxxxxxxxx:role/kyverno-irsa
```

Confirm that the environment variables are injected to the admission controller:

```sh
$ kubectl get pod -n kyverno -l app.kubernetes.io/component=admission-controller -o yaml | grep AWS -A2
      - name: AWS_STS_REGIONAL_ENDPOINTS
        value: regional
      - name: AWS_DEFAULT_REGION
        value: us-west-2
      - name: AWS_REGION
        value: us-west-2
      - name: AWS_ROLE_ARN
        value: arn:aws:iam::xxxxxxxxxxxx:role/kyverno-irsa
      - name: AWS_WEB_IDENTITY_TOKEN_FILE
        value: /var/run/secrets/eks.amazonaws.com/serviceaccount/token
```

If you do not see these environment variables, try restarting the pod to inject variables. If you still do not see these variables, follow this instruction to [verify that your pod identity webhook configuration exists and is valid](https://repost.aws/knowledge-center/eks-troubleshoot-irsa-errors).

## Verifying ECR private images using IRSA and Kyverno

To test IRSA works with Kyverno, you can create pods with signed and unsigned images respectively and verify container images signatures using the Kyverno policy. If the IAM role assumption is configured correctly, the pod should be deployed successfully. Otherwise, Kyverno will deny the request.

The test image used in this blog is signed by Notary. If you don't have a signed images for testing, you can follow this guidance to [sign a private ECR image using Notation](https://docs.aws.amazon.com/AmazonECR/latest/userguide/image-signing.html).

You can inspect all signatures with Notation. The following is an inspection result of all signatures and signed artifacts for the test image `xxxxxxxxxxxx.dkr.ecr.us-west-2.amazonaws.com/test-shuting-notation:v1`:

```sh
✗ notation inspect xxxxxxxxxxxx.dkr.ecr.us-west-2.amazonaws.com/test-shuting-notation:v1
Inspecting all signatures for signed artifact
xxxxxxxxxxxx.dkr.ecr.us-west-2.amazonaws.com/test-shuting-notation@sha256:b31bfb4d0213f254d361e0079deaaebefa4f82ba7aa76ef82e90b4935ad5b105
└── application/vnd.cncf.notary.signature
    └── sha256:86abf8af48c152f871a5ea56a62a9302e145760089db926420e72c1bbd0de07d
        ├── media type: application/jose+json
        ├── signature algorithm: RSASSA-PSS-SHA-256
        ├── signed attributes
        │   ├── signingScheme: notary.x509
        │   └── signingTime: Fri Aug 11 16:37:40 2023
        ├── user defined attributes
        │   └── (empty)
        ├── unsigned attributes
        │   └── signingAgent: Notation/1.0.0
        ├── certificates
        │   └── SHA256 fingerprint: da1f2d7d648dfacc7ebd59f98a9f35c753c331d80ca4280bb94060f4af4a5357
        │       ├── issued to: CN=test,O=Notary,L=Seattle,ST=WA,C=US
        │       ├── issued by: CN=test,O=Notary,L=Seattle,ST=WA,C=US
        │       └── expiry: Thu May 19 21:15:18 2033
        └── signed artifact
            ├── media type: application/vnd.docker.distribution.manifest.v2+json
            ├── digest: sha256:b31bfb4d0213f254d361e0079deaaebefa4f82ba7aa76ef82e90b4935ad5b105
            └── size: 938
```

The following policy verifies the image signature for pods in `test-shuting` namespace, you can tune the policy to verify different images:

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  annotations:
    pod-policies.kyverno.io/autogen-controllers: none
  name: test-irsa
spec:
  background: true
  rules:
    - match:
        resources:
          kinds:
            - Pod
          namespaces:
            - test-shuting
      name: check-digest
      verifyImages:
        - attestors:
            - count: 1
              entries:
                - certificates:
                    cert: |-
                      -----BEGIN CERTIFICATE-----
                      ...
                      ...
                      ...
                      -----END CERTIFICATE-----
          imageReferences:
            - xxxxxxxxxxxx.dkr.ecr.us-west-2.amazonaws.com/test-shuting*
          mutateDigest: true
          required: true
          type: Notary
          verifyDigest: true
  validationFailureAction: Enforce
  webhookTimeoutSeconds: 30
```

Once the policy is installed in the cluster, you can create the pod using the signed image and check the creation passes through:

```sh
$ kubectl -n test-shuting run test --image=xxxxxxxxxxxx.dkr.ecr.us-west-2.amazonaws.com/test-shuting-notation:v1 --dry-run=server
pod/test created (server dry run)
```

Then if you create the pod using an unsigned image, the pod creation is blocked by Kyverno as it does not have any signatures associated with it:

```sh
$ kubectl -n test-shuting run test --image=xxxxxxxxxxxx.dkr.ecr.us-west-2.amazonaws.com/test-shuting-notation:v1-unsigned --dry-run=server

Error from server: admission webhook "mutate.kyverno.svc-fail" denied the request:

resource Pod/test-shuting/test was blocked due to the following policies

test-irsa:
  check-digest: 'failed to verify image xxxxxxxxxxxx.dkr.ecr.us-west-2.amazonaws.com/test-shuting-notation:v1-unsigned:
    .attestors[0].entries[0]: failed to verify xxxxxxxxxxxx.dkr.ecr.us-west-2.amazonaws.com/test-shuting-notation@sha256:74a98f0e4d750c9052f092a7f7a72de7b20f94f176a490088f7a744c76c53ea5:
    no signature is associated with "xxxxxxxxxxxx.dkr.ecr.us-west-2.amazonaws.com/test-shuting-notation@sha256:74a98f0e4d750c9052f092a7f7a72de7b20f94f176a490088f7a744c76c53ea5",
    make sure the artifact was signed successfully'

```

### Conclusion

By leveraging Kyverno and IRSA, you can simplify the configuration of IAM role assumptions for Kubernetes service accounts in EKS. This approach enhances the security of the cluster by ensuring fine-grained access control to AWS resources. With the steps outlined in this blog post, you can easily set up and test IRSA in your EKS cluster.
