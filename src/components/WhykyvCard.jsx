import React from 'react'
import { twMerge } from 'tailwind-merge'

export const WhykyvCard = ({ card, color }) => {
  return (
    <div
      key={card.title}
      className="bg-dark-50 p-4 rounded-2xl border 
   border-stroke flex flex-col space-y-4 w-full md:w-1/3 xl:w-1/5 md:h-70 py-8"
    >
      <span
        className={twMerge(
          'w-8 h-8 p-2 rounded-md flex justify-center items-center',
          color.bg,
        )}
      >
        <card.icon className={twMerge('w-4 h-4', color.text)} />
      </span>
      <h3
        className={twMerge(
          'w-40 text-md font-bold text-center rounded-full border my-4 px-1',
          color.bg,
          color.text,
        )}
      >
        {card.title}
      </h3>
      <ul className="text-left text-sm list-[square] space-y-3 p-4">
        <li>{card.desc1}</li>
        <li>{card.desc2}</li>
      </ul>
    </div>
  )
}
