/**
 * Format the UTC date as a YYYY/MM/DD path, independent of the build timezone.
 */
export function formatDatePath(date: Date | string | undefined): string {
  if (!date) return ''
  const d = typeof date === 'string' ? new Date(date) : date
  const year = d.getUTCFullYear()
  const month = String(d.getUTCMonth() + 1).padStart(2, '0')
  const day = String(d.getUTCDate()).padStart(2, '0')
  return `${year}/${month}/${day}`
}
