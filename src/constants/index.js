import {
  Shield,
  Code,
  Zap,
  Globe,
  Box,
  ChartColumn,
  Terminal,
} from 'lucide-react'
import {
  TestTube,
  GitBranch,
  Lock,
  CircleCheckBig,
  Github,
  Book,
} from 'lucide-react'

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
  { label: 'Docs', href: '/docs/introduction' },
  { label: 'Blog', href: '#' },
  { label: 'Community', href: '/community' },
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
       rules:
    name: check-labels
    match:
        any:
    resources:
        kinds:
        - Pod
              validate:
                  message: “Missing required labels”
        pattern:
            metadata:
                            labels:
            app:”?*”
            version:”?*”`,
  },
  {
    icon: Zap,
    title: 'New CEL-Based Policies',
    color: 'deep-blue',
    content: `apiVersion: kyverno.io/v1alpha1
kind: ValidatingPolicy
metadata:
    name: require-labels-cel
spec:
   rules:
name: check-labels
match:
    any:
resources:
    kinds:
    - Pod
          assert:
             all: 	   
            -  expression: >
		has(object.metadata.labels.app) && 
		has(object.metadat.labels.version)
           message: “Pod must have ‘app’ and ‘version’ labels”`,
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
