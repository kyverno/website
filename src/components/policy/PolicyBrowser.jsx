import { useMemo, useState } from 'react'

export const PolicyBrowser = ({ policies }) => {
  const [searchQuery, setSearchQuery] = useState('')
  const [selectedCategories, setSelectedCategories] = useState([])
  const [selectedSeverities, setSelectedSeverities] = useState([])
  const [selectedResources, setSelectedResources] = useState([])
  const [activeCategoryButton, setActiveCategoryButton] = useState('all')

  // Calculate filter counts
  const categoryCounts = useMemo(() => {
    const counts = {}
    policies.forEach((policy) => {
      const cat = policy.data.category
      counts[cat] = (counts[cat] || 0) + 1
    })
    return counts
  }, [policies])

  const severityCounts = useMemo(() => {
    const counts = {}
    policies.forEach((policy) => {
      const sev = policy.data.severity
      counts[sev] = (counts[sev] || 0) + 1
    })
    return counts
  }, [policies])

  const resourceCounts = useMemo(() => {
    const counts = {}
    policies.forEach((policy) => {
      if (policy.data.subjects) {
        policy.data.subjects.forEach((resource) => {
          counts[resource] = (counts[resource] || 0) + 1
        })
      }
    })
    return counts
  }, [policies])

  const topResources = useMemo(() => {
    return Object.entries(resourceCounts)
      .sort(([, a], [, b]) => b - a)
      .slice(0, 10)
  }, [resourceCounts])

  const filteredPolicies = useMemo(() => {
    return policies.filter((policy) => {
      const category = policy.data.category || ''
      const severity = policy.data.severity || ''
      const resources = (policy.data.subjects || []).join(',').toLowerCase()
      const title = (policy.data.title || '').toLowerCase()
      const tags = (policy.data.tags || []).join(',').toLowerCase()

      // Search filter
      const matchesSearch =
        !searchQuery ||
        title.includes(searchQuery.toLowerCase()) ||
        tags.includes(searchQuery.toLowerCase())

      // Category filter
      const matchesCategory =
        selectedCategories.length === 0 || selectedCategories.includes(category)

      // Severity filter
      const matchesSeverity =
        selectedSeverities.length === 0 || selectedSeverities.includes(severity)

      // Resource filter
      const matchesResource =
        selectedResources.length === 0 ||
        selectedResources.some((res) => resources.includes(res.toLowerCase()))

      return (
        matchesSearch && matchesCategory && matchesSeverity && matchesResource
      )
    })
  }, [
    policies,
    searchQuery,
    selectedCategories,
    selectedSeverities,
    selectedResources,
  ])

  const handleCategoryToggle = (category) => {
    setSelectedCategories((prev) =>
      prev.includes(category)
        ? prev.filter((c) => c !== category)
        : [...prev, category],
    )
  }

  const handleSeverityToggle = (severity) => {
    setSelectedSeverities((prev) =>
      prev.includes(severity)
        ? prev.filter((s) => s !== severity)
        : [...prev, severity],
    )
  }

  const handleResourceToggle = (resource) => {
    setSelectedResources((prev) =>
      prev.includes(resource)
        ? prev.filter((r) => r !== resource)
        : [...prev, resource],
    )
  }

  const handleCategoryButtonClick = (category) => {
    setActiveCategoryButton(category)
    if (category === 'all') {
      setSelectedCategories([])
    } else {
      setSelectedCategories([category])
    }
  }

  const categoryLabels = {
    verifyImages: 'Verify Images',
    validate: 'Validate',
    mutate: 'Mutate',
    generate: 'Generate',
    cleanup: 'Cleanup',
  }

  const severityLabels = {
    high: 'High',
    medium: 'Medium',
    low: 'Low',
  }

  const severityOrder = { high: 0, medium: 1, low: 2 }
  const sortedSeverities = Object.entries(severityCounts).sort(
    ([a], [b]) => (severityOrder[a] || 99) - (severityOrder[b] || 99),
  )

  return (
    <div>
      <div className="mb-8">
        <div className="flex gap-4 items-center mb-4">
          <div className="flex-1 min-w-[300px] relative">
            <svg
              className="absolute left-5 top-1/2 -translate-y-1/2 text-white/50 pointer-events-none"
              width="20"
              height="20"
              fill="none"
              stroke="currentColor"
              strokeWidth="2.5"
            >
              <circle cx="9" cy="9" r="7" />
              <path d="M14 14l5 5" />
            </svg>
            <input
              type="text"
              placeholder="Search policies by name, description, or tag..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full py-4 pl-14 pr-5 bg-dark-50/80 backdrop-blur-sm border border-stroke/50 rounded-xl text-white text-base transition-all focus:outline-none focus:border-primary-100 focus:ring-4 focus:ring-primary-100/20 focus:bg-dark-50 placeholder:text-white/40 shadow-lg"
            />
          </div>
          <div className="text-white/70 text-sm font-medium whitespace-nowrap">
            {filteredPolicies.length}{' '}
            {filteredPolicies.length === 1 ? 'policy' : 'policies'} found
          </div>
        </div>
        <div className="flex gap-1 border-b border-stroke/50">
          {[
            { value: 'all', label: 'All' },
            { value: 'verifyImages', label: 'Verify Images' },
            { value: 'validate', label: 'Validate' },
            { value: 'mutate', label: 'Mutate' },
            { value: 'generate', label: 'Generate' },
            { value: 'cleanup', label: 'Cleanup' },
          ].map((category) => (
            <button
              key={category.value}
              type="button"
              onClick={() => handleCategoryButtonClick(category.value)}
              className={`px-5 py-3 text-sm font-medium cursor-pointer transition-all whitespace-nowrap relative ${
                activeCategoryButton === category.value
                  ? 'text-primary-100 border-b-2 border-primary-100'
                  : 'text-white/60 hover:text-white/80'
              }`}
            >
              {category.label}
            </button>
          ))}
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-[280px_1fr] gap-8">
        {/* Filter Sidebar */}
        <aside className="static lg:sticky lg:top-8 h-fit space-y-4">
          <div className="bg-dark-50/80 backdrop-blur-sm border border-stroke/50 rounded-2xl p-6 mb-4 hidden lg:block shadow-lg">
            <h3 className="text-xs uppercase tracking-widest text-white/50 mb-5 font-bold">
              Policy Type
            </h3>
            <div className="space-y-2">
              {Object.entries(categoryCounts).map(([category, count]) => (
                <label
                  key={category}
                  className="flex items-center justify-between py-2.5 px-3 rounded-lg cursor-pointer transition-all hover:bg-primary-100/10 hover:text-primary-100 filter-option group"
                >
                  <span className="text-sm font-medium text-white/80 group-hover:text-primary-100">
                    {categoryLabels[category] || category}
                  </span>
                  <span className="text-white/40 text-xs font-semibold ml-auto mr-3 bg-stroke/50 px-2 py-0.5 rounded-md">
                    {count}
                  </span>
                  <input
                    type="checkbox"
                    className="w-4 h-4 cursor-pointer accent-primary-100 category-filter rounded"
                    checked={selectedCategories.includes(category)}
                    onChange={() => handleCategoryToggle(category)}
                  />
                </label>
              ))}
            </div>
          </div>

          <div className="bg-dark-50/80 backdrop-blur-sm border border-stroke/50 rounded-2xl p-6 mb-4 hidden lg:block shadow-lg">
            <h3 className="text-xs uppercase tracking-widest text-white/50 mb-5 font-bold">
              Severity
            </h3>
            <div className="space-y-2">
              {sortedSeverities.map(([severity, count]) => (
                <label
                  key={severity}
                  className="flex items-center justify-between py-2.5 px-3 rounded-lg cursor-pointer transition-all hover:bg-primary-100/10 hover:text-primary-100 filter-option group"
                >
                  <span className="text-sm font-medium text-white/80 group-hover:text-primary-100">
                    {severityLabels[severity] || severity}
                  </span>
                  <span className="text-white/40 text-xs font-semibold ml-auto mr-3 bg-stroke/50 px-2 py-0.5 rounded-md">
                    {count}
                  </span>
                  <input
                    type="checkbox"
                    className="w-4 h-4 cursor-pointer accent-primary-100 severity-filter rounded"
                    checked={selectedSeverities.includes(severity)}
                    onChange={() => handleSeverityToggle(severity)}
                  />
                </label>
              ))}
            </div>
          </div>

          {topResources.length > 0 && (
            <div className="bg-dark-50/80 backdrop-blur-sm border border-stroke/50 rounded-2xl p-6 mb-4 hidden lg:block shadow-lg">
              <h3 className="text-xs uppercase tracking-widest text-white/50 mb-5 font-bold">
                Resources
              </h3>
              <div className="space-y-2 max-h-[400px] overflow-y-auto pr-2">
                {topResources.map(([resource, count]) => (
                  <label
                    key={resource}
                    className="flex items-center justify-between py-2.5 px-3 rounded-lg cursor-pointer transition-all hover:bg-primary-100/10 hover:text-primary-100 filter-option group"
                  >
                    <span className="text-sm font-medium text-white/80 group-hover:text-primary-100">
                      {resource}
                    </span>
                    <span className="text-white/40 text-xs font-semibold ml-auto mr-3 bg-stroke/50 px-2 py-0.5 rounded-md">
                      {count}
                    </span>
                    <input
                      type="checkbox"
                      className="w-4 h-4 cursor-pointer accent-primary-100 resource-filter rounded"
                      checked={selectedResources.includes(resource)}
                      onChange={() => handleResourceToggle(resource)}
                    />
                  </label>
                ))}
              </div>
            </div>
          )}
        </aside>

        {/* Policy Grid */}
        {filteredPolicies.length > 0 ? (
          <div className="grid grid-cols-[repeat(auto-fill,minmax(300px,1fr))] gap-6 lg:grid-cols-[repeat(auto-fill,minmax(380px,1fr))]">
            {filteredPolicies.map((policy) => (
              <PolicyCardReact key={policy.id} policy={policy} />
            ))}
          </div>
        ) : (
          <div className="col-span-full text-center py-20">
            <svg
              className="w-20 h-20 mx-auto mb-4 text-white/20"
              fill="none"
              stroke="currentColor"
              strokeWidth="1.5"
              viewBox="0 0 24 24"
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                d="M9.879 7.519c1.171-1.025 3.071-1.025 4.242 0 1.172 1.025 1.172 2.687 0 3.712-.203.179-.43.326-.67.442-.745.361-1.45.999-1.45 1.827v.75M21 12a9 9 0 11-18 0 9 9 0 0118 0zm-9 5.25h.008v.008H12v-.008z"
              />
            </svg>
            <p className="text-white/60 text-lg font-medium">
              No policies found matching your filters
            </p>
            <p className="text-white/40 text-sm mt-2">
              Try adjusting your search or filter criteria
            </p>
          </div>
        )}
      </div>
    </div>
  )
}

