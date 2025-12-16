export const CncfSection = () => {
  return (
    <section className="p-12 flex flex-col items-center space-y-12 text-center bg-dark-50 py-16">
      <h2 className="text-2xl font-bold text-primary-100">
        Kyverno is a CNCF Incubating Project
      </h2>
      <img
        src="/public/assets/images/cncf.png"
        alt="cncf logo"
        className="w-120"
      />
      <p className="max-w-100">
        The Linux Foundation® (TLF) has registered trademarks and uses
        trademarks. For a list of TLF trademarks, see Trademark Usage.
      </p>
    </section>
  )
}
