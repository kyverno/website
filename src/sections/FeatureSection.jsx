import { cardColors2, features } from '../constants'
import { KyvernoFeatureCard } from '../components/KyvernoFeatureCard'

export const FeatureSection = () => {
  return (
    <section
      className="p-20 flex flex-col items-center space-y-5"
      id="features"
    >
      <div className="items-center flex flex-col space-y-6 my-5">
        <h2
          className="min-w-80 md:w-full text-4xl tracking-wide
                    capitalize text-center font-bold"
        >
          Complete Platform Engineering
          <span className="text-primary-100"> Policy As Code Solution</span>
        </h2>
        <p className="max-w-150 text-[1rem] sm:text-lg md:max-w-200 text-center text-white/80 ">
          From policy creation to enforcement, testing to reporting, and
          everything in between, get comprehensive Kubernetes governance and
          compliance with Kyverno.
        </p>
        <div
          className="flex flex-col items-center justify-center space-y-4 sm:flex-row sm:flex-wrap 
                    md:items-baseline sm:justify-center sm:space-x-4 px-10 mt-8"
        >
          {features.map((card, index) => (
            <KyvernoFeatureCard
              card={card}
              color={cardColors2[index]}
              key={index}
            />
          ))}
        </div>
      </div>
    </section>
  )
}
