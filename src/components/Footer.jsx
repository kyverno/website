import { Github, Slack, Twitter, Mail } from "lucide-react"
import { communityLinks, policies, productsLinks, ResourcesLinks } from "../constants"


export const Footer = () => {

    const currentYear = new Date().getFullYear();

  return (
    <footer className="flex flex-col items-start bg-dark-footer">
        <div className="w-full flex flex-col  p-12 space-y-6 md:space-y-0 md:flex-row md:justify-evenly text-[16px]">
            <div className="1/4 flex flex-col items-start space-y-4">
                <span className="flex items-center justify-center space-x-2 ">
                    <img src="kyverno-logo.svg" alt="kyverno logo" className="w-8"/>
                    <span className="font-bold">Kyverno</span>
                </span>
                <p className="max-w-80 text-white/80">Unified Policy as Code for Platform Engineers. Secure, automate, and govern your infrastructure with next-generation CEL-based policies.</p>
                <span className="flex justify-center items-center space-x-2 cursor-pointer">
                    <Github />
                    <Slack />
                    <Twitter />
                    <Mail />
                </span>
            </div>
            <div className="1/4">
                <p className="font-bold">Products</p>
                <ul className="text-white/80 py-3 space-y-2">
                    {productsLinks.map(({text, href}) => (
                        <li key={text}><a href={href}>{text}</a></li>
                    ))}
                </ul>
            </div>
            <div className="1/4">
                <p className="font-bold">Resources</p>
                <ul className="text-white/80 py-3 space-y-2">
                    {ResourcesLinks.map(({text, href}) => (
                        <li key={text}><a href={href}>{text}</a></li>
                    ))}
                </ul>
            </div>
            <div className="1/4">
                <p className="font-bold">Community</p>
                <ul className="text-white/80 py-3 space-y-2">
                    {communityLinks.map(({text, href}) => (
                        <li key={text}><a href={href}>{text}</a></li>
                    ))}
                </ul>
            </div>
        </div>
        <div className="w-full space-y-4 flex flex-col p-12 justify-between items-start md:items-center 
        border-t border-stroke text-white/80">
            <ul className="flex items-center justify-between space-x-3">
                 {policies.map(({text, href}) => (
                        <li key={text} className="hover:text-accent-100"><a href={href}>{text}</a></li>
                ))}
            </ul>
            <p>&copy; {currentYear} Kyverno created by Nirmata.</p>
        </div>
    </footer>
  )
}

