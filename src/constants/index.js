import {} from 'lucide-react'

import {
  Box,
  ChartColumn,
  CircleCheckBig,
  Code,
  GitBranch,
  Globe,
  Lock,
  Shield,
  Terminal,
  TestTube,
  Zap,
} from 'lucide-react'

import { themes } from 'prism-react-renderer'

export const versions = [
  { label: 'v1alpha1', href: '#' },
  { label: 'v1.15', href: '#' },
  { label: 'v1.14', href: '#' },
]

export const navItemsOnsite = []

export const navItemsExternal = [
  { label: 'Documentation', href: '/docs/introduction' },
  { label: 'Sample Policies', href: '/policies' },
  { label: 'Community', href: '/community' },
  { label: 'Blog', href: '#' },
]

export const whyKyvernoCards = [
  {
    icon: Zap,
    title: 'Easy to Adopt',
    desc1: 'Use familiar languages and tools.',
    desc2:
      'Kubernetes-native types that integrate seamlessly into your workflow.',
  },
  {
    icon: Shield,
    title: 'Flexible & Powerful',
    desc1:
      'From basic validation to complex automation, Kyverno has you covered.',
    desc2: 'Built for Kubernetes, now works everywhere.',
  },
  {
    icon: Globe,
    title: 'Trusted & Proven',
    desc1: 'Production-ready at scale for enterprises worldwide.',
    desc2: 'Top CNCF project with a vibrant community and ecosystem.',
  },
]

export const cardColors1 = [
  {
    bg: 'bg-primary-100/20',
    text: 'text-primary-100',
  },
  {
    bg: 'bg-primary-75/20',
    text: 'text-primary-75',
  },
  {
    bg: 'bg-primary-50/20',
    text: 'text-primary-50',
  },
]

export const cardColors2 = [
  {
    bg: 'bg-blue-900/70',
    text: 'text-blue-300',
  },
  {
    bg: 'bg-orange-900/70',
    text: 'text-orange-300',
  },
  {
    bg: 'bg-yellow-900/70',
    text: 'text-yellow-300',
  },
  {
    bg: 'bg-green-900/70',
    text: 'text-green-300',
  },
  {
    bg: 'bg-purple-900/70',
    text: 'text-purple-300',
  },
  {
    bg: 'bg-cyan-900/70',
    text: 'text-cyan-300',
  },
  {
    bg: 'bg-indigo-900/70',
    text: 'text-indigo-300',
  },
  {
    bg: 'bg-amber-900/70',
    text: 'text-amber-300',
  },
  {
    bg: 'bg-lime-900/70',
    text: 'text-lime-300',
  },
]

export const celPoliciesCardColors = [
  { bg: 'bg-blue-900' },
  { bg: 'bg-orange-900' },
  { bg: 'bg-green-900' },
  { bg: 'bg-purple-900' },
  { bg: 'bg-red-900' },
]

export const yamlCelCardColors = [
  { bg: 'bg-primary-100' },
  { bg: 'bg-primary-50' },
]

export const kyvernoVsOthers = [
  {
    feature: 'Policy Language',
    kyverno: 'YAML & CEL (languages familiar to K8s users)',
    opa: 'Constraint Templates, Rego (new DSL to learn)',
    kubernetesNative: 'Placeholder text for Kubernetes Native Policies',
  },
  {
    feature: 'Ease of Adoption',
    kyverno: 'Intuitive, no extra learning curve',
    opa: 'Steeper learning curve due to Rego',
    kubernetesNative: 'Placeholder text for Kubernetes Native Policies',
  },
  {
    feature: 'K8s Resource Validation',
    kyverno: 'Yes',
    opa: 'Yes',
    kubernetesNative: 'limited',
  },
  {
    feature: 'K8s Resource Mutation',
    kyverno: 'Yes',
    opa: 'limited',
    kubernetesNative: 'limited',
  },
  {
    feature: 'K8s Resource Generation',
    kyverno: 'Yes',
    opa: 'No',
    kubernetesNative: 'No',
  },
  {
    feature: 'K8s Resource Cleanup',
    kyverno: 'Yes',
    opa: 'No',
    kubernetesNative: 'No',
  },
  {
    feature: 'Any JSON / YAML',
    kyverno: 'Yes',
    opa: 'Yes',
    kubernetesNative: 'No',
  },
]

