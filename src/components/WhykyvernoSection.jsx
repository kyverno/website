
import { whyKyvernoCards } from "../constants";
import { twMerge } from "tailwind-merge";



export const WhykyvernoSection = () => {

    return (
        <section className="p-20 flex flex-col items-center space-y-5" id="whykyverno">
            <div className="text-sm capitalize w-40 h-8 bg-primary-50
            rounded-full text-dark-100 font-bold flex justify-center items-center">
                created by Nirmata
            </div> 
            <div className="items-center flex flex-col space-y-6 my-5">
                <h2 className="text-4xl sm:text-4xl font-bold tracking-wide
                capitalize text-center">
                    Why
                  <span className="text-primary-100"> Kyverno?</span>
                </h2>
                <p className="w-full text-[1rem] sm:text-lg md:w-150 lg:w-220 text-center ">
                    Kyverno, created by Nirmata is the Kubernetes-native policy 
                    engine designed to simplify security, compliance, and 
                    automation by letting you manage policies the same way 
                    you manage your cluster.
                </p>
                <div className="flex flex-col space-y-4 md:flex-row md:content-baseline justify-center 
                md:justify-center md:space-x-4">
                    {whyKyvernoCards.map((card) => (
                        <div key={card.title} className="bg-dark-50 p-4 rounded-2xl border 
                        border-stroke flex flex-col space-y-4 w-full md:w-1/3 xl:w-1/5 md:h-70 py-8">
                            <span className={twMerge("w-8 h-8 rounded-lg flex justify-center items-center",
                                card.color === 'blue' && 'bg-blue-900/70',
                                card.color === 'orange' && 'bg-orange-900/70',
                                card.color === 'green' && 'bg-green-900/70',
                                card.color === 'purple' && 'bg-purple-900/70'
                             )}>
                                <card.icon className = {twMerge("w-4",
                                card.color === 'blue' && 'text-blue-300',
                                card.color === 'orange' && 'text-orange-300',
                                card.color === 'green' && 'text-green-300',
                                card.color === 'purple' && 'text-purple-300'
                                 )}/>
                            </span>
                            <h3 className={twMerge("w-40 text-md font-bold text-center rounded-full border my-4 px-1",
                                card.color === 'blue' && 'text-blue-300 bg-blue-900/80 border-blue-500',
                                card.color === 'orange' && 'text-orange-300 bg-orange-900/80 border-orange-500',
                                card.color === 'green' && 'text-green-300 bg-green-900/80 border-green-500',
                                card.color === 'purple' && 'text-purple-300 bg-purple-900/80 border-purple-500'
                                 )}>{card.title}</h3>
                            <ul className="text-left text-sm list-[square] space-y-3 p-4">
                                <li>{card.desc1}</li>
                                <li>{card.desc2}</li>
                            </ul>
                        </div>
                    ))}
                </div>
            </div>
        </section>
    )
}