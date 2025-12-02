import React, { useState } from 'react'
import { navItemsExternal, navItemsOnsite } from '../constants/index.js'
import { Menu, X } from 'lucide-react'
import { TopNavLinks } from '../components/TopNavLinks.jsx'
import { SiteLogo } from '../components/SiteLogo.jsx'
import { Button } from '../components/Button.jsx'

export const TopNav = () => {
  const [mobileNavOpen, setMobileNavOpen] = useState(false)
  const toggleMobileNav = () => {
    setMobileNavOpen(!mobileNavOpen)
  }

  const handleScroll = (event, targetId) => {
    event.preventDefault()
    const targetElement = document.getElementById(targetId)
    if (targetElement) {
      const offsetTop = targetElement.offsetTop - 80
      window.scrollTo({
        top: offsetTop,
        behavior: 'smooth',
      })
    }
    setMobileNavOpen(false)
  }

  return (
    <nav className="w-full top-10 py-3 backdrop-blur-lg border-b border-neutral-700/80">
      <div className="container px-4 md:w-full md:px-0 lg:px-4 mx-auto relative text-sm">
        <div className="flex justify-between items-center">
          <SiteLogo />
          <div className="hidden xl:flex justify-between items-center md:text-sm lg:text-base xl:text-lg space-x-12">
            <TopNavLinks links={navItemsOnsite} handleScroll={handleScroll} />
            <TopNavLinks links={navItemsExternal} />
          </div>
          <div
            className="hidden xl:flex xl:text-lg justify-center space-x-6 
                    items-center"
          >
            <Button
              href="https://playground.kyverno.io/"
              variant="secondary"
              size="large"
            >
              Playground
            </Button>
            <Button
              href="https://kyverno.io/support/"
              variant="primary"
              size="large"
            >
              Support
            </Button>
          </div>
          <div className="xl:hidden flex flex-col justify-end">
            <button onClick={toggleMobileNav}>
              {mobileNavOpen ? <X /> : <Menu />}
            </button>
          </div>
        </div>
        {mobileNavOpen && (
          <div
            className="fixed right-0 z-20 bg-dark-50 w-full p-12 flex 
                    flex-col justify-center items-center space-y-6 lg:hidden mt-3"
          >
            <TopNavLinks links={navItemsOnsite} handleScroll={handleScroll} />
            <TopNavLinks links={navItemsExternal} />
            <div className="xl:hidden flex space-x-2">
              <Button
                href="https://playground.kyverno.io/"
                variant="secondary"
                size="medium"
              >
                Playground
              </Button>
              <Button
                href="https://kyverno.io/support/"
                variant="primary"
                size="medium"
              >
                Support
              </Button>
            </div>
          </div>
        )}
      </div>
    </nav>
  )
}