export const features = [
  {
    icon: Box,
    title: 'Kubernetes Native',
    details:
      'Extends and completes Kubernetes policy types for comprehensive platform engineering capabilities.',
  },
  {
    icon: Globe,
    title: 'Works Everywhere',
    details:
      'Executes Kubernetes-style policies on any JSON payload using CLI or SDK for universal compatibility.',
  },
  {
    icon: ChartColumn,
    title: 'Integrated Reporting',
    details:
      'OpenReports compatible producers, routers, and dashboards for comprehensive policy compliance visibility.',
  },
  {
    icon: Shield,
    title: 'Exception Management',
    details:
      'Timebound and fine-grained exception management decoupled from policies for flexible governance.',
  },
  {
    icon: Terminal,
    title: 'Shift-Left Integration',
    details:
      'CLI for seamless integrations into CI/CD and Infrastructure as Code (Terraform, etc.) pipelines.',
  },
  {
    icon: TestTube,
    title: 'Policy Testing',
    details:
      'Comprehensive tooling for declarative unit tests and end-to-end behavioral policy validation.',
  },
  {
    icon: Zap,
    title: 'CEL Performance',
    details:
      'Enhanced performance with Common Expression Language for faster policy, evaluation and execution.',
  },
  {
    icon: GitBranch,
    title: 'Version Control',
    details:
      'Full version control integration with GitOps workflows for policy lifecycle management.',
  },
  {
    icon: Lock,
    title: 'Security Policies',
    details:
      'Comprehensive security policy templates and best practices for zero-trust architectures.',
  },
]

export const celPolicies = [
  {
    icon: CircleCheckBig,
    title: 'ValidatingPolicy',
    description:
      'For validation of Kubernetes resources or arbitrary JSON payloads using CEL expressions.',
  },
  {
    icon: CircleCheckBig,
    title: 'ImageValidatingPolicy',
    description:
      'Dedicated solely to verifying container images: their signatures, attestations, SBOMs, etc.',
  },
  {
    icon: CircleCheckBig,
    title: 'MutatingPolicy',
    description:
      'For mutating or modifying resources using CEL first, including patches/ApplyConfiguration.',
  },
  {
    icon: CircleCheckBig,
    title: 'GeneratingPolicy',
    description:
      'For creating or cloning resources in response to triggers (e.g. on creation of certain resources), but using CEL for more flexible logic.',
  },
  {
    icon: CircleCheckBig,
    title: 'DeletingPolicy',
    description:
      'For controlled cleanup of resources, scheduled deletions or deletions when certain conditions in the cluster are met.',
  },
]

export const yamlCEL = [
  {
    icon: CircleCheckBig,
    title: 'Traditional YAML Policies',
    color: 'light-blue',
    content: `apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: require-labels
spec:
  validationFailureAction: Enforce
  background: true
  rules:
  - name: check-for-labels
    match:
      any:
      - resources:
          kinds:
          - Pod
    validate:
      message: "Missing required labels"
      pattern:
        metadata:
          labels:
            app: "*"
            version: "*"`,
  },
  {
    icon: Zap,
    title: 'New CEL-Based Policies',
    color: 'deep-blue',
    content: `apiVersion: policies.kyverno.io/v1alpha1
kind: ValidatingPolicy
metadata:
  name: check-labels
spec:
  validationActions:
    - Deny
  matchConstraints:
    resourceRules:
    - apiGroups:   [""]
      apiVersions: [v1]
      operations:  [CREATE, UPDATE]
      resources:   [pods]
  validations:
    - message: "Missing required labels"
      expression: >
        has(object.metadata.labels.app) && 
        has(object.metadata.labels.version)`,
  },
]

export const partners = [
  { image: 'assets/product-icons/adidas-icon.svg', name: 'Adidas' },
  { image: 'assets/product-icons/bloomberg-icon.svg', name: 'Bloomberg' },
  { image: 'assets/product-icons/linkedin-icon.svg', name: 'Linkedin' },
  { image: 'assets/product-icons/razorpay-icon.svg', name: 'Razorpay' },
  { image: 'assets/product-icons/robinhood-icon.svg', name: 'Robinhood' },
  { image: 'assets/product-icons/spotify-icon.svg', name: 'Spotify' },
  { image: 'assets/product-icons/telecom-icon.svg', name: 'Telecom' },
  { image: 'assets/product-icons/us-dod-icon.svg', name: 'US-DOD' },
  { image: 'assets/product-icons/vodafone-icon.svg', name: 'Vodafone' },
  { image: 'assets/product-icons/wayfair-icon.svg', name: 'Wayfair' },
  { image: 'assets/product-icons/yahoo-icon.svg', name: 'Yahoo' },
]

