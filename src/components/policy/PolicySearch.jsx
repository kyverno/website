export const PolicySearch = ({
  searchQuery,
  onSearchChange,
  onCategoryFilter,
}) => {
  const categories = [
    { value: 'all', label: 'All' },
    { value: 'verifyImages', label: 'Verify Images' },
    { value: 'validate', label: 'Validate' },
    { value: 'mutate', label: 'Mutate' },
    { value: 'generate', label: 'Generate' },
    { value: 'cleanup', label: 'Cleanup' },
  ]

  return (
    <div class="flex gap-4 mb-8 flex-wrap">
      <div class="flex-1 min-w-[300px] relative">
        <svg
          class="absolute left-4 top-1/2 -translate-y-1/2 text-white/40"
          width="20"
          height="20"
          fill="none"
          stroke="currentColor"
          stroke-width="2"
        >
          <circle cx="9" cy="9" r="7" />
          <path d="M14 14l5 5" />
        </svg>
        <input
          type="text"
          placeholder="Search policies by name, description, or tag..."
          value={searchQuery}
          oninput={(e) => onSearchChange?.(e.target.value)}
          class="w-full py-3.5 pl-12 pr-4 bg-dark-50 border border-stroke rounded-lg text-white text-base transition-all focus:outline-none focus:border-primary-100 focus:ring-4 focus:ring-primary-100/10"
        />
      </div>
      <div class="flex gap-2">
        {categories.map((category) => (
          <button
            type="button"
            onClick={() => onCategoryFilter?.(category.value)}
            class={`px-5 py-3.5 rounded-lg text-sm cursor-pointer transition-all whitespace-nowrap ${
              category.value === 'all'
                ? 'bg-primary-100 border border-primary-100 text-white font-semibold'
                : 'bg-dark-50 border border-stroke text-white hover:border-primary-100 hover:bg-dark-50/80'
            }`}
          >
            {category.label}
          </button>
        ))}
      </div>
    </div>
  )
}
