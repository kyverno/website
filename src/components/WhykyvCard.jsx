import React from 'react'
import { twMerge } from 'tailwind-merge'
import { useTheme } from '../hooks/useTheme'

export const WhykyvCard = ({ card, color }) => {
  const { theme } = useTheme()
  const isLight = theme === 'light'

  // Use darker blue shades in light mode
  const bubbleBg = isLight ? 'bg-primary-75/30' : color.bg
  const bubbleText = isLight ? 'text-primary-75' : color.text

  return (
    <div
      key={card.title}
      className="bg-dark-50 p-6 rounded-2xl border border-stroke flex flex-col space-y-4 w-full h-full min-h-full items-start transition-all duration-200 ease-in-out hover:border-primary-100/50 hover:shadow-lg hover:shadow-primary-100/10"
    >
      <div className="flex items-center gap-3 flex-wrap">
        <span
          className={twMerge(
            'w-10 h-10 p-2 rounded-md flex justify-center items-center flex-shrink-0',
            bubbleBg,
          )}
        >
          <card.icon className={twMerge('w-6 h-6', bubbleText)} />
        </span>
        <h3
          className={twMerge(
            'text-lg font-bold rounded-full border px-3 py-1 whitespace-nowrap',
            bubbleBg,
            bubbleText,
          )}
        >
          {card.title}
        </h3>
      </div>
      <p className="text-base leading-relaxed text-theme-secondary text-left transition-colors duration-200 flex-grow">
        {card.desc1} {card.desc2}
      </p>
    </div>
  )
}
