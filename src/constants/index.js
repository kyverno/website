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

export const navItemsOnsite = [
  { label: 'Why Kyverno', targetId: 'whykyverno' },
  { label: 'Features', targetId: 'features' },
  { label: 'Policies', targetId: 'policies' },
]

export const navItemsExternal = [
  { label: 'Docs', href: '/getting-started/introduction' },
  { label: 'Blog', href: '/blog' },
  { label: 'Community', href: 'https://kyverno.io/community/' },
]

export const heroTags = [
  {
    title: 'Kubernates Native',
    icon: Shield,
  },
  {
    title: 'Flexible',
    icon: Code,
  },
  {
    title: 'Enhanced Performance',
    icon: Zap,
  },
]

export const whyKyvernoCards = [
  {
    icon: Code,
    title: 'Kubernates Native',
    desc1: 'Uses YAML & CEL, languages familiar to K8s users',
    desc2: 'Write & apply policies as CRDs',
    color: 'blue',
  },
  {
    icon: Zap,
    title: 'Easy to Adopt',
    desc1: 'Quick and easy to get started with',
    desc2: 'Designed for K8s',
    color: 'orange',
  },
  {
    icon: Shield,
    title: 'Flexible & Powerful',
    desc1: 'Wide range of use cases',
    desc2: 'Fits naturally into existing workflows',
    color: 'green',
  },
  {
    icon: Globe,
    title: 'Trusted & Proven',
    desc1: 'CNCF incubating project',
    desc2: 'Widely adopted & used in Production by orgs of all sizes',
    color: 'purple',
  },
]

export const cardColors1 = [
  {
    bg: 'bg-blue-900/70',
    text: 'text-blue-300',
  },
  {
    bg: 'bg-orange-900/70',
    text: 'text-orange-300',
  },
  {
    bg: 'bg-green-900/70',
    text: 'text-green-300',
  },
  {
    bg: 'bg-purple-900/70',
    text: 'text-purple-300',
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
    kyverno:
      'Supports YAML & CEL-based policies (languages familiar to K8s users)',
    opa: 'Rego (new DSL to learn)',
  },
  {
    feature: 'Ease of Adoption',
    kyverno: 'Intuitive, no extra learning curve',
    opa: 'Steeper learning curve due to Rego',
  },
  {
    feature: 'Policy Types',
    kyverno: 'Validate, Mutate, Generate, Verify, Delete',
    opa: 'Validate',
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
  { href: '#', text: 'Features' },
  { href: '#', text: 'CEL Policies' },
  { href: '#', text: 'Migration Guide' },
  { href: 'https://playground.kyverno.io/', text: 'Playground' },
]

export const ResourcesLinks = [
  { href: '/getting-started/introduction', text: 'Documentation' },
  { href: '#', text: 'API Reference' },
  { href: 'https://kyverno.io/community/', text: 'Policy Samples' },
  { href: '/blog', text: 'Blog' },
]

export const communityLinks = [
  { href: 'https://github.com/kyverno/kyverno/', text: 'Github' },
  {
    href: 'https://communityinviter.com/apps/kubernetes/community#kyverno',
    text: 'Slack',
  },
  { href: 'https://github.com/kyverno/kyverno/', text: 'Contributing' },
]

export const policies = [
  { href: '#', text: 'Privacy Policy' },
  { href: '#', text: 'Terms of service' },
  { href: '#', text: 'Security' },
]

export const heroSectionHeadingContent = {
  headingText: [
    { text: 'Unified', color: 'text-primary-100' },
    { text: 'Policy As Code', color: 'text-white' },
    { text: 'For Platform Engineers', color: 'text-accent-100' },
  ],

  paragraphText: `Kyverno, created by Nirmata, makes it simple to secure, 
                  automate, and manage your infrastructures and applications 
                  using Kubernetes-native YAML and CEL. Easy-to-learn and 
                  powered by the CNCF community.`,
}

export const whykyvernoHeadingContent = {
  headingText: [
    { text: 'why', color: 'text-white' },
    { text: 'Kyverno', color: 'text-primary-100' },
  ],

  paragraphText: `Kyverno, created by Nirmata is the Kubernetes-native policy 
                  engine designed to simplify security, compliance, and 
                  automation by letting you manage policies the same way 
                  you manage your cluster.`,
}

export const comparisonChartHeadingContent = {
  headingText: [
    { text: 'Kyverno Vs', color: 'text-white' },
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

export const BlogSectionContent = {
  headingText: [
    { text: 'Latest', color: 'text-white' },
    { text: 'On Kyverno', color: 'text-primary-100' },
  ],

  paragraphText:
    'Keep up with projects, updates and insights from the Kyverno community',
}

export const blogSectionHeadingContent = {
  headingText: [
    { text: 'Announcing', color: 'text-white' },
    { text: 'Kyverno Release 1.15!', color: 'text-accent-100' },
  ],

  paragraphText:
    'Kyverno 1.15 makes policy management more modular, streamlined, and powerful.',
}

export const codingThemes = {
  dark: themes.materialDark,
  light: themes.materialLight,
}