export const productsLinks = [
  { href: 'https://kyverno.io/support/blakyaks/', text: 'BlakYaks' },
  { href: 'https://kyverno.io/support/giantswarm/', text: 'Giant Swarm' },
  { href: 'https://kyverno.io/support/infracloud/', text: 'Infra Cloud' },
  { href: 'https://kyverno.io/support/kodekloud/', text: 'Kodekloud' },
  { href: 'https://kyverno.io/support/nirmata/', text: 'Nirmata' },
]

export const ResourcesLinks = [
  { href: 'docs/introduction', text: 'Documentation' },
  {
    href: 'https://kyverno.io/docs/kyverno-cli/reference/',
    text: 'API Reference',
  },
  { href: 'policies', text: 'Policy Samples' },
  { href: '#', text: 'Blog' },
]

export const communityLinks = [
  { href: 'https://github.com/kyverno', text: 'Github' },
  { href: 'https://slack.k8s.io/#kyverno', text: 'Slack' },
  {
    href: 'https://github.com/kyverno/kyverno/blob/main/CONTRIBUTING.md',
    text: 'Contributing',
  },
]

export const policies = [
  {
    href: 'https://www.linuxfoundation.org/legal/privacy-policy',
    text: 'Privacy Policy',
  },
  {
    href: 'https://www.linuxfoundation.org/legal/terms',
    text: 'Terms of service',
  },
  { href: 'https://www.linuxfoundation.org/security', text: 'Security' },
]

export const heroSectionHeadingContent = {
  headingText: [
    { text: 'Unified', color: 'text-primary-100' },
    { text: 'Policy as Code', color: 'text-primary-100' },
    { text: 'Simplified!', color: 'text-accent-100' },
  ],

  paragraphText: `Secure, automate, and operate all your infrastructure and applications with YAML and CEL based policies.`,
}

export const whykyvernoHeadingContent = {
  headingText: [],

  paragraphText: ``,
}

export const comparisonChartHeadingContent = {
  headingText: [
    { text: 'Kyverno vs', color: 'text-white' },
    { text: 'Other policy engines', color: 'text-primary-100' },
  ],

  paragraphText: `As the industry's leading policy engine, here's how Kyverno 
                    compares with other policy engines.`,
}

export const featureSectionHeadingContent = {
  headingText: [
    { text: 'Complete Platform Engineering', color: 'text-white' },
    { text: 'Policy As Code Solution', color: 'text-primary-100' },
  ],

  paragraphText: `From policy creation to enforcement, testing to reporting, and everything in between,
                       get comprehensive Kubernetes governance and compliance with Kyverno.`,
}

export const celPoliciesHeadingContent = {
  headingText: [
    { text: 'Introducing', color: 'text-white' },
    { text: 'CEL Polices', color: 'text-primary-100' },
  ],
  paragraphText: `CEL (Common Expression Language) policies bring powerful, 
                    fine-grained control to Kyverno, enabling users to write more 
                    expressive and dynamic policy rules without sacrificing performance. `,
}

export const ctaSectionHeadingContent = {
  headingText: [{ text: 'Get started with Kyverno', color: 'text-white' }],

  paragraphText: `Deploy Kyverno in your Kubernetes cluster within minutes and start writing 
                  policies using simple, familiar YAML.`,
}

export const partnersSectionHeadingContent = {
  headingText: [{ text: 'Trusted By Industry Leaders', color: 'text-white' }],

  paragraphText: 'Powering policy management for organizations worldwide',
}

export const codingThemes = {
  dark: themes.materialDark,
  light: themes.materialLight,
}

export const policyShowcaseHeadingContent = {
  headingText: [
    { text: 'Kyverno', color: 'text-white' },
    { text: 'Policy Showcase', color: 'text-primary-100' },
  ],
  paragraphText: `Explore sample policies showcasing Kyverno's versatility across different use cases and policy types.`,
}

