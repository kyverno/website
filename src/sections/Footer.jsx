import { Github, Slack, Twitter, Mail } from 'lucide-react'
import {
  communityLinks,
  policies,
  supportLinks,
  ResourcesLinks,
} from '../constants'
import { SiteLogo } from '../components/SiteLogo'
import { BottomNavLinks } from '../components/BottomNavLinks'
import { BottomLinkLists } from '../components/BottomLinkLists'

export const Footer = () => {
  const currentYear = new Date().getFullYear()

  return (
    <footer className="flex flex-col items-start bg-dark-footer">
      <div className="w-full flex flex-col  p-12 space-y-6 md:space-y-0 md:flex-row md:justify-evenly text-[16px]">
        <div className="1/4 flex flex-col items-start space-y-4">
          <SiteLogo />
          <p className="max-w-80 text-white/80">
            Unified Policy as Code. Secure, automate, and govern your all
            infrastructure and applications with modern CEL-based policies.
          </p>
          <span className="flex justify-center items-center space-x-2 cursor-pointer">
            <a href="https://github.com/kyverno">
              <Github />
            </a>
            <a href="https://slack.k8s.io/#kyverno">
              <Slack />
            </a>
            <a href="https://twitter.com/kyverno">
              <Twitter />
            </a>
            <a href="https://groups.google.com/g/kyverno">
              <Mail />
            </a>
          </span>
        </div>
        <BottomLinkLists links={ResourcesLinks} title="Resources" />
        <BottomLinkLists links={communityLinks} title="Community" />
        <BottomLinkLists links={supportLinks} title="Support" />
      </div>
      <div
        className="w-full space-y-4 flex flex-col p-12 justify-between items-start md:items-center 
        border-t border-stroke text-white/80"
      >
        <ul className="flex items-center justify-between space-x-3">
          {policies.map(({ text, href }) => (
            <li key={text} className="hover:text-accent-100">
              <a href={href}>{text}</a>
            </li>
          ))}
        </ul>
        <p>&copy; {currentYear} Kyverno created by Nirmata.</p>
      </div>
    </footer>
  )
}
