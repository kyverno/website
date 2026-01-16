import { Check, Copy } from 'lucide-react'
import React, { useState } from 'react'

import { Button } from './Button'
import { YamlCodeBlock } from './YamlCodeBlock'
import { twMerge } from 'tailwind-merge'

export const PolicyTabPanel = ({ tabs }) => {
  const [activeTab, setActiveTab] = useState(tabs[0]?.id || '')
  const [copied, setCopied] = useState(false)

  const activeTabData = tabs.find((tab) => tab.id === activeTab) || tabs[0]

  const handleCopy = async () => {
    try {
      await navigator.clipboard.writeText(activeTabData?.policy || '')
      setCopied(true)
      setTimeout(() => setCopied(false), 2000)
    } catch (err) {
      console.error('Failed to copy:', err)
    }
  }

  return (
    <div className="w-full max-w-6xl mx-auto">
      <div className="flex flex-col lg:flex-row gap-6">
        {/* Left Sidebar - Tabs */}
        <div className="w-full lg:w-80 flex-shrink-0">
          <div className="flex flex-row lg:flex-col gap-2 overflow-x-auto lg:overflow-x-visible pb-2 lg:pb-0">
            {tabs.map((tab) => (
              <button
                key={tab.id}
                onClick={() => setActiveTab(tab.id)}
                className={twMerge(
                  'px-4 py-2 rounded-lg font-medium text-base transition-all whitespace-nowrap text-left',
                  activeTab === tab.id
                    ? 'bg-primary-100 text-white shadow-lg'
                    : 'bg-dark-50 text-theme-secondary hover:text-theme-primary hover:bg-dark-100 border border-stroke',
                )}
              >
                {tab.label}
              </button>
            ))}
          </div>
        </div>

        {/* Right Content Area */}
        <div className="flex-1 min-w-0">
          {/* Code Display */}
          <div className="bg-dark-50 rounded-2xl border border-stroke overflow-hidden">
            {/* Code Content */}
            <div className="h-[531px] overflow-hidden">
              <YamlCodeBlock
                code={activeTabData?.policy || ''}
                showCopyButton={false}
                className="h-full"
                preClassName="h-full overflow-y-auto thin-scrollbar text-xs sm:text-sm"
              />
            </div>

            {/* Footer with Copy and Learn More buttons */}
            <div className="flex items-center justify-between p-4 border-t border-stroke bg-dark-100">
              <div className="flex items-center gap-3">
                <button
                  onClick={handleCopy}
                  className="flex items-center gap-2 px-3 py-1.5 rounded-md bg-dark-50 hover:bg-dark-200 text-theme-secondary hover:text-theme-primary text-sm font-medium transition-all border border-stroke"
                >
                  {copied ? (
                    <>
                      <Check className="w-4 h-4" />
                      <span>Copied!</span>
                    </>
                  ) : (
                    <>
                      <Copy className="w-4 h-4" />
                      <span>Copy YAML</span>
                    </>
                  )}
                </button>
              </div>
              <div className="flex items-center gap-3">
                <Button
                  href="/policies/"
                  variant="secondary"
                  size="small"
                  className="text-sm min-w-0 px-3"
                >
                  Explore More Policies
                </Button>
                {activeTabData?.learnMore && (
                  <Button
                    href={activeTabData.learnMore}
                    variant="primary"
                    size="small"
                    className="text-sm min-w-0 px-3"
                  >
                    Learn More
                  </Button>
                )}
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
