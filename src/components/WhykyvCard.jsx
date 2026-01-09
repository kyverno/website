import React from 'react'
import { twMerge } from 'tailwind-merge'

export const WhykyvCard = ({ card, color }) => {
  return (
    <div
      key={card.title}
      className="bg-dark-50 p-6 rounded-2xl border border-stroke flex flex-col space-y-4 w-full h-full min-h-full items-start transition-all duration-200 ease-in-out hover:border-primary-100/50 hover:shadow-lg hover:shadow-primary-100/10"
    >
      <div className="flex items-center gap-3 flex-wrap">
        <span
          className={twMerge(
            'w-10 h-10 p-2 rounded-md flex justify-center items-center flex-shrink-0',
            color.bg,
          )}
        >
          <card.icon className={twMerge('w-6 h-6', color.text)} />
        </span>
        <h3
          className={twMerge(
            'text-lg font-bold rounded-full border px-3 py-1 whitespace-nowrap',
            color.bg,
            color.text,
          )}
        >
          {card.title}
        </h3>
      </div>
      <p className="text-base leading-relaxed text-white/90 text-left transition-colors duration-200 flex-grow">
        {card.desc1} {card.desc2}
      </p>
    </div>
  )
}
