/**
 * Kyverno Design Tokens
 *
 * Centralized design system tokens for consistent styling across the application.
 * These tokens define spacing, colors, typography, and component standards.
 */

// Spacing Scale (8px base unit)
export const spacing = {
  xs: '0.5rem', // 8px
  sm: '1rem', // 16px
  md: '1.5rem', // 24px
  lg: '2rem', // 32px
  xl: '3rem', // 48px
  '2xl': '4rem', // 64px
  '3xl': '5rem', // 80px
}

// Section Padding Standards
export const sectionPadding = {
  mobile: 'p-12', // px-6 py-12
  tablet: 'sm:p-16', // px-8 py-16
  desktop: 'md:p-20', // px-20 py-20
  horizontal: 'px-6 sm:px-12 md:px-20',
  vertical: 'py-12 sm:py-16 md:py-20',
  standard: 'p-12 sm:p-16 md:p-20',
}

// Container Max-Width
export const container = {
  maxWidth: 'max-w-7xl',
  center: 'mx-auto',
  standard: 'max-w-7xl mx-auto',
}

// Vertical Spacing
export const verticalSpacing = {
  section: 'space-y-8', // Major sections
  subsection: 'space-y-4', // Subsections
  card: 'space-y-3', // Card content
}

// Color Tokens (matching theme.css)
// Note: These are dark mode defaults. Light mode colors are defined in global.css
// and automatically applied via CSS custom properties when data-theme='light'
export const colors = {
  // Dark mode colors (default) - for backward compatibility
  primary: {
    100: '#3783c4', // primary-100
    75: '#69a2d3', // primary-75
    50: '#9bc1e1', // primary-50
    25: '#cde0f0', // primary-25
  },
  accent: {
    100: '#e77e5b', // accent-100
    75: '#ed9e84', // accent-75
    50: '#f3bfad', // accent-50
    25: '#f9dfd6', // accent-25
  },
  dark: {
    100: '#12171b', // dark-100 (main background)
    50: '#171e22', // dark-50 (cards/sections)
    footer: '#0d1012', // dark-footer
  },
  stroke: '#28353c', // border color
  text: {
    primary: 'text-white',
    secondary: 'text-white/90', // Better contrast than /80
    tertiary: 'text-white/80',
  },
  // Light mode colors (reference only - actual colors come from CSS variables)
  // Note: Uses the same blue and orange as dark mode for brand consistency
  light: {
    primary: {
      100: '#3783c4', // primary-100 (same as dark mode)
      75: '#69a2d3', // primary-75 (same as dark mode)
      50: '#9bc1e1', // primary-50 (same as dark mode)
      25: '#cde0f0', // primary-25 (same as dark mode)
    },
    accent: {
      100: '#e77e5b', // accent-100 (same as dark mode)
      75: '#ed9e84', // accent-75 (same as dark mode)
      50: '#f3bfad', // accent-50 (same as dark mode)
      25: '#f9dfd6', // accent-25 (same as dark mode)
    },
    background: {
      100: '#ffffff', // light-100 (main background)
      50: '#f5f7fa', // light-50 (cards/sections)
      footer: '#f0f2f5', // light-footer
    },
    stroke: '#e5e7eb', // border color
    text: {
      primary: 'text-gray-900',
      secondary: 'text-gray-800', // Better contrast
      tertiary: 'text-gray-700',
    },
  },
}

// Typography Scale
export const typography = {
  h1: {
    mobile: 'text-5xl',
    tablet: 'sm:text-[52px]',
    desktop: 'md:text-6xl',
    weight: 'font-bold',
    lineHeight: 'leading-12 sm:leading-16',
  },
  h2: {
    size: 'text-4xl',
    weight: 'font-bold',
  },
  h3: {
    size: 'text-3xl',
    weight: 'font-bold',
  },
  body: {
    base: 'text-base',
    large: 'text-lg',
    small: 'text-sm',
  },
}

// Card Color Schemes (Standardized)
export const cardColors = {
  // Primary card scheme (3 colors for hero cards)
  primary: [
    { bg: 'bg-orange-900/70', text: 'text-orange-300' },
    { bg: 'bg-green-900/70', text: 'text-green-300' },
    { bg: 'bg-purple-900/70', text: 'text-purple-300' },
  ],
  // Feature card scheme (extended palette)
  feature: [
    { bg: 'bg-blue-900/70', text: 'text-blue-300' },
    { bg: 'bg-orange-900/70', text: 'text-orange-300' },
    { bg: 'bg-yellow-900/70', text: 'text-yellow-300' },
    { bg: 'bg-green-900/70', text: 'text-green-300' },
    { bg: 'bg-purple-900/70', text: 'text-purple-300' },
    { bg: 'bg-cyan-900/70', text: 'text-cyan-300' },
    { bg: 'bg-indigo-900/70', text: 'text-indigo-300' },
    { bg: 'bg-amber-900/70', text: 'text-amber-300' },
    { bg: 'bg-lime-900/70', text: 'text-lime-300' },
  ],
  // CEL Policy cards (solid backgrounds)
  cel: [
    { bg: 'bg-blue-900' },
    { bg: 'bg-orange-900' },
    { bg: 'bg-green-900' },
    { bg: 'bg-purple-900' },
    { bg: 'bg-red-900' },
  ],
}

// Button Usage Guidelines
export const buttonUsage = {
  primary: {
    variant: 'primary',
    usage: 'Main CTAs (Get Started, Sign Up)',
    href: '/docs/introduction',
  },
  secondary: {
    variant: 'secondary',
    usage: 'Secondary actions (Learn More, Explore)',
    href: '/policies',
  },
  accent: {
    variant: 'accent',
    usage: 'Special emphasis (Join Community, Limited Offers)',
  },
}

// Transitions & Animations
export const transitions = {
  standard: 'transition-all duration-200 ease-in-out',
  hover: 'hover:transition-all hover:duration-200 hover:ease-in-out',
  focus:
    'focus:outline-none focus:ring-2 focus:ring-primary-100 focus:ring-offset-2 focus:ring-offset-dark-100',
}

// Responsive Breakpoints
export const breakpoints = {
  sm: '640px', // sm:
  md: '768px', // md:
  lg: '1024px', // lg:
  xl: '1280px', // xl:
}

// Accessibility Standards
export const accessibility = {
  minTextSize: 'text-base', // 16px minimum for readability
  contrast: {
    normal: 'text-white/90', // 4.5:1 contrast ratio
    large: 'text-white', // 3:1 for large text
  },
  focusRing:
    'focus:outline-none focus:ring-2 focus:ring-primary-100 focus:ring-offset-2',
}
