/**
 * Shared utility functions for policy components
 */

/**
 * Formats category labels for display
 */
export const formatCategoryLabel = (category: string): string => {
  const knownLabels: Record<string, string> = {
    verifyImages: 'Verify Images',
    validate: 'Validate',
    mutate: 'Mutate',
    generate: 'Generate',
    cleanup: 'Cleanup',
  }

  if (category && knownLabels[category]) {
    return knownLabels[category]
  }

  // Fallback: format camelCase/PascalCase to Title Case
  if (!category) return ''
  return category
    .replace(/([A-Z])/g, ' $1')
    .replace(/^./, (str: string) => str.toUpperCase())
    .trim()
}

/**
 * Formats severity labels for display
 */
export const formatSeverityLabel = (severity: string): string => {
  const knownLabels: Record<string, string> = {
    high: 'High',
    medium: 'Medium',
    low: 'Low',
  }

  if (severity && knownLabels[severity]) {
    return knownLabels[severity]
  }

  // Fallback: capitalize first letter
  if (!severity) return ''
  return severity.charAt(0).toUpperCase() + severity.slice(1)
}

/**
 * Gets category color classes for styling
 */
export const getCategoryColor = (category: string): string => {
  const knownColors: Record<string, string> = {
    verifyImages: 'bg-cyan-500/15 text-cyan-400 border-cyan-500/30',
    validate: 'bg-primary-100/15 text-primary-100 border-primary-100/30',
    mutate: 'bg-purple-500/15 text-purple-400 border-purple-500/30',
    generate: 'bg-emerald-500/15 text-emerald-400 border-emerald-500/30',
    cleanup: 'bg-orange-500/15 text-orange-400 border-orange-500/30',
  }

  if (category && knownColors[category]) {
    return knownColors[category]
  }
  return 'bg-stroke/15 text-white/80 border-stroke/30'
}

/**
 * Gets severity color classes for styling
 */
export const getSeverityColor = (severity: string): string => {
  const knownColors: Record<string, string> = {
    high: 'bg-red-500/10 text-red-400 border-red-500/20',
    medium: 'bg-yellow-500/10 text-yellow-400 border-yellow-500/20',
    low: 'bg-green-500/10 text-green-400 border-green-500/20',
  }

  if (severity && knownColors[severity]) {
    return knownColors[severity]
  }
  return 'bg-stroke/10 text-white/60 border-stroke/20'
}

/**
 * Gets severity order for sorting (lower number = higher priority)
 */
export const getSeverityOrder = (severity: string): number => {
  const knownOrder: Record<string, number> = { high: 0, medium: 1, low: 2 }
  if (severity && knownOrder[severity] !== undefined) {
    return knownOrder[severity]
  }
  return 99
}
