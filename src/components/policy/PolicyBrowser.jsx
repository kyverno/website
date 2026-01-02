import {
  ChevronLeft,
  ChevronRight,
  ChevronsLeft,
  ChevronsRight,
  Search,
  X,
} from 'lucide-react'
import {
  formatCategoryLabel,
  formatSeverityLabel,
  getSeverityOrder,
} from './utils'
import { useEffect, useMemo, useState } from 'react'

import { PolicyCard } from './PolicyCard'

export const PolicyBrowser = ({ policies }) => {
  const [searchQuery, setSearchQuery] = useState('')
  const [selectedCategories, setSelectedCategories] = useState([])
  const [selectedSeverities, setSelectedSeverities] = useState([])
  const [selectedResources, setSelectedResources] = useState([])
  const [selectedTags, setSelectedTags] = useState([])
  const [selectedTypes, setSelectedTypes] = useState([])
  const [activeCategoryButton, setActiveCategoryButton] = useState('all')
  const [currentPage, setCurrentPage] = useState(1)
  const itemsPerPage = 24

  // Helper function to check if a policy matches filters (excluding a specific filter type)
  const matchesFilters = (policy, excludeFilter) => {
    const category = policy.data.category || ''
    const severity = policy.data.severity || ''
    const resources = (policy.data.subjects || []).join(',').toLowerCase()
    const title = (policy.data.title || '').toLowerCase()
    const description = (policy.data.description || '').toLowerCase()
    const tags = (policy.data.tags || []).join(',').toLowerCase()
    const categoryLabel = formatCategoryLabel(category).toLowerCase()
    const severityLabel = formatSeverityLabel(severity).toLowerCase()

    // Search filter
    const searchLower = searchQuery.toLowerCase()
    const matchesSearch =
      !searchQuery ||
      title.includes(searchLower) ||
      description.includes(searchLower) ||
      tags.includes(searchLower) ||
      resources.includes(searchLower) ||
      categoryLabel.includes(searchLower) ||
      severityLabel.includes(searchLower)

    // Category filter (exclude if excludeFilter is 'category')
    const matchesCategory =
      excludeFilter === 'category' ||
      selectedCategories.length === 0 ||
      selectedCategories.includes(category)

    // Severity filter (exclude if excludeFilter is 'severity')
    const matchesSeverity =
      excludeFilter === 'severity' ||
      selectedSeverities.length === 0 ||
      selectedSeverities.includes(severity)

    // Resource filter (exclude if excludeFilter is 'resource')
    const matchesResource =
      excludeFilter === 'resource' ||
      selectedResources.length === 0 ||
      selectedResources.some((selectedRes) => {
        const policySubjects = policy.data.subjects || []
        return policySubjects.some(
          (subject) => subject.toLowerCase() === selectedRes.toLowerCase(),
        )
      })

    // Tag filter (exclude if excludeFilter is 'tag')
    const matchesTag =
      excludeFilter === 'tag' ||
      selectedTags.length === 0 ||
      selectedTags.some((tag) => {
        const policyTags = (policy.data.tags || []).map((t) => t.toLowerCase())
        return policyTags.includes(tag.toLowerCase())
      })

    // Type filter (exclude if excludeFilter is 'type')
    const matchesType =
      excludeFilter === 'type' ||
      selectedTypes.length === 0 ||
      (policy.data.type && selectedTypes.includes(policy.data.type))

    return (
      matchesSearch &&
      matchesCategory &&
      matchesSeverity &&
      matchesResource &&
      matchesTag &&
      matchesType
    )
  }

  // Generic function to calculate filter counts
  const calculateFilterCounts = (excludeFilter, getValue) => {
    const counts = {}
    policies.forEach((policy) => {
      if (matchesFilters(policy, excludeFilter)) {
        const value = getValue(policy)
        if (value !== null && value !== undefined) {
          if (Array.isArray(value)) {
            value.forEach((item) => {
              counts[item] = (counts[item] || 0) + 1
            })
          } else {
            counts[value] = (counts[value] || 0) + 1
          }
        }
      }
    })
    return counts
  }

  // Calculate dynamic filter counts based on current filters
  const typeCounts = useMemo(
    () => calculateFilterCounts('type', (p) => p.data.type),
    [
      policies,
      searchQuery,
      selectedCategories,
      selectedSeverities,
      selectedResources,
      selectedTags,
      selectedTypes,
    ],
  )

  const categoryCounts = useMemo(
    () => calculateFilterCounts('category', (p) => p.data.category),
    [
      policies,
      searchQuery,
      selectedSeverities,
      selectedResources,
      selectedTags,
      selectedTypes,
    ],
  )

  const severityCounts = useMemo(
    () => calculateFilterCounts('severity', (p) => p.data.severity),
    [
      policies,
      searchQuery,
      selectedCategories,
      selectedResources,
      selectedTags,
      selectedTypes,
    ],
  )

  const resourceCounts = useMemo(
    () => calculateFilterCounts('resource', (p) => p.data.subjects),
    [
      policies,
      searchQuery,
      selectedCategories,
      selectedSeverities,
      selectedTags,
      selectedTypes,
    ],
  )

  const tagCounts = useMemo(
    () => calculateFilterCounts('tag', (p) => p.data.tags),
    [
      policies,
      searchQuery,
      selectedCategories,
      selectedSeverities,
      selectedResources,
      selectedTypes,
    ],
  )

  const topResources = useMemo(() => {
    return Object.entries(resourceCounts).sort(([nameA], [nameB]) =>
      nameA.localeCompare(nameB),
    )
  }, [resourceCounts])

  const topTags = useMemo(() => {
    return Object.entries(tagCounts).sort(([tagA], [tagB]) =>
      tagA.localeCompare(tagB),
    )
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

  // Use matchesFilters for filteredPolicies (no excludeFilter means all filters apply)
  const filteredPolicies = useMemo(() => {
    return policies.filter((policy) => matchesFilters(policy, null))
  }, [
    policies,
    searchQuery,
    selectedCategories,
    selectedSeverities,
    selectedResources,
    selectedTags,
    selectedTypes,
  ])

  // Reset to page 1 when filters change
  useEffect(() => {
    setCurrentPage(1)
  }, [
    searchQuery,
    selectedCategories,
    selectedSeverities,
    selectedResources,
    selectedTags,
    selectedTypes,
  ])

  // Calculate pagination
  const totalPages = Math.ceil(filteredPolicies.length / itemsPerPage)
  const startIndex = (currentPage - 1) * itemsPerPage
  const endIndex = startIndex + itemsPerPage
  const paginatedPolicies = filteredPolicies.slice(startIndex, endIndex)

  const goToPage = (page) => {
    const validPage = Math.max(1, Math.min(page, totalPages))
    setCurrentPage(validPage)
    // Scroll to top of results
    window.scrollTo({ top: 0, behavior: 'smooth' })
  }

  // Generic toggle handler factory
  const createToggleHandler = (setter) => (value) => {
    setter((prev) =>
      prev.includes(value) ? prev.filter((v) => v !== value) : [...prev, value],
    )
  }

  const handleCategoryToggle = createToggleHandler(setSelectedCategories)
  const handleSeverityToggle = createToggleHandler(setSelectedSeverities)
  const handleResourceToggle = createToggleHandler(setSelectedResources)
  const handleTagToggle = createToggleHandler(setSelectedTags)
  const handleTypeToggle = createToggleHandler(setSelectedTypes)

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
      const countDiff = categoryCounts[b] - categoryCounts[a]
      if (countDiff !== 0) return countDiff
      return formatCategoryLabel(a).localeCompare(formatCategoryLabel(b))
    })
  }, [categoryCounts])

  const sortedSeverities = Object.entries(severityCounts).sort(
    ([a], [b]) => getSeverityOrder(a) - getSeverityOrder(b),
  )

  // Filter chip component
  const FilterChip = ({ label, value, onRemove, ariaLabel }) => (
    <span className="inline-flex items-center gap-2 px-3 py-1.5 bg-primary-100/20 text-primary-100 border border-primary-100/50 rounded-lg text-sm font-medium max-w-full">
      <span className="truncate">{label}</span>
      <button
        onClick={onRemove}
        className="hover:bg-primary-100/20 rounded p-0.5 transition-colors flex-shrink-0"
        aria-label={ariaLabel}
      >
        <X size={14} />
      </button>
    </span>
  )

  // Filter section component
  const FilterSection = ({
    title,
    items,
    selectedItems,
    onToggle,
    formatLabel,
    sortFn,
    defaultOpen = false,
    showCount = true,
    itemClassName = '',
  }) => {
    if (!items || items.length === 0) return null

    const sortedItems = sortFn ? [...items].sort(sortFn) : items

    return (
      <details
        className="group bg-dark-50/80 backdrop-blur-sm border border-stroke/50 rounded-2xl shadow-lg overflow-hidden"
        open={defaultOpen}
      >
        <summary className="px-4 sm:px-6 py-4 cursor-pointer list-none flex items-center justify-between hover:bg-dark-50/50 transition-colors">
          <h3 className="text-xs uppercase tracking-widest text-white/50 font-bold">
            {title}
          </h3>
          <ChevronLeft
            size={16}
            className="text-white/50 transition-transform duration-200 group-open:rotate-[-90deg]"
          />
        </summary>
        <div className="px-4 sm:px-6 pb-6 pt-2 space-y-2 max-h-[400px] overflow-y-auto pr-2">
          {sortedItems.map(([value, count]) => (
            <label
              key={value}
              className={`flex items-center justify-between py-2.5 px-3 rounded-lg cursor-pointer transition-all hover:bg-primary-100/10 filter-option group ${itemClassName}`}
            >
              <span className="text-sm font-medium text-white/80 truncate min-w-0 flex-1">
                {formatLabel ? formatLabel(value) : value}
              </span>
              {showCount && (
                <span className="text-white/40 text-xs font-semibold ml-auto mr-3 bg-stroke/50 px-2 py-0.5 rounded-md flex-shrink-0">
                  {count}
                </span>
              )}
              <input
                type="checkbox"
                className="w-4 h-4 cursor-pointer accent-primary-100 rounded flex-shrink-0"
                checked={selectedItems.includes(value)}
                onChange={() => onToggle(value)}
              />
            </label>
          ))}
        </div>
      </details>
    )
  }

  // Active filters configuration
  const activeFilters = useMemo(() => {
    const filters = []
    if (searchQuery) {
      filters.push({
        type: 'search',
        label: `Search: "${searchQuery}"`,
        onRemove: () => setSearchQuery(''),
        ariaLabel: 'Clear search',
      })
    }
    selectedCategories.forEach((category) => {
      filters.push({
        type: 'category',
        label: `Category: ${formatCategoryLabel(category)}`,
        onRemove: () => handleCategoryToggle(category),
        ariaLabel: `Remove ${formatCategoryLabel(category)} filter`,
      })
    })
    selectedSeverities.forEach((severity) => {
      filters.push({
        type: 'severity',
        label: `Severity: ${formatSeverityLabel(severity)}`,
        onRemove: () => handleSeverityToggle(severity),
        ariaLabel: `Remove ${formatSeverityLabel(severity)} filter`,
      })
    })
    selectedTypes.forEach((type) => {
      filters.push({
        type: 'type',
        label: `Kind: ${type}`,
        onRemove: () => handleTypeToggle(type),
        ariaLabel: `Remove ${type} filter`,
      })
    })
    selectedResources.forEach((resource) => {
      filters.push({
        type: 'resource',
        label: `Resource: ${resource}`,
        onRemove: () => handleResourceToggle(resource),
        ariaLabel: `Remove ${resource} filter`,
      })
    })
    selectedTags.forEach((tag) => {
      filters.push({
        type: 'tag',
        label: `Tag: ${tag}`,
        onRemove: () => handleTagToggle(tag),
        ariaLabel: `Remove ${tag} filter`,
      })
    })
    return filters
  }, [
    searchQuery,
    selectedCategories,
    selectedSeverities,
    selectedTypes,
    selectedResources,
    selectedTags,
  ])

  const hasActiveFilters = activeFilters.length > 0

  const clearAllFilters = () => {
    setSearchQuery('')
    setSelectedCategories([])
    setSelectedSeverities([])
    setSelectedResources([])
    setSelectedTags([])
    setSelectedTypes([])
    setActiveCategoryButton('all')
  }

  return (
    <div>
      <div className="mb-8">
        <div className="flex flex-col sm:flex-row gap-4 items-stretch sm:items-center mb-4">
          <div className="flex-1 relative">
            <Search
              className="absolute left-5 top-1/2 -translate-y-1/2 text-white/60 pointer-events-none z-10"
              size={20}
              strokeWidth={2.5}
            />
            <input
              type="text"
              placeholder={`Search by ${getSearchableFields.map((f) => (f === 'subjects' ? 'resources' : f)).join(', ')}...`}
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full py-4 pl-14 pr-5 bg-dark-50/80 backdrop-blur-sm border border-stroke/50 rounded-xl text-white text-base transition-all focus:outline-none focus:border-primary-100 focus:ring-4 focus:ring-primary-100/20 focus:bg-dark-50 placeholder:text-white/40 shadow-lg relative z-0"
            />
          </div>
          <div className="text-white/70 text-sm font-medium whitespace-nowrap text-center sm:text-left">
            {filteredPolicies.length}{' '}
            {filteredPolicies.length === 1 ? 'policy' : 'policies'} found
            {totalPages > 1 && (
              <span className="text-white/50 ml-2">
                (Page {currentPage} of {totalPages})
              </span>
            )}
          </div>
        </div>

        {/* Active Filter Chips */}
        {hasActiveFilters && (
          <div className="flex flex-wrap gap-2 mb-4">
            {activeFilters.map((filter, index) => (
              <FilterChip
                key={`${filter.type}-${index}`}
                label={filter.label}
                onRemove={filter.onRemove}
                ariaLabel={filter.ariaLabel}
              />
            ))}
            <button
              onClick={clearAllFilters}
              className="px-3 py-1.5 text-white/60 hover:text-white/80 text-sm font-medium underline transition-colors"
            >
              Clear all
            </button>
          </div>
        )}

        <div className="flex gap-1 border-b border-stroke/50 overflow-x-auto scrollbar-hide -mx-4 px-4 sm:mx-0 sm:px-0">
          <button
            type="button"
            onClick={() => handleCategoryButtonClick('all')}
            className={`px-5 py-3 text-sm font-medium cursor-pointer transition-all whitespace-nowrap relative flex-shrink-0 ${
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
              className={`px-5 py-3 text-sm font-medium cursor-pointer transition-all whitespace-nowrap relative flex-shrink-0 ${
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

      <div className="flex flex-col lg:grid lg:grid-cols-[280px_1fr] gap-4 lg:gap-8">
        {/* Filter Sidebar */}
        <aside className="static lg:sticky lg:top-8 h-fit space-y-4">
          <FilterSection
            title="Policy Kind"
            items={Object.entries(typeCounts)}
            selectedItems={selectedTypes}
            onToggle={handleTypeToggle}
            sortFn={([typeA, countA], [typeB, countB]) => {
              if (countB !== countA) return countB - countA
              return typeA.localeCompare(typeB)
            }}
            defaultOpen={true}
            itemClassName="font-mono"
          />

          <FilterSection
            title="Severity"
            items={sortedSeverities}
            selectedItems={selectedSeverities}
            onToggle={handleSeverityToggle}
            formatLabel={formatSeverityLabel}
          />

          <FilterSection
            title="Resources"
            items={topResources}
            selectedItems={selectedResources}
            onToggle={handleResourceToggle}
            itemClassName="min-w-0"
          />

          <FilterSection
            title="Tags"
            items={topTags}
            selectedItems={selectedTags}
            onToggle={handleTagToggle}
          />
        </aside>

        {/* Policy Grid */}
        <div className="flex flex-col">
          {filteredPolicies.length > 0 ? (
            <div className="grid grid-cols-1 sm:grid-cols-[repeat(auto-fill,minmax(280px,1fr))] lg:grid-cols-[repeat(auto-fill,minmax(380px,1fr))] gap-4 sm:gap-6">
              {paginatedPolicies.map((policy) => (
                <PolicyCard key={policy.id} policy={policy} />
              ))}
            </div>
          ) : (
            <div className="text-center py-20">
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

        {/* Pagination Controls - spans full width on desktop */}
        {filteredPolicies.length > 0 && totalPages > 1 && (
          <div className="lg:col-span-2 mt-8 pt-6 border-t border-stroke/50">
            <div className="flex flex-col gap-4">
              {/* Results info */}
              <div className="text-white/60 text-sm text-center">
                Showing{' '}
                <span className="text-white font-medium">{startIndex + 1}</span>{' '}
                to{' '}
                <span className="text-white font-medium">
                  {Math.min(endIndex, filteredPolicies.length)}
                </span>{' '}
                of{' '}
                <span className="text-white font-medium">
                  {filteredPolicies.length}
                </span>{' '}
                policies
              </div>

              {/* Pagination controls */}
              <div className="w-full overflow-x-auto scrollbar-hide -mx-4 px-4 sm:mx-0 sm:px-0">
                <div className="flex items-center justify-center gap-1 sm:gap-2 min-w-max mx-auto">
                  {/* Navigation buttons */}
                  <button
                    onClick={() => goToPage(1)}
                    disabled={currentPage === 1}
                    className="p-2 rounded-lg border border-stroke/50 bg-dark-50/50 text-white/60 hover:text-white hover:border-primary-100/50 hover:bg-primary-100/10 disabled:opacity-30 disabled:cursor-not-allowed disabled:hover:bg-dark-50/50 disabled:hover:border-stroke/50 transition-all flex-shrink-0"
                    aria-label="First page"
                    title="First page"
                  >
                    <ChevronsLeft size={18} />
                  </button>
                  <button
                    onClick={() => goToPage(currentPage - 1)}
                    disabled={currentPage === 1}
                    className="p-2 rounded-lg border border-stroke/50 bg-dark-50/50 text-white/60 hover:text-white hover:border-primary-100/50 hover:bg-primary-100/10 disabled:opacity-30 disabled:cursor-not-allowed disabled:hover:bg-dark-50/50 disabled:hover:border-stroke/50 transition-all flex-shrink-0"
                    aria-label="Previous page"
                    title="Previous page"
                  >
                    <ChevronLeft size={18} />
                  </button>

                  {/* Page numbers */}
                  {Array.from({ length: totalPages }, (_, i) => i + 1)
                    .filter((page) => {
                      // Show first page, last page, current page, and pages around current
                      const maxPages = 7
                      if (totalPages <= maxPages) return true
                      if (page === 1 || page === totalPages) return true
                      if (Math.abs(page - currentPage) <= 1) return true
                      return false
                    })
                    .map((page, index, array) => {
                      // Add ellipsis if there's a gap
                      const showEllipsisBefore =
                        index > 0 && page - array[index - 1] > 1
                      return (
                        <div key={page} className="flex items-center gap-1">
                          {showEllipsisBefore && (
                            <span className="px-1 sm:px-2 text-white/40 text-xs sm:text-sm flex-shrink-0">
                              ...
                            </span>
                          )}
                          <button
                            onClick={() => goToPage(page)}
                            className={`min-w-[36px] sm:min-w-[40px] h-9 sm:h-10 px-2 sm:px-3 rounded-lg text-xs sm:text-sm font-medium transition-all flex-shrink-0 ${
                              currentPage === page
                                ? 'bg-primary-100 text-white shadow-lg shadow-primary-100/20'
                                : 'border border-stroke/50 bg-dark-50/50 text-white/70 hover:text-white hover:border-primary-100/50 hover:bg-primary-100/10'
                            }`}
                            aria-label={`Go to page ${page}`}
                            aria-current={
                              currentPage === page ? 'page' : undefined
                            }
                          >
                            {page}
                          </button>
                        </div>
                      )
                    })}

                  <button
                    onClick={() => goToPage(currentPage + 1)}
                    disabled={currentPage === totalPages}
                    className="p-2 rounded-lg border border-stroke/50 bg-dark-50/50 text-white/60 hover:text-white hover:border-primary-100/50 hover:bg-primary-100/10 disabled:opacity-30 disabled:cursor-not-allowed disabled:hover:bg-dark-50/50 disabled:hover:border-stroke/50 transition-all flex-shrink-0"
                    aria-label="Next page"
                    title="Next page"
                  >
                    <ChevronRight size={18} />
                  </button>
                  <button
                    onClick={() => goToPage(totalPages)}
                    disabled={currentPage === totalPages}
                    className="p-2 rounded-lg border border-stroke/50 bg-dark-50/50 text-white/60 hover:text-white hover:border-primary-100/50 hover:bg-primary-100/10 disabled:opacity-30 disabled:cursor-not-allowed disabled:hover:bg-dark-50/50 disabled:hover:border-stroke/50 transition-all flex-shrink-0"
                    aria-label="Last page"
                    title="Last page"
                  >
                    <ChevronsRight size={18} />
                  </button>
                </div>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  )
}
