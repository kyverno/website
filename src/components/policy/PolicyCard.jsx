export const PolicyCard = ({ policy, baseUrl = '/policies' }) => {
  if (!policy) return null
  const categoryLabels = {
    verifyImages: 'Verify Images',
    validate: 'Validate',
    mutate: 'Mutate',
    generate: 'Generate',
    cleanup: 'Cleanup',
  }

  const categoryColors = {
    verifyImages: 'bg-blue-400/10 text-blue-400 border-blue-400/20',
    validate: 'bg-blue-400/10 text-blue-400 border-blue-400/20',
    mutate: 'bg-blue-400/10 text-blue-400 border-blue-400/20',
    generate: 'bg-blue-400/10 text-blue-400 border-blue-400/20',
    cleanup: 'bg-blue-400/10 text-blue-400 border-blue-400/20',
  }

  const severityColors = {
    high: 'bg-red-500/10 text-red-400 border-red-500/20',
    medium: 'bg-yellow-500/10 text-yellow-400 border-yellow-500/20',
    low: 'bg-green-500/10 text-green-400 border-green-500/20',
  }

  const severityLabels = {
    high: 'High',
    medium: 'Medium',
    low: 'Low',
  }

  return (
    <div className="policy-card bg-dark-50 border border-stroke rounded-xl p-6 transition-all duration-300 cursor-pointer relative overflow-hidden hover:border-primary-100 hover:-translate-y-0.5 hover:shadow-[0_10px_30px_rgba(55,131,196,0.1)] before:content-[''] before:absolute before:top-0 before:left-0 before:right-0 before:h-[3px] before:bg-gradient-to-r before:from-primary-100 before:to-accent-100 before:scale-x-0 before:transition-transform before:duration-300 hover:before:scale-x-100">
      <div className="flex justify-between items-start mb-4">
        <div className="w-full">
          <div className="flex gap-2 flex-wrap mb-3">
            <span
              className={`px-3 py-1 rounded-md text-xs font-semibold uppercase tracking-wide border ${categoryColors[policy.data.category] || categoryColors.validate}`}
            >
              {categoryLabels[policy.data.category] || policy.data.category}
            </span>
            <span
              className={`px-3 py-1 rounded-md text-xs font-semibold uppercase tracking-wide border ${severityColors[policy.data.severity] || severityColors.medium}`}
            >
              {severityLabels[policy.data.severity] || policy.data.severity}
            </span>
          </div>
          <h3 className="text-lg font-semibold mb-2 text-white">
            <a
              href={`${baseUrl}/${policy.id}/`}
              className="hover:text-primary-100 transition-colors"
              data-astro-prefetch
            >
              {policy.data.title}
            </a>
          </h3>
        </div>
      </div>
      {policy.data.tags && policy.data.tags.length > 0 && (
        <div className="flex flex-wrap gap-2 mt-3 mb-4">
          {policy.data.tags.map((tag) => (
            <span
              key={tag}
              className="tag px-2.5 py-1 bg-stroke rounded text-xs text-white/60 transition-all hover:bg-stroke/80 hover:text-white/90"
            >
              #{tag}
            </span>
          ))}
        </div>
      )}
      <div className="flex flex-wrap gap-4 pt-4 border-t border-stroke text-[0.813rem] text-white/60">
        {policy.data.subjects && policy.data.subjects.length > 0 && (
          <div className="flex items-center gap-1.5">
            <svg
              width="14"
              height="14"
              fill="none"
              stroke="currentColor"
              strokeWidth="2"
              className="text-white/40"
            >
              <rect x="2" y="2" width="10" height="10" rx="1" />
            </svg>
            {policy.data.subjects.slice(0, 3).join(', ')}
            {policy.data.subjects.length > 3 && '...'}
          </div>
        )}
        {policy.data.version && (
          <div className="flex items-center gap-1.5">
            <svg
              width="14"
              height="14"
              fill="none"
              stroke="currentColor"
              strokeWidth="2"
              className="text-white/40"
            >
              <path d="M7 2v12M2 7h12" />
            </svg>
            v{policy.data.version}+
          </div>
        )}
      </div>
      <div className="flex gap-2 mt-4">
        <a
          href={`${baseUrl}/${policy.id}/`}
          className="action-btn flex-1 py-2.5 bg-stroke border border-stroke/80 rounded-md text-white text-[0.813rem] cursor-pointer transition-all flex items-center justify-center gap-1.5 hover:bg-stroke/80 hover:border-primary-100"
          data-astro-prefetch
        >
          <svg
            width="16"
            height="16"
            fill="none"
            stroke="currentColor"
            strokeWidth="2"
          >
            <path d="M8 2v12M2 8h12" />
          </svg>
          View Details
        </a>
      </div>
    </div>
  )
}
