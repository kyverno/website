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
  { label: 'Support', href: '/support' },
  { label: 'Blog', href: '/blog' },
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
    bg: 'bg-primary-50/20',
    text: 'text-primary-50',
  },
  {
    bg: 'bg-primary-50/20',
    text: 'text-primary-50',
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

export const supportLinks = [
  { href: 'https://github.com/giantswarm/security-pack', text: 'Giant Swarm' },
  { href: 'https://nirmata.com/', text: 'Nirmata' },
  { href: 'https://www.blakyaks.com/partners', text: 'BlakYaks' },
  {
    href: 'https://www.infracloud.io/kyverno-consulting-support/',
    text: 'InfraCloud',
  },
  {
    href: 'https://learn.kodekloud.com/courses?search=kyverno',
    text: 'Kodekloud',
  },
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
    { text: 'Policy as Code,', color: 'text-primary-100' },
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
    { text: 'Kyverno vs', color: 'text-primary-100' },
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

  paragraphText: 'Powering Policy-Based Security & Operations Worldwide',
}

export const codingThemes = {
  dark: themes.materialDark,
  light: themes.materialLight,
}

export const policyShowcaseHeadingContent = {
  headingText: [
    { text: 'Kyverno', color: 'text-primary-100' },
    { text: 'Policy Showcase', color: 'text-primary-100' },
  ],
  paragraphText: `Explore sample policies showcasing Kyverno's versatility across different use cases and policy types.`,
}

export const policyShowcaseTabs = [
  {
    id: 'validate-k8s',
    label: 'Validate Kubernetes Resources',
    learnMore: '/docs/policy-types/validating-policy',
    policy: `apiVersion: policies.kyverno.io/v1beta1
kind: ValidatingPolicy
metadata:
  name: require-labels
spec:
  matchConstraints:
    resourceRules:
      - apiGroups:   [""]
        apiVersions: ["v1"]
        operations:  ["CREATE", "UPDATE"]
        resources:   ["pods"]
  variables:
    - name: "labels"
      expression: "object.metadata.?labels.orValue([])"
  validations:
    -  message: "Pods must have 'app' and 'version' labels"
       expression: |
         has(variables.labels.app) && 
         has(variables.labels.version)
     `,
  },
  {
    id: 'validate-terraform',
    label: 'Validate Terraform Plans',
    learnMore: '/docs/policy-types/validating-policy',
    policy: `apiVersion: policies.kyverno.io/v1alpha1
kind: ValidatingPolicy
metadata:
  name: check-awsvpc-network-mode
spec:
  evaluation:
    mode: "JSON"
  matchConditions:
    - name: "isTerraformPlan"
      expression: |
        has(object.terraform_version) &&
          has(object.planned_values)
  variables:
    - name: ecsTasks
      expression: |
        object.?planned_values.root_module.resources.exists(r, 
          r.type == 'aws_ecs_task_definition').orValue([])
  validations:
    - message: "ECS tasks must use awsvpc network mode."
      expression: |
        variables.ecsTasks.all(task_def,
            has(task_def.values.network_mode) &&
            task_def.values.network_mode == 'awsvpc'
        )
    `,
  },
  {
    id: 'validate-dockerfile',
    label: 'Validate Dockerfiles',
    learnMore: '/docs/policy-types/validating-policy',
    policy: `apiVersion: policies.kyverno.io/v1alpha1
kind: ValidatingPolicy
metadata:
  name: check-label-maintainer
spec:
  evaluation:
    mode: JSON
  matchConditions:
    - name: isDockerfile
      expression: "has(object.Stages)"
  validations:
    - message: "MAINTAINER is deprecated, use LABELS instead"
      expression: |
        !object.Stages.exists(stage,
          has(stage.Commands) && 
            stage.Commands.exists(cmd, cmd.Name == 'MAINTAINER')
        )
    - message: "Use the LABELS instruction to set the MAINTAINER name"
      expression: |
        object.Stages.exists(stage,
          has(stage.Commands) && stage.Commands.exists(cmd,
            has(cmd.Labels) && cmd.Labels.exists(label,
              label.Key == 'maintainer' || 
              label.Key == 'owner' || 
              label.Key == 'author'
            )
          )
        )`,
  },
  {
    id: 'validate-http',
    label: 'Authorize HTTP Requests',
    learnMore: '/docs/policy-types/validating-policy',
    policy: `apiVersion: policies.kyverno.io/v1alpha1
kind: ValidatingPolicy
metadata:
  name: authorize-jwt
spec:
  evaluation:
    mode: "HTTP"
  failurePolicy: Fail 
  variables: 
  - name: authorizationlist
    expression: object.attributes.Header("authorization")
  - name: authorization
    expression: >
      size(variables.authorizationlist) == 1
        ? variables.authorizationlist[0].split(" ")
        : []
  - name: token
    expression: >
      size(variables.authorization) == 2 && 
        variables.authorization[0].lowerAscii() == "bearer"
          ? jwt.Decode(variables.authorization[1], "secret")
          : null
  validations: 
    # request not authenticated -> 401
  - expression: >
      variables.token == null || !variables.token.Valid
        ? http.Denied("Unauthorized").Response()
        : null
    # request authenticated but not admin role -> 403
  - expression: >
      variables.token.Claims.?role.orValue("") != "admin"
        ? http.Denied("Forbidden").Response()
        : null
    # request authenticated and admin role -> 200
  - expression: >
      http.Allowed().Response()`,
  },
  {
    id: 'validate-envoy',
    label: 'Authorize Envoy Requests',
    learnMore: '/docs/policy-types/validating-policy',
    policy: `apiVersion: policies.kyverno.io/v1alpha1
kind: ValidatingPolicy
metadata:
  name: check-envoy-request
spec:
  failurePolicy: Fail
  evaluation:
    mode: "Envoy"
  variables:
  - name: force_authorized
    expression: object.attributes.request.http.headers[?"x-force-authorized"].orValue("")
  - name: allowed
    expression: variables.force_authorized in ["enabled", "true"]
  validations:
  - expression: >
      !variables.allowed
        ? envoy.Denied(403).Response()
        : envoy.Allowed().Response()`,
  },
  {
    id: 'mutate-k8s',
    label: 'Mutate Kubernetes Resources',
    learnMore: '/docs/policy-types/mutating-policy',
    policy: `apiVersion: policies.kyverno.io/v1alpha1
kind: MutatingPolicy
metadata:
  name: add-safe-to-evict
spec:
  matchConstraints:
    resourceRules:
      - apiGroups: [""]
        apiVersions: ["v1"]
        operations: ["CREATE", "UPDATE"]
        resources: ["pods"]
  matchConditions:
    - name: has-emptydir-or-hostpath
      expression: |
        has(object.spec.volumes) && 
        object.spec.volumes.exists(v, has(v.emptyDir) || has(v.hostPath))
    - name: annotation-not-present
      expression: |
        !has(object.metadata.annotations) || 
        !object.metadata.annotations.exists(k, k == 'cluster-autoscaler.kubernetes.io/safe-to-evict')
  mutations:
    - patchType: ApplyConfiguration
      applyConfiguration:
        expression: |
          Object{
            metadata: Object.metadata{
              annotations: {
                "cluster-autoscaler.kubernetes.io/safe-to-evict": "true"
              }
            }
          }`,
  },
  {
    id: 'generate-k8s',
    label: 'Generate Kubernetes Resources',
    learnMore: '/docs/policy-types/generating-policy',
    policy: `apiVersion: policies.kyverno.io/v1alpha1
kind: GeneratingPolicy
metadata:
  name: add-networkpolicy
spec:
  evaluation:
    synchronize:
      enabled: true
  matchConstraints:
    resourceRules:
      - apiGroups: [""]
        apiVersions: ["v1"]
        operations: ["CREATE", "UPDATE"]
        resources: ["namespaces"]
  variables:
    - name: targetNamespace
      expression: "object.metadata.name"
    - name: downstream
      expression: >-
        [
          {
            "kind": dyn("NetworkPolicy"),
            "apiVersion": dyn("networking.k8s.io/v1"),
            "metadata": dyn({
              "name": "default-deny",
            }),
            "spec": dyn({
              "podSelector": dyn({}),
              "policyTypes": dyn(["Ingress", "Egress"])
            })
          }
        ]
  generate:
    - expression: generator.Apply(variables.targetNamespace, variables.downstream)`,
  },
  {
    id: 'cleanup-k8s',
    label: 'Cleanup Kubernetes Resources',
    learnMore: '/docs/policy-types/cleanup-policy',
    policy: `apiVersion: policies.kyverno.io/v1alpha1
kind: DeletingPolicy
metadata:
  name: cleanup-empty-replicasets
spec:
  matchConstraints:
    resourceRules:
      - apiGroups: ["apps"]
        apiVersions: ["v1"]
        resources: ["replicasets"]
    namespaceSelector:
      matchExpressions:
        - key: kubernetes.io/metadata.name
          operator: NotIn
          values:
            - kube-system
  conditions:
    - name: is-empty
      expression: "object.spec.replicas == 0"
  schedule: "* * * * *"`,
  },
  {
    id: 'validate-images',
    label: 'Validate Container Images',
    learnMore: '/docs/policy-types/image-validating-policy',
    policy: `apiVersion: policies.kyverno.io/v1alpha1
kind: ImageValidatingPolicy
metadata:
  name: verify-image-ivpol
spec:
  webhookConfiguration:
    timeoutSeconds: 30
  evaluation:
   background:
    enabled: true
  validationActions: [Deny]
  matchConstraints:
    resourceRules:
      - apiGroups: [""]
        apiVersions: ["v1"]
        operations: ["CREATE", "UPDATE"]
        resources: ["pods"]
  matchImageReferences:
        - glob : "docker.io/*"
  attestors:
  - name: cosign
    cosign:
     key:
      data: |
        -----BEGIN PUBLIC KEY-----
        MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAE6QsNef3SKYhJVYSVj+ZfbPwJd0pv
        DLYNHXITZkhIzfE+apcxDjCCkDPcJ3A3zvhPATYOIsCxYPch7Q2JdJLsDQ==
        -----END PUBLIC KEY-----
  validations:
    - message: image is not authorized
      expression: |
       images.containers.map(image, 
         verifyImageSignatures(image, [attestors.cosign])).all(e ,e > 0)`,
  },
]
