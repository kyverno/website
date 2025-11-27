
export const BottomNavLinks = ({links}) => {
  return (
    <ul className="text-white/80 py-3 space-y-2">
            {links.map(({text, href}) => (
                <li key={text}><a href={href}>{text}</a></li>
            ))}
    </ul>
  )
}

