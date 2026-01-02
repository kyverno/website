import { Highlight } from 'prism-react-renderer'
import { codingThemes } from '../../constants'

export const YamlCodeBlock = ({ code }) => {
  if (!code) return null

  return (
    <div className="w-full min-w-0 max-w-full rounded-xl overflow-hidden">
      <Highlight language="yml" theme={codingThemes.dark} code={code.trim()}>
        {({ className, style, tokens, getLineProps, getTokenProps }) => (
          <pre
            className={`${className} p-6 text-sm leading-relaxed overflow-x-auto max-w-full`}
            style={{
              ...style,
              tabSize: 2,
              backgroundColor: 'rgba(0, 0, 0, 0.3)',
              border: '1px solid rgba(255, 255, 255, 0.1)',
              borderRadius: '0.75rem',
              margin: 0,
              maxWidth: '100%',
              width: '100%',
            }}
          >
            <code
              style={{ display: 'block', whiteSpace: 'pre', maxWidth: '100%' }}
            >
              {tokens.map((line, i) => (
                <div
                  key={i}
                  {...getLineProps({ line, key: i })}
                  style={{ whiteSpace: 'pre' }}
                >
                  {line.map((token, key) => (
                    <span key={key} {...getTokenProps({ token, key })} />
                  ))}
                </div>
              ))}
            </code>
          </pre>
        )}
      </Highlight>
    </div>
  )
}
