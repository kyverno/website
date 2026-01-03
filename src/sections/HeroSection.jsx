import {
  heroSectionHeadingContent,
  heroTags,
  whyKyvernoCards,
  cardColors1,
} from '../constants'

import { Button } from '../components/Button'
import { HeadingContent } from '../components/HeadingContent'
import { Tag } from '../components/Tag'
import { WhykyvCard } from '../components/WhykyvCard'
import { Zap } from 'lucide-react'
import { motion } from 'motion/react'

export const HeroSection = () => {
  const zapIcon = Zap

  const { headingText, paragraphText } = heroSectionHeadingContent

  return (
    <section className="w-full bg-linear-to-br from-dark-50 to-dark-100 relative pt-10 pb-12 sm:pt-20 sm:px-20 sm:pb-20 place-items-center">
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
            items-center text-center space-y-2"
      >
        <HeadingContent
          headingParts={headingText}
          subheading={paragraphText}
          variant="level1"
          headerLevel="h1"
        />
        <div
          className="w-full max-w-7xl mx-auto flex flex-col space-y-4 justify-center md:flex-row md:flex-wrap md:content-baseline
            md:space-x-4 md:mt-2 lg:flex-nowrap"
        >
          {whyKyvernoCards.map((card, index) => (
            <WhykyvCard card={card} color={cardColors1[index]} key={index} />
          ))}
        </div>
        <div className="flex flex-col space-y-4 sm:flex-row sm:space-x-4 sm:space-y-0">
          <Button href="/docs/introduction" variant="primary" size="large">
            Get Started
          </Button>
          <Button
            href="https://playground.kyverno.io/"
            variant="secondary"
            size="large"
          >
            Explore Kyverno
          </Button>
        </div>
        <div className="flex items-center gap-4 flex-wrap justify-center mt-6 mb-8 sm:mb-12">
          <Tag
            variant="secondary"
            href="https://nirmata.com/"
            className="bg-white text-dark-100 text-xl"
            target="_blank"
            rel="noopener noreferrer"
          >
            Created with ❤️ at Nirmata
          </Tag>
        </div>
      </div>
    </section>
  )
}
