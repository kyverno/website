import { useEffect, useRef, useState } from 'react'
import { partners, partnersSectionHeadingContent } from '../constants'
import { PartnersBrand } from '../components/PartnersBrand'
import { Button } from '../components/Button'
import { HeadingContent } from '../components/HeadingContent'

const KEYBOARD_STEP = 140

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
  const updateAnimationLoopRef = useRef(null)

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
      updateAnimationLoop()
    }
    if (mediaQuery.addEventListener) {
      mediaQuery.addEventListener('change', handleMotionChange)
    } else if (mediaQuery.addListener) {
      mediaQuery.addListener(handleMotionChange)
    }

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

    const handleResize = () => {
      updateSetWidth()
      if (singleSetWidthRef.current > 0) {
        xRef.current = wrapOffset(xRef.current, singleSetWidthRef.current)
        applyTransform(xRef.current)
      }
    }

    let resizeObserver = null
    if (typeof ResizeObserver !== 'undefined' && firstSetRef.current) {
      resizeObserver = new ResizeObserver(handleResize)
      resizeObserver.observe(firstSetRef.current)
    } else if (typeof window !== 'undefined') {
      window.addEventListener('resize', handleResize)
    }

    let animationFrameId = null
    let lastTime = performance.now()
    let isIntersecting = false
    let isDocumentVisible =
      typeof document !== 'undefined'
        ? document.visibilityState !== 'hidden'
        : true

    const checkShouldRun = () => {
      const isInteracting =
        isHoveredRef.current ||
        isDraggingRef.current ||
        isFocusedRef.current ||
        isWheelingRef.current

      return (
        isIntersecting &&
        isDocumentVisible &&
        !reducedMotionRef.current &&
        !isInteracting &&
        singleSetWidthRef.current > 0
      )
    }

    const animate = (currentTime) => {
      if (!checkShouldRun()) {
        animationFrameId = null
        return
      }

      const dt = (currentTime - lastTime) / 1000
      lastTime = currentTime

      // Scroll through one full cycle of logos every 30 seconds
      const speed = singleSetWidthRef.current / 30
      xRef.current -= speed * dt
      xRef.current = wrapOffset(xRef.current, singleSetWidthRef.current)
      applyTransform(xRef.current)

      animationFrameId = requestAnimationFrame(animate)
    }

    const updateAnimationLoop = () => {
      if (checkShouldRun()) {
        if (!animationFrameId) {
          lastTime = performance.now()
          animationFrameId = requestAnimationFrame(animate)
        }
      } else {
        if (animationFrameId) {
          cancelAnimationFrame(animationFrameId)
          animationFrameId = null
        }
      }
    }

    updateAnimationLoopRef.current = updateAnimationLoop

    const handleVisibilityChange = () => {
      isDocumentVisible = document.visibilityState !== 'hidden'
      updateAnimationLoop()
    }

    document.addEventListener('visibilitychange', handleVisibilityChange)

    let intersectionObserver = null
    if (typeof IntersectionObserver !== 'undefined' && containerRef.current) {
      intersectionObserver = new IntersectionObserver(([entry]) => {
        isIntersecting = entry.isIntersecting
        updateAnimationLoop()
      })
      intersectionObserver.observe(containerRef.current)
    } else {
      isIntersecting = true
      updateAnimationLoop()
    }

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
        updateAnimationLoop()
        if (wheelTimeoutRef.current) {
          clearTimeout(wheelTimeoutRef.current)
        }
        wheelTimeoutRef.current = setTimeout(() => {
          isWheelingRef.current = false
          updateAnimationLoop()
        }, 500)
      }
    }

    if (container) {
      container.addEventListener('wheel', handleWheel, { passive: false })
    }

    return () => {
      updateAnimationLoopRef.current = null
      if (animationFrameId) {
        cancelAnimationFrame(animationFrameId)
      }
      if (mediaQuery.removeEventListener) {
        mediaQuery.removeEventListener('change', handleMotionChange)
      } else if (mediaQuery.removeListener) {
        mediaQuery.removeListener(handleMotionChange)
      }
      if (resizeObserver) {
        resizeObserver.disconnect()
      } else if (typeof window !== 'undefined') {
        window.removeEventListener('resize', handleResize)
      }
      if (intersectionObserver) {
        intersectionObserver.disconnect()
      }
      document.removeEventListener('visibilitychange', handleVisibilityChange)
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
    updateAnimationLoopRef.current?.()

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
    updateAnimationLoopRef.current?.()

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
      if (singleSetWidthRef.current > 0) {
        xRef.current = wrapOffset(
          xRef.current + KEYBOARD_STEP,
          singleSetWidthRef.current,
        )
        applyTransform(xRef.current)
      }
    } else if (e.key === 'ArrowRight') {
      e.preventDefault()
      if (singleSetWidthRef.current > 0) {
        xRef.current = wrapOffset(
          xRef.current - KEYBOARD_STEP,
          singleSetWidthRef.current,
        )
        applyTransform(xRef.current)
      }
    }
  }

  return (
    <>
      <noscript
        dangerouslySetInnerHTML={{
          __html: `<style>
            .partner-carousel-track {
              --carousel-gap: 2rem;
              gap: var(--carousel-gap);
              animation: scroll-logos 30s linear infinite;
            }
            @media (min-width: 768px) {
              .partner-carousel-track {
                --carousel-gap: 3rem;
              }
            }
            .partner-carousel-track:hover {
              animation-play-state: paused;
            }
            @media (prefers-reduced-motion: reduce) {
              .partner-carousel-track {
                animation: none;
              }
            }
            @keyframes scroll-logos {
              0% {
                transform: translateX(0);
              }
              100% {
                transform: translateX(calc(-25% - var(--carousel-gap) / 4));
              }
            }
          </style>`,
        }}
      />
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
          aria-describedby="partner-carousel-instructions"
          onPointerDown={handlePointerDown}
          onPointerMove={handlePointerMove}
          onPointerUp={handlePointerUpOrCancel}
          onPointerCancel={handlePointerUpOrCancel}
          onMouseEnter={() => {
            isHoveredRef.current = true
            updateAnimationLoopRef.current?.()
          }}
          onMouseLeave={() => {
            isHoveredRef.current = false
            updateAnimationLoopRef.current?.()
          }}
          onFocus={() => {
            isFocusedRef.current = true
            updateAnimationLoopRef.current?.()
          }}
          onBlur={() => {
            isFocusedRef.current = false
            updateAnimationLoopRef.current?.()
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
          <span id="partner-carousel-instructions" className="sr-only">
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
