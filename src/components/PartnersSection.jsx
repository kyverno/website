import { partners } from "../constants"

export const PartnersSection = () => {
  return (
    <section className="w-full flex flex-col items-center text-center space-y-12 pb-12 my-6">
        <div className="space-y-3 text-lg">
            <h3 className="font-bold">Trusted By Industry Leaders</h3>
            <p className="text-white/80">Powering policy management for organizations worldwide</p>
        </div>
        <div className="w-full flex flec-col sm:flex-row justify-between items-end">
            {partners.map(({image, name}) => (
            <span key={name} className="flex flex-col justify-baseline items-center space-y-3">
                <img src={image} alt="product icons" className="w-6 h-6 sm:w-8 sm:h-8
                md:w-10 md:h-10"/>
                <span className="text-sm text-white/80 hidden sm:inline-block">{name}</span>
            </span>
            ))}   
        </div>
        <p className="text-white/80">Join 1000+ organizations using Kyverno in production environments</p>
    </section>
  )
}

export default PartnersSection