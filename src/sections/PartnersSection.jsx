import { partners } from '../constants'
import { PartnersBrand } from '../components/PartnersBrand'
import { Button } from '../components/Button'

export const PartnersSection = () => {
  return (
    <section className="w-full flex flex-col items-center text-center space-y-12 p-12 my-6">
      <div className="space-y-3 text-lg">
        <h3 className="font-bold text-2xl">Trusted By Industry Leaders</h3>
        <p className="text-white/80">
          Powering policy management for organizations worldwide
        </p>
      </div>
      <div className="w-full flex gap-y-6 space-x-3 flex-wrap items-center justify-around lg:gap-y-0">
        {partners.map(({ image, name }) => (
          <PartnersBrand image={image} name={name} key={name} />
        ))}
      </div>
      <p className="text-white/80">
        Join 1000+ organizations using Kyverno in production environments
      </p>
      <Button variant="accent">Join us</Button>
    </section>
  )
}
