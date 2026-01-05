import {
  celPolicies,
  celPoliciesCardColors,
  celPoliciesHeadingContent,
  yamlCEL,
  yamlCelCardColors,
} from '../constants'

import { Button } from '../components/Button'
import { CelPolicyCards } from '../components/CelPolicyCards'
import { HeadingContent } from '../components/HeadingContent'
import { YamlCodeBlock } from '../components/YamlCodeBlock'

export const CelPolicySection = () => {
  const { headingText, paragraphText } = celPoliciesHeadingContent

  return (
    <section
      className="w-full bg-dark-footer p-12 sm:p-16 md:p-20 flex flex-col items-center space-y-8"
      id="policies"
    >
      <div className="w-full max-w-7xl mx-auto flex flex-col items-center space-y-8">
        <HeadingContent
          headingParts={headingText}
          subheading={paragraphText}
          variant="level2"
          headerLevel="h2"
        />
        <div className="w-full flex flex-col items-center space-y-8">
          <h3 className="font-bold text-2xl text-white">CEL Policy Types</h3>
          <div className="w-full flex flex-col space-y-4 justify-center items-center md:flex-row md:flex-wrap sm:gap-4 sm:items-baseline sm:space-x-4">
            {celPolicies.map((card, index) => (
              <CelPolicyCards
                card={card}
                color={celPoliciesCardColors[index]}
                key={index}
              />
            ))}
          </div>
        </div>
        <div className="w-full flex flex-col items-center space-y-8">
          <h3 className="font-bold text-2xl text-center text-white">
            Validating policy in YAML vs CEL
          </h3>
          <div
            className="w-full max-w-7xl flex flex-col items-center space-y-4 
                       sm:flex-row sm:items-baseline sm:justify-center sm:space-x-6"
          >
            {yamlCEL.map((card, index) => (
              <YamlCodeBlock
                key={index}
                code={card.content}
                showCopyButton={true}
                header={{
                  icon: card.icon,
                  title: card.title,
                }}
                headerColor={yamlCelCardColors[index]?.bg}
              />
            ))}
          </div>
          <Button href="/policies" variant="primary">
            Explore CEL Policies
          </Button>
        </div>
      </div>
    </section>
  )
}
