import { Check, Copy, Eye, FileText } from 'lucide-react'
import {
  formatCategoryLabel,
  formatSeverityLabel,
  getCategoryColor,
  getSeverityColor,
  isPolicyNew,
} from './utils'

import { useState } from 'react'

export const PolicyCard = ({ policy }) => {
  const category = policy.data.category || 'validate'
  const severity = policy.data.severity || 'N/A'
  const description = policy.data.description || null
  const isNew = isPolicyNew(policy.data.createdAt)
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
    <div className="policy-card group bg-dark-50 border border-stroke rounded-2xl p-6 relative overflow-hidden flex flex-col h-full min-h-[320px] max-h-[450px] transition-all duration-300 hover:border-primary-100/50 hover:bg-dark-50/80 hover:-translate-y-1">
      <div className="flex flex-col h-full">
        {/* Top content (badges, title, description) */}
        <div>
          {/* Badges */}
          <div className="flex gap-2 flex-wrap mb-4">
            <span
              className={`px-3 py-1.5 rounded-lg text-xs font-bold uppercase tracking-wider border ${getCategoryColor(category)}`}
            >
              {formatCategoryLabel(category)}
            </span>
            <span
              className={`px-3 py-1.5 rounded-lg text-xs font-bold uppercase tracking-wider border ${getSeverityColor(severity)}`}
            >
              {formatSeverityLabel(severity)}
            </span>
            {isNew && (
              <span className="px-3 py-1.5 rounded-lg text-xs font-bold uppercase tracking-wider border text-purple-400 bg-purple-950/50 border-purple-900/50">
                New
              </span>
            )}
          </div>

          {/* Title */}
          <a
            href={`/policies/${policy.id}/`}
            onClick={(e) => e.stopPropagation()}
            className="text-xl font-semibold mb-2 text-theme-primary leading-tight group-hover:text-primary-100 transition-colors block hover:underline cursor-pointer"
          >
            {policy.data.title}
          </a>

          {/* Description */}
          {description && (
            <p className="text-theme-secondary text-sm mb-4 leading-relaxed line-clamp-2">
              {description}
            </p>
          )}
        </div>

        {/* Spacer - pushes bottom content down */}
        <div className="flex-1" />

        {/* Bottom content (tags, resource, actions) - always aligned */}
        <div>
          {/* Tags */}
          {policy.data.tags && policy.data.tags.length > 0 && (
            <div className="flex flex-wrap gap-2 mb-4">
              {policy.data.tags.map((tag) => (
                <span
                  key={tag}
                  className="px-2 py-0.5 text-xs text-theme-tertiary bg-stroke/50 rounded"
                >
                  #{tag}
                </span>
              ))}
            </div>
          )}

          {/* Resource and Version */}
          <div className="flex items-center gap-2 text-sm text-theme-tertiary mb-4">
            {policy.data.subjects && policy.data.subjects.length > 0 && (
              <>
                <FileText
                  size={16}
                  className="text-theme-tertiary flex-shrink-0"
                />
                <span className="font-medium">
                  {policy.data.subjects.slice(0, 1).join(', ')}
                </span>
              </>
            )}
            {policy.data.version && (
              <>
                <span className="text-theme-tertiary">•</span>
                <span className="font-medium">v{policy.data.version}+</span>
              </>
            )}
          </div>

          {/* Action Buttons */}
          <div className="flex gap-2 pt-4">
            <a
              href={`/policies/${policy.id}/`}
              onClick={(e) => e.stopPropagation()}
              className="flex-1 py-2.5 px-4 bg-primary-100 hover:bg-primary-100/90 rounded-lg text-white text-sm font-medium cursor-pointer transition-all flex items-center justify-center gap-2"
            >
              <Eye size={16} />
              View Details
            </a>
            <button
              onClick={handleCopyYAML}
              className={`p-2.5 border border-stroke hover:border-primary-100/50 rounded-lg text-theme-primary text-sm font-medium cursor-pointer transition-all flex items-center justify-center bg-dark-50 hover:bg-dark-50/80 ${
                copyState === 'success'
                  ? 'bg-green-500/20 border-green-500/50 hover:bg-green-500/30'
                  : copyState === 'error'
                    ? 'bg-red-500/20 border-red-500/50 hover:bg-red-500/30'
                    : ''
              }`}
            >
              {copyState === 'success' ? (
                <Check size={16} />
              ) : (
                <Copy size={16} />
              )}
            </button>
          </div>
        </div>
      </div>
    </div>
  )
}
