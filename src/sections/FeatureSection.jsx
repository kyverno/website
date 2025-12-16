import {
  cardColors2,
  features,
  featureSectionHeadingContent,
} from '../constants'
import { KyvernoFeatureCard } from '../components/KyvernoFeatureCard'
import { HeadingContent } from '../components/HeadingContent'

export const FeatureSection = () => {
  const { headingText, paragraphText } = featureSectionHeadingContent

  return (
    <section
      className="py-20 px-4 md:p-20 flex flex-col items-center space-y-5"
      id="features"
    >
      <div className="items-center flex flex-col space-y-6 my-5">
        <HeadingContent
          headingParts={headingText}
          subheading={paragraphText}
          variant="level2"
          headerLevel="h2"
        />
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
