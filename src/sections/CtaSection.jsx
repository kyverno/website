import { Button } from '../components/Button'
import { motion } from 'motion/react'
import { HeadingContent } from '../components/HeadingContent'
import { ctaSectionHeadingContent } from '../constants'

const containerVariants = {
  hidden: { opacity: 0 },
  visible: { opacity: 1, transition: { straggerChildren: 0.2 } },
}

const fadeInUp = {
  hidden: { opacity: 0, y: 20 },
  visible: { opacity: 1, y: 0, transition: { duration: 0.6 } },
}

const fadeIn = {
  hidden: { opacity: 0 },
  visible: { opacity: 1, transition: { duration: 0.6 } },
}

export const CtaSection = () => {
  const { headingText, paragraphText } = ctaSectionHeadingContent

  return (
    <motion.section className="w-full p-16 md:p-20 flex flex-col space-y-8 bg-dark-50 items-center">
      <div className="space-y-3 flex flex-col justify-center items-center">
        <HeadingContent
          headingParts={headingText}
          subheading={paragraphText}
          variant="level3"
          headerLevel="h3"
        />
      </div>
      <div className="flex flex-col space-y-4 sm:flex-row sm:space-x-4 sm:space-y-0">
        <Button href="docs/introduction" variant="primary">
          Get Started
        </Button>
        <Button href="https://kyverno.io/policies/" variant="secondary">
          Explore Policies
        </Button>
      </div>
    </motion.section>
  )
}
