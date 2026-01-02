import React from 'react'
import { twMerge } from 'tailwind-merge'

export const WhykyvCard = ({ card, color }) => {
  return (
    <div
      key={card.title}
      className="bg-dark-50 p-4 rounded-2xl border border-stroke flex flex-col space-y-3 w-full md:w-1/3 lg:w-1/3 md:h-56 py-6 items-start"
    >
      <div className="flex items-center gap-3">
        <span
          className={twMerge(
            'w-10 h-10 p-2 rounded-md flex justify-center items-center',
            color.bg,
          )}
        >
          <card.icon className={twMerge('w-6 h-6', color.text)} />
        </span>
        <h3
          className={twMerge(
            'text-lg font-bold rounded-full border px-3',
            color.bg,
            color.text,
          )}
        >
          {card.title}
        </h3>
      </div>
      <p className="text-base leading-relaxed text-white/90 pt-1 max-w-xs text-left">
        {card.desc1} {card.desc2}
      </p>
    </div>
  )
}
