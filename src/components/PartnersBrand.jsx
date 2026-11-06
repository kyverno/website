export const PartnersBrand = ({ name, image, isDuplicate = false }) => {
  return (
    <div
      className="flex flex-col justify-center items-center space-y-3 flex-shrink-0 min-w-[100px] md:min-w-[140px] select-none"
      aria-hidden={isDuplicate ? 'true' : undefined}
    >
      <img
        src={image}
        alt={isDuplicate ? '' : `${name} logo`}
        draggable={false}
        className={`w-12 h-12 sm:w-16 sm:h-16 md:w-20 md:h-20 lg:w-24 lg:h-24 object-contain transition-all duration-200 select-none ${
          name === 'Adidas'
            ? 'invert dark:invert-0 opacity-90 hover:opacity-100'
            : 'opacity-80 hover:opacity-100'
        }`}
        loading="lazy"
      />

      <span
        aria-hidden="true"
        className="text-sm text-theme-secondary hidden md:inline-block select-none"
      >
        {name}
      </span>
    </div>
  )
}
