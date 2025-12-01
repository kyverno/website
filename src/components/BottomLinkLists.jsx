import { BottomNavLinks } from "./BottomNavLinks"

export const BottomLinkLists = ({links, title}) => {
  return (
      <div className="1/4">
        <p className="font-bold">{title}</p>
        <BottomNavLinks links={links}/>
     </div>
  )
}
