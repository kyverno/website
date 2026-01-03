import React, { useState } from 'react'
import { Highlight } from 'prism-react-renderer'
import { Copy, Check } from 'lucide-react'
import { codingThemes } from '../constants'
import { twMerge } from 'tailwind-merge'
import { Button } from './Button'

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
        <div className="w-full lg:w-64 flex-shrink-0">
          <div className="flex flex-row lg:flex-col gap-2 overflow-x-auto lg:overflow-x-visible pb-2 lg:pb-0">
            {tabs.map((tab) => (
              <button
                key={tab.id}
                onClick={() => setActiveTab(tab.id)}
                className={twMerge(
                  'px-4 py-2 rounded-lg font-medium text-sm transition-all whitespace-nowrap text-left',
                  activeTab === tab.id
                    ? 'bg-primary-100 text-white shadow-lg'
                    : 'bg-dark-50 text-white/70 hover:text-white hover:bg-dark-100 border border-stroke',
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
            <div className="p-4 sm:p-6 overflow-x-auto max-h-[600px] overflow-y-auto">
              <Highlight
                language="yaml"
                theme={codingThemes.dark}
                code={activeTabData?.policy || ''}
              >
                {({
                  className,
                  style,
                  tokens,
                  getLineProps,
                  getTokenProps,
                }) => (
                  <pre
                    className={twMerge(
                      className,
                      'text-xs sm:text-sm leading-relaxed m-0',
                    )}
                    style={{
                      ...style,
                      tabSize: 2,
                    }}
                  >
                    {tokens.map((line, i) => (
                      <div key={i} {...getLineProps({ line, key: i })}>
                        {line.map((token, key) => (
                          <span key={key} {...getTokenProps({ token, key })} />
                        ))}
                      </div>
                    ))}
                  </pre>
                )}
              </Highlight>
            </div>

            {/* Footer with Copy and Learn More buttons */}
            <div className="flex items-center justify-between p-4 border-t border-stroke bg-dark-100">
              <div className="flex items-center gap-3">
                <button
                  onClick={handleCopy}
                  className="flex items-center gap-2 px-3 py-1.5 rounded-md bg-dark-50 hover:bg-dark-200 text-white/80 hover:text-white text-sm font-medium transition-all border border-stroke"
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
                  href="/policies"
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
