import { twMerge } from "tailwind-merge";

export const CelPolicyCards = ({card, color}) => {
  return (
    <div key={card.title} className="bg-dark-50 p-4 rounded-2xl border border-stroke flex flex-col 
    space-y-4 sm:space-y-8 w-full md:w-1/3 text-sm sm:text-[1rem] md:text-[13px] lg:text-sm pt-8 min-w-0 h-70 lg:h-60 ">
            <span className={twMerge("w-8 h-8 rounded-lg flex justify-center items-center", color.bg)}>
                <card.icon className = "w-4 text-white"/>
            </span>
            <h3 className="font-bold">{card.title}</h3>
            <p className="text-white/80">{card.description}</p>
    </div>
  )
}

