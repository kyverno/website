import { useEffect, useMemo, useState } from 'react'

import { BlogSearch } from './BlogSearch'

export const BlogBrowser = ({ posts }) => {
  const [searchQuery, setSearchQuery] = useState('')
  const [activeTag, setActiveTag] = useState(null)

  // Extract all unique tags from posts
  const allTags = useMemo(() => {
    const tagSet = new Set()
    posts.forEach((post) => {
      if (post.tags && Array.isArray(post.tags)) {
        post.tags.forEach((tag) => tagSet.add(tag))
      }
    })
    return Array.from(tagSet)
  }, [posts])

  // Filter posts based on search query and active tag
  const filteredPosts = useMemo(() => {
    return posts.filter((post) => {
      // Search filter - check title, excerpt, and tags
      const searchLower = searchQuery.toLowerCase()
      const matchesSearch =
        !searchQuery ||
        (post.title || '').toLowerCase().includes(searchLower) ||
        (post.excerpt || '').toLowerCase().includes(searchLower) ||
        (post.tags || []).some((tag) => tag.toLowerCase().includes(searchLower))

      // Tag filter - single active tag (tab-style)
      const matchesTag =
        !activeTag ||
        activeTag === 'all' ||
        (post.tags || []).some(
          (tag) => tag.toLowerCase() === activeTag.toLowerCase(),
        )

      return matchesSearch && matchesTag
    })
  }, [posts, searchQuery, activeTag])

  // Handle tag filter toggle (tab-style: single selection)
  const handleTagFilter = (tag) => {
    if (tag === 'all') {
      setActiveTag(null)
    } else {
      // Toggle: if clicking the same tag, deselect it (show all)
      setActiveTag((prev) => (prev === tag ? null : tag))
    }
  }

  // Clear search when component unmounts or when needed
  useEffect(() => {
    return () => {
      setSearchQuery('')
      setActiveTag(null)
    }
  }, [])

  return (
    <div>
      <BlogSearch
        searchQuery={searchQuery}
        onSearchChange={setSearchQuery}
        onTagFilter={handleTagFilter}
        activeTag={activeTag}
        availableTags={allTags}
      />

      {/* Results count */}
      {filteredPosts.length !== posts.length && (
        <div class="mb-6 text-gray-400 text-sm">
          Showing {filteredPosts.length} of {posts.length} posts
        </div>
      )}

      {/* Filtered posts grid */}
      {filteredPosts.length > 0 ? (
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
          {filteredPosts.map((post, index) => {
            const isExternal = !!post.externalURL

            return (
              <article key={index} class="group">
                {isExternal ? (
                  <a
                    href={post.url}
                    target="_blank"
                    rel="noopener noreferrer"
                    class="block h-full"
                  >
                    <div class="h-full flex flex-col bg-gray-800/20 rounded-xl overflow-hidden border border-gray-700/30 hover:border-primary-100/50 hover:bg-gray-800/40 transition-all duration-300 hover:shadow-xl hover:shadow-primary-100/20 hover:-translate-y-1">
                      {post.image && (
                        <div class="w-full h-48 overflow-hidden bg-gray-700/30">
                          <img
                            src={post.image}
                            alt={post.title}
                            class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
                          />
                        </div>
                      )}
                      <div class="flex flex-col flex-grow p-6">
                        <div class="flex flex-col gap-1 mb-3">
                          {post.date && (
                            <time
                              class="text-sm text-gray-400"
                              datetime={
                                typeof post.date === 'string'
                                  ? post.date
                                  : post.date.toISOString()
                              }
                            >
                              {post.formattedDate}
                            </time>
                          )}
                          {post.authors && post.authors.length > 0 && (
                            <div class="text-xs text-gray-500">
                              By{' '}
                              {post.authors.map((author, idx) => (
                                <>
                                  {author.name}
                                  {idx < post.authors.length - 1 && ', '}
                                </>
                              ))}
                            </div>
                          )}
                        </div>
                        <h3 class="text-xl md:text-2xl font-bold mb-3 text-white group-hover:text-primary-100 transition-colors line-clamp-2">
                          {post.title}
                        </h3>
                        {post.excerpt && (
                          <p class="text-gray-300 text-sm md:text-base leading-relaxed mb-4 flex-grow line-clamp-3">
                            {post.excerpt}
                          </p>
                        )}
                        <div class="flex flex-wrap gap-2 mt-auto">
                          <span class="px-2.5 py-1 text-xs font-semibold uppercase tracking-wide bg-primary-100/10 text-primary-100 border border-primary-100/20 rounded flex items-center gap-1.5">
                            <span>EXTERNAL</span>
                            <svg
                              class="w-3 h-3"
                              fill="none"
                              stroke="currentColor"
                              stroke-width="2"
                              viewBox="0 0 24 24"
                            >
                              <path
                                stroke-linecap="round"
                                stroke-linejoin="round"
                                d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14"
                              />
                            </svg>
                          </span>
                          {post.tags && post.tags.length > 0 && (
                            <>
                              {post.tags.slice(0, 1).map((tag) => (
                                <span class="px-2.5 py-1 text-xs font-semibold uppercase tracking-wide bg-primary-100/10 text-primary-100 border border-primary-100/20 rounded">
                                  {tag}
                                </span>
                              ))}
                            </>
                          )}
                        </div>
                      </div>
                    </div>
                  </a>
                ) : (
                  <a href={post.url} data-astro-reload class="block h-full">
                    <div class="h-full flex flex-col bg-gray-800/20 rounded-xl overflow-hidden border border-gray-700/30 hover:border-primary-100/50 hover:bg-gray-800/40 transition-all duration-300 hover:shadow-xl hover:shadow-primary-100/20 hover:-translate-y-1">
                      {post.image && (
                        <div class="w-full h-48 overflow-hidden bg-gray-700/30">
                          <img
                            src={post.image}
                            alt={post.title}
                            class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
                          />
                        </div>
                      )}
                      <div class="flex flex-col flex-grow p-6">
                        <div class="flex flex-col gap-1 mb-3">
                          {post.date && (
                            <time
                              class="text-sm text-gray-400"
                              datetime={
                                typeof post.date === 'string'
                                  ? post.date
                                  : post.date.toISOString()
                              }
                            >
                              {post.formattedDate}
                            </time>
                          )}
                          {post.authors && post.authors.length > 0 && (
                            <div class="text-xs text-gray-500">
                              By{' '}
                              {post.authors.map((author, idx) => (
                                <>
                                  {author.name}
                                  {idx < post.authors.length - 1 && ', '}
                                </>
                              ))}
                            </div>
                          )}
                        </div>
                        <h3 class="text-xl md:text-2xl font-bold mb-3 text-white group-hover:text-primary-100 transition-colors line-clamp-2">
                          {post.title}
                        </h3>
                        {post.excerpt && (
                          <p class="text-gray-300 text-sm md:text-base leading-relaxed mb-4 flex-grow line-clamp-3">
                            {post.excerpt}
                          </p>
                        )}
                        {post.tags && post.tags.length > 0 && (
                          <div class="flex flex-wrap gap-2 mt-auto">
                            {post.tags.slice(0, 2).map((tag) => (
                              <span class="px-2.5 py-1 text-xs font-semibold uppercase tracking-wide bg-primary-100/10 text-primary-100 border border-primary-100/20 rounded">
                                {tag}
                              </span>
                            ))}
                          </div>
                        )}
                      </div>
                    </div>
                  </a>
                )}
              </article>
            )
          })}
        </div>
      ) : (
        <div class="text-center py-16">
          <p class="text-gray-400 text-lg">
            No posts found matching your filters.
          </p>
        </div>
      )}
    </div>
  )
}
