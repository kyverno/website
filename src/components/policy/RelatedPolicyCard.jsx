import {
  formatCategoryLabel,
  formatSeverityLabel,
  getCategoryColor,
  getSeverityColor,
} from './utils'

import { FileText } from 'lucide-react'

export const RelatedPolicyCard = ({ policy }) => {
  const category = policy.data.category || 'validate'
  const severity = policy.data.severity || 'medium'
  const description = policy.data.description || null

  return (
    <a
      href={`/policies/${policy.id}/`}
      className="bg-gray-900 border border-gray-800 rounded-xl p-5 hover:border-gray-700 hover:bg-gray-900/50 transition-all group cursor-pointer h-full flex flex-col"
    >
      <div className="flex flex-col space-y-3 flex-1">
        {/* Badges */}
        <div className="flex gap-2 flex-wrap">
          <span
            className={`px-2 py-1 rounded-md text-xs font-bold uppercase tracking-wider border ${getCategoryColor(category)}`}
          >
            {formatCategoryLabel(category)}
          </span>
          <span
            className={`px-2 py-1 rounded-md text-xs font-bold uppercase tracking-wider border ${getSeverityColor(severity)}`}
          >
            {formatSeverityLabel(severity)}
          </span>
        </div>

        {/* Title */}
        <h3 className="text-base font-semibold text-white leading-tight line-clamp-2 group-hover:text-primary-100 transition-colors min-h-[3rem]">
          {policy.data.title}
        </h3>

        {/* Description */}
        {description && (
          <p className="text-gray-400 text-sm leading-relaxed line-clamp-1">
            {description}
          </p>
        )}

        {/* Resource Type */}
        {policy.data.subjects && policy.data.subjects.length > 0 && (
          <div className="flex items-center gap-2 text-sm text-gray-300 mt-auto">
            <FileText size={14} className="text-gray-300 flex-shrink-0" />
            <span className="font-medium truncate">
              {policy.data.subjects.slice(0, 1).join(', ')}
            </span>
          </div>
        )}
      </div>
    </a>
  )
}
