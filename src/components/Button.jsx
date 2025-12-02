export const Button = ({
  children,
  href,
  variant = 'primary',
  size = 'medium',
  className = '',
  ...restProps
}) => {
  const baseStyles =
    'min-w-40 flex justify-center items-center py-2 px-3 rounded-md font-medium md:text-base'

  const variantStyles = {
    primary:
      'bg-primary-100 text-white hover:bg-blue-50 hover:text-primary-100',
    secondary: 'border border-primary-100 text-white hover:border-white',
    accent: 'bg-accent-100 text-white hover:bg-accent-50 hover:text-dark-100',
    accentSecondary:
      'border border-primary-100 text-white hover:border-accent-25',
  }

  const sizeStyles = {
    small: 'text-sm',
    medium: 'text-base',
    large: 'text-lg',
  }

  const combinedClassName = `${baseStyles} ${variantStyles[variant]} ${sizeStyles[size]} 
    } ${className}`

  return (
    <a href={href} className={combinedClassName} {...restProps}>
      {children}
    </a>
  )
}
