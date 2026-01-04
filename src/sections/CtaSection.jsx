import { Button } from '../components/Button'
import { motion } from 'motion/react'
import { HeadingContent } from '../components/HeadingContent'
import { ctaSectionHeadingContent } from '../constants'

const fadeInUp = {
  hidden: { opacity: 0, y: 20 },
  visible: {
    opacity: 1,
    y: 0,
    transition: { duration: 0.6, ease: 'easeOut' },
  },
}

export const CtaSection = () => {
  const { headingText, paragraphText } = ctaSectionHeadingContent

  return (
    <motion.section
      className="w-full p-12 sm:p-16 md:p-20 flex flex-col space-y-8 bg-dark-50 items-center"
      initial="hidden"
      whileInView="visible"
      viewport={{ once: true, amount: 0.3 }}
      variants={fadeInUp}
    >
      <div className="w-full max-w-7xl mx-auto flex flex-col items-center space-y-8">
        <HeadingContent
          headingParts={headingText}
          subheading={paragraphText}
          variant="level3"
          headerLevel="h3"
        />
        <div className="flex flex-col space-y-4 sm:flex-row sm:space-x-4 sm:space-y-0">
          <Button href="docs/introduction" variant="primary">
            Get Started
          </Button>
          <Button href="docs/applying-policies/" variant="secondary">
            Explore Policies
          </Button>
        </div>
      </div>
    </motion.section>
  )
}
