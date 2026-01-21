import React from 'react'

export const Tag = ({
  children,
  Icon,
  variant,
  className,
  href,
  ...restProps
}) => {
  const baseStyles =
    'min-w-40 py-2 px-3 flex justify-center items-center space-x-2 rounded-4xl font-bold text-sm transition-all duration-200 ease-in-out focus:outline-none focus:ring-2 focus:ring-primary-100 focus:ring-offset-2 focus:ring-offset-dark-100'

  const variantStyles = {
    primary: 'bg-primary-100 text-white hover:bg-primary-75',
    secondary: 'bg-primary-50 text-dark-100 hover:bg-primary-25',
    accent: 'bg-accent-25 text-accent-100 hover:bg-accent-50',
    tertiary:
      'border border-stroke text-sm text-theme-secondary font-medium hover:border-primary-100',
  }

  const combinedClassName = `${baseStyles} ${variantStyles[variant]} ${href ? 'cursor-pointer hover:scale-105 active:scale-95' : ''} ${className || ''}`

  const content = (
    <>
      {Icon && <Icon className="w-5 h-5" />}
      <span>{children}</span>
    </>
  )

  if (href) {
    return (
      <a href={href} className={combinedClassName} {...restProps}>
        {content}
      </a>
    )
  }

  return (
    <div className={combinedClassName} {...restProps}>
      {content}
    </div>
  )
}
