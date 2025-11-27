import React from 'react'
import { twMerge } from "tailwind-merge";


export const KyvernoFeatureCard = ({card, color}) => {
  return (
    <div key={card.title} className="bg-dark-50 p-4 rounded-2xl border border-stroke flex flex-col 
    space-y-4 w-full sm:space-y-8 md:w-1/3 md:space-y-4 lg:w-1/4 pt-8 h-60">
            <span className={twMerge("w-8 h-8 rounded-lg flex justify-center items-center", color.bg)}>
                <card.icon className = {twMerge("w-4", color.text)}/>
            </span>
            <h3 className="font-bold">{card.title}</h3>
            <p className="text-sm text-white/80">{card.details}</p>
    </div>
  )
}



