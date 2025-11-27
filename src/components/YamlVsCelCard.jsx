import { twMerge } from "tailwind-merge";

export const YamlVsCelCard = ({card, color}) => {
  return (
    <div className="w-[80%] overflow-x-clip sm:w-1/3 md:w-1/2 bg-dark-50 rounded-2xl sm:h-130">
        <div className={twMerge("p-4 text-sm md:text-[16px] text-center text-dark-100 rounded-tl-2xl rounded-tr-2xl flex items-center justify-start space-x-2", color.bg)}>
             <card.icon className="w-4 h-4"/>
             <span className="font-bold">{card.title}</span>
        </div>
        <p className="whitespace-pre p-6 sm:pr-20 text-left text-[10px] sm:text-sm ">{card.content}</p>
    </div>
  )
}

