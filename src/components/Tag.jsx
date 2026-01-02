import React from 'react'

export const Tag = ({ children, Icon, variant, className, ...restProps }) => {
  const baseStyles =
    'min-w-40 py-2 px-3 flex justify-center items-center space-x-2 rounded-4xl font-bold text-sm'

  const variantStyles = {
    primary: 'bg-primary-100 text-white',
    secondary: 'bg-primary-50 text-dark-100',
    accent: 'bg-accent-25 text-accent-100',
    tertiary: 'border border-stroke text-sm text-white/70 font-medium',
  }

  const combinedClassName = `${baseStyles} ${variantStyles[variant]} ${className}`

  return (
    <div className={combinedClassName}>
      {Icon && <Icon className="w-5 h-5" />}
      <span>{children}</span>
    </div>
  )
}
