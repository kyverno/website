import * as lzstring from 'lz-string'

import { Check, Copy, ExternalLink, Play, X } from 'lucide-react'

import { useState } from 'react'

export const PolicyActionButtons = ({ yamlUrl, yamlContent }) => {
  const [copyState, setCopyState] = useState('idle') // 'idle', 'success', 'error'

  /**
   * Extracts YAML content from props or DOM
   */
  const getYamlContent = () => {
    // Prefer the yamlContent prop (passed from Astro)
    if (yamlContent) {
      return yamlContent.trim()
    }

    // Fallback: try to find it in the DOM
    if (typeof document !== 'undefined') {
      const yamlDataEl = document.getElementById('yaml-content-data')
      if (yamlDataEl) {
        try {
          const content = JSON.parse(
            yamlDataEl.getAttribute('data-yaml') || '""',
          )
          if (content) {
            return content.trim()
          }
        } catch (e) {
          console.warn('Failed to parse YAML from data attribute:', e)
        }
      }

      // Last resort: find YAML code block in rendered content
      const codeBlock = document.querySelector(
        'pre code.language-yaml, pre code[class*="yaml"]',
      )
      if (codeBlock) {
        return codeBlock.textContent?.trim() || null
      }
    }

    return null
  }

  const handleCopy = async () => {
    try {
      const content = getYamlContent()

      if (!content) {
        throw new Error('YAML content not found')
      }

      await navigator.clipboard.writeText(content)
      setCopyState('success')
      setTimeout(() => setCopyState('idle'), 2000)
    } catch (error) {
      console.error('Failed to copy YAML:', error)
      setCopyState('error')
      setTimeout(() => setCopyState('idle'), 2000)
    }
  }

  const handleOpenInPlayground = () => {
    try {
      const content = getYamlContent()

      if (!content) {
        throw new Error('YAML content not found')
      }

      // Verify we have valid YAML content
      if (!content.includes('apiVersion:') || !content.includes('kind:')) {
        console.warn('YAML content might not be a valid policy')
        console.warn('Content preview:', content.substring(0, 200))
      }

      // Generate playground share URL using the same method as the playground
      // Based on https://github.com/kyverno/playground/blob/b7997c02bca2830e99c11d4f82c441198357a895/frontend/src/functions/share.ts
      const dataToCompress = {
        policy: content,
        resource: '',
        oldResource: '',
      }

      // Use compressToBase64 as the playground does
      const base64Compressed = lzstring.compressToBase64(
        JSON.stringify(dataToCompress),
      )

      // URL-encode the base64 string for safe URL usage
      // The playground uses #/?content= format (hash fragment with query parameter)
      const compressed = encodeURIComponent(base64Compressed)

      const playgroundUrl = `https://playground.kyverno.io/#/?content=${compressed}`

      window.open(playgroundUrl, '_blank', 'noopener,noreferrer')
    } catch (error) {
      console.error('Failed to open in playground:', error)
    }
  }

  return (
    <div className="flex flex-wrap gap-3">
      {yamlUrl && (
        <a
          href={yamlUrl}
          target="_blank"
          rel="noopener noreferrer"
          className="inline-flex items-center gap-2 px-6 py-3 bg-primary-100 hover:bg-primary-100/90 border border-primary-100 rounded-lg text-white font-medium transition-all"
        >
          <ExternalLink size={18} />
          View on GitHub
        </a>
      )}
      <button
        onClick={handleCopy}
        className={`inline-flex items-center gap-2 px-6 py-3 border border-gray-700 hover:border-gray-600 rounded-lg text-white font-medium transition-all bg-gray-800 hover:bg-gray-750 ${
          copyState === 'success'
            ? 'bg-green-500/20 border-green-500/50'
            : copyState === 'error'
              ? 'bg-red-500/20 border-red-500/50'
              : ''
        }`}
      >
        {copyState === 'success' ? (
          <>
            <Check size={18} />
            Copied!
          </>
        ) : copyState === 'error' ? (
          <>
            <X size={18} />
            Error
          </>
        ) : (
          <>
            <Copy size={18} />
            Copy YAML
          </>
        )}
      </button>
      <button
        onClick={handleOpenInPlayground}
        className="inline-flex items-center gap-2 px-6 py-3 border border-gray-700 hover:border-gray-600 rounded-lg text-white font-medium transition-all bg-gray-800 hover:bg-gray-750"
      >
        <Play size={18} />
        Open in Playground
      </button>
    </div>
  )
}