// Policy Card as React component
const PolicyCardReact = ({ policy }) => {
  const categoryLabels = {
    verifyImages: 'Verify Images',
    validate: 'Validate',
    mutate: 'Mutate',
    generate: 'Generate',
    cleanup: 'Cleanup',
  }

  const categoryColors = {
    verifyImages: 'bg-cyan-500/15 text-cyan-400 border-cyan-500/30',
    validate: 'bg-primary-100/15 text-primary-100 border-primary-100/30',
    mutate: 'bg-purple-500/15 text-purple-400 border-purple-500/30',
    generate: 'bg-emerald-500/15 text-emerald-400 border-emerald-500/30',
    cleanup: 'bg-orange-500/15 text-orange-400 border-orange-500/30',
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

  const category = policy.data.category || 'validate'
  const severity = policy.data.severity || 'N/A'

  // Use description from policy data if available
  const description = policy.data.description || null

  // Check if policy is marked as new
  const isNew = policy.data.isNew || false

  const handleCopyYAML = (e) => {
    e.preventDefault()
    e.stopPropagation()
    // Copy YAML logic - you'll need to fetch the YAML from the policy page
    const yamlUrl = `https://github.com/kyverno/policies/raw/main/${policy.id.replace(/-/g, '/')}/${policy.id.split('/').pop()}.yaml`
    // For now, just copy the URL
    navigator.clipboard.writeText(yamlUrl)
    // You could show a toast notification here
  }

  return (
    <div
      onClick={() => (window.location.href = `/policies/${policy.id}/`)}
      className="policy-card group bg-dark-50 border border-stroke rounded-2xl p-6 transition-all duration-300 cursor-pointer relative overflow-hidden hover:border-primary-100/50 hover:-translate-y-1 hover:shadow-[0_20px_40px_rgba(55,131,196,0.15)] before:content-[''] before:absolute before:top-0 before:left-0 before:right-0 before:h-[4px] before:bg-gradient-to-r before:from-primary-100 before:via-accent-100 before:to-primary-100 before:scale-x-0 before:transition-transform before:duration-300 hover:before:scale-x-100 flex flex-col min-h-[320px] max-h-[450px]"
    >
      <div className="flex-1 flex flex-col">
        <div className="flex gap-2 flex-wrap mb-4">
          <span
            className={`px-3 py-1.5 rounded-lg text-xs font-bold uppercase tracking-wider border backdrop-blur-sm ${
              categoryColors[category] || categoryColors.validate
            } shadow-sm`}
          >
            {categoryLabels[category] || category}
          </span>
          <span
            className={`px-3 py-1.5 rounded-lg text-xs font-bold uppercase tracking-wider border backdrop-blur-sm ${
              severityColors[severity] || severityColors.medium
            } shadow-sm`}
          >
            {severityLabels[severity] || severity}
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
                className="tag px-2.5 py-1 bg-stroke/60 backdrop-blur-sm rounded-lg text-xs text-white/70 transition-all hover:bg-primary-100/20 hover:text-primary-100 border border-stroke/50"
              >
                #{tag}
              </span>
            ))}
          </div>
        )}
      </div>
      <div className="flex flex-wrap gap-4 pt-4 border-t border-stroke/50 text-sm text-white/50 mb-4">
        {policy.data.subjects && policy.data.subjects.length > 0 && (
          <div className="flex items-center gap-2">
            <svg
              width="16"
              height="16"
              fill="none"
              stroke="currentColor"
              strokeWidth="2"
              className="text-primary-100/60"
            >
              <rect x="2" y="2" width="12" height="12" rx="1.5" />
            </svg>
            <span className="font-medium">
              {policy.data.subjects.slice(0, 3).join(', ')}
            </span>
            {policy.data.subjects.length > 3 && (
              <span className="text-white/30">...</span>
            )}
          </div>
        )}
        {policy.data.version && (
          <div className="flex items-center gap-2">
            <svg
              width="16"
              height="16"
              fill="none"
              stroke="currentColor"
              strokeWidth="2"
              className="text-primary-100/60"
            >
              <path d="M8 2v12M2 8h12" />
            </svg>
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
          <svg
            width="16"
            height="16"
            fill="none"
            stroke="currentColor"
            strokeWidth="2.5"
          >
            <path d="M8 2v12M2 8h12" />
          </svg>
          View Details
        </a>
        <button
          onClick={handleCopyYAML}
          className="flex-1 py-2.5 px-4 bg-stroke border border-stroke/80 rounded-lg text-white text-sm font-medium cursor-pointer transition-all flex items-center justify-center gap-2 hover:bg-primary-100/20 hover:border-primary-100/50 hover:text-primary-100"
        >
          <svg
            width="16"
            height="16"
            fill="none"
            stroke="currentColor"
            strokeWidth="2"
          >
            <rect x="3" y="3" width="10" height="10" rx="1" />
            <path d="M7 3V1M11 3V1" />
          </svg>
          Copy YAML
        </button>
      </div>
    </div>
  )
}
