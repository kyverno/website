import { Check, Copy, Plus, Square } from 'lucide-react'
import {
  formatCategoryLabel,
  formatSeverityLabel,
  getCategoryColor,
  getSeverityColor,
} from './utils'

import { useState } from 'react'

export const PolicyCard = ({ policy }) => {
  const category = policy.data.category || 'validate'
  const severity = policy.data.severity || 'N/A'
  const description = policy.data.description || null
  const isNew = policy.data.isNew || false
  const [copyState, setCopyState] = useState('idle') // 'idle', 'success', 'error'

  // Get YAML content from prop (extracted in Astro)
  const yamlContent = policy.yamlContent || null

  const handleCopyYAML = async (e) => {
    e.preventDefault()
    e.stopPropagation()

    try {
      if (!yamlContent || !yamlContent.trim()) {
        throw new Error('YAML content not available')
      }

      await navigator.clipboard.writeText(yamlContent.trim())
      setCopyState('success')
      setTimeout(() => setCopyState('idle'), 2000)
    } catch (error) {
      console.error('Failed to copy YAML:', error)
      setCopyState('error')
      setTimeout(() => setCopyState('idle'), 2000)
    }
  }

  return (
    <div
      onClick={() => {
        window.location.href = `/policies/${policy.id}/`
      }}
      className="policy-card group bg-dark-50 border border-stroke rounded-2xl p-6 cursor-pointer relative overflow-hidden flex flex-col min-h-[320px] max-h-[450px] transition-all duration-300 hover:border-primary-100/50 hover:-translate-y-1 hover:shadow-[0_20px_40px_rgba(55,131,196,0.15)] hover:before:scale-x-100 before:content-[''] before:absolute before:top-0 before:left-0 before:right-0 before:h-[4px] before:bg-gradient-to-r before:from-primary-100 before:via-accent-100 before:to-primary-100 before:scale-x-0 before:transition-transform before:duration-300"
    >
      <div className="flex-1 flex flex-col">
        <div className="flex gap-2 flex-wrap mb-4">
          <span
            className={`px-3 py-1.5 rounded-lg text-xs font-bold uppercase tracking-wider border backdrop-blur-sm ${getCategoryColor(category)} shadow-sm`}
          >
            {formatCategoryLabel(category)}
          </span>
          <span
            className={`px-3 py-1.5 rounded-lg text-xs font-bold uppercase tracking-wider border backdrop-blur-sm ${getSeverityColor(severity)} shadow-sm`}
          >
            {formatSeverityLabel(severity)}
          </span>
          {isNew && (
            <span className="px-3 py-1.5 rounded-lg text-xs font-bold uppercase tracking-wider border backdrop-blur-sm bg-purple-500/15 text-purple-400 border-purple-500/30 shadow-sm">
              New
            </span>
          )}
        </div>
        <h3 className="text-xl font-bold mb-3 text-white leading-tight group-hover:text-primary-100 transition-colors">
          {policy.data.title}
        </h3>
        {description && (
          <p className="text-white/80 text-sm mb-4 leading-relaxed line-clamp-3">
            {description}
          </p>
        )}
        {policy.data.tags && policy.data.tags.length > 0 && (
          <div className="flex flex-wrap gap-2 mb-4">
            {policy.data.tags.map((tag) => (
              <span
                key={tag}
                className="tag px-2.5 py-1 bg-stroke/60 backdrop-blur-sm rounded-lg text-xs text-white/70 border border-stroke/50"
              >
                #{tag}
              </span>
            ))}
          </div>
        )}
      </div>
      <div className="flex items-center gap-4 pt-4 border-t border-stroke/50 text-sm text-white/50 mb-4">
        {policy.data.subjects && policy.data.subjects.length > 0 && (
          <div className="flex items-center gap-2 min-w-0 flex-1">
            <Square size={16} className="text-primary-100/60 flex-shrink-0" />
            <span className="font-medium truncate">
              {policy.data.subjects.slice(0, 3).join(', ')}
            </span>
            {policy.data.subjects.length > 3 && (
              <span className="text-white/30 flex-shrink-0">...</span>
            )}
          </div>
        )}
        {policy.data.version && (
          <div className="flex items-center gap-2 flex-shrink-0">
            <Plus size={16} className="text-primary-100/60" />
            <span className="font-medium">v{policy.data.version}+</span>
          </div>
        )}
      </div>
      <div className="flex gap-2 mt-auto pt-4">
        <a
          href={`/policies/${policy.id}/`}
          onClick={(e) => e.stopPropagation()}
          className="flex-1 py-2.5 px-4 bg-stroke border border-stroke/80 rounded-lg text-white text-sm font-medium cursor-pointer transition-all flex items-center justify-center gap-2 hover:bg-primary-100/20 hover:border-primary-100/50 hover:text-primary-100"
        >
          <Plus size={16} />
          View Details
        </a>
        <button
          onClick={handleCopyYAML}
          className={`flex-1 py-2.5 px-4 border rounded-lg text-white text-sm font-medium cursor-pointer transition-all flex items-center justify-center gap-2 ${
            copyState === 'success'
              ? 'bg-green-500/20 border-green-500/50 hover:bg-green-500/30'
              : copyState === 'error'
                ? 'bg-red-500/20 border-red-500/50 hover:bg-red-500/30'
                : 'bg-stroke border-stroke/80 hover:bg-primary-100/20 hover:border-primary-100/50 hover:text-primary-100'
          }`}
        >
          {copyState === 'success' ? (
            <>
              <Check size={16} />
              Copied!
            </>
          ) : (
            <>
              <Copy size={16} />
              Copy YAML
            </>
          )}
        </button>
      </div>
    </div>
  )
}
