import React, { useEffect, useState } from 'react'

import { TopBanner } from '../components/TopBanner.jsx'
import { TopNav } from '../components/TopNav.jsx'

const BANNER_STORAGE_KEY = 'kyverno-banner-closed'

export const Header = () => {
  // Initialize: closed by default, but open on first visit (when localStorage key doesn't exist)
  const [isBannerVisible, setIsBannerVisble] = useState(() => {
    // Check localStorage on initial render
    if (typeof window !== 'undefined') {
      const bannerClosed = localStorage.getItem(BANNER_STORAGE_KEY)
      // If key doesn't exist, it's first visit - show banner (return true)
      // If key exists and is 'true', user closed it - hide banner (return false)
      return bannerClosed !== 'true'
    }
    // Server-side: default to closed
    return false
  })

  const handleCloseBanner = () => {
    setIsBannerVisble(false)
    // Persist the closed state to localStorage
    localStorage.setItem(BANNER_STORAGE_KEY, 'true')
  }

  return (
    <header className="w-full sticky z-50 top-0">
      {isBannerVisible && <TopBanner onClose={handleCloseBanner} client:load />}
      <TopNav />
    </header>
  )
}
