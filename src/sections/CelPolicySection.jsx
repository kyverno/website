import { celPolicies, yamlCEL } from '../constants'
import { celPoliciesCardColors, yamlCelCardColors } from '../constants'
import { Button } from '../components/Button'
import { CelPolicyCards } from '../components/CelPolicyCards'
import { Tag } from '../components/Tag'
import { YamlVsCelCard } from '../components/YamlVsCelCard'
import { celPoliciesHeadingContent } from '../constants'
import { HeadingContent } from '../components/HeadingContent'

export const CelPolicySection = () => {
  const { headingText, paragraphText } = celPoliciesHeadingContent

  return (
    <section
      className="bg-dark-footer p-20 flex flex-col items-center space-y-5"
      id="policies"
    >
      <Tag variant="accent">New in v1.16</Tag>
      <HeadingContent
        headingParts={headingText}
        subheading={paragraphText}
        variant="level2"
        headerLevel="h2"
      />
      <div className="flex flex-col items-center mt-6">
        <h3 className="font-bold text-2xl">CEL Policy Types</h3>
        <div className="flex flex-col space-y-4 justify-center items-center md:flex-row md:flex-wrap sm:gap-4 sm:items-baseline sm:space-x-4 my-8">
          {celPolicies.map((card, index) => (
            <CelPolicyCards
              card={card}
              color={celPoliciesCardColors[index]}
              key={index}
            />
          ))}
        </div>
      </div>
      <div className="flex flex-col items-center space-y-6">
        <h3 className="font-bold text-2xl text-center">
          Validating policy in YAML vs CEL
        </h3>
        <div
          className="w-full sm:max-w-240 flex flex-col items-center space-y-4 
                     sm:flex-row sm:items-baseline sm:justify-center sm:space-x-6"
        >
          {yamlCEL.map((card, index) => (
            <YamlVsCelCard
              card={card}
              color={yamlCelCardColors[index]}
              key={index}
            />
          ))}
        </div>
        <Button variant="primary">Explore CEL Policies</Button>
      </div>
    </section>
  )
}
