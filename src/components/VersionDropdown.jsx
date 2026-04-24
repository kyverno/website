import React, { useEffect, useRef, useState } from 'react'
import { createVersionOptions, getCurrentVersion } from '../utils/versions'

import { ChevronDown } from 'lucide-react'
import { documentationVersions } from '../constants/index.js'

export const VersionDropdown = ({ className = '' }) => {
  // Initialize with "main" version as default
  const mainVersion =
    documentationVersions.find((v) => v.href.includes('main.kyverno.io')) ||
    documentationVersions[0]
  const [isOpen, setIsOpen] = useState(false)
  const [currentVersion, setCurrentVersion] = useState(mainVersion)
  const dropdownRef = useRef(null)

  useEffect(() => {
    // Detect current version based on URL (client-side only)
    if (typeof window !== 'undefined') {
      const hostname = window.location.hostname
      setCurrentVersion(getCurrentVersion(documentationVersions, hostname))
    }
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
        className="flex items-center space-x-1 text-theme-primary hover:text-accent-100 transition-colors px-3 py-2 rounded-md hover:bg-dark-50 focus:outline-none focus:ring-2 focus:ring-primary-100 focus:ring-offset-2 focus:ring-offset-dark-100"
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
            {(() => {
              // Generate version options with preserved paths (client-side only)
              if (typeof window === 'undefined') {
                return documentationVersions.map((version, index) => (
                  <a
                    key={index}
                    href={version.href}
                    className="block px-4 py-2 text-sm text-theme-primary hover:bg-primary-100/20 hover:text-accent-100 transition-colors"
                  >
                    {version.label}
                  </a>
                ))
              }

              const hostname = window.location.hostname
              const currentPath = window.location.pathname
              const versionOptions = createVersionOptions(
                documentationVersions,
                currentPath,
                hostname,
              )

              return versionOptions.map((version, index) => (
                <a
                  key={index}
                  href={version.href}
                  className={`block px-4 py-2 text-sm transition-colors ${
                    version.isCurrent
                      ? 'bg-primary-100/30 text-accent-100 font-medium'
                      : 'text-theme-primary hover:bg-primary-100/20 hover:text-accent-100'
                  }`}
                >
                  {version.label}
                </a>
              ))
            })()}
          </div>
        </div>
      )}
    </div>
  )
}