export const policyShowcaseTabs = [
  {
    id: 'validate-k8s',
    label: 'Validate K8s Resources',
    learnMore: '/docs/policy-types/validating-policy',
    policy: `apiVersion: kyverno.io/v1
kind: ValidatingPolicy
metadata:
  name: require-labels
spec:
  validationFailureAction: Enforce
  rules:
    - name: check-labels
      match:
        any:
          - resources:
              kinds:
                - Pod
      validate:
        cel:
          expressions:
            - expression: |
                has(object.metadata.labels.app) &&
                has(object.metadata.labels.version)
              message: "Pod must have 'app' and 'version' labels"`,
  },
  {
    id: 'validate-terraform',
    label: 'Validate Terraform',
    learnMore: '/docs/policy-types/validating-policy',
    policy: `apiVersion: json.kyverno.io/v1alpha1
kind: ValidatingPolicy
metadata:
  name: require-encryption
spec:
  match:
    any:
      - resources:
          kinds:
            - terraform.aws_s3_bucket
  validate:
    cel:
      expressions:
        - expression: |
            object.server_side_encryption_configuration != null
          message: "S3 buckets must have encryption enabled"`,
  },
  {
    id: 'validate-dockerfile',
    label: 'Validate Dockerfile',
    learnMore: '/docs/policy-types/validating-policy',
    policy: `apiVersion: json.kyverno.io/v1alpha1
kind: ValidatingPolicy
metadata:
  name: require-non-root
spec:
  match:
    any:
      - resources:
          kinds:
            - Dockerfile
  validate:
    cel:
      expressions:
        - expression: |
            !contains(object.content, "USER root")
          message: "Dockerfiles must not run as root user"`,
  },
  {
    id: 'validate-http',
    label: 'HTTP Authorization',
    learnMore: '/docs/policy-types/validating-policy',
    policy: `apiVersion: json.kyverno.io/v1alpha1
kind: ValidatingPolicy
metadata:
  name: require-auth-header
spec:
  match:
    any:
      - resources:
          kinds:
            - HTTPRequest
  validate:
    cel:
      expressions:
        - expression: |
            has(object.headers.authorization)
          message: "HTTP requests must include authorization header"`,
  },
  {
    id: 'mutate-k8s',
    label: 'Mutate K8s Resources',
    learnMore: '/docs/policy-types/mutating-policy',
    policy: `apiVersion: kyverno.io/v1
kind: MutatingPolicy
metadata:
  name: add-default-labels
spec:
  rules:
    - name: add-labels
      match:
        any:
          - resources:
              kinds:
                - Pod
      mutate:
        patchStrategicMerge:
          metadata:
            labels:
              managed-by: kyverno
              +(app): "{{request.object.metadata.name}}"`,
  },
  {
    id: 'generate-k8s',
    label: 'Generate K8s Resources',
    learnMore: '/docs/policy-types/generating-policy',
    policy: `apiVersion: kyverno.io/v1
kind: GeneratingPolicy
metadata:
  name: generate-network-policy
spec:
  rules:
    - name: generate-netpol
      match:
        any:
          - resources:
              kinds:
                - Namespace
      generate:
        apiVersion: networking.k8s.io/v1
        kind: NetworkPolicy
        name: default-deny
        namespace: "{{request.object.metadata.name}}"
        synchronize: true
        data:
          spec:
            podSelector: {}
            policyTypes:
              - Ingress
              - Egress`,
  },
  {
    id: 'cleanup-k8s',
    label: 'Cleanup K8s Resources',
    learnMore: '/docs/policy-types/cleanup-policy',
    policy: `apiVersion: kyverno.io/v2alpha1
kind: CleanupPolicy
metadata:
  name: cleanup-old-pods
spec:
  match:
    any:
      - resources:
          kinds:
            - Pod
          namespaces:
            - default
  schedule: "0 0 * * *"
  conditions:
    any:
      - key: "{{request.object.metadata.creationTimestamp}}"
        operator: GreaterThanOrEquals
        value: "{{time_ago('24h')}}"`,
  },
  {
    id: 'validate-images',
    label: 'Validate Images',
    learnMore: '/docs/policy-types/image-validating-policy',
    policy: `apiVersion: kyverno.io/v1
kind: ImageValidatingPolicy
metadata:
  name: verify-image-signatures
spec:
  rules:
    - name: verify-signature
      match:
        any:
          - resources:
              kinds:
                - Pod
      verifyImages:
        - imageReferences:
            - "*"
          attestors:
            - count: 1
              entries:
                - keys:
                    publicKeys: |-
                      -----BEGIN PUBLIC KEY-----
                      MFkwEwYHKoZIzj0CAQYIKoZIzj0CAQcDQgAE...
                      -----END PUBLIC KEY-----`,
  },
]
