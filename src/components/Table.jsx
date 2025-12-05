import { kyvernoVsOthers } from '../constants'

export const Table = () => {
  return (
    <table className="w-full">
      <thead className="w-full hidden sm:table-header-group">
        <tr className="w-full flex flex-col sm:flex-row sm:justify-between items-start sm:items-center bg-dark-50 rounded-t-2xl gap-4 sm:gap-8 min-h-[80px] py-4">
          <th className="font-bold w-full sm:w-1/4 px-4 sm:px-0 sm:pl-6 text-left flex items-center">
            Feature
          </th>
          <th className="flex items-center space-x-4 px-4 sm:px-0 sm:w-[37.5%]">
            <img
              src="assets/images/kyverno-square.svg"
              alt="kyverno logo"
              className="h-6 w-6 sm:h-10 sm:w-10 flex-shrink-0"
            />
            <span>Kyverno</span>
          </th>
          <th className="flex items-center space-x-4 px-4 sm:px-0 sm:w-[37.5%]">
            <img
              src="assets/images/opa.svg"
              alt="opa logo"
              className="h-6 w-6 sm:h-10 sm:w-10 flex-shrink-0"
            />
            <span className="hidden sm:inline">Open Policy Agent</span>
            <span className="sm:hidden">OPA</span>
          </th>
        </tr>
      </thead>
      <tbody className="w-full">
        {kyvernoVsOthers.map(({ feature, kyverno, opa }, index) => (
          <tr
            key={feature}
            className={`w-full flex flex-col sm:flex-row sm:justify-between items-start 
                sm:items-center gap-4 sm:gap-8 rounded-xl min-h-[80px] py-4 ${
                  index % 2 === 0 ? 'bg-stroke' : 'bg-dark-50'
                }`}
          >
            <td className="font-bold w-full sm:w-1/4 px-4 sm:px-0 sm:pl-6 flex items-center">
              {feature}
            </td>

            <td className="w-full sm:contents">
              <div className="flex flex-col sm:contents gap-4">
                {/* Kyverno */}
                <div className="flex items-center space-x-4 px-4 sm:px-0 sm:w-[37.5%]">
                  <img
                    src="assets/images/blue-ring.svg"
                    alt="kyverno logo"
                    className="w-6 h-6 flex-shrink-0 self-center hidden sm:inline"
                  />
                  <img
                    src="assets/images/kyverno-square.svg"
                    alt="kyverno logo"
                    className="w-6 h-6 flex-shrink-0 self-center sm:hidden"
                  />
                  <span className="leading-relaxed">{kyverno}</span>
                </div>

                {/* OPA */}
                <div className="flex items-center space-x-4 px-4 sm:px-0 sm:w-[37.5%]">
                  <img
                    src="assets/images/red-ring.svg"
                    alt="opa logo"
                    className="w-6 h-6 flex-shrink-0 self-center hidden sm:inline"
                  />
                  <img
                    src="assets/images/opa.svg"
                    alt="opa logo"
                    className="w-6 h-6 flex-shrink-0 self-center sm:hidden"
                  />
                  <span className="leading-relaxed">{opa}</span>
                </div>
              </div>
            </td>
          </tr>
        ))}
      </tbody>
    </table>
  )
}

// Section parent component
export const ComparisonSection = () => {
  return (
    <section className="flex flex-col justify-center items-center pb-6 px-6">
      <div className="w-full max-w-[1200px]">
        {/* Titre et description */}
        <div className="items-center flex flex-col space-y-6 my-5">
          <h2 className="text-4xl font-bold tracking-wide capitalize text-center">
            Kyverno Vs
            <span className="text-primary-100"> Other policy engines</span>
          </h2>
          <p className="min-w-80 text-[1rem] w-80 sm:text-lg sm:min-w-150 text-center text-white/80">
            As the industry's leading policy engine, here's how Kyverno compares
            with other policy engines.
          </p>
        </div>

        {/* Tableau */}
        <div className="flex justify-center items-center w-full bg-dark-50 border border-stroke p-6 rounded-2xl sm:overflow-x-auto text-[16px] mt-8">
          <Table />
        </div>
      </div>
    </section>
  )
}
