import React, { useEffect, useRef, useState } from 'react'

import { ChevronDown } from 'lucide-react'
import { documentationVersions } from '../constants/index.js'

const getCurrentVersion = (versions) => {
  if (typeof window === 'undefined') {
    // Find "main" version or default to first
    return (
      versions.find((v) => v.href.includes('main.kyverno.io')) || versions[0]
    )
  }

  const hostname = window.location.hostname

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

export const VersionDropdown = ({ className = '' }) => {
  // Initialize with "main" version as default
  const mainVersion =
    documentationVersions.find((v) => v.href.includes('main.kyverno.io')) ||
    documentationVersions[0]
  const [isOpen, setIsOpen] = useState(false)
  const [currentVersion, setCurrentVersion] = useState(mainVersion)
  const dropdownRef = useRef(null)

  useEffect(() => {
    // Detect current version based on URL
    setCurrentVersion(getCurrentVersion(documentationVersions))
  }, [])

  useEffect(() => {
    const handleClickOutside = (event) => {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target)) {
        setIsOpen(false)
      }
    }

    if (isOpen) {
      document.addEventListener('mousedown', handleClickOutside)
    }

    return () => {
      document.removeEventListener('mousedown', handleClickOutside)
    }
  }, [isOpen])

  return (
    <div className={`relative ${className}`} ref={dropdownRef}>
      <button
        className="flex items-center space-x-1 text-white hover:text-accent-100 transition-colors px-3 py-2 rounded-md hover:bg-dark-50 focus:outline-none focus:ring-2 focus:ring-primary-100 focus:ring-offset-2 focus:ring-offset-dark-100"
        onClick={() => setIsOpen(!isOpen)}
        aria-haspopup="true"
        aria-expanded={isOpen}
      >
        <span>{currentVersion.label}</span>
        <ChevronDown
          className={`w-4 h-4 transition-transform ${isOpen ? 'rotate-180' : ''}`}
        />
      </button>
      {isOpen && (
        <div className="absolute right-0 mt-2 w-48 bg-dark-50 border border-stroke rounded-md shadow-lg z-50">
          <div className="py-1">
            {documentationVersions.map((version, index) => {
              // Preserve current path when switching versions
              const getVersionUrl = () => {
                if (typeof window === 'undefined') return version.href
                const currentPath = window.location.pathname
                const versionUrl = new URL(version.href)
                const targetUrl = new URL(currentPath, versionUrl.origin)
                return targetUrl.toString()
              }

              const isCurrentVersion = currentVersion.href === version.href

              return (
                <a
                  key={index}
                  href={getVersionUrl()}
                  className={`block px-4 py-2 text-sm transition-colors ${
                    isCurrentVersion
                      ? 'bg-primary-100/30 text-accent-100 font-medium'
                      : 'text-white hover:bg-primary-100/20 hover:text-accent-100'
                  }`}
                >
                  {version.label}
                </a>
              )
            })}
          </div>
        </div>
      )}
    </div>
  )
}
