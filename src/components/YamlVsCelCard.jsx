import { Highlight } from 'prism-react-renderer'
import { codingThemes } from '../constants'
import { twMerge } from 'tailwind-merge'

export const YamlVsCelCard = ({ card, color }) => (
  <div className="w-[80%] sm:w-1/3 lg:w-1/2 bg-dark-50 rounded-2xl flex flex-col h-150">
    <div
      className={twMerge(
        'p-4 text-sm md:text-[16px] text-center text-dark-100 rounded-tl-2xl rounded-tr-2xl flex items-center justify-start space-x-2',
        color.bg,
      )}
    >
      <card.icon className="w-4 h-4" />
      <span className="font-bold">{card.title}</span>
    </div>
    <div className="flex-1 w-full overflow-hidden">
      <Highlight language="yaml" theme={codingThemes.dark} code={card.content}>
        {({ className, style, tokens, getLineProps, getTokenProps }) => (
          <pre
            className={`${className} w-full h-full p-6 text-[10px] sm:text-sm leading-relaxed rounded-bl-2xl rounded-br-2xl overflow-y-auto flex flex-col justify-start`}
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
  </div>
)
