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
      className="w-full p-12 sm:p-16 md:p-20 flex flex-col items-center space-y-8"
      id="features"
    >
      <div className="w-full max-w-7xl mx-auto flex flex-col items-center space-y-8">
        <HeadingContent
          headingParts={headingText}
          subheading={paragraphText}
          variant="level2"
          headerLevel="h2"
        />
        <div
          className="w-full flex flex-col items-center justify-center space-y-4 sm:flex-row sm:flex-wrap 
                    md:items-baseline sm:justify-center sm:space-x-4"
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
