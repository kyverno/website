
export const TopNavLinks = ({links, handleScroll }) => {
  return (
    <ul className='flex lg:flex justify-between items-center space-x-12'>
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

