import { celPolicies, yamlCEL } from "../constants";
import { twMerge } from "tailwind-merge";

export const CelPolicySection = () => {
  return (
    <section className="p-20 flex flex-col items-center space-y-5" id="policies">
            <div className="text-sm capitalize w-40 h-8 bg-accent-25
            rounded-full text-accent-100 font-bold flex justify-center items-center">
               New in v1.16
            </div> 
            <div className="items-center flex flex-col space-y-6 my-5">
                <h2 className="text-4xl sm:text-4xl font-bold tracking-wide
                capitalize text-center">
                    Introducing
                  <span className="text-primary-100"> CEL Polices</span>
                </h2>
                <p className="w-80 text-[1rem] sm:text-lg sm:w-150 lg:w-220 text-center ">
                    CEL (Common Expression Language) policies bring powerful, 
                    fine-grained control to Kyverno, enabling users to write more 
                    expressive and dynamic policy rules without sacrificing performance. 
                </p>
                </div>
                <div className="flex flex-col items-center">
                    <h3 className="font-bold">CEL Policy Types</h3>
                    <div className="flex flex-col space-y-4 justify-center items-center md:flex-row md:flex-wrap sm:gap-4 sm:items-baseline sm:space-x-4 my-8">
                        {celPolicies.map((card) => (
                            <div key={card.title} className="bg-dark-50 p-4 rounded-2xl border 
                            border-stroke flex flex-col space-y-4 sm:space-y-8 w-full md:w-1/3 pt-8 
                            min-w-0 h-70 lg:h-60 text-sm sm:text-[1rem]">
                                <span className={twMerge("w-8 h-8 rounded-lg flex justify-center items-center",
                                    card.color === 'blue' && 'bg-blue-900',
                                    card.color === 'orange' && 'bg-orange-900',
                                    card.color === 'green' && 'bg-green-900',
                                    card.color === 'purple' && 'bg-purple-900',
                                    card.color === 'red' && 'bg-red-900'
                                )}>
                                    <card.icon className = "w-4 text-white"/>
                                </span>
                                <h3 className="font-bold">{card.title}</h3>
                                <p className="text-white/80">{card.description}</p>
                            </div>
                        ))}
                    </div> 
                </div>
                <div className="flex flex-col items-center space-y-6">
                     <h3 className="font-bold">Validating poliy in YAML vs CEL</h3>
                     <div className="w-full sm:max-w-240 flex flex-col items-center space-y-4 
                     sm:flex-row sm:items-baseline sm:justify-center sm:space-x-6">
                        {yamlCEL.map((card) => (
                            <div className="w-[80%] overflow-x-clip sm:w-1/3 md:w-1/2 bg-dark-50 rounded-2xl sm:h-130" key={card.title}>
                                <div className=
                                {twMerge("p-4 text-sm md:text-[16px] text-center text-dark-100 rounded-tl-2xl rounded-tr-2xl flex items-center justify-start space-x-2",
                                card.color === "light-blue" && "bg-primary-50",
                                card.color === "deep-blue" && "bg-primary-100"
                             )}>
                                    <card.icon className="w-4 h-4"/>
                                    <span className="font-bold">{card.title}</span>
                            </div>
                            <p className="whitespace-pre p-6 sm:pr-20 text-left text-[10px] sm:text-sm ">{card.content}</p>
                        </div>
                        ))}
                     </div>
                     <a href="#" className='w-50 h-10 flex justify-center items-center py-2 
                        px-3 bg-primary-100 text-white rounded-md hover:border hover:bg-white hover:text-primary-100'>
                        Explore CEL Policies
                    </a>
                </div>
        </section>
  )
}

