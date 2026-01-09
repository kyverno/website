import { partners, partnersSectionHeadingContent } from '../constants'
import { PartnersBrand } from '../components/PartnersBrand'
import { Button } from '../components/Button'
import { HeadingContent } from '../components/HeadingContent'

export const PartnersSection = () => {
  const { headingText, paragraphText } = partnersSectionHeadingContent

  return (
    <>
      <style>{`
        @keyframes scroll-logos {
          0% {
            transform: translateX(0);
          }
          100% {
            transform: translateX(-50%);
          }
        }
        .animate-scroll-logos {
          animation: scroll-logos 30s linear infinite;
        }
        .animate-scroll-logos:hover {
          animation-play-state: paused;
        }
      `}</style>
      <section className="w-full flex flex-col items-center text-center space-y-8 p-12 sm:p-16 md:p-20">
        <div className="w-full max-w-7xl mx-auto flex flex-col items-center space-y-4">
          <HeadingContent
            headingParts={headingText}
            subheading={paragraphText}
            variant="level3"
            headerLevel="h3"
          />
        </div>
        <div className="w-full overflow-hidden">
          <div className="flex animate-scroll-logos gap-8 md:gap-12 items-center w-max">
            {/* First set of logos */}
            {partners.map(({ image, name }, index) => (
              <PartnersBrand
                image={image}
                name={name}
                key={`first-${name}-${index}`}
              />
            ))}
            {/* Duplicate set for seamless loop */}
            {partners.map(({ image, name }, index) => (
              <PartnersBrand
                image={image}
                name={name}
                key={`second-${name}-${index}`}
              />
            ))}
          </div>
        </div>
        <p className="text-white/90 text-base sm:text-lg">
          Join 1000+ organizations using Kyverno in production environments
        </p>
        <Button href="community/#join-kyverno-adopters" variant="accent">
          Join the Policy as Code Revolution!
        </Button>
      </section>
    </>
  )
}
