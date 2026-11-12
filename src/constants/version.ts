export interface VersionLink {
  label: string
  href: string
}

// Single source of truth for release/version updates across the site.
export const latestStableVersion = 'v1.20.0'

export const documentationVersions: VersionLink[] = [
  { label: 'v1.20.0', href: 'https://kyverno.io' },
  { label: 'v1.19.0', href: 'https://release-1-19-0.kyverno.io' },
  { label: 'v1.18.0', href: 'https://release-1-18-0.kyverno.io' },
  { label: 'v1.17.0', href: 'https://release-1-17-0.kyverno.io' },
  { label: 'main', href: 'https://main.kyverno.io' },
]
