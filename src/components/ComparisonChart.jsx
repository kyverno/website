import { kyvernoVsOthers } from "../constants"

export const ComparisonChart = () => {
  return (
    <section className="flex flex-col justify-center items-center pb-6 px-6">
         <div className="items-center flex flex-col space-y-6 my-5">
                <h2 className="text-4xl font-bold tracking-wide
                capitalize text-center">
                    Kyverno Vs
                  <span className="text-primary-100"> Other policy engines</span>
                </h2>
                <p className="text-[1rem] w-80 sm:text-lg md:w-150 lg:w-220 text-center ">
                    As the industry's leading policy engine, here's how Kyverno 
                    compares with other policy engines.
                </p>
        </div>
        <div className="flex justify-center items-center w-full md:max-w-260 
        bg-dark-50 border border-stroke p-6 rounded-2xl sm:overflow-x-auto text-[16px]" >
          <table className="w-full p-12">
            <thead className="w-full hidden sm:table">
              <tr className="flex justify-start items-center">
                <th className="w-1/3 text-left">Feature</th>
                <th className="flex items-center flex-between space-x-4 w-1/3 pr-4">
                  <img src="assets/images/kyverno-square.svg" alt="kyverno logo" className="
                  h-6 w-6 sm:h-10 sm:w-10"/>
                  <span>Kyverno</span>
                </th>
                <th className="flex items-center flex-between space-x-6 sm:space-x-4 w-1/3">
                  <img src="assets/images/opa.svg" alt="opa logo" className="
                  h-6 w-6 sm:h-10 sm:w-10"/>
                  <span className="hidden sm:inline">Open Policy Agent</span>
                   <span className="sm:hidden">OPA</span>
                </th>
              </tr>
            </thead>
              <tbody className="w-full">
                {kyvernoVsOthers.map(({feature, kyverno, opa}) => (
                <tr key={feature} className="w-full flex flex-col sm:flex-row sm:justify-between items-start 
                sm:items-center mt-10 bg-stroke sm:bg-transparent rounded-2xl sm:odd:bg-stroke sm:odd:rounded-2xl ">
                  <td className="font-bold py-4 w-full sm:w-1/3 px-4 sm:px-0 sm:pl-6">{feature}</td>
                  <td className="flex items-center space-x-4 justify-start py-4 px-4 sm:px-0  w-full sm:w-1/3 pr-10">
                    <img src="assets/images/blue-ring.svg" alt="kyverno logo" className="w-4 h-4
                    sm:w-6 sm:h-6 hidden sm:inline" />
                    <img src="assets/images/kyverno-square.svg" alt="kyverno logo" className="w-4 h-4
                    sm:w-6 sm:h-6 sm:hidden" />
                    <span className="sm:text-wrap">{kyverno}</span>
                  </td>
                  <td className="flex items-center justify-start space-x-4 py-4 px-4 sm:px-0  w-full sm:w-1/3">
                    <img src="assets/images/red-ring.svg" alt="opa logo" className="w-4 h-4
                    sm:w-6 sm:h-6 hidden sm:inline"/>
                    <img src="assets/images/opa.svg" alt="kyverno logo" className="w-4 h-4
                    sm:w-6 sm:h-6 sm:hidden" />
                    <span className="text-wrap">{opa}</span>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
    </section>
  )
}

