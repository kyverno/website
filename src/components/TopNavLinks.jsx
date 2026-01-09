export const TopNavLinks = ({ links, handleScroll }) => {
  return (
    <ul
      className="flex flex-col text-lg space-y-6 justify-between items-center lg:flex-row lg:space-y-0 
    lg:text-base lg:space-x-12 xl:text-lg"
    >
      {links.map((item, index) => (
        <li key={index} className="hover:text-accent-100 active:text-accent-50">
          <a
            href={item.href}
            onClick={
              handleScroll ? (e) => handleScroll(e, item.href) : undefined
            }
          >
            {item.label}
          </a>
        </li>
      ))}
    </ul>
  )
}
