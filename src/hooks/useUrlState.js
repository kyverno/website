import { useEffect, useRef, useState } from 'react'

/**
 * Like useState, but syncs the value to/from a URL query param.
 * SSG-safe: window/history are accessed only inside useEffect (client-only).
 * Follows the VersionDropdown.jsx pattern for client-side state restore.
 *
 * @param {string} key - URL query param name (e.g. 'q', 'category')
 * @param {string|string[]} defaultValue - value used on SSR and initial CSR render
 * @returns {[string|string[], Function]} - [value, setValue] identical to useState
 */
export function useUrlState(key, defaultValue) {
  const isArray = Array.isArray(defaultValue)
  const [value, setValue] = useState(defaultValue)
  const hasMounted = useRef(false)

  // On mount: read URL and restore state (client-only, never runs on SSR)
  useEffect(() => {
    if (typeof window === 'undefined') return
    const params = new URLSearchParams(window.location.search)
    const raw = params.get(key)
    if (raw !== null) {
      setValue(isArray ? (raw ? raw.split(',') : []) : raw)
    }
    hasMounted.current = true
  }, []) // eslint-disable-line react-hooks/exhaustive-deps

  // On state change: write back to URL via replaceState (not pushState,
  // so the back button still navigates away from /policies/ rather than
  // stepping through every filter combination)
  useEffect(() => {
    if (typeof window === 'undefined' || !hasMounted.current) return
    const params = new URLSearchParams(window.location.search)
    const isEmpty = isArray ? value.length === 0 : !value
    if (isEmpty) {
      params.delete(key)
    } else {
      params.set(key, isArray ? value.join(',') : value)
    }
    const qs = params.toString()
    history.replaceState(
      null,
      '',
      qs ? `${window.location.pathname}?${qs}` : window.location.pathname,
    )
  }, [value]) // eslint-disable-line react-hooks/exhaustive-deps

  return [value, setValue]
}
