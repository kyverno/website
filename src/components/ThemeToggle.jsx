import { Monitor, Moon, Sun } from 'lucide-react'

import React from 'react'
import { useTheme } from '../hooks/useTheme'

export const ThemeToggle = () => {
  const { theme, mode, toggleTheme, mounted } = useTheme()

  // Prevent hydration mismatch by not rendering until mounted
  if (!mounted) {
    return (
      <button
        className="p-2 rounded-lg border border-stroke text-theme-primary hover:bg-dark-50 transition-colors duration-200"
        aria-label="Toggle theme"
        disabled
      >
        <Moon className="w-5 h-5" />
      </button>
    )
  }

  const getIcon = () => {
    if (mode === 'auto') {
      return <Monitor className="w-5 h-5" />
    }
    // Show current theme: Sun for light, Moon for dark
    return mode === 'light' ? (
      <Sun className="w-5 h-5" />
    ) : (
      <Moon className="w-5 h-5" />
    )
  }

  const getAriaLabel = () => {
    if (mode === 'light') {
      return 'Switch to dark mode'
    }
    if (mode === 'dark') {
      return 'Switch to auto mode (follow system)'
    }
    return 'Switch to light mode'
  }

  return (
    <button
      onClick={toggleTheme}
      className="p-2 rounded-lg border border-stroke text-theme-primary hover:bg-dark-50 transition-colors duration-200 focus:outline-none focus:ring-2 focus:ring-primary-100 focus:ring-offset-2"
      aria-label={getAriaLabel()}
      title={getAriaLabel()}
    >
      {getIcon()}
    </button>
  )
}
