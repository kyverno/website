import { Shield, Code, Zap, Globe, Box, ChartColumn, Terminal } from "lucide-react";
import { TestTube, GitBranch, Lock, CircleCheckBig, Github, Book} from "lucide-react";

export const versions = [
  {label: "v1alpha1", href: "#"},
  {label: "v1.15", href: "#"},
  {label: "v1.14", href: "#"}
]

export const navItemsOnsite = [
  { label: "Why Kyverno", targetId: "whykyverno" },
  { label: "Features", targetId: "features" },
  { label: "Policies", targetId: "policies" }
];

export const navItemsExternal = [
  { label: "Docs", href: "/guides/example" },
  { label: "Blog", href: "#"},
  { label: "Community", href: "https://kyverno.io/community/" } 
];


export const heroTags = [
  {
    title: "Kubernates Native",
    icon: Shield
  },
  {
    title: "Flexible",
    icon: Code
  },
  {
    title: "Enhanced Performance",
    icon: Zap
  }
];

export const whyKyvernoCards = [
  {
    icon: Code,
    title: "Kubernates Native",
    desc1: "Uses YAML & CEL, languages familiar to K8s users",
    desc2: "Write & apply policies as CRDs", 
    color: "blue"
  },
  {
    icon: Zap,
    title: "Easy to Adopt",
    desc1: "Quick and easy to get started with",
    desc2: "Designed for K8s",
    color: "orange"
  },
  {
    icon: Shield,
    title: "Flexible & Powerful",
    desc1: "Wide range of use cases",
    desc2: "Fits naturally into existing workflows",
    color: "green"
  },
  {
    icon: Globe,
    title: "Trusted & Proven",
    desc1: "CNCF incubating project",
    desc2: "Widely adopted & used in Production by orgs of all sizes",
    color: "purple"
  }

];

export const kyvernoVsOthers = [
  {
    feature: "Policy Language",
    kyverno: "Supports YAML & CEL-based policies (languages familiar to K8s users)",
    opa: "Rego (new DSL to learn)"
  },
  {
    feature: "Ease of Adoption",
    kyverno: "Intuitive, no extra learning curve",
    opa: "Steeper learning curve due to Rego"
  },
  {
    feature: "Policy Types",
    kyverno: "Validate, Mutate, Generate, Verify, Delete",
    opa: "Validate"
  },
];

export const features = [
  {
    icon: Box,
    title: "Kubernetes Native",
    details: "Extends and completes Kubernetes policy types for comprehensive platform engineering capabilities.",
    color: "orange"
  },
  {
    icon: Globe,
    title: "Works Everywhere",
    details: "Executes Kubernetes-style policies on any JSON payload using CLI or SDK for universal compatibility.",    
    color: "yellow"
  },
  {
    icon: ChartColumn,
    title: "Integrated Reporting",
    details: "OpenReports compatible producers, routers, and dashboards for comprehensive policy compliance visibility.",
    color: "green"
  },
  {
    icon: Shield,
    title: "Exception Management",
    details: "Timebound and fine-grained exception management decoupled from policies for flexible governance.",
    color: "cyan"
  },
  {
    icon: Terminal,
    title: "Shift-Left Integration",
    details: "CLI for seamless integrations into CI/CD and Infrastructure as Code (Terraform, etc.) pipelines.",
    color: "purple"
  },
  {
    icon: TestTube,
    title: "Policy Testing",
    details: "Comprehensive tooling for declarative unit tests and end-to-end behavioral policy validation.",
    color: "blue"
  },
  {
    icon: Zap,
    title: "CEL Performance",
    details: "Enhanced performance with Common Expression Language for faster policy, evaluation and execution.",
    color: "amber"
  },
  {
    icon: GitBranch,
    title: "Version Control",
    details: "Full version control integration with GitOps workflows for policy lifecycle management.",
    color: "indigo"
  },
  {
    icon: Lock,
    title: "Security Policies",
    details: "Comprehensive security policy templates and best practices for zero-trust architectures.",
    color: "lime"
  }
];

export const celPolicies = [
 {
  icon: CircleCheckBig,
  title: "ValidatingPolicy",
  description: "For validation of Kubernetes resources or arbitrary JSON payloads using CEL expressions.",
  color: "purple" 
},
 {
  icon: CircleCheckBig,
  title: "ImageValidatingPolicy",
  description: "Dedicated solely to verifying container images: their signatures, attestations, SBOMs, etc.",
  color: "green" 
},
 {
  icon: CircleCheckBig,
  title: "MutatingPolicy",
  description: "For mutating or modifying resources using CEL first, including patches/ApplyConfiguration.",
   color: "red"  
},
 {
  icon: CircleCheckBig,
  title: "GeneratingPolicy",
  description: "For creating or cloning resources in response to triggers (e.g. on creation of certain resources), but using CEL for more flexible logic.",
  color: "orange" 
},
 {
  icon: CircleCheckBig,
  title: "DeletingPolicy",
  description: "For controlled cleanup of resources, scheduled deletions or deletions when certain conditions in the cluster are met.",
   color: "blue" 
}
];

export const yamlCEL= [
  { 
    icon: CircleCheckBig,
    title: "Traditional YAML Policies",
    color: "light-blue",
    content: 
      `apiVersion: kyverno.io/v1
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
            version:”?*”`
     
  },
  { 
    icon: Zap,
    title: "New CEL-Based Policies",
    color: "deep-blue",
    content: 
      `apiVersion: kyverno.io/v1alpha1
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
           message: “Pod must have ‘app’ and ‘version’ labels”`
     
  }
];

export const partners = [
  { image: "assets/product-icons/adidas-icon.svg", name: "Adidas" },
  { image: "assets/product-icons/bloomberg-icon.svg", name: "Bloomberg" },
  { image: "assets/product-icons/linkedin-icon.svg", name: "Linkedin" },
  { image: "assets/product-icons/razorpay-icon.svg", name: "Razorpay" },
  { image: "assets/product-icons/robinhood-icon.svg", name: "Robinhood" },
  { image: "assets/product-icons/spotify-icon.svg", name: "Spotify" },
  { image: "assets/product-icons/telecom-icon.svg", name: "Telecom" },
  { image: "assets/product-icons/us-dod-icon.svg", name: "US-DOD" },
  { image: "assets/product-icons/vodafone-icon.svg", name: "Vodafone" },
  { image: "assets/product-icons/wayfair-icon.svg", name: "Wayfair" },
  { image: "assets/product-icons/yahoo-icon.svg", name: "Yahoo" },
];

export const productsLinks = [
  { href: "#", text: "Features" },
  { href: "#", text: "CEL Policies" },
  { href: "#", text: "Migration Guide" },
  { href: "#", text: "Playground" },
];

export const ResourcesLinks = [
  { href: "#", text: "Documentation" },
  { href: "#", text: "API Reference" },
  { href: "#", text: "Policy Samples" },
  { href: "#", text: "Blog" }
];

export const communityLinks = [
  { href: "#", text: "Github" },
  { href: "#", text: "Slack" },
  { href: "#", text: "Contributing" }
];

export const policies = [
  { href: "#", text: "Privacy Policy" },
  { href: "#", text: "Terms of service" },
  { href: "#", text: "Security" }
];