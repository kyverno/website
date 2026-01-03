export const CncfSection = () => {
  return (
    <section className="w-full p-12 sm:p-16 md:p-20 flex flex-col items-center space-y-8 text-center bg-dark-50">
      <div className="w-full max-w-7xl mx-auto flex flex-col items-center space-y-8">
        <h2 className="text-2xl sm:text-3xl font-bold text-primary-100">
          Kyverno is a CNCF Incubating Project
        </h2>
        <img
          src="assets/images/cncf.png"
          alt="CNCF logo"
          className="w-120"
          loading="lazy"
        />
        <p className="text-base sm:text-lg text-white/90 max-w-100">
          The Linux Foundation® (TLF) has registered trademarks and uses
          trademarks. For a list of TLF trademarks, see Trademark Usage.
        </p>
      </div>
    </section>
  )
}
