
export const TopNavLinks = ({links, handleScroll }) => {
  return (
    <ul className='flex flex-col text-lg space-y-6 justify-between items-center lg:flex-row lg:space-y-0 
    lg:text-base lg:space-x-12 xl:text-lg'>
      {links.map((item, index) => (
        <li key={index} className='hover:text-accent-100 active:text-accent-50'>
          {handleScroll ? <a href={`#${item.targetId}`} onClick={(e) => handleScroll(e, item.targetId)}>
                {item.label}
          </a> : <a href={item.href}>{item.label}</a>}
        </li>
      ))}
  </ul>
  )
}

