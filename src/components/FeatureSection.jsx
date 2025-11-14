import { features } from "../constants";
import { twMerge } from "tailwind-merge";

export const FeatureSection = () => {
  return (
     <section className="p-20 flex flex-col items-center space-y-5" id="features">
                <div className="items-center flex flex-col space-y-6 my-5">
                    <h2 className="w-100 md:w-full text-4xl tracking-wide
                    capitalize text-center font-bold">
                        Complete Platform Engineering
                      <span className="text-primary-100">  Policy As Code Solution</span>
                    </h2>
                    <p className="w-100 text-[1rem] sm:text-lg sm:w-220 text-center ">
                       From policy creation to enforcement, testing to reporting, and everything in between,
                       get comprehensive Kubernetes governance and compliance with Kyverno.
                    </p>
                    <div className="flex flex-col items-center justify-center space-y-4 sm:flex-row sm:flex-wrap 
                    md:items-baseline sm:justify-center sm:space-x-4 px-10">
                        {features.map((card) => (
                            <div key={card.title} className="bg-dark-50 p-4 rounded-2xl border 
                            border-stroke flex flex-col space-y-4 w-full sm:space-y-8 md:w-1/3 md:space-y-4 
                            lg:w-1/4 pt-8 h-60">
                                <span className={twMerge("w-8 h-8 rounded-lg flex justify-center items-center",
                                    card.color === 'blue' && 'bg-blue-900/70',
                                    card.color === 'orange' && 'bg-orange-900/70',
                                    card.color === 'yellow' && 'bg-yellow-900/70',
                                    card.color === 'green' && 'bg-green-900/70',
                                    card.color === 'purple' && 'bg-purple-900/70',
                                    card.color === 'cyan' && 'bg-cyan-900/70',
                                    card.color === 'lime' && 'bg-lime-900/70',
                                    card.color === 'indigo' && 'bg-indigo-900/70',
                                    card.color === 'amber' && 'bg-amber-900/70',

                                 )}>
                                    <card.icon className = {twMerge("w-4",
                                    card.color === 'blue' && 'text-blue-300',
                                    card.color === 'orange' && 'text-orange-300',
                                    card.color === 'green' && 'text-green-300',
                                    card.color === 'purple' && 'text-purple-300',
                                    card.color === 'yellow' && 'text-yellow-300',
                                    card.color === 'cyan' && 'text-cyan-300',
                                    card.color === 'indigo' && 'text-indigo-300',
                                    card.color === 'amber' && 'text-amber-300',
                                    card.color === 'lime' && 'text-lime-300'
                                     )}/>
                                </span>
                                <h3 className="font-bold">{card.title}</h3>
                                <p className="text-sm text-white/80">{card.details}</p>
                            </div>
                        ))}
                    </div>
                </div>
            </section>
        )
    }
  