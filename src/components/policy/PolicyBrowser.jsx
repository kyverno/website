import {
  formatCategoryLabel,
  formatSeverityLabel,
  getSeverityOrder,
} from './utils'
import { useMemo, useState } from 'react'

import { PolicyCard } from './PolicyCard'

export const PolicyBrowser = ({ policies }) => {
  const [searchQuery, setSearchQuery] = useState('')
  const [selectedCategories, setSelectedCategories] = useState([])
  const [selectedSeverities, setSelectedSeverities] = useState([])
  const [selectedResources, setSelectedResources] = useState([])
  const [selectedTags, setSelectedTags] = useState([])
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
    // Show all resources, sorted by count (descending), then alphabetically
    return Object.entries(resourceCounts).sort(
      ([nameA, countA], [nameB, countB]) => {
        // First sort by count (descending)
        if (countB !== countA) {
          return countB - countA
        }
        // Then sort alphabetically
        return nameA.localeCompare(nameB)
      },
    )
  }, [resourceCounts])

  const tagCounts = useMemo(() => {
    const counts = {}
    policies.forEach((policy) => {
      if (policy.data.tags) {
        policy.data.tags.forEach((tag) => {
          counts[tag] = (counts[tag] || 0) + 1
        })
      }
    })
    return counts
  }, [policies])

  const topTags = useMemo(() => {
    return Object.entries(tagCounts)
      .sort(([, a], [, b]) => b - a)
      .slice(0, 20) // Show top 20 tags
  }, [tagCounts])

  // Get all searchable metadata fields dynamically
  const getSearchableFields = useMemo(() => {
    const fields = new Set()
    policies.forEach((policy) => {
      if (policy.data.title) fields.add('title')
      if (policy.data.description) fields.add('description')
      if (policy.data.tags && policy.data.tags.length > 0) fields.add('tags')
      if (policy.data.subjects && policy.data.subjects.length > 0)
        fields.add('subjects')
      if (policy.data.category) fields.add('category')
      if (policy.data.severity) fields.add('severity')
    })
    return Array.from(fields)
  }, [policies])

  const filteredPolicies = useMemo(() => {
    return policies.filter((policy) => {
      const category = policy.data.category || ''
      const severity = policy.data.severity || ''
      const resources = (policy.data.subjects || []).join(',').toLowerCase()
      const title = (policy.data.title || '').toLowerCase()
      const description = (policy.data.description || '').toLowerCase()
      const tags = (policy.data.tags || []).join(',').toLowerCase()
      const categoryLabel = formatCategoryLabel(category).toLowerCase()
      const severityLabel = formatSeverityLabel(severity).toLowerCase()

      // Search filter - search across all available metadata fields
      const searchLower = searchQuery.toLowerCase()
      const matchesSearch =
        !searchQuery ||
        title.includes(searchLower) ||
        description.includes(searchLower) ||
        tags.includes(searchLower) ||
        resources.includes(searchLower) ||
        categoryLabel.includes(searchLower) ||
        severityLabel.includes(searchLower)

      // Category filter
      const matchesCategory =
        selectedCategories.length === 0 || selectedCategories.includes(category)

      // Severity filter
      const matchesSeverity =
        selectedSeverities.length === 0 || selectedSeverities.includes(severity)

      // Resource filter - exact match to avoid partial matches (e.g., "Service" matching "ServiceAccount")
      // Matches against policies.kyverno.io/subject annotation values
      const matchesResource =
        selectedResources.length === 0 ||
        selectedResources.some((selectedRes) => {
          // Get subjects from policy.data.subjects (which comes from policies.kyverno.io/subject annotation)
          const policySubjects = policy.data.subjects || []
          // Case-insensitive exact match
          return policySubjects.some(
            (subject) => subject.toLowerCase() === selectedRes.toLowerCase(),
          )
        })

      // Tag filter - check if policy has any of the selected tags
      const matchesTag =
        selectedTags.length === 0 ||
        selectedTags.some((tag) => {
          const policyTags = (policy.data.tags || []).map((t) =>
            t.toLowerCase(),
          )
          return policyTags.includes(tag.toLowerCase())
        })

      return (
        matchesSearch &&
        matchesCategory &&
        matchesSeverity &&
        matchesResource &&
        matchesTag
      )
    })
  }, [
    policies,
    searchQuery,
    selectedCategories,
    selectedSeverities,
    selectedResources,
    selectedTags,
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

  const handleTagToggle = (tag) => {
    setSelectedTags((prev) =>
      prev.includes(tag) ? prev.filter((t) => t !== tag) : [...prev, tag],
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

  // Generate category buttons dynamically from available categories
  const availableCategories = useMemo(() => {
    return Object.keys(categoryCounts).sort((a, b) => {
      // Sort by count (descending), then by label
      const countDiff = categoryCounts[b] - categoryCounts[a]
      if (countDiff !== 0) return countDiff
      return formatCategoryLabel(a).localeCompare(formatCategoryLabel(b))
    })
  }, [categoryCounts])

  const sortedSeverities = Object.entries(severityCounts).sort(
    ([a], [b]) => getSeverityOrder(a) - getSeverityOrder(b),
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
              placeholder={`Search by ${getSearchableFields.map((f) => (f === 'subjects' ? 'resources' : f)).join(', ')}...`}
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
          <button
            type="button"
            onClick={() => handleCategoryButtonClick('all')}
            className={`px-5 py-3 text-sm font-medium cursor-pointer transition-all whitespace-nowrap relative ${
              activeCategoryButton === 'all'
                ? 'text-primary-100 border-b-2 border-primary-100'
                : 'text-white/60 hover:text-white/80'
            }`}
          >
            All
          </button>
          {availableCategories.map((category) => (
            <button
              key={category}
              type="button"
              onClick={() => handleCategoryButtonClick(category)}
              className={`px-5 py-3 text-sm font-medium cursor-pointer transition-all whitespace-nowrap relative ${
                activeCategoryButton === category
                  ? 'text-primary-100 border-b-2 border-primary-100'
                  : 'text-white/60 hover:text-white/80'
              }`}
            >
              {formatCategoryLabel(category)}
            </button>
          ))}
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-[280px_1fr] gap-8">
        {/* Filter Sidebar */}
        <aside className="static lg:sticky lg:top-8 h-fit space-y-4">
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
                    {formatSeverityLabel(severity)}
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
                    className="flex items-center justify-between py-2.5 px-3 rounded-lg cursor-pointer transition-all hover:bg-primary-100/10 hover:text-primary-100 filter-option group min-w-0"
                  >
                    <span className="text-sm font-medium text-white/80 group-hover:text-primary-100 truncate min-w-0 flex-1">
                      {resource}
                    </span>
                    <span className="text-white/40 text-xs font-semibold ml-auto mr-3 bg-stroke/50 px-2 py-0.5 rounded-md flex-shrink-0">
                      {count}
                    </span>
                    <input
                      type="checkbox"
                      className="w-4 h-4 cursor-pointer accent-primary-100 resource-filter rounded flex-shrink-0"
                      checked={selectedResources.includes(resource)}
                      onChange={() => handleResourceToggle(resource)}
                    />
                  </label>
                ))}
              </div>
            </div>
          )}

          {topTags.length > 0 && (
            <div className="bg-dark-50/80 backdrop-blur-sm border border-stroke/50 rounded-2xl p-6 mb-4 hidden lg:block shadow-lg">
              <h3 className="text-xs uppercase tracking-widest text-white/50 mb-5 font-bold">
                Tags
              </h3>
              <div className="space-y-2 max-h-[400px] overflow-y-auto pr-2">
                {topTags.map(([tag, count]) => (
                  <label
                    key={tag}
                    className="flex items-center justify-between py-2.5 px-3 rounded-lg cursor-pointer transition-all hover:bg-primary-100/10 hover:text-primary-100 filter-option group"
                  >
                    <span className="text-sm font-medium text-white/80 group-hover:text-primary-100">
                      {tag}
                    </span>
                    <span className="text-white/40 text-xs font-semibold ml-auto mr-3 bg-stroke/50 px-2 py-0.5 rounded-md">
                      {count}
                    </span>
                    <input
                      type="checkbox"
                      className="w-4 h-4 cursor-pointer accent-primary-100 tag-filter rounded"
                      checked={selectedTags.includes(tag)}
                      onChange={() => handleTagToggle(tag)}
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
              <PolicyCard key={policy.id} policy={policy} />
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
