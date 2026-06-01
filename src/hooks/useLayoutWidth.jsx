import { useEffect, useRef, useState } from 'react'

const STORAGE_KEY = 'kyverno-layout-width'

export const useLayoutWidth = () => {
  const [layoutWidth, setLayoutWidthState] = useState('fixed')
  const [mounted, setMounted] = useState(false)
  const layoutWidthRef = useRef(layoutWidth)

  const getStoredWidth = () => {
    if (typeof window === 'undefined') return 'fixed'
    const stored = localStorage.getItem(STORAGE_KEY)
    if (stored === 'fluid') return 'fluid'
    return 'fixed'
  }

  const applyWidth = (width) => {
    if (typeof window !== 'undefined') {
      if (width === 'fluid') {
        document.documentElement.setAttribute('data-layout-width', 'fluid')
      } else {
        document.documentElement.removeAttribute('data-layout-width')
      }
    }
  }

  const setLayoutWidth = (newWidth) => {
    const validWidth = newWidth === 'fluid' ? 'fluid' : 'fixed'
    setLayoutWidthState(validWidth)
    layoutWidthRef.current = validWidth
    if (typeof window !== 'undefined') {
      localStorage.setItem(STORAGE_KEY, validWidth)
      applyWidth(validWidth)
    }
  }

  const toggleLayoutWidth = () => {
    setLayoutWidth(layoutWidth === 'fixed' ? 'fluid' : 'fixed')
  }

  useEffect(() => {
    setMounted(true)

    const initialWidth = getStoredWidth()
    setLayoutWidthState(initialWidth)
    layoutWidthRef.current = initialWidth
    applyWidth(initialWidth)

    if (!localStorage.getItem(STORAGE_KEY)) {
      localStorage.setItem(STORAGE_KEY, 'fixed')
    }

    const observer = new MutationObserver(() => {
      const hasAttr = document.documentElement.hasAttribute('data-layout-width')
      const currentWidth = hasAttr ? 'fluid' : 'fixed'
      if (currentWidth !== layoutWidthRef.current) {
        setLayoutWidthState(currentWidth)
        layoutWidthRef.current = currentWidth
        if (typeof window !== 'undefined') {
          localStorage.setItem(STORAGE_KEY, currentWidth)
        }
      }
    })

    observer.observe(document.documentElement, {
      attributes: true,
      attributeFilter: ['data-layout-width'],
    })

    const handleStorageChange = (e) => {
      if (e.key === STORAGE_KEY) {
        const newWidth = e.newValue === 'fluid' ? 'fluid' : 'fixed'
        setLayoutWidthState(newWidth)
        layoutWidthRef.current = newWidth
        applyWidth(newWidth)
      }
    }

    window.addEventListener('storage', handleStorageChange)

    return () => {
      observer.disconnect()
      window.removeEventListener('storage', handleStorageChange)
    }
  }, [])

  return {
    layoutWidth,
    toggleLayoutWidth,
    setLayoutWidth,
    mounted,
  }
}
