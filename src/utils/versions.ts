/**
 * Utility functions for version detection and URL handling
 */

export interface Version {
  label: string
  href: string
}

export interface VersionOption {
  label: string
  href: string
  isCurrent: boolean
}

/**
 * Detects the current version based on the hostname
 * @param versions - Array of version objects with {label, href}
 * @param hostname - Current hostname to match against
 * @returns The matched version object, or "main" version as default
 */
export function getCurrentVersion(
  versions: Version[],
  hostname?: string,
): Version {
  if (!hostname || !versions || versions.length === 0) {
    // Default to "main" version if no hostname or versions
    return (
      versions?.find((v) => v.href.includes('main.kyverno.io')) || versions?.[0]
    )
  }

  // Match version based on hostname from href
  for (const version of versions) {
    try {
      const versionUrl = new URL(version.href)
      const versionHostname = versionUrl.hostname

      // Exact match
      if (hostname === versionHostname) {
        return version
      }

      // Check if hostname contains the subdomain (e.g., release-1-15-0.kyverno.io)
      const versionSubdomain = versionHostname.split('.')[0]
      if (
        hostname.includes(versionSubdomain) &&
        versionSubdomain !== 'kyverno'
      ) {
        return version
      }
    } catch (e) {
      // If URL parsing fails, skip this version
      continue
    }
  }

  // Default to "main" version if no match found
  const mainVersion = versions.find((v) => v.href.includes('main.kyverno.io'))
  return mainVersion || versions[0]
}

/**
 * Creates version options with URLs that preserve the current path
 * @param versions - Array of version objects with {label, href}
 * @param currentPath - Current pathname to preserve
 * @param currentHostname - Current hostname for detection
 * @returns Array of version options with {label, href, isCurrent}
 */
export function createVersionOptions(
  versions: Version[],
  currentPath: string,
  currentHostname?: string,
): VersionOption[] {
  const currentVersion = getCurrentVersion(versions, currentHostname)

  return versions.map((version) => {
    try {
      const versionUrl = new URL(version.href)
      const targetUrl = new URL(currentPath, versionUrl.origin)
      return {
        label: version.label,
        href: targetUrl.toString(),
        isCurrent: version.href === currentVersion.href,
      }
    } catch (e) {
      // If URL parsing fails, return the base href
      return {
        label: version.label,
        href: version.href,
        isCurrent: version.href === currentVersion.href,
      }
    }
  })
}
