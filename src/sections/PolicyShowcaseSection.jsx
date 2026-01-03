import { policyShowcaseHeadingContent, policyShowcaseTabs } from '../constants'
import { HeadingContent } from '../components/HeadingContent'
import { PolicyTabPanel } from '../components/PolicyTabPanel'

export const PolicyShowcaseSection = () => {
  const { headingText, paragraphText } = policyShowcaseHeadingContent

  return (
    <section
      className="bg-dark-footer p-12 sm:p-20 flex flex-col items-center space-y-8"
      id="policy-showcase"
    >
      <div className="w-full max-w-7xl mx-auto flex flex-col items-center space-y-4">
        <HeadingContent
          headingParts={headingText}
          subheading={paragraphText}
          variant="level2"
          headerLevel="h2"
        />

        <PolicyTabPanel tabs={policyShowcaseTabs} />
      </div>
    </section>
  )
}
