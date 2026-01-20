import { useEffect, useRef, useState } from 'react'

const STORAGE_KEY = 'starlight-theme'

/**
 * Get system preference for color scheme
 */
const getSystemPreference = () => {
  if (typeof window === 'undefined') return 'dark'
  return window.matchMedia('(prefers-color-scheme: dark)').matches
    ? 'dark'
    : 'light'
}

/**
 * Hook to manage theme based on Starlight's starlight-theme localStorage variable
 * @returns {Object} { theme, mode, toggleTheme, setTheme, mounted }
 *   - theme: the effective theme ('light' or 'dark')
 *   - mode: the current mode ('light', 'dark', or 'auto')
 *   - toggleTheme: cycles through light -> dark -> auto
 *   - setTheme: sets a specific theme mode
 *   - mounted: whether the component has mounted on the client
 */
export const useTheme = () => {
  const [mode, setModeState] = useState('dark') // 'light', 'dark', or 'auto'
  const [mounted, setMounted] = useState(false)
  const modeRef = useRef(mode)

  // Get the effective theme based on mode
  const getEffectiveTheme = () => {
    if (mode === 'auto') {
      return getSystemPreference()
    }
    return mode
  }

  // Get current mode from localStorage
  const getMode = () => {
    if (typeof window === 'undefined') return 'dark'

    // Check Starlight's localStorage key
    const stored = localStorage.getItem(STORAGE_KEY)
    if (stored === 'light' || stored === 'dark') {
      return stored
    }

    // Empty or missing means auto mode
    if (!stored || stored === '') {
      return 'auto'
    }

    // Fallback to data-theme attribute
    const docTheme = document.documentElement.getAttribute('data-theme')
    if (docTheme === 'light' || docTheme === 'dark') {
      return docTheme
    }

    // Default to dark
    return 'dark'
  }

  // Update theme mode in localStorage and on document
  const setTheme = (newMode) => {
    const validMode =
      newMode === 'light' ? 'light' : newMode === 'dark' ? 'dark' : 'auto'
    setModeState(validMode)

    if (typeof window !== 'undefined') {
      if (validMode === 'auto') {
        // Clear localStorage for auto mode
        localStorage.setItem(STORAGE_KEY, '')
        // Apply system preference
        const systemTheme = getSystemPreference()
        document.documentElement.setAttribute('data-theme', systemTheme)
      } else {
        localStorage.setItem(STORAGE_KEY, validMode)
        document.documentElement.setAttribute('data-theme', validMode)
      }
    }
  }

  // Toggle between light -> dark -> auto -> light
  const toggleTheme = () => {
    if (mode === 'light') {
      setTheme('dark')
    } else if (mode === 'dark') {
      setTheme('auto')
    } else {
      // auto -> light
      setTheme('light')
    }
  }

  useEffect(() => {
    // Only run on client
    setMounted(true)

    // Get initial mode
    const initialMode = getMode()
    setModeState(initialMode)
    modeRef.current = initialMode

    // Apply effective theme to document
    if (typeof window !== 'undefined') {
      const effectiveTheme =
        initialMode === 'auto' ? getSystemPreference() : initialMode
      document.documentElement.setAttribute('data-theme', effectiveTheme)

      // Sync localStorage if not set
      if (!localStorage.getItem(STORAGE_KEY) && initialMode !== 'auto') {
        localStorage.setItem(STORAGE_KEY, initialMode)
      }
    }

    // Watch for theme changes from Starlight's theme selector or other sources
    const observer = new MutationObserver(() => {
      const currentMode = getMode()
      if (currentMode !== modeRef.current) {
        setModeState(currentMode)
        modeRef.current = currentMode
        // Sync localStorage if changed externally
        if (typeof window !== 'undefined') {
          if (currentMode === 'auto') {
            localStorage.setItem(STORAGE_KEY, '')
          } else {
            localStorage.setItem(STORAGE_KEY, currentMode)
          }
        }
      }
    })

    observer.observe(document.documentElement, {
      attributes: true,
      attributeFilter: ['data-theme'],
    })

    // Listen for storage changes (from other tabs or Starlight's theme selector)
    const handleStorageChange = (e) => {
      if (e.key === STORAGE_KEY) {
        const newMode =
          e.newValue === 'light' || e.newValue === 'dark' ? e.newValue : 'auto'
        setModeState(newMode)
        modeRef.current = newMode
        if (typeof window !== 'undefined') {
          const effectiveTheme =
            newMode === 'auto' ? getSystemPreference() : newMode
          document.documentElement.setAttribute('data-theme', effectiveTheme)
        }
      }
    }

    // Listen for system preference changes (only relevant when in auto mode)
    const mediaQuery = window.matchMedia('(prefers-color-scheme: dark)')
    const handleSystemThemeChange = () => {
      if (modeRef.current === 'auto') {
        const systemTheme = getSystemPreference()
        document.documentElement.setAttribute('data-theme', systemTheme)
      }
    }

    window.addEventListener('storage', handleStorageChange)
    mediaQuery.addEventListener('change', handleSystemThemeChange)

    return () => {
      observer.disconnect()
      window.removeEventListener('storage', handleStorageChange)
      mediaQuery.removeEventListener('change', handleSystemThemeChange)
    }
  }, [mode])

  // Update ref when mode changes
  useEffect(() => {
    modeRef.current = mode
  }, [mode])

  const theme = getEffectiveTheme()

  return {
    theme, // Effective theme (light or dark)
    mode, // Current mode (light, dark, or auto)
    toggleTheme,
    setTheme,
    mounted,
  }
}
