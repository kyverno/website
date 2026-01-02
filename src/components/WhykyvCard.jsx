import React from 'react'
import { twMerge } from 'tailwind-merge'

export const WhykyvCard = ({ card, color }) => {
  return (
    <div
      key={card.title}
      className="bg-dark-50 p-4 rounded-2xl border border-stroke flex flex-col space-y-4 w-full md:w-1/3 xl:w-1/5 md:h-70 py-8 items-start"
    >
      <span
        className={twMerge(
          'w-8 h-8 p-2 rounded-md flex justify-center items-center ml-1 mb-2',
          color.bg,
        )}
      >
        <card.icon className={twMerge('w-4 h-4', color.text)} />
      </span>
      <h3
        className={twMerge(
          'text-md font-bold rounded-full border my-4 px-3 self-start',
          color.bg,
          color.text,
        )}
      >
        {card.title}
      </h3>
      <ul className="text-sm leading-relaxed text-white/90 list-[square] list-inside space-y-2 pt-2 max-w-xs">
        <li>{card.desc1}</li>
        <li>{card.desc2}</li>
      </ul>
    </div>
  )
}
