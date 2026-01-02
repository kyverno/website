export const PartnersBrand = ({ name, image }) => {
  return (
    <span
      key={name}
      className="flex flex-col justify-baseline items-center space-y-3"
    >
      <img
        src={image}
        alt="product icons"
        className="w-6 h-6 sm:w-8 sm:h-8 md:w-10 md:h-10"
      />
      <span className="text-sm text-white/80 hidden sm:inline-block">
        {name}
      </span>
    </span>
  )
}
