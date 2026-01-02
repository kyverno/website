export const FilterSidebar = ({
  policies,
  selectedCategories = [],
  selectedSeverities = [],
  selectedResources = [],
  onCategoryChange,
  onSeverityChange,
  onResourceChange,
}) => {
  // Calculate counts
  const categoryCounts = {}
  const severityCounts = {}
  const resourceCounts = {}

  policies.forEach((policy) => {
    // Category counts
    const cat = policy.data.category
    categoryCounts[cat] = (categoryCounts[cat] || 0) + 1

    // Severity counts
    const sev = policy.data.severity
    severityCounts[sev] = (severityCounts[sev] || 0) + 1

    // Resource counts
    if (policy.data.subjects) {
      policy.data.subjects.forEach((resource) => {
        resourceCounts[resource] = (resourceCounts[resource] || 0) + 1
      })
    }
  })

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

  // Get top resources by count
  const topResources = Object.entries(resourceCounts)
    .sort(([, a], [, b]) => b - a)
    .slice(0, 10)

  return (
    <aside class="static lg:sticky lg:top-8 h-fit">
      <div class="bg-dark-50 border border-stroke rounded-xl p-6 mb-4 hidden lg:block">
        <h3 class="text-xs uppercase tracking-wider text-white/60 mb-4 font-semibold">
          Policy Type
        </h3>
        {Object.entries(categoryCounts).map(([category, count]) => (
          <label class="flex items-center justify-between py-2 cursor-pointer transition-colors hover:text-primary-100">
            <span>{categoryLabels[category] || category}</span>
            <span class="text-white/40 text-sm ml-auto mr-2">{count}</span>
            <input
              type="checkbox"
              class="w-[1.125rem] h-[1.125rem] cursor-pointer accent-primary-100"
              checked={selectedCategories.includes(category)}
              onchange={(e) => onCategoryChange?.(category, e.target.checked)}
            />
          </label>
        ))}
      </div>

      <div class="bg-dark-50 border border-stroke rounded-xl p-6 mb-4 hidden lg:block">
        <h3 class="text-xs uppercase tracking-wider text-white/60 mb-4 font-semibold">
          Severity
        </h3>
        {Object.entries(severityCounts)
          .sort(([a], [b]) => {
            const order = { high: 0, medium: 1, low: 2 }
            return (order[a] || 99) - (order[b] || 99)
          })
          .map(([severity, count]) => (
            <label class="flex items-center justify-between py-2 cursor-pointer transition-colors hover:text-primary-100">
              <span>{severityLabels[severity] || severity}</span>
              <span class="text-white/40 text-sm ml-auto mr-2">{count}</span>
              <input
                type="checkbox"
                class="w-[1.125rem] h-[1.125rem] cursor-pointer accent-primary-100"
                checked={selectedSeverities.includes(severity)}
                onchange={(e) => onSeverityChange?.(severity, e.target.checked)}
              />
            </label>
          ))}
      </div>

      {topResources.length > 0 && (
        <div class="bg-dark-50 border border-stroke rounded-xl p-6 mb-4 hidden lg:block">
          <h3 class="text-xs uppercase tracking-wider text-white/60 mb-4 font-semibold">
            Resources
          </h3>
          {topResources.map(([resource, count]) => (
            <label class="flex items-center justify-between py-2 cursor-pointer transition-colors hover:text-primary-100">
              <span>{resource}</span>
              <span class="text-white/40 text-sm ml-auto mr-2">{count}</span>
              <input
                type="checkbox"
                class="w-[1.125rem] h-[1.125rem] cursor-pointer accent-primary-100"
                checked={selectedResources.includes(resource)}
                onchange={(e) => onResourceChange?.(resource, e.target.checked)}
              />
            </label>
          ))}
        </div>
      )}
    </aside>
  )
}
