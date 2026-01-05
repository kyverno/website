export const PartnersBrand = ({ name, image }) => {
  return (
    <div className="flex flex-col justify-center items-center space-y-3 flex-shrink-0 min-w-[100px] md:min-w-[140px]">
      <img
        src={image}
        alt={`${name} logo`}
        className="w-12 h-12 sm:w-16 sm:h-16 md:w-20 md:h-20 lg:w-24 lg:h-24 object-contain opacity-80 hover:opacity-100 transition-opacity duration-200"
        loading="lazy"
      />
      <span className="text-sm text-white/90 hidden md:inline-block">
        {name}
      </span>
    </div>
  )
}
