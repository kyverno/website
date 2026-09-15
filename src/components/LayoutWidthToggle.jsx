import { Maximize2, Minimize2 } from 'lucide-react'

import React from 'react'
import { useLayoutWidth } from '../hooks/useLayoutWidth'

export const LayoutWidthToggle = () => {
  const { layoutWidth, toggleLayoutWidth, mounted } = useLayoutWidth()

  if (!mounted) {
    return (
      <button
        className="p-2 rounded-lg border border-stroke text-theme-primary hover:bg-dark-50 transition-colors duration-200"
        aria-label="Toggle layout width"
        disabled
      >
        <Minimize2 className="w-5 h-5" />
      </button>
    )
  }

  const isFluid = layoutWidth === 'fluid'

  return (
    <button
      onClick={toggleLayoutWidth}
      className="p-2 rounded-lg border border-stroke text-theme-primary hover:bg-dark-50 transition-colors duration-200 focus:outline-none focus:ring-2 focus:ring-primary-100 focus:ring-offset-2"
      aria-label={isFluid ? 'Switch to fixed width' : 'Switch to fluid width'}
      title={isFluid ? 'Switch to fixed width' : 'Switch to fluid width'}
    >
      {isFluid ? (
        <Minimize2 className="w-5 h-5" />
      ) : (
        <Maximize2 className="w-5 h-5" />
      )}
    </button>
  )
}
