import kyvernoLogo from '../assets/images/kyverno-logo.svg'

export const SiteLogo = () => {
  return (
    <a href="/" className="flex space-x-3 hover:text-accent-100 cursor-pointer">
      <img src={kyvernoLogo.src} alt="kyverno logo" className="w-8 h-8" />
      <span className="text-xl tracking-tight font-bold">Kyverno</span>
    </a>
  )
}
