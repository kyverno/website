import React from 'react'
import { twMerge } from 'tailwind-merge'

export const KyvernoFeatureCard = ({ card, color }) => {
  return (
    <div
      key={card.title}
      className="bg-dark-50 p-4 rounded-2xl border border-stroke flex flex-col 
    space-y-4 w-full sm:space-y-8 md:w-1/3 md:space-y-4 lg:w-1/4 pt-8 h-60 transition-all duration-200 ease-in-out hover:border-primary-100/50 hover:shadow-lg hover:shadow-primary-100/10"
    >
      <span
        className={twMerge(
          'w-8 h-8 rounded-lg flex justify-center items-center',
          color.bg,
        )}
      >
        <card.icon className={twMerge('w-4', color.text)} />
      </span>
      <h3 className="font-bold text-theme-primary">{card.title}</h3>
      <p className="text-sm text-theme-secondary">{card.details}</p>
    </div>
  )
}
