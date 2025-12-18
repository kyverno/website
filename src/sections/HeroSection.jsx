import { heroSectionHeadingContent, heroTags } from '../constants'

import { Button } from '../components/Button'
import { HeadingContent } from '../components/HeadingContent'
import { Tag } from '../components/Tag'
import { Zap } from 'lucide-react'
import { motion } from 'motion/react'

export const HeroSection = () => {
  const zapIcon = Zap

  const { headingText, paragraphText } = heroSectionHeadingContent

  return (
    <section className="w-full bg-linear-to-br from-dark-50 to-dark-100 relative py-10 px-4 sm:p-20">
      <img
        src="assets/images/lg-hero-ball.svg"
        alt="lg-hero-ball"
        className="
            hidden sm:inline-block absolute sm:top-20 sm:left-8 lg:top-20 
            lg:left-20"
      />
      <img
        src="assets/images/sm-hero-ball.svg"
        alt="sm-hero-ball"
        className="hidden
            sm:inline-block absolute sm:right-15 sm:top-50 md:right-25
            lg:top-50 lg:right-50 xl:right-90 "
      />

      <div
        className="container py-10 sm:py-0 sm:px-10 flex flex-col justify-center 
            items-center text-center space-y-6"
      >
        <Tag variant="primary" Icon={zapIcon}>
          Introducing CEL Policies
        </Tag>
        <HeadingContent
          headingParts={headingText}
          subheading={paragraphText}
          variant="level1"
          headerLevel="h1"
        />
        <div
          className="flex flex-col justify-center items-center lg:flex-row space-y-3 lg:justify-between 
                lg:items-baseline lg:space-x-3"
        >
          {heroTags.map((tag) => (
            <Tag Icon={tag.icon} variant="tertiary" key={tag.title}>
              {tag.title}
            </Tag>
          ))}
        </div>
        <div className="flex flex-col space-y-4 sm:flex-row sm:space-x-4 sm:space-y-0">
          <Button href="/docs/quickstart" variant="primary" size="large">
            Quickstart
          </Button>
          <Button href="/docs/introduction" variant="secondary" size="large">
            Read Documentation
          </Button>
        </div>
      </div>
    </section>
  )
}
