import { useEffect, useRef, useState } from 'react'
import { partners, partnersSectionHeadingContent } from '../constants'
import { PartnersBrand } from '../components/PartnersBrand'
import { Button } from '../components/Button'
import { HeadingContent } from '../components/HeadingContent'

export const PartnersSection = () => {
  const { headingText, paragraphText } = partnersSectionHeadingContent

  const containerRef = useRef(null)
  const trackRef = useRef(null)
  const firstSetRef = useRef(null)
  const secondSetRef = useRef(null)

  const singleSetWidthRef = useRef(0)
  const xRef = useRef(0)
  const isDraggingRef = useRef(false)
  const hasDraggedRef = useRef(false)
  const pointerStartXRef = useRef(0)
  const dragStartXRef = useRef(0)
  const isHoveredRef = useRef(false)
  const isFocusedRef = useRef(false)
  const isWheelingRef = useRef(false)
  const wheelTimeoutRef = useRef(null)
  const reducedMotionRef = useRef(false)

  const [isDraggingState, setIsDraggingState] = useState(false)

  const wrapOffset = (val, setWidth) => {
    if (!setWidth || setWidth <= 0) return val
    let wrapped = val % setWidth
    if (wrapped > 0) {
      wrapped -= setWidth
    }
    return wrapped
  }

  const applyTransform = (x) => {
    if (trackRef.current) {
      trackRef.current.style.transform = `translate3d(${x}px, 0, 0)`
    }
  }

  useEffect(() => {
    // Check reduced motion preference
    const mediaQuery = window.matchMedia('(prefers-reduced-motion: reduce)')
    reducedMotionRef.current = mediaQuery.matches

    const handleMotionChange = (e) => {
      reducedMotionRef.current = e.matches
    }
    mediaQuery.addEventListener('change', handleMotionChange)

    const updateSetWidth = () => {
      if (firstSetRef.current && secondSetRef.current) {
        const measured =
          secondSetRef.current.offsetLeft - firstSetRef.current.offsetLeft
        if (measured > 0) {
          singleSetWidthRef.current = measured
        }
      }
    }

    updateSetWidth()

    const resizeObserver = new ResizeObserver(() => {
      updateSetWidth()
      if (singleSetWidthRef.current > 0) {
        xRef.current = wrapOffset(xRef.current, singleSetWidthRef.current)
        applyTransform(xRef.current)
      }
    })

    if (firstSetRef.current) {
      resizeObserver.observe(firstSetRef.current)
    }

    let animationFrameId
    let lastTime = performance.now()

    const animate = (currentTime) => {
      const dt = (currentTime - lastTime) / 1000
      lastTime = currentTime

      const isInteracting =
        isHoveredRef.current ||
        isDraggingRef.current ||
        isFocusedRef.current ||
        isWheelingRef.current

      if (
        !isInteracting &&
        !reducedMotionRef.current &&
        singleSetWidthRef.current > 0
      ) {
        // Scroll through one full cycle of logos every 30 seconds
        const speed = singleSetWidthRef.current / 30
        xRef.current -= speed * dt
        xRef.current = wrapOffset(xRef.current, singleSetWidthRef.current)
        applyTransform(xRef.current)
      }

      animationFrameId = requestAnimationFrame(animate)
    }

    animationFrameId = requestAnimationFrame(animate)

    // Wheel event handler with non-passive listener to prevent horizontal scroll chaining
    const container = containerRef.current
    const handleWheel = (e) => {
      if (Math.abs(e.deltaX) > Math.abs(e.deltaY)) {
        e.preventDefault()
        if (singleSetWidthRef.current > 0) {
          xRef.current -= e.deltaX
          xRef.current = wrapOffset(xRef.current, singleSetWidthRef.current)
          applyTransform(xRef.current)
        }

        isWheelingRef.current = true
        if (wheelTimeoutRef.current) {
          clearTimeout(wheelTimeoutRef.current)
        }
        wheelTimeoutRef.current = setTimeout(() => {
          isWheelingRef.current = false
          lastTime = performance.now()
        }, 500)
      }
    }

    if (container) {
      container.addEventListener('wheel', handleWheel, { passive: false })
    }

    return () => {
      cancelAnimationFrame(animationFrameId)
      mediaQuery.removeEventListener('change', handleMotionChange)
      resizeObserver.disconnect()
      if (container) {
        container.removeEventListener('wheel', handleWheel)
      }
      if (wheelTimeoutRef.current) {
        clearTimeout(wheelTimeoutRef.current)
      }
    }
  }, [])

  const handlePointerDown = (e) => {
    // Only respond to primary button (e.g. left mouse button) or touch/pen
    if (e.button !== 0 && e.pointerType === 'mouse') return

    isDraggingRef.current = true
    setIsDraggingState(true)
    pointerStartXRef.current = e.clientX
    dragStartXRef.current = xRef.current
    hasDraggedRef.current = false

    try {
      e.currentTarget.setPointerCapture(e.pointerId)
    } catch {}
  }

  const handlePointerMove = (e) => {
    if (!isDraggingRef.current) return

    const dx = e.clientX - pointerStartXRef.current
    if (Math.abs(dx) > 4) {
      hasDraggedRef.current = true
    }

    if (singleSetWidthRef.current > 0) {
      const nextX = dragStartXRef.current + dx
      xRef.current = wrapOffset(nextX, singleSetWidthRef.current)
      applyTransform(xRef.current)
    }
  }

  const handlePointerUpOrCancel = (e) => {
    if (!isDraggingRef.current) return

    isDraggingRef.current = false
    setIsDraggingState(false)

    // On touch devices, clear hover state after touch release
    if (e.pointerType === 'touch') {
      isHoveredRef.current = false
    }

    try {
      e.currentTarget.releasePointerCapture(e.pointerId)
    } catch {}
  }

  const handleClickCapture = (e) => {
    if (hasDraggedRef.current) {
      e.preventDefault()
      e.stopPropagation()
      hasDraggedRef.current = false
    }
  }

  const handleKeyDown = (e) => {
    if (e.key === 'ArrowLeft') {
      e.preventDefault()
      const step = 140
      if (singleSetWidthRef.current > 0) {
        xRef.current = wrapOffset(
          xRef.current + step,
          singleSetWidthRef.current,
        )
        applyTransform(xRef.current)
      }
    } else if (e.key === 'ArrowRight') {
      e.preventDefault()
      const step = 140
      if (singleSetWidthRef.current > 0) {
        xRef.current = wrapOffset(
          xRef.current - step,
          singleSetWidthRef.current,
        )
        applyTransform(xRef.current)
      }
    }
  }

  return (
    <>
      <noscript>
        <style>{`
          .partner-carousel-track {
            animation: scroll-logos 30s linear infinite;
          }
          .partner-carousel-track:hover {
            animation-play-state: paused;
          }
          @keyframes scroll-logos {
            0% {
              transform: translateX(0);
            }
            100% {
              transform: translateX(-50%);
            }
          }
        `}</style>
      </noscript>
      <section className="w-full flex flex-col items-center text-center space-y-8 p-12 sm:p-16 md:p-20">
        <div className="w-full max-w-7xl mx-auto flex flex-col items-center space-y-4">
          <HeadingContent
            headingParts={headingText}
            subheading={paragraphText}
            variant="level3"
            headerLevel="h3"
          />
        </div>
        <div
          ref={containerRef}
          tabIndex={0}
          role="region"
          aria-label="Partner and customer logos"
          aria-roledescription="carousel"
          aria-keyshortcuts="ArrowLeft ArrowRight"
          onPointerDown={handlePointerDown}
          onPointerMove={handlePointerMove}
          onPointerUp={handlePointerUpOrCancel}
          onPointerCancel={handlePointerUpOrCancel}
          onMouseEnter={() => {
            isHoveredRef.current = true
          }}
          onMouseLeave={() => {
            isHoveredRef.current = false
          }}
          onFocus={() => {
            isFocusedRef.current = true
          }}
          onBlur={() => {
            isFocusedRef.current = false
          }}
          onKeyDown={handleKeyDown}
          onClickCapture={handleClickCapture}
          className={`w-full overflow-hidden select-none rounded-lg focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-theme-accent focus-visible:ring-offset-2 ${
            isDraggingState ? 'cursor-grabbing' : 'cursor-grab'
          }`}
          style={{
            touchAction: 'pan-y',
            userSelect: 'none',
            WebkitUserSelect: 'none',
          }}
        >
          <span className="sr-only">
            Interactive customer and partner logo carousel. Use left and right
            arrow keys to scroll manually.
          </span>
          <div
            ref={trackRef}
            className="flex gap-8 md:gap-12 items-center w-max will-change-transform partner-carousel-track"
          >
            {/* Primary set of logos (announced by screen readers) */}
            <div
              ref={firstSetRef}
              className="flex gap-8 md:gap-12 items-center flex-shrink-0"
            >
              {partners.map(({ image, name }, index) => (
                <PartnersBrand
                  image={image}
                  name={name}
                  key={`first-${name}-${index}`}
                  isDuplicate={false}
                />
              ))}
            </div>
            {/* Duplicate sets for seamless looping across any viewport size (hidden from screen readers) */}
            {[1, 2, 3].map((setIndex) => (
              <div
                key={`set-${setIndex}`}
                ref={setIndex === 1 ? secondSetRef : undefined}
                className="flex gap-8 md:gap-12 items-center flex-shrink-0"
                aria-hidden="true"
              >
                {partners.map(({ image, name }, index) => (
                  <PartnersBrand
                    image={image}
                    name={name}
                    key={`duplicate-${setIndex}-${name}-${index}`}
                    isDuplicate={true}
                  />
                ))}
              </div>
            ))}
          </div>
        </div>
        <p className="text-theme-secondary text-base sm:text-lg">
          Join 1000+ organizations using Kyverno in production environments
        </p>
        <Button href="/community/#join-kyverno-adopters" variant="accent">
          Join the Policy as Code Revolution!
        </Button>
      </section>
    </>
  )
}
