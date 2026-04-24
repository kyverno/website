export const BlogSearch = ({
  searchQuery,
  onSearchChange,
  onTagFilter,
  availableTags = [],
  activeTag = null,
}) => {
  // Get unique tags sorted alphabetically
  const sortedTags = [...new Set(availableTags)].sort()

  return (
    <div className="mb-8">
      {/* Search Bar */}
      <div className="flex flex-col sm:flex-row gap-4 items-stretch sm:items-center mb-4">
        <div className="flex-1 relative">
          <svg
            className="absolute left-4 top-1/2 -translate-y-1/2 text-theme-tertiary pointer-events-none z-10"
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
            placeholder="Search post titles..."
            value={searchQuery || ''}
            onChange={(e) => onSearchChange?.(e.target.value)}
            className="w-full py-3.5 pl-12 pr-4 bg-dark-50 border border-stroke rounded-lg text-theme-primary text-base transition-all focus:outline-none focus:border-primary-100 focus:ring-4 focus:ring-primary-100/10"
          />
        </div>
      </div>

      {/* Tag Tabs */}
      <div className="flex gap-1 border-b border-stroke overflow-x-auto scrollbar-hide -mx-4 px-4 sm:mx-0 sm:px-0">
        <button
          type="button"
          onClick={() => onTagFilter?.('all')}
          className={`px-5 py-3 text-sm font-medium cursor-pointer transition-all whitespace-nowrap relative flex-shrink-0 ${
            activeTag === null
              ? 'text-primary-100 border-b-2 border-primary-100'
              : 'text-theme-tertiary hover:text-theme-secondary'
          }`}
        >
          All
        </button>
        {sortedTags.map((tag) => (
          <button
            type="button"
            key={tag}
            onClick={() => onTagFilter?.(tag)}
            className={`px-5 py-3 text-sm font-medium cursor-pointer transition-all whitespace-nowrap relative flex-shrink-0 ${
              activeTag === tag
                ? 'text-primary-100 border-b-2 border-primary-100'
                : 'text-theme-tertiary hover:text-theme-secondary'
            }`}
          >
            {tag}
          </button>
        ))}
      </div>
    </div>
  )
}
