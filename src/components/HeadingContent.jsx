import PropTypes from 'prop-types'

export const HeadingContent = ({
  headingParts,
  subheading,
  variant,
  headerLevel,
  ...restProps
}) => {
  const HeaderTag = headerLevel

  const getVariantClasses = (type) => {
    switch (variant) {
      case 'level1':
        return type === 'header'
          ? `w-full inline-flex flex-wrap justify-center items-center gap-x-2
                        text-5xl px-2 sm:text-[52px] md:text-6xl font-bold tracking-wide text-primary-100 
                        capitalize leading-12 sm:leading-16`
          : 'text-[1.4rem] sm:text-xl md:text-2xl max-w-[90%] sm:max-w-[600px] md:max-w-[700px] leading-8 sm:leading-9 md:leading-10 text-white/80'

      case 'level2':
        return type === 'header'
          ? 'text-4xl font-bold tracking-wide capitalize text-center'
          : 'max-w-150 text-[1.2rem] sm:text-xl md:text-xl md:max-w-250 text-center text-white/80'

      case 'level3':
        return type === 'header'
          ? 'text-3xl sm:text-3xl font-bold tracking-wide capitalize text-center'
          : 'text-[1rem] sm:text-lg md:text-xl max-w-80 sm:max-w-150 leading-6 text-white/80'
    }
  }

  const processHeading = (text) => {
    return text.map((part, index) => (
      <span
        key={index}
        className={`${part.color} ${index < text.length - 1 ? 'mr-2' : ''}`}
      >
        {part.text}
      </span>
    ))
  }

  return (
    <div
      className={`items-center flex flex-col ${variant === 'level1' ? 'space-y-8' : 'space-y-4'} my-5 ${variant}`}
    >
      <HeaderTag className={`header-style ${getVariantClasses('header')}`}>
        {processHeading(headingParts)}
      </HeaderTag>
      <p
        className={`w-full text-[1rem] text-white/80 sm:text-lg md:w-150 lg:w-220 text-center ${getVariantClasses('paragraph')}`}
      >
        {subheading}
      </p>
    </div>
  )
}

HeadingContent.propTypes = {
  headingParts: PropTypes.string.isRequired,
  subheading: PropTypes.string.isRequired,
  headerLevel: PropTypes.oneOf[('h1', 'h2', 'h3', 'h4', 'h5', 'h6')],
  variant: PropTypes.oneOf(['level1', 'level2', 'level3']),
}
