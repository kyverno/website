export const BottomNavLinks = ({ links }) => {
  return (
    <ul className="text-theme-secondary py-3 space-y-2">
      {links.map(({ text, href, target }) => {
        // Default to _blank for external links (http/https) if target is not specified
        const linkTarget =
          target ||
          (href.startsWith('http://') || href.startsWith('https://')
            ? '_blank'
            : undefined)
        return (
          <li key={text}>
            <a href={href} target={linkTarget}>
              {text}
            </a>
          </li>
        )
      })}
    </ul>
  )
}
