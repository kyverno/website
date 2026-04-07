export interface VersionLink {
  label: string
  href: string
}

export interface CompatibilityMatrixEntry {
  kyverno: string
  minKubernetes: string
  maxKubernetes: string
}

// Single source of truth for release/version updates across the site.
export const latestStableVersion = 'v1.18'

export const documentationVersions: VersionLink[] = [
  { label: 'v1.18.0', href: 'https://kyverno.io' },
  { label: 'v1.17.0', href: 'https://release-1-17-0.kyverno.io' },
  { label: 'v1.16.0', href: 'https://release-1-16-0.kyverno.io' },
  { label: 'main', href: 'https://main.kyverno.io' },
]

// Keep compatibility data centralized so docs/components can import from here.
export const compatibilityMatrix: CompatibilityMatrixEntry[] = [
  { kyverno: '1.18.x', minKubernetes: '1.32', maxKubernetes: '1.35' },
  { kyverno: '1.17.x', minKubernetes: '1.32', maxKubernetes: '1.35' },
  { kyverno: '1.16.x', minKubernetes: '1.31', maxKubernetes: '1.34' },
]
