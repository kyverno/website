import { partners, partnersSectionHeadingContent } from '../constants'
import { PartnersBrand } from '../components/PartnersBrand'
import { Button } from '../components/Button'
import { HeadingContent } from '../components/HeadingContent'

export const PartnersSection = () => {
  const { headingText, paragraphText } = partnersSectionHeadingContent

  return (
    <section className="w-full flex flex-col items-center text-center space-y-12 p-12 my-6">
      <div className="space-y-3 text-lg">
        <HeadingContent
          headingParts={headingText}
          subheading={paragraphText}
          variant="level3"
          headerLevel="h3"
        />
      </div>
      <div className="w-full flex gap-y-6 space-x-3 flex-wrap items-center justify-around lg:gap-y-0">
        {partners.map(({ image, name }) => (
          <PartnersBrand image={image} name={name} key={name} />
        ))}
      </div>
      <p className="text-white/80">
        Join 1000+ organizations using Kyverno in production environments
      </p>
      <Button variant="accent">Join us</Button>
    </section>
  )
}
