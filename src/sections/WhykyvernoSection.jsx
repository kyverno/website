import {
  whyKyvernoCards,
  cardColors1,
  whykyvernoHeadingContent,
} from '../constants'
import { WhykyvCard } from '../components/WhykyvCard'
import { HeadingContent } from '../components/HeadingContent'

export const WhykyvernoSection = () => {
  const { headingText, paragraphText } = whykyvernoHeadingContent

  return (
    <section
      className="w-full p-12 sm:p-16 md:p-20 flex flex-col items-center space-y-8"
      id="whykyverno"
    >
      <div className="w-full max-w-7xl mx-auto flex flex-col items-center space-y-8">
        <HeadingContent
          headingParts={headingText}
          subheading={paragraphText}
          variant="level2"
          headerLevel="h2"
        />
        <div
          className="w-full flex flex-col space-y-4 justify-center md:flex-row md:flex-wrap md:content-baseline
            md:space-x-4 lg:flex-nowrap"
        >
          {whyKyvernoCards.map((card, index) => (
            <WhykyvCard card={card} color={cardColors1[index]} key={index} />
          ))}
        </div>
      </div>
    </section>
  )
}
