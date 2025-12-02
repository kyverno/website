import { Tag } from '../components/Tag'
import { whyKyvernoCards, cardColors1 } from '../constants'
import { WhykyvCard } from '../components/WhykyvCard'

export const WhykyvernoSection = () => {
  return (
    <section
      className="p-20 flex flex-col items-center space-y-5"
      id="whykyverno"
    >
      <Tag variant="secondary">Created by Nirmata</Tag>
      <div className="items-center flex flex-col space-y-6 my-5">
        <h2
          className="text-4xl sm:text-4xl font-bold tracking-wide
                capitalize text-center"
        >
          Why
          <span className="text-primary-100"> Kyverno?</span>
        </h2>
        <p className="w-full text-[1rem] text-white/80 sm:text-lg md:w-150 lg:w-220 text-center ">
          Kyverno, created by Nirmata is the Kubernetes-native policy engine
          designed to simplify security, compliance, and automation by letting
          you manage policies the same way you manage your cluster.
        </p>
      </div>
      <div
        className="w-full flex flex-col space-y-4 justify-center md:flex-row md:flex-wrap md:content-baseline
            md:space-x-4 md:mt-8 lg:flex-nowrap"
      >
        {whyKyvernoCards.map((card, index) => (
          <WhykyvCard card={card} color={cardColors1[index]} key={index} />
        ))}
      </div>
    </section>
  )
}
