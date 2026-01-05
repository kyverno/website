import { Check, Copy } from 'lucide-react'

import { Highlight } from 'prism-react-renderer'
import { codingThemes } from '../constants'
import { useState } from 'react'

export const YamlCodeBlock = ({
  code,
  showCopyButton = true,
  header = null,
  headerColor = null,
  className = '',
  preClassName = '',
}) => {
  const [copyState, setCopyState] = useState('idle')

  if (!code) return null

  const handleCopy = async () => {
    try {
      await navigator.clipboard.writeText(code.trim())
      setCopyState('success')
      setTimeout(() => setCopyState('idle'), 2000)
    } catch (error) {
      console.error('Failed to copy YAML:', error)
      setCopyState('error')
      setTimeout(() => setCopyState('idle'), 2000)
    }
  }

  // If header is provided, render as card (YamlVsCelCard style)
  if (header) {
    return (
      <div
        className={`bg-dark-50 rounded-2xl flex flex-col h-[600px] ${className}`}
      >
        {/* Header */}
        <div
          className={`p-4 text-sm md:text-[16px] text-center text-white rounded-tl-2xl rounded-tr-2xl flex items-center justify-start space-x-2 ${
            headerColor || 'bg-primary-100'
          }`}
        >
          {header.icon && <header.icon className="w-4 h-4" />}
          <span className="font-bold">{header.title}</span>
        </div>
        {/* Code Block */}
        <div className="flex-1 w-full overflow-hidden rounded-bl-2xl rounded-br-2xl">
          <Highlight language="yaml" theme={codingThemes.dark} code={code}>
            {({ className, style, tokens, getLineProps, getTokenProps }) => {
              // Ensure we use the theme's background color consistently
              const themeBg =
                codingThemes.dark.plain?.backgroundColor ||
                style?.backgroundColor
              return (
                <pre
                  className={`${className} prism-code language-yaml w-full h-full p-6 text-[10px] sm:text-sm leading-relaxed rounded-bl-2xl rounded-br-2xl overflow-y-auto flex flex-col justify-start  ${preClassName}`}
                  style={{
                    ...style,
                    tabSize: 2,
                    margin: 0,
                    padding: style.padding || '1.5rem',
                    borderRadius: '0 0 1rem 1rem',
                    backgroundColor: themeBg,
                  }}
                >
                  {tokens.map((line, i) => {
                    const lineProps = getLineProps({ line, key: i })
                    const { key: lineKey, ...restLineProps } = lineProps
                    return (
                      <div key={lineKey} {...restLineProps}>
                        {line.map((token, tokenKey) => {
                          const tokenProps = getTokenProps({
                            token,
                            key: tokenKey,
                          })
                          const { key: tokenKeyProp, ...restTokenProps } =
                            tokenProps
                          return <span key={tokenKeyProp} {...restTokenProps} />
                        })}
                      </div>
                    )
                  })}
                </pre>
              )
            }}
          </Highlight>
        </div>
      </div>
    )
  }

  // Default: render as standalone code block with optional copy button
  return (
    <div className={`w-full min-w-0 max-w-full relative ${className}`}>
      {/* Floating Copy Button */}
      {showCopyButton && (
        <button
          onClick={handleCopy}
          className={`absolute top-4 right-4 z-10 p-2 rounded-lg border transition-all ${
            copyState === 'success'
              ? 'bg-green-500/20 border-green-500/50 text-green-400'
              : copyState === 'error'
                ? 'bg-red-500/20 border-red-500/50 text-red-400'
                : 'bg-gray-800/80 border-gray-700 hover:border-gray-600 text-gray-400 hover:text-white backdrop-blur-sm'
          }`}
          title="Copy YAML"
        >
          {copyState === 'success' ? <Check size={16} /> : <Copy size={16} />}
        </button>
      )}

      <Highlight language="yaml" theme={codingThemes.dark} code={code}>
        {({ className, style, tokens, getLineProps, getTokenProps }) => {
          return (
            <pre
              className={`${className} w-full h-full p-6 text-[10px] sm:text-sm leading-relaxed rounded-bl-2xl rounded-br-2xl overflow-y-auto flex flex-col justify-start ${preClassName}`}
              style={{
                ...style,
                tabSize: 2,
                whiteSpace: 'pre',
              }}
            >
              {tokens.map((line, i) => {
                const lineProps = getLineProps({ line, key: i })
                const { key: lineKey, ...restLineProps } = lineProps
                return (
                  <div key={lineKey} {...restLineProps}>
                    {line.map((token, tokenKey) => {
                      const tokenProps = getTokenProps({ token, key: tokenKey })
                      const { key: tokenKeyProp, ...restTokenProps } =
                        tokenProps
                      console.log({ tokenKey, restTokenProps, tokenProps })
                      return <span key={tokenKeyProp} {...restTokenProps} />
                    })}
                  </div>
                )
              })}
            </pre>
          )
        }}
      </Highlight>
    </div>
  )
}
