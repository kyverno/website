import {
  cardColors1,
  heroSectionHeadingContent,
  whyKyvernoCards,
} from '../constants'

import { Button } from '../components/Button'
import { HeadingContent } from '../components/HeadingContent'
import { Tag } from '../components/Tag'
import { WhykyvCard } from '../components/WhykyvCard'
import { motion } from 'motion/react'

const containerVariants = {
  hidden: { opacity: 0 },
  visible: {
    opacity: 1,
    transition: {
      staggerChildren: 0.15,
      delayChildren: 0.1,
    },
  },
}

const fadeInUp = {
  hidden: { opacity: 0, y: 20 },
  visible: {
    opacity: 1,
    y: 0,
    transition: {
      duration: 0.6,
      ease: 'easeOut',
    },
  },
}

const fadeIn = {
  hidden: { opacity: 0 },
  visible: {
    opacity: 1,
    transition: {
      duration: 0.8,
      ease: 'easeOut',
    },
  },
}

export const HeroSection = () => {
  const { headingText, paragraphText } = heroSectionHeadingContent

  return (
    <section className="w-full bg-gradient-to-br from-dark-50 to-dark-100 relative pt-12 pb-12 sm:pt-20 sm:pb-16 px-6 sm:px-12 md:px-20">
      <motion.div
        className="container max-w-7xl mx-auto py-10 sm:py-0 flex flex-col justify-center items-center text-center space-y-8 relative z-10"
        variants={containerVariants}
        initial="hidden"
        animate="visible"
      >
        <motion.div variants={fadeInUp}>
          <HeadingContent
            headingParts={headingText}
            subheading={paragraphText}
            variant="level1"
            headerLevel="h1"
          />
        </motion.div>
        <motion.div
          className="w-full max-w-7xl mx-auto grid grid-cols-1 gap-4 md:grid-cols-3 md:gap-4"
          variants={fadeInUp}
        >
          {whyKyvernoCards.map((card, index) => (
            <motion.div
              key={index}
              className="flex h-full"
              variants={fadeInUp}
              whileHover={{ scale: 1.02 }}
              transition={{ duration: 0.2 }}
            >
              <WhykyvCard card={card} color={cardColors1[index]} />
            </motion.div>
          ))}
        </motion.div>
        <motion.div
          className="flex flex-col space-y-4 sm:flex-row sm:space-x-4 sm:space-y-0 mt-4"
          variants={fadeInUp}
        >
          <Button href="/docs/introduction" variant="primary" size="large">
            Get Started
          </Button>
          <Button href="#policy-showcase" variant="secondary" size="large">
            Explore Policies
          </Button>
        </motion.div>
        <motion.div
          className="flex items-center gap-4 flex-wrap justify-center mt-2 mb-4"
          variants={fadeIn}
        >
          <Tag
            variant="tertiary"
            href="https://nirmata.com/"
            className="bg-dark-50 border border-stroke text-white hover:text-white hover:border-primary-100 text-base sm:text-lg px-4 py-2 rounded-md transition-colors duration-200"
            target="_blank"
            rel="noopener noreferrer"
          >
            Created with ❤️ by Nirmata
          </Tag>
        </motion.div>
      </motion.div>
    </section>
  )
}
