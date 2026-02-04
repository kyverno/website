export const Button = ({
  children,
  href,
  variant = 'primary',
  size = 'medium',
  className = '',
  ...restProps
}) => {
  const baseStyles =
    'min-w-40 flex justify-center items-center py-2 px-3 rounded-md font-medium md:text-base transition-all duration-200 ease-in-out focus:outline-none focus:ring-2 focus:ring-primary-100 focus:ring-offset-2 focus:ring-offset-dark-100'

  const variantStyles = {
    primary:
      'bg-primary-100 text-white hover:bg-primary-75 hover:scale-105 active:scale-95',
    secondary:
      'border border-primary-100 text-theme-primary hover:border-primary-100 hover:bg-primary-100/10 hover:scale-105 active:scale-95',
    accent:
      'bg-accent-100 text-white hover:bg-accent-75 hover:scale-105 active:scale-95',
    accentSecondary:
      'border border-primary-100 text-theme-primary hover:border-accent-100 hover:bg-accent-100/10 hover:scale-105 active:scale-95',
  }

  const sizeStyles = {
    small: 'text-sm py-1.5 px-2.5',
    medium: 'text-base py-2 px-3',
    large: 'text-lg py-3 px-4',
  }

  const combinedClassName = `${baseStyles} ${variantStyles[variant]} ${sizeStyles[size]} ${className}`

  return (
    <a href={href} className={combinedClassName} {...restProps}>
      {children}
    </a>
  )
}
