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
    verifyImages: 'text-cyan-400 bg-cyan-950/50 border-cyan-900/50',
    validate: 'text-blue-400 bg-blue-950/50 border-blue-900/50',
    mutate: 'text-purple-400 bg-purple-950/50 border-purple-900/50',
    generate: 'text-emerald-400 bg-emerald-950/50 border-emerald-900/50',
    cleanup: 'text-orange-400 bg-orange-950/50 border-orange-900/50',
  }

  if (category && knownColors[category]) {
    return knownColors[category]
  }
  return 'text-gray-400 bg-gray-950/50 border-gray-900/50'
}

/**
 * Gets severity color classes for styling
 */
export const getSeverityColor = (severity: string): string => {
  const knownColors: Record<string, string> = {
    high: 'text-red-400 bg-red-950/50 border-red-900/50',
    medium: 'text-yellow-400 bg-yellow-950/50 border-yellow-900/50',
    low: 'text-green-400 bg-green-950/50 border-green-900/50',
  }

  if (severity && knownColors[severity]) {
    return knownColors[severity]
  }
  return 'text-gray-400 bg-gray-950/50 border-gray-900/50'
}

/** Number of days after creation a policy is considered "new" */
export const NEW_POLICY_DAYS = 90

/**
 * Returns true if the policy was created within NEW_POLICY_DAYS (e.g. for "New" badge).
 */
export const isPolicyNew = (createdAt: Date | string | undefined): boolean => {
  if (!createdAt) return false
  const created =
    typeof createdAt === 'string' ? new Date(createdAt) : createdAt
  const daysSinceCreation =
    (Date.now() - created.getTime()) / (1000 * 60 * 60 * 24)
  return daysSinceCreation <= NEW_POLICY_DAYS
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
